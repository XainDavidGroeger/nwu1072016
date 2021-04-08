local postLocation = 'http://localhost/nwr/rest/index.php/'

if GetMapName() == "ranked" then
    ListenToGameEvent('game_rules_state_change', function(keys)
        local state = GameRules:State_Get()
        if state == 2 then
           --receive match data from server  
           --start teamassignment
           -- GameMode:assignRankedPlayer(playerId, teamId)
           -- update match data on db -> status started
           GameMode:printMatchDataStarted()
        end
        if state == DOTA_GAMERULES_STATE_DISCONNECT then 
            -- send match data status = delete if not finished yet
            GameMode:printMatchDataDisconnect()
        end

    end, nil)


    --This call should be done from the hosting bot once game starts loading
        ListenToGameEvent('player_connect_full', function(keys)

            local payload = [[ {"bot_steamid" : "133943769", "map" : "ranked", "mode" : "ap", "players":[
            {"steamid" : "123", "name" : "daveee"},
            {"steamid" : "234", "name" : "davezee"},
            {"steamid" : "323", "name" : "davefee"},
            {"steamid" : "423", "name" : "daveece"},
            {"steamid" : "523", "name" : "davexee"},
            {"steamid" : "623", "name" : "davxeee"},
            {"steamid" : "723", "name" : "davxeee"},
            {"steamid" : "823", "name" : "daveeae"},
            {"steamid" : "923", "name" : "davefee"},
            {"steamid" : "1123", "name" : "davaeee"}]} ]]
    local response_body = { }


-- Create the request
    local req = CreateHTTPRequest('POST', postLocation .. "/match/initiate")
    print(postLocation.."match/initiate")
    --print(json.encode(payload))
    -- Add the data
    req:SetHTTPRequestGetOrPostParameter('payload', payload)

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


        end, nil)


    -- Hook SetGameWinner
    local oldSetGameWinner = GameRules.SetGameWinner
    GameRules.SetGameWinner = function(gameRules, team)

    -- Run the rael setGameWinner function
    oldSetGameWinner(gameRules, team)

    -- Send Game Data Match is over
    GameMode:printMatchData(team)
    end
end

function GameMode:SendGameEndedData( team )
    local payload = [[ {"match_id" : "18", "match_winner" : "2", "duration" : "300", "forfeit" : "0",
        "players":[
            {"steamid" : "123", "name" : "daveee", "kills" : "1", "deaths" : "1", "assists" : "1", "last_hits" : "1", "denies" : "1", "dmg_dealt" : "1", "dmg_taken" : "1", "dc" : "1", "hero_id" : "1", "gold_networth" : "1", "item_1_id" : "1", "item_2_id" : "1", "item_3_id" : "1", "item_4_id" : "1" ,"item_5_id" : "1", "item_6_id" : "1", "gold_current" : "1", 
            "chat" : [
                {"message" : "hallo", "gametime" : "20", "systemtime" : "100434"},
                {"message" : "ciao", "gametime" : "45", "systemtime" : "1004434"}
            ]},
            {"steamid" : "234", "name" : "davezee", "kills" : "1", "deaths" : "1", "assists" : "1", "last_hits" : "1", "denies" : "1", "dmg_dealt" : "1", "dmg_taken" : "1", "dc" : "1", "hero_id" : "1", "gold_networth" : "1", "item_1_id" : "1", "item_2_id" : "1", "item_3_id" : "1", "item_4_id" : "1" ,"item_5_id" : "1", "item_6_id" : "1", "gold_current" : "1", 
            "chat" : [
              
            ]},
            {"steamid" : "323", "name" : "davefee", "kills" : "1", "deaths" : "1", "assists" : "1", "last_hits" : "1", "denies" : "1", "dmg_dealt" : "1", "dmg_taken" : "1", "dc" : "1", "hero_id" : "1", "gold_networth" : "1", "item_1_id" : "1", "item_2_id" : "1", "item_3_id" : "1", "item_4_id" : "1" ,"item_5_id" : "1", "item_6_id" : "1", "gold_current" : "1", 
            "chat" : [
                
            ]},
            {"steamid" : "423", "name" : "daveece", "kills" : "1", "deaths" : "1", "assists" : "1", "last_hits" : "1", "denies" : "1", "dmg_dealt" : "1", "dmg_taken" : "1", "dc" : "1", "hero_id" : "1", "gold_networth" : "1", "item_1_id" : "1", "item_2_id" : "1", "item_3_id" : "1", "item_4_id" : "1" ,"item_5_id" : "1", "item_6_id" : "1", "gold_current" : "1", 
            "chat" : [
               
            ]},
            {"steamid" : "523", "name" : "davexee", "kills" : "1", "deaths" : "1", "assists" : "1", "last_hits" : "1", "denies" : "1", "dmg_dealt" : "1", "dmg_taken" : "1", "dc" : "1", "hero_id" : "1", "gold_networth" : "1", "item_1_id" : "1", "item_2_id" : "1", "item_3_id" : "1", "item_4_id" : "1" ,"item_5_id" : "1", "item_6_id" : "1", "gold_current" : "1", 
            "chat" : [
               
            ]},
            {"steamid" : "623", "name" : "davxeee", "kills" : "1", "deaths" : "1", "assists" : "1", "last_hits" : "1", "denies" : "1", "dmg_dealt" : "1", "dmg_taken" : "1", "dc" : "1", "hero_id" : "1", "gold_networth" : "1", "item_1_id" : "1", "item_2_id" : "1", "item_3_id" : "1", "item_4_id" : "1" ,"item_5_id" : "1", "item_6_id" : "1", "gold_current" : "1", 
            "chat" : [
                
            ]},
            {"steamid" : "723", "name" : "davxeee", "kills" : "1", "deaths" : "1", "assists" : "1", "last_hits" : "1", "denies" : "1", "dmg_dealt" : "1", "dmg_taken" : "1", "dc" : "1", "hero_id" : "1", "gold_networth" : "1", "item_1_id" : "1", "item_2_id" : "1", "item_3_id" : "1", "item_4_id" : "1" ,"item_5_id" : "1", "item_6_id" : "1", "gold_current" : "1", 
            "chat" : [
               
            ]},
            {"steamid" : "823", "name" : "daveeae", "kills" : "1", "deaths" : "1", "assists" : "1", "last_hits" : "1", "denies" : "1", "dmg_dealt" : "1", "dmg_taken" : "1", "dc" : "1", "hero_id" : "1", "gold_networth" : "1", "item_1_id" : "1", "item_2_id" : "1", "item_3_id" : "1", "item_4_id" : "1" ,"item_5_id" : "1", "item_6_id" : "1", "gold_current" : "1", 
            "chat" : [
                
            ]},
            {"steamid" : "923", "name" : "davefee", "kills" : "1", "deaths" : "1", "assists" : "1", "last_hits" : "1", "denies" : "1", "dmg_dealt" : "1", "dmg_taken" : "1", "dc" : "1", "hero_id" : "1", "gold_networth" : "1", "item_1_id" : "1", "item_2_id" : "1", "item_3_id" : "1", "item_4_id" : "1" ,"item_5_id" : "1", "item_6_id" : "1", "gold_current" : "1", 
            "chat" : [
                
            ]},
            {"steamid" : "1123", "name" : "davaeee", "kills" : "1", "deaths" : "1", "assists" : "1", "last_hits" : "1", "denies" : "1", "dmg_dealt" : "1", "dmg_taken" : "1", "dc" : "1", "hero_id" : "1", "gold_networth" : "1", "item_1_id" : "1", "item_2_id" : "1", "item_3_id" : "1", "item_4_id" : "1" ,"item_5_id" : "1", "item_6_id" : "1", "gold_current" : "1", 
            "chat" : [
               
            ]}
            ],
        "team_one":[{"gold" : "1", "dmg_dealt" : "1", "dmg_taken" : "1", "juubi_count" : "1", "tower_destroyed" : "1", "kills" : "1", "deaths" : "1"}],
        "team_two":[{"gold" : "2", "dmg_dealt" : "1", "dmg_taken" : "1", "juubi_count" : "1", "tower_destroyed" : "1", "kills" : "1", "deaths" : "1"}]
            } ]]

    local response_body = { }

