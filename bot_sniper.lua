
dkjson = require( "game/dkjson" )


npcBot = GetBot();
math.randomseed( RealTime())

---- STATE
	--- game state

LAST_HIT_DENY_STATE = 0;
ATTACk_ENEMY_STATE = 1;
GO_TOWER_STATE = 2;
RETREAT_STATE = 5;
IDLE_STATE = 10;
FOLLOW_CREEP_STATE = 11;



state = GO_TOWER_STATE;
waitGetState  = false

	--- http request state
PREDICT_STATE = 20;
UPDATE_STATE = 21;

--- 



rewardSumInEpisode = 0;
previous_lasthit = 0;
previous_deny = 0;
previous_kill = 0;
oldHP = 0;
oldHP_enemy = 0;

-- weight
lasthit_reward_weight = 1;
deny_reward_weight = 1;
kill_reward_weight = 20;
hp_npc_reward_weight = 0.01;
hp_enemy_reward_weight = 0.01;


lasthitCheck = {}
attackEnemyCheck = {}
healthCheck = {}
trainList = {}

lasthitCheck['previous_lasthit'] = npcBot:GetLastHits();
lasthitCheck['previous_deny'] = npcBot:GetDenies();
lasthitCheck['already_attack'] = false
lasthitCheck['time_attack'] = 0

attackEnemyCheck['already_attack'] = false
attackEnemyCheck['time_attack'] = 0
attackEnemyCheck['oldHP_enemy'] = 0

healthCheck['oldHP'] = npcBot:GetHealth();
healthCheck['rewardMinus'] = 0;

trainList['reward'] = {}
trainList['action'] = {}
trainList['observation'] = {}
-- trainList['m'] = nil



inputPredict = {1,2,3,4,5,6} -- distance , canDo  , damageToEnemyHero , hpEnemyHero ,canSeeHero,hpNPC
---

firstMidTowerRadian = GetTower(TEAM_RADIANT,TOWER_MID_1)
towerLocationRadian = firstMidTowerRadian:GetLocation()
firstMidTowerDire = GetTower(TEAM_DIRE,TOWER_MID_1)
towerLocationDire = firstMidTowerDire:GetLocation()



function Think()

	if(npcBot:GetAnimActivity() == ACTIVITY_SPAWN and npcBot:GetAnimCycle() == 0)then

		sendHttpRequest(UPDATE_STATE,trainList);
		trainList['reward'] = {}
		trainList['action'] = {}
		trainList['observation'] = {}
		rewardSumInEpisode = 0;
		print("reward :"..rewardSumInEpisode)

		print("ACTIVITY_SPAWN "..npcBot:GetAnimCycle())

		state = GO_TOWER_STATE;
		waitGetState = false

	end	

	if(waitGetState == false)then

		creepEnemy, inputPredict[1], inputPredict[2] = canLastHit();
		npcEnemy, inputPredict[3], inputPredict[4], inputPredict[5] = getEnemyHeroStatus();
		inputPredict[6] = getDamageTaken();

		
		if( state == IDLE_STATE)then
			getPredict(inputPredict);
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

		
			updateTable(GO_TOWER_STATE, -healthCheck['rewardMinus'] ,inputPredict);
			healthCheck['rewardMinus'] = 0;

			state = FOLLOW_CREEP_STATE
			

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

	end


	checkHelathDecrease();


	

end


function getPredict(inputTable)

	sendHttpRequest(PREDICT_STATE,inputTable);

end

-- canDo - 1 = false , 1 = true
function canLastHit()



	creepsEnemy = npcBot:GetNearbyLaneCreeps(1600,true);
	creepsAlly = npcBot:GetNearbyLaneCreeps(1600,false);

	attackDamageHero = npcBot:GetAttackDamage()

	-- last hit
	for iEnemy,creepEnemy in pairs(creepsEnemy) do

		trueDamage = creepEnemy:GetActualIncomingDamage( attackDamageHero, DAMAGE_TYPE_PHYSICAL )
		
		hpCreepEnemy = creepEnemy:GetHealth() 					

		if( hpCreepEnemy  < trueDamage  )then


			return creepEnemy,math.floor( GetUnitToUnitDistance(creepEnemy,npcBot) ),1;			
			
		end

	end

	-- deny
	for iAlly,creepAlly in pairs(creepsAlly) do

		trueDamage = creepAlly:GetActualIncomingDamage( attackDamageHero, DAMAGE_TYPE_PHYSICAL )
		
		hpCreepAlly = creepAlly:GetHealth() 					

		if( hpCreepAlly   < trueDamage  )then


			return creepAlly,math.floor( GetUnitToUnitDistance(creepAlly,npcBot) ),1;			
			
		end

	end

	return nil,-1,-1;

