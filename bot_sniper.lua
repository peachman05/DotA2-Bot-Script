
dkjson = require( "game/dkjson" )


npcBot = GetBot();




---- STATE
	--- game state

LAST_HIT_DENY_STATE = 0;
ATTACk_ENEMY_STATE = 1;
BACKWARD_STATE = 2;
FORWARD_STATE = 3;
IDLE_STATE = 10;
GO_TO_LANE = 11;
FOLLOW_CREEP_STATE = 12;

state = GO_TO_LANE;

moveCheck = {}
moveCheck['timeStop'] = 0;
moveCheck['walkNow'] = false;

firstMidTowerRadian = GetTower(TEAM_RADIANT,TOWER_MID_1)
towerLocationRadian = firstMidTowerRadian:GetLocation()
firstMidTowerDire = GetTower(TEAM_DIRE,TOWER_MID_1)
towerLocationDire = firstMidTowerDire:GetLocation()

ancientRadian = GetAncient(TEAM_RADIANT)
ancientDire = GetAncient(TEAM_DIRE)

walkTime = 0.5


function Think()
	
	if( state == IDLE_STATE)then

		state = getPredict();		

	elseif( state == GO_TO_LANE and npcBot:IsAlive() )then
		
		if(npcBot:GetTeam() == TEAM_DIRE)then
			npcBot:ActionPush_MoveToLocation( towerLocationDire );	
		else 
			npcBot:Action_MoveToLocation( towerLocationRadian );	
		end
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
		-- lastHitDenyState()
		state = IDLE_STATE;
	elseif( state == ATTACk_ENEMY_STATE)then
		state = IDLE_STATE;		
	elseif( state == BACKWARD_STATE )then
		moveState(ancientRadian)	
	elseif( state == FORWARD_STATE )then		
		forwardState(ancientDire)

	end

end

function moveState(ancientUnit)

	if(moveCheck['walkNow'] == false)then

		npcBot:ActionPush_MoveToUnit( ancientUnit );
		moveCheck['walkNow'] = true;
		moveCheck['timeStop'] = GameTime() + walkTime ;
		print("start walk") 

	else
		
		timenow = GameTime();
		if( timenow > moveCheck['timeStop'] )then

			npcBot:Action_ClearActions(true);
			moveCheck['walkNow'] = false
			state = IDLE_STATE
			print("stop walk")

		end
	end


end

function getPredict()
	return RandomInt( 0, 3 )
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end