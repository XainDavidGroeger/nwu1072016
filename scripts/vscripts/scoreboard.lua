LinkLuaModifier( "modifier_takeDamage", "modifiers/modifier_takeDamage.lua" ,LUA_MODIFIER_MOTION_NONE )

function recordDamageDone( hero )
	if hero:IsRealHero() then
		if not hero.scoreboard then
			CustomGameEventManager:Send_ServerToAllClients( "initiate", hero )
			hero.scoreboard = true
		end
		if not hero:HasModifier("modifier_takeDamage") then
			hero:AddNewModifier(hero, nil, "modifier_takeDamage", {})
		end
		
	end
end


function SetScoreBoardAssists()
	Timers:CreateTimer(function()
              local dataTable = {}
              local assistsTable = {}
              local count = 0
              local teamTable = {}
              for playerID=0,12 do
                if PlayerResource:IsValidPlayerID(playerID) then
                  local player = PlayerResource:GetPlayer(playerID)
                  if player ~= nil then
                        table.insert(assistsTable, PlayerResource:GetAssists(playerID))
                        table.insert(teamTable, player:GetAssignedHero():GetTeamNumber())
                        count = count + 1
                  end
                end
              end
              table.insert(dataTable, teamTable)
              table.insert(dataTable, assistsTable)
              table.insert(dataTable, count)
              CustomGameEventManager:Send_ServerToAllClients( "initiate", dataTable )
              return 2.0 
       end
      )
end
 