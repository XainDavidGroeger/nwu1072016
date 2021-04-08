-- Creates an Illusion, making use of the built in modifier_illusion
function ConjureImage( event )

 local caster = event.caster
 local player = caster:GetPlayerID()
 local ability = event.ability
 local unit_name = caster:GetUnitName()
 local origin = caster:GetAbsOrigin() + RandomVector(100)
 local duration = ability:GetLevelSpecialValueFor( "illusion_duration", ability:GetLevel() - 1 )
 local damage_percentage = ability:GetLevelSpecialValueFor( "damage_percentage", ability:GetLevel() - 1 )
 local illusion_max_hp_percentage = ability:GetLevelSpecialValueFor( "illusion_max_hp_percentage", ability:GetLevel()-1)

 -- particle stuff
 local particle = ParticleManager:CreateParticle("particles/units/heroes/kisame/kisame_mizu_bunshin.vpcf",PATTACH_CUSTOMORIGIN,caster)
 ParticleManager:SetParticleControl(particle,0,origin)

 -- water clone particle, spawn clones when particle is finished
 Timers:CreateTimer( 0.2, function()
	 -- handle_UnitOwner needs to be nil, else it will crash the game.
	 local illusion = CreateUnitByName("kisame_bunshin", origin, true, caster, nil, caster:GetTeamNumber())
	 illusion:SetControllableByPlayer(player, true)
	 illusion:SetOwner(caster)

	 -- illusion Graphic stuff 
	 GameMode:RemoveWearables(illusion)
	 illusion:SetForwardVector(caster:GetForwardVector())
	 illusion:SetModel(caster:GetModelName())	 
	 illusion:SetOriginalModel(caster:GetModelName())
	 illusion:SetModelScale(caster:GetModelScale())    

	 -- add water prison (channeled hold) to bunshin
	 AbilityWater = illusion:FindAbilityByName("kisame_bunshin_water_prison")
	 AbilityWater:SetAbilityIndex(0)
	 AbilityWater:SetLevel(event.ability:GetLevel())

	 -- add samehada to bunshin
	 AbilityWater = illusion:FindAbilityByName("kisame_samehada_bunshin")
	 AbilityWater:SetAbilityIndex(1)
	 AbilityWater:SetLevel(event.ability:GetLevel())

	 illusion:SetMaxHealth(caster:GetMaxHealth() / 100 * illusion_max_hp_percentage)

	 local hp_caster_percentage = caster:GetHealth() / (caster:GetMaxHealth() / 100)
	 illusion:SetHealth(illusion:GetMaxHealth() / 100 * hp_caster_percentage)

	 illusion:SetBaseDamageMin(caster:GetAverageTrueAttackDamage() / 100 * damage_percentage)
	 illusion:SetBaseDamageMax(caster:GetAverageTrueAttackDamage() / 100 * damage_percentage)

	 -- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle 
	 ability:ApplyDataDrivenModifier(caster, illusion, "modifier_water_bunshin",  {duration = duration})
	 ability:ApplyDataDrivenModifier(caster, illusion, "modifier_water_bunshin_bonus_damage",  {duration = duration})	 
	 

     return nil
    end
 )

end

--Destroys the illusion when time is gone
function RemoveBunshin(keys)	
  local dummy_modifier = keys.dummy_particle
  local dummy = CreateUnitByName("npc_dummy_unit", keys.target:GetAbsOrigin(), false, keys.caster, keys.caster, keys.caster:GetTeam())
  dummy:AddNewModifier(caster, nil, "modifier_phased", {})
  keys.ability:ApplyDataDrivenModifier(keys.caster, dummy, "modifier_bunshin", {duration = duration})
  local particle = ParticleManager:CreateParticle("particles/units/heroes/kisame/kisame_mizu_bunshin_end.vpcf",PATTACH_ABSORIGIN,dummy)  
  keys.target:Destroy()
  Timers:CreateTimer(5, function() dummy:RemoveSelf() end)
end