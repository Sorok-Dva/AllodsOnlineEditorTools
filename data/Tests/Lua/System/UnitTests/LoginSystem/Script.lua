Global( "TEST_NAME", "System.UnitTest.Login" )
Global( "TEST_AVATAR1", nil)
Global( "TEST_AVATAR2", nil)
Global( "TEST_AVATAR3", nil)
Global( "STEP_TEST", 0)

function OnAvatarCreated( params )
	Log("Avatar Created, next step after 2 sec",TEST_NAME)
	if STEP_TEST == 0 then
		StartTimer(2000,Restart,nil)
		STEP_TEST = 1
	elseif STEP_TEST == 1 then
		StartTimer(2000,Restart, TEST_AVATAR2 )
		STEP_TEST = 2
	elseif STEP_TEST == 2 then
		StartTimer(2000,Restart, TEST_AVATAR3 )
		STEP_TEST = 3
	else
		StartTimer(2000,Success, TEST_NAME)
	end
end

function IfErrorInTest( testName, text )
	Warn( TEST_NAME, text )
end

function Init()          
	local loginParam = developerAddon.GetParam( "login" )
	TEST_AVATAR1 = developerAddon.GetParam( "avatar1" )
	TEST_AVATAR2 = developerAddon.GetParam( "avatar2" )
	TEST_AVATAR3 = developerAddon.GetParam( "avatar3" )
	local avS = {}
	table.insert( avS, TEST_AVATAR1)
	table.insert( avS, TEST_AVATAR2)
	table.insert( avS, TEST_AVATAR3)
	
	local login_params = {
		login = loginParam,
		pass = loginParam,
		avatar = TEST_AVATAR1,
		debugMode = true,
		avatars = avS,
		errorFunc = IfErrorInTest,
	}
	InitLoging(login_params) 
	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )  	
end


Init()