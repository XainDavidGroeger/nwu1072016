-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode


-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
-- You can also change the cvar 'barebones_spew' at any time to 1 or 0 for output/no output
BAREBONES_DEBUG_SPEW = false
--Set this to false to deactive cheat inputs(cheats.lua) and true to activate cheat inputs 
CHEATS_ACTIVATED = false

PLAYERINFO_DUMP_1 = nil
PLAYERINFO_DUMP_2 = nil
PLAYERINFO_DUMP_3 = nil
PLAYERINFO_DUMP_4 = nil

if GameMode == nil then
    DebugPrint( '[BAREBONES] creating barebones game mode' )
    _G.GameMode = class({})
end
--TODO find a way to get position of the shops by name/entityname
--base shop position team 1 
SHOP_TEAM_1 = Vector(-832, 768, 128) 
--base shop position team 2
SHOP_TEAM_2 = Vector(-832, 768, 128)


-- This library allow for easily delayed/timed actions
require('libraries/timers')
-- This library can be used for advancted physics/motion/collision of units.  See PhysicsReadme.txt for more information.
require('libraries/physics')
-- This library can be used for advanced 3D projectile systems.
require('libraries/projectiles')
require('utilities')
-- These internal libraries set up barebones's events and processes.  Feel free to inspect them/change them if you need to.
require('internal/gamemode')
require('internal/events')
require('notifications')
-- settings.lua is where you can specify many different properties for your game mode and is one of the core barebones files.
require('settings')
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core barebones files.
require('events')
--duel.lua handles duel map logic
require('duel')


--[[
  This function should be used to set up Async precache calls at the beginning of the gameplay.

  In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
  after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
  be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
  precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
  defined on the unit.

  This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
  time, you can call the functions individually (for example if you want to precache units in a new wave of
  holdout).

  This function should generally only be used if the Precache() function in addon_game_mode.lua is not working.
]]
function GameMode:PostLoadPrecache()
 

        --[[PrecacheResource("soundfile", "soundevents/oddball_sounds.vsndevts", context)
PrecacheItemByNameSync("item_oddball", context)--]]
end

--[[
  This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
  It can be used to initialize state that isn't initializeable in InitGameMode() but needs to be done before everyone loads in.
]]
function GameMode:OnFirstPlayerLoaded()
  DebugPrint("[BAREBONES] First Player has loaded")
end

--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function GameMode:OnAllPlayersLoaded()
  DebugPrint("[BAREBONES] All Players have loaded into the game")
