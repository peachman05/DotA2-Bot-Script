
dkjson = require( "game/dkjson" )


npcBot = GetBot();
math.randomseed( RealTime())


GO_TOWER_STATE = 1;
FOLLOW_CREEP_STATE = 2;
LAST_HIT_DENY_STATE = 3;

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
lasthitCheck['already_attack'] = false

trainList = {}
trainList['reward'] = {}
trainList['action'] = {}
trainList['observation'] = {}


input = {1,2,3,4,5,6} -- distance , canDo , damageToEnemyHero , hpEnemyHero ,canSeeHero,hpNPC
---

firstMidTower = GetTower(TEAM_RADIANT,TOWER_MID_1)
towerLocation = firstMidTower:GetLocation()



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
	input[3], input[4], input[5] = getEnemyHeroStatus();
	input[6] = getDamageTaken();

	-- state = getPredict(input);
		
	if( state == GO_TOWER_STATE and npcBot:IsAlive() )then

		npcBot:Action_MoveToLocation( towerLocation );	
		state = LAST_HIT_DENY_STATE

		-- print("go to tower")

	elseif( state == LAST_HIT_DENY_STATE )then

		if(lasthitCheck['already_attack'] == false)then 

			if(creepEnemy ~= nil)then

				lasthitCheck['already_attack'] = true
				lasthitCheck['time_lasthit'] = GameTime();
				npcBot:Action_AttackUnit( creepEnemy, true );
			end

		else

			if( lasthitCheck['time_lasthit'] + npcBot:GetAttackPoint() + 0.4 < GameTime() )then

				lasthitCheck['already_attack'] = false;
				newLasthit = npcBot:GetLastHits();
				new_reward = 0;

				if( newLasthit > lasthitCheck['previous_lasthit'] )then

					--- last hit		
					new_reward = ( newLasthit - lasthitCheck['previous_lasthit'] ) * lasthit_reward_weight;					
					lasthitCheck['previous_lasthit'] = newLasthit
					print("can last hit "..newLasthit.." "..lasthitCheck['previous_lasthit'].." "..new_reward);

					
				
			
				end

				updateTable(LAST_HIT_DENY_STATE, new_reward, input)

			end

		end
		
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
	return LAST_HIT_DENY_STATE;
end

-- canDo - 1 = false , 1 = true
function canLastHit()



	creepsEnemy = npcBot:GetNearbyLaneCreeps(1600,true);
	attackDamageHero = npcBot:GetAttackDamage()


	for iEnemy,creepEnemy in pairs(creepsEnemy) do

		trueDamage = creepEnemy:GetActualIncomingDamage( attackDamageHero, DAMAGE_TYPE_PHYSICAL )
		
		hpCreepEnemy = creepEnemy:GetHealth() 					

		if( hpCreepEnemy  < trueDamage  )then


			return creepEnemy,math.floor( GetUnitToUnitDistance(creepEnemy,npcBot) ),1;			
			
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
		return npcBot:GetEstimatedDamageToTarget( true, npcEnemy, 1, DAMAGE_TYPE_ALL ),npcEnemy:GetHealth(),1;
	end

	return -1,-1,-1;
end

function getDamageTaken()

	return npcBot:GetHealth();

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
