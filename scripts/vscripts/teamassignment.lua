function GameMode:assignRanked()
  --GameMode:balanceAndAssignTeams()
	PlayerResource:SetCustomTeamAssignment(0, 6)
  PlayerResource:SetCustomTeamAssignment(1, 2)
  PlayerResource:SetCustomTeamAssignment(2, 2)
  PlayerResource:SetCustomTeamAssignment(3, 2)
  PlayerResource:SetCustomTeamAssignment(4, 2)
  PlayerResource:SetCustomTeamAssignment(5, 2)
  PlayerResource:SetCustomTeamAssignment(6, 3)
  PlayerResource:SetCustomTeamAssignment(7, 3)
  PlayerResource:SetCustomTeamAssignment(8, 3)
  PlayerResource:SetCustomTeamAssignment(9, 3)
  PlayerResource:SetCustomTeamAssignment(10, 3)
end

function GameMode:assignRankedPlayer(playerId, teamId)
  PlayerResource:SetCustomTeamAssignment(playerId, teamId)
end

function GameMode:assignDuel(  )
  PlayerResource:SetCustomTeamAssignment(0, 2)
  PlayerResource:SetCustomTeamAssignment(1, 3)
end

function GameMode:assignDota(  )
	PlayerResource:SetCustomTeamAssignment(0, 2)
    PlayerResource:SetCustomTeamAssignment(1, 2)
    PlayerResource:SetCustomTeamAssignment(2, 2)
    PlayerResource:SetCustomTeamAssignment(3, 2)
    PlayerResource:SetCustomTeamAssignment(4, 2)
    PlayerResource:SetCustomTeamAssignment(5, 3)
    PlayerResource:SetCustomTeamAssignment(6, 3)
    PlayerResource:SetCustomTeamAssignment(7, 3)
    PlayerResource:SetCustomTeamAssignment(8, 3)
    PlayerResource:SetCustomTeamAssignment(9, 3)
end

function assignRankedMMR( keys )
	PlayerResource:SetCustomTeamAssignment(0, 6)
    PlayerResource:SetCustomTeamAssignment(1, 6)

    --json result example
    --{
  	--"1": [
    --"steamid": 133943769,
  	--],
  --"2": [
    --"steamid": 133943769,
  --],
  --"3": [
    --"steamid": 133943769,
  --],
  --"4": [
    --"steamid": 133943769,
  --],
  --"5": [
    --"steamid": 133943769,
  --],
  --"6": [
    --"steamid": 133943769,
  --],
  --"7": [
    --"steamid": 133943769,
  --],
  --"8": [
    --"steamid": 133943769,
  --],
  --"9": [
    --"steamid": 133943769,
  --],
  --"10": [
   -- "steamid": 133943769,
  --],
--}

    local request = CreateHTTPRequest("GET", "https://euw.api.pvp.net/api/lol/euw/v1.4/summoner/by-name/eGloryDave?api_key=d3c42ab3-5db9-46ac-9b8b-d12024364f29")
    print("WebAPI sending request, path: ")
    request:Send(function(result)
        if not result or result.StatusCode ~= 200 then
            print("WebAPI receive failed")
            print(result.StatusCode)
            return
        end
         result_data = JSON:decode(result.Body)
         PrintTable(result_data)
         for playerID=2,12 do
			if PlayerResource:IsValidPlayerID(playerID) then
				local player = PlayerResource:GetPlayer(playerID)
				print(PlayerResource:GetSteamID(playerID))
				print(PlayerResource:GetSteamAccountID(playerID))
				print(playerID)
				local index = 0
				for _,oneResult in pairs(result_data) do 
					if PlayerResource:GetSteamAccountID(playerID) == oneResult['steamid'] then
						if index < 5 then
							PlayerResource:SetCustomTeamAssignment(playerID, 2)
						else 
							PlayerResource:SetCustomTeamAssignment(playerID, 3)
						end
					end
					index = index + 1
				end

			end
		end

    end)
end


function GameMode:balanceAndAssignTeams()
  
   local bot_id =  PlayerResource:GetSteamAccountID(0)
   print(bot_id)
   local request = CreateHTTPRequest("GET", "http://localhost/nwr/rest/index.php/loadingMatchByBot/" .. bot_id)
      print("WebAPI sending request, path: ")
      request:Send(function(result)
          if not result or result.StatusCode ~= 200 then
              print("WebAPI receive failed")
              print(result.StatusCode)
              return
          end
    
          result_data = JSON:decode(result.Body)
          --PrintTable(result_data)
          print(result_data[1]['steamid'])

          for key,onePlayer in pairs(result_data) do 
            print(onePlayer['mmr_old'])
          end

          local team_one_player_ids = {}
          local team_one_mmr_list = {}
          local team_two_mmr_list = {}
          local team_two_player_ids = {}
          local mmr_difference = 10
          local accepted = 1

      while mmr_difference > accepted do
        team_one_player_ids = {}
        team_two_player_ids = {}
        team_one_mmr_list = {}
        team_two_mmr_list = {}
        local taken_slots = {}
        local team_one_mmr = 0
        local team_two_mmr = 0
        accepted = accepted + 0.05
        
        for i=1, 10 do
          local random = math.random(1, 10)
          while tableContains(taken_slots, random) do
            random = math.random(1,10)
          end
          table.insert(taken_slots, random)
        end

        for i=1, 5 do
          team_one_mmr = team_one_mmr + result_data[taken_slots[i]]['mmr_old']
          table.insert(team_one_player_ids,  taken_slots[i])
          table.insert(team_one_mmr_list,  result_data[taken_slots[i]]['mmr_old'])
        end

        for i=6, 10 do
          team_two_mmr = team_two_mmr + result_data[taken_slots[i]]['mmr_old']
          table.insert(team_two_player_ids,  taken_slots[i])
          table.insert(team_two_mmr_list,  result_data[taken_slots[i]]['mmr_old'])
        end

        mmr_difference = team_one_mmr - team_two_mmr

        if mmr_difference < 0 then
          mmr_difference = -1 * mmr_difference
        end

        print("MMR Difference: " .. mmr_difference)
        print("Accepted: " .. accepted)

      end
          
      PrintTable(team_one_player_ids)
      PrintTable(team_two_player_ids)

      for i=1, 5 do
        PlayerResource:SetCustomTeamAssignment(2, team_one_player_ids[i])
        PlayerResource:SetCustomTeamAssignment(2, team_one_player_ids[i])
        PlayerResource:SetCustomTeamAssignment(2, team_one_player_ids[i])
        PlayerResource:SetCustomTeamAssignment(2, team_one_player_ids[i])
        PlayerResource:SetCustomTeamAssignment(2, team_one_player_ids[i])
      end

      for i=1, 5 do
        PlayerResource:SetCustomTeamAssignment(3, team_two_player_ids[i])
        PlayerResource:SetCustomTeamAssignment(3, team_two_player_ids[i])
        PlayerResource:SetCustomTeamAssignment(3, team_two_player_ids[i])
        PlayerResource:SetCustomTeamAssignment(3, team_two_player_ids[i])
        PlayerResource:SetCustomTeamAssignment(3, team_two_player_ids[i])
      end
    end)
 end 


