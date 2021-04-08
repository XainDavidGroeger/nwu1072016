
PLAYER_ONE_WINS = 0
PLAYER_TWO_WINS = 0
PLAYER_ONE_CS = 0
PLAYER_TWO_CS = 0
CS_LIMIT = 100

function GameMode:duelLogic( keys )

  GameMode:Setup_Hero_Tables()
  
   if tableContains(GameRules.heroTable, PlayerResource:GetPlayer(0):GetAssignedHero():GetName()) then
    	local hero_index = getIndex(GameRules.heroTable, PlayerResource:GetPlayer(0):GetAssignedHero():GetName())
    	newHeroName = GameRules.nwrHeroTable[hero_index]
   end
  
  local text = "DUEL<br>" .. PlayerResource:GetPlayerName(0) .. "(" .. string.upper(tostring(newHeroName)) .. ") VS " .. PlayerResource:GetPlayerName(1) .. "(" .. string.upper(tostring(newHeroName)) .. ")"
  Notifications:TopToAll({text=text, duration=8.0, style={color="#B2B2B2",  fontSize="50px;"}})
  Notifications:TopToAll({text="ROUND 1", duration=8.0, style={color="#B2B2B2",  fontSize="50px;"}})

  local repeatInterval = 30    -- Return this timer every few seconds in game-time 
  local startAfter     = 0.05  -- Start this timer after few seconds 
  local count          = 0     -- Count how much spawn cycles were ran 
  DebugPrint("[BAREBONES] The game has officially begun")
  Timers:CreateTimer(startAfter, 
    function()
      SpawnCreeps(count)
      count = count + 1
      return repeatInterval 
    end)
end

-- Spawn creeps for a determined lane
function SpawnCreepsLane(units, unitsCount, path, team, spawnerName)
	local spawner = Entities:FindByName(nil, spawnerName)
	if IsValidEntity(spawner) then -- Only spawn units from which spawner is alive
		for unitKey, unitValue in pairs(units) do 
            --print("Spawning " .. tostring(unitsCount[unitKey]) .. " " .. unitValue .. " at " .. spawnerName .. "...")
			for i = 1, unitsCount[unitKey] do 
				Timers:CreateTimer(function()
					local unit = CreateUnitByName(unitValue, spawner:GetAbsOrigin() + RandomVector(RandomInt(100, 200)), true, nil, nil, team)
					for j = 2, #path do 
						ExecuteOrderFromTable({
							UnitIndex = unit:GetEntityIndex(),
							OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
							Position = path[j],
							Queue = true
						})
					end
				end)
			end
		end
	end
end

-- Spawn creeps for the whole map
function SpawnCreeps(count)
    -- Getting info points 
    local konohaLeftLane     = Entities:FindByName(nil, "konohaLeftLane"):GetAbsOrigin()
    local konohaMidLane        = Entities:FindByName(nil, "konohaMidLane"):GetAbsOrigin()
	local akatMidLane        = Entities:FindByName(nil, "akatMidLane"):GetAbsOrigin()
    -- Define the units for each team 
    local konohaUnits = { chunnin = "npc_dota_creep_goodguys_melee", 
        jounin = "npc_dota_creep_goodguys_ranged" }
    local akatUnits = { chunnin = "npc_dota_creep_badguys_melee",
        jounin = "npc_dota_creep_badguys_ranged" }
    -- How much units will be spawned?
    local spawnCountSide = { chunnin = 3,
        jounin = 1}
    local spawnCountMid = { chunnin = 3,
        jounin = 1}
    -- Define the path for which the units will walk 
    local konohaLanePath    = {konohaLeftLane, konohaMidLane, akatMidLane}
    local akatLanePath       = {akatMidLane, konohaMidLane, konohaLeftLane}

    -- Spawn creeps 
    SpawnCreepsLane(konohaUnits, spawnCountSide, konohaLanePath, DOTA_TEAM_GOODGUYS, "spawn_konoha_lane")
    SpawnCreepsLane(akatUnits, spawnCountSide, akatLanePath, DOTA_TEAM_BADGUYS, "spawn_akat_lane")
