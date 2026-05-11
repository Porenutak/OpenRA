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

namespace OpenRA.Mods.Common.Traits
{
	[Desc("Used by StockManager")]
	public class StockableInfo : TraitInfo<Stockable>
	{

		[Desc("Necessary time to stock one item (-1 indicates to use the unit's BuildDuration).")]
		public readonly int StockDuration = 100;

		[Desc("Disable production when there are more than this many of this actor on the battlefield. Set to 0 to disable.")]
		public readonly int StockLimit = 5;
	}

	public class Stockable { }
}
