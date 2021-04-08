LinkLuaModifier("modifier_chronosphere_speed_lua", "heroes/hero_faceless_void/modifiers/modifier_chronosphere_speed_lua.lua", LUA_MODIFIER_MOTION_NONE)

--[[Author: LearningDave
	Date: 22.10.2015
	Creates a dummy at the target location that acts as the Fog
	]]
function Chronosphere( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local target_point = keys.target_points[1]
	keys.ability.castPoint = target_point
	-- Special Variables
	local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() - 1))

	-- Dummy
	local dummy_modifier = keys.dummy_aura
	local dummy = CreateUnitByName("npc_dummy_unit", target_point, false, caster, caster, caster:GetTeam())
	dummy:AddNewModifier(caster, nil, "modifier_phased", {})
	ability:ApplyDataDrivenModifier(caster, dummy, dummy_modifier, {duration = duration})


	-- Timer to remove the dummy
	Timers:CreateTimer(duration, function() dummy:RemoveSelf() end)
end

function applyModifier( keys )
	local caster = keys.caster
	local ability = keys.ability
	local mr_reduction = ability:GetLevelSpecialValueFor("mr_reduction", (ability:GetLevel() - 1))
	local radius = ability:GetLevelSpecialValueFor("radius", (ability:GetLevel() - 1))
	local targetEntities = FindUnitsInRadius(caster:GetTeamNumber(), keys.ability.castPoint, nil, 1000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
 
	if targetEntities then
		for _,target in pairs(targetEntities) do
			if not target:HasModifier("modifier_mei_komu_mr_reduction") then
				ability:ApplyDataDrivenModifier(caster,target,"modifier_mei_komu_mr_reduction",{})
				target:SetModifierStackCount("modifier_mei_komu_mr_reduction",ability, mr_reduction)
			end
		end
	end
end


function reduceMR( keys )
	local ability = keys.ability
	local target = keys.target
	local mr_remove_per_second = ability:GetLevelSpecialValueFor("mr_remove_per_second", (ability:GetLevel() - 1))
	local StackCount = keys.target:GetModifierStackCount("modifier_mei_komu_mr_reduction", keys.ability)
	if StackCount <= 0 then
		target:RemoveModifierByName("modifier_mei_komu_mr_reduction")
	else
		target:SetModifierStackCount("modifier_mei_komu_mr_reduction",ability, StackCount - mr_remove_per_second)
	end


	local StackCount = keys.target:GetModifierStackCount("modifier_mei_komu_mr_reduction", keys.ability)
	if StackCount <= 0 then
		target:RemoveModifierByName("modifier_mei_komu_mr_reduction")
	end
end