
Global("TAKT_NUM",nil)
Global("TAKT_LEARN_NUM",nil)

Global("BOT_TAKT",nil)
Global("BOT_MOBLIST",nil)
Global("BOT_LEARN_TAKT",nil)

Global("BOT_LOGIN_NAME","luabot1")
Global("BOT_DELTA_X",50)
Global("BOT_INIT_X",50)
Global("BOT_MAX_X",950)
Global("BOT_DELTA_Y",25)
Global("BOT_INIT_Y",50)
Global("BOT_MAX_Y",950)
Global("TEST_NAME","KillBotAdvanced")
Global("LOGIN_ADVANCED", true) 
Global("INDEX", 0) 
Global("BOT_LEVEL", 0) 
Global("MOB_DIST", 25) 
Global("COUNT_KILLS",0)
Global("BOT_TIME_START",0)
Global("BOT_TIME_AVERAGE",0)
-- STATES
Global("BOT_STATE",3)
Global("BOT_SUCCESS_ST",0)
Global("BOT_WAIT_ST",1)
Global("BOT_KILL_BEE_ST",2)
Global("BOT_KILL_BEE_PREPARE",3)
Global("BOT_FARM_AL1",4)

Global("OnStateDebugNotify",nil)

function BotNextStep()
	LogToAccountFile("BotNextStep "..tostring(BOT_STATE))
	if BOT_STATE == BOT_KILL_BEE_ST then
		BotStatLog()
		StartKill()
	elseif BOT_STATE == BOT_KILL_BEE_PREPARE then
		BOT_STATE = BOT_KILL_BEE_ST
		BotStatInit()
		LevelUp( BOT_LEVEL, BOT_LEARN_TAKT, AltNormalize, Warn )
	elseif BOT_STATE == BOT_FARM_AL1 then
		local zoneTp = "Maps/Kania_AL1/MapResource.xdb"
		local zoneName = "Maps/Kania_AL1/Zones/ArchipelagoLeague1/ArchipelagoLeague1.xdb"
		local mobNames = {}
		table.insert(mobNames,"Creatures/Artiodactyl/Instances/Deer3_4.xdb")
		table.insert(mobNames,"Creatures/Snake/Asp/Instances/Asp3_4.xdb")
		InitRespawnMobs( mobNames, zoneName, zoneTp, BOT_MOBLIST, 20000, BotNextStep, Warn )
	elseif BOT_STATE == BOT_WAIT_ST then
		StartTimer(5000, BotNextStep,nil)
	elseif BOT_STATE == BOT_SUCCESS_ST then
		BotStatLog()
		Success(TEST_NAME)
	end
end

function SendMsgHttp(text)
	LogToAccountFile(BOT_LISTENER_ADDRESS.."/msg?bot="..BOT_LOGIN_NAME.."&msg="..text )
	qaCommon.HttpGET( BOT_LISTENER_ADDRESS.."/msg?bot="..BOT_LOGIN_NAME.."&msg="..text )
end
function StartKill( )
	Log("StartKill")
	--SendMsgHttp("ImStartKill!")
	BOT_TIME_START = TIME_SEC
	
	InitKillMob(nil,BOT_TAKT,100,EndKill,BotError,RangeFunction,BotError, 15000)
end

function RangeFunction(func, errorFunc, dist)
	local map = debugMission.GetMap()
	local mapName = "/"..map.debugName
	--local mob = "Tests/Mobs/AllLevels/Bee/Bee"..tostring(BOT_LEVEL)..".xdb" 
	local mob = "Tests/Mobs/AllLevels/TestSatyr/Satyr"..tostring(BOT_LEVEL)..".xdb" 
	--local mob = "Creatures/Snake/Asp/Instances/ZoneEmpire3/Asp14_15.(MobWorld).xdb" 
	--local mob = "Creatures/Cat/Lynx/Instances/ArchipelagoLeague2/Lynx12_13.xdb" 
	--local mob = "Creatures/BlackWidow/Instances/ArchipelagoEmpire1/Spider11_12.(MobWorld).xdb" 
	SummonMob( mob , mapName, 
				GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), dist ), 0, func, errorFunc )
end

function BotError(text)
	Log("Bot Error"..text)
	--Warn( TEST_NAME, text, true )
	EndKill({kill = not unit.IsDead( avatar.GetId() )})
end

