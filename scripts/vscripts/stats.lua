JUUBI_ONE = 0
JUUBI_TWO = 0
TOWER_ONE = 0
TOWER_TWO = 0
MATCHID = 0
CHECK_STAGE_START = false
CHECK_STAGE_FINISH = false
MINPLAYERSEND = 10

local postLocation = 'http://stats.narutowarsreborn.com/rest/index.php/'

if GetMapName() == "dota"  then
    ListenToGameEvent('game_rules_state_change', function(keys)
        local state = GameRules:State_Get()
        if state == 6 then
           --receive match data from server  
           --start teamassignment
           -- GameMode:assignRankedPlayer(playerId, teamId)
           -- update match data on db -> status started
           GameMode:sendMatchDataStarted()
        end
        if state == DOTA_GAMERULES_STATE_DISCONNECT then 
            -- send match data status = delete if not finished yet
            GameMode:sendDataDisconnect()
        end

    end, nil)
end


function GameMode:sendMatchData( team )
	if CHECK_STAGE_FINISH then return end
	CHECK_STAGE_FINISH = true
	local dmg_dealt_team_one = 0
	local dmg_dealt_team_two = 0
	local dmg_taken_team_one = 0
	local dmg_taken_team_two = 0
	local gold_team_one = 0
	local gold_team_two = 0
	local players = {}
	    --player data
    for i=0, 12 do
        if PlayerResource:IsValidPlayer(i) then 
            --stats
            local hero = PlayerResource:GetSelectedHeroEntity(i)

            if hero ~= nil then
                local dmgdealt = hero.damageDealt or 0
                local dmgtaken = hero.damageTaken or 0
                local chat = {}

                if hero:GetTeamNumber() == 2 then
                    gold_team_one = gold_team_one + GameMode:GetNetworth(hero)
                    dmg_taken_team_one = dmg_taken_team_one + dmgtaken
                    dmg_dealt_team_one = dmg_dealt_team_one + dmgdealt
                end

                if hero:GetTeamNumber() == 3 then
                     gold_team_two = gold_team_two + GameMode:GetNetworth(hero)
                     dmg_dealt_team_two = dmg_dealt_team_two + dmgdealt
                     dmg_taken_team_two = dmg_taken_team_two + dmgtaken
                end

                --chat
            --    if GameRules.chatInput then
            --        for key,chat_entry in pairs(GameRules.chatInput) do
            --            if chat_entry.id == i then
             --               for index,message in pairs(chat_entry) do
             --                   if message ~= chat_entry.id  then 
             --                       table.insert(chat, {
             --                           message = message.message or 0,
             --                           gametime = message.time or 0,
             --                           systemtime = message.systemTime or 0
            --                        })
             --                   end
            --               end
             --           end
             --       end
             --   end

                table.insert(players, {
                    steamid = PlayerResource:GetSteamAccountID(i) or 0,
                    name = PlayerResource:GetPlayerName(i) or 0,
                    kills = hero:GetKills() or 0,
                    deaths = hero:GetDeaths() or 0,
                    assists = hero:GetAssists() or 0,
                    last_hits = hero:GetLastHits() or 0,
                    denies = hero:GetDenies() or 0,
                    dmg_dealt = dmgdealt or 0,
                    dmg_taken = dmgtaken or 0,
                    dc = GameRules.stateTable[i+1],
                    hero_id = GameMode:GetNarutoHeroId(GameMode:GetHeroName(i)),
                    gold_networth = GameMode:GetNetworth(hero),
                    item_1_id = GameMode:GetItemSlotNWR(hero, 0),
                    item_2_id = GameMode:GetItemSlotNWR(hero, 1),
                    item_3_id = GameMode:GetItemSlotNWR(hero, 2),
                    item_4_id = GameMode:GetItemSlotNWR(hero, 3),
                    item_5_id = GameMode:GetItemSlotNWR(hero, 4),
                    item_6_id = GameMode:GetItemSlotNWR(hero, 5),
                    gold_current = hero:GetGold(),
                    team_number = hero:GetTeamNumber(),
                    chat = chat
                })
            else
                local player = PlayerResource:GetPlayer(i)
                local team = PlayerResource:GetTeam(i)
                local dmgdealt =  0
                local dmgtaken =  0
                local chat = {}

                table.insert(players, {
                    steamid = PlayerResource:GetSteamAccountID(i) or 0,
                    name = PlayerResource:GetPlayerName(i) or 0,
                    kills =  0,
                    deaths =  0,
                    assists =  0,
                    last_hits =  0,
                    denies =  0,
                    dmg_dealt =  0,
                    dmg_taken =  0,
                    dc = GameRules.stateTable[i+1],
                    hero_id = 0,
                    gold_networth = 0,
                    item_1_id = "empty",
                    item_2_id = "empty",
                    item_3_id = "empty",
                    item_4_id = "empty",
                    item_5_id = "empty",
                    item_6_id = "empty",
                    gold_current = 0,
                    team_number = team,
                    chat = chat
                })
            end
        end
    end


    local teamOne = {}
	table.insert(teamOne, {
                gold = gold_team_one,
                dmg_dealt = dmg_dealt_team_one or 0,
                dmg_taken = dmg_taken_team_one or 0,
                juubi_count = 0,
                tower_destroyed = 0,
                kills = 0,
                deaths = 0
    })

    local teamTwo = {}
	table.insert(teamTwo, {
                gold = gold_team_two,
                dmg_dealt = dmg_dealt_team_two or 0,
                dmg_taken = dmg_taken_team_two or 0,
                juubi_count = 0,
                tower_destroyed = 0,
                kills = 0,
                deaths = 0
    })

	local payload = {
		match_id = MATCHID,
        match_winner = team,
        duration =  math.floor(GameRules:GetGameTime() or 0),
        forfeit = 0,
        team_one = teamOne,
        team_two = teamTwo,
        players = players
    }
    local response_body = { }

