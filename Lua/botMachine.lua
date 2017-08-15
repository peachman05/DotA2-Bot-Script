local M = {}

serverHTTPLoc = ""

IDLE_THINK_STATE = 0;
ATTACK_THINK_STATE = 1;

function checkIfZero(number)
	if number == nil
	then 
		return 0;
	else
		return number;
	end

end 

function createRequest(input,mode,method)
	request =	CreateHTTPRequest(  serverHTTPLoc )
	
	print("testddd");
	request:SetHTTPRequestGetOrPostParameter("hp_me", tostring(  checkIfZero(input['hp_me']) )  );
	request:SetHTTPRequestGetOrPostParameter("hp_enemy",tostring( checkIfZero(input['hp_enemy']) )  );
	request:SetHTTPRequestGetOrPostParameter("mp_me", tostring( checkIfZero(input['mp_me']) ) );
	request:SetHTTPRequestGetOrPostParameter("mp_enemy",tostring( checkIfZero(input['mp_enemy']) ) );
	request:SetHTTPRequestGetOrPostParameter("distance",tostring( checkIfZero( math.ceil(input['distance']) ) ) );
	request:SetHTTPRequestGetOrPostParameter("level_s1",tostring( checkIfZero(input['level_s1']) ) );
	request:SetHTTPRequestGetOrPostParameter("level_s2",tostring( checkIfZero(input['level_s2']) ) );
	request:SetHTTPRequestGetOrPostParameter("level_s3",tostring( checkIfZero(input['level_s3']) ) );
	request:SetHTTPRequestGetOrPostParameter("cd_s1",tostring( checkIfZero(  math.ceil(input['cd_s1']) ) ) );
	request:SetHTTPRequestGetOrPostParameter("cd_s2",tostring( checkIfZero(  math.ceil(input['cd_s2']) ) ) );
	request:SetHTTPRequestGetOrPostParameter("cd_s3",tostring( checkIfZero(  math.ceil(input['cd_s3']) ) ) );
	request:SetHTTPRequestGetOrPostParameter("method",method);

	if(method == "Train")then
		request:SetHTTPRequestGetOrPostParameter("output", tostring( checkIfZero(input['output']) ) );
		print("Trainnn "..tostring( checkIfZero(input['output']) ))
	else
		request:SetHTTPRequestGetOrPostParameter("mode",tostring(mode));
	end



	return request

end

function getThinkState()

	input = _G.input

	print(type( input ))
	for key,value in pairs( input )
		do
			print(key , value);

	end

 	request = createRequest( input , IDLE_THINK_STATE ,"predict" )

 	
	print("getThinkState")

	_G.dataReturn = 0;

	request:Send( function( result )
 				print( "GET response: \n")
 				returnNum = tonumber(result['Body'])
 				print(returnNum );

 				_G.dataReturn = returnNum;
 				--return returnNum;
 				-- for k,v in pairs( result) do
 				-- 	print( string.format( "%s : %s\n", k, v ) )

 				-- 	-- for k2, v2 in pairs( v ) do
		 		-- 	-- 		print(k, v2)
		 		-- 	-- 		print("--------")
		 		-- 	-- 		print(type(v2))
		 		-- 	-- 		-- return  tonumber(v)
		 		-- 	-- end 
 				-- end
 
 -- 			for k, v in pairs( result['Request'] ) do
 -- 					print(k, v)
 -- 					print(type(v))
 --				end
 	end )
 	

end

function getAttackState(input)
	local request = createRequest( input , ATTACK_THINK_STATE )
	
	request:Send( function( result )
 				print( "GET response: \n")
 				for k,v in pairs( result ) do
 					print( string.format( "%s : %s\n", k, v ) )
 				end

 				print( "Done." )
 	end )
end


function trainAttackState()
	inputTrain = _G.inputTrain

	for key,value in pairs( inputTrain )
		do
			print(key , value);

	end

	request = createRequest( inputTrain , IDLE_THINK_STATE , "Train" )

	request:Send( function( result )
 				print( "GET response: \n")
 				returnNum = tonumber(result['Body'])
 				print(returnNum );
 			
 	end )

end


M.getThinkState = getThinkState
M.trainAttackState = trainAttackState
 
return M

