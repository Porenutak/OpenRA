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
		"Will only work together with the Production: trait on the actor that actually does the production.",
		"You will also want to add PrimaryBuildings: to let the user choose where new units should exit.")]
	public class BulkProductionQueueInfo : ProductionQueueInfo, Requires<TechTreeInfo>, Requires<PlayerResourcesInfo>
	{
		[Desc("If you build more actors of the same type,", "the same queue will get its build time lowered for every actor produced there.")]
		public readonly bool SpeedUp = false;

		[Desc("Maximum deliver capacity")]
		public readonly int MaxCapacity = 3;

		public override object Create(ActorInitializer init) { return new BulkProductionQueue(init, this); }
	}

	public class BulkProductionQueue : ProductionQueue
	{
		static readonly ActorInfo[] NoItems = { };

		readonly Actor self;
		readonly BulkProductionQueueInfo info;

		int totalOrderValue = 0;
		protected readonly List<ActorInfo> ActorsReadyForDelivery = new();
		protected readonly List<TypeDictionary> ActorsInits = new();

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
			return Enabled && ActorsReadyForDelivery.Count != info.MaxCapacity ? base.AllItems() : NoItems;
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

		public List<ActorInfo> GetActorsReadyForDelivery()
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
				if (ActorsReadyForDelivery.Count < info.MaxCapacity)
				{
					ActorsReadyForDelivery.Add(unit);
					ActorsInits.Add(inits);
					Console.WriteLine("pocet:" + ActorsReadyForDelivery.Count);
					totalOrderValue += item.TotalCost;
					EndProduction(item);
				}

				if (ActorsReadyForDelivery.Count == info.MaxCapacity)
				{
					Console.WriteLine("starting delivery");
					if (p.Trait.DeliverOrder(p.Actor, ActorsReadyForDelivery, type, inits, totalOrderValue))
					{
						EndProduction(item);
						totalOrderValue = 0;
						//ActorsReadyForDelivery.Clear();
						return true;
					}
				}
				else
				{
					return false;
				}
			}

			if (!anyProducers)
				CancelProduction(unit.Name, 1);

			return false;
		}
	}
}
