Global( "LOGIN", nil )
Global( "PASS", nil )
Global( "AVATAR", nil )
Global( "SHARD_AVATARS", nil )
Global( "SHARD_NAMES", nil )
Global( "FLAG_EXIT", false )
Global( "FLAG_AVATAR_CREATE", false )
Global( "FLAG_AVATAR_DELETE", false )

Global( "AVATAR_TEMPLATE", "AutoWarrior" )

Global( "ERROR_CODE", nil )

-- переменная включающая лог либы
Global( "DEBUG_MODE", true )
Global( "ERROR_FUNC", nil )
-- exit cods
Global( "EXIT_CODE_SUCCESS", 0  )
Global( "EXIT_CODE_UNKNOWN", -1 )
Global( "EXIT_CODE_SCRIPT_ERROR",   1  )
Global( "EXIT_CODE_CONNECTION_ERROR",   10  )

Global( "COUNT_CONFIRM", 0 )
Global( "MAX_ERROR_COUNT", 20 )
Global( "LOGGED_TO_ACCOUNT_SERVER", false )
Global( "GAME_STATE_MISSION", false )
Global( "GAME_STATE_MAINMENU", false )
Global( "CUR_SHARD_INDEX", 1 )
Global( "LOGIN_CUR_SHARD_INDEX", nil ) -- номер шарда на который смогли зайти
Global( "NUM_SHARDS", nil )
Global( "WRONG_VERSION", false )
Global( "ACC_BANNED", false )
Global( "WRONG_AUTH_INFO", false )
Global( "CHECK_SHARD_SUCCEED", false )
Global( "CHECK_SHARD_FAILED", false )
Global( "LOGIN_RELOGIN", false )

Global( "LOGIN_TIME_LAG", 0 )

Global( "SendMsgHttp", nil)
Global( "ON_LOGIN_IN", false) 

Global( "LOGIN_TEST_NAME", nil )


function LoginLog(text)
	if DEBUG_MODE then
		Log(text,"Login")
	end
end

function InitShards()
	SHARD_NAMES = {}
	table.insert( SHARD_NAMES, "auto" )
	NUM_SHARDS = GetTableSize( SHARD_NAMES )
	CUR_SHARD_INDEX = 1
end

function GetShardLag()
	return LOGIN_TIME_LAG
end
----------------------------- LOGOUT --------------------------------
Global( "LIB_ERROR_CODE", -1 )
Global( "LOGOUT_WITHQUIT", false )
function SendExitEvent()     
	Logout(FLAG_EXIT)
end
-- обычная функция выхода из теста при успешном выполнении
function Success( testName, isNeedToExit )
	if SendMsgHttp ~= nil then
		SendMsgHttp("Success!")
	end
	LIB_ERROR_CODE = EXIT_CODE_SUCCESS
	LogSuccess( testName )
	if isNeedToExit == true then
		Logout( true )
	else
		SendExitEvent()	
	end
end 
-- обычная функция при выходе из теста по ошибке
function Warn( testName, textCode, isNeedToExit )
	if SendMsgHttp ~= nil then
		SendMsgHttp(tostring(textCode))
	end
	
	if LIB_ERROR_CODE ~= EXIT_CODE_CONNECTION_ERROR then
		LIB_ERROR_CODE = EXIT_CODE_SCRIPT_ERROR
	end
	LogErr( tostring( textCode ) .. " Error code " .. LIB_ERROR_CODE, testName )
	if isNeedToExit == true then
		Logout( true )
	else
		SendExitEvent()
	end
end

function LoginWarn( textCode, isNeedToExit )
	local testName = LOGIN_TEST_NAME
	if testName == nil and TEST_NAME ~= nil then
		testName = TEST_NAME
	end
	if testName == nil then
		testName = "Unknown test"
	end
	
	Warn( testName, textCode, isNeedToExit )
end

function ShowWarning( params )
	Warn( params.testName, params.text )
end

