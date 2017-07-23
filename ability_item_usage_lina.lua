
----------------------------------------------------------------------------------------------------

IDLE_THINK_STATE = 0;
ATTACK_THINK_STATE = 1;
ESCAPE_THINK_STATE = 2;

think_state = IDLE_THINK_STATE;

-------------- attack

NORMAL_ATTACK_STATE = 0;
SKILL1_ATTACK_STATE = 1;
SKILL2_ATTACK_STATE = 2;
SKILL3_ATTACK_STATE = 3;
ESCAPE_ATTACK_STATE = 4;

attack_state = NORMAL_ATTACK_STATE;

botMachineObj = botMachine();

function AbilityUsageThink()

	

	local npcBot = GetBot();

	heroEnemy = npcBot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	if(heroEnemy != nil)

		input = {}
		input['hp_me'] = npcBot:GetHealth();
		input['hp_enemy'] = npcEnemy:GetHealth();
		input['mp_me'] = npcBot:GetMana();
		input['mp_enemy'] = npcEnemy:GetMana();
		input['distance'] = GetUnitToUnitDistance(npcBot,npcEnemy);
		
		abilityDS = npcBot:GetAbilityByName( "lina_dragon_slave" );
		abilityLSA = npcBot:GetAbilityByName( "lina_light_strike_array" );	 +	
	 +	abilityLB = npcBot:GetAbilityByName( "lina_laguna_blade" );

		input['cooldown_s1'] = abilityDS:GetCooldownTimeRemaining()
		input['cooldown_s2'] = abilityLSA:GetCooldownTimeRemaining()
		input['cooldown_s3'] = abilityLB:GetCooldownTimeRemaining()
		input['level_s1'] = abilityDS:GetLevel()
		input['level_s2'] = abilityLSA:GetLevel()
		input['level_s3'] = abilityLB:GetLevel()


		if(THINK_STATE == IDLE_THINK_STATE)
		then

			think_state = botMachineObj:getThinkState(input)

		elseif(THINK_STATE == ATTACK_THINK_STATE)

			attack_state = botMachineObj:getAttackState(input)

			if(attack_state == ESCAPE_ATTACK_STATE)
			then
				THINK_STATE = ESCAPE_THINK_STATE;
			else	
				attackEnemy(attack_state,npc,enemy)
			end
			

		elseif(THINK_STATE == ESCAPE_THINK_STATE)

			--STATE = botMachineObj:getEscapeState(input)
			escape();

		end


	

end


function attackEnemy(attack_state,npcBot,enemy)

	if(attack_state == NORMAL_ATTACK_STATE)
	then
		npcBot:Action_AttackUnit( enemy, false )

	elseif(attack_state == SKILL1_ATTACK_STATE)

		abilityDS = npcBot:GetAbilityByName( "lina_dragon_slave" );
		if ( abilityDS:IsFullyCastable() ) 
		then
			npcBot:Action_UseAbilityOnEntity(abilityDS,enemy);
		end

		
	 +	
	elseif(attack_state == SKILL2_ATTACK_STATE)

		abilityLSA = npcBot:GetAbilityByName( "lina_light_strike_array" );
		if ( abilityLSA:IsFullyCastable() ) 
		then
			npcBot:Action_UseAbilityOnEntity(abilityLSA,enemy);
		end

	elseif(attack_state == SKILL3_ATTACK_STATE)

		abilityLB = npcBot:GetAbilityByName( "lina_laguna_blade" );
		if ( abilityLB:IsFullyCastable() ) 
		then
			npcBot:Action_UseAbilityOnEntity(abilityLB,enemy);
		end

	end

end

function escape()


end