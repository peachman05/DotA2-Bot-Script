
dkjson = require( "game/dkjson" )
ability_item_usage_lich = require( "bots/ability_item_usage_lich" );


npcBot = GetBot();


GO_TOWER_STATE = 1;
FOLLOW_CREEP_STATE = 2;
LANING_STATE = 3;

STATE = GO_TOWER_STATE;



previous_lasthit = 0;
current_lasthit = 0;

rewardAll = 0;
maxRewardMean = 0; 
countRound = 0;  -- 10 round

checkUpdate = false;

maxParameter = {}
parameter = {}
parameter['hp_weight'] = 0
parameter['distance_weight'] = 0
parameter['baseDamage_weight'] = 0
parameter['attackSpeed_weight'] = 0
parameter['creepDamageTaken_weight'] = 0





-- damageCreepTaken = {}


firstMidTower = GetTower(TEAM_RADIANT,TOWER_MID_1)

function Think()

	if(npcBot:IsAlive() == false)then 
		-- print("hero is dead");
		STATE = GO_TOWER_STATE;
	end

	-- print("test lich")
	if( STATE == GO_TOWER_STATE and npcBot:IsAlive() )then

		-- npcBot:ActionImmediate_LevelAbility("lich_frost_nova");

		npcBot:Action_MoveToUnit( firstMidTower );
		-- print("go to state FOLLOW_CREEP_STATE")
		STATE = FOLLOW_CREEP_STATE;

	elseif( STATE == FOLLOW_CREEP_STATE )then

		creeps = npcBot:GetNearbyLaneCreeps(1600,false);

		if( tablelength(creeps) > 0 )then

			npcBot:Action_MoveToUnit( creeps[1] );
			-- print(creeps[1])

			if( tablelength(npcBot:GetNearbyLaneCreeps(900,true) ) > 0 )then

				STATE = LANING_STATE;
				-- print("go to state LANING_STATE")

			end


		end
		

	elseif( STATE == LANING_STATE )then

		creepsEnemy = npcBot:GetNearbyLaneCreeps(900,true);
		creepsAlly = npcBot:GetNearbyLaneCreeps(900,false);

		if(npcBot:WasRecentlyDamagedByCreep(1) or tablelength( creepsAlly ) == 1 )then

			STATE = GO_TOWER_STATE

		elseif( tablelength( creepsEnemy ) == 0 )then

			STATE = FOLLOW_CREEP_STATE

		else

			for iEnemy,creepEnemy in pairs(creepsEnemy) do

				hpCreepEnemy = creepEnemy:GetHealth() 
				baseDmageHero = npcBot:GetAttackDamage()

				if( hpCreepEnemy  < baseDmageHero + 80 )then				

					countAttack = 0 ;
					sumAttack = 0;

					for iAlly,creepAlly in pairs(creepsAlly) do
						if( creepAlly:GetAttackTarget() == creepEnemy )then
							sumAttack = sumAttack + creepAlly:GetAttackDamage() ; 
							countAttack = countAttack + 1 ;
						end
					end

					action = nil
					hpDesire = parameter['hp_weight'] * hpCreepEnemy;
					distanceDesire = parameter['distance_weight'] * GetUnitToUnitDistance(creepEnemy,npcBot) ;
					baseDamageDesire = parameter['baseDamage_weight'] * baseDmageHero;
					attackSpeedDesire = parameter['attackSpeed_weight'] * npcBot:GetSecondsPerAttack();
					damageTakenDesire = parameter['creepDamageTaken_weight'] * sumAttack;

					valueDesire = hpDesire + distanceDesire + baseDamageDesire + attackSpeedDesire + damageTakenDesire;
					
					if(valueDesire < 0 )then -- stop

						npcBot:Action_ClearActions(true);

					else  -- attack

						npcBot:Action_AttackUnit(creepEnemy,true)

					end

					

				end				

			end
		end

	end



	time = DotaTime()
	-- print("Time :"..time.." Time mod "..time%30)

	timemod = time % 30
	if( time >= 0 and  timemod >= 0  and timemod <= 0.1 and checkUpdate == false)then

		checkUpdate = true;

		-- print("STATE :"..STATE)
		print("Count :"..countRound.."Time :"..time.."rewardAll :"..rewardAll)



		current_lasthit = npcBot:GetLastHits();
		rewardAll = rewardAll + (current_lasthit - previous_lasthit) ;
		previous_lasthit = current_lasthit;
		print(rewardAll)


		if(countRound == 9)then

			if( rewardAll > maxRewardMean)then

				maxParameter = parameter;
				maxRewardMean = rewardAll;

				print("best param :"..maxRewardMean)
				-- print(maxParameter)
				for key,value in pairs(maxParameter) do
					print(key.." "..value)

				end

			end

			rewardAll = 0;
			randomParameter();
			-- countRound = 0;


		end

		countRound = (countRound + 1) % 10;


		-- request = CreateHTTPRequest(":8080" )
		-- request:SetHTTPRequestHeaderValue("Accept", "application/json")		
		-- request:SetHTTPRequestRawPostBody('application/json', dkjson.encode(data))
		-- request:Send( 	function( result ) 
		-- 					  --for k,v in pairs( result ) do
		-- 			              if result["StatusCode"] == 200  then  
		-- 								  print( result['Body'] )
		-- 			              end
		-- 			          --end
		-- 				end )	

		
		
	end 

	if( timemod > 2)then
		checkUpdate = false;
	end
	   

end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end


function randomParameter()

	parameter['hp_weight'] = math.random()
	parameter['distance_weight'] = math.random()
	parameter['baseDamage_weight'] = math.random()
	parameter['attackSpeed_weight'] = math.random()
	parameter['creepDamageTaken_weight'] = math.random()

end 