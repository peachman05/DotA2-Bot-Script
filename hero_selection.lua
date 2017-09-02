
BotRadiantList = {"npc_dota_hero_axe",
				  "npc_dota_hero_axe",
				  "npc_dota_hero_lich",
				  "npc_dota_hero_axe",
				  "npc_dota_hero_axe"};

BotDireList = {"npc_dota_hero_axe",
				  "npc_dota_hero_bane",
				  "npc_dota_hero_axe",
				  "npc_dota_hero_crystal_maiden",
				  "npc_dota_hero_batrider"};
----------------------------------------------------------------------------------------------------

function Think()


	if ( GetTeam() == TEAM_RADIANT )
	then

		-- print( "selecting radiant" );
		local IDs=GetTeamPlayers(GetTeam());
		for i,id in pairs(IDs) do
			if IsPlayerBot(id) then
				SelectHero(id,BotRadiantList[i]);
			end
		end

	elseif ( GetTeam() == TEAM_DIRE )
	then

		-- print( "selecting dire" );
		local IDs=GetTeamPlayers(GetTeam());
		for i,id in pairs(IDs) do
			if IsPlayerBot(id) then
				SelectHero(id,BotDireList[i]);
			end
		end

	end

end

function UpdateLaneAssignments()

	

	if ( GetTeam() == TEAM_RADIANT ) then

		table = {}
		IDs=GetTeamPlayers(TEAM_RADIANT);
		for i,id in pairs(IDs) do
			if IsPlayerBot(id) then
				if( GetSelectedHeroName(id) == "npc_dota_hero_lich" )then
					table[i] = LANE_MID;
					-- print(tostring(id).." mid");
				else
					table[i] = LANE_TOP;
					-- print(tostring(id).." top");
				end

			end
		end

		return table;

	elseif ( GetTeam() == TEAM_DIRE ) then
		
		table = {}
		IDs=GetTeamPlayers(TEAM_DIRE);
		for i,id in pairs(IDs) do
			if IsPlayerBot(id) then
				if( GetSelectedHeroName(id) == "npc_dota_hero_lich" )then
					table[i] = LANE_MID;
					-- print(tostring(id).." mid");
				else
					table[i] = LANE_TOP;
					-- print(tostring(id).." top");
				end

			end
		end

		return table;

	end


end

----------------------------------------------------------------------------------------------------
