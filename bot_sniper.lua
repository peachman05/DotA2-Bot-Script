
dkjson = require( "game/dkjson" )


npcBot = GetBot();
math.randomseed( RealTime())

IDLE_STATE = 0;
GO_TOWER_STATE = 1;
FOLLOW_CREEP_STATE = 2;
LAST_HIT_DENY_STATE = 3;
ATTACk_ENEMY_STATE = 4;
RETREAT_STATE = 5;

state = GO_TOWER_STATE;

--- 



reward = 0;
previous_lasthit = 0;
previous_deny = 0;
previous_kill = 0;
oldHP = 0;
oldHP_enemy = 0;

-- weight
lasthit_reward_weight = 1;
deny_reward_weight = 1;
kill_reward_weight = 20;
hp_npc_reward_weight = 0.02;
hp_enemy_reward_weight = 0.02;

lasthitCheck = {}
lasthitCheck['previous_lasthit'] = npcBot:GetLastHits();
lasthitCheck['previous_deny'] = npcBot:GetDenies();
lasthitCheck['already_attack'] = false
lasthitCheck['time_attack'] = 0


attackEnemyCheck = {}
attackEnemyCheck['already_attack'] = false
attackEnemyCheck['time_attack'] = 0
attackEnemyCheck['oldHP_enemy'] = 0

healthCheck = {}
healthCheck['oldHP'] = npcBot:GetHealth();
healthCheck['rewardMinus'] = 0;


trainList = {}
trainList['reward'] = {}
trainList['action'] = {}
trainList['observation'] = {}


input = {1,2,3,4,5,6} -- distance , canDo  , damageToEnemyHero , hpEnemyHero ,canSeeHero,hpNPC
---

firstMidTowerRadian = GetTower(TEAM_RADIANT,TOWER_MID_1)
towerLocationRadian = firstMidTowerRadian:GetLocation()
firstMidTowerDire = GetTower(TEAM_DIRE,TOWER_MID_1)
towerLocationDire = firstMidTowerDire:GetLocation()



function Think()

	if(npcBot:GetAnimActivity() == ACTIVITY_SPAWN and npcBot:GetAnimCycle() == 0)then

		updateModel();
		trainList['reward'] = {}
		trainList['action'] = {}
		trainList['observation'] = {}

		print("ACTIVITY_SPAWN "..npcBot:GetAnimCycle())

	end

	if(npcBot:IsAlive() == false)then 

		
		

		--- deny
		-- reward = reward + ( GetDenies() - previous_deny  ) * deny_reward_weight
		-- previous_deny = GetDenies()

		-- --- kill
		-- reward = reward + ( GetHeroKills( npcBot:GetPlayerID() ) - previous_kill  ) * kill_reward_weight
		-- previous_deny = GetDenies()



		reward = 0;

		state = GO_TOWER_STATE;
	end

	input = {}

	creepEnemy, input[1], input[2] = canLastHit();
	npcEnemy, input[3], input[4], input[5] = getEnemyHeroStatus();
	input[6] = getDamageTaken();

	
	if( state == IDLE_STATE)then
		state = getPredict(input);
		-- print("predict")
		-- state = LAST_HIT_DENY_STATE
	elseif( state == GO_TOWER_STATE and npcBot:IsAlive() )then

		locationCheck = 0;
		if(npcBot:GetTeam() == TEAM_DIRE)then
			npcBot:ActionPush_MoveToLocation( towerLocationDire );	
			locationCheck = towerLocationDire
		else 
			npcBot:Action_MoveToLocation( towerLocationRadian );	
			locationCheck = towerLocationRadian
		end

		-- if( GetUnitToLocationDistance(npcBot,locationCheck ) < 400)then		
		-- 	state = FOLLOW_CREEP_STATE
		-- end
		print("tower :"..(-healthCheck['rewardMinus']) )
		updateTable(GO_TOWER_STATE, -healthCheck['rewardMinus'] ,input);
		healthCheck['rewardMinus'] = 0;

		state = FOLLOW_CREEP_STATE
		-- print("Retreat "..GetUnitToLocationDistance(npcBot,locationCheck ))

	elseif( state == FOLLOW_CREEP_STATE )then

		creeps = npcBot:GetNearbyLaneCreeps(900,false);
		-- print(tablelength(creeps))
		if( tablelength(creeps) > 0 )then

			npcBot:Action_MoveToLocation( creeps[1]:GetLocation() )

			if( tablelength(npcBot:GetNearbyLaneCreeps(900,true) ) > 0 )then

				state = IDLE_STATE;

			end

		end
		

	elseif( state == LAST_HIT_DENY_STATE )then

		lastHitDenyState(creepEnemy)
		
	
	elseif( state == ATTACk_ENEMY_STATE )then

		attackEnemyState(npcEnemy)
		

	end

	-- print(npcBot:GetTeam().." "..state);
	-- if(npcBot:GetTeam() == TEAM_DIRE)then
	-- 	print("Dire "..state)
	-- else
	-- 	print("Radian "..state)
	-- end
	
	--- hp npc
	

	checkHelathDecrease();


	

end


function getPredict(input)
	value = RandomInt( 1, 10 );
	-- return GO_TOWER_STATE;
	if(value <=  1)then
		return GO_TOWER_STATE; 
	elseif(value <= 5)then
		return ATTACk_ENEMY_STATE;
	else
		return LAST_HIT_DENY_STATE;
	end