-- Create the request
    local req = CreateHTTPRequest('POST', postLocation .. "match/finished")

     print("sending stats...")
    -- Add the data
    req:SetHTTPRequestGetOrPostParameter('payload', json.encode(payload))

    -- Send the request
    req:Send(function(res)
        if res.StatusCode ~= 200 or not res.Body then
            PrintTable(res)
            return
        end

         print("finished sending stats")
        PrintTable(payload)
        -- Try to decode the result
        local obj, pos, err = json.decode(res.Body, 1, nil)

    end)
end

function GameMode:printMatchData(team)
    print("Print of the match data sent on setGameWinner")
    local duration = math.floor(GameRules:GetGameTime() or 0)
    --match data
    local surrendered = GameRules.surrendered or false
    print("-----------------------------------")
    print("Match Data")
    print("Duration: " .. duration)
    print("Winner: " .. team)
    print("Surrendered: " .. tostring(surrendered))
    print("-----------------------------------")

    --player data
    for i=0, 12 do
        if PlayerResource:IsValidPlayer(i) then 
            --stats
            local player = PlayerResource:GetPlayer(i)
            local hero = player:GetAssignedHero()
            print("-------------------------------------------")
            print("PlayerData for " .. PlayerResource:GetPlayerName(i))
            print("Kills: " .. hero:GetKills())
            print("Deaths: " .. hero:GetDeaths())
            print("Assists: " .. hero:GetAssists())

            print("Last Hits: " .. hero:GetLastHits())
            print("Denies: " .. hero:GetDenies())

            local dmgdealt = hero.damageDealt or 0
            local dmgtaken = hero.damageTaken or 0
            print("Damage Dealt: " .. dmgdealt)
            print("Damage Taken: " .. dmgtaken)
            print("TeamNumber: " .. hero:GetTeamNumber())


            --items
            print("-----------")
            print("Items:")
            print("-----------")
            for j=0, 6 do
                print("Item #" .. (j+1))
                print(GetItemSlotNWRByHeroSlot(hero, j))
            end

            --chat
            print("Chatlog")
            if GameRules.chatInput then
                for key,chat_entry in pairs(GameRules.chatInput) do
                    if chat_entry.id == i then
                        for index,message in pairs(chat_entry) do
                            if message ~= chat_entry.id  then 
                                print("---------------------")
                                print("Message #" .. index)
                                print("Message: " .. message.message)
                                print("Gametime of Message:" .. message.time)
                                print("Systemtime of Message: " .. message.systemTime)
                                print("Systemdate of Message: " .. message.systemDate)
                                print("---------------------")
                            end
                        end
                    end
                end
            end

            print("-------------------------------------------")
            
        end
    end
end

