BotPlayers = {}
IsAnyBotsHere = false
CurrentConyards = {}
CheckPlayerTechtree = false
ActivePlayers = {}
PlayersThatNotchoosedyet = 0 --Numbver of players that didnt choose any subfaction yet
FactionsMode = 0 -- default Faction mode: vannila
local CallAirstrike -- must be local fuction. otherwise it crash when multiple AirStrikes are called at ones.
ActorRegister={}
--Airstrike variables
SquadSpamDelay = 0 -- Spam delay betwwen every Aircraft. Use when Useoffest is false, else 0
SpamWposOffsets = {-1256, 0, 1256} -- offset for each aircraft
Useoffest = true -- if false Air sqad will span in line. !!! If false SquadSpamDelay must be least 5 !!!!
ReinforcementSquads = {
	{"light_inf.vet4","light_inf.vet3","light_inf.vet3","trooper.vet2","trooper.vet2"},
	{"light_inf.vet3", "light_inf.vet3", "trooper.vet2", "trooper.vet2", "trooper.vet2"},
	{"mpsardaukar.level3","mpsardaukar.level2","light_inf.vet4", "trooper.vet2",  "mpsardaukar.level2"},
	{"mercenary","mercenary","mercenary","mercenary","mercenary"}
}
--different Squads for different Factons 1.Atreides, 2. Ordos 3. Harkonnen
AirSquads = {
	{"ornithopter_a","ornithopter_a", "ornithopter_a"},
	{"ornithopter_a","ornithopter_a"},
	{"ornithopter_o", "ornithopter_o", "ornithopter_o"}
}
DropActor = {"carryall.reinforce_with_sound", "carryall.reinforce_with_sound", "frigate.harkonnen_cargo"}

SubfactionPrerequisitesList = {}
SubfactionPrerequisitesList["atreides"] = "subfaction.atreides"
SubfactionPrerequisitesList["fremen"] = "subfaction.fremen"
SubfactionPrerequisitesList["harkonnen"] = "subfaction.harkonnen"
SubfactionPrerequisitesList["corrino"] = "subfaction.corrino"
SubfactionPrerequisitesList["ordos"] = "subfaction.ordos"
SubfactionPrerequisitesList["smuggler"] = "subfaction.smuggler"
SubfactionPrerequisitesList["mercenary"] = "subfaction.mercenary"
Mergedsubfactions = { "merged.fremen","merged.corrino","merged.smuggler", "merged.mercenary"}

-- Experimental Starport variables - limited to 24 players
FrigateDeliveryDelay = 1500 --how much time to wait until frigate arrives
FrigateCapacity = 5 -- must be set as: n -1
StarportUnits = {}
StarportUnits["Multi0"] = {}
StarportUnits["Multi1"] = {}
StarportUnits["Multi2"] = {}
StarportUnits["Multi3"] = {}
StarportUnits["Multi4"] = {}
StarportUnits["Multi5"] = {}
StarportUnits["Multi6"] = {}
StarportUnits["Multi7"] = {}
StarportUnits["Multi8"] = {}
StarportUnits["Multi9"] = {}
StarportUnits["Multi10"] = {}
StarportUnits["Multi11"] = {}
StarportUnits["Multi12"] = {}
StarportUnits["Multi13"] = {}
StarportUnits["Multi14"] = {}
StarportUnits["Multi15"] = {}
StarportUnits["Multi16"] = {}
StarportUnits["Multi17"] = {}
StarportUnits["Multi18"] = {}
StarportUnits["Multi19"] = {}
StarportUnits["Multi20"] = {}
StarportUnits["Multi21"] = {}
StarportUnits["Multi22"] = {}
StarportUnits["Multi23"] = {}
RevokeTokens = {} --isFull and notEmpty revoke tokens
RevokeTokens["Multi0"] = {}
RevokeTokens["Multi1"] = {}
RevokeTokens["Multi2"] = {}
RevokeTokens["Multi3"] = {}
RevokeTokens["Multi4"] = {}
RevokeTokens["Multi5"] = {}
RevokeTokens["Multi6"] = {}
RevokeTokens["Multi7"] = {}
RevokeTokens["Multi8"] = {}
RevokeTokens["Multi9"] = {}
RevokeTokens["Multi10"] = {}
RevokeTokens["Multi11"] = {}
RevokeTokens["Multi12"] = {}
RevokeTokens["Multi13"] = {}
RevokeTokens["Multi14"] = {}
RevokeTokens["Multi15"] = {}
RevokeTokens["Multi16"] = {}
RevokeTokens["Multi17"] = {}
RevokeTokens["Multi18"] = {}
RevokeTokens["Multi19"] = {}
RevokeTokens["Multi20"] = {}
RevokeTokens["Multi21"] = {}
RevokeTokens["Multi22"] = {}
RevokeTokens["Multi23"] = {}
DummyActors = {} -- used for icons overiddes
DummyActors["Multi0"] = {}
DummyActors["Multi1"] = {}
DummyActors["Multi2"] = {}
DummyActors["Multi3"] = {}
DummyActors["Multi4"] = {}
DummyActors["Multi5"] = {}
DummyActors["Multi6"] = {}
DummyActors["Multi7"] = {}
DummyActors["Multi8"] = {}
DummyActors["Multi9"] = {}
DummyActors["Multi10"] = {}
DummyActors["Multi11"] = {}
DummyActors["Multi12"] = {}
DummyActors["Multi13"] = {}
DummyActors["Multi14"] = {}
DummyActors["Multi15"] = {}
DummyActors["Multi16"] = {}
DummyActors["Multi17"] = {}
DummyActors["Multi18"] = {}
DummyActors["Multi19"] = {}
DummyActors["Multi20"] = {}
DummyActors["Multi21"] = {}
DummyActors["Multi22"] = {}
DummyActors["Multi23"] = {}
RepairPadList = {} -- repairpad owned by Bots

