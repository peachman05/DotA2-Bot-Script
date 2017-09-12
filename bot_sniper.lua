
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

lasthit_reward_weight = 1;
deny_reward_weight = 1;
kill_reward_weight = 20;
hp_npc_reward_weight = 0.05;
hp_enemy_reward_weight = 0.05;

---

firstMidTower = GetTower(TEAM_RADIANT,TOWER_MID_1)
towerLocation = firstMidTower:GetLocation()

function Think()

	if(npcBot:IsAlive() == false)then 

		
		--- last hit		
		reward = reward + ( GetLastHits() - previous_lasthit ) * lasthit_reward_weight
		previous_lasthit = GetLastHits()

		--- deny
		reward = reward + ( GetDenies() - previous_deny  ) * deny_reward_weight
		previous_deny = GetDenies()

		--- kill
		reward = reward + ( GetHeroKills( npcBot:GetPlayerID() ) - previous_kill  ) * kill_reward_weight
		previous_deny = GetDenies()



		reward = 0;

		state = GO_TOWER_STATE;
	end

	input = {}

	creepEnemy, input['distance'], input['canDo'] = canLastHit();
	input['damageToEnemyHero'], input['hpEnemyHero'], input['canSeeHero'] = getEnemyHeroStatus();
	input['hpNPC'] = getDamageTaken();

	state = getPredict(input);
	
	if( state == GO_TOWER_STATE and npcBot:IsAlive() )then

		npcBot:Action_MoveToLocation( towerLocation );	

	elseif( state == LAST_HIT_DENY_STATE )then

		if(creepEnemy ~= nil)then
			npcBot:Action_AttackUnit( creepEnemy, true );
		end
		
	end

	--- hp npc
	newHP = npcBot:GetHealth();
	if( newHP < oldHP )then
		reward = reward - (oldHP - newHP) * hp_npc_reward_weight
	end
	oldHP = newHP;
	
	--- hp enemy 
	newHP_enemy = npcEnemy:GetHealth();
	if( newHP_enemy < oldHP_enemy )then
		reward = reward + (oldHP_enemy - newHP_enemy) * hp_enemy_reward_weight
	end
	oldHP_enemy = newHP_enemy;


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

function canLastHit()

	creepsEnemy = npcBot:GetNearbyLaneCreeps(900,true);
	baseDmageHero = npcBot:GetAttackDamage()

	for iEnemy,creepEnemy in pairs(creepsEnemy) do
		
		hpCreepEnemy = creepEnemy:GetHealth() 					

		if( hpCreepEnemy  < baseDmageHero  )then

			-- npcBot:Action_AttackUnit( creepEnemy, true );
			return creepEnemy,GetUnitToUnitDistance(creepEnemy,npcBot);			
			
		end

	end

	return nil,-1;

end

function  getEnemyHeroStatus()
	local heroEnemys = npcBot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	
	for _,npcEnemy in pairs( heroEnemys )
		return npcBot:GetEstimatedDamageToTarget( true, npcEnemy, 1, DAMAGE_TYPE_ALL ),npcEnemy:GetHealth(),true;
	end

	return -1,-1,false;
end

function getDamageTaken()

	return npcBot:GetHealth();

end 


function updateModel()

	-- time = DotaTime()
	-- -- print("Time :"..time.." Time mod "..time%30)

	-- timemod = time % 30
	-- if( time >= 0 and  timemod >= 0  and timemod <= 0.1 and checkUpdate == false)then

	-- 	checkUpdate = true;

	-- 	-- print("STATE :"..STATE)
	-- 	npcBot:ActionImmediate_Chat( "Count :"..countRound.."Time :"..time.."rewardAll :"..rewardAll , false )



	-- 	current_lasthit = npcBot:GetLastHits();
	-- 	rewardAll = rewardAll + (current_lasthit - previous_lasthit) ;
	-- 	previous_lasthit = current_lasthit;
	-- 	-- print(rewardAll)


	-- 	if(countRound == 9)then

	-- 		if( rewardAll > maxRewardMean)then

	-- 			maxParameter = parameter;
	-- 			maxRewardMean = rewardAll;
	-- 			npcBot:ActionImmediate_Chat( "best param :"..maxRewardMean , false )
	-- 			-- print("best param :"..maxRewardMean)
	-- 			-- print(maxParameter)
	-- 			for key,value in pairs(maxParameter) do
	-- 				npcBot:ActionImmediate_Chat( key.." "..value , false )

	-- 			end				
	-- 		end

	-- 		parameter['maxReward'] = rewardAll

	-- 		request = CreateHTTPRequest(":8080" )
	-- 		request:SetHTTPRequestHeaderValue("Accept", "application/json")		
	-- 		request:SetHTTPRequestRawPostBody('application/json', dkjson.encode(parameter))
	-- 		request:Send( 	function( result ) 
	-- 							  --for k,v in pairs( result ) do
	-- 					              if result["StatusCode"] == 200  then  
	-- 										  print("result:"..result['Body'] )
	-- 					              end
	-- 					          --end
	-- 						end )

	-- 		rewardAll = 0;
	-- 		-- randomParameter();
	-- 		-- countRound = 0;


	-- 	end

	-- 	countRound = (countRound + 1) % 10;


			

		
		
	-- end 

	-- if( timemod > 2)then
	-- 	checkUpdate = false;
	-- end

end