function explosive_kunai_post_vision( keys )
	-- Variables
	local ability = keys.ability
	local target = keys.target_points[ 1 ]
	local duration = ability:GetLevelSpecialValueFor( "vision_duration", ( ability:GetLevel() - 1 ) )
	local radius = ability:GetLevelSpecialValueFor( "vision_radius", ( ability:GetLevel() - 1 ) )

	-- Create unit to reference the point
	ability:CreateVisibilityNode( target, radius, duration )
end