-- функиция выхода из игры в параметрах (с закрытием окна)
function Logout( withQuit )
	LOGOUT_WITHQUIT = withQuit
	Log( "logout " .. tostring( withQuit ))
	if LIB_ERROR_CODE  == EXIT_CODE_UNKNOWN then
		LIB_ERROR_CODE = EXIT_CODE_SUCCESS
	end
	
	local state = common.GetStateDebugName()
	if state == "class Game::MainMenu" then
		COUNT_CONFIRM = 0
  		ShardLogout()
	elseif state == "class Game::Mission" then
		COUNT_CONFIRM = 0
		LogoutFromMission(ShardLogout)
	else
		Log( "logout 2 " .. tostring( withQuit ) )
		if withQuit then
			CloseGame()
		else
			developerAddon.FinishAddon()
		end
	end
end
-- ф-ия выхода из миссии, в параметрах - следущая функция после завершения выхода
function LogoutFromMission( NextFunc )
	if GAME_STATE_MISSION then
		if COUNT_CONFIRM < MAX_ERROR_COUNT then
			COUNT_CONFIRM = COUNT_CONFIRM + 1
			if not unit.IsInCombat( avatar.GetId() ) then
				LoginLog( "Try leave mission... not in combat" )
				mission.Logout()
				--StartPrivateTimer( 5000, LogoutFromMission, NextFunc )
				StartPrivateCheckTimer( 5000, CheckGameStateMission, nil, LogoutFromMission, NextFunc, LogoutFromMission, NextFunc )
			else
				LoginLog( "avatar in combat kill all aggro mobs, wait 10 sec and try logout again..." )
				LoginLog( "aggro mobs:" )
				local aggromobss = GetAggroMobsIds()
				for index, id in aggromobss do
					LoginLog( "aggro mob: " .. debugCommon.FromWString( object.GetName( id )) .. "   debugName=" .. qaMission.UnitGetXDB( id ))
					DeSummon( id, Log, Log)
					break
					--DisintagrateMob( qaMission.UnitGetXDB( id ) )
				end
				StartPrivateTimer( 10000, LogoutFromMission, NextFunc )
--				mission.Logout()
				--StartPrivateTimer( 70000, LogoutFromMission, NextFunc )
--				StartPrivateCheckTimer( 70000, CheckGameStateMission, nil, LogoutFromMission, NextFunc, LogoutFromMission, NextFunc )
			end
		else
			COUNT_CONFIRM = 0
			LoginWarn( "Cant logout from Mission "..tostring(MAX_ERROR_COUNT).." times" )
		end
	else
		COUNT_CONFIRM = 0
		NextFunc()
	end
end
-- ф-ия Выхода из миссии, с принудительным последущим выходом с шарда
function MissionLogout(fivesec)
	if fivesec == nil then
		COUNT_CONFIRM = 0
		LogoutFromMission(ShardLogout)
	else
		COUNT_CONFIRM = 0
		StartPrivateTimer(5000, LogoutFromMission, ShardLogout )
	end
end
-- ф-ия выхода с шарда и акк сервера
function ShardLogout(nextFunc)
	--LoginLog( "nextFunc "..tostring(nextFunc).." type "..type(nextFunc) )
	if LOGGED_TO_ACCOUNT_SERVER then
		if COUNT_CONFIRM < MAX_ERROR_COUNT then
		LoginLog( "Try logout from mainMenu.." )
		COUNT_CONFIRM = COUNT_CONFIRM + 1
		mainMenu.Logout()
		--StartPrivateTimer(5000,ShardLogout,nil)
		StartPrivateCheckTimer( 5000, CheckLoggedToAccountServer, nil, ShardLogout, nextFunc, ShardLogout, nextFunc )
		else
			COUNT_CONFIRM = 0
			LoginWarn( "Cant logout from shard and acc server "..tostring(MAX_ERROR_COUNT).." times" )
		end
	else
		if nextFunc ~= nil then
			nextFunc()
		else
			Log( "Shard logout" )
			if LOGOUT_WITHQUIT then
				CloseGame( )
			else
				FinishAddon( )
			end
		end
	end
