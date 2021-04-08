-- This file contains all barebones-registered events and has already set up the passed-in parameters for your use.
-- Do not remove the GameMode:_Function calls in these events as it will mess with the internal barebones systems.

-- item relevant functions which are fired on events
require('items')
-- music.lua, relevant functions to control the music each will player will listen to/not listen to
require('music')
-- rescale.lua, relevant functions rescale the model sizes
require('rescale')
-- label.lua, relevant functions to modify the name/label of a player
require('label')

-- teamassignment.lua, relevant functions assign players to teams
require('teamassignment')
require('kyuubi')
require('denyHeroes')
require('scoreboard')

TEAM_1_VIEW = false
TEAM_2_VIEW = false
STOPMESSAGE = false
PLAYERCOUNT = 0
--cheats.lua, includes functions which listen to chat inputs of the players
  require('cheats')

-- Cleanup a player when they leave
function GameMode:OnDisconnect(keys)
  DebugPrint('[BAREBONES] Player Disconnected ' .. tostring(keys.userid))
  DebugPrintTable(keys)

  local name = keys.name
  local networkid = keys.networkid
  local reason = keys.reason
  local userid = keys.userid

end

-- A player has reconnected to the game.  This function can be used to repaint Player-based particles or change
-- state as necessary
function GameMode:OnPlayerReconnect(keys)
  DebugPrint( '[BAREBONES] OnPlayerReconnect' )
  DebugPrintTable(keys) 

end

-- The overall game state has changed
function GameMode:OnGameRulesStateChange(keys)
  DebugPrint("[BAREBONES] GameRules State Changed")
  DebugPrintTable(keys)
  -- This internal handling is used to set up main barebones functions
  GameMode:_OnGameRulesStateChange(keys)
  local newState = GameRules:State_Get()
  
  if newState == 4 then
    
     local shopkeeper = Entities:FindByModel(nil, "models/heroes/shopkeeper/shopkeeper.vmdl")
     shopkeeper:SetModelScale(2.4)
     local shopkeeper_dire = Entities:FindByModel(nil, "models/heroes/shopkeeper_dire/shopkeeper_dire.vmdl")
     shopkeeper_dire:SetModelScale(2.4)
  end


  if newState == 2 then
    if GetMapName() == "ranked" then
      GameMode:assignRanked()
    end
    if GetMapName() == "duel" then
      GameMode:assignDuel()
    end
  end

  if newState == 7 then
       GameMode:checkLeaver()
  end
 
 if newState == 6 then  
 
    makeHeroesDenyable()
    PLAYERCOUNT = PlayerResource:GetPlayerCount()
    if GetMapName() == "duel" then
      Timers:CreateTimer(0.03, function()
              CustomGameEventManager:Send_ServerToAllClients("update_duel_score", {text="PROGAMING", continue=2} )
       end
      )
    end
    Timers:CreateTimer(60, function()
              STOPMESSAGE = true
               return nil
       end
      )
     Timers:CreateTimer(function()
            if GetMapName() == "duel" then
              GameRules:SendCustomMessage("BEST OF 3<br>WIN CONDITIONS:<br>KILL ENEMY HERO / FARM 100 CS / DESTROY ENEMY TOWER<br>2ND ROUND HERO SWAP | 3RD ROUND SAME RANDOM HERO", 0, 0)
            else
              GameRules:SendCustomMessage("Visit our forum at: rebornforum.narutowarsunlimited.com", 0, 0)
            end
            if STOPMESSAGE then
               return nil
            else
               return 7.0 
            end
       end
      )
end


  --This function controls the music on each gamestate
  GameMode:PlayGameMusic(newState)

  if newState == 2 then
    if GetMapName() == "duel" then
       GameMode:ChangeDuelBuildings()
     else
       GameMode:ChangeBuildings()
    end
  end
  

end


