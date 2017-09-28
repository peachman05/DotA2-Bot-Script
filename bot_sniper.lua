
dkjson = require( "game/dkjson" )


npcBot = GetBot();




---- STATE
	--- game state

LAST_HIT_DENY_STATE = 0;
BACKWARD_STATE = 1;
FORWARD_STATE = 2;
ATTACk_ENEMY_STATE = 3;
IDLE_STATE = 10;
GO_TO_LANE = 11;
FOLLOW_CREEP_STATE = 12;

state = GO_TO_LANE;

	--- http request state
PREDICT_STATE = 20;
UPDATE_STATE = 21;


-- weight
lasthit_reward_weight = 1;
deny_reward_weight = 1;
kill_reward_weight = 20;
hp_npc_reward_weight = 0.005;
hp_enemy_reward_weight = 0.01;

step_decrease = 0.05

--- keep variable
hpCheck = {}
hpCheck['oldHp'] = npcBot:GetHealth();

moveCheck = {}
moveCheck['timeStop'] = 0;
moveCheck['walkNow'] = false;

lasthitCheck = {}
lasthitCheck['previous_lasthit'] = npcBot:GetLastHits();
lasthitCheck['previous_deny'] = npcBot:GetDenies();
lasthitCheck['already_attack'] = false
lasthitCheck['time_attack'] = 0

--- unit object
towerRadian = {}
towerDire = {}
towerRadian[1] = GetTower(TEAM_RADIANT,TOWER_MID_1)
towerRadian[2] = GetTower(TEAM_RADIANT,TOWER_MID_2)
towerRadian[3] = GetTower(TEAM_RADIANT,TOWER_MID_3)
towerDire[1] = GetTower(TEAM_DIRE,TOWER_MID_1)
towerDire[2] = GetTower(TEAM_DIRE,TOWER_MID_2)
towerDire[3] = GetTower(TEAM_DIRE,TOWER_MID_3)

towerNearest = 1;

ancientRadian = GetAncient(TEAM_RADIANT)
ancientDire = GetAncient(TEAM_DIRE)

--- variable ajust
walkTime = 0.5

--[[ 
- hp_me_decrease [1]
- hp_me [2]
- can_last_hit [3] 
- distance_to_lower_hp_creep [4]
- distance_to_nearest_creep [5]
- distance_to_nearest_tower [6]
--]]
inputPredict = {1,2,3,4,5,6}
rewardTimeStep = 0; 

waitGetState = false

function Think()

	

	if(npcBot:GetAnimActivity() == ACTIVITY_SPAWN and npcBot:GetAnimCycle() == 0)then
		state = GO_TO_LANE;
		getPredict(UPDATE_STATE,nil);
	end

	if(waitGetState == false and npcBot:IsAlive() )then	

		if( state == IDLE_STATE)then
			updateInput();
			getPredict(PREDICT_STATE,inputPredict);
		elseif( state == GO_TO_LANE )then			
			if(npcBot:GetTeam() == TEAM_DIRE)then
				npcBot:ActionPush_MoveToLocation( towerDire[towerNearest]:GetLocation() );	
			else 
				npcBot:Action_MoveToLocation( towerRadian[towerNearest]:GetLocation() );	
			end
			state = FOLLOW_CREEP_STATE
		elseif( state == FOLLOW_CREEP_STATE )then
			creeps = npcBot:GetNearbyLaneCreeps(900,false);
			if( tablelength(creeps) > 0 )then
				npcBot:Action_MoveToLocation( creeps[1]:GetLocation() )
				if( tablelength(npcBot:GetNearbyLaneCreeps(900,true) ) > 0 )then
					state = IDLE_STATE;
				end
			end
		elseif( state == LAST_HIT_DENY_STATE )then

			print(state)
			lastHitDenyState(lasthitCheck['creepEnemy'])
		elseif( state == ATTACk_ENEMY_STATE)then
			state = IDLE_STATE;		
		elseif( state == BACKWARD_STATE )then

			print(state)
			moveState(ancientRadian)	
		elseif( state == FORWARD_STATE )then

			print(state)		
			moveState(ancientDire)

		end
	end

end

function sendHttpRequest(method,inputTable)
	
	waitGetState = true;

	dataSend = {}
	dataSend['method']= method;

	if(method == PREDICT_STATE)then
		dataSend['observation'] =  inputTable;
		dataSend['reward'] = rewardTimeStep - step_decrease + inputTable[1]*hp_npc_reward_weight;
	end

	request = CreateHTTPRequest(":8080" )
	request:SetHTTPRequestHeaderValue("Accept", "application/json")		
	request:SetHTTPRequestRawPostBody('application/json', dkjson.encode(dataSend))
	request:Send( 	function( result ) 
						 
				              if result["StatusCode"] == 200  then  
									  -- print("result: "..result['Body'] )
									  if(method == PREDICT_STATE)then
									  		-- clearTempValue();
									  		state = tonumber(result['Body']);
									  		waitGetState = false;									  		
									  end
				              end
				              
					end )

	rewardTimeStep = 0;


end


function getPredict(method,inputTable)

	sendHttpRequest(method,inputTable)
	-- return RandomInt( 0, 3 )
end