end
-- ф-ия закрытия игры, вызывает QuitGame
function CloseGame()
	debugCommon.SetErrorReturn( LIB_ERROR_CODE )
	LoginLog( "Set Error Code to: " .. tostring( LIB_ERROR_CODE ))
	QuitGame( )
end
-- ф-иф завершения дев аддона, для запуска след в сьюте
function FinishAddon()
	LoginLog( "Finish current addon!" )
	developerAddon.FinishAddon()
end
-- ф-ия закрытия окна игры
function QuitGame()
	LoginLog( "Quit Game!" )
	common.QuitGame()
end
------------RESTART without dissconnect from account server and shard
function Restart(name)
	if type(name) == "string" then
		AVATAR = debugCommon.ToWString(name)
	end
	FLAG_AVATAR_DELETE = FLAG_AVATAR_CREATE
	LogoutFromMission(StartGame)
end
---- Restart with disconnect from acc server
function RestartWithLogout(login, avatar)
	if login ~= nil and avatar ~= nil then
		AVATAR = avatar
		LOGIN = login
	end
	LoginLog( "Restart With Logout" )
	LogoutFromMission(RestartFromShard)
end

function RestartFromShard()
	LoginLog( "Restart From Shard" )
	ShardLogout(MainMenuLogin)
end
--------- EVENTS -------------------------------------------------------------
-- заход на шард
function OnLoginGameStateChanged( params )
	if params.stateDebugName == "class Game::MainMenu" then
		GAME_STATE_MAINMENU = params.registered
	end
	if params.stateDebugName == "class Game::Mission" then
		GAME_STATE_MISSION = params.registered
		if GAME_STATE_MISSION then
			StopPrivateTimer()
			ON_LOGIN_IN = false
			LoginLog("Game State Changed to Mission !!!")
			--RestartPrivateTimer()
		end
	end
end
function CheckGameStateMission()
	return not GAME_STATE_MISSION
end

function CheckShardIsBusy()
	return shard.IsValid() == true and shard.IsBusy() == false