end

-- canDo - 1 = false , 1 = true
function canLastHit()



	creepsEnemy = npcBot:GetNearbyLaneCreeps(1600,true);
	creepsAlly = npcBot:GetNearbyLaneCreeps(1600,false);

	attackDamageHero = npcBot:GetAttackDamage()


	for iEnemy,creepEnemy in pairs(creepsEnemy) do

		trueDamage = creepEnemy:GetActualIncomingDamage( attackDamageHero, DAMAGE_TYPE_PHYSICAL )
		
		hpCreepEnemy = creepEnemy:GetHealth() 					

		if( hpCreepEnemy  < trueDamage  )then


			return creepEnemy,math.floor( GetUnitToUnitDistance(creepEnemy,npcBot) ),1;			
			
		end

	end

	for iAlly,creepAlly in pairs(creepsAlly) do

		trueDamage = creepAlly:GetActualIncomingDamage( attackDamageHero, DAMAGE_TYPE_PHYSICAL )
		
		hpCreepAlly = creepAlly:GetHealth() 					

		if( hpCreepAlly   < trueDamage  )then


			return creepAlly,math.floor( GetUnitToUnitDistance(creepAlly,npcBot) ),1;			
			
		end

	end

	return nil,-1,-1;

end

function updateModel()

	-- print("start "..i..": "..GameTime())
	
	request = CreateHTTPRequest(":8080" )
	request:SetHTTPRequestHeaderValue("Accept", "application/json")		
	request:SetHTTPRequestRawPostBody('application/json', dkjson.encode(trainList))
	request:Send( 	function( result ) 
						  --for k,v in pairs( result ) do
				              if result["StatusCode"] == 200  then  
									  print("result: "..result['Body'] )
				              end
				              -- print("Recieve "..GameTime())
				          --end
					end )


end

function updateTable(action,reward,observation)
	-- print("reward :"..new_reward.."Action :"..action)
	table.insert( trainList['observation'], observation )
	table.insert( trainList['reward'], new_reward)
	table.insert( trainList['action'], action)



end


function  getEnemyHeroStatus()
	local heroEnemys = npcBot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	
	for _,npcEnemy in pairs( heroEnemys ) do
		return npcEnemy, npcBot:GetEstimatedDamageToTarget( true, npcEnemy, 1, DAMAGE_TYPE_ALL ), npcEnemy:GetHealth(), 1;
	end

	return nil, -1,-1,-1;
end

function getDamageTaken()

	return npcBot:GetHealth();

end 


---- state function
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

				updateTable(LAST_HIT_DENY_STATE, new_reward, input)
				state = IDLE_STATE;


			end

		end
end

function attackEnemyState(npcEnemy)
	
	if(npcEnemy ~= nil)then
		if(attackEnemyCheck['already_attack'] == false)then

			

				attackEnemyCheck['already_attack'] = true
				attackEnemyCheck['time_attack'] = GameTime();
				npcBot:Action_AttackUnit( npcEnemy, true );

			

		else

			if( attackEnemyCheck['time_attack'] + npcBot:GetAttackPoint() + 0.4 < GameTime() )then
				
				attackEnemyCheck['already_attack'] = false;
				new_reward = 0;

				newHP_enemy = npcEnemy:GetHealth();
				-- print("new :"..newHP_enemy.." Old: "..attackEnemyCheck['oldHP_enemy']);
				if( newHP_enemy <  attackEnemyCheck['oldHP_enemy'] )then

					attackDamageHero = npcBot:GetAttackDamage()
					trueDamage = npcEnemy:GetActualIncomingDamage( attackDamageHero, DAMAGE_TYPE_PHYSICAL )

					new_reward = trueDamage * hp_enemy_reward_weight ;
					
					print("can hit enemy "..new_reward);

				end

				attackEnemyCheck['oldHP_enemy'] = newHP_enemy;

				updateTable(ATTACk_ENEMY_STATE, new_reward, input)
				state = IDLE_STATE;


			end

		end
	else
		state = IDLE_STATE;
	end

end

function checkHelathDecrease()

	newHP = npcBot:GetHealth();

	if( newHP < healthCheck['oldHP'] )then
		healthCheck['rewardMinus'] = healthCheck['rewardMinus'] + (healthCheck['oldHP'] - newHP) * hp_npc_reward_weight
	end
	healthCheck['oldHP'] = newHP;

end


----- debug function
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

function findMin(table)
	min = 9999999;
	posi = nil;
	for key,value in pairs(table) do

		if(value < min)then
			min = value;
			posi = key
		end

	end

	return posi,min


end

function printTable(table)
	i = 0
	for key,value in pairs(table) do

		if( key:IsNull() == false )then
			print(i..""..key:GetUnitName())			
			j=0;
			for key2,value2 in pairs(value) do
				print("+++++"..j..""..key2:GetUnitName().." "..value2)
				j = j +1;
			end
			i = i +1
		end

	end

end

function printTable2(table)

	
	-- if( key:IsNull() == false )then		
		j=0;
		for key2,value2 in pairs(table) do
			print(key2)
			print("+++++"..j.." "..key2:GetUnitName().." "..value2)
			j = j +1;
		end
		
	-- end


end
