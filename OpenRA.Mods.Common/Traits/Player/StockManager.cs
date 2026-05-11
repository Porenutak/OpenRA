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
using OpenRA.Traits;
using System;
using System.Collections.Generic;
using System.Collections.Frozen;

namespace OpenRA.Mods.Common.Traits
{
	[TraitLocation(SystemActors.Player)]
	[Desc("Manage stock replenishment. Attack this to Player actor")]

	public class StockManagerInfo : TraitInfo
	{
		public override object Create(ActorInitializer init) { return new StockManager(init); }
	}

	public class StockManager
	{
		protected readonly List<ActorInfo> AllItems = [];
		Player Owner;
		public StockManager(ActorInitializer init)
		{
			Owner = init.Self.Owner;
		}

	}
}
