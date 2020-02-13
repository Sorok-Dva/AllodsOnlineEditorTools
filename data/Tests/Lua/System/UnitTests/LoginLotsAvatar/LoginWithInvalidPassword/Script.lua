Global( "TEST_NAME", "LoginWithInvalidPassword; author: Liventsev Andrey, date: 14.01.09, bug 53508" )

-- аддон пытается залогиниться под неверными логинами, потом под верным

Global( "INDEX_OF_TRYES", nil )
Global( "PASSWORDS", nil )

function CheckStateMainMenu()
	return common.GetStateDebugName() == "class Game::MainMenu"
end

function MainMenuLogin()
	Log( "main menu login" )
	StartTimer( 10000, ErrorFunc, "EVENT_LOGIN_FAILED did not come" )
	mainMenu.Login( debugCommon.ToWString( LOGIN ), debugCommon.ToWString( PASSWORDS[INDEX_OF_TRYES] ))
end

function ErrorFunc( text )
	Warn( TEST_NAME, text )
end

----------------------------- EVENTS -----------------------------------

function OnLoggedIn()
	if INDEX_OF_TRYES ~= 3 then
		ErrorFunc( "Can connect with wrong password. login=" .. LOGIN .. " password=" .. PASSWORDS[INDEX_OF_TRYES] )
	else
		Success( TEST_NAME )
	end
end

function OnLoginFailed( params )
	Log( "Login failed cause " .. params.sysResult .. ". Using password " .. PASSWORDS[INDEX_OF_TRYES] )
	if INDEX_OF_TRYES == 3 then
		ErrorFunc( "Can't login with correct password"  )
	else
		
		INDEX_OF_TRYES = INDEX_OF_TRYES + 1
		StartTimer( 3000, MainMenuLogin )
	end
end

function Init()
	LOGIN = developerAddon.GetParam( "login")
	
	INDEX_OF_TRYES = 1
	PASSWORDS = {}
	table.insert( PASSWORDS, "WrongPassword_1" )
	table.insert( PASSWORDS, "WrongPassword_2" )
	table.insert( PASSWORDS, developerAddon.GetParam( "password" ))

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
	
	StartPrivateCheckTimer( 5000, CheckStateMainMenu, nil, Warn, "Cant Login: can't get MainMenu state", MainMenuLogin )
end

Init()