function stackInt( keys )
	local bonus_int_per_stack = keys.ability:GetLevelSpecialValueFor("bonus_int_per_stack", (keys.ability:GetLevel() - 1))
	local max_stacks = keys.ability:GetLevelSpecialValueFor("max_stacks", (keys.ability:GetLevel() - 1))
	local duration = keys.ability:GetLevelSpecialValueFor("duration", (keys.ability:GetLevel() - 1))
	local counter = 0

	if not keys.caster:HasModifier("modifier_mei_pressence") then
		keys.ability:ApplyDataDrivenModifier(keys.caster,keys.caster,"modifier_mei_pressence",{})
	end
		if keys.ability.castCount == nil then
			keys.ability.castCount = 1
			counter = 1
		else
			keys.ability.castCount = keys.ability.castCount + 1
			counter = keys.ability.castCount
		end

		if keys.ability.castCount > max_stacks then
			counter = max_stacks
		end

		keys.caster:SetModifierStackCount("modifier_mei_pressence", keys.caster, counter * bonus_int_per_stack)


		Timers:CreateTimer(duration, function()
			keys.ability.castCount = keys.ability.castCount - 1
			if keys.ability.castCount < 1 then
				keys.caster:RemoveModifierByName("modifier_mei_pressence")
				keys.ability.castCount = 0
			else
				counter = keys.ability.castCount
				if counter > max_stacks then
					counter = max_stacks
				end
				keys.caster:SetModifierStackCount("modifier_mei_pressence", keys.caster, counter * bonus_int_per_stack)
			end

		end)
	

end