
----------------------------------------------------------------------------------------------------

IDLE_THINK_STATE = 0;
ATTACK_THINK_STATE = 1;
ESCAPE_THINK_STATE = 2;

think_state = IDLE_THINK_STATE;

-------------- attack

NORMAL_ATTACK_STATE = 0;
SKILL1_ATTACK_STATE

attack_state = NORMAL_ATTACK_STATE;

function AbilityUsageThink()

	botMachineObj = botMachine()

	input = {}
	input['hp_me'] = 
	input['hp_enemy'] = 
	input['mp_me'] = 
	input['mp_enemy'] = 
	input['distance'] = 
	input['cooldown_s1'] = 
	input['cooldown_s2'] = 
	input['cooldown_s3'] = 
	input['level_s1'] = 
	input['level_s2'] = 
	input['level_s3'] = 


	if(THINK_STATE == IDLE_THINK_STATE)
	then

		think_state = botMachineObj:getThinkState(input)

	elseif(THINK_STATE == ATTACK_THINK_STATE)

		attack_state = botMachineObj:getAttackState(input)
		attackEnemy(attack_state)

	elseif(THINK_STATE == ESCAPE_THINK_STATE)

		--STATE = botMachineObj:getEscapeState(input)
		escape();

	end


	

end


function attackEnemy(attack_state)
	

end

function escape()


end