-- Create the request
    local req = CreateHTTPRequest('POST', postLocation .. "/match/finished")
    print(postLocation.."match/finished")
    --print(json.encode(payload))
    -- Add the data
    req:SetHTTPRequestGetOrPostParameter('payload', payload)

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

function GameMode:printMatchDataStarted()
   -- print("Print of the match data sent on assignment")
    local bot = PlayerResource:GetPlayer(0)
   -- print("HostBot SteamId: " .. PlayerResource:GetSteamAccountID(0))
  --  print("Get Data from match by bot steam id + status = loading")
  --  print("teams get balanced and assigned now")
    for i=0, 12 do
        if PlayerResource:IsValidPlayer(i) then
            local player = PlayerResource:GetPlayer(i)
         --    print("PlayerID: " .. player:GetPlayerID() .. " TeamId: " .. player:GetTeamNumber() .. " SteamId: " .. PlayerResource:GetSteamAccountID(i))
        end
    end
 --   print("send update to database -> status = started, player_match-> set team id, match->set average mmr")

    local payload = [[ {"shinobiMMR":"1500","akatMMR":"1530", "bot_steamid" : "133943769", "map" : "ranked", "mode" : "ap", "matchId" : "18", "players":[{"steamid" : "123", "name" : "daveee", "team_number" : "2"},
    {"steamid" : "234", "name" : "davezee", "team_number" : "2"},
    {"steamid" : "323", "name" : "davefee", "team_number" : "2"},
    {"steamid" : "423", "name" : "daveece", "team_number" : "2"},
    {"steamid" : "523", "name" : "davexee", "team_number" : "2"},
    {"steamid" : "623", "name" : "davxeee", "team_number" : "3"},
    {"steamid" : "723", "name" : "davxeee", "team_number" : "3"},
    {"steamid" : "823", "name" : "daveeae", "team_number" : "3"},
    {"steamid" : "923", "name" : "davefee", "team_number" : "3"},
    {"steamid" : "1123", "name" : "davaeee", "team_number" : "3"}]} ]]
    local response_body = { }

-- Create the request
    local req = CreateHTTPRequest('POST', postLocation .. "/match/started")
    print(postLocation.."match/started")
    --print(json.encode(payload))
    -- Add the data
    req:SetHTTPRequestGetOrPostParameter('payload', payload)

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

function GameMode:printMatchDataDisconnect()
    print("Print match data on disconnect")

    local payload = [[ {"match_id":"8" } ]]
    local response_body = { }

-- Create the request
    local req = CreateHTTPRequest('POST', postLocation .. "/match/deleted")
    print(postLocation.."match/deleted")
    --print(json.encode(payload))
    -- Add the data
    req:SetHTTPRequestGetOrPostParameter('payload', payload)

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
    print(postLocation.."match/abandoned")
    --print(json.encode(payload))
    -- Add the data
    req:SetHTTPRequestGetOrPostParameter('payload', payload)

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