function EndKill( params )
	COUNT_KILLS = COUNT_KILLS + 1
	LogToAccountFile("Kill - "..tostring(COUNT_KILLS))
	local time = TIME_SEC - BOT_TIME_START
	if BOT_TIME_AVERAGE == 0 then
		BOT_TIME_AVERAGE = time
	else
		BOT_TIME_AVERAGE = math.floor( (BOT_TIME_AVERAGE + time) / 2 )
	end
	SendMsgHttp("MyLevel:"..tostring(BOT_LEVEL)..";LastTime:"..tostring(time)..";Average:"..tostring(BOT_TIME_AVERAGE).."Kill:"..tostring(params.kill)..";count:"..tostring(COUNT_KILLS)..";")
	if not params.kill then
		qaMission.AvatarRevive()
		StartTimer(1000,AltNormalize,nil)
	else
		qaMission.AvatarRevive()
		StartTimer(300,TpToPos,nil)
	end
end

function CleanPlace()

	local units = avatar.GetUnitList()
	Log("CleanPlace ")
	for key, value in units do
		Log(tostring(value))
		if not unit.IsPlayer( value ) then
			Log("not player")
			if not unit.IsDead( value ) then
				Log("not dead")
			end
				local pos = GetPositionAtDistance(avatar.GetPos(), avatar.GetDir(), MOB_DIST)
				local dist = GetDistanceFromPosition( value, pos )
				Log("dist"..tostring(dist))
				if dist < ((BOT_DELTA_X / 2)-5) then
					Log("need desummon "..tostring(value))
					return DeSummon( value, CleanPlace, BotError)
				end
				dist = GetDistanceFromPosition( value, avatar.GetPos())
				if dist < ((BOT_DELTA_X / 2)-5) then
					Log("need desummon "..tostring(value))
					return DeSummon( value, CleanPlace, BotError)
				end
		end
	end
	RemoveAllBuffs()
	BotNextStep()
end

function AltNormalize()
	Log("Normalize ")
	qaMission.SendCustomMsg("normalize 0 0 0")
	StartTimer(1500, TpToPos, nil)
end
function TpToPos()
	Log("TpToPos ")
	qaMission.AvatarRevive()
	local name = object.GetName( avatar.GetId() )
	name = debugCommon.FromWString(name)
	local num = string.find(name, "[0-9]+")
	if num == nil then
		return Warn( TEST_NAME, "cannot find num in name")
	end
	num = string.sub(name,num)
	if num == "" then
		return Warn( TEST_NAME, "cannot find num in name")
	end
	LogToAccountFile("num find "..num)
	num = tonumber(num)
	local pos = GetPosForBot(num,1)
	if pos == nil then
		return Warn( TEST_NAME, "cant find pos")
	end
	LogToAccountFile("X - "..tostring(pos.X).." Y - "..tostring(pos.Y))
	MoveToPos( pos, CleanPlace, nil,3000)
end
function GetPosForBot(num, z)
	local numX_inLine = math.floor((BOT_MAX_X - BOT_INIT_X) / BOT_DELTA_X)
	local numY_inLine = math.floor((BOT_MAX_Y - BOT_INIT_Y) / BOT_DELTA_Y)
	local numPoints = numX_inLine * numY_inLine
	if numPoints < num then
		return nil
	end
	local y_coord = math.floor(num/ numX_inLine)
	local x_coord = num - (y_coord * numX_inLine)
	return {X = (x_coord * BOT_DELTA_X) + BOT_INIT_X, Y = (y_coord * BOT_DELTA_Y) + BOT_INIT_Y, Z = z}
end

function OnAvatarCreated( params )
	if LOGIN_ADVANCED then
		LOGIN_ADVANCED = false 
		--GetNewAvatar()
		
		qaMission.ListAvatars()
		StartTimer(10000,BotError,"Fail requestion ListAvatars")
		return
	end
	-- TODO
	SendMsgHttp("ImInGame!")
	BotNextStep()
	--LevelUp( BOT_LEVEL, BOT_LEARN_TAKT, AltNormalize, Warn )
	--LevelUp( BOT_LEVEL, BOT_LEARN_TAKT, Success, Warn  )
	--AltNormalize()
end

function GetNewAvatar()
	local new_avatar = debugCommon.ToWString("LuaBot"..tostring(INDEX))
	local new_login = debugCommon.ToWString("luabot"..tostring(INDEX))
	LogToAccountFile("LOGIN: "..debugCommon.FromWString(new_login))
	LogToAccountFile("AVATAR: "..debugCommon.FromWString(new_avatar))
	RestartWithLogout(new_login,new_avatar)	