end
--- Функция входа в игру с шарда.
function StartGame()
	if not LOGGED_TO_ACCOUNT_SERVER then
		return WaitShardReconnect("Fail StartGame on lost connection to account server")
	end
	if not shard.IsValid() then
		if COUNT_CONFIRM < MAX_ERROR_COUNT then
			COUNT_CONFIRM = COUNT_CONFIRM + 1
			LoginLog( "ReTry StartGame... shard.IsValid() = false " )
			return StartPrivateTimer(5000,StartGame,nil)
		else
			COUNT_CONFIRM = 0
			WaitShardReconnect("Fail 20 times shard.IsValid() = false")
		end
	end
	if shard.IsBusy() then
		if COUNT_CONFIRM < MAX_ERROR_COUNT then
			COUNT_CONFIRM = COUNT_CONFIRM + 1
			LoginLog( "ReTry StartGame... shard.IsBusy() = true " )
			--return StartPrivateTimer(5000,StartGame,nil)
			return StartPrivateCheckTimer( 5000, CheckShardIsBusy, nil, StartGame, nil, StartGame, nil )
		else
			COUNT_CONFIRM = 0
			WaitShardReconnect("Fail 20 times shard.IsBusy() = true")
		end
	end
	
	--LoginLog( "shard is valid and not busy" )
	local avatarsList = shard.GetAvatars()
	if SHARD_AVATARS ~= nil then
		local noavatar = "fffgghheehhhhsskjkk"
		local avs
		local numAvl = 0
		local numAvc = 0
		for ii, avl in avatarsList do
			numAvl = numAvl + 1
			avs = debugCommon.FromWString(avl)
			numAvc = 0
			for ij, avc in SHARD_AVATARS do
				numAvc = numAvc + 1
				if avc == avs then
					avs = noavatar
				end
			end
			if avs ~= noavatar then -- FAIL
				if type(ERROR_FUNC) == "function" then
					StopPrivateTimer()
					return ERROR_FUNC("find wrong avatar "..avs)
				end
				LoginLog("cant find avatar "..avs)
			end
		end
		if numAvl ~= numAvc then -- FAIL
			if type(ERROR_FUNC) == "function" then
				StopPrivateTimer()
				return ERROR_FUNC("Number avatars on shard "..tostring(numAvl).." vs "..tostring(numAvc).." number avatars in list")
			end
			LoginLog("Number avatars on shard "..tostring(numAvl).." vs "..tostring(numAvc).." number avatars in list")
		end
	end
	local exists = false
	local av = AVATAR
	for index, name in avatarsList do
		if string.lower( debugCommon.FromWString( name )) == string.lower( debugCommon.FromWString( AVATAR )) then
			exists = true
			break
		end	
	end	
	if exists == true then
		LoginLog("Avatar exists on shard ".. debugCommon.FromWString(AVATAR))
		if not FLAG_AVATAR_DELETE then
			StartPrivateTimer(60000,WaitShardReconnect,"Fail timeout to shard.StartGame( "..debugCommon.FromWString(AVATAR).." )")
			LoginLog("Try shard.StartGame( "..debugCommon.FromWString(AVATAR).." )")
			shard.StartGame( av )
		else
			LoginLog("Try delete avatar "..debugCommon.FromWString(AVATAR).." )")
			shard.DeleteAvatar( AVATAR )
			return StartPrivateTimer(3000, StartGame, nil )
		end
	else
		FLAG_AVATAR_DELETE = false
		LoginLog("Avatar not exists on shard ".. debugCommon.FromWString(AVATAR))
		if FLAG_AVATAR_CREATE then
			LoginLog("Try create avatar Name: ".. debugCommon.FromWString(AVATAR).." Template: "..AVATAR_TEMPLATE)
			shard.CreateAvatarByClassName( AVATAR, debugCommon.ToWString(AVATAR_TEMPLATE) )
			return StartPrivateTimer(3000, StartGame, nil )
		end
		WaitShardReconnect("Fail "..debugCommon.FromWString(AVATAR).." don't exists on shard")
	end
end
    

--- эвент прислыается при неуспешном логине на шард
function OnConnectShardFailed( params )
	if params.sysResult == "ENUM_LoginResult_OTHERCLIENTINGAME" then
		LoginLog("Connect to Shard Failed : other client in game. try connect 1 min")
		StartPrivateTimer( 10000, MainMenuLogin, nil )
	else
		LoginLog("Connect to Shard Failed "..params.sysResult)
		WRONG_VERSION = ( params.sysResult == "ENUM_LoginResult_WRONGVERSION" or params.sysResult == "ENUM_LoginResult_SERVERERROR")
		ACC_BANNED = ( params.sysResult == "ENUM_LoginResult_BANNED" )
		WRONG_AUTH_INFO = ( params.sysResult == "ENUM_LoginResult_WRONGAUTHINFO" )
	end	
end
--- эвент присылвается при успегном логине на шард
function OnConnectShardSucceed()
	LOGIN_CUR_SHARD_INDEX = CUR_SHARD_INDEX
	StopPrivateTimer()
	LoginLog( "Connect to shard Succeed " )
	COUNT_CONFIRM = 0
	LOGIN_TIME_LAG = TIME_SEC - LOGIN_TIME_LAG
	LoginLog( "Try StartGame " )
	StartGame()

end
-- аналог вышевзятого
function OnEnterShard()
	LoginLog( "Conection on shard established" )
end
--- эвент прогресса входа на шард
function OnConnectShardProgress( params )
	RestartPrivateTimer()
