
--[[Author: LearningDave
  Date: november, 9th 2015.
  If not done yet, sets up hero tables to match naruto name to dota hero name
]]
function GameMode:Setup_stateTable()
    -- setup race reference table
    if GameRules.stateTable == nil then
        GameRules.stateTable = {}
        GameRules.stateTable[1] = 2
        GameRules.stateTable[2] = 2
        GameRules.stateTable[3] = 2
        GameRules.stateTable[4] = 2
        GameRules.stateTable[5] = 2
        GameRules.stateTable[6] = 2
        GameRules.stateTable[7] = 2
        GameRules.stateTable[8] = 2
        GameRules.stateTable[9] = 2
        GameRules.stateTable[10] = 2
        GameRules.stateTable[11] = 2
        GameRules.stateTable[12] = 2
    end
    if GameRules.dcTimer == nil then
        GameRules.dcTimer = {}
        GameRules.dcTimer[1] = 0
        GameRules.dcTimer[2] = 0
        GameRules.dcTimer[3] = 0
        GameRules.dcTimer[4] = 0
        GameRules.dcTimer[5] = 0
        GameRules.dcTimer[6] = 0
        GameRules.dcTimer[7] = 0
        GameRules.dcTimer[8] = 0
        GameRules.dcTimer[9] = 0
        GameRules.dcTimer[10] = 0
        GameRules.dcTimer[11] = 0
        GameRules.dcTimer[12] = 0
    end
