function GameMode:kyuubiHelp(teamnumber, owner)

	if teamnumber == 2 then

		JUUBI_ONE = JUUBI_ONE + 1
		Notifications:TopToAll({text="Juubi joins the shinobi alliance and pushes the midlane!", duration=8.0, style={color="#B2B2B2",  fontSize="50px;"}})
	else
		JUUBI_TWO = JUUBI_TWO + 1
		Notifications:TopToAll({text="Juubi joins the akatsuki force and pushes the midlane!", duration=8.0, style={color="#B2B2B2",  fontSize="50px;"}})
	end
	
	local mid     = Entities:FindByName(nil, "kyuubi_midlane"):GetAbsOrigin()
    local konoha        = Entities:FindByName(nil, "kyuubi_konoha_spawner"):GetAbsOrigin()
	local akat        = Entities:FindByName(nil, "kyuubi_akat_spawner"):GetAbsOrigin()

	local kono_1     = Entities:FindByName(nil, "konoha_tower_1"):GetAbsOrigin()
	local kono_2     = Entities:FindByName(nil, "konoha_tower_2"):GetAbsOrigin()
	local kono_3     = Entities:FindByName(nil, "konoha_tower_3"):GetAbsOrigin()

	local akat_1     = Entities:FindByName(nil, "akat_tower_1"):GetAbsOrigin()
	local akat_2     = Entities:FindByName(nil, "akat_tower_2"):GetAbsOrigin()
	local akat_3     = Entities:FindByName(nil, "akat_tower_3"):GetAbsOrigin()

    local path = nil
	local spawner = nil
	if teamnumber == 2 then
		 path    = {akat_1, akat_2, akat_3, akat}
		 spawner = Entities:FindByName(nil, "kyuubi_konoha_spawner")
	else
		 spawner = Entities:FindByName(nil, "kyuubi_akat_spawner")
		 path   = {kono_1, kono_2, kono_3, konoha}
	end
	local kyuubi = "npc_dota_roshan_datadriven"
	if IsValidEntity(spawner) then -- Only spawn units from which spawner is alive
				Timers:CreateTimer(function()
					local unit = CreateUnitByName(kyuubi, spawner:GetAbsOrigin(), true, owner, owner, teamnumber)
					unit:SetTeam(teamnumber)

					for j = 0, #path do 
						ExecuteOrderFromTable({
							UnitIndex = unit:GetEntityIndex(),
							OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
							Position = path[j],
							Queue = true
						})
					end
				end)
	end
end