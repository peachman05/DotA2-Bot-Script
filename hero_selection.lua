
BotRadiantList = {"npc_dota_hero_lina",
				  "npc_dota_hero_disruptor",
				  "npc_dota_hero_antimage",
				  "npc_dota_hero_bristleback",
				  "npc_dota_hero_brewmaster"};

BotDireList = {"npc_dota_hero_axe",
				  "npc_dota_hero_bane",
				  "npc_dota_hero_bloodseeker",
				  "npc_dota_hero_crystal_maiden",
				  "npc_dota_hero_batrider"};
----------------------------------------------------------------------------------------------------

function Think()


	if ( GetTeam() == TEAM_RADIANT )
	then

		print( "selecting radiant" );
		local IDs=GetTeamPlayers(GetTeam());
		for i,id in pairs(IDs) do
			if IsPlayerBot(id) then
				SelectHero(id,BotRadiantList[i]);
			end
		end

	elseif ( GetTeam() == TEAM_DIRE )
	then

		print( "selecting dire" );
		local IDs=GetTeamPlayers(GetTeam());
		for i,id in pairs(IDs) do
			if IsPlayerBot(id) then
				SelectHero(id,BotDireList[i]);
			end
		end

	end

end

----------------------------------------------------------------------------------------------------
