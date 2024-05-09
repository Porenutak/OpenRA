#region Copyright & License Information
/*
 * Copyright 2007-2020 The OpenRA Developers (see AUTHORS)
 * This file is part of OpenRA, which is free software. It is made
 * available to you under the terms of the GNU General Public License
 * as published by the Free Software Foundation, either version 3 of
 * the License, or (at your option) any later version. For more
 * information, see COPYING.
 */
#endregion

using System.Collections.Generic;
using System.Linq;
using System;
using OpenRA.Mods.Common;
using OpenRA.Mods.Common.Traits;
using OpenRA.Primitives;
using OpenRA.Traits;
using System.Xml.Schema;

namespace OpenRA.Mods.Common.Traits
{
	[Desc("Attach this to the player actor (not a building!) to define a new shared build queue.",
		"Will only work together with the StartProductionProduction: trait on the actor that actually does the production.",
		"You will also want to add PrimaryBuildings: to let the user choose where new units should exit.")]
	public class BulkProductionQueueInfo : ProductionQueueInfo, Requires<TechTreeInfo>, Requires<PlayerResourcesInfo>
	{

		[Desc("Maximum deliver capacity")]
		public readonly int MaxCapacity = 6;

		[Desc("Notification played when deliver started")]
		public readonly string StartDeliveryAudio = null;

		[Desc("Notification displayed when deliver started")]
		public readonly string StartDeliveryNotification = null;

		public override object Create(ActorInitializer init) { return new BulkProductionQueue(init, this); }
	}

	public class BulkProductionQueue : ProductionQueue
	{
		static readonly ActorInfo[] NoItems = { };

		readonly Actor self;
		readonly BulkProductionQueueInfo info;

		readonly List<int> actorsTotalCost = new();
		protected readonly List<ActorInfo> ActorsReadyForDelivery = new();
		protected readonly List<TypeDictionary> ActorsInits = new();

		protected bool deliveryProcessStarted = false;
		public BulkProductionQueue(ActorInitializer init, BulkProductionQueueInfo info)
			: base(init, info)
		{
			self = init.Self;
			this.info = info;
		}

		protected override void Tick(Actor self)
		{
			// PERF: Avoid LINQ.
			Enabled = false;
			var isActive = false;
			foreach (var x in self.World.ActorsWithTrait<Production>())
			{
				if (x.Trait.IsTraitDisabled)
					continue;

				if (x.Actor.Owner != self.Owner || !x.Trait.Info.Produces.Contains(Info.Type))
					continue;

				Enabled |= IsValidFaction;
				isActive |= !x.Trait.IsTraitPaused;
			}

			if (!Enabled)
				ClearQueue();

			TickInner(self, !isActive);
		}

		public override IEnumerable<ActorInfo> AllItems()
		{
			return Enabled ? base.AllItems() : NoItems;
		}

		public override IEnumerable<ActorInfo> BuildableItems()
		{
			return Enabled && ActorsReadyForDelivery.Count != info.MaxCapacity && !deliveryProcessStarted ? base.AllItems() : NoItems;
		}

		public override TraitPair<Production> MostLikelyProducer()
		{
			var productionActor = self.World.ActorsWithTrait<Production>()
				.Where(x => x.Actor.Owner == self.Owner
					&& !x.Trait.IsTraitDisabled && x.Trait.Info.Produces.Contains(Info.Type))
				.OrderBy(x => x.Trait.IsTraitPaused)
				.ThenByDescending(x => x.Actor.Trait<PrimaryBuilding>().IsPrimary)
				.ThenByDescending(x => x.Actor.ActorID)
				.FirstOrDefault();

			return productionActor;
		}

		public List<ActorInfo> GetPurchasedActors()
		{
			return ActorsReadyForDelivery;
		}

		protected override bool BuildUnit(ActorInfo unit)
		{
			// Find a production structure to build this actor
			var bi = unit.TraitInfo<BuildableInfo>();

			// Some units may request a specific production type, which is ignored if the AllTech cheat is enabled
			var type = developerMode.AllTech ? Info.Type : (bi.BuildAtProductionType ?? Info.Type);

			var producers = self.World.ActorsWithTrait<ProductionStarport>()
				.Where(x => x.Actor.Owner == self.Owner
					&& !x.Trait.IsTraitDisabled
					&& x.Trait.Info.Produces.Contains(type))
					.OrderByDescending(x => x.Actor.Trait<PrimaryBuilding>().IsPrimary)
					.ThenByDescending(x => x.Actor.ActorID);

			var anyProducers = false;
			foreach (var p in producers)
			{
				anyProducers = true;
				if (p.Trait.IsTraitPaused)
					continue;

				var inits = new TypeDictionary
				{
					new OwnerInit(self.Owner),
					new FactionInit(BuildableInfo.GetInitialFaction(unit, p.Trait.Faction))
				};

				var item = Queue.First(i => i.Done && i.Item == unit.Name);
				if (ActorsReadyForDelivery.Count <= info.MaxCapacity)
				{
					ActorsReadyForDelivery.Add(unit);
					ActorsInits.Add(inits);
					Console.WriteLine("Couter:" + ActorsReadyForDelivery.Count);
					actorsTotalCost.Add(item.TotalCost);
					EndProduction(item);
				}

				return false;
			}

			if (!anyProducers)
				CancelProduction(unit.Name, 1);

			return false;
		}

