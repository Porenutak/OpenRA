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
using OpenRA.Traits;

namespace OpenRA.Mods.Common.Traits
{
	[Desc("Attach this into the actor which require stored Stocks before ordering/building")]
	public class StockPilesInfo : TraitInfo<StockPiles>
	{
		[Desc("Number of stocks available when game started")]
		public readonly int InitialStocks = 0;

		[Desc("maximum capacity for this stock.")]
		public readonly int MaxCapacity = 5;

		[Desc("Time in Ticks until new stock become available")]
		public readonly int ReplenishmentRate = 100;
		[Desc("Chance that stock replenishment is succefull")]
		public readonly int Chance = 100;
	}

	public class StockPiles { }

}
