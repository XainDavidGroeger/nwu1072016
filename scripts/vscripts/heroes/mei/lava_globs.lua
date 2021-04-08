function applyDamage( keys )
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	local damage_percent_int = keys.ability:GetLevelSpecialValueFor("damage_percent_int", (keys.ability:GetLevel() - 1))
	local damage = caster:GetIntellect() / 100 * damage_percent_int
	ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})

end


function aoeEffect( keys )

	local radius = 300
	local target_point = keys.target:GetAbsOrigin()
	local lava_count = 6
	local scope = math.pi * radius
	local posX = 0
	local posY = 0

	local r = radius / 2
	for i = 1,lava_count do
			posX = target_point.x + r * math.cos((math.pi*2/lava_count) * i)
			posY = target_point.y + r * math.sin((math.pi*2/lava_count) * i)
			local position = Vector(posX, posY, 0)
			local projectileTable = {
		        Ability = ability,
		        EffectName = "particles/units/heroes/mei/bolt_core.vpcf",
		        vSpawnOrigin = keys.caster:GetAbsOrigin(),
		        fDistance = spill_range,
		        fStartRadius = 150,
		        fEndRadius = 150,
		        Source = keys.caster,
		        bHasFrontalCone = true,
		        bReplaceExisting = false,
		        bProvidesVision = false,
		        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			}

    		local speed = 500

    		local pos = keys.caster:GetAbsOrigin()
    		pos.z = 0
    		local diff = position - pos
    		projectileTable.vVelocity = diff:Normalized() * speed

			ProjectileManager:CreateLinearProjectile( projectileTable )
	end
		

end