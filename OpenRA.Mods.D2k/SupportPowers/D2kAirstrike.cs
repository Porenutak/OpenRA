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
using OpenRA.Mods.Common;
using OpenRA.Mods.Common.Activities;
using OpenRA.Mods.Common.Effects;
using OpenRA.Mods.Common.Traits;
using OpenRA.Traits;

namespace OpenRA.Mods.D2k.Traits
{
	[Desc("Support power that spawns a group of aircraft and orders them to deliver an multiple airstrike attacks on seleted target.")]
	public class D2kAirstrikePowerInfo : AirstrikePowerInfo
	{
		[Desc("How manny times aircraft should strike selected target")]
		public readonly int Strikes = 3;

		[Desc("Additional distance beyound target after attack roll ends")]
		public readonly WDist StrafeOutLength = new(10240);

		[Desc("Initial preparation distance before attack starts")]
		public readonly WDist StrafeInLenght = new(3036);

		[Desc("Define rotation between each strike")]
		public readonly int Angle = 45;
		[Desc("point against which formation will turn. Default to selected target")]
		public readonly WVec PivotOffSet = WVec.Zero;

		public override object Create(ActorInitializer init) { return new D2kAirstrikePower(init.Self, this); }
	}

	public class D2kAirstrikePower : AirstrikePower
	{
		readonly D2kAirstrikePowerInfo info;

