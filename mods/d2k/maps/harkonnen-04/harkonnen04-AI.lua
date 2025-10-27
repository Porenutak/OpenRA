--[[
   Copyright (c) The OpenRA Developers and Contributors
   This file is part of OpenRA, which is free software. It is made
   available to you under the terms of the GNU General Public License
   as published by the Free Software Foundation, either version 3 of
   the License, or (at your option) any later version. For more
   information, see COPYING.
]]
EarlyGameStage = DateTime.Minutes(6)

InitialProductionDelay = {
		easy = DateTime.Seconds(150),
		normal = DateTime.Seconds(100),
		hard = DateTime.Seconds(60)
}
AttackGroupSize =
{
	easy = 6,
	normal = 8,
	hard = 10
}

EarlyAttackDelays =
{
	easy = { DateTime.Seconds(7), DateTime.Seconds(10) },
	normal = { DateTime.Seconds(4), DateTime.Seconds(6) },
	hard = { DateTime.Seconds(3), DateTime.Seconds(5) }
}
LateAttackDelays =
{
	easy = { DateTime.Seconds(4), DateTime.Seconds(7) },
	normal = { DateTime.Seconds(2), DateTime.Seconds(5) },
	hard = { DateTime.Seconds(1), DateTime.Seconds(3) }
}



AtreidesInfantryTypes = { "light_inf", "light_inf", "trooper", "trooper", "trooper" }
AtreidesVehicleTypes = { "trike", "trike", "quad" }
AtreidesTankType = { "combat_tank_a" }
RebuildBuildingstypes =
{
	wind_trap = {},
	barracks = AtreidesInfantryTypes,
	refinery = {},
	outpost = {},
	light_factory = AtreidesVehicleTypes,
	heavy_factory = AtreidesTankType
}

AttackThresholdSize = AttackGroupSize[Difficulty] * 2.5

ActivateAI = function()
	AlreadyDefending[Atreides] = {}
	AlreadyDefending[Fremen] = {}
	GuardSquad[Atreides] = {}
	GuardSquad[Fremen] = {}
	GuarSquadUnitLimit[Atreides] = AttackThresholdSize
	GuarSquadUnitLimit[Fremen] = 0

	IdlingUnits[Fremen] = { }
	IdlingUnits[Atreides] = Utils.Concat(Reinforcements.Reinforce(Atreides, InitialAtreidesReinforcements[1], AtreidesPaths[2]), Reinforcements.Reinforce(Atreides, InitialAtreidesReinforcements[2], AtreidesPaths[3]))
	AddUnitsToPatrolSquad(Atreides, #IdlingUnits[Atreides])
	FremenProduction()
	DefensePerimeter[Atreides] = GetCellsInRectangle(CPos.New(4,67), CPos.New(50, 87))
--[[
	Trigger.OnEnteredFootprint(DefensePerimeter[Atreides], function(intruder, id)
		if Atreides.IsAlliedWith(intruder.Owner) or AlreadyDefending[Atreides][id]
		then
			Media.Debug("false positive "..tostring(intruder))
			return
		end
		Media.Debug("INTRUDER "..tostring(intruder))
		CheckArea(Atreides, intruder.Location)
		AlreadyDefending[Atreides][id] = true
		Trigger.AfterDelay(1000, function()
			AlreadyDefending[Atreides][id] = false
		end)
	end)
]]
	DefendAndRepairBase(Atreides, AtreidesBase, 0.75, AttackGroupSize[Difficulty])
	DefendAndRepairBase(Fremen, FremenBase, 0.75, AttackGroupSize[Difficulty])

	delay = function()
		if EarlyGameStage >= DateTime.GameTime then
			return Utils.RandomInteger(EarlyAttackDelays[Difficulty][1], EarlyAttackDelays[Difficulty][2] + 1)
		else
			return Utils.RandomInteger(LateAttackDelays[Difficulty][1], LateAttackDelays[Difficulty][2] + 1)
		end
	end
	local infantryToBuild = function() return { Utils.Random(AtreidesInfantryTypes) } end
	local vehilcesToBuild = function() return { Utils.Random(AtreidesVehicleTypes) } end
	local tanksToBuild = function() return AtreidesTankType end

	Trigger.AfterDelay(InitialProductionDelay[Difficulty], function()
		ProduceUnits(Atreides, ABarracks, delay, infantryToBuild, AttackGroupSize[Difficulty], AttackThresholdSize)
		ProduceUnits(Atreides, ALightFactory, delay, vehilcesToBuild, AttackGroupSize[Difficulty], AttackThresholdSize)
		ProduceUnits(Atreides, AHeavyFactory, delay, tanksToBuild, AttackGroupSize[Difficulty], AttackThresholdSize)
	end)
	ActivateCrusherOnProductions( { "combat_tank_a" }, { AHeavyFactory } )
	ActivateBaseRebuilder(Atreides, AtreidesBase, RebuildBuildingstypes)
end
