modifier_takeDamage = class({})

UNIQUE_DAMAGE_KEY = ''
--------------------------------------------------------------------------------

function modifier_takeDamage:IsHidden()
	return true
end



function modifier_takeDamage:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
 
	return funcs
end
--------------------------------------------------------------------------------

function modifier_takeDamage:OnTakeDamage( params )
 	local keys = params
 	local newunique = keys.attacker:GetName() .. "+" .. keys.damage .. "+" .. keys.unit:GetName()

	if keys.attacker:IsRealHero() and keys.unit:IsRealHero() and UNIQUE_DAMAGE_KEY ~= newunique then
		UNIQUE_DAMAGE_KEY = newunique
		if keys.attacker.damageDealt == nil then
			keys.attacker.damageDealt = keys.damage
		else
			keys.attacker.damageDealt = keys.attacker.damageDealt + keys.damage
		end

		if keys.unit.damageTaken == nil then
			keys.unit.damageTaken = keys.damage
		else
			keys.unit.damageTaken = keys.unit.damageTaken + keys.damage
		end

		

		
		 local broadcast_damage_event =
	  		{
	    		damage = keys.damage,
	    		attacker_id = keys.attacker:GetPlayerOwner():GetPlayerID(),
	    		victim_id = keys.unit:GetPlayerOwner():GetPlayerID(),
	    		attacker_team_id = keys.attacker:GetTeamNumber(),
	    		victim_team_id = keys.unit:GetTeamNumber()
	 		 }

 		CustomGameEventManager:Send_ServerToAllClients( "damage_event", broadcast_damage_event )
		
	end
	return 0
end

--------------------------------------------------------------------------------