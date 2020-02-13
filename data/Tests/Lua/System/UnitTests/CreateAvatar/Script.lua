Global( "TEST_NAME", "SmokeTest.CreateAvatar; author: Liventsev Andrey, date: 29.09.2008, task 37334" )

Global( "LOGIN", nil )
Global( "PASS", nil )
Global( "AVATAR", nil )

Global( "CLASS_ID", 2 )

Global( "LOGGING", true )
Global( "LOGGING_TO_SHARD", true )
Global("OnCustomGameStateChanged", nil)

		
-- mustExist: true если проверка на то, что аватар есть в списке
function CheckForAvatar( mustExist )
	local avatars = shard.GetAvatars()
	for key, value in avatars do
		if debugCommon.FromWString( value ) == AVATAR then
			return mustExist
		end	
	end

	return not mustExist
end

function DeleteAvatar()

end

function Done()
	common.LogInfo( "common", "avatar deleted" )
	Success( TEST_NAME )
end

function ErrorFunc( text )
	Warn( TEST_NAME, text )
end

---------------------------- EVENTS -------------------------------------------


function MainMenuLogin()
	cLog("main menu login")
	debugCommon.SetErrorReturn( -1 )
	mainMenu.Login( LOGIN, LOGIN )
end

--------- EVENTS -------------------------------------------------------------

-- заход на шард
function OnLoginGameStateChanged( params )
	if OnCustomGameStateChanged then
       OnCustomGameStateChanged( params )
    end
	if LOGGING and params.registered and params.stateDebugName == "class Game::MainMenu" then
  		MainMenuLogin()
	end
end

function OnLoggedIn(params)
	LOGGING = false
	account.ConnectShard( debugCommon.ToWString( SHARD_NAME ))
	Log( "try connect to shard. name=" .. SHARD_NAME )
	StartPrivateTimer( 30000, Warn, "Can't connect to shard. name=" .. SHARD_NAME )
end

function OnConnectionShardFailed( params )
	Warn( "LOGIN", "Connection to shard failed: " .. params.sysResult )
end

function OnConnectShardProgress(params)
	if params.sysStage == "ENUM_CONNECT_SHARD_PROGRESS_SUCCEED" then
		StopPrivateTimer()
		StartPrivateCheckTimer( 10000, IsBusy, nil, Warn, "Shard is busy for 10 sec", StartGame, nil )
	end
end

function IsBusy()
	return not shard.IsBusy()
end

function StartGame()
	if CheckForAvatar( true ) == true then	
		cLog( "avatar exists: deleting..." )
		shard.DeleteAvatar( debugCommon.ToWString( AVATAR ) )
		StartCheckTimer( 10000, CheckForAvatar, false, ErrorFunc, "Can't delete avatar", StartGame )
	else
		StartCheckTimer( 10000, CheckForAvatar, true, ErrorFunc, "Can't create avatar", Done )
		shard.CreateAvatar( debugCommon.ToWString( AVATAR ), CLASS_ID )
	end
end

-- заход в игру

function OnShardChanged()
	if LOGGING_TO_SHARD == true and shard.IsValid() == true then
		StartGame()
	end
end

function OnConnectionShardSucceed()
	if LOGGING_TO_SHARD == true then
		local isBusy = shard.IsBusy()
		if not isBusy then
			LOGGING_TO_SHARD = true
			StartGame()
		else
			Warn("LOGIN","Cant enter to shard : shard is busy")
		end
	end	
end

-- event ON_LOGIN_END result Strings
Global( "LOGIN_END_LOGIN_SUCCESS", "ENUM_LoginResult_LOGINSUCCESS" )
Global( "LOGIN_END_AUTHSERVICENOTFOUND", "ENUM_LoginResult_AUTHSERVICENOTFOUND" )
Global( "LOGIN_END_OTHERCLIENTINGAME", "ENUM_LoginResult_OTHERCLIENTINGAME" )
Global( "LOGIN_END_WRONGVERSION", "ENUM_LoginResult_WRONGVERSION" )
Global( "LOGIN_END_ERROR", "ENUM_LoginResult_ERROR" )
Global( "LOGIN_END_UNEXPECTEDDATA", "ENUM_LoginResult_UNEXPECTEDDATA" )
Global( "LOGIN_END_CLIENTNOTFOUND", "ENUM_LoginResult_CLIENTNOTFOUND" )
Global( "LOGIN_END_WRONGPASSWORD", "ENUM_LoginResult_WRONGPASSWORD" )
Global( "LOGIN_END_BANNED", "ENUM_LoginResult_BANNED" )
function OnLoginFailed(params)
	cLog( "login failed param=" .. params.sysResult .. " try=" .. tostring(AmountTryLogin) )

	if params.sysResult == LOGIN_END_LOGIN_SUCCESS then
	    AmountTryLogin = 0
	    
	elseif params.sysResult == LOGIN_END_UNEXPECTEDDATA or params.sysResult == LOGIN_END_OTHERCLIENTINGAME then
	    if AmountTryLogin < AmountTryLoginMax then
			common.LogInfo( tostring( AmountTryLogin ))
	    	AmountTryLogin = AmountTryLogin + 1
        	MainMenuLogin()
        else
            Warn( "LOGIN","Cant Login: " .. tostring( params.sysResult ))
        end
        
    elseif params.sysResult == LOGIN_END_WRONGVERSION then
        Warn( "LOGIN","Cant Login: " .. tostring( params.sysResult ) .. " " .. params.clientVersion .. "!=" .. params.serverVersion )

	else
		Warn( "LOGIN","Cant Login: " .. tostring( params.sysResult ))
	end
end

function OnLoginStart()
	LOGGING_TO_SHARD = false
end

function OnLoginConnectionFailed(params)
	if params.sysResult ~= "ENUM_ECS_OK" then
		Warn( "LOGIN","Connection lost: " .. params.sysResult )
	end
end

function Init()          
	LOGIN = debugCommon.ToWString( developerAddon.GetParam( "login" ))
	PASS = debugCommon.ToWString( developerAddon.GetParam( "password" ))
	AVATAR = debugCommon.ToWString( developerAddon.GetParam( "avatar" ))

	LOGGING_TO_SHARD = true
	
	if common.GetStateDebugName() == "class Game::MainMenu" then
		MainMenuLogin()
	end
    common.RegisterEventHandler( OnLoginGameStateChanged, "EVENT_GAME_STATE_CHANGED" )
	common.RegisterEventHandler( OnLoggedIn, "EVENT_LOGGED_IN" )
	common.RegisterEventHandler( OnLoginFailed, "EVENT_LOGIN_FAILED" )
	
	common.RegisterEventHandler( OnConnectShardProgress, "EVENT_CONNECT_SHARD_PROGRESS" )
	
	
	common.RegisterEventHandler( OnConnectionShardSucceed, "EVENT_CONNECT_SHARD_SUCCEED" )
	common.RegisterEventHandler( OnConnectionShardFailed, "EVENT_CONNECT_SHARD_FAILED" )
	common.RegisterEventHandler( OnShardChanged, "EVENT_SHARD_CHANGED" )
	common.RegisterEventHandler( OnLoginStart, "EVENT_LOGIN_START" )

	common.RegisterEventHandler( OnLoginConnectionFailed, "EVENT_CONNECTION_FAILED" )
end

Init()