end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
]]
function GameMode:OnHeroInGame(hero)
  DebugPrint("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())
    GameMode:Setup_Hero_Tables()

    GameMode:RemoveWearables( hero )

  --[[ --These lines if uncommented will replace the W ability of any hero that loads into the game
    --with the "example_ability" ability

  local abil = hero:GetAbilityByIndex(1)
  hero:RemoveAbility(abil:GetAbilityName())
  hero:AddAbility("example_ability")]]
end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function GameMode:OnGameInProgress()
  DebugPrint("[BAREBONES] The game has officially begun")
  if GetMapName() == "duel" then
       GameMode:duelLogic()
  end
end

-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:InitGameMode()
  GameMode = self
  DebugPrint('[BAREBONES] Starting to load Barebones gamemode...')
  SendToServerConsole("dota_combine_models 0")
  -- Call the internal function to set up the rules/behaviors specified in constants.lua
  -- This also sets up event hooks for all event handlers in events.lua
  -- Check out internals/gamemode to see/modify the exact code
  GameMode:_InitGameMode()
  CustomGameEventManager:RegisterListener("set_team", Dynamic_Wrap(GameMode, "onSetTeam"))
  CustomGameEventManager:RegisterListener("set_game_option", Dynamic_Wrap(GameMode, "onSetGameOption"))


  -- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
  Convars:RegisterCommand( "command_example", Dynamic_Wrap(GameMode, 'ExampleConsoleCommand'), "A console command example", FCVAR_CHEAT )
  ListenToGameEvent('player_chat', Dynamic_Wrap(GameMode, 'OnPlayerChat'), self)
  

  --mapping debuff modifiers from abiltiies
  GameRules.debuffModifiers = {}
  for _,ability in pairs(GameRules.abilityKV) do
    if ability['Modifiers'] ~= nil then
      for key,modifier in pairs(ability['Modifiers']) do
        if modifier['IsDebuff'] ~= nil then
          if modifier['IsDebuff'] == 1 then
            table.insert(GameRules.debuffModifiers, key)
          end
        end  
      end
    end
  end
 --mapping debuff modifiers from items
  for _,ability in pairs(GameRules.itemKV) do
    if ability['Modifiers'] ~= nil then
      for key,modifier in pairs(ability['Modifiers']) do
        if modifier['IsDebuff'] ~= nil then
          if modifier['IsDebuff'] == 1 then
            table.insert(GameRules.debuffModifiers, key)
          end
        end  
      end
    end
  end

  DebugPrint('[BAREBONES] Done loading Barebones gamemode!\n\n')
end

function GameMode:onSetGameOption(args)
    --print("onSetGameOption called")
  --DeepPrintTable(args)

end



-- This is an example console command
function GameMode:ExampleConsoleCommand()
  print( '******* Example Console Command ***************' )
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      -- Do something here for the player who called this command
      PlayerResource:ReplaceHeroWith(playerID, "npc_dota_hero_viper", 1000, 1000)
    end
  end

  print( '*********************************************' )
end


function GameMode:RemoveWearables( hero )

    local children = hero:GetChildren()
    for k,child in pairs(children) do
       if child:GetClassname() == "dota_item_wearable" then
           child:RemoveSelf()
       end
    end
end





--[[Author: LearningDave
  Date: november, 9th 2015.
  If not done yet, sets up hero tables to match naruto name to dota hero name
]]
function GameMode:Setup_Hero_Tables()
    -- setup race reference table
    if GameRules.heroTable == nil then
        GameRules.heroTable = {}
        GameRules.heroTable[1] = "npc_dota_hero_lion"
        GameRules.heroTable[2] = "npc_dota_hero_centaur"
        GameRules.heroTable[3] = "npc_dota_hero_doom_bringer"
        GameRules.heroTable[4] = "npc_dota_hero_antimage"
        GameRules.heroTable[5] = "npc_dota_hero_beastmaster"
        GameRules.heroTable[6] = "npc_dota_hero_kunkka"
        GameRules.heroTable[7] = "npc_dota_hero_ogre_magi"
        GameRules.heroTable[8] = "npc_dota_hero_dragon_knight"
        GameRules.heroTable[9] = "npc_dota_hero_sven"
        GameRules.heroTable[10] = "npc_dota_hero_sand_king"
        GameRules.heroTable[11] = "npc_dota_hero_phantom_assassin"
        GameRules.heroTable[12] = "npc_dota_hero_storm_spirit"
        GameRules.heroTable[13] = "npc_dota_hero_juggernaut"
        GameRules.heroTable[14] = "npc_dota_hero_bloodseeker"
        GameRules.heroTable[15] = "npc_dota_hero_axe"
        GameRules.heroTable[16] = "npc_dota_hero_shadow_shaman"
        GameRules.heroTable[17] = "npc_dota_hero_medusa"
        GameRules.heroTable[18] = "npc_dota_hero_enchantress"
        GameRules.heroTable[19] = "npc_dota_hero_juggernaut"
        GameRules.heroTable[20] = "npc_dota_hero_legion_commander"
        GameRules.heroTable[21] = "npc_dota_hero_warlock"
        GameRules.heroTable[22] = "npc_dota_hero_drow_ranger"
        GameRules.heroTable[23] = "npc_dota_hero_ursa"
    end
    if GameRules.heroTableShort == nil then
        GameRules.heroTableShort = {}
        GameRules.heroTableShort[1] = "lion"
        GameRules.heroTableShort[2] = "centaur"
        GameRules.heroTableShort[3] = "doom_bringer"
        GameRules.heroTableShort[4] = "antimage"
        GameRules.heroTableShort[5] = "beastmaster"
        GameRules.heroTableShort[6] = "kunkka"
        GameRules.heroTableShort[7] = "ogre_magi"
        GameRules.heroTableShort[8] = "dragon_knight"
        GameRules.heroTableShort[9] = "sven"
        GameRules.heroTableShort[10] = "sand_king"
        GameRules.heroTableShort[11] = "phantom_assassin"
        GameRules.heroTableShort[12] = "storm_spirit"
        GameRules.heroTableShort[13] = "juggernaut"
        GameRules.heroTableShort[14] = "bloodseeker"
        GameRules.heroTableShort[15] = "axe"
        GameRules.heroTableShort[16] = "shadow_shaman"
        GameRules.heroTableShort[17] = "medusa"
        GameRules.heroTableShort[18] = "enchantress"
        GameRules.heroTableShort[19] = "juggernaut"
        GameRules.heroTableShort[20] = "legion_commander"
        GameRules.heroTableShort[21] = "warlock"
        GameRules.heroTableShort[22] = "drow_ranger"
        GameRules.heroTableShort[23] = "ursa"
    end
    if GameRules.nwrHeroTable == nil then
        GameRules.nwrHeroTable = {}
        GameRules.nwrHeroTable[1] = "gaara"
        GameRules.nwrHeroTable[2] = "guy"
        GameRules.nwrHeroTable[3] = "hidan"
        GameRules.nwrHeroTable[4] = "itachi"
        GameRules.nwrHeroTable[5] = "kakashi"
        GameRules.nwrHeroTable[6] = "kisame"
        GameRules.nwrHeroTable[7] = "madara"
        GameRules.nwrHeroTable[8] = "naruto"
        GameRules.nwrHeroTable[9] = "onoki"
        GameRules.nwrHeroTable[10] = "raikage"
        GameRules.nwrHeroTable[11] = "sakura"
        GameRules.nwrHeroTable[12] = "sasuke"
        GameRules.nwrHeroTable[13] = "yondaime"
        GameRules.nwrHeroTable[14] = "zabuza"
        GameRules.nwrHeroTable[15] = "neji"
        GameRules.nwrHeroTable[16] = "shikamaru"
        GameRules.nwrHeroTable[17] = "anko"
        GameRules.nwrHeroTable[18] = "temari"
        GameRules.nwrHeroTable[19] = "minato"
        GameRules.nwrHeroTable[20] = "tsunade"
        GameRules.nwrHeroTable[21] = "kankuro"
        GameRules.nwrHeroTable[22] = "haku"
        GameRules.nwrHeroTable[23] = "kimimaro"
    end
end


function GameMode:GetNarutoHeroName( dota_short_name )

  GameMode:Setup_Hero_Tables()
  local key = TableFindKey(GameRules.heroTableShort, dota_short_name)
  if key == nil then
    return dota_short_name
  else
    return GameRules.nwrHeroTable[key]
  end
end

function GameMode:GetNarutoHeroId( dota_short_name )

  GameMode:Setup_Hero_Tables()
  local key = TableFindKey(GameRules.heroTableShort, dota_short_name)
  if key == nil then
    return dota_short_name
  else
    return key
  end
end

function GameMode:GetItemSlotNWR(hero, slot)

    local item = hero:GetItemInSlot(slot)
    local itemName = "empty"
    if item then
            itemName = string.gsub(item:GetAbilityName(), "item_", "")
    end

    return itemName
end