end
-- Функция для адвансед логин, исползуется при параметре LOGIN_ADVANCED = true
-- приходит эвентом после
function OnDebugListAvatars( params )
--table of key, value
--key: number (int) - индекс [0..]
--value: WString - имя персонажа
--TODO polu4it LOGIN i AVATAR po sisteme
	LOGIN_ADVANCED = false
	StopTimer()
	ParamsToConsole(params,"EVENT_DEBUG_LIST_AVATARS" )
	local matching = nil
	local list = {}
	local avatarName = nil
	for key, value in params do
		avatarName = debugCommon.FromWString(value)
		matching = string.find (avatarName, "(LuaBot)" )
		if matching~=nil then
			matching = string.find(avatarName, "[0-9]+")
			list[value] = string.sub(avatarName,matching)
		end
	end
	ParamsToConsole(list,"list")
	local index = 1
	local find = true
	while find do
	    find = false
		index = index + 1
		for key, value in list do
	    	if index == tonumber(value) then
				find = true
				break
	    	end
		end
	end

	local new_avatar = debugCommon.ToWString("LuaBot"..tostring(index))
	local new_login = debugCommon.ToWString("luabot"..tostring(index))
	BOT_LOGIN_NAME = "luabot"..tostring(index)
	LogToAccountFile("LOGIN: "..debugCommon.FromWString(new_login))
	LogToAccountFile("AVATAR: "..debugCommon.FromWString(new_avatar))
	RestartWithLogout(new_login,new_avatar)
end    

function OnDebugNotify( params )
	local sender = debugCommon.FromWString( params.sender )
	local message = debugCommon.FromWString( params.message )

	local command = string.find(message, "BOT:")
	if command then
		if BOT_STATE == BOT_FARM_AL1 then
			RespStopFarm()
		end
		if message == "BOT:SUCCESS" then
			BOT_STATE = BOT_SUCCESS_ST
		elseif message == "BOT:WAIT" then
			BOT_STATE = BOT_WAIT_ST
		elseif message == "BOT:RESPAWN" then
			BOT_STATE = BOT_FARM_AL1
		elseif message == "BOT:FARMER" then
			BOT_STATE = BOT_KILL_BEE_PREPARE
		end
	end
	if OnStateDebugNotify ~= nil then
		OnStateDebugNotify( params )
	end
end
-------------------------------------------------------------------------------
-- INITIALIZATION
-------------------------------------------------------------------------------

function GetTaktiks(class,level)
	Log("Get Taktik "..class.." - "..level)
	---- find taktiks ------
	local check_takt = 0
	local num_takt = developerAddon.GetTacticsSize() -------------------------
	local i = 0
	local takt_num = nil
	local takt_learn_num = nil
	for i = 0, num_takt - 1, 1 do
		--Log("taktika "..tostring(i))
		check_takt = 0
		local takt = developerAddon.LoadTactics( i )
		if takt == nil then
			Warn( TEST_NAME, "taktik not found "..tostring(i), true )
			return nil
		end
		for key, value in takt[1].conditions do
			
			if debugCommon.FromWString(value.rule) == "class" then
				if string.upper(class) == string.upper(debugCommon.FromWString(value.param)) then
					check_takt = check_takt + 2
				end
			end
			if debugCommon.FromWString(value.rule) == "level_min" then
				if level >= tonumber(debugCommon.FromWString(value.param)) then
					check_takt = check_takt + 3
				end
			end
			if debugCommon.FromWString(value.rule) == "level_max" then
				if level <= tonumber(debugCommon.FromWString(value.param)) then
					check_takt = check_takt + 3
				end
			end
			if debugCommon.FromWString(value.rule) == "level" then
				if level == tonumber(debugCommon.FromWString(value.param)) then
					check_takt = check_takt + 6
				end
			end
			if debugCommon.FromWString(value.rule) == "range" then
				if tonumber(debugCommon.FromWString(value.param)) > 0 then
					check_takt = check_takt + 8
				else
					check_takt = check_takt + 16
				end
			end
			--Log("check_takt "..tostring(check_takt))
		end
		if check_takt == 16 then
			takt_num = i
		end
		if check_takt == 24 then
			takt_learn_num = i
		end
		if takt_num ~= nil and takt_learn_num ~= nil then
			break
		end
	end
	if takt_num == nil or takt_learn_num == nil then
		Warn( TEST_NAME, "cant find taktik", true )
		return nil 
	end
	Log("taktika find "..tostring(takt_num).." Learn takt "..tostring(takt_learn_num))
	BOT_TAKT = developerAddon.LoadTactics( takt_num )
	local learn = developerAddon.LoadTactics( takt_learn_num )	
	return learn 
	-- end find taktiks ---------------	
