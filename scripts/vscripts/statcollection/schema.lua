customSchema = class({})

function customSchema:init()

    -- Check the schema_examples folder for different implementations

    -- Flag Example
    statCollection:setFlags({ version = "1.0.6b Beta" })

    -- Listen for changes in the current state
    ListenToGameEvent('game_rules_state_change', function(keys)
        local state = GameRules:State_Get()
        -- Send custom stats when the game ends
        if state == DOTA_GAMERULES_STATE_POST_GAME then

            -- Build game array
            local game = BuildGameArray()

            -- Build players array
            local players = BuildPlayersArray()

            -- Print the schema data to the console
            if statCollection.TESTING then
                PrintSchema(game, players)
            end

            -- Send custom stats
            if statCollection.HAS_SCHEMA then
                statCollection:sendCustom({ game = game, players = players })
            end
        end
    end, nil)
end

-------------------------------------

-- In the statcollection/lib/utilities.lua, you'll find many useful functions to build your schema.
-- You are also encouraged to call your custom mod-specific functions

-- Returns a table with our custom game tracking.
function BuildGameArray()
    local game = {}

    -- Add game values here as game.someValue = GetSomeGameValue()
   game.gl = math.floor(GameRules:GetGameTime() or 0)
    return game
end

-- Returns a table containing data for every player in the game
function BuildPlayersArray()
    local players = {}
    for playerID = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
            if not PlayerResource:IsBroadcaster(playerID) then

                local hero = PlayerResource:GetSelectedHeroEntity(playerID)

                -- Team string logic
                local player_team = ""
                if hero:GetTeam() == DOTA_TEAM_GOODGUYS then
                    player_team = "Shinobi Alliance"
                end
                if hero:GetTeam() == DOTA_TEAM_BADGUYS then
                    player_team = "Akatsuki Force"
                end

                table.insert(players, {
                    -- steamID32 required in here
                    steamID32 = PlayerResource:GetSteamAccountID(playerID),

                    -- Example functions for generic stats are defined in statcollection/lib/utilities.lua
                    -- Add player values here as someValue = GetSomePlayerValue(),

                    ph = GameMode:GetNarutoHeroName(GetHeroName(playerID)), -- Hero by its short name
                    pt = player_team, -- Team this hero belongs to
                    pk = hero:GetKills(), -- Number of kills of this players hero
                    pa = hero:GetAssists(), -- Number of deaths of this players hero
                    pd = hero:GetDeaths(), -- Number of deaths of this players hero
                    pl = hero:GetLevel(), -- Hero level at the end of the game
                    plh = hero:GetLastHits(), -- Hero level at the end of the game
                    pde = hero:GetDenies(), -- Hero level at the end of the game
                    pnw = GetNetworth(hero), -- Sum of hero gold and item worth
                    pdd = hero.damageDealt or 0,
                    pdt = hero.damageTaken or 0,
                    i1 = GetItemSlotNWR(hero, 0), -- Item Slot #1
                    i2 = GetItemSlotNWR(hero, 1), -- Item Slot #2
                    i3 = GetItemSlotNWR(hero, 2), -- Item Slot #3
                    i4 = GetItemSlotNWR(hero, 3), -- Item Slot #4
                    i5 = GetItemSlotNWR(hero, 4), -- Item Slot #5
                    i6 = GetItemSlotNWR(hero, 5), -- Item Slot #6
                })
            end
        end
    end

    return players
end

-- Prints the custom schema, required to get an schemaID
function PrintSchema(gameArray, playerArray)
    print("-------- GAME DATA --------")
    DeepPrintTable(gameArray)
    print("\n-------- PLAYER DATA --------")
    DeepPrintTable(playerArray)
    print("-------------------------------------")
end

-- Write 'test_schema' on the console to test your current functions instead of having to end the game
if Convars:GetBool('developer') then
    Convars:RegisterCommand("test_schema", function() PrintSchema(BuildGameArray(), BuildPlayersArray()) end, "Test the custom schema arrays", 0)
end

-------------------------------------

-- If your gamemode is round-based, you can use statCollection:submitRound(bLastRound) at any point of your main game logic code to send a round
-- If you intend to send rounds, make sure your settings.kv has the 'HAS_ROUNDS' set to true. Each round will send the game and player arrays defined earlier
-- The round number is incremented internally, lastRound can be marked to notify that the game ended properly
function customSchema:submitRound(isLastRound)

    local winners = BuildRoundWinnerArray()
    local game = BuildGameArray()
    local players = BuildPlayersArray()

    statCollection:sendCustom({ game = game, players = players })

    isLastRound = isLastRound or false --If the function is passed with no parameter, default to false.
    return { winners = winners, lastRound = isLastRound }
end

-- A list of players marking who won this round
function BuildRoundWinnerArray()
    local winners = {}
    local current_winner_team = GameRules.Winner or 0 --You'll need to provide your own way of determining which team won the round
    for playerID = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
            if not PlayerResource:IsBroadcaster(playerID) then
                winners[PlayerResource:GetSteamAccountID(playerID)] = (PlayerResource:GetTeam(playerID) == current_winner_team) and 1 or 0
            end
        end
    end
    return winners
end

-------------------------------------
-- MY CUSTOM FUNCTIONS
-------------------------------------
function GetItemSlotNWR(hero, slot)

    local item = hero:GetItemInSlot(slot)
    local itemName = "empty"
    if item then
            itemName = string.gsub(item:GetAbilityName(), "item_", "")
    end

    return itemName
end