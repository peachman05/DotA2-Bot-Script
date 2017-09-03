
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
parameter['hp_weight'] = -0.83805749760029-- max basedamage + 180 = 250 
parameter['distance_weight'] = 0.32221439199044 -- max 900
parameter['baseDamage_weight'] = -0.32133317719315-- max 60
-- parameter['attackSpeed_weight'] = 0.70539834412996 -- max 1.5 
parameter['creepDamageTaken_weight'] = 0.47147806006616-- max 100
parameter['maxReward'] = 0
-- parameter['bias'] = 1000 -- 0 1300


-- [VScript] best param :25
-- [VScript] distance_weight 0.054892783198761
-- [VScript] creepDamageTaken_weight 0.17595799685588
-- [VScript] hp_weight 0.11446190140255
-- [VScript] attackSpeed_weight 0.70539834412996
-- [VScript] baseDamage_weight 0.97416291350284


-- damageCreepTaken = {}


firstMidTower = GetTower(TEAM_RADIANT,TOWER_MID_1)
towerLocation = firstMidTower:GetLocation()

function Think()

	if(npcBot:IsAlive() == false)then 
		-- print("hero is dead");
		STATE = GO_TOWER_STATE;
	end

	-- print("test lich")
	if( STATE == GO_TOWER_STATE and npcBot:IsAlive() )then

		print("go tower ")

		-- npcBot:ActionImmediate_LevelAbility("lich_frost_nova");
		npcBot:Action_MoveToLocation( towerLocation );
		-- npcBot:Action_MoveToUnit( firstMidTower );

		-- if()
		-- print("go to state FOLLOW_CREEP_STATE")
		STATE = FOLLOW_CREEP_STATE;

	elseif( STATE == FOLLOW_CREEP_STATE )then

		creeps = npcBot:GetNearbyLaneCreeps(1600,false);

		if( tablelength(creeps) > 1 )then

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

		if( npcBot:WasRecentlyDamagedByCreep(1) or tablelength( creepsAlly ) == 0 )then   

			STATE = GO_TOWER_STATE

		elseif( tablelength( creepsEnemy ) == 0 )then

			STATE = FOLLOW_CREEP_STATE

		else

			for iEnemy,creepEnemy in pairs(creepsEnemy) do

				hpCreepEnemy = creepEnemy:GetHealth() 
				baseDmageHero = npcBot:GetAttackDamage()

				if( hpCreepEnemy  < baseDmageHero + 150 )then				

					countAttack = 0 ;
					sumAttack = 0;

					for iAlly,creepAlly in pairs(creepsAlly) do
						if( creepAlly:GetAttackTarget() == creepEnemy )then
							sumAttack = sumAttack + creepAlly:GetAttackDamage() ; 
							countAttack = countAttack + 1 ;
						end
					end

					action = nil
					hpDesire = parameter['hp_weight'] * normalizeValue(hpCreepEnemy,1,250 );
					distanceDesire = parameter['distance_weight'] * normalizeValue( GetUnitToUnitDistance(creepEnemy,npcBot),0,900 ) ;
					baseDamageDesire = parameter['baseDamage_weight'] * normalizeValue( baseDmageHero,47,125 );
					-- attackSpeedDesire = parameter['attackSpeed_weight'] * normalizeValue( npcBot:GetSecondsPerAttack(), );
					damageTakenDesire = parameter['creepDamageTaken_weight'] * normalizeValue(sumAttack,0,100);

					valueDesire = hpDesire + distanceDesire + baseDamageDesire  + damageTakenDesire;
					
					
					sigmoidValue = sigmoid(valueDesire);

					-- print("Value :"..valueDesire.."sigmoid :"..sigmoidValue)

					if(valueDesire < 0 )then -- stop

						npcBot:Action_ClearActions(true);
						-- print("stop attack")

					else  -- attack

						npcBot:Action_AttackUnit(creepEnemy,true)
						-- print("attack!")

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
		npcBot:ActionImmediate_Chat( "Count :"..countRound.."Time :"..time.."rewardAll :"..rewardAll , false )



		current_lasthit = npcBot:GetLastHits();
		rewardAll = rewardAll + (current_lasthit - previous_lasthit) ;
		previous_lasthit = current_lasthit;
		-- print(rewardAll)


		if(countRound == 9)then

			if( rewardAll > maxRewardMean)then

				maxParameter = parameter;
				maxRewardMean = rewardAll;
				npcBot:ActionImmediate_Chat( "best param :"..maxRewardMean , false )
				-- print("best param :"..maxRewardMean)
				-- print(maxParameter)
				for key,value in pairs(maxParameter) do
					npcBot:ActionImmediate_Chat( key.." "..value , false )

				end				
			end

			parameter['maxReward'] = rewardAll

			request = CreateHTTPRequest(":8080" )
			request:SetHTTPRequestHeaderValue("Accept", "application/json")		
			request:SetHTTPRequestRawPostBody('application/json', dkjson.encode(parameter))
			request:Send( 	function( result ) 
								  --for k,v in pairs( result ) do
						              if result["StatusCode"] == 200  then  
											  print("result:"..result['Body'] )
						              end
						          --end
							end )

			rewardAll = 0;
			randomParameter();
			-- countRound = 0;


		end

		countRound = (countRound + 1) % 10;


			

		
		
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

	parameter['hp_weight'] = math.random()*2-1
	parameter['distance_weight'] = math.random()*2-1
	parameter['baseDamage_weight'] = math.random()*2-1
	-- parameter['attackSpeed_weight'] = math.random()*2-1
	parameter['creepDamageTaken_weight'] = math.random()*2-1
	-- parameter['bias'] = math.random( 0, 1300 )

end 

function sigmoid(x)
	return 1/( 1+math.exp(-x) )
end 

function normalizeValue(x,min,max)
	return (x - min)/(max - min)
end