end

function Init()
	BOT_MOBLIST = developerAddon.LoadMobList()
	if BOT_MOBLIST == nil then
		return Warn( TEST_NAME, "error  mobList = nil", true )
	end
	local lvl_min = developerAddon.GetParam( "level_min" ) ----------------------
	local lvl_max = developerAddon.GetParam( "level_max" ) -----------------------
	if lvl_min == "" or lvl_max == "" then
		return Warn( TEST_NAME, "error cant read prams lvl_min or lvl_max", true )
	end
	lvl_min = tonumber(lvl_min)
	lvl_max = tonumber(lvl_max)
	if type(lvl_min) ~= "number" or type(lvl_max) ~= "number" then
		return Warn( TEST_NAME, "error  in lvl_min or lvl_max", true )
	end
	if lvl_min >= lvl_max then
		return Warn( TEST_NAME, "error lvl_min >= lvl_max", true )
	end
	local lvl = math.random ( lvl_min, lvl_max )
	BOT_LEVEL = lvl
	--------------------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	BOT_LEVEL = 40
	---------------------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	Log("random lvl - "..tostring(BOT_LEVEL))
	local class = developerAddon.GetParam( "class" ) ----------------------------
	if class == "" or type(class) ~= "string" then
		return Warn( TEST_NAME, "cannot read param class", true )
	end

	BOT_LEARN_TAKT = GetTaktiks(class,BOT_LEVEL)
	if BOT_LEARN_TAKT == nil then
		return
	end
	local index = developerAddon.GetParam( "index" ) 
	if index == "" then
		return Warn( TEST_NAME, "wrong index", true )
	end
	INDEX = tonumber(index)
	
	common.RegisterEventHandler( OnDebugListAvatars, "EVENT_DEBUG_LIST_AVATARS")
	common.RegisterEventHandler( OnDebugNotify, "EVENT_DEBUG_NOTIFY")
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	
	local botShards = {}
	if BOT_SHARD_NAME ~= nil then
		table.insert( botShards, BOT_SHARD_NAME )
	else
		botShards = SHARD_NAMES
	end
	
	local login
	if BOT_ACCOUNT_NAME ~= nil then
		local numb = 0
		if type(BOT_ACCOUNT_NAME) == "string" then
			numb = string.find(BOT_ACCOUNT_NAME,"[0-9]+")
			if numb == nil then
				return Warn( TEST_NAME, "wrong BOT_ACCOUNT_NAME - "..tostring(BOT_ACCOUNT_NAME), true )
			end
			numb = string.sub(BOT_ACCOUNT_NAME, numb)
			numb = tonumber(numb)
			if type(numb) ~= "number" then
				return Warn( TEST_NAME, "wrong BOT_ACCOUNT_NAME - "..tostring(BOT_ACCOUNT_NAME), true )
			end
		elseif type(BOT_ACCOUNT_NAME) == "number" then
			numb = BOT_ACCOUNT_NAME
		else
			return Warn( TEST_NAME, "wrong BOT_ACCOUNT_NAME - "..tostring(BOT_ACCOUNT_NAME), true )
		end
		LOGIN_ADVANCED = false
		BOT_LOGIN_NAME = "luabot"..tostring(numb)
		local avatar_name = "LuaBot"..tostring(numb)
		---------------------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		BOT_LEVEL = tonumber(numb)
		--BOT_LOGIN_NAME = "bj"
		--avatar_name = "BJ"
		---------------------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		login = {login = BOT_LOGIN_NAME,
					pass = BOT_LOGIN_NAME,
					avatar = avatar_name,
					create = "Auto"..class,
					delete = true,
					debugMode = true,
					shards = botShards,
					errorFunc = Warn,
					flagExit = true}
	else
		login = {login = developerAddon.GetParam( "login" ),
					pass = developerAddon.GetParam( "password" ),
					avatar = developerAddon.GetParam( "avatar" ),
					create = "Auto"..class,
					delete = true,
					debugMode = true,
					shards = botShards,
					errorFunc = Warn,
					flagExit = true}
	end
	SendMsgHttp("ImComingIn!")
	InitLoging(login)
end

-------------------------------------------------------------------------------


Init()
