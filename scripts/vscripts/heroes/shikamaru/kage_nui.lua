function SetDamage( event )
	local target = event.target
	local ability = event.ability
	local attack_damage_min = ability:GetLevelSpecialValueFor("damage_min", ability:GetLevel() - 1 )
	local attack_damage_max = ability:GetLevelSpecialValueFor("damage_max", ability:GetLevel() - 1 )

	target:SetBaseDamageMax(attack_damage_max)
	target:SetBaseDamageMin(attack_damage_min)

end

function playSound( keys )
	local random = math.random(1, 2)
	if random == 1 then
		EmitSoundOn("shikamaru_ult",keys.caster)
	elseif random == 2 then
		EmitSoundOn("shikamaru_ult_alt",keys.caster)
	end
end