		public override void ResolveOrder(Actor self, Order order)
		{
			if (!Enabled)
				return;

			var rules = self.World.Map.Rules;
			switch (order.OrderString)
			{
				case "StartProduction":
					var unit = rules.Actors[order.TargetString];
					var bi = unit.TraitInfo<BuildableInfo>();

					// Not built by this queue
					if (!bi.Queue.Contains(Info.Type))
						return;

					// You can't build that
					if (BuildableItems().All(b => b.Name != order.TargetString))
						return;

					// Check if the player is trying to build more units that they are allowed
					var fromLimit = int.MaxValue;
					if (!developerMode.AllTech)
					{
						if (Info.QueueLimit > 0)
							fromLimit = Info.QueueLimit - Queue.Count;

						if (Info.ItemLimit > 0)
							fromLimit = Math.Min(fromLimit, Info.ItemLimit - Queue.Count(i => i.Item == order.TargetString));

						if (bi.BuildLimit > 0)
						{
							var inQueue = Queue.Count(pi => pi.Item == order.TargetString);
							var owned = self.Owner.World.ActorsHavingTrait<Buildable>().Count(a => a.Info.Name == order.TargetString && a.Owner == self.Owner);
							fromLimit = Math.Min(fromLimit, bi.BuildLimit - (inQueue + owned));
						}

						if (fromLimit <= 0)
							return;
					}

					var cost = GetProductionCost(unit);
					var time = GetBuildTime(unit, bi);
					var amountToBuild = Math.Min(fromLimit, order.ExtraData);
					for (var n = 0; n < amountToBuild; n++)
					{
						if (Info.PayUpFront && cost > playerResources.GetCashAndResources())
							return;
						var hasPlayedSound = false;
						BeginProduction(new ProductionItem(this, order.TargetString, cost, playerPower, () => self.World.AddFrameEndTask(_ =>
						{
							// Make sure the item hasn't been invalidated between the ProductionItem ticking and this FrameEndTask running
							if (!Queue.Any(i => i.Done && i.Item == unit.Name))
								return;

							var isBuilding = unit.HasTraitInfo<BuildingInfo>();
							if (isBuilding && !hasPlayedSound)
							{
								//hasPlayedSound = Game.Sound.PlayNotification(rules, self.Owner, "Speech", Info.ReadyAudio, self.Owner.Faction.InternalName);
								//TextNotificationsManager.AddTransientLine(self.Owner, Info.ReadyTextNotification);
							}
							else if (!isBuilding)
							{
								if (BuildUnit(unit))
								{
									//Game.Sound.PlayNotification(rules, self.Owner, "Speech", Info.ReadyAudio, self.Owner.Faction.InternalName);
									//TextNotificationsManager.AddTransientLine(self.Owner, Info.ReadyTextNotification);
								}
								else if (!hasPlayedSound && time > 0)
								{
									//hasPlayedSound = Game.Sound.PlayNotification(rules, self.Owner, "Speech", Info.BlockedAudio, self.Owner.Faction.InternalName);
									//TextNotificationsManager.AddTransientLine(self.Owner, Info.BlockedTextNotification);
								}
							}
						})), !order.Queued);
					}

					break;
				case "PauseProduction":
					PauseProduction(order.TargetString, order.ExtraData != 0);
					break;
				case "CancelProduction":
					CancelProduction(order.TargetString, order.ExtraData);
					break;
				case "ReturnOrder":
					Console.WriteLine("returning actor:" + order.TargetString);
					ReturnOrder(order.TargetString, order.ExtraData);
					break;
				case "PurchaseOrder":
					if (!deliveryProcessStarted)
						StartDeliveryProcess();
					break;
			}
		}

		public void DeliverFinished()
		{
			if (deliveryProcessStarted)
			{
				actorsTotalCost.Clear();
				ActorsReadyForDelivery.Clear();
				deliveryProcessStarted = false;
				Console.WriteLine("delivery finished");
			}
		}

		public bool HasDeliveryStarted()
		{
			return deliveryProcessStarted;
		}
		public List<ActorInfo> GetActorsReadyForDelivery()
		{
			return ActorsReadyForDelivery;
		}
		protected void StartDeliveryProcess()
		{
			Console.WriteLine("Starting delivery process");
			ClearQueue();
			deliveryProcessStarted = true;
			var producers = self.World.ActorsWithTrait<ProductionStarport>()
				.Where(x => x.Actor.Owner == self.Owner
					&& !x.Trait.IsTraitDisabled
					&& !x.Trait.IsTraitPaused
					&& x.Trait.Info.Produces.Contains(Info.Type))
					.OrderByDescending(x => x.Actor.Trait<PrimaryBuilding>().IsPrimary)
					.ThenByDescending(x => x.Actor.ActorID);
			var p = producers.First();
			p.Trait.DeliverOrder(p.Actor, ActorsReadyForDelivery, Info.Type, ActorsInits.FirstOrDefault());
			var rules = self.World.Map.Rules;
			Game.Sound.PlayNotification(rules, self.Owner, "Speech", info.StartDeliveryAudio, self.Owner.Faction.InternalName);
			TextNotificationsManager.AddTransientLine(self.Owner, info.StartDeliveryNotification);
		}
		public void ReturnOrder(string itemName, uint numberToCancel = 1)
		{
			for (var i = 0; i < numberToCancel; i++)
			{
				var actor = ActorsReadyForDelivery.LastOrDefault(actor => actor.Name == itemName);
				if (actor == null)
					break;
				playerResources.GiveCash(actor.TraitInfo<ValuedInfo>().Cost);
				ActorsReadyForDelivery.Remove(actor);
			}
		}
	}
}