		WPos pivot;
		public D2kAirstrikePower(Actor self, D2kAirstrikePowerInfo info)
			: base(self, info)
		{
			this.info = info;
		}
		public override void Activate(Actor self, Order order, SupportPowerManager manager)
		{
			base.Activate(self, order, manager);
		}
		public override Actor[] SendAirstrike(Actor self, WPos target, WAngle? facing = null)
		{
			var aircraft = new List<Actor>();

			if (!facing.HasValue)
				facing = new WAngle(1024 * self.World.SharedRandom.Next(info.QuantizedFacings) / info.QuantizedFacings);

			Actor camera = null;
			Beacon beacon = null;
			var aircraftInRange = new Dictionary<Actor, bool>();

			void OnEnterRange(Actor a)
			{
				//var targets = a.CurrentActivity.NextActivity.GetTargets(a);
				//var attackTrait = a.Trait<AttackBomber>();
				//foreach (var target in targets) { attackTrait.SetTarget(target.CenterPosition); }
				// Spawn a camera and remove the beacon when the first plane enters the target area
				if (info.CameraActor != null && camera == null)
				{
					self.World.AddFrameEndTask(w =>
					{
						camera = w.CreateActor(info.CameraActor,
						[
							new LocationInit(self.World.Map.CellContaining(target)),
							new OwnerInit(self.Owner),
						]);
					});
				}
				else if (!camera.IsInWorld) camera.World.Add(camera);

				RemoveBeacon(beacon);

				aircraftInRange[a] = true;
			}

			void OnExitRange(Actor a)
			{
				var attack = a.Trait<AttackBomber>();

				foreach (var target in a.CurrentActivity.NextActivity.NextActivity.GetTargets(a))
				{
					attack.SetTarget(target.CenterPosition);
				}
				aircraftInRange[a] = false;

				// Remove the camera when the final plane leaves the target area
				if (!aircraftInRange.Any(kv => kv.Value))
					DisableCamera(camera);
			}

			void OnRemovedFromWorld(Actor a)
			{
				aircraftInRange[a] = false;

				// Checking for attack range is not relevant here because
				// aircraft may be shot down before entering the range.
				// If at the map's edge, they may be removed from world before leaving.
				if (aircraftInRange.All(kv => !kv.Key.IsInWorld))
				{
					RemoveCamera(camera);
					RemoveBeacon(beacon);
				}
			}

			WPos? startPos = null;

			// Create the actors immediately so they can be returned.
			foreach (var squadMember in info.Squad)
			{
				var a = self.World.CreateActor(false, squadMember.UnitType,
				[
					new OwnerInit(self.Owner),
					new FacingInit(facing.Value),
				]);

				aircraft.Add(a);
				aircraftInRange.Add(a, false);
			}

			self.World.AddFrameEndTask(w =>
			{
				PlayLaunchSounds();

				Actor distanceTestActor = null;
				for (var i = 0; i < aircraft.Count; i++)
				{
					var squadMember = info.Squad[i];
					var actor = aircraft[i];

					var altitude = self.World.Map.Rules.Actors[squadMember.UnitType].TraitInfo<AircraftInfo>().CruiseAltitude.Length;
					var attackRotation = WRot.FromYaw(facing.Value);
					var delta = new WVec(0, -1024, 0).Rotate(attackRotation);
					var targetPos = target + new WVec(0, 0, altitude);
					var startEdge = targetPos - (self.World.Map.DistanceToEdge(target, -delta) + info.Cordon).Length * delta / 1024;
					startPos = startEdge;

					// Includes the 90 degree rotation between body and world coordinates.
					var so = squadMember.SpawnOffset;
					var to = squadMember.TargetOffset;
					var spawnOffset = new WVec(so.Y, -1 * so.X, 0).Rotate(attackRotation);
					var targetOffset = new WVec(to.Y, -1 * to.X, 0).Rotate(attackRotation);
					pivot = target + new WVec(info.PivotOffSet.Y, -1 * info.PivotOffSet.X, 0).Rotate(attackRotation);
					actor.Trait<IPositionable>().SetPosition(actor, startEdge + spawnOffset);
					w.Add(actor);
					var defaultTarget = target + targetOffset;
					var attack = actor.Trait<AttackBomber>();
					attack.OnEnteredAttackRange += OnEnterRange;
					attack.SetTarget(defaultTarget);
					attack.OnExitedAttackRange += OnExitRange;
					var angle = facing.Value;
					var targetOffsetAngle = WAngle.FromDegrees(0);
					var beyondTarget = WPos.Zero;
					var vectorAgainstPivot = defaultTarget - pivot;
					for (var j = 0; j < info.Strikes; j++)
					{
						targetOffset = vectorAgainstPivot.Rotate(WRot.FromYaw(targetOffsetAngle));
						defaultTarget = pivot + targetOffset;
						var color = Primitives.Color.Red;
						if (j == 1) color = Primitives.Color.Yellow;
						if (j == 2) color = Primitives.Color.Green;
						delta = new WVec(0, -1024, 0).Rotate(WRot.FromYaw(angle));
						var beforeTarget = defaultTarget - info.StrafeInLenght.Length * delta / 1024;
						actor.QueueActivity(new Fly(actor, Target.FromPos(beforeTarget), WDist.Zero, null, color));
						actor.QueueActivity(new Fly(actor, Target.FromPos(defaultTarget), WDist.Zero, null, color));

						delta = new WVec(0, -1024, 0).Rotate(WRot.FromYaw(angle));

						beyondTarget = defaultTarget + info.StrafeOutLength.Length * delta / 1024;
						actor.QueueActivity(new Fly(actor, Target.FromPos(beyondTarget), WDist.Zero, null, color));

						angle -= WAngle.FromDegrees(45) + WAngle.FromDegrees(180);
						targetOffsetAngle -= WAngle.FromDegrees(45);

					}

					attack.OnRemovedFromWorld += OnRemovedFromWorld;
					var finishEdge = beyondTarget + (self.World.Map.DistanceToEdge(target, delta) + info.Cordon).Length * delta / 1024;
					actor.QueueActivity(new Fly(actor, Target.FromPos(finishEdge), WDist.Zero, null, Primitives.Color.Wheat));
					actor.QueueActivity(new RemoveSelf());
					distanceTestActor = actor;
				}

				if (Info.DisplayBeacon && startPos.HasValue)
				{
					var distance = (target - startPos.Value).HorizontalLength;

					beacon = new Beacon(
						self.Owner,
						new WPos(target.X, target.Y, 0),
						Info.BeaconPaletteIsPlayerPalette,
						Info.BeaconPalette,
						Info.BeaconImage,
						Info.BeaconPoster,
						Info.BeaconPosterPalette,
						Info.BeaconSequence,
						Info.ArrowSequence,
						Info.CircleSequence,
						Info.ClockSequence,
						() => 1 - ((distanceTestActor.CenterPosition - target).HorizontalLength - info.BeaconDistanceOffset.Length) * 1f / distance,
						Info.BeaconDelay);

					w.Add(beacon);
					var beacon1 = new Beacon(
						self.Owner,
						new WPos(pivot.X, pivot.Y, 0),
						Info.BeaconPaletteIsPlayerPalette,
						Info.BeaconPalette,
						Info.BeaconImage,
						Info.BeaconPoster,
						Info.BeaconPosterPalette,
						Info.BeaconSequence,
						Info.ArrowSequence,
						Info.CircleSequence,
						Info.ClockSequence,
						() => 1 - ((distanceTestActor.CenterPosition - target).HorizontalLength - info.BeaconDistanceOffset.Length) * 1f / distance,
						Info.BeaconDelay);

					w.Add(beacon1);
				}
			});

			return aircraft.ToArray();
		}

		public WPos CalculatePivot(WPos targetPosition, WAngle facing)
		{
			var sumX = 0;
			var sumY = 0;
			foreach (var squadMember in info.Squad)
			{
				var to = squadMember.TargetOffset;
				var targetOffset = new WVec(to.Y, -1 * to.X, 0).Rotate(WRot.FromYaw(facing));
				sumX += targetOffset.X + targetPosition.X;
				sumY += targetOffset.Y + targetPosition.Y;
			}

			return new WPos(sumX / info.Squad.Count, sumY / info.Squad.Count, 0);
		}

		public void DisableCamera(Actor camera)
		{
			if (camera == null)
				return;
			camera.World.Remove(camera);
		}
	}
}
