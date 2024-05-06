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
	[Desc("Deliver the unit in production via skylift.")]
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

		[Desc("The cargo aircraft will spawn at the player baseline (map edge closest to the player spawn)")]
		public readonly bool BaselineSpawn = false;

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
		int WaitTickbeforeSpawn = 0;
		public ProductionStarport(ActorInitializer init, ProductionStarportInfo info)
			: base(init, info) { }

		protected override void Created(Actor self)
		{
			base.Created(self);

			rp = self.TraitOrDefault<RallyPoint>();
		}

		public bool DeliverOrder(Actor self, List<ActorInfo> orderedActors, string productionType, List<TypeDictionary> inits, int refundableValue)
		{
			Console.WriteLine("total cost is: " + refundableValue);
			if (IsTraitDisabled || IsTraitPaused)
				return false;

			var info = (ProductionStarportInfo)Info;
			var owner = self.Owner;
			var map = owner.World.Map;
			var aircraftInfo = self.World.Map.Rules.Actors[info.ActorType].TraitInfo<AircraftInfo>();

			CPos startPos;
			CPos endPos;
			WAngle spawnFacing;

			if (info.BaselineSpawn)
			{
				var bounds = map.Bounds;
				var center = new MPos(bounds.Left + bounds.Width / 2, bounds.Top + bounds.Height / 2).ToCPos(map);
				var spawnVec = owner.HomeLocation - center;
				startPos = owner.HomeLocation + spawnVec * Exts.ISqrt((bounds.Height * bounds.Height + bounds.Width * bounds.Width) / (4 * spawnVec.LengthSquared));
				endPos = startPos;
				var spawnDirection = new WVec((self.Location - startPos).X, (self.Location - startPos).Y, 0);
				spawnFacing = spawnDirection.Yaw;
			}
			else
			{
				// Start a fixed distance away: the width of the map.
				// This makes the production timing independent of spawnpoint
				var loc = self.Location.ToMPos(map);
				startPos = new MPos(loc.U + map.Bounds.Width, loc.V).ToCPos(map);
				endPos = new MPos(map.Bounds.Left, loc.V).ToCPos(map);
				spawnFacing = info.Facing;
			}

			// Assume a single exit point for simplicity
			var exit = self.Info.TraitInfos<ExitInfo>().First();

			foreach (var tower in self.TraitsImplementing<INotifyDelivery>())
				tower.IncomingDelivery(self);

			owner.World.AddFrameEndTask(w =>
			{
				if (!self.IsInWorld || self.IsDead)
				{
					owner.PlayerActor.Trait<PlayerResources>().GiveCash(refundableValue);
					return;
				}

				// aircrafts are delivered by themselfs
				var destinations = rp != null && rp.Path.Count > 0 ? rp.Path : new List<CPos> { self.Location };
				destinations.Insert(1, self.Location);
				foreach (var orderedAircraft in orderedActors.Where(actor => actor.HasTraitInfo<AircraftInfo>()))
				{
					var aircraft = w.CreateActor(orderedAircraft.Name, new TypeDictionary
					{
						new CenterPositionInit(w.Map.CenterOfCell(startPos) + new WVec(WDist.Zero, WDist.Zero, aircraftInfo.CruiseAltitude)),
						new OwnerInit(owner),
						new FacingInit(spawnFacing)
					});
					var move = aircraft.TraitOrDefault<IMove>();
					if (move != null)
					{
						aircraft.QueueActivity(new Wait(WaitTickbeforeSpawn));
						WaitTickbeforeSpawn += 10;
						foreach (var cell in destinations)
						{
							aircraft.QueueActivity(move.MoveTo(cell, 2, evaluateNearestMovableCell: true));
						}
					}
				}

				WaitTickbeforeSpawn = 0;
				var exitCell = self.Location + exit.ExitCell;
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
					if (!self.IsInWorld || self.IsDead)
					{
						// TODO fix refund cash
						owner.PlayerActor.Trait<PlayerResources>().GiveCash(refundableValue);
						orderedActors.Clear();
						return;
					}

					foreach (var cargo in self.TraitsImplementing<INotifyDelivery>())
						cargo.Delivered(self);

					for (var i = 0; i < orderedActors.Count; i++)
					{
						transport.QueueActivity(new Wait(WaitTickbeforeSpawn));
						transport.QueueActivity(new CallFunc(() =>
						{
							var finalexit = SelectExit(self, orderedActors[i], productionType);
							if (orderedActors[i].HasTraitInfo<MobileInfo>())
							{
								DoProduction(self, orderedActors[i], finalexit?.Info, productionType, inits[i]);
								WaitTickbeforeSpawn += 10;
							}
						}));
					}

					Game.Sound.PlayNotification(self.World.Map.Rules, self.Owner, "Speech", info.ReadyAudio, self.Owner.Faction.InternalName);
					TextNotificationsManager.AddTransientLine(self.Owner, info.ReadyTextNotification);
				}));
				transport.QueueActivity(new CallFunc(() =>
				{
					orderedActors.Clear();
					inits.Clear();
				}));
				if (info.WaitTickAfterProduce > 0)
					transport.QueueActivity(new Wait(info.WaitTickAfterProduce));
				transport.QueueActivity(new FlyOffMap(transport, Target.FromCell(w, endPos)));
				transport.QueueActivity(new RemoveSelf());
			});

			return true;
		}
	}
}
