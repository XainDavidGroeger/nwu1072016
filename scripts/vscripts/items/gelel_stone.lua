--[[ ============================================================================================================
	Author: Rook, SkFoRZa
	Date: January 29, 2015
	Called when Black King Bar is created.  Since BKB's level is tied to the player, not the item, set it to the
	appropriate level.
================================================================================================================= ]]
function modifier_item_black_king_bar_datadriven_on_created(keys)	
	if keys.caster.BKBLevel ~= nil and keys.caster.BKBLevel ~= keys.ability:GetLevel() then
		keys.ability:SetLevel(keys.caster.BKBLevel)
	end
end

--[[ ============================================================================================================
	Author: Rook, with some of Noya's code for model scaling, SkFoRZa
	Date: January 29, 2015
	Called when Black King Bar is cast.  Applies the modifier and then updates the cooldown and duration for future casts.
	Additional parameters: keys.MaxLevel, keys.PercentageOverModelScale, and keys.Duration
================================================================================================================= ]]
function item_black_king_bar_datadriven_on_spell_start(keys)
	original_model_scale = keys.caster:GetModelScale();
	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_black_king_bar_datadriven_active", nil)
	keys.caster:EmitSound("DOTA_Item.BlackKingBar.Activate")	
	local duration  = keys.ability:GetLevelSpecialValueFor("duration", keys.ability:GetLevel() - 1)	
	--Level up BKB so future casts will use an updated cooldown and duration.
	local current_level = keys.ability:GetLevel()
	if current_level + 1 <= keys.MaxLevel then
		keys.ability:SetLevel(current_level + 1)
		keys.caster.BKBLevel = current_level + 1  --BKB's level is tied to the player, not the item, so store it here.
		
		local i = nil
		for i=0, 11, 1 do  --Level up any other BKBs in the player's inventory or stash to match the new level.
			local current_item = keys.caster:GetItemInSlot(i)
			if current_item ~= nil then
				if current_item:GetName() == "item_black_king_bar_datadriven" and current_item:GetLevel() ~= keys.caster.BKBLevel then
					current_item:SetLevel(keys.caster.BKBLevel)
				end
			end
		end
	end

	local final_model_scale = (original_model_scale * keys.PercentageOverModelScale / 100) + original_model_scale
	local model_scale_increase_per_interval = (final_model_scale - original_model_scale) / 100

	--Scale the model up over time.
	local i = nil
	for i=1,100 do
		Timers:CreateTimer(i/75,
		function()
			keys.caster:SetModelScale(keys.caster:GetModelScale() + model_scale_increase_per_interval)
		end)
	end
end

function modifier_item_black_king_bar_datadriven_on_destroy(keys)	
	--Scale the model down over time.
	-- Fix for those heroes with model swap with different scale. Dirty as fuck
	if string.find(keys.caster:GetModelName(),"kisame.vmdl") ~= nil then
		original_model_scale = 2.2					
	else
		if string.find(keys.caster:GetModelName(),"kisame_samehada.vmdl") ~= nil then
			original_model_scale = 0.7
		end
	end	
	-- End dirty fix
	local model_scale_decrease_per_interval = (keys.caster:GetModelScale() - original_model_scale) / 100 -- Global because we need it to rescale back
	
	local i = nil
	for i=1,100 do
		Timers:CreateTimer(i/75, 
		function()
			keys.caster:SetModelScale(keys.caster:GetModelScale() - model_scale_decrease_per_interval)
		end)
	end	
end

