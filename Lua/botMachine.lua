local M = {}

local serverHTTPLoc = ""

IDLE_THINK_STATE = 0;
ATTACK_THINK_STATE = 1;

local function getThinkState(input)
 	local request = createRequest( input , IDLE_THINK_STATE )
	
	request:Send( function( result )
 				print( "GET response: \n")
 				for k,v in pairs( result ) do
 					print( string.format( "%s : %s\n", k, v ) )
 					return v
 				end
 
 -- 			for k, v in pairs( result['Request'] ) do
 -- 					print(k, v)
 -- 					print(type(v))
 --				end
 	end )

end

local function getAttackState(input)
	local request = createRequest( input , ATTACK_THINK_STATE )
	
	request:Send( function( result )
 				print( "GET response: \n")
 				for k,v in pairs( result ) do
 					print( string.format( "%s : %s\n", k, v ) )
 				end

 				print( "Done." )
 	end )
end

local function createRequest(input,mode)
	local request =	CreateHTTPRequest(  serverHTTPLoc )

	request:SetHTTPRequestGetOrPostParameter("hp_me","400");
	request:SetHTTPRequestGetOrPostParameter("hp_enemy","400");
	request:SetHTTPRequestGetOrPostParameter("mp_me","200");
	request:SetHTTPRequestGetOrPostParameter("mp_enemy","150");
	request:SetHTTPRequestGetOrPostParameter("distance","700");
	request:SetHTTPRequestGetOrPostParameter("level_s1","2");
	request:SetHTTPRequestGetOrPostParameter("level_s2","2");
	request:SetHTTPRequestGetOrPostParameter("level_s3","1");
	request:SetHTTPRequestGetOrPostParameter("cd_s1","10");
	request:SetHTTPRequestGetOrPostParameter("cd_s2","15");
	request:SetHTTPRequestGetOrPostParameter("cd_s3","10");
	request:SetHTTPRequestGetOrPostParameter("mode",mode);

	return request

end

M.getThinkState = getThinkState
 
return M

