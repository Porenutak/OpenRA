
WorldLoaded = function()
	player0 = Player.GetPlayer("Multi0")
	xMax = 129
	yMax = 129
	for x = 2, xMax do
		x = x + 1
		for y = 2, yMax do
			y = y + 1
			local cell = CPos.New(x,y)
			AddCellLabel(cell, Map.TerrainType(cell))
		end
	end
end

function AddCellLabel(cell, terrain)
	terrain = terrain or Map.TerrainType(cell)
	Media.Debug("creating label for cell:"..tostring(cell).." is "..Map.TileID(cell))
	Actor.Create("label_" .. string.lower(terrain), true, { Owner = player0, Location = cell })
end
