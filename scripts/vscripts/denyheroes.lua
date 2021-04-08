LinkLuaModifier( "modifier_deniable", "modifiers/modifier_deniable.lua" ,LUA_MODIFIER_MOTION_NONE )

function makeHeroesDenyable(  )
	Timers:CreateTimer(function()
     	local PlayerCount = PlayerResource:GetPlayerCount() - 1
		for i=0, PlayerCount do     
	    	if PlayerResource:IsValidPlayer(i) then
	            local player = PlayerResource:GetPlayer(i)
	        	if player ~= nil then
	        		 local hero = player:GetAssignedHero()
		            if hero ~= nil then
		            	if hero:IsAlive() then
		            		local healthPercent = hero:GetHealth() / (hero:GetMaxHealth() / 100)
		            		if healthPercent < 10.0 then
		            			if not hero:HasModifier("modifier_deniable") then
		            				hero:AddNewModifier(hero, nil, "modifier_deniable", {})
		            			end
		            		else
		            			if hero:HasModifier("modifier_deniable") then
		            				hero:RemoveModifierByName("modifier_deniable")
		            			end
		            		end
		            	end
		            end
	        	end
	        end
	    end
      return 0.03 
    end)
	
end