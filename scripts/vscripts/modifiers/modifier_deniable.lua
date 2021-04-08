modifier_deniable = class({})

--------------------------------------------------------------------------------

function modifier_deniable:IsHidden()
	return false
end


--------------------------------------------------------------------------------

function modifier_deniable:CheckState()
	local state = {
	[MODIFIER_STATE_SPECIALLY_DENIABLE] = true,
	}

	return state
end

--------------------------------------------------------------------------------