
npcBot = GetBot();

GO_TOWER_STATE = 1;
FOLLOW_CREEP_STATE = 2;
LANING_STATE = 3;

STATE = GO_TOWER_STATE;

previous_time = DotaTime();
current_time = 0;

-- damageCreepTaken = {}


firstMidTower = GetTower(TEAM_RADIANT,TOWER_MID_1)

function Think()

	-- print("test lich")
	if( STATE == GO_TOWER_STATE )then

		npcBot:ActionImmediate_LevelAbility("lich_frost_nova");

		npcBot:Action_MoveDirectly( firstMidTower:GetLocation() );
		STATE = FOLLOW_CREEP_STATE;
	elseif( STATE == FOLLOW_CREEP_STATE )then

		creeps = npcBot:GetNearbyLaneCreeps(900,false);

		if( tablelength(creeps) > 0 )then

			npcBot:Action_MoveToUnit( creeps[1] );
			print(creeps[1])

			if( tablelength(npcBot:GetNearbyLaneCreeps(400,true) ) > 0 )then

				STATE = LANING_STATE;

			end


		end
		

	elseif( STATE == LANING_STATE )then

		creepsEnemy = npcBot:GetNearbyLaneCreeps(900,true);

		for iEnemy,creepEnemy in pairs(creepsEnemy) do

			if( creepEnemy:GetHealth()  < npcBot:GetAttackDamage() + 40 )then

				creepsAlly = npcBot:GetNearbyLaneCreeps(900,false);

				countAttack = 0 ;
				sumAttack = 0;

				for iAlly,creepAlly in pairs(creepsAlly) do
					if( creepAlly:GetAttackTarget() == creepEnemy )then
						sumAttack = sumAttack + creepAlly:GetAttackDamage() ; 
						countAttack = countAttack+1;
					end
				end

				npcBot:Action_AttackUnit(creepEnemy,true)

				print("attack")
				print( npcBot:GetEstimatedDamageToTarget( true, creepEnemy , 1.5, DAMAGE_TYPE_ALL) );
				print(npcBot:GetLastHits())
				print("Count :"..countAttack.. "sum :"..sumAttack);
				previous_time = DotaTime();
				-- print( npcBot:GetAttackCombatProficiency(creep) ); 

			end
			

		end

	end
	print( STATE )


end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end