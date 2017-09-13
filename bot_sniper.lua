
dkjson = require( "game/dkjson" )


npcBot = GetBot();
math.randomseed( RealTime())

IDLE_STATE = 0;
GO_TOWER_STATE = 1;
FOLLOW_CREEP_STATE = 2;
LAST_HIT_DENY_STATE = 3;
ATTACk_ENEMY_STATE = 4;

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
hp_npc_reward_weight = 0.05;
hp_enemy_reward_weight = 0.05;

lasthitCheck = {}
lasthitCheck['previous_lasthit'] = npcBot:GetLastHits();
lasthitCheck['previous_deny'] = npcBot:GetDenies();
lasthitCheck['already_attack'] = false
lasthitCheck['time_attack'] = 0


attackEnemyCheck = {}
attackEnemyCheck['already_attack'] = false
attackEnemyCheck['time_attack'] = 0
attackEnemyCheck['oldHP_enemy'] = 0


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
		-- state = LAST_HIT_DENY_STATE
	elseif( state == GO_TOWER_STATE and npcBot:IsAlive() )then

		if(npcBot:GetTeam() == TEAM_DIRE)then
			npcBot:Action_MoveToLocation( towerLocationDire );	
		else 
			npcBot:Action_MoveToLocation( towerLocationRadian );	
		end
		state = LAST_HIT_DENY_STATE

	elseif( state == LAST_HIT_DENY_STATE )then

		lastHitDenyState(creepEnemy)
	
	elseif( state == ATTACk_ENEMY_STATE )then

		attackEnemyState(npcEnemy)

	end
	-- print(state)

	-- --- hp npc
	-- newHP = npcBot:GetHealth();
	-- if( newHP < oldHP )then
	-- 	reward = reward - (oldHP - newHP) * hp_npc_reward_weight
	-- end
	-- oldHP = newHP;
	
	-- --- hp enemy 
	-- newHP_enemy = npcEnemy:GetHealth();
	-- if( newHP_enemy < oldHP_enemy )then
	-- 	reward = reward + (oldHP_enemy - newHP_enemy) * hp_enemy_reward_weight
	-- end
	-- oldHP_enemy = newHP_enemy;


end


function getPredict(input)

	return RandomInt( 3, 4 );
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

	table.insert( trainList['observation'], observation )
	table.insert( trainList['reward'], new_reward )
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
				if( newHP_enemy <  attackEnemyCheck['oldHP_enemy'] )then

					new_reward = (attackEnemyCheck['oldHP_enemy']  - newHP_enemy) * hp_enemy_reward_weight ;
					attackEnemyCheck['oldHP_enemy'] = newHP_enemy;
					print("can hit enemy "..newLasthit);

				end

				updateTable(ATTACk_ENEMY_STATE, new_reward, input)
				state = IDLE_STATE;


			end

		end
	end

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
