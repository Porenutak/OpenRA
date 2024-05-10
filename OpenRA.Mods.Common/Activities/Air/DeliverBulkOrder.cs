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

using System.Collections.Generic;
using System.Linq;
using OpenRA.Activities;
using OpenRA.Mods.Common.Traits;
using OpenRA.Primitives;

namespace OpenRA.Mods.Common.Activities
{
	public class DeliverBulkOrder : Activity
	{
		readonly Actor producer;
		readonly Actor transport;
		readonly List<ActorInfo> orderedActors;
		readonly string productionType;
		readonly TypeDictionary inits;
		readonly BulkProductionQueue queue;

		public DeliverBulkOrder(Actor producer, Actor transport, List<ActorInfo> orderedActors, string productionType, TypeDictionary inits, BulkProductionQueue queue)
		{
			this.producer = producer;
			this.transport = transport;
			this.orderedActors = orderedActors;
			this.productionType = productionType;
			this.inits = inits;
			this.queue = queue;
		}

		public override bool Tick(Actor self)
		{
			if (transport.IsDead || !producer.IsInWorld || producer.IsDead)
			{
				// Inform parent queue that deliver is finished
				queue.DeliverFinished();
				return true;
			}

			if (orderedActors == null || orderedActors.Count == 0)
			{
				producer.Trait<ProductionStarport>().CancelDelivery();
				return true;
			}

			transport.QueueChildActivity(new Wait(1));
			var actor = orderedActors.Last();
			var exit = producer.Trait<ProductionStarport>().PublicExit(producer, actor, productionType);
			if (exit == null)
			{
				var exits = producer.Info.TraitInfos<ExitInfo>().First();
				var cell = producer.Location + exits.ExitCell;
				producer.NotifyBlocker(cell);
				return false;
			}
			else
			{
				producer.World.AddFrameEndTask(ww =>
				{
					producer.Trait<ProductionStarport>().DoProduction(producer, actor, exit?.Info, productionType, inits);
					orderedActors.Remove(actor);
				});
				return false;
			}
		}
	}
}
