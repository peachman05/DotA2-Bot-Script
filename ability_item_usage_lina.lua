
----------------------------------------------------------------------------------------------------

IDLE_THINK_STATE = 1;
ATTACK_THINK_STATE = 2;
ESCAPE_THINK_STATE = 3;

think_state = 1;

-------------- attack

NORMAL_ATTACK_STATE = 0;
SKILL1_ATTACK_STATE = 1;
SKILL2_ATTACK_STATE = 2;
SKILL3_ATTACK_STATE = 3;
ESCAPE_ATTACK_STATE = 4;

attack_state = NORMAL_ATTACK_STATE;

input = {}

botMachineObj = require( "bots/Lua/botMachine" );


scriptTest = require( "bots/Lua/scriptTest" );

function AbilityUsageThink()

	

	local npcBot = GetBot();
	


	local heroEnemy = npcBot:GetNearbyHeroes(600,true,BOT_MODE_NONE);
	-- print(heroEnemy)
	for _,npcEnemy in pairs( heroEnemy )
	do

		print( npcEnemy:GetUnitName() )
	
	

		
		input['hp_me'] = npcBot:GetHealth();
		input['hp_enemy'] = npcEnemy:GetHealth();
		input['mp_me'] = npcBot:GetMana();
		input['mp_enemy'] = npcEnemy:GetMana();
		input['distance'] = GetUnitToUnitDistance(npcBot,npcEnemy);
		
		abilityDS = npcBot:GetAbilityByName( "lina_dragon_slave" );
		abilityLSA = npcBot:GetAbilityByName( "lina_light_strike_array" );	
		abilityLB = npcBot:GetAbilityByName( "lina_laguna_blade" );

		input['cooldown_s1'] = abilityDS:GetCooldownTimeRemaining()
		input['cooldown_s2'] = abilityLSA:GetCooldownTimeRemaining()
		input['cooldown_s3'] = abilityLB:GetCooldownTimeRemaining()
		input['level_s1'] = abilityDS:GetLevel()
		input['level_s2'] = abilityLSA:GetLevel()
		input['level_s3'] = abilityLB:GetLevel()

		_G.input = input


		-- for key,value in pairs( input )
		-- do
		-- 	print( key , value )

		-- end

		
		if(think_state == IDLE_THINK_STATE)
		then

			--think_state = botMachineObj:getThinkState()
			--test(input);
			print("go think_state");

			request =	CreateHTTPRequest(  ""  )
	
			print("testddd");

			-- request:SetHTTPRequestGetOrPostParameter("hp_me", tostring(input['hp_me'])  );
			-- request:SetHTTPRequestGetOrPostParameter("hp_enemy",tostring(input['hp_enemy'])  );
			-- request:SetHTTPRequestGetOrPostParameter("mp_me", tostring(input['mp_me']) );
			-- request:SetHTTPRequestGetOrPostParameter("mp_enemy",tostring(input['mp_enemy']) );
			-- request:SetHTTPRequestGetOrPostParameter("distance",tostring(input['distance']) );
			-- request:SetHTTPRequestGetOrPostParameter("level_s1",tostring(input['level_s1']) );
			-- request:SetHTTPRequestGetOrPostParameter("level_s2",tostring(input['level_s2']) );
			-- request:SetHTTPRequestGetOrPostParameter("level_s3",tostring(input['level_s3']) );
			-- request:SetHTTPRequestGetOrPostParameter("cd_s1",tostring(input['cd_s1']) );
			-- request:SetHTTPRequestGetOrPostParameter("cd_s2",tostring(input['cd_s2']) );
			-- request:SetHTTPRequestGetOrPostParameter("cd_s3",tostring(input['cd_s3']) );
			-- request:SetHTTPRequestGetOrPostParameter("mode",tostring(mode));

			print("getThinkState")
			request:Send( function( result )
		 				print( "GET response: \n")
		 				--print(result)
		 				for k,v in pairs( result ) do
		 					print( string.format( "%s : %s\n", k, v ) )
		 				end
		 
		 				for k2, v2 in pairs( v ) do
		 					print(k, v2)
		 					print(type(v2))
		 				end
		 	end )

		elseif(think_state == ATTACK_THINK_STATE)
		then
			attack_state = botMachineObj:getAttackState(input)

			if(attack_state == ESCAPE_ATTACK_STATE)
			then
				think_state = ESCAPE_THINK_STATE;
			else	
				attackEnemy(attack_state,npc,enemy)
			end
			

		elseif(think_state == ESCAPE_THINK_STATE)
		then
			--STATE = botMachineObj:getEscapeState(input)
			escape();

		end
		print("State:"..tostring(think_state) )
	end


	

end

function test(input)

	print(type(input))
	for key,value in pairs( input )
		do
			print( key , value )

		end

end


-- function attackEnemy(attack_state,npcBot,enemy)

-- 	if(attack_state == NORMAL_ATTACK_STATE)
-- 	then
-- 		npcBot:Action_AttackUnit( enemy, false )

-- 	elseif(attack_state == SKILL1_ATTACK_STATE)

-- 		abilityDS = npcBot:GetAbilityByName( "lina_dragon_slave" );
-- 		if ( abilityDS:IsFullyCastable() ) 
-- 		then
-- 			npcBot:Action_UseAbilityOnEntity(abilityDS,enemy);
-- 		end

		
-- 	 +	
-- 	elseif(attack_state == SKILL2_ATTACK_STATE)

-- 		abilityLSA = npcBot:GetAbilityByName( "lina_light_strike_array" );
-- 		if ( abilityLSA:IsFullyCastable() ) 
-- 		then
-- 			npcBot:Action_UseAbilityOnEntity(abilityLSA,enemy);
-- 		end

-- 	elseif(attack_state == SKILL3_ATTACK_STATE)

-- 		abilityLB = npcBot:GetAbilityByName( "lina_laguna_blade" );
-- 		if ( abilityLB:IsFullyCastable() ) 
-- 		then
-- 			npcBot:Action_UseAbilityOnEntity(abilityLB,enemy);
-- 		end

-- 	end

-- end

-- function escape()


-- end