-- An NPC has spawned somewhere in game.  This includes heroes
function GameMode:OnNPCSpawned(keys)
    local npc = EntIndexToHScript(keys.entindex)


    if npc:IsRealHero() then
      GameMode:RemoveWearables( npc )
      if npc:GetTeamNumber() == 2 and not TEAM_1_VIEW then
        if GetMapName() == "mid" then
          npc:AddItemByName("item_courier")
        end

        AddFOWViewer(npc:GetTeamNumber(),Vector(5528, 5000, 256), 10000000000, 0.1, false)
        AddFOWViewer(npc:GetTeamNumber(),Vector(1500, 1000, 256), 10000000000, 0.1, false)
        AddFOWViewer(npc:GetTeamNumber(),Vector(-2500, 6000, 256), 10000000000, 0.1, false)
        AddFOWViewer(npc:GetTeamNumber(),Vector(6200, -500, 256), 10000000000, 0.1, false)
        AddFOWViewer(npc:GetTeamNumber(),Vector(-2500, -2000, 240), 10000000000, 0.1, false)
        AddFOWViewer(npc:GetTeamNumber(),Vector(-5932, -5348, 240), 10000000000, 0.1, false)
        TEAM_1_VIEW= true
       -- if npc:GetUnitName() == "npc_dota_hero_lion" then
      --    npc:AddItem(CreateItem("item_chakra_armor_male", npc, npc))
       -- end
      end
      if npc:GetTeamNumber() == 3 and not TEAM_2_VIEW then
        if GetMapName() == "mid" then
          npc:AddItemByName("item_courier")
        end
        AddFOWViewer(npc:GetTeamNumber(),Vector(5528, 5000, 256), 10000000000, 0.1, false)
        AddFOWViewer(npc:GetTeamNumber(),Vector(1500, 1000, 256), 10000000000, 0.1, false)
        AddFOWViewer(npc:GetTeamNumber(),Vector(-2500, 6000, 256), 10000000000, 0.1, false)
        AddFOWViewer(npc:GetTeamNumber(),Vector(6200, -500, 256), 10000000000, 0.1, false)
        AddFOWViewer(npc:GetTeamNumber(),Vector(-2500, -2000, 240), 10000000000, 0.1, false)
        AddFOWViewer(npc:GetTeamNumber(),Vector(-5932, -5348, 240), 10000000000, 0.1, false)
       -- if npc:GetUnitName() == "npc_dota_hero_lion" then
      --    npc:AddItem(CreateItem("item_chakra_armor_male", npc, npc))
       -- end
       TEAM_2_VIEW = true
      end
    end
    GameMode:RescaleUnit(npc)
    recordDamageDone(npc)
end

-- An entity somewhere has been hurt.  This event fires very often with many units so don't do too many expensive
-- operations here
function GameMode:OnEntityHurt(keys)
  --DebugPrint("[BAREBONES] Entity Hurt")
  --DebugPrintTable(keys)

  local entCause = nil
  local damagebits = keys.damagebits -- This might always be 0 and therefore useless
  if keys.entindex_attacker ~= nil then
     entCause = EntIndexToHScript(keys.entindex_attacker)
  end
end

-- An item was picked up off the ground
function GameMode:OnItemPickedUp(keys)
  DebugPrint( '[BAREBONES] OnItemPickedUp' )
  DebugPrintTable(keys)
  local heroEntity = EntIndexToHScript(keys.HeroEntityIndex)
  local itemEntity = EntIndexToHScript(keys.ItemEntityIndex)
  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local itemname = keys.itemname
 

end



-- An item was purchased by a player
function GameMode:OnItemPurchased( keys )
  DebugPrint( '[BAREBONES] OnItemPurchased' )
  DebugPrintTable(keys)

  -- The playerID of the hero who is buying something
  local plyID = keys.PlayerID
  if not plyID then return end

  -- The name of the item purchased
  local itemName = keys.itemname 
  
  -- The cost of the item purchased
  local itemcost = keys.itemcost
  
  local player = PlayerResource:GetPlayer(keys.PlayerID)

  if itemName == "item_forehead_protector" then
    GameMode:ForeheadProtectorOnItemPickedUp(player, itemName)
  end 

  if itemName == "item_flying_courier" then
    Timers:CreateTimer( 0.25, function()
        local flying_courier = nil
		flying_courier = Entities:FindByModel(nil, "models/props_gameplay/donkey_wings.vmdl")
        if flying_courier == nil then		
			flying_courier = Entities:FindByModel(nil, "models/props_gameplay/donkey_dire_wings.vmdl")	
		end
		
		if flying_courier ~= nil then
			flying_courier:SetModelScale(1.2)
		end
        return nil
     end
     )
  end 
  if itemName == "courier_radiant_flying" then
    Timers:CreateTimer( 0.25, function()
        local flying_courier = nil
		flying_courier = Entities:FindByModel(nil, "models/props_gameplay/donkey_wings.vmdl")
        if flying_courier == nil then		
			flying_courier = Entities:FindByModel(nil, "models/props_gameplay/donkey_dire_wings.vmdl")	
		end
		
		if flying_courier ~= nil then
			flying_courier:SetModelScale(1.2)
		end
        return nil
     end
     )
  end 
 
end

-- An ability was used by a player
function GameMode:OnAbilityUsed(keys)
  DebugPrint('[BAREBONES] AbilityUsed')
  DebugPrintTable(keys)

  local player = EntIndexToHScript(keys.PlayerID)
  local abilityname = keys.abilityname

end




-- A non-player entity (necro-book, chen creep, etc) used an ability
function GameMode:OnNonPlayerUsedAbility(keys)
  DebugPrint('[BAREBONES] OnNonPlayerUsedAbility')
  DebugPrintTable(keys)
  local abilityname=  keys.abilityname