end
----- МЕГА ЭВЕНТ ЧЕ С НИМ ДЕЛАТЬ ХЗ
function OnConnectionFailed(params)
	LoginLog( "Connection to server lost: " .. params.sysResult )
	StopAllTimers()
	if params.sysResult == "ENUM_ECS_WRONG_VERSION" then
		WRONG_VERSION = true
	elseif params.sysResult == "ENUM_ECS_LOST" or params.sysResult == "ENUM_ECS_CLOSED_BY_SERVER" then
		StartPrivateTimer(1000,WaitShardReconnect,"Connection to shard lost: " .. params.sysResult)
		return
	elseif params.sysResult ~= "ENUM_ECS_OK" then
		LIB_ERROR_CODE = EXIT_CODE_CONNECTION_ERROR
		if not ON_LOGIN_IN then
			WaitShardReconnect("Connection to shard lost: " .. params.sysResult)
		else
			StartPrivateTimer(60000,MainMenuLogin,nil)
		end
	end
end
----------------------------------------------------------------------------------------------
function WaitShardReconnect(text)
	if type(ERROR_FUNC) == "function" then
		StopPrivateTimer()
		return ERROR_FUNC("Global",text,FLAG_EXIT)
	end
	LoginLog( "WaitShardReconnect " .. text )
	if LOGGED_TO_ACCOUNT_SERVER then 
		if COUNT_CONFIRM < MAX_ERROR_COUNT then
			local gamestate = common.GetStateDebugName()
			Log("Game State "..tostring(gamestate).." ----------------------============================")
			if gamestate == "class Game::Mission" then
				return StartPrivateTimer(1000,WaitShardReconnect,text)
			end
			if mainMenu ~= nil then
				mainMenu.Logout()
				COUNT_CONFIRM = COUNT_CONFIRM + 1
				StartPrivateTimer(5000,WaitShardReconnect,"Fail timeout to mainMenu.Logout()")
			else
				StartPrivateTimer(1000,WaitShardReconnect,text.." and mainMenu = nil")
			end
		else
			LoginWarn( "Cant logout "..tostring(MAX_ERROR_COUNT).." times" )
		end
	else
		COUNT_CONFIRM = 0
		StopAllTimers()
		LoginLog("wait 5 min")
		return StartPrivateTimer(300000,MainMenuLogin, nil)
	end
end
---- заходим на конкретный шард несколько раз, если не получается возвращаем в заход по списку.
function ConnectToFindingShard(shardWString)
	if not LOGGED_TO_ACCOUNT_SERVER then
		return WaitShardReconnect("Fail ConnectToFindingShard on lost connection to account server ")
	end
	if COUNT_CONFIRM < MAX_ERROR_COUNT then
		COUNT_CONFIRM = COUNT_CONFIRM + 1
		if not WRONG_VERSION then
			StartPrivateTimer(30000, ConnectToFindingShard, shardWString)
			CHECK_SHARD_SUCCEED = false
			CHECK_SHARD_FAILED = false
			LoginLog( "Try connect to shard. name = " .. debugCommon.FromWString(shardWString) )
			account.ConnectShard( shardWString )
		else
			LoginWarn( "Cant login to account server WRONGVERSION "..tostring(WRONG_VERSION))
		end
	else
		COUNT_CONFIRM = 0
		LoginLog( "cant connect to shard 20 times name = " .. debugCommon.FromWString(shardWString) )
		ShardConnect()
	end
end
--------- Заход на шард по списку, если находим в списке доступных отдаем в заход по конкретному шарду
function ShardConnect()
	if not LOGGED_TO_ACCOUNT_SERVER then
		return WaitShardReconnect("Fail ShardConnect on lost connection to account server ")
	end

	if CUR_SHARD_INDEX > NUM_SHARDS then
		return WaitShardReconnect("Fail cant connect to all shards in list")
	else
		local shards = account.GetShardsInfo()
		for index, shard in shards do
			if debugCommon.FromWString( shard.name ) == SHARD_NAMES[ CUR_SHARD_INDEX ] then
				LoginLog( "Find shard "..debugCommon.FromWString(shard.name).." from user list" )
				CUR_SHARD_INDEX = CUR_SHARD_INDEX + 1
				return ConnectToFindingShard( shard.name )
			end
		end
		LoginLog( "can't find shard. name=" .. SHARD_NAMES[ CUR_SHARD_INDEX ] )
		CUR_SHARD_INDEX = CUR_SHARD_INDEX + 1
		return ShardConnect()
	end
