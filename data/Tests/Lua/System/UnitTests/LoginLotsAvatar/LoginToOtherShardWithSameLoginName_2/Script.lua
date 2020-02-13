Global( "TEST_NAME", "LoginToOtherShardWithSameLoginName_2_Parent; author: Liventsev Andrey, date: 14.01.09, bug 53508" )

-- чилд коннектится нашард, а главный через 30 сек. коннектится на ДРУГОЙ шард, проверка на то, что главный аддон получит валидное сообщение
-- из-за невозможности общаться между аддонами пользоваться только в паре с LoginLotsAvatar_21

Global( "L_LOGIN", nil )
Global( "L_PASSWORD", nil )

Global( "SHARD_INDEX", nil )

function MainMenuLogin()
	Log( "main menu login" )
	debugCommon.SetErrorReturn( -1 )
	mainMenu.Login( debugCommon.ToWString( L_LOGIN ), debugCommon.ToWString( L_PASSWORD ))
end

function ErrorFunc( text )
	Warn( TEST_NAME, text )
end

----------------------------- EVENTS -----------------------------------

function OnLoginFailed( params )
	ErrorFunc( "Login failed cause " .. params.sysResult )
end

function OnLoggedIn()
	local shards = account.GetShardsInfo()
	if SHARD_INDEX > GetTableSize( shards ) then
		ErrorFunc( "Can't connect to all shards (not cause OTHERCLIENTINGAME)" )

	else
		local shardName = shards[SHARD_INDEX].name
		
		SHARD_INDEX = SHARD_INDEX + 1
		if shardName ~= SHARD_NAMES[LOGIN_CUR_SHARD_INDEX] then
			Log( "login success. connecting to shard " ..  debugCommon.FromWString( shardName ))
			account.ConnectShard( shardName )
		else
			Log( "same shard. try next" )
			OnLoggedIn()
		end	
	end
end

function OnLoginConnectionFailed( params )
	if params.sysResult ~= "ENUM_ECS_OK" then
		Log( "Connection to shard " .. debugCommon.FromWString( account.GetShardsInfo()[SHARD_INDEX-1].name ).. " lost: " .. params.sysResult )
		StartPrivateTimer( 3000, MainMenuLogin )
	end	
end

function OnConnectShardSucceed()
	ErrorFunc( "Can connect to shard when other account in game" )
end

function OnConnectShardFailed( params )
	if params.sysResult == "ENUM_LoginResult_OTHERCLIENTINGAME" then
		Log( "Connection to shard  failed cause " .. params.sysResult )
		Success( TEST_NAME )
	else
		OnLoggedIn()
	end	
end




function Init()
	InitShards()
	L_LOGIN = developerAddon.GetParam( "login" )
	L_PASSWORD = developerAddon.GetParam( "password" )
	
	SHARD_INDEX = 1
	SHARD_NAMES = {}
	GlobalLoginParams()
	NUM_SHARDS = GetSizeForLogin( SHARD_NAMES )
	CUR_SHARD_INDEX = 1
	
	if common.IsEulaAccepted() == false then
		Log( "accept EULA" )
		common.ConfirmAcceptEula()
	end
	
	common.RegisterEventHandler( OnLoggedIn, "EVENT_LOGGED_IN" )
	common.RegisterEventHandler( OnLoginFailed, "EVENT_LOGIN_FAILED" )
	common.RegisterEventHandler( OnConnectShardSucceed, "EVENT_CONNECT_SHARD_SUCCEED" )
	common.RegisterEventHandler( OnConnectShardFailed, "EVENT_CONNECT_SHARD_FAILED" )
	common.RegisterEventHandler( OnLoginConnectionFailed, "EVENT_CONNECTION_FAILED" )
	
	developerAddon.RunChildGame( "Child.(DeveloperAddon).xdb" , "  -silentMode" )
	StartTimer( 30000, MainMenuLogin )
end

Init()