WorldLoaded = function()
	--get players
	mp0=Player.GetPlayer("Multi0")
	mp1=Player.GetPlayer("Multi1")
	mp2=Player.GetPlayer("Multi2")
	mp3=Player.GetPlayer("Multi3")
	mp4=Player.GetPlayer("Multi4")
	mp5=Player.GetPlayer("Multi5")
	mp6=Player.GetPlayer("Multi6")
	mp7=Player.GetPlayer("Multi7")
	mp8=Player.GetPlayer("Multi8")
	mp9=Player.GetPlayer("Multi9")
	mp10=Player.GetPlayer("Multi10")
	mp11=Player.GetPlayer("Multi11")
	mp12=Player.GetPlayer("Multi12")
	mp13=Player.GetPlayer("Multi13")
	mp14=Player.GetPlayer("Multi14")
	mp15=Player.GetPlayer("Multi15")
	mp16=Player.GetPlayer("Multi16")
	mp17=Player.GetPlayer("Multi17")
	mp18=Player.GetPlayer("Multi18")
	mp19=Player.GetPlayer("Multi19")
	mp20=Player.GetPlayer("Multi20")
	mp21=Player.GetPlayer("Multi21")
	mp22=Player.GetPlayer("Multi22")
	mp23=Player.GetPlayer("Multi23")
	mp24=Player.GetPlayer("Multi24")
	mp25=Player.GetPlayer("Multi25")
	mp26=Player.GetPlayer("Multi26")
	mp27=Player.GetPlayer("Multi27")
	Players = {mp0, mp1, mp2, mp3, mp4, mp5, mp6, mp7, mp8, mp9, mp10, mp11, mp12, mp13, mp14, mp15, mp16, mp17, mp18, mp19, mp20, mp21, mp22, mp23, mp24, mp25, mp26, mp27}
	
	FactionsMode  = tonumber(Map.LobbyOption("fation_mode"))
	if (FactionsMode == 0) then
		--Media.DisplayMessage("you play with standart d2k mode", "Mentat", HSLColor.DarkRed)
	end
	if (FactionsMode == 1) then
		Media.DisplayMessage("Sub-faction Mode - Choose between Major faction or one of its sub-factions", "Mentat",  HSLColor.DarkRed)
	end
	if (FactionsMode == 2) then
		Media.DisplayMessage("Merge Faction mode - chosen subfaction will be merged in to your Major faction","Mentat", HSLColor.DarkRed)
	end
	for i, player in pairs(Players)
		do
		-- freecarryall
		if player.HasPrerequisites({"FreeCarry"})
		then
			addCarryToPlayer(player)
		end
		-- factions  option check
		if (FactionsMode == 0)
		then
			player.GrantCondition("vanilla_factions_Only")
			addmcv(player)
		elseif (FactionsMode == 1) then
			CheckPlayerTechtree = true
			player.GrantCondition("subfactions")
				botsubfaction(player)
		elseif (FactionsMode == 2) then
			player.GrantCondition("mergedsubfactions")
			botsubfaction(player)
			CheckPlayerTechtree = true
		end
		--adding bots to table
		if player.IsBot then
			table.insert(BotPlayers, player)
		end
		if not player.IsNonCombatant then
			table.insert(ActivePlayers, player)
		end
	end
	-- worm delay
	local wormDelay = Map.LobbyOption("WormsSpawnDelay")
	if tonumber(wormDelay) > 0
	then
		local delay = tonumber(Map.LobbyOption("WormsSpawnDelay"))
		Trigger.AfterDelay(DateTime.Minutes(delay), function()
			--in teory any player can own wormspawner actor
			wormSpawnFunction(Player.GetPlayer("Creeps"))
			wormSpawnFunction(Player.GetPlayer("Neutral"))
			for i, player in pairs(Players)
			do
				wormSpawnFunction(player)
			end
		end)
	end
	-- Scripts for BOTS
	for i, bot in pairs(BotPlayers)
	do
		IsAnyBotsHere = true
		FindSaboteur(bot)
	end
	--Production trriggers - Starport, AI Engi, AI Repairing
	Trigger.OnAnyProduction( function(producer, produced, productionQueue)
			local actor = produced.Type
		if productionQueue == "Starport" then
			if actor == "purchase.starport" then
				CHOAMDelivery(produced.Owner)
			-- Mercenary support power
			elseif actor == "dummy_mercenary_spawnpoint" then
				CHOAMDeliverCustomUnits(producer.Owner, ReinforcementSquads[4])
				produced.Destroy()
			elseif actor=="dummy.trike" or actor=="dummy.quad" or actor=="dummy.harvester" or actor=="dummy.mcv" or actor=="dummy.combat_tank_a" or actor=="dummy.combat_tank_o" or actor=="dummy.combat_tank_h" or actor=="dummy.siege_tank" or actor=="dummy.missile_tank" or actor=="dummy.carryall" or actor=="dummy.combat_tank_cheap"or actor=="dummy.combat_tank_corrino" then
				ExperimentalStarport(producer.Owner, produced)
			end
		end
		if produced.Owner.IsBot then
			if actor == "engineer" then
				EnginnerLogic(produced)
			end
		if productionQueue == "Armor" or productionQueue== "Vehicle" then
			CheckForRepair(produced, produced.MaxHealth, produced.Owner.InternalName)
		end
		end
	end)