end

-- A player changed their name
function GameMode:OnPlayerChangedName(keys)
  DebugPrint('[BAREBONES] OnPlayerChangedName')
  DebugPrintTable(keys)

  local newName = keys.newname
  local oldName = keys.oldName
end

-- A player leveled up an ability
function GameMode:OnPlayerLearnedAbility( keys)
  DebugPrint('[BAREBONES] OnPlayerLearnedAbility')
  DebugPrintTable(keys)

  local player = EntIndexToHScript(keys.player)
  local abilityname = keys.abilityname
end

-- A channelled ability finished by either completing or being interrupted
function GameMode:OnAbilityChannelFinished(keys)
  DebugPrint('[BAREBONES] OnAbilityChannelFinished')
  DebugPrintTable(keys)

  local abilityname = keys.abilityname
  local interrupted = keys.interrupted == 1
end

-- A player leveled up
function GameMode:OnPlayerLevelUp(keys)
  DebugPrint('[BAREBONES] OnPlayerLevelUp')
  DebugPrintTable(keys)

  local player = EntIndexToHScript(keys.player)
  local level = keys.level
end

-- A player last hit a creep, a tower, or a hero
function GameMode:OnLastHit(keys)
  DebugPrint('[BAREBONES] OnLastHit')
  DebugPrintTable(keys)

  local isFirstBlood = keys.FirstBlood == 1
  local isHeroKill = keys.HeroKill == 1
  local isTowerKill = keys.TowerKill == 1
  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local killedEnt = EntIndexToHScript(keys.EntKilled)

  if GetMapName() == "duel" then
      GameMode:lastHitDuel(keys)
  end
  if killedEnt:IsCreep() or killedEnt:IsCreature() then
    local broadcast_lasthit_event =
    {
      killer_id = keys.PlayerID,
      team_id = player:GetAssignedHero():GetTeamNumber()
    }
    CustomGameEventManager:Send_ServerToAllClients( "lasthit_event", broadcast_lasthit_event )
  end

  

end

-- A tree was cut down by tango, quelling blade, etc
function GameMode:OnTreeCut(keys)
  DebugPrint('[BAREBONES] OnTreeCut')
  DebugPrintTable(keys)

  local treeX = keys.tree_x
  local treeY = keys.tree_y
end

-- A rune was activated by a player
function GameMode:OnRuneActivated (keys)
  DebugPrint('[BAREBONES] OnRuneActivated')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local rune = keys.rune

  --[[ Rune Can be one of the following types
  DOTA_RUNE_DOUBLEDAMAGE
  DOTA_RUNE_HASTE
  DOTA_RUNE_HAUNTED
  DOTA_RUNE_ILLUSION
  DOTA_RUNE_INVISIBILITY
  DOTA_RUNE_BOUNTY
  DOTA_RUNE_MYSTERY
  DOTA_RUNE_RAPIER
  DOTA_RUNE_REGENERATION
  DOTA_RUNE_SPOOKY
  DOTA_RUNE_TURBO
  ]]
end

-- A player took damage from a tower
function GameMode:OnPlayerTakeTowerDamage(keys)
  DebugPrint('[BAREBONES] OnPlayerTakeTowerDamage')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local damage = keys.damage
end

-- A player picked a hero
function GameMode:OnPlayerPickHero(keys)
  DebugPrint('[BAREBONES] OnPlayerPickHero')
  DebugPrintTable(keys)

  local player = EntIndexToHScript(keys.player)
  local hero = player:GetAssignedHero()
  hero.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
  local model = hero:FirstMoveChild()
  while model ~= nil do
    if model:GetClassname() == "dota_item_wearable" then
      model:AddEffects(EF_NODRAW) -- Set model hidden
      table.insert(hero.hiddenWearables, model)
    end
    model = model:NextMovePeer()
  end
  local heroClass = keys.hero
  local heroEntity = EntIndexToHScript(keys.heroindex)

  -- modifies the name/label of a player
  GameMode:setPlayerHealthLabel(player)

end

-- A player killed another player in a multi-team context
function GameMode:OnTeamKillCredit(keys)
  DebugPrint('[BAREBONES] OnTeamKillCredit')
  DebugPrintTable(keys)


  local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
  local victimPlayer = PlayerResource:GetPlayer(keys.victim_userid)
  local numKills = keys.herokills
  local killerTeamNumber = keys.teamnumber


  local broadcast_kill_event =
  {
    killer_id = keys.killer_userid,
    team_id = keys.teamnumber,
    team_kills = keys.herokills,
    victim_id = keys.victim_userid,
    victim_team_id = victimPlayer:GetAssignedHero():GetTeamNumber()
  }
  SetScoreBoardAssists()
  CustomGameEventManager:Send_ServerToAllClients( "kill_event", broadcast_kill_event )
end

