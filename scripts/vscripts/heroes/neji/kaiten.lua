function createParticle( keys )
	local particle = ParticleManager:CreateParticle("particles/units/heroes/neji/neji_forgot_a.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)
	ParticleManager:SetParticleControl(particle, 1, keys.caster:GetAbsOrigin()) -- Origin
	ParticleManager:SetParticleControlEnt(particle, 0, keys.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.caster:GetAbsOrigin(), true)
	keys.ability.ultiParticle = particle
end

function removeParticle( keys )
	keys.caster:Stop()
	ParticleManager:DestroyParticle( keys.ability.ultiParticle, true )
end

function playSound( keys )
	local random = math.random(1, 2)
	if random == 1 then
		EmitSoundOn("neji_kaiten",keys.caster)
	elseif random == 2 then
		EmitSoundOn("neji_kaiten_2",keys.caster)
	end
end

function playKaitenSound( keys )
	EmitSoundOn("Hero_Juggernaut.BladeFuryStart",keys.caster)
	Timers:CreateTimer( 1.0, function()
        StopSoundOn("Hero_Juggernaut.BladeFuryStart",keys.caster)
		return nil
	end
	)

end

function stunAfterKnockback( keys )
	print("yo")
	local caster = keys.caster
	local targetEntities = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, keys.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO , 0, FIND_ANY_ORDER, false)
	Timers:CreateTimer(1.0, function() 
		print("yoyo")
		if targetEntities then
			for _,target in pairs(targetEntities) do
				local origin = target:GetAbsOrigin()
				target:AddNewModifier(keys.caster, keys.ability, 'modifier_stunned', {duration = keys.duration})
			end
		end
		return nil
	end)
end