end

function addCarryToPlayer(player)

	local actors = player.GetActorsByTypes({"mcv", "construction_yard", "choosefaction"})
	for i, actor in pairs(actors) do
		if (actor.Type == "mcv") or (actor.Type == "construction_yard") or (actor.Type == "choosefaction") then
			Reinforcements.Reinforce(player, { "carryall" }, { actor.Owner.HomeLocation}, 10)
			return
		end
	end
	Reinforcements.Reinforce(player, { "carryall" }, { player.HomeLocation}, 10)
end

function wormSpawnFunction(owner)
    local actorsSpawner = owner.GetActorsByType("wormspawner")
  if actorsSpawner ~= nil
  then
    for i, spawner in pairs(actorsSpawner)
    do
      if spawner.AcceptsCondition("WormSpamDelayed")
      then
        spawner.GrantCondition("WormSpamDelayed")
      end
    end
  end
end



Tick = function()
	--everything execute's one's per 2 second, because preformance :( - will case lags
	if DateTime.GameTime % DateTime.Seconds(2) == 0 then
		local New_actors = ActorsAddedToWorld(Map.ActorsInWorld, ActorRegister)
		for _,actor in pairs(New_actors) do
			local actType = actor.Type --less expensive that act.Type
			-- Air support powers
			if actType == "waypoint.airtstrike_a" then
				CallAirstrike(actor)
			end
			if actType == "waypoint.airtstrike_o" then
				CallAirstrike(actor)
			end
			if actType == "waypoint.reinforce_h" or actType == "waypoint.reinforce_o" then
				DropAirReinforcements(actor)
			end
			if actType == "repair_pad.bot"then
				RepairPadList[actor.Owner.InternalName] = actor
			end
		end
	end
	-- Bot engi  protection scripts: executed ones per 2 sec.
	if IsAnyBotsHere then
		if DateTime.GameTime % DateTime.Seconds(2) == 0 then
			findConyards()
			engiProtection()
		end
	end
	-- check if player already choose subfaction
	if(CheckPlayerTechtree == true and PlayersThatNotchoosedyet > 0) then
	--	Media.DisplayMessage("cheking")
		techtreecheck()
	end

end

-------------------------
--FactionsModes Scripts--
-------------------------
function addmcv(player)
		local actors = player.GetActorsByType("choosefaction")
		for pom, actor in pairs(actors) do
			local mcv = Actor.Create("mcv", true, { Owner = player, Facing = Angle.SouthWest, Location = actor.Location})
			actor.Kill();
			if player.IsBot then
				mcv.Deploy()
			end
		end
end

function techtreecheck()
	for i, player in pairs(Players) do
		local actors = player.GetActorsByType("choosefaction")
		if FactionsMode == 1 then
			for faction, prerequisite in pairs(SubfactionPrerequisitesList) do
				if player.HasPrerequisites({prerequisite}) then
					for pom, actor in pairs(actors) do
						Actor.Create("mcv", true, { Owner = player, Facing = Angle.North, Location = actor.Location, Faction = faction})
						actor.Kill();
						PlayersThatNotchoosedyet = PlayersThatNotchoosedyet - 1
						--Media.DisplayMessage("Subfaction choosed", tostring(PlayersThatNotchoosedyet))
					end
				end
			end
		elseif FactionsMode == 2 then
			for faction, prerequisite in pairs(Mergedsubfactions) do
				if player.HasPrerequisites({prerequisite}) then
					for pom, actor in pairs(actors) do
						Actor.Create("mcv", true, { Owner = player, Facing = Angle.North, Location = actor.Location, Faction = player.Faction})
						actor.Kill();
						PlayersThatNotchoosedyet = PlayersThatNotchoosedyet - 1
						--Media.DisplayMessage("Subfaction choosed Remaining"..tostring(PlayersThatNotchoosedyet))
					end
				end
			end
		end
	end
end

function botsubfaction(player)
	if(not player.IsBot)
	then
		PlayersThatNotchoosedyet = PlayersThatNotchoosedyet + 1
		--Media.DisplayMessage("got the player",tostring(PlayersThatNotchoosedyet) )
	else
		local bluefactions = {"atreides", "fremen"}
		local redfactions = {"harkonnen", "corrino"}
		local greenfactions = {"ordos", "smuggler", "mercenary"}
		local faction = {}
		local actors = player.GetActorsByType("choosefaction")
		if (FactionsMode == 1) then
			if player.Faction == "atreides" then
				faction = bluefactions
			end
			if player.Faction == "harkonnen" then
				faction = redfactions
			end
			if player.Faction == "ordos" then
				faction = greenfactions
			end
			--Media.DisplayMessage("got the bot")
			for pom, actor in pairs(actors) do
				local mcv = Actor.Create("mcv", true, { Owner = player, Facing = Angle.North, Location = actor.Location, Faction = Utils.Random(faction)})
				actor.Kill();
				if player.IsBot then
					mcv.Deploy()
				end
			end
		else
			faction = player.Faction
			for pom, actor in pairs(actors) do
				local mcv = Actor.Create("mcv", true, { Owner = player, Facing = Angle.North, Location = actor.Location, Faction = player.Faction})
				Actor.Create( Utils.Random(Mergedsubfactions), true, { Owner = player, Facing = Angle.North, Location = actor.Location, Faction = player.Faction})
				actor.Kill();
				if player.IsBot then
					mcv.Deploy()
				end
			end
		end
	end
end

-----------------------------------
---AI protection against engineer--
-----------------------------------

function engiProtection()
  for i, conyard in pairs(CurrentConyards) do
    if conyard.IsDead then
        --Media.DisplayMessage("conyard dead")
    else
      actorsInRadius = Map.ActorsInCircle(conyard.CenterPosition, WDist.New(3036))
	  local owner = conyard.Owner
      for _, actor in pairs(actorsInRadius) do
        if actor.Type == "engineer" and not owner.IsAlliedWith(actor.Owner) then
          --Media.DisplayMessage(actor.Type)
		  conyard.Sell()
          --CurrentConyards[i] = nil
        end
      end
    end
  end
end

function findConyards()
  local newConyards = {}
 for i, bot in pairs(BotPlayers)
  do
    local conyards = bot.GetActorsByType("construction_yard")
    for _, conyard in pairs(conyards) do
      table.insert(newConyards, conyard)
    end
  end
  CurrentConyards = newConyards
end
-----------------------------
---AI scripts--engi/Saboteur/repairing
-----------------------------

function CheckForRepair(actor, maxHP, internalName)
	Trigger.AfterDelay(300, function()
		if not actor.IsDead then
			if maxHP * 0.4 > actor.Health then
				if RepairPadList[internalName] ~= nil then
					if not RepairPadList[internalName].IsDead then
						local token = actor.GrantCondition("reject_control", 3000) -- if unit stuck, expire after 3000 ticks
					--Media.Debug("send to repair_pad "..tostring(actor))
					actor.Stop()
					actor.Move(RepairPadList[internalName].Location + CVec.New(1,1), 2)
					actor.CallFunc(function ()
						if not actor.IsDead then
							actor.RevokeCondition(token)
							CheckForRepair(actor, maxHP, internalName)
						end
					end)
					end
				else
					CheckForRepair(actor, maxHP, internalName)
				end
			else
				CheckForRepair(actor, maxHP, internalName)
			end
		end
	end)
end

EnginnerLogic = function(enginner)
	if enginner.HasTag("close_target") == false then
		local closeActors = Map.ActorsInCircle(enginner.CenterPosition, WDist.FromCells(15))
		local targets = Utils.Where(closeActors, function(actor)
			return
				actor.HasProperty("Capture") and
				actor.Type ~= "wall" and
				actor.Type ~= "medium_gun_turret" and
				actor.Type ~= "large_gun_turret" and
				actor.Type ~= "engineer" and
				actor.Type ~= "silo" and not
				enginner.Owner.IsAlliedWith(actor.Owner)
		end)
		if targets[1] ~= nil then
			local token = enginner.GrantCondition("reject_control")
			enginner.Stop()
			local target = Utils.Random(targets)
			enginner.Capture(target)
			enginner.AddTag("close_target")
			--Media.Debug("redirection to close target"..tostring(enginner))
			enginner.CallFunc( function ()
				if enginner.IsDead == false then
					--Media.Debug("cancel, target destroyed"..tostring(enginner))
					enginner.RevokeCondition(token)
					enginner.RemoveTag("close_target")
				end
			end)
		end
	end
	Trigger.AfterDelay(500, function()
		if enginner.IsDead == false then
			EnginnerLogic(enginner)
		end
	end)
end

FindCloseTarget = function (saboteur, distance)
	local closeActors = Map.ActorsInCircle(saboteur.CenterPosition, WDist.FromCells(distance))
	return Utils.Where(closeActors, function(actor)
		return
			actor.HasProperty("Sell") and
			actor.Type ~= "wall" and
			actor.Type ~= "medium_gun_turret" and
			actor.Type ~= "large_gun_turret" and
			actor.Type ~= "silo" and not
			saboteur.Owner.IsAlliedWith(actor.Owner) and not
			actor.Owner.IsNonCombatant
	end)
end

FindAnyTarget = function (saboteur)
	local filteredPlayers = FilterPlayers(saboteur.Owner)
	if filteredPlayers[1] == nil then
		-- no suitable players for targeting
		return nil
	end
	local randomplayer = Utils.Random(filteredPlayers)
	if randomplayer ~= nil then
		local suitableActors = Utils.Where(randomplayer.GetActors(), function(actor)
			return
				actor.HasProperty("Sell") and
				actor.Type ~= "wall" and
				actor.Type ~= "medium_gun_turret" and
				actor.Type ~= "large_gun_turret" and
				actor.Type ~= "silo"
		end)
		if (next(suitableActors) ~= nil) then
			return suitableActors
		else
			-- case when random player is dead or have no buildings
			return nil
		end
	else
		-- case when no suitable players found
		return nil
	end
end

FindSaboteur = function(bot)
	local saboteurs = bot.GetActorsByType("saboteur")
	for i, saboteur in pairs(saboteurs) do
		if  saboteur.HasTag("close_target") == false and saboteur.HasTag("random_target") == false then
			local targets = FindCloseTarget(saboteur, 15)
			if (next(targets) ~= nil) then
				saboteur.AddTag("close_target")
				SendSaboteur(saboteur, targets)
			else
				targets = FindAnyTarget(saboteur)
				if targets ~= nil then
					saboteur.AddTag("random_target")
					SendSaboteur(saboteur, targets)
				end
			end
		elseif not saboteur.HasTag("close_target") and saboteur.HasTag("random_target") then
			local targets = FindCloseTarget(saboteur, 15)
			if (next(targets) ~= nil) then
				saboteur.AddTag("close_target")
				SendSaboteur(saboteur, targets)
			end
		end
	end
	Trigger.AfterDelay(400, function ()
		FindSaboteur(bot) end)
end

SendSaboteur = function(saboteur, targets)
	if targets == nil then
		--Media.Debug("no targets for", saboteur.Owner.Name)
		saboteur.RemoveTag("close_target")
		saboteur.RemoveTag("random_target")
		return
	end
	saboteur.Stop()
	local target = Utils.Random(targets)
	saboteur.Demolish(target)
-- 'target' was removed from the world in the meantime
	saboteur.CallFunc(function()
		saboteur.RemoveTag("close_target")
		saboteur.RemoveTag("random_target")
	end)
end

function FilterPlayers(forPlayer)
	local filteredPlayers = ActivePlayers
	for i, player in pairs(filteredPlayers) do
		if forPlayer.IsAlliedWith(player) or forPlayer.InternalName == player.InternalName then
			table.remove(filteredPlayers, i)
		end
	end
	return filteredPlayers
end

------------------------------------------------------------
--Experimental starport---Original D2k Starport behaviour---
------------------------------------------------------------

function ExperimentalStarport(player, dummy)
	local playerInternalName = player.InternalName
	local unit = dummy.Type
	local cutDummyFromString = unit:sub(7, #unit)
	--  Icons number Overlays
	table.insert(DummyActors[playerInternalName], dummy)
	if #DummyActors[playerInternalName] > FrigateCapacity + 1 then
		--Media.Debug("Index above Fridate capacity, unit rejected "..playerInternalName)
		return
	end
	dummy.GrantCondition("order_"..tostring(#DummyActors[playerInternalName]))
	-- remove not needed number in icon
	for i, dummyActor in pairs(DummyActors[playerInternalName]) do
		if dummyActor.Type == unit and i < #DummyActors[playerInternalName] then
			dummyActor.RevokeCondition(1)
		end
	end
	if not player.HasPrerequisites({"frigate.not_empty"}) then
		local token = player.GrantCondition("frigate_not_empty")
		table.insert(RevokeTokens[playerInternalName], token)
	end
	-- add unit to the Shopping list
	if StarportUnits[playerInternalName] == nil then
		table.insert(StarportUnits[playerInternalName], cutDummyFromString)
	elseif #StarportUnits[playerInternalName] < FrigateCapacity then
		table.insert(StarportUnits[playerInternalName], cutDummyFromString)
	elseif #StarportUnits[playerInternalName] == FrigateCapacity then
		table.insert(StarportUnits[playerInternalName], cutDummyFromString)
		local token = player.GrantCondition("frigate_full")
		table.insert(RevokeTokens[playerInternalName], token)
		--for i, name in pairs(StarportUnits[playerInternalName]) do
		--	Media.Debug(name.." shoping list")
		--end
	else
		--Media.Debug("Frigate full - unit rejected"..player.Name)
		local token = player.GrantCondition("frigate_full")
		table.insert(RevokeTokens[playerInternalName], token)
	end
end

function SelectStarport(player)
	local chosenStarport
	for i, starport in pairs(player.GetActorsByTypes({"starport","merged.starport","merged.starport_smuggler"})) do
		if not starport.IsDead then	
			if starport.IsPrimaryBuilding then
				return starport
			else
				chosenStarport = starport
			end
		end
	end
	return  chosenStarport
end

function CHOAMDelivery(player)
	DeliveryNotifications(player)
	Trigger.AfterDelay(FrigateDeliveryDelay, function ()
		--Media.Debug("starting delivery process")
		local starport = SelectStarport(player)
		if starport == nil then
			--Media.Debug("Error, cant find any starport. Starport reset"..player.Name)
			ResetStartport(player)
			return
		end
		local rallypoint = starport.RallyPoint
		local path = {Map.ClosestEdgeCell(starport.Location),starport.Location + CVec.New(1,1)}
		local airUnits = FilterAirUnits(player.InternalName)
		--wait for Choam to come
		local units = Reinforcements.ReinforceWithTransport(player,"frigate_choam",StarportUnits[player.InternalName], path,{path[2], path[1]})
		local frigate = units[1]
		Reinforcements.Reinforce(player, airUnits,path)
		-- when killed or deliver finish remove Frigade and reset Starport settings
		Trigger.OnRemovedFromWorld(starport, function()
			--Media.Debug("Starport removed redirecting order "..frigate.Type)
			local starport_new = SelectStarport(player)
			if starport_new == nil then
				if not frigate.IsDead then
					--Media.Debug("no more starports, canceling order"..player.Name)
					frigate.Stop()
					frigate.Move(path[1])
				end
			else
			--	Media.Debug("Starport removed redirecting order "..frigate.Type)
				if not frigate.IsDead then
					frigate.Stop()
					rallypoint = starport_new.RallyPoint
					frigate.Move(starport_new.Location + CVec.New(1,1))
					frigate.UnloadPassengers()
				else
					--Media.Debug("Cant redirect, frigate is dead"..player.Name)
				end
			end
		end)
		-- when killed or deliver finish. Remove Frigade and reset Starport settings
		Trigger.OnRemovedFromWorld(frigate, function()
			ResetStartport(player)
			if not starport.IsDead then
				Trigger.ClearAll(starport)
			end
		end)
			--in case frigate stuck
		Trigger.OnIdle(frigate, function()
			frigate.UnloadPassengers()
		end)
		Trigger.OnPassengerExited(frigate,
			function(carry, pass)
				Media.PlaySpeechNotification(carry.Owner,"Reinforce")
				if pass ~= nil then
					-- triggered when actor is in the world (dont use OnAddedToWorld triger!!!)
					Trigger.AfterDelay(10, function()
						if pass.HasProperty("AttackMove") then
							pass.AttackMove(rallypoint,1)
						elseif pass.HasProperty("FindResources") then
							pass.Move(rallypoint)
							pass.FindResources()
						elseif pass.HasProperty("Move") then
							pass.Move(rallypoint)
						end
					end)
				end
			end)
	end)
end

function ResetStartport(player)
	local playerInternalName = player.InternalName
	if RevokeTokens[playerInternalName][1] ~= nil then
		player.RevokeCondition(RevokeTokens[player.InternalName][1])
		RevokeTokens[playerInternalName][1] = nil
	end
	if RevokeTokens[playerInternalName][2] ~= nil then
		player.RevokeCondition(RevokeTokens[player.InternalName][2])
		RevokeTokens[playerInternalName][1] = nil
	end
	for i, dummy in pairs(DummyActors[playerInternalName]) do
		--edge case check. when player surrender while delivery is in progress
		if not dummy.IsDead then
			dummy.Destroy()
		end
	end
	DummyActors[playerInternalName] = {}
	RevokeTokens[playerInternalName] = {}
	StarportUnits[playerInternalName] = {}
	local purchaseActors = player.GetActorsByType("purchase.starport")
	if purchaseActors[1] ~= nil then
		purchaseActors[1].Destroy()
	end
end

function FilterAirUnits(playerInternalName)
	local airUnits = {}
	for i,unit in pairs(StarportUnits[playerInternalName]) do
		if unit == "carryall" then
			--Media.Debug("removing carryall")
			StarportUnits[playerInternalName][i] = nil
			table.insert(airUnits, "carryall")
		end
	end
	return airUnits
end

function DeliveryNotifications(player)
	Media.PlaySpeechNotification(player,"OrderPlaced")
	local time = 0
	local timeBetweenNotifications = FrigateDeliveryDelay / 5
	time = time + timeBetweenNotifications
	Trigger.AfterDelay(time -15, function()
		Media.PlaySpeechNotification(player,"TMinusFive")
	end)
	time = time + timeBetweenNotifications
	Trigger.AfterDelay(time, function()
		Media.PlaySpeechNotification(player,"TMinusFour")
	end)
	time = time + timeBetweenNotifications
	Trigger.AfterDelay(time, function()
		Media.PlaySpeechNotification(player,"TMinusThree")
	end)
	time = time + timeBetweenNotifications
	Trigger.AfterDelay(time, function()
		Media.PlaySpeechNotification(player,"TMinusTwo")
	end)
	time = time + timeBetweenNotifications
	Trigger.AfterDelay(time, function()
		Media.PlaySpeechNotification(player,"TMinusOne")
	end)

end

-- Reinforcements via Starport

function CHOAMDeliverCustomUnits(player, squad)
	local starport = SelectStarport(player)
	--Media.Debug("Starting custom units delivery "..player.InternalName)
	if starport == nil then
		--Media.Debug("Error, cant find any starport. Starport reset"..player.Name)
		ResetStartport(player)
		return
	end
	local rallypoint = starport.RallyPoint
	local path = {Map.ClosestEdgeCell(starport.Location),starport.Location + CVec.New(1,1)}
	local airUnits = FilterAirUnits(player.InternalName)
	--wait for Choam to come
	local units = Reinforcements.ReinforceWithTransport(player,"frigate_choam",squad, path,{path[2], path[1]})
	local frigate = units[1]
	Reinforcements.Reinforce(player, airUnits,path)
	-- when killed or deliver finish remove Frigade and reset Starport settings
	Trigger.OnRemovedFromWorld(starport, function()
		--Media.Debug("Starport removed redirecting order "..frigate.Type)
		local starport_new = SelectStarport(player)
		if starport_new == nil then
			if not frigate.IsDead then
				--Media.Debug("no more starports canceling order"..player.Name)
				frigate.Stop()
				frigate.Move(path[1])
			end
		else
		--	Media.Debug("Starport removed redirecting order "..frigate.Type)
			if not frigate.IsDead then
				frigate.Stop()
				frigate.Move(starport_new.Location + CVec.New(1,1))
				frigate.UnloadPassengers()
			end
		end
	end)
		--in case frigate stuck
	Trigger.OnIdle(frigate, function()
		frigate.UnloadPassengers()
	end)
	Trigger.OnPassengerExited(frigate,
		function(carry, pass)
				if pass ~= nil then
					Trigger.AfterDelay(10, function()
						if pass.HasProperty("Move") then
							pass.Move(rallypoint)
						end
					end)
				end
			end)
end
-------------------------------
-- Multi pass Airstrikes  - 
--warring use only as local function (global function can crash)
--------------------------------
CallAirstrike = function(dummy)
	local dummyPosition = dummy.Location
	local spawnEdgeCell = Map.ClosestEdgeCell(dummyPosition)
	local angle = CalculateBestAngle(spawnEdgeCell)
	local wposDummyLocation = Map.CenterOfCell(dummyPosition)
	Beacon.New(dummy.Owner,wposDummyLocation, 250)
	local wposAirCraftSpawnLocation = Map.CenterOfCell(spawnEdgeCell)
	local airUnits = GiveAirSquad(dummy.Type)
	local squadRefference = {}
	local dummyRefference = {}
	local pon = 1
	local arrayLenght = #SpamWposOffsets + 1
	-- calculate WPos offset for every aircraft
	while pon <= #airUnits do
		local newLocation
		if Useoffest == true then
			if angle == Angle.West or angle == Angle.East then
				newLocation =WPos.New( wposDummyLocation.X + SpamWposOffsets[arrayLenght - pon], wposDummyLocation.Y+SpamWposOffsets[pon], 0)
			else
				newLocation =WPos.New( wposDummyLocation.X + SpamWposOffsets[pon], wposDummyLocation.Y+SpamWposOffsets[pon], 0)
			end
		else
			newLocation = wposDummyLocation
		end
		dummyRefference[pon] = Actor.Create("dummy.generic",true, {Owner = dummy.Owner, CenterPosition = newLocation,Location })
		pon = pon + 1
	end
	--Media.Debug("calling Airstrike"..tostring(spawnPosition.X).."  ,   "..tostring(spawnPosition.Y))
	-- calculate squadron
	for i, actorName in pairs(airUnits) do
		local spamDelay = i * SquadSpamDelay
		Trigger.AfterDelay(spamDelay, function()
			local airUnit
			local finalWposPosition
			if angle == Angle.West or angle == Angle.East then
				finalWposPosition = wposAirCraftSpawnLocation + WVec.New(SpamWposOffsets[arrayLenght - i], SpamWposOffsets[i], Actor.CruiseAltitude(actorName))
			else
				finalWposPosition = wposAirCraftSpawnLocation + WVec.New(SpamWposOffsets[i], SpamWposOffsets[i], Actor.CruiseAltitude(actorName))
			end
			if Useoffest == true then
				airUnit = Actor.Create(actorName ,true, {Owner = dummy.Owner ,Facing = angle,  CenterPosition = finalWposPosition })
				airUnit.Attack(dummyRefference[i], true, true)
			else
				airUnit = Actor.Create(actorName ,true, {Owner = dummy.Owner, Location = spawnEdgeCell, Facing = angle})
				airUnit.Attack(dummyRefference[i], true, true)
			end
			table.insert(squadRefference, airUnit)
			LeaveOnEmpty(airUnit)
		end)
	end
	Trigger.AfterDelay(SquadSpamDelay + 1 * 5, function()
		Trigger.OnAllRemovedFromWorld(squadRefference, function ()
			-- edge case check. if player surrender while airstrike is in progress -> crash
			if not dummy.IsDead then
				dummy.Destroy()
				for i, dummy_generic in pairs(dummyRefference) do
					dummy_generic.Kill()
				end
			end
		end)
	end)
end

function LeaveOnEmpty(unit)
	if not unit.IsDead then
		if unit.AmmoCount("primary") < 1 then
			unit.Stop()
			local position = Map.ClosestEdgeCell(unit.Location)
			unit.Move(position)
			unit.Destroy()
		else
			Trigger.AfterDelay(30, function()
				LeaveOnEmpty(unit)
			end)
		end
	end
end

function CalculateBestAngle(position)
	if position.X <= 2 then
		return Angle.East
	elseif position.Y <= 2 then
		return Angle.South
	elseif position.X < position.Y then
		return Angle.North
	else
		return Angle.West
	end
end


function GiveAirSquad(faction)
	if faction == "waypoint.airtstrike_a" then
		--Media.DisplayMessage("atreides squad")
		return AirSquads[1]
	elseif faction == "waypoint.airtstrike_h"then
		return AirSquads[2]
	elseif faction == "waypoint.airtstrike_o"then
		return AirSquads[3]
	end
end
----------------------
---Air Reinforcements-
----------------------
function DropAirReinforcements(dummy)
	local squad
	if dummy.Type=="waypoint.reinforce_a" then squad=1
	elseif dummy.Type=="waypoint.reinforce_o" then squad=2
	elseif dummy.Type=="waypoint.reinforce_h" then squad=3 
	end
	--Carryall reinforcements
	local spawnCell = GetSpawnPoint(dummy)
	local path = {spawnCell,dummy.Location}
	local exitPath = {dummy.Location, Map.ClosestEdgeCell(dummy.Location) }
	--Media.Debug("reinforcements on the way"..dummy.Owner.InternalName)
	Beacon.New(dummy.Owner,Map.CenterOfCell(dummy.Location))
	local units = Reinforcements.ReinforceWithTransport(dummy.Owner,DropActor[squad] , ReinforcementSquads[squad], path, exitPath, nil, nil, 5)
	local carryall = units[1]
	Trigger.OnIdle(carryall, function()
		carryall.UnloadPassengers()

	end)
	Trigger.OnPassengerExited(carryall,
		function(carry, pass) 
			if not carry.HasPassengers 
			then 
				carry.Stop()
				carry.Move(path[1]) 
				carry.Destroy()
			end
		end
	)
end

function GetSpawnPoint(dummy)
	local buildings = dummy.Owner.GetActorsByType("high_tech_factory")
	for i, building in pairs(buildings) do
		if building.IsPrimaryBuilding then
			return Map.ClosestEdgeCell(building.Location)
		end
	end
	if (buildings[1].Location ~= nil) then
		return Map.ClosestEdgeCell(buildings[1].Location)
	else
		return dummy.Owner.HomeLocation
	end
end

-- adds new actors into the list (used only in tick function)

function ActorsAddedToWorld(newlist,register)
	local new_actor_list={}
	for key,act in pairs(newlist)
	do
		if not register[tostring(act)]
		then
			register[tostring(act)]=true
			table.insert(new_actor_list,act)
		end
	end
	return new_actor_list
end