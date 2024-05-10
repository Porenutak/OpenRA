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

	sealed class ProductionStarport : Production, Itick
	{
		RallyPoint rp;
		BulkProductionQueue queue;
		Actor transport;

		public ProductionStarport(ActorInitializer init, ProductionStarportInfo info)
			: base(init, info) { }

		protected override void Created(Actor self)
		{
			base.Created(self);

			rp = self.TraitOrDefault<RallyPoint>();
		}

		public bool DeliverOrder(Actor producent, List<ActorInfo> orderedActors, string productionType, TypeDictionary inits)
		{
			if (IsTraitDisabled || IsTraitPaused)
				return false;
			var info = (ProductionStarportInfo)Info;
			var owner = producent.Owner;
			var map = owner.World.Map;
			var waitTickbeforeSpawn = 10;
			var aircraftInfo = producent.World.Map.Rules.Actors[info.ActorType].TraitInfo<AircraftInfo>();
			queue = owner.World.ActorsWithTrait<BulkProductionQueue>().First(x => x.Actor.Owner == owner
				&& x.Trait.GetActorsReadyForDelivery().Equals(orderedActors)).Trait;
			CPos startPos;
			WAngle spawnFacing;

			startPos = producent.World.Map.ChooseClosestEdgeCell(producent.Location);
			spawnFacing = producent.World.Map.FacingBetween(startPos, producent.Location, WAngle.Zero);

			// Assume a single exit point for simplicity
			var exits = producent.Info.TraitInfos<ExitInfo>();
			var exit = producent.Info.TraitInfos<ExitInfo>().First();

			foreach (var tower in producent.TraitsImplementing<INotifyDelivery>())
				tower.IncomingDelivery(producent);

			owner.World.AddFrameEndTask(w =>
			{
				if (!producent.IsInWorld || producent.IsDead)
				{
					CancelDelivery();
					return;
				}

				// aircrafts are delivered by themselfs
				var exitCell = producent.Location + exit.ExitCell;
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
				transport = w.CreateActor(info.ActorType, new TypeDictionary
				{
					new CenterPositionInit(w.Map.CenterOfCell(startPos) + new WVec(WDist.Zero, WDist.Zero, aircraftInfo.CruiseAltitude)),
					new OwnerInit(owner),
					new FacingInit(spawnFacing)
				});

				transport.QueueActivity(new Land(transport, Target.FromActor(producent), WDist.FromCells(10), info.LandOffset));
				transport.QueueActivity(new DeliverBulkOrder(producent, transport, orderedActors, productionType, inits, queue));
				if (info.WaitTickAfterProduce > 0)
					transport.QueueActivity(new Wait(info.WaitTickAfterProduce));
				transport.QueueActivity(new CallFunc(() =>
				{
					if (producent.IsDead || !producent.IsInWorld)
						return;
					foreach (var cargo in producent.TraitsImplementing<INotifyDelivery>())
						cargo.Delivered(producent);
				}));
				transport.QueueActivity(new FlyOffMap(transport, Target.FromCell(w, startPos)));
				transport.QueueActivity(new RemoveSelf());
			});

			return true;
		}

		public void CancelDelivery()
		{
			queue.DeliverFinished();
		}

		public Exit PublicExit(Actor self, ActorInfo producee, string productionType)
		{
			return SelectExit(self, producee, productionType);
		}
	}

	internal interface Itick
	{

	}
}