-- An entity died
function GameMode:OnEntityKilled( keys )
  DebugPrint( '[BAREBONES] OnEntityKilled Called' )
  DebugPrintTable( keys )

  GameMode:_OnEntityKilled( keys )
  

  -- The Unit that was Killed
  local killedUnit = EntIndexToHScript( keys.entindex_killed )
  -- The Killing entity
  local killerEntity = nil
  if keys.entindex_attacker ~= nil then
    killerEntity = EntIndexToHScript( keys.entindex_attacker )
  end


  if GetMapName() == "dota" then
    if killedUnit:GetName() == "dota_badguys_fort" then
      GameMode:sendMatchData(2)
    end
    if killedUnit:GetName() == "dota_goodguys_fort" then
      GameMode:sendMatchData(3)
    end
  end
  


  local damagebits = keys.damagebits -- This might always be 0 and therefore useless
  --Items
  if killerEntity ~= nil then
    GameMode:SupportItemCooldownReset(killedUnit, killerEntity)
    GameMode:PlayKillSound(killerEntity, killedUnit)
  end

  if killedUnit:GetModelName() == "models/creeps/roshan/roshan.vmdl" and killedUnit:GetTeamNumber() ~= 2  and killedUnit:GetTeamNumber() ~= 3 and (GetMapName() == "dota" or GetMapName() == "ranked") then
    GameMode:kyuubiHelp(killerEntity:GetTeamNumber(), killerEntity)
  end

  if GetMapName() == "duel" then
      GameMode:duelKill(killedUnit)
  end

  if (killedUnit:GetTeamNumber() == killerEntity:GetTeamNumber()) and killedUnit:IsCreep() and killerEntity:IsRealHero() then
    local broadcast_deny_event =
    {
      killer_id = killerEntity:GetPlayerID(),
      team_id = killerEntity:GetTeamNumber()
    }
      CustomGameEventManager:Send_ServerToAllClients( "deny_event", broadcast_deny_event )
  end

  

end



-- This function is called 1 to 2 times as the player connects initially but before they 
-- have completely connected
function GameMode:PlayerConnect(keys)
  DebugPrint('[BAREBONES] PlayerConnect')
  DebugPrintTable(keys)
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function GameMode:OnConnectFull(keys)
  DebugPrint('[BAREBONES] OnConnectFull')
  DebugPrintTable(keys)

  GameMode:_OnConnectFull(keys)
  
  local entIndex = keys.index+1
  -- The Player entity of the joining user
  local ply = EntIndexToHScript(entIndex)
  
  -- The Player ID of the joining player
  local playerID = ply:GetPlayerID()
end

-- This function is called whenever illusions are created and tells you which was/is the original entity
function GameMode:OnIllusionsCreated(keys)
  DebugPrint('[BAREBONES] OnIllusionsCreated')
  DebugPrintTable(keys)

  local originalEntity = EntIndexToHScript(keys.original_entindex)
end

-- This function is called whenever an item is combined to create a new item
function GameMode:OnItemCombined(keys)
  DebugPrint('[BAREBONES] OnItemCombined')
  DebugPrintTable(keys)

  -- The playerID of the hero who is buying something
  local plyID = keys.PlayerID
  if not plyID then return end
  local player = PlayerResource:GetPlayer(plyID)

  -- The name of the item purchased
  local itemName = keys.itemname 
  
  -- The cost of the item purchased
  local itemcost = keys.itemcost

  if itemName == "item_chakra_armor" then
    GameMode:ChakraArmorOnItemPickedUp(player, itemName)
  end

end

-- This function is called whenever an ability begins its PhaseStart phase (but before it is actually cast)
function GameMode:OnAbilityCastBegins(keys)
  DebugPrint('[BAREBONES] OnAbilityCastBegins')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local abilityName = keys.abilityname
end

-- This function is called whenever a tower is killed
function GameMode:OnTowerKill(keys)
  DebugPrint('[BAREBONES] OnTowerKill')
  DebugPrintTable(keys)

  local gold = keys.gold
  local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
  local team = keys.teamnumber
end

-- This function is called whenever a player changes there custom team selection during Game Setup 
function GameMode:OnPlayerSelectedCustomTeam(keys)
  DebugPrint('[BAREBONES] OnPlayerSelectedCustomTeam')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.player_id)
  local success = (keys.success == 1)
  local team = keys.team_id
end

-- This function is called whenever an NPC reaches its goal position/target
function GameMode:OnNPCGoalReached(keys)
  DebugPrint('[BAREBONES] OnNPCGoalReached')
  DebugPrintTable(keys)

  local goalEntity = EntIndexToHScript(keys.goal_entindex)
  local nextGoalEntity = EntIndexToHScript(keys.next_goal_entindex)
  local npc = EntIndexToHScript(keys.npc_entindex)
end