end
--- эвент о том что логин начался
function OnLoginStart()
	
end
---- Эвент о ошибках входа на аккаунт сервер
function OnLoginFailed(params)
	LoginLog( "Fail to connect to account server "..params.sysResult )
	WRONG_VERSION = ( params.sysResult == "ENUM_LoginResult_WRONGVERSION" or params.sysResult == "ENUM_LoginResult_SERVERERROR" )
	ACC_BANNED = ( params.sysResult == "ENUM_LoginResult_BANNED" )
	WRONG_AUTH_INFO = ( params.sysResult == "ENUM_LoginResult_WRONGAUTHINFO" )
	if LOGIN_RELOGIN == true then
		StartPrivateTimer( 2000, MainMenuLogin )
	end	
end
---- Эвент о том что мы зашли на аккаунт сервер
function OnLoggedIn()
	LoginLog("Open connection to account server")
	LOGGED_TO_ACCOUNT_SERVER = true
	if not LOGIN_RELOGIN then
		StopPrivateTimer()
		MainMenuLogin()
	else
		LOGIN_RELOGIN = false
		COUNT_CONFIRM = 0
		CUR_SHARD_INDEX = 1
		LoginLog( "Try select shard" )
		StartPrivateTimer(1000,ShardConnect, nil)	
	end
end
------Эвент о том что мы вышли/выкинуло с аккаунт сервера
function OnLoggedOut()
	LoginLog("Closed connect to account server")
	LOGGED_TO_ACCOUNT_SERVER = false
end
function OnLoginProgress( params )
	RestartPrivateTimer()
end

function CheckLoggedToAccountServer()
	return not LOGGED_TO_ACCOUNT_SERVER
end
---- заход в на аккаунт сервер несколько раз, если в игру вошли переходим в выбор шарда
function MainMenuLogin(fromThis)
	Log("mainmenu")
	if fromThis == nil then
		LOGIN_TIME_LAG = TIME_SEC
	end
	if COUNT_CONFIRM < MAX_ERROR_COUNT then
		COUNT_CONFIRM = COUNT_CONFIRM + 1
		if not LOGGED_TO_ACCOUNT_SERVER then
				if not ( WRONG_VERSION and WRONG_AUTH_INFO and ACC_BANNED ) then
					StartPrivateTimer(60000,MainMenuLogin,true)
					LoginLog( "Try mainMenu.Login "..debugCommon.FromWString(LOGIN) )
					ON_LOGIN_IN = true
					mainMenu.Login( LOGIN, LOGIN )
				else
					LoginWarn( "Cant login to account server WRONGVERSION "..tostring(WRONG_VERSION).." WRONGAUTHINFO "..tostring(WRONG_AUTH_INFO).." BANNED "..tostring(ACC_BANNED) )
				end
		else
			LoginLog( "Login dont need we have connection to account server" )
			LOGIN_RELOGIN = true
			LoginLog( "Try Relogin from MainMenu " )
			StartTimer( 1500, mainMenu.Relogin )
		end		
		
	else
		LoginWarn( "Cant login to account server "..tostring(MAX_ERROR_COUNT).." times" )
	end
