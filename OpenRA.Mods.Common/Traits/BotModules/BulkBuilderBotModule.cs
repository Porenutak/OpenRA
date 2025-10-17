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

using System.Linq;
using OpenRA.Traits;

namespace OpenRA.Mods.Common.Traits
{
	[TraitLocation(SystemActors.Player)]
	[Desc("Controls AI bulk unit production.")]
	public class BulkBuilderBotModuleInfo : UnitBuilderBotModuleInfo
	{
		[Desc("Do not purchase unit until bulkproduction MaxCapacity is reach")]
		public readonly bool ForceMaxCapacity = true;
		public override object Create(ActorInitializer init) { return new BulkBuilderBotModule(init.Self, this); }
	}

	public class BulkBuilderBotModule : UnitBuilderBotModule
	{
		readonly Player player;

		readonly BulkBuilderBotModuleInfo info;
		public BulkBuilderBotModule(Actor self, BulkBuilderBotModuleInfo info)
			: base(self, info)
		{
			player = self.Owner;
			this.info = info;
		}

		protected override void BotTick(IBot bot)
		{
			base.BotTick(bot);
			var bulkproductionQueues = World.ActorsWithTrait<BulkProductionQueue>()
				.Where(a => a.Actor.Owner == player && a.Trait.Enabled &&
				!a.Trait.HasDeliveryStarted() &&
				a.Trait.GetActorsReadyForDelivery().Count > 0)
				.Select(a => a.Trait).ToList();

			foreach (var unitQueue in Info.UnitQueues)
			{
				var queue = bulkproductionQueues.FirstOrDefault(a => a.Info.Type == unitQueue);
				if (queue == null)
					return;
				if (queue.Info.MaxCapacity == queue.GetActorsReadyForDelivery().Count)
				{
					World.IssueOrder(
					new Order("PurchaseOrder", queue.Actor, false)
					{
						TargetString = unitQueue
					});
				}

				if (!info.ForceMaxCapacity && World.SharedRandom.Next(0, queue.Info.MaxCapacity) <= queue.GetActorsReadyForDelivery().Count)
				{
					World.IssueOrder(
				new Order("PurchaseOrder", queue.Actor, false)
				{
					TargetString = unitQueue
				});
				}
			}
		}
	}
}
