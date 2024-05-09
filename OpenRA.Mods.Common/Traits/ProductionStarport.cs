#region Copyright & License Information
/*
 * Copyright (c) The OpenRA Developers and Contributors
 * This file is part of OpenRA, which is free software. It is made
 * available to you under the terms of the GNU General Public License
 * as published by the Free Software Foundation, either version 3 of
 * the License, or (at your option) any later version. For more
 * information, see COPYING.
 */
#endregion

using System;
using System.Collections.Generic;
using System.Linq;
using OpenRA.Activities;
using OpenRA.Mods.Common;
using OpenRA.Mods.Common.Activities;
using OpenRA.Mods.Common.Traits;
using OpenRA.Primitives;
using OpenRA.Traits;

namespace OpenRA.Mods.Common.Traits
{
	[Desc("Deliver multiple units via skylift. Works with BuildProductionQueue")]
	public class ProductionStarportInfo : ProductionInfo
	{
		[NotificationReference("Speech")]
		[Desc("Speech notification to play when a unit is delivered.")]
		public readonly string ReadyAudio = "Reinforce";

		[TranslationReference(optional: true)]
		[Desc("Text notification to display when a unit is delivered.")]
		public readonly string ReadyTextNotification = null;

		[FieldLoader.Require]
		[ActorReference(typeof(AircraftInfo))]
		[Desc("Cargo aircraft used for delivery. Must have the `" + nameof(Aircraft) + "` trait.")]
		public readonly string ActorType = null;


		[Desc("Direction the aircraft should face to land.")]
		public readonly WAngle Facing = new(256);

		[Desc("Tick that aircraft should wait before producing.")]
		public readonly int WaitTickBeforeProduce = 0;

		[Desc("Tick that aircraft should wait after producing.")]
		public readonly int WaitTickAfterProduce = 0;

		[Desc("Offset the aircraft used for landing.")]
		public readonly WVec LandOffset = WVec.Zero;

		public override object Create(ActorInitializer init) { return new ProductionStarport(init, this); }
	}

	sealed class ProductionStarport : Production
	{
		RallyPoint rp;

		BulkProductionQueue queue;
		public ProductionStarport(ActorInitializer init, ProductionStarportInfo info)
			: base(init, info) { }

		protected override void Created(Actor self)
		{
			base.Created(self);

			rp = self.TraitOrDefault<RallyPoint>();
		}

		public bool DeliverOrder(Actor self, List<ActorInfo> orderedActors, string productionType, TypeDictionary inits)
		{
			if (IsTraitDisabled || IsTraitPaused)
				return false;
			var info = (ProductionStarportInfo)Info;
			var owner = self.Owner;
			var map = owner.World.Map;
			var waitTickbeforeSpawn = 10;
			var aircraftInfo = self.World.Map.Rules.Actors[info.ActorType].TraitInfo<AircraftInfo>();
			queue = owner.World.ActorsWithTrait<BulkProductionQueue>().First(x => x.Actor.Owner == owner
				&& x.Trait.GetActorsReadyForDelivery().Equals(orderedActors)).Trait;
			CPos startPos;
			WAngle spawnFacing;

			startPos = self.World.Map.ChooseClosestEdgeCell(self.Location);
			spawnFacing = self.World.Map.FacingBetween(startPos, self.Location, WAngle.Zero);
			// Assume a single exit point for simplicity
			var exit = self.Info.TraitInfos<ExitInfo>().First();

			foreach (var tower in self.TraitsImplementing<INotifyDelivery>())
				tower.IncomingDelivery(self);

			owner.World.AddFrameEndTask(w =>
			{
				if (!self.IsInWorld || self.IsDead)
				{
					RefundDelivery(orderedActors);
					queue.DeliverFinished();
					return;
				}

				// aircrafts are delivered by themselfs
				var exitCell = self.Location + exit.ExitCell;
				var destinations = rp != null && rp.Path.Count > 0 ? rp.Path : new List<CPos> { exitCell };

				foreach (var orderedAircraft in orderedActors.Where(actor => actor.HasTraitInfo<AircraftInfo>()))
				{
					var altitude = orderedAircraft.TraitInfo<AircraftInfo>().CruiseAltitude;
					var aircraft = w.CreateActor(orderedAircraft.Name, new TypeDictionary
					{
						new CenterPositionInit(w.Map.CenterOfCell(startPos) + new WVec(WDist.Zero, WDist.Zero, altitude)),
						new OwnerInit(owner),
						new FacingInit(spawnFacing)
					});
					var move = aircraft.TraitOrDefault<IMove>();
					if (move != null)
					{
						aircraft.QueueActivity(new Wait(waitTickbeforeSpawn));
						waitTickbeforeSpawn += 10;
						// first move must be to the Producer location
						aircraft.QueueActivity(move.MoveTo(exitCell, 2, evaluateNearestMovableCell: true));
						foreach (var cell in destinations)
						{
							aircraft.QueueActivity(move.MoveTo(cell, 2, evaluateNearestMovableCell: true));
						}
					}
				}

				orderedActors.RemoveAll(actor => actor.HasTraitInfo<AircraftInfo>());
				waitTickbeforeSpawn = 0;
				var transport = w.CreateActor(info.ActorType, new TypeDictionary
				{
					new CenterPositionInit(w.Map.CenterOfCell(startPos) + new WVec(WDist.Zero, WDist.Zero, aircraftInfo.CruiseAltitude)),
					new OwnerInit(owner),
					new FacingInit(spawnFacing)
				});
				transport.QueueActivity(new Land(transport, Target.FromActor(self), WDist.Zero, info.LandOffset, info.Facing, clearCells: new CPos[1] { exitCell }));
				if (info.WaitTickBeforeProduce > 0)
					transport.QueueActivity(new Wait(info.WaitTickBeforeProduce));

				transport.QueueActivity(new CallFunc(() =>
				{
					Console.WriteLine("2.strating deploying");
					if (!self.IsInWorld || self.IsDead)
					{
						// TODO fix refund cash
						RefundDelivery(orderedActors);
						queue.DeliverFinished();
						return;
					}

					foreach (var cargo in self.TraitsImplementing<INotifyDelivery>())
						cargo.Delivered(self);

					foreach (var cargo in orderedActors.Where(actor => actor.HasTraitInfo<MobileInfo>()))
					{
						var finalexit = SelectExit(self, cargo, productionType);
						if (cargo.HasTraitInfo<MobileInfo>())
						{
							self.World.AddFrameEndTask(ww => DoProduction(self, cargo, finalexit?.Info, productionType, inits));
							waitTickbeforeSpawn += 10;
						}
					}

					Game.Sound.PlayNotification(self.World.Map.Rules, self.Owner, "Speech", info.ReadyAudio, self.Owner.Faction.InternalName);
					TextNotificationsManager.AddTransientLine(self.Owner, info.ReadyTextNotification);
				}));
				transport.QueueActivity(new CallFunc(() =>
				{

					queue.DeliverFinished();
				}));
				if (info.WaitTickAfterProduce > 0)
					transport.QueueActivity(new Wait(info.WaitTickAfterProduce));
				transport.QueueActivity(new FlyOffMap(transport, Target.FromCell(w, startPos)));
				transport.QueueActivity(new RemoveSelf());
			});

			return true;
		}

		public void RefundDelivery(List<ActorInfo> orderedActors)
		{
			foreach (var actor in orderedActors)
			{
				queue.ReturnOrder(actor.Name);
			}
		}
	}
}