end

function sendHttpRequest(method,inputTable)

	
	waitGetState = true;

	dataSend = {}
	dataSend['method']= method;
	dataSend['observation'] =  inputTable;
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


end

function updateTable(action,reward,observation)
	-- print("reward :"..new_reward.."Action :"..action)
	new_reward = reward - healthCheck['rewardMinus'];
	healthCheck['rewardMinus'] = 0;
	table.insert( trainList['observation'], observation )
	table.insert( trainList['reward'], new_reward)
	actionArray = {0,0,0}
	actionArray[action+1] = 1;
	table.insert( trainList['action'], actionArray)
	rewardSumInEpisode = rewardSumInEpisode + new_reward;

	if( npcBot:GetTeam() ==  TEAM_DIRE)then
		print("Dire :"..reward)

	else
		print("Radian :"..reward)
	end




end


function clearTempValue()

	lasthitCheck['previous_lasthit'] = npcBot:GetLastHits();
	lasthitCheck['previous_deny'] = npcBot:GetDenies();
	lasthitCheck['already_attack'] = false
	lasthitCheck['time_attack'] = 0


	attackEnemyCheck['already_attack'] = false
	attackEnemyCheck['time_attack'] = 0
	attackEnemyCheck['oldHP_enemy'] = 0
	attackEnemyCheck['canKill'] = false

	healthCheck['oldHP'] = npcBot:GetHealth();
	healthCheck['rewardMinus'] = 0;


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
						-- print("can last hit "..newLasthit);

						
					end

				else

					newDeny = npcBot:GetDenies();					

					if( newDeny > lasthitCheck['previous_deny'] )then

						--- last hit		
						new_reward = ( newDeny - lasthitCheck['previous_deny'] ) * lasthit_reward_weight;					
						lasthitCheck['previous_deny'] = newDeny
						-- print("can Deny "..newDeny);

						
					end

				

				end

				updateTable(LAST_HIT_DENY_STATE, new_reward, inputPredict)
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

			attackDamageHero = npcBot:GetAttackDamage()
			trueDamage = npcEnemy:GetActualIncomingDamage( attackDamageHero, DAMAGE_TYPE_PHYSICAL )		
			hpHeroEnemy = npcEnemy:GetHealth()

			if( hpHeroEnemy < trueDamage)then
				attackEnemyCheck['canKill'] = true;
				attackEnemyCheck['kill_param_input'] = inputPredict;
				attackEnemyCheck['old_kill'] = GetHeroKills( npcBot:GetPlayerID() )
				attackEnemyCheck['old_assist'] = GetHeroAssists( npcBot:GetPlayerID()  )
			end

			

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
					
					-- print("can hit enemy "..new_reward);

				end



				attackEnemyCheck['oldHP_enemy'] = newHP_enemy;

				updateTable(ATTACk_ENEMY_STATE, new_reward, inputPredict)
				state = IDLE_STATE;


			end

		end
	else

		if( attackEnemyCheck['canKill'] == true  )then

			killCurrent = GetHeroKills( npcBot:GetPlayerID() )
			assistCurrent= GetHeroAssists( npcBot:GetPlayerID()  )

			if( killCurrent > attackEnemyCheck['old_kill'])then
				new_reward = (killCurrent - attackEnemyCheck['old_kill']) * kill_reward_weight
				updateTable( ATTACk_ENEMY_STATE, new_reward, attackEnemyCheck['kill_param_input'] )
				attackEnemyCheck['old_kill'] = killCurrent
				print("can kill")
			elseif(assistCurrent > attackEnemyCheck['old_assist'] )then
				new_reward = (assistCurrent - attackEnemyCheck['old_assist']) * kill_reward_weight
				updateTable( ATTACk_ENEMY_STATE, new_reward, attackEnemyCheck['kill_param_input'] )
				attackEnemyCheck['old_assist'] = assistCurrent
				print("can assist")
			end

		end

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