end
------------ подтверждаем ЕУЛУ несколько раз, если получается переходим в логин аккаунта
function ConfirmEula()
	if common.IsEulaAccepted() == false then
		LoginLog("Eula does not accepted")
		if COUNT_CONFIRM < MAX_ERROR_COUNT then
			LoginLog( "accepting EULA..." )
			common.ConfirmAcceptEula()
			COUNT_CONFIRM = COUNT_CONFIRM + 1
			StartPrivateTimer( 1000, ConfirmEula )
			return
		else
			LoginWarn( "Cant accept Eula "..tostring(MAX_ERROR_COUNT).." times" )
		end
	else
		COUNT_CONFIRM = 0
		LoginLog( "Eula accepted" )
		LoginLog( "Try login to account server" )
		return MainMenuLogin()
	end
end

-- КОпия для логина
function GetSizeForLogin( t )
	local count = 0
	for index in t do
	    count = count + 1
	end

	return count
end

function InitLoging(params)
    common.RegisterEventHandler( OnLoginGameStateChanged, "EVENT_GAME_STATE_CHANGED" )
	-- эвенты на аккунт сервере
	common.RegisterEventHandler( OnLoggedIn, "EVENT_LOGGED_IN" )
	common.RegisterEventHandler( OnLoginProgress, "EVENT_LOGIN_PROGRESS" )
	
	common.RegisterEventHandler( OnLoggedOut, "EVENT_LOGGED_OUT" )
	-- информационный эвент - смотрим на возможный
	common.RegisterEventHandler( OnLoginFailed, "EVENT_LOGIN_FAILED" )
	common.RegisterEventHandler( OnLoginStart, "EVENT_LOGIN_START" )

	-- эвенты на шард вход
	
	common.RegisterEventHandler( OnConnectShardProgress, "EVENT_CONNECT_SHARD_PROGRESS" )
	common.RegisterEventHandler( OnConnectShardSucceed, "EVENT_CONNECT_SHARD_SUCCEED" )
	common.RegisterEventHandler( OnEnterShard, "EVENT_ENTER_SHARD")
	common.RegisterEventHandler( OnConnectShardFailed, "EVENT_CONNECT_SHARD_FAILED" )
	

	--- странный эвент смотрим
	common.RegisterEventHandler( OnConnectionFailed, "EVENT_CONNECTION_FAILED" )

    LOGIN = debugCommon.ToWString(params.login)
	AVATAR = debugCommon.ToWString(params.avatar)
	if params.pass ~= "" then
		PASS = debugCommon.ToWString(params.pass)
	else
		PASS = debugCommon.ToWString(params.avatar)
	end
	
	if GlobalLoginParams ~= nil then
		SHARD_NAMES = {}
		Log("Get Params from GlobalLoginParams.lua")
		GlobalLoginParams()
		NUM_SHARDS = GetSizeForLogin( SHARD_NAMES )
		CUR_SHARD_INDEX = 1
	else
		InitShards()
	end
	if params.shards ~= nil then
		SHARD_NAMES = params.shards
		NUM_SHARDS = GetSizeForLogin( SHARD_NAMES )
		CUR_SHARD_INDEX = 1
	end
	
	if params.avatars ~= nil then
		SHARD_AVATARS = params.avatars
	end
	if params.debugMode ~= nil then
		DEBUG_MODE = params.debugMode
	end
	if params.errorFunc ~= nil then
		if type(params.errorFunc) == "function" then
			ERROR_FUNC = params.errorFunc
		elseif type(params.errorFunc) == "boolean" then
			if not params.errorFunc then
				ERROR_FUNC = nil
			end
		end
	end
	if params.create ~= nil then
		FLAG_AVATAR_CREATE = true
		AVATAR_TEMPLATE = params.create
	end
	if params.delete ~= nil then
		FLAG_AVATAR_DELETE = true
	end
	if params.flagExit ~= nil then
		FLAG_EXIT = params.flagExit
	end
	
	if params.testName ~= nil then
		LOGIN_TEST_NAME = params.testName
	end

	debugCommon.SetErrorReturn( -1 )
	LoginLog("Try to accept Eula if need")
	ConfirmEula()
end
