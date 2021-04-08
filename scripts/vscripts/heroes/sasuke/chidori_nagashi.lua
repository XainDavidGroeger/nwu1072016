function playSound( keys )
	local random = math.random(1, 2)
	if random == 1 then
		EmitSoundOn("sasuke_nagashi",keys.caster)
	elseif random == 2 then
		EmitSoundOn("sasuke_nagashi_2",keys.caster)
	end
end