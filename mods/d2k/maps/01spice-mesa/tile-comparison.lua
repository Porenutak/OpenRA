local Atreides = Player.GetPlayer("Atreides")
local TerrainColors =
{
	Default = HSLColor.White,
	Cliff = HSLColor.OrangeRed,
	Concrete = HSLColor.FromHex("CE8C42"),
	Dune = HSLColor.FromHex("EFDE8C"),
	Ice = HSLColor.FromHex("FFFFFF"),
	Rock = HSLColor.Yellow,
	Rough = HSLColor.Cyan,
	Sand = HSLColor.FromHex("D0C0A0"),
	Spice = HSLColor.FromHex("EF944A"),
	Transition = HSLColor.FromHex("CFA664"),
	SpiceSand = HSLColor.FromHex("D0C0A0")
	--Cliff = HSLColor.FromHex("4A2910"),
	--Rock = HSLColor.FromHex("CE8C42"),
	--Rough = HSLColor.FromHex("587474"),
}

local CenterCells = { CPos.New(13, 6), CPos.New(14, 6), CPos.New(14, 7), CPos.New(13, 7), CPos.New(13, 9), CPos.New(14, 9), CPos.New(14, 10), CPos.New(13, 10), CPos.New(13, 12), CPos.New(14, 12), CPos.New(14, 13), CPos.New(13, 13), CPos.New(13, 15), CPos.New(14, 15), CPos.New(14, 16), CPos.New(13, 16), CPos.New(13, 18), CPos.New(14, 18), CPos.New(14, 19), CPos.New(13, 19), CPos.New(13, 21), CPos.New(14, 21), CPos.New(14, 22), CPos.New(13, 22), CPos.New(13, 24), CPos.New(14, 24), CPos.New(14, 25), CPos.New(13, 25), CPos.New(13, 27), CPos.New(14, 27), CPos.New(14, 28), CPos.New(13, 28), CPos.New(13, 33), CPos.New(13, 34), CPos.New(14, 34), CPos.New(14, 33), CPos.New(13, 36), CPos.New(13, 37), CPos.New(14, 37), CPos.New(14, 36), CPos.New(13, 39), CPos.New(13, 40), CPos.New(14, 40), CPos.New(14, 39), CPos.New(13, 42), CPos.New(13, 43), CPos.New(14, 43), CPos.New(14, 42), CPos.New(14, 45), CPos.New(14, 46), CPos.New(15, 46), CPos.New(15, 45), CPos.New(16, 45), CPos.New(16, 46), CPos.New(14, 48), CPos.New(14, 49), CPos.New(15, 49), CPos.New(15, 48), CPos.New(16, 48), CPos.New(16, 49), CPos.New(13, 51), CPos.New(14, 51), CPos.New(13, 53), CPos.New(13, 54), CPos.New(14, 54), CPos.New(14, 53), CPos.New(13, 56), CPos.New(13, 57), CPos.New(14, 57), CPos.New(14, 56), CPos.New(13, 59), CPos.New(13, 60), CPos.New(14, 60), CPos.New(14, 59), CPos.New(13, 62), CPos.New(13, 63), CPos.New(14, 63), CPos.New(14, 62), CPos.New(13, 65), CPos.New(13, 66), CPos.New(14, 66), CPos.New(14, 65), CPos.New(13, 68), CPos.New(13, 69), CPos.New(14, 69), CPos.New(14, 68), CPos.New(13, 71), CPos.New(13, 72), CPos.New(14, 72), CPos.New(14, 71), CPos.New(13, 74), CPos.New(13, 75), CPos.New(14, 75), CPos.New(14, 74), CPos.New(13, 77), CPos.New(13, 78), CPos.New(14, 78), CPos.New(14, 77), CPos.New(14, 80), CPos.New(14, 81), CPos.New(15, 81), CPos.New(15, 80), CPos.New(16, 80), CPos.New(16, 81), CPos.New(13, 83), CPos.New(13, 84), CPos.New(14, 84), CPos.New(14, 83), CPos.New(13, 85), CPos.New(14, 85), CPos.New(13, 87), CPos.New(14, 87), CPos.New(14, 88), CPos.New(13, 88), CPos.New(13, 90), CPos.New(13, 91), CPos.New(14, 90), CPos.New(14, 91), CPos.New(14, 92), CPos.New(13, 92), CPos.New(13, 94), CPos.New(13, 95), CPos.New(14, 95), CPos.New(14, 94), CPos.New(13, 97), CPos.New(13, 98), CPos.New(14, 98), CPos.New(14, 97), CPos.New(14, 99), CPos.New(13, 99), CPos.New(13, 101), CPos.New(14, 101), CPos.New(14, 102), CPos.New(13, 102), CPos.New(13, 104), CPos.New(13, 106), CPos.New(13, 107), CPos.New(14, 107), CPos.New(14, 106), CPos.New(14, 109), CPos.New(14, 110), CPos.New(15, 110), CPos.New(15, 109), CPos.New(16, 109), CPos.New(16, 110), CPos.New(14, 112), CPos.New(15, 112), CPos.New(16, 112), CPos.New(13, 114), CPos.New(13, 115), CPos.New(14, 115), CPos.New(14, 114), CPos.New(13, 117), CPos.New(14, 117), CPos.New(13, 119), CPos.New(13, 120), CPos.New(14, 120), CPos.New(14, 119), CPos.New(13, 122), CPos.New(13, 124), CPos.New(13, 126), CPos.New(13, 127), CPos.New(14, 126), CPos.New(14, 127), CPos.New(14, 129), CPos.New(14, 130), CPos.New(15, 130), CPos.New(15, 129), CPos.New(16, 129), CPos.New(16, 130), CPos.New(17, 132), CPos.New(17, 133), CPos.New(17, 134), CPos.New(18, 134), CPos.New(18, 133), CPos.New(18, 132), CPos.New(19, 132), CPos.New(19, 133), CPos.New(19, 134), CPos.New(20, 134), CPos.New(20, 133), CPos.New(20, 132), CPos.New(21, 132), CPos.New(21, 133), CPos.New(21, 134), CPos.New(22, 134), CPos.New(22, 133), CPos.New(22, 132), CPos.New(13, 136), CPos.New(14, 136), CPos.New(14, 137), CPos.New(13, 137), CPos.New(13, 139), CPos.New(14, 139), CPos.New(14, 140), CPos.New(13, 140), CPos.New(13, 142), CPos.New(14, 142), CPos.New(14, 143), CPos.New(13, 143), CPos.New(13, 144), CPos.New(14, 144), CPos.New(13, 146), CPos.New(13, 147), CPos.New(13, 148), CPos.New(14, 148), CPos.New(14, 147), CPos.New(14, 146), CPos.New(13, 150), CPos.New(13, 151), CPos.New(13, 153), CPos.New(14, 153), CPos.New(14, 154), CPos.New(13, 154), CPos.New(13, 156), CPos.New(14, 156), CPos.New(14, 158), CPos.New(14, 159), CPos.New(14, 160), CPos.New(15, 160), CPos.New(15, 159), CPos.New(15, 158), CPos.New(16, 158), CPos.New(16, 159), CPos.New(16, 160), CPos.New(13, 162), CPos.New(13, 163), CPos.New(14, 163), CPos.New(14, 162), CPos.New(13, 165), CPos.New(13, 166), CPos.New(14, 166), CPos.New(14, 165), CPos.New(13, 168), CPos.New(13, 169), CPos.New(14, 169), CPos.New(14, 168), CPos.New(13, 171), CPos.New(13, 172), CPos.New(14, 172), CPos.New(14, 171), CPos.New(13, 174), CPos.New(13, 175), CPos.New(14, 175), CPos.New(14, 174), CPos.New(13, 177), CPos.New(13, 178), CPos.New(14, 178), CPos.New(14, 177), CPos.New(13, 180), CPos.New(13, 181), CPos.New(14, 181), CPos.New(14, 180), CPos.New(14, 183), CPos.New(14, 184), CPos.New(14, 185), CPos.New(13, 185), CPos.New(13, 184), CPos.New(13, 183), CPos.New(13, 188), CPos.New(13, 187), CPos.New(14, 187), CPos.New(14, 188), CPos.New(14, 190), CPos.New(13, 191), CPos.New(13, 190), CPos.New(14, 191), CPos.New(13, 193), CPos.New(13, 194), CPos.New(14, 194), CPos.New(14, 193), CPos.New(13, 196), CPos.New(13, 197), CPos.New(14, 197), CPos.New(14, 196), CPos.New(14, 199), CPos.New(14, 200), CPos.New(13, 200), CPos.New(13, 199), CPos.New(13, 202), CPos.New(13, 203), CPos.New(14, 203), CPos.New(14, 202), CPos.New(14, 205), CPos.New(14, 206), CPos.New(13, 206), CPos.New(13, 205), CPos.New(13, 208), CPos.New(13, 209), CPos.New(14, 209), CPos.New(14, 208), CPos.New(14, 211), CPos.New(14, 212), CPos.New(13, 212), CPos.New(13, 211), CPos.New(13, 214), CPos.New(13, 215), CPos.New(14, 214), CPos.New(14, 215), CPos.New(14, 218), CPos.New(14, 217), CPos.New(13, 217), CPos.New(13, 218), CPos.New(13, 220), CPos.New(13, 221), CPos.New(14, 221), CPos.New(14, 220), CPos.New(14, 223), CPos.New(15, 223), CPos.New(16, 223) }
local CenterTerrains = { "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Sand", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Sand", "Cliff", "Cliff", "Sand", "Sand", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Sand", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Sand", "Sand", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Rock", "Transition", "Cliff", "Cliff", "Rock", "Rock", "Cliff", "Cliff", "Cliff", "Cliff", "Rock", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Rock", "Rock", "Cliff", "Cliff", "Rock", "Rock", "Cliff", "Cliff", "Rock", "Rock", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Sand", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Sand", "Cliff", "Cliff", "Cliff", "Rock", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Rock", "Rock", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Rock", "Rock", "Cliff", "Cliff", "Rock", "Sand", "Cliff", "Sand", "Cliff", "Cliff", "Sand", "Cliff", "Sand", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Sand", "Cliff", "Transition", "Transition", "Transition", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "SpiceSand", "Sand", "Sand", "Sand", "Sand", "Sand", "Sand", "Sand", "Sand", "Sand", "Sand", "Sand", "Sand", "Sand", "SpiceSand", "SpiceSand", "Sand", "Sand", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Rock", "Cliff", "Cliff", "Rough", "Rough", "Rock", "Rock", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Cliff", "Rough", "Cliff" }
local RightCells = { CPos.New(16, 6), CPos.New(17, 6), CPos.New(17, 7), CPos.New(16, 7), CPos.New(16, 9), CPos.New(17, 9), CPos.New(17, 10), CPos.New(16, 10), CPos.New(16, 12), CPos.New(17, 12), CPos.New(17, 13), CPos.New(16, 13), CPos.New(16, 15), CPos.New(17, 15), CPos.New(17, 16), CPos.New(16, 16), CPos.New(16, 18), CPos.New(17, 18), CPos.New(17, 19), CPos.New(16, 19), CPos.New(16, 21), CPos.New(17, 21), CPos.New(17, 22), CPos.New(16, 22), CPos.New(16, 24), CPos.New(17, 24), CPos.New(17, 25), CPos.New(16, 25), CPos.New(16, 27), CPos.New(17, 27), CPos.New(17, 28), CPos.New(16, 28), CPos.New(16, 33), CPos.New(17, 33), CPos.New(17, 34), CPos.New(16, 34), CPos.New(16, 36), CPos.New(17, 36), CPos.New(17, 37), CPos.New(16, 37), CPos.New(16, 39), CPos.New(17, 39), CPos.New(17, 40), CPos.New(16, 40), CPos.New(16, 42), CPos.New(17, 42), CPos.New(17, 43), CPos.New(16, 43), CPos.New(18, 45), CPos.New(19, 46), CPos.New(18, 46), CPos.New(19, 45), CPos.New(20, 45), CPos.New(20, 46), CPos.New(18, 48), CPos.New(18, 49), CPos.New(19, 48), CPos.New(19, 49), CPos.New(20, 49), CPos.New(20, 48), CPos.New(16, 51), CPos.New(17, 51), CPos.New(16, 53), CPos.New(16, 54), CPos.New(17, 54), CPos.New(17, 53), CPos.New(16, 56), CPos.New(17, 56), CPos.New(17, 57), CPos.New(16, 57), CPos.New(16, 59), CPos.New(16, 60), CPos.New(17, 60), CPos.New(17, 59), CPos.New(16, 62), CPos.New(16, 63), CPos.New(17, 63), CPos.New(17, 62), CPos.New(16, 65), CPos.New(16, 66), CPos.New(17, 66), CPos.New(17, 65), CPos.New(16, 68), CPos.New(16, 69), CPos.New(17, 69), CPos.New(17, 68), CPos.New(16, 71), CPos.New(16, 72), CPos.New(17, 72), CPos.New(17, 71), CPos.New(16, 74), CPos.New(16, 75), CPos.New(17, 75), CPos.New(17, 74), CPos.New(16, 77), CPos.New(16, 78), CPos.New(17, 78), CPos.New(17, 77), CPos.New(18, 80), CPos.New(18, 81), CPos.New(19, 81), CPos.New(19, 80), CPos.New(20, 80), CPos.New(20, 81), CPos.New(16, 83), CPos.New(16, 84), CPos.New(16, 85), CPos.New(17, 85), CPos.New(17, 84), CPos.New(17, 83), CPos.New(16, 87), CPos.New(16, 88), CPos.New(17, 88), CPos.New(17, 87), CPos.New(16, 90), CPos.New(16, 91), CPos.New(16, 92), CPos.New(17, 92), CPos.New(17, 91), CPos.New(17, 90), CPos.New(16, 94), CPos.New(16, 95), CPos.New(17, 95), CPos.New(17, 94), CPos.New(16, 97), CPos.New(16, 98), CPos.New(16, 99), CPos.New(17, 99), CPos.New(17, 98), CPos.New(17, 97), CPos.New(16, 101), CPos.New(16, 102), CPos.New(17, 102), CPos.New(17, 101), CPos.New(16, 104), CPos.New(16, 106), CPos.New(16, 107), CPos.New(17, 107), CPos.New(17, 106), CPos.New(18, 109), CPos.New(18, 110), CPos.New(19, 110), CPos.New(19, 109), CPos.New(20, 109), CPos.New(20, 110), CPos.New(18, 112), CPos.New(19, 112), CPos.New(20, 112), CPos.New(16, 114), CPos.New(16, 115), CPos.New(17, 115), CPos.New(17, 114), CPos.New(16, 117), CPos.New(17, 117), CPos.New(16, 119), CPos.New(16, 120), CPos.New(17, 120), CPos.New(17, 119), CPos.New(16, 122), CPos.New(16, 124), CPos.New(16, 126), CPos.New(16, 127), CPos.New(17, 127), CPos.New(17, 126), CPos.New(18, 129), CPos.New(18, 130), CPos.New(19, 130), CPos.New(19, 129), CPos.New(20, 129), CPos.New(20, 130), CPos.New(24, 132), CPos.New(24, 133), CPos.New(24, 134), CPos.New(25, 134), CPos.New(25, 133), CPos.New(25, 132), CPos.New(26, 134), CPos.New(26, 132), CPos.New(27, 132), CPos.New(26, 133), CPos.New(27, 134), CPos.New(27, 133), CPos.New(28, 133), CPos.New(28, 132), CPos.New(29, 132), CPos.New(29, 133), CPos.New(29, 134), CPos.New(28, 134), CPos.New(16, 137), CPos.New(17, 137), CPos.New(17, 136), CPos.New(16, 136), CPos.New(16, 139), CPos.New(16, 140), CPos.New(17, 140), CPos.New(17, 139), CPos.New(16, 142), CPos.New(16, 143), CPos.New(16, 144), CPos.New(17, 144), CPos.New(17, 143), CPos.New(17, 142), CPos.New(16, 147), CPos.New(16, 146), CPos.New(17, 146), CPos.New(17, 147), CPos.New(17, 148), CPos.New(16, 148), CPos.New(16, 150), CPos.New(16, 151), CPos.New(16, 153), CPos.New(17, 153), CPos.New(17, 154), CPos.New(16, 154), CPos.New(16, 156), CPos.New(17, 156), CPos.New(18, 158), CPos.New(18, 159), CPos.New(18, 160), CPos.New(19, 160), CPos.New(19, 159), CPos.New(19, 158), CPos.New(20, 158), CPos.New(20, 159), CPos.New(20, 160), CPos.New(16, 162), CPos.New(16, 163), CPos.New(17, 163), CPos.New(17, 162), CPos.New(16, 165), CPos.New(16, 166), CPos.New(17, 166), CPos.New(17, 165), CPos.New(16, 168), CPos.New(16, 169), CPos.New(17, 169), CPos.New(17, 168), CPos.New(16, 171), CPos.New(16, 172), CPos.New(17, 171), CPos.New(17, 172), CPos.New(16, 174), CPos.New(16, 175), CPos.New(17, 175), CPos.New(17, 174), CPos.New(16, 177), CPos.New(16, 178), CPos.New(17, 178), CPos.New(17, 177), CPos.New(16, 180), CPos.New(16, 181), CPos.New(17, 181), CPos.New(17, 180), CPos.New(16, 183), CPos.New(16, 184), CPos.New(16, 185), CPos.New(17, 185), CPos.New(17, 184), CPos.New(17, 183), CPos.New(16, 187), CPos.New(16, 188), CPos.New(17, 188), CPos.New(17, 187), CPos.New(16, 190), CPos.New(16, 191), CPos.New(17, 191), CPos.New(17, 190), CPos.New(16, 193), CPos.New(16, 194), CPos.New(17, 194), CPos.New(17, 193), CPos.New(16, 196), CPos.New(16, 197), CPos.New(17, 197), CPos.New(17, 196), CPos.New(16, 199), CPos.New(16, 200), CPos.New(17, 200), CPos.New(17, 199), CPos.New(16, 202), CPos.New(16, 203), CPos.New(17, 203), CPos.New(17, 202), CPos.New(16, 205), CPos.New(16, 206), CPos.New(17, 206), CPos.New(17, 205), CPos.New(16, 208), CPos.New(16, 209), CPos.New(17, 209), CPos.New(17, 208), CPos.New(16, 211), CPos.New(16, 212), CPos.New(17, 212), CPos.New(17, 211), CPos.New(16, 214), CPos.New(16, 215), CPos.New(17, 215), CPos.New(17, 214), CPos.New(16, 217), CPos.New(16, 218), CPos.New(17, 218), CPos.New(17, 217), CPos.New(16, 220), CPos.New(16, 221), CPos.New(17, 221), CPos.New(17, 220), CPos.New(18, 223), CPos.New(19, 223), CPos.New(20, 223) }

