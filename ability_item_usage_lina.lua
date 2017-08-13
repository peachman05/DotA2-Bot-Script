
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


-------------- get damage
ENEMY_NOT_USE_ABILITY = 201;
ENEMY_USE_ABILITY = 202;

enemy_attack = ENEMY_NOT_USE_ABILITY;

time_attack = 0;

-----------------------

hAbilityAttack = nil;

skill_cooldown = { 0 , 0 , 0 , 0}
cooldown_lina = {}
cooldown_lina[1] = {8,8,8}
cooldown_lina[2] = {7,7,7}
cooldown_lina[3] = {70,60,50}

hp_bot_old = 0;

skillName = {"lina_dragon_slave","lina_light_strike_array","lina_laguna_blade"}
coolDownArray = {"cd_s1","cd_s2","cd_s3"}

input = {}
inputTrain = {}
npcBot = GetBot();


botMachineObj = require( "bots/Lua/botMachine" );


scriptTest = require( "bots/Lua/scriptTest" );

function AbilityUsageThink()


	local heroEnemy = npcBot:GetNearbyHeroes(1000,true,BOT_MODE_NONE);
	-- print(heroEnemy)
	for _,npcEnemy in pairs( heroEnemy )
	do

		--print( npcEnemy:GetUnitName() )
		
		----------------------  Train Data
		if(npcEnemy:GetUnitName() == "npc_dota_hero_lina" )then

			if(  npcEnemy:IsCastingAbility() == true )
			then

				print("Use Skill");
				hAbilityAttack = npcEnemy:GetCurrentActiveAbility();
				time_attack = GameTime();
				enemy_attack =  ENEMY_USE_ABILITY;

				if( hAbilityAttack:GetName() == "lina_dragon_slave" )then
					
					skill_cooldown[1] = timeSecNow;	

				elseif( hAbilityAttack:GetName() == "lina_light_strike_array" )then
					
					skill_cooldown[2] = timeSecNow;

				elseif( hAbilityAttack:GetName() == "lina_laguna_blade" )then
					
					skill_cooldown[3] = timeSecNow;

				end

			end -- end check cast spell
				

			
			time = npcBot:TimeSinceDamagedByHero(npcEnemy)
			timeSecNow = GameTime();

			if(  npcEnemy:GetUnitName() == "npc_dota_hero_lina" and time < 0.05 )
			then
				

				inputTrain['hp_me'] = npcEnemy:GetHealth();
				inputTrain['hp_enemy'] = hp_bot_old;
				--inputTrain['mp_me'] = mp_enemy_old;
				inputTrain['mp_enemy'] = npcBot:GetMana();
				inputTrain['distance'] = GetUnitToUnitDistance(npcBot,npcEnemy);
				


				local abilityArray = {}

				abilityArray[1] = npcEnemy:GetAbilityByName( "lina_dragon_slave" );
				abilityArray[2] = npcEnemy:GetAbilityByName( "lina_light_strike_array" );	
				abilityArray[3] = npcEnemy:GetAbilityByName( "lina_laguna_blade" );

				inputTrain['level_s1'] = abilityArray[1]:GetLevel();
				inputTrain['level_s2'] = abilityArray[2]:GetLevel();
				inputTrain['level_s3'] = abilityArray[3]:GetLevel();


				if( enemy_attack == ENEMY_USE_ABILITY and timeSecNow - time_attack < 1  )then -- use skill

					print( hAbilityAttack:GetName() );

					for i=1,3 do  
						if( hAbilityAttack:GetName() ~= skillName[i] )then -- This ability don't use
							inputTrain[coolDownArray[i]] = calCoolDown(i , abilityArray[i]:GetLevel() ,timeSecNow );
						else
							inputTrain[coolDownArray[i]] = 0 ;
							inputTrain['output'] = NORMAL_ATTACK_STATE + i ;
							inputTrain['mp_me'] = npcEnemy:GetMana() + abilityArray[i]:GetManaCost();
						end

						--print("Cooldown"..tostring(i).." Remain:"..tostring(inputTrain[coolDownArray[i]]));

					end
				
					
				else
					print("Normal Damage");

					inputTrain['cd_s1'] = calCoolDown(1 , abilityArray[1]:GetLevel() ,timeSecNow );	
					inputTrain['cd_s2'] = calCoolDown(2 , abilityArray[1]:GetLevel() ,timeSecNow );
					inputTrain['cd_s3'] = calCoolDown(3 , abilityArray[1]:GetLevel() ,timeSecNow );
					inputTrain['output'] = NORMAL_ATTACK_STATE

					inputTrain['mp_me'] = npcEnemy:GetMana();

					damageTaken = npcBot:GetActualIncomingDamage(npcEnemy:GetAttackDamage(),DAMAGE_TYPE_PHYSICAL) ;
					-- inputTrain['hp_enemy'] = npcBot:GetHealth() + damageTaken;
					-- print( "Damage Taken"..tostring(npcBot:GetActualIncomingDamage(npcEnemy:GetAttackDamage(),DAMAGE_TYPE_PHYSICAL) ) );

				end 

				_G.inputTrain = inputTrain;

				botMachineObj:trainAttackState();
				enemy_attack =  ENEMY_NOT_USE_ABILITY;

			else

				hp_bot_old =  npcBot:GetHealth();


			end  -- end check damage

		end


		---------------------- predict

		input['hp_me'] = npcBot:GetHealth();
		input['hp_enemy'] = npcEnemy:GetHealth();
		input['mp_me'] = npcBot:GetMana();
		input['mp_enemy'] = npcEnemy:GetMana();
		input['distance'] = GetUnitToUnitDistance(npcBot,npcEnemy);
		
		abilityDS = npcBot:GetAbilityByName( "lina_dragon_slave" );
		abilityLSA = npcBot:GetAbilityByName( "lina_light_strike_array" );	
		abilityLB = npcBot:GetAbilityByName( "lina_laguna_blade" );

		input['cd_s1'] = abilityDS:GetCooldownTimeRemaining()
		input['cd_s2'] = abilityLSA:GetCooldownTimeRemaining()
		input['cd_s3'] = abilityLB:GetCooldownTimeRemaining()
		input['level_s1'] = abilityDS:GetLevel()
		input['level_s2'] = abilityLSA:GetLevel()
		input['level_s3'] = abilityLB:GetLevel()



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

					--botMachineObj:getThinkState()
				

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
				--print("State:"..tostring(think_state) )
		end

	end


	

end


function AbilityLevelUpThink()

	 -- print("Poit  ".. tostring(npcBot:GetAbilityPoints()));
	  if (npcBot:GetAbilityPoints() > 0) then  

	  		abilityDS = npcBot:GetAbilityByName( "lina_dragon_slave" );
	  		abilityLSA = npcBot:GetAbilityByName( "lina_light_strike_array" );
	  	--	print("Get "..tostring(abilityLSA:GetLevel()).." Max"..tostring(abilityLSA:GetMaxLevel()) .. "Can"..tostring(abilityLSA:CanAbilityBeUpgraded()))
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


function calCoolDown(numberSkill , levelSkill , timeSecNow )

	if( levelSkill > 0 )then
		timePassSec = timeSecNow - skill_cooldown[numberSkill] ;

		cooldownRemain = cooldown_lina[numberSkill][levelSkill] - timePassSec  ;


		if( cooldownRemain < 0 )then
			cooldownRemain = 0;
		end

		return cooldownRemain;
	else

		return 0;
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