end


function GameMode:lastHitDuel( keys )
	local isFirstBlood = keys.FirstBlood == 1
  	local isHeroKill = keys.HeroKill == 1
  	local isTowerKill = keys.TowerKill == 1

  	local player = PlayerResource:GetPlayer(keys.PlayerID)
  	local killedEnt = EntIndexToHScript(keys.EntKilled)
  	if player ~= nil then
  		if player:GetAssignedHero():IsRealHero() then
	  		if isHeroKill then
	  		else
	  			if player:GetPlayerID() == 0 then
	  				PLAYER_ONE_CS = PLAYER_ONE_CS + 1
	  				if PLAYER_ONE_CS >= CS_LIMIT then
	  					local text = PlayerResource:GetPlayerName(0) .. " HAS WON THIS ROUND CAUSE HE REACHED 100 CS!"
	  					Notifications:TopToAll({text=text, duration=5.0, style={color="#B2B2B2",  fontSize="50px;"}})
	  					GameMode:roundEnds(player)
	  				end
	  			else
	  				PLAYER_TWO_CS = PLAYER_TWO_CS + 1
	  				if PLAYER_TWO_CS >= CS_LIMIT then
	  					local text = PlayerResource:GetPlayerName(1) .. " HAS WON THIS ROUND CAUSE HE REACHED 100 CS!"
	  					Notifications:TopToAll({text=text, duration=5.0, style={color="#B2B2B2",  fontSize="50px;"}})
	  					GameMode:roundEnds(player)
	  				end
	  			end		
	  		end
  		end
  	end 
  	CustomGameEventManager:Send_ServerToAllClients("update_duel_score", {scoreOne=PLAYER_ONE_WINS, scoreTwo=PLAYER_TWO_WINS, csOne = PLAYER_ONE_CS, csTwo = PLAYER_TWO_CS, continue=1} ) 	
end

function GameMode:duelKill( killedUnit )


	if killedUnit:GetName() == "dota_badguys_tower1_bot" then
		GameMode:roundEnds(PlayerResource:GetPlayer(0))
		local text = PlayerResource:GetPlayerName(0) .. " HAS WON THIS ROUND CAUSE HE DESTROYED THE ENEMY TOWER!"
	  	Notifications:TopToAll({text=text, duration=8.0, style={color="#B2B2B2",  fontSize="50px;"}})
	  	CreateUnitByName("dota_badguys_tower1_bot",killedUnit:GetAbsOrigin(),true,nil,nil,3)
	end

	if killedUnit:GetName() == "dota_goodguys_tower1_bot" then
		GameMode:roundEnds(PlayerResource:GetPlayer(1))
		local text = PlayerResource:GetPlayerName(1) .. " HAS WON THIS ROUND CAUSE HE DESTROYED THE ENEMY TOWER!"
	  	Notifications:TopToAll({text=text, duration=8.0, style={color="#B2B2B2",  fontSize="50px;"}})
	  	CreateUnitByName("dota_goodguys_tower1_bot",killedUnit:GetAbsOrigin(),true,nil,nil,2)
	end

    if killedUnit:IsRealHero() then

    	if killedUnit:GetTeamNumber() == 2 then
    		GameMode:roundEnds(PlayerResource:GetPlayer(1))
    	else
    		GameMode:roundEnds(PlayerResource:GetPlayer(0))
    	end
    end
end