function GameMode:sendMatchDataStarted()
if CHECK_STAGE_START then return end
if PlayerResource:GetPlayerCount() < MINPLAYERSEND then return end
	CHECK_STAGE_START = true
 	local players = {}

    for i=0, 12 do
        if PlayerResource:IsValidPlayer(i) then
            table.insert(players, {
                steamid = PlayerResource:GetSteamAccountID(i) or 0,
                name = PlayerResource:GetPlayerName(i) or 0,
                team_number = PlayerResource:GetTeam(i) or 0
    		})
        end
    end


 	local payload = {
 		mode = "ap",
        players = players
    }
    print("sending stats...")
    local response_body = { }

-- Create the request
    local req = CreateHTTPRequest('POST', postLocation .. "match/normal/started")
     print(json.encode(payload))
    --print(json.encode(payload))
    -- Add the data
    req:SetHTTPRequestGetOrPostParameter('payload', json.encode(payload))

    -- Send the request
    req:Send(function(res)
        if res.StatusCode ~= 200 or not res.Body then
            PrintTable(res)
            return
        end

        print(json.decode(res.Body))
        MATCHID = json.decode(res.Body)
        
        print("finished sending stats")
        -- Try to decode the result
        local obj, pos, err = json.decode(res.Body, 1, nil)


    end)


end

function GameMode:sendDataDisconnect()

   print("Print match data on disconnect")

    local payload = {
        match_id = MATCHID
    }

    local response_body = { }

-- Create the request
    local req = CreateHTTPRequest('POST', postLocation .. "/match/deleted")
    --print(json.encode(payload))
    -- Add the data
    req:SetHTTPRequestGetOrPostParameter('payload', json.encode(payload))
    print(json.encode(payload))
    -- Send the request
    req:Send(function(res)
        if res.StatusCode ~= 200 or not res.Body then
            PrintTable(res)
            return
        end
        PrintTable(res.Body)
        print(res.Body)

        -- Try to decode the result
        local obj, pos, err = json.decode(res.Body, 1, nil)


    end)

end

function GetItemSlotNWRByHeroSlot(hero, slot)
    local item = hero:GetItemInSlot(slot)
    local itemName = "empty"
    if item then
            itemName = string.gsub(item:GetAbilityName(), "item_", "")
    end

    return itemName
end


function GameMode:sendPlayerAbandonedGame(player)
     local payload = [[ {"match_id" : "18", "steam_id" : "123"} ]]

    local response_body = { }

-- Create the request
    local req = CreateHTTPRequest('POST', postLocation .. "/match/abandoned")
    --print(json.encode(payload))
    -- Add the data
    req:SetHTTPRequestGetOrPostParameter('payload', json.encode(payload))

    -- Send the request
    req:Send(function(res)
        if res.StatusCode ~= 200 or not res.Body then
            PrintTable(res)
            return
        end
        PrintTable(res.Body)
        print(res.Body)

        -- Try to decode the result
        local obj, pos, err = json.decode(res.Body, 1, nil)

    end)
end



-- Number of times roshan was killed
function GetRoshanKills()
    local total_rosh_kills = 0
    for playerID = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
            local roshan_kills_player = PlayerResource:GetRoshanKills(playerID)
            total_rosh_kills = total_rosh_kills + roshan_kills_player
        end
    end

    return total_rosh_kills
end

------------------------------
-- Player Functions    --
------------------------------

-- Hero name without its npc_dota_hero prefix.
-- If you would like to send custom hero names you should use a different function instead
function GameMode:GetHeroName(playerID)
    local heroName = PlayerResource:GetSelectedHeroName(playerID)
    heroName = string.gsub(heroName, "npc_dota_hero_", "") --Cuts the npc_dota_hero_ prefix

    return heroName
end

-- String of item name, without the item_ prefix
function  GameMode:GetItemSlot(hero, slot)
    local item = hero:GetItemInSlot(slot)
    local itemName = ""

    if item then
        itemName = string.gsub(item:GetAbilityName(), "item_", "")
    end

    return itemName
end

-- Long string of item names ordered alphabetically, without the item_ prefix and separated by commas
function  GameMode:GetItemList(hero)
    local itemTable = {}

    for i = 0, 5 do
        local item = hero:GetItemInSlot(i)
        if item then
            local itemName = string.gsub(item:GetAbilityName(), "item_", "") --Cuts the item_ prefix
            table.insert(itemTable, itemName)
        end
    end

    table.sort(itemTable)
    local itemList = table.concat(itemTable, ",") --Concatenates with a comma

    return itemList
end