local function GetMarkedCells()
	local marks = Utils.Where(Map.ActorsInWorld, function(a)
		return a.Type == "waypoint" and a ~= BoxTop and a ~= BoxBottom end)

	local cells = { }
	Utils.Do(marks, function(m)
		cells[#cells + 1] = m.Location
	end)

	return cells
end

local function PrintCells(cells, label)
	label = label or ""
	local text = label .. " Cells = { "
	for i = 1, #cells do
		local info = "CPos.New(" .. cells[i].X .. ", " .. cells[i].Y .. ")"
		text = text .. info .. ", "
	end

	text = text .. "\n}"
	print(text)
end

---@param cells cpos[]
local function PrintTerrains(cells)
	local text = "Terrains = { "

	for i = 1, #cells do
		if Map.TerrainType(cells[i]) ~= "Concrete" then
			local info = "\"" .. Map.TerrainType(cells[i]) .. "\""
			text = text .. info .. ", "
		end
	end

	text = text .. "\n}"
	print(text)
end

---@param cells cpos[]
---@return string[]
local function TerrainsFromCells(cells)
	local terrains = { }

	for i = 1, #cells do
		terrains[i] = Map.TerrainType(cells[i])
	end

	return terrains
end

---@param cell cpos
local function SpawnInfantryCluster(cell)
	for i = 1, 5 do
		Actor.Create("e1", true, { Owner = Atreides, Location = cell, SubCell = i })
	end
end

---@param cell cpos
---@param terrain? string
local function AddCellLabel(cell, terrain)
	terrain = terrain or Map.TerrainType(cell)
	Actor.Create("label_" .. string.lower(terrain), true, { Owner = Atreides, Location = cell })
end

WorldLoaded = function()
	Actor.Create("camera.all", true, { Owner = Atreides, Location = CPos.Zero })
	Camera.Position = BoxTop.CenterPosition

	--local mc = GetMarkedCells()
	--PrintCells(mc, "Marked")
	--PrintTerrains(mc)
	local rightTerrains = TerrainsFromCells(RightCells)

	for i = 1, #CenterCells do
		AddCellLabel(CenterCells[i], CenterTerrains[i])
	end

	for i = 1, #RightCells do
		AddCellLabel(RightCells[i], rightTerrains[i])
		--SpawnInfantryCluster(RightCells[i])
	end
end

Tick = function()
	Atreides.Cash = 5000
end