function GameMode:roundEnds( player )

	if player:GetPlayerID() == 0 then
		PLAYER_ONE_WINS = PLAYER_ONE_WINS + 1
	else 
		PLAYER_TWO_WINS = PLAYER_TWO_WINS + 1
	end

	if PLAYER_ONE_WINS == 2 or PLAYER_TWO_WINS == 2 then
		if tableContains(GameRules.heroTable, PlayerResource:GetPlayer(player:GetPlayerID()):GetAssignedHero():GetName()) then
		    local hero_index = getIndex(GameRules.heroTable, PlayerResource:GetPlayer(player:GetPlayerID()):GetAssignedHero():GetName())
		    newHeroName = GameRules.nwrHeroTable[hero_index]
   		end
   		local text = PlayerResource:GetPlayerName(player:GetPlayerID()) .. " WON THE DUEL!"
		Notifications:TopToAll({text=text, duration=5.0, style={color="#B2B2B2",  fontSize="50px;"}})
		GameRules:SetGameWinner(player:GetTeamNumber())
	else
		if PLAYER_ONE_WINS == 1 and PLAYER_TWO_WINS == 1 then
			local text = PlayerResource:GetPlayerName(player:GetPlayerID()) .. "(" .. newHeroName .. ") won this round."
	  		Notifications:TopToAll({text=text, duration=8.0, style={color="#B2B2B2",  fontSize="50px;"}})
	  		Notifications:TopToAll({text="BOTH PLAYERS WILL GET THE SAME RANDOM HERO FOR ROUND 3", duration=5.0, style={color="#B2B2B2",  fontSize="50px;"}})
			local random = math.random(1, 19)
			local newHero = GameRules.heroTable[random]
			PlayerResource:ReplaceHeroWith(0, newHero, 625, 0)
			PlayerResource:ReplaceHeroWith(1, newHero, 625, 0)
			FindClearSpaceForUnit(PlayerResource:GetPlayer(0):GetAssignedHero(), Entities:FindByName(nil, "spawn_konoha_lane"):GetAbsOrigin(), true)
			FindClearSpaceForUnit(PlayerResource:GetPlayer(1):GetAssignedHero(), Entities:FindByName(nil, "spawn_akat_lane"):GetAbsOrigin(), true)
		else
			if tableContains(GameRules.heroTable, PlayerResource:GetPlayer(player:GetPlayerID()):GetAssignedHero():GetName()) then
		    	local hero_index = getIndex(GameRules.heroTable, PlayerResource:GetPlayer(player:GetPlayerID()):GetAssignedHero():GetName())
		    	newHeroName = GameRules.nwrHeroTable[hero_index]
   			end
			local text = PlayerResource:GetPlayerName(player:GetPlayerID()) .. "(" .. newHeroName .. ") won this round."
			Notifications:TopToAll({text=text, duration=8.0, style={color="#B2B2B2",  fontSize="50px;"}})
			Notifications:TopToAll({text="HEROES WILL BE SWAPPED FOR ROUND 2", duration=5.0, style={color="#B2B2B2",  fontSize="50px;"}})
			local hero_one = PlayerResource:GetPlayer(0):GetAssignedHero()
			local hero_two = PlayerResource:GetPlayer(1):GetAssignedHero()

			PlayerResource:ReplaceHeroWith(0, hero_two:GetName(), 625, 0)
			PlayerResource:ReplaceHeroWith(1, hero_one:GetName(), 625, 0)
			hero_two:RemoveSelf()
			hero_one:RemoveSelf()
			FindClearSpaceForUnit(PlayerResource:GetPlayer(0):GetAssignedHero(), Entities:FindByName(nil, "spawn_konoha_lane"):GetAbsOrigin(), true)
			FindClearSpaceForUnit(PlayerResource:GetPlayer(1):GetAssignedHero(), Entities:FindByName(nil, "spawn_akat_lane"):GetAbsOrigin(), true)
		end
	end
	PLAYER_ONE_CS = 0
	PLAYER_TWO_CS = 0
	CustomGameEventManager:Send_ServerToAllClients("update_duel_score", {scoreOne=PLAYER_ONE_WINS, scoreTwo=PLAYER_TWO_WINS, csOne = PLAYER_ONE_CS, csTwo = PLAYER_TWO_CS, continue=1} )
end


function GameMode:duelHeroSelection( keys )
	local player = EntIndexToHScript(keys.player)
  	local hero = player:GetAssignedHero()
  	local model = hero:FirstMoveChild()
  	if player:GetPlayerID() == 0 then
  		PlayerResource:ReplaceHeroWith(1, hero:GetName(), 625, 0)
  	else
  		PlayerResource:ReplaceHeroWith(0, hero:GetName(), 625, 0)
  	end
  	
end