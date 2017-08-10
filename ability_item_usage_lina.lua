
----------------------------------------------------------------------------------------------------

IDLE_THINK_STATE = 1;
ATTACK_THINK_STATE = 2;
ESCAPE_THINK_STATE = 3;

think_state = 1;

_G.dataReturn = 1;

-------------- attack

NORMAL_ATTACK_STATE = 100;
SKILL1_ATTACK_STATE = 101;
SKILL2_ATTACK_STATE = 102;
SKILL3_ATTACK_STATE = 103;
ESCAPE_ATTACK_STATE = 104;

attack_state = NORMAL_ATTACK_STATE;

input = {}
npcBot = GetBot();

botMachineObj = require( "bots/Lua/botMachine" );


scriptTest = require( "bots/Lua/scriptTest" );

function AbilityUsageThink()

	
	
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

		-- print( tostring(  npcEnemy:GetAbilityByName("lina_dragon_slave"):GetLevel() )  )
		-- print( tostring(  npcEnemy:GetAbilityByName("lina_light_strike_array"):GetLevel() )  )
		-- print( tostring(  npcEnemy:GetAbilityByName("lina_laguna_blade"):GetLevel() )  )

		_G.input = input


		-- for key,value in pairs( input )
		-- do
		-- 	print( key , value )

		-- end

		if( _G.dataReturn ~= 0)
		then
				think_state = _G.dataReturn;
				if(think_state == IDLE_THINK_STATE)
				then

					botMachineObj:getThinkState()
				

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


	

end


function AbilityLevelUpThink()

	 -- print("Poit  ".. tostring(npcBot:GetAbilityPoints()));
	  if (npcBot:GetAbilityPoints() > 0) then  

	  		abilityDS = npcBot:GetAbilityByName( "lina_dragon_slave" );
	  		abilityLSA = npcBot:GetAbilityByName( "lina_light_strike_array" );
	  		print("Get "..tostring(abilityLSA:GetLevel()).." Max"..tostring(abilityLSA:GetMaxLevel()) .. "Can"..tostring(abilityLSA:CanAbilityBeUpgraded()))
	  		if( abilityLSA:CanAbilityBeUpgraded() and ( abilityLSA:GetLevel() < abilityLSA:GetMaxLevel() ) )
	  		then 
                
                 GetBot():ActionImmediate_LevelAbility("lina_light_strike_array" ); 

            elseif(  abilityDS:CanAbilityBeUpgraded() and ( abilityDS:GetLevel() < abilityDS:GetMaxLevel() ) )
            	 then
                 GetBot():ActionImmediate_LevelAbility("lina_dragon_slave" ); 

            end  	

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

