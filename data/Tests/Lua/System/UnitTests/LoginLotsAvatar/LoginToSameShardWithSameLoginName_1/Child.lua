Global( "TEST_NAME", "LoginToSameShardWithSameLoginName_1_Child; author: Liventsev Andrey, date: 14.01.09, bug 53508" )

Global( "L_LOGIN", nil )
Global( "L_PASSWORD", nil )

function CheckStateMainMenu()
	return common.GetStateDebugName() == "class Game::MainMenu"
end

function MainMenuLogin()
	Log( "main menu login" )
	debugCommon.SetErrorReturn( -1 )
	mainMenu.Login( debugCommon.ToWString( L_LOGIN ), debugCommon.ToWString( L_PASSWORD ))
end

function ErrorFunc( text )
	Warn( TEST_NAME, text, true )
end

function Done()
	Success( TEST_NAME, true )
end

----------------------------- EVENTS -----------------------------------

function OnLoginFailed( params )
	ErrorFunc( "Login failed cause " .. params.sysResult )
end

function OnLoggedIn()
	Log( "login success. connecting to shard " ..  SHARD_NAMES[1])
	account.ConnectShard( debugCommon.ToWString( SHARD_NAMES[1] ))
end

function OnLoginConnectionFailed( params )
	if params.sysResult ~= "ENUM_ECS_OK" then
		Log( "Connection to shard " .. debugCommon.FromWString( account.GetShardsInfo()[CUR_SHARD_INDEX-1].name ).. " lost: " .. params.sysResult )
		StartPrivateTimer( 3000, MainMenuLogin )
	end	
end

function OnConnectShardSucceed()
	ErrorFunc( "Can connect to shard when other account in game" )
end

function OnConnectShardFailed( params )
	if params.sysResult == "ENUM_LoginResult_OTHERCLIENTINGAME" then
		Log( "Connection to shard  failed cause " .. params.sysResult )
		Done()
	else
		OnLoggedIn()
	end	
end




function Init()
	InitShards()
	L_LOGIN = developerAddon.GetParam( "login" )
	L_PASSWORD = developerAddon.GetParam( "password" )
	
	if common.IsEulaAccepted() == false then
		Log( "accept EULA" )
		common.ConfirmAcceptEula()
	end
	
	SHARD_NAMES = {}
	GlobalLoginParams()
	NUM_SHARDS = GetSizeForLogin( SHARD_NAMES )
	CUR_SHARD_INDEX = 1
		
	common.RegisterEventHandler( OnLoggedIn, "EVENT_LOGGED_IN" )
	common.RegisterEventHandler( OnLoginFailed, "EVENT_LOGIN_FAILED" )
	common.RegisterEventHandler( OnConnectShardSucceed, "EVENT_CONNECT_SHARD_SUCCEED" )
	common.RegisterEventHandler( OnConnectShardFailed, "EVENT_CONNECT_SHARD_FAILED" )
	common.RegisterEventHandler( OnLoginConnectionFailed, "EVENT_CONNECTION_FAILED" )
	StartPrivateCheckTimer( 5000, CheckStateMainMenu, nil, Warn, "Cant Login: can't get MainMenu state", MainMenuLogin )
end
function CheckStateMainMenu()
	return common.GetStateDebugName() == "class Game::MainMenu"
end

Init()