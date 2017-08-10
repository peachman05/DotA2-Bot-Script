local M = {}

serverHTTPLoc = ""

IDLE_THINK_STATE = 0;
ATTACK_THINK_STATE = 1;

function createRequest(input,mode)
	request =	CreateHTTPRequest(  serverHTTPLoc )
	
	print("testddd");

	request:SetHTTPRequestGetOrPostParameter("hp_me", tostring(input['hp_me'])  );
	request:SetHTTPRequestGetOrPostParameter("hp_enemy",tostring(input['hp_enemy'])  );
	request:SetHTTPRequestGetOrPostParameter("mp_me", tostring(input['mp_me']) );
	request:SetHTTPRequestGetOrPostParameter("mp_enemy",tostring(input['mp_enemy']) );
	request:SetHTTPRequestGetOrPostParameter("distance",tostring(input['distance']) );
	request:SetHTTPRequestGetOrPostParameter("level_s1",tostring(input['level_s1']) );
	request:SetHTTPRequestGetOrPostParameter("level_s2",tostring(input['level_s2']) );
	request:SetHTTPRequestGetOrPostParameter("level_s3",tostring(input['level_s3']) );
	request:SetHTTPRequestGetOrPostParameter("cd_s1",tostring(input['cd_s1']) );
	request:SetHTTPRequestGetOrPostParameter("cd_s2",tostring(input['cd_s2']) );
	request:SetHTTPRequestGetOrPostParameter("cd_s3",tostring(input['cd_s3']) );
	request:SetHTTPRequestGetOrPostParameter("mode",tostring(mode));



	return request

end

function getThinkState()

	input = _G.input

	print(type( input ))
	for key,value in pairs( input )
		do
			print(key , value);

	end
	--print("hp_me"..tostring( (_G.input)['hp_me'] ) )
	

 	--request = createRequest( input , IDLE_THINK_STATE )

 -- 	request =	CreateHTTPRequest(  "" )
	
	-- print("testddd");

	-- request:SetHTTPRequestGetOrPostParameter("hp_me", tostring(input['hp_me'])  );
	-- request:SetHTTPRequestGetOrPostParameter("hp_enemy",tostring(input['hp_enemy'])  );
	-- request:SetHTTPRequestGetOrPostParameter("mp_me", tostring(input['mp_me']) );
	-- request:SetHTTPRequestGetOrPostParameter("mp_enemy",tostring(input['mp_enemy']) );
	-- request:SetHTTPRequestGetOrPostParameter("distance",tostring(input['distance']) );
	-- request:SetHTTPRequestGetOrPostParameter("level_s1",tostring(input['level_s1']) );
	-- request:SetHTTPRequestGetOrPostParameter("level_s2",tostring(input['level_s2']) );
	-- request:SetHTTPRequestGetOrPostParameter("level_s3",tostring(input['level_s3']) );
	-- request:SetHTTPRequestGetOrPostParameter("cd_s1",tostring(input['cd_s1']) );
	-- request:SetHTTPRequestGetOrPostParameter("cd_s2",tostring(input['cd_s2']) );
	-- request:SetHTTPRequestGetOrPostParameter("cd_s3",tostring(input['cd_s3']) );
	-- request:SetHTTPRequestGetOrPostParameter("mode",tostring(mode));
	-- print("getThinkState")
	-- request:Send( function( result )
 -- 				print( "GET response: \n")
 -- 				for k,v in pairs( result ) do
 -- 					print( string.format( "%s : %s\n", k, v ) )
 -- 					return  tonumber(v)
 -- 				end
 
 -- -- 			for k, v in pairs( result['Request'] ) do
 -- -- 					print(k, v)
 -- -- 					print(type(v))
 -- --				end
 -- 	end )
 	

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



M.getThinkState = getThinkState
 
return M