end


 function GameMode:checkLeaver()
         GameMode:Setup_stateTable()
    --  A timer running every second that starts immediately on the next frame, respects pauses
        Timers:CreateTimer(function()
          for playerID=0,12 do
            if  GameRules.stateTable[playerID+1] ~= 4 then
              if PlayerResource:GetConnectionState(playerID) == 4 then
                 print("should be 2 or 3 now " ..  GameRules.stateTable[playerID+1])
                GameRules.stateTable[playerID+1] = 4
                print("splitting gold now from player" .. playerID)
                print("should be 4 now " ..  GameRules.stateTable[playerID+1])
                GameMode:splitGold(playerID)
              end

               if PlayerResource:GetConnectionState(playerID) == 2 then
                if GameRules.stateTable[playerID+1] == 3 then
                  GameRules.stateTable[playerID+1] = 2
                else
                  GameRules.stateTable[playerID+1] = 2
                end
                
               end

              if PlayerResource:GetConnectionState(playerID) == 3 then
                  if GameRules.stateTable[playerID+1] ~= 4 and GameRules.stateTable[playerID+1] ~= 3 then
                    GameRules:SendCustomMessage(PlayerResource:GetPlayerName(playerID) .. " disconnected from this game. He has 5 minutes to reconnect before his gold will be split within his team.", 0, 0)
                    GameRules.dcTimer[playerID+1] = GameRules:GetGameTime()
                     GameRules.stateTable[playerID+1] = 3
                  Timers:CreateTimer(300, function()
                    print(GameRules.dcTimer[playerID+1] .. " compare " .. GameRules:GetGameTime() .. " = " .. (GameRules:GetGameTime() - GameRules.dcTimer[playerID+1]))
                    local difference = GameRules:GetGameTime() - GameRules.dcTimer[playerID+1]
                  if PlayerResource:GetConnectionState(playerID) == 3 and difference > 285 then
                    GameMode:shareDcGold(playerID)
                    GameRules.stateTable[playerID+1] = 4
                 end
                 return nil
                 end
                  )
              end
            end
            end
          end
       return 1.0  
       end
        )
  end


  function GameMode:shareDcGold(playerId)
    local player = PlayerResource:GetPlayer(playerId)
    local hero = PlayerResource:GetSelectedHeroEntity(playerId)
    local teamNumber = PlayerResource:GetTeam(playerId)
    local heroName = "nohero"
    local gold = 625
    if hero ~= nil then
         gold =  GameMode:GetNetworth(hero)
        hero:SetGold(0,false)
      for itemSlot = 0, 15 do
          local item = hero:GetItemInSlot( itemSlot )
          if item then 
            hero:RemoveItem(item)
          end
      end
       heroName = hero:GetName()
    end


    local teamNumber = hero:GetTeamNumber()
    local gold =  GameMode:GetNetworth(hero)
    hero:SetGold(0,false)
    GameRules:SendCustomMessage(PlayerResource:GetPlayerName(playerId) .. " didnt reconnect in time. His " .. gold .. " gold will be split within his team. Shame on him.", 0, 0)



    local toShareNumber = 0

      for id=0,12 do
        if  GameRules.stateTable[id+1] ~= 4 then
           local currentPlayer = PlayerResource:GetPlayer(id)
           local currentHero = PlayerResource:GetSelectedHeroEntity(id)
           if currentHero ~= nil and currentPlayer ~= nil then
            if currentHero:GetTeamNumber() == teamNumber then
              toShareNumber = toShareNumber + 1
              print("tosharenumber" .. toShareNumber)
            end
          end
        end
      end

      for id=0,12 do
        if  GameRules.stateTable[id+1] ~= 4 then
           local goldGain = gold / toShareNumber
           local addGoldGain = 1.67 / toShareNumber
            print("to modify gold" .. goldGain)
           local currentPlayer = PlayerResource:GetPlayer(id)
           local currentHero = PlayerResource:GetSelectedHeroEntity(id)
            if currentHero ~= nil and currentPlayer ~= nil then
           print("teamnumber from player" .. currentHero:GetTeamNumber())
           print("teamnumber from leaver" .. teamNumber)
            if currentHero:GetTeamNumber() == teamNumber and currentHero:GetName() ~= hero:GetName() then
              currentHero:ModifyGold(goldGain,true,0)
              PopupGoldGain(currentHero, goldGain)
               Timers:CreateTimer(function()
                currentHero:ModifyGold(addGoldGain,true,0)
               return 1.0  
               end
                )
            end
          end
        end
      end
  end

  function GameMode:splitGold(playerId)

    local player = PlayerResource:GetPlayer(playerId)
    local hero = PlayerResource:GetSelectedHeroEntity(playerId)
    local teamNumber = PlayerResource:GetTeam(playerId)
    local heroName = "nohero"
    local gold = 625
    if hero ~= nil then
         gold =  GameMode:GetNetworth(hero)
        hero:SetGold(0,false)
      for itemSlot = 0, 15 do
          local item = hero:GetItemInSlot( itemSlot )
          if item then 
            hero:RemoveItem(item)
          end
      end
       heroName = hero:GetName()
    end

    
    
    GameRules:SendCustomMessage(PlayerResource:GetPlayerName(playerId) .. " abandoned this game. His " .. gold .. " gold will be split within his team. Shame on him.", 0, 0)

    local toShareNumber = 0

      for id=0,12 do
        if  GameRules.stateTable[id+1] ~= 4 then
           local currentPlayer = PlayerResource:GetPlayer(id)
           local currentHero = PlayerResource:GetSelectedHeroEntity(id)
           if currentHero ~= nil and currentPlayer ~= nil then
            if currentHero:GetTeamNumber() == teamNumber then
              toShareNumber = toShareNumber + 1
              print("tosharenumber" .. toShareNumber)
            end
          end
        end
      end

      for id=0,12 do
        if  GameRules.stateTable[id+1] ~= 4 then
           local goldGain = gold / toShareNumber
           local addGoldGain = 1.67 / toShareNumber
            print("to modify gold" .. goldGain)
           local currentPlayer = PlayerResource:GetPlayer(id)
           local currentHero = PlayerResource:GetSelectedHeroEntity(id)
            if currentHero ~= nil and currentPlayer ~= nil then
           print("teamnumber from player" .. currentHero:GetTeamNumber())
           print("teamnumber from leaver" .. teamNumber)

            if currentHero:GetTeamNumber() == teamNumber and currentHero:GetName() ~= heroName  then
              currentHero:ModifyGold(goldGain,true,0)
              PopupGoldGain(currentHero, goldGain)
               Timers:CreateTimer(function()
                currentHero:ModifyGold(addGoldGain,true,0)
               return 1.0  
               end
                )
            end
          end
        end
      end


  end



-- Current gold and item net worth
function GameMode:GetNetworth(hero)
    local networth = hero:GetGold()

    -- Iterate over item slots adding up its gold cost
    for i = 0, 15 do
        local item = hero:GetItemInSlot(i)
        if item then
            networth = networth + (item:GetCost() / 2)
        end
    end

    return networth
end