-- State
function lastHitDenyState(creepEnemy)

		if(lasthitCheck['already_attack'] == false)then 

				if(creepEnemy ~= nil)then

					lasthitCheck['already_attack'] = true
					lasthitCheck['time_attack'] = GameTime();
					lasthitCheck['creep_team'] = creepEnemy:GetTeam();
					npcBot:Action_AttackUnit( creepEnemy, true );
				else
					state = IDLE_STATE;
				end

		else

			if( lasthitCheck['time_attack'] + npcBot:GetAttackPoint() + 0.4 < GameTime() )then
				lasthitCheck['already_attack'] = false;
				new_reward = 0;
				if(lasthitCheck['creep_team'] == TEAM_DIRE )then
					newLasthit = npcBot:GetLastHits();
					if( newLasthit > lasthitCheck['previous_lasthit'] )then
						--- last hit		
						new_reward = ( newLasthit - lasthitCheck['previous_lasthit'] ) * lasthit_reward_weight;					
						lasthitCheck['previous_lasthit'] = newLasthit
						print("can last hit "..newLasthit);
					end

				else
					newDeny = npcBot:GetDenies();
					if( newDeny > lasthitCheck['previous_deny'] )then
						--- last hit		
						new_reward = ( newDeny - lasthitCheck['previous_deny'] ) * lasthit_reward_weight;					
						lasthitCheck['previous_deny'] = newDeny
						print("can Deny "..newDeny);						
					end
				end

				rewardTimeStep = rewardTimeStep + new_reward;

				state = IDLE_STATE;


			end

		end
end

function moveState(ancientUnit)
	if(moveCheck['walkNow'] == false)then
		nearTower = towerRadian[towerNearest]
		farTower = towerRadian[towerNearest+1]
		distanceHeroToFarTower = GetUnitToUnitDistance(npcBot,farTower)
		distanceBetweenTower = GetUnitToUnitDistance(nearTower,farTower)

		if(ancientUnit == ancientRadian and distanceHeroToFarTower < distanceBetweenTower/2 )then -- back ward
			state = IDLE_STATE			
		else
			npcBot:ActionPush_MoveToUnit( ancientUnit );
			moveCheck['walkNow'] = true;
			moveCheck['timeStop'] = GameTime() + walkTime ;
		end

		-- print("start walk") 
	else		
		timenow = GameTime();
		if( timenow > moveCheck['timeStop'] )then
			npcBot:Action_ClearActions(true);
			moveCheck['walkNow'] = false
			state = IDLE_STATE
			-- print("stop walk")
		end
	end
end

-- Help Funtion
function canLastHit()

	creepsEnemy = npcBot:GetNearbyLaneCreeps(1600,true);
	creepsAlly = npcBot:GetNearbyLaneCreeps(1600,false);

	attackDamageHero = npcBot:GetAttackDamage()

	-- last hit
	for iEnemy,creepEnemy in pairs(creepsEnemy) do

		trueDamage = creepEnemy:GetActualIncomingDamage( attackDamageHero, DAMAGE_TYPE_PHYSICAL )
		
		hpCreepEnemy = creepEnemy:GetHealth() 					

		if( hpCreepEnemy  < trueDamage  )then


			return creepEnemy,1;			
			
		end

	end

	-- deny
	for iAlly,creepAlly in pairs(creepsAlly) do

		trueDamage = creepAlly:GetActualIncomingDamage( attackDamageHero, DAMAGE_TYPE_PHYSICAL )
		
		hpCreepAlly = creepAlly:GetHealth() 					

		if( hpCreepAlly   < trueDamage  )then


			return creepAlly,1;			
			
		end

	end

	return nil,-1;

end

function updateInput()
	inputPredict[1] = normalizeValue(npcBot:GetHealth() - hpCheck['oldHp'], 0 , npcBot:GetMaxHealth()); -- old hp
	inputPredict[2] = normalizeValue(npcBot:GetHealth(), 0 , npcBot:GetMaxHealth());
	lasthitCheck['creepEnemy'], inputPredict[3] = canLastHit();
	inputPredict[4],inputPredict[5] = distanceCreep();
	inputPredict[6] = distanceNearestTower();
	hpCheck['oldHp'] = npcBot:GetHealth();

	-- print("-------------------")
	-- print("hpDecrease :"..inputPredict[1]);
	-- print("Hp :"..inputPredict[2]);
	-- print("canLastHit :"..inputPredict[3]);
	-- print("distanceCreepminHp :"..inputPredict[4]);
	-- print("distanceCreepnear :"..inputPredict[5]);
	-- print("nearestTower :"..inputPredict[6]);

end

function distanceCreep()
	creepsEnemy = npcBot:GetNearbyLaneCreeps(1600,true);

	minHp = 999;
	minHp_creep = nil;
	min_distance = 1800;
	min_distance_creep = nil;

	for iEnemy,creepEnemy in pairs(creepsEnemy) do
		hp = creepEnemy:GetHealth();
		if(  hp < minHp )then
			minHp = hp;
			minHp_creep = creepEnemy;
		end

		distance = GetUnitToUnitDistance(creepEnemy,npcBot)
		if( distance < min_distance)then
			min_distance = distance;
			min_distance_creep = creepEnemy;
		end

	end

	if(minHp == 999)then -- no creeps
		return -1.5 , -1.5;
	else
		return getTruePosition( minHp_creep ),getTruePosition( min_distance_creep );
	end 
	
end

function distanceNearestTower()
 	if( towerRadian[towerNearest]:IsNull())then
 		towerNearest = towerNearest + 1;
 	end
 	return getTruePosition(towerRadian[towerNearest])
end


-- Calculate Function
function getTruePosition(hUnit)
	distanceToUnit = GetUnitToUnitDistance(npcBot,hUnit);
	distanceToAncient = GetUnitToUnitDistance(npcBot,ancientRadian);
 	distanceUnitToAncient = GetUnitToUnitDistance(ancientRadian,hUnit);
 	result = normalizeValue(distanceToUnit,0,1600);
 	if(distanceToAncient > distanceUnitToAncient)then -- unit is near ancient more than hero (hero is 0 position)
 		return -result;
 	else -- unit is far ancient more than hero
 		return result;
 	end
end

function normalizeValue(x,min,max)
	return (x - min)/(max - min)
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end