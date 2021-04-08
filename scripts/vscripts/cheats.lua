WTF_MODE = false

CHEAT_CODES = {
    ["wtfmode"] = function() GameMode:Wtf() end,              -- "Toggles Wtf-mode: Gives all playes no cd on their abilities and 1k manareg"    
    ["rescale"] = function(arg, arg2) GameMode:Rescale(arg, arg2) end,              -- rescale's model size
    ["gold"] = function(arg) GameMode:Gold(arg) end,              -- "Gives the player x gold"    
    ["repick"] = function(arg) GameMode:Repick(arg) end,              -- "Changes the Hero of the player"    
    ["lvlup"] = function(arg) GameMode:LvlUp(arg) end,                -- "The player lvlups x levels"        
    ["riseandshine"] = function() GameMode:RiseAndShine() end,        -- "Set time of day to dawn" 
    ["lightsout"] = function() GameMode:LightsOut() end,              -- "Set time of day to dusk"   
    ["api"] = function() GameMode:ApiTest() end,              -- "Set time of day to dusk"          
}



-- A player has typed something into the chat
function GameMode:OnPlayerChat(keys)

    local userID = keys.userid
    local playerID = self.vUserIds[userID]:GetPlayerID()
    local text = keys.text
    local bTeamOnly = keys.teamonly
    if CHEATS_ACTIVATED then
        GameMode:Setup_Hero_Tables()
        -- Handle '-command'
        if StringStartsWith(text, "-") then
            text = string.sub(text, 2, string.len(text))
        end
        local input = split(text)
        local command = input[1]
        if CHEAT_CODES[command] then
            if input[3] then
                CHEAT_CODES[command](input[2], input[3])
            else 
                CHEAT_CODES[command](input[2])
            end
        end
    end

    if GetMapName() == "dota" and (text == "ff" or text == "surrender") and GameRules:State_Get() == 7 then
        GameMode:surrender(playerID)
    end

    --initiates chat tables
    if not GameRules.chatInput then
        GameRules.chatInput = {}
        for i=0, 12 do
          if PlayerResource:IsValidPlayer(i) then
            local player_chat = {}
            player_chat.id = i
            table.insert(GameRules.chatInput, player_chat)
          end
        end
    end 

    --store chat input of players
    for key,chat_entry in pairs(GameRules.chatInput) do
        if chat_entry.id == playerID then
            local message_table = {}
            message_table.message = text
            message_table.time = GameRules:GetGameTime()
            message_table.systemTime = GetSystemTime()
            message_table.systemDate = GetSystemDate()
            table.insert(chat_entry, message_table)
        end
    end

    -- how to access chat messages
    --for key,chat_entry in pairs(GameRules.chatInput) do
    --    print(chat_entry.id)
    --    for index,message in pairs(chat_entry) do
    --        if message ~= chat_entry.id  then
    --            print(chat_entry.id .. " " .. message.message)
    --            print(message.time)
    --            print(message.systemTime)
    --            print(message.systemDate)
    --        end
    --    end
    --end
end
--[[Author: LearningDave
  Date: october, 30th 2015.
  Gives the Hero of the Player who typed 'lvlup x' x level ups
]]
function GameMode:LvlUp(value)
    local cmdPlayer = Convars:GetCommandClient()
    local pID = cmdPlayer:GetPlayerID()
    if not value then value = 1 end
    
    local hero = PlayerResource:GetPlayer(pID):GetAssignedHero()

    for i=1, value do 
        hero:HeroLevelUp(true)
    end
    GameRules:SendCustomMessage("Cheat enabled!", 0, 0)
end
--[[Author: LearningDave
  Date: october, 30th 2015.
  Gives the Hero of the Player who typed 'lvlup x' x level ups
]]
function GameMode:RiseAndShine()
    GameRules:SetTimeOfDay( 0.3 )
end
--[[Author: https://github.com/MNoya/DotaCraft/blob/01a29892b124f695cadd0a134afb8d056c83015a/game/dota_addons/dotacraft/scripts/vscripts/developer.lua
    Brings the light out!->Daytime
]]
function GameMode:LightsOut()
    GameRules:SetTimeOfDay( 0.8 )
end
--[[Author: LearningDave
    All players get 1000 manareg and have no cds
]]
function GameMode:Wtf()
    if WTF_MODE then
        WTF_MODE = false
    else
        WTF_MODE = true
    end
    local cmdPlayer = Convars:GetCommandClient()
    local PlayerCount = PlayerResource:GetPlayerCount() - 1
    if  WTF_MODE then
        Timers:CreateTimer( function()
            for i=0, PlayerCount do
                if PlayerResource:IsValidPlayer(i) then
                    local player = PlayerResource:GetPlayer(i)
                    
                    local hero = player:GetAssignedHero()
                 
					hero:SetBaseManaRegen(1000)
                    for i=0, hero:GetAbilityCount()-1 do 
                        if  hero:GetAbilityByIndex(i) ~= nil then
                            hero:GetAbilityByIndex(i):EndCooldown()
                        end
                    end
                    for i=0, 6 do 
                        if  hero:GetItemInSlot(i) ~= nil then
                            hero:GetItemInSlot(i):EndCooldown()
                        end
                    end
                end
            end
            if WTF_MODE then
                return 0.003
            else
                return nil
            end        
        end
        )   
    end
    if WTF_MODE then
        GameRules:SendCustomMessage("Cheat enabled!", 0, 0)
    else
        GameRules:SendCustomMessage("Cheat disabled!", 0, 0)
    end
end
--[[Author: LearningDave
  Date: october, 30th 2015.
  Gives the Player x Gold (500 if no value given)
]]
function GameMode:Gold(value)
    local cmdPlayer = Convars:GetCommandClient()
    local pID = cmdPlayer:GetPlayerID()
    if not value then value = 500 end
    PlayerResource:ModifyGold(pID, tonumber(value), true, 0)

    GameRules:SendCustomMessage("Cheat enabled!", 0, 0)
end
--[[Author: LearningDave
  Date: november, 9th 2015.
  Gives the player a new hero
]]
function GameMode:Repick(value)
    local cmdPlayer = Convars:GetCommandClient()
    local pID = cmdPlayer:GetPlayerID()
    if  value then   
        if tableContains(GameRules.nwrHeroTable, value) then
            local hero_index = getIndex(GameRules.nwrHeroTable, value)
            newHeroName = GameRules.heroTable[hero_index]
            PlayerResource:ReplaceHeroWith(pID, newHeroName, 0, 0)
        end
    end
end
--[[Author: LearningDave
  Date: February, 10th 
 Rescales the model size of a given hero name and scale value
]]
function GameMode:Rescale(value, scale)
    local cmdPlayer = Convars:GetCommandClient()
    local pID = cmdPlayer:GetPlayerID()
    if  value then   
        if tableContains(GameRules.nwrHeroTable, value) then
            local hero_index = getIndex(GameRules.nwrHeroTable, value)
            newHeroName = GameRules.heroTable[hero_index]
            local hero = Entities:FindByName(nil, newHeroName)
            hero:SetModelScale(tonumber(scale))
        end
    end
end

function GameMode:ApiTest()
    GameRules:SetGameWinner(2)
    --GameMode:sendPlayerAbandonedGame(PlayerResource:GetPlayer(0))
end

