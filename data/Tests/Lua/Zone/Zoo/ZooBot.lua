--
-- Global vars
--
-- проверяет отправителя сообщения и возвращает сообщение без префикса в удачном случае
Global("BOTNAME_PREFIX","ZooBotLogin:")
Global("BOTCLASS_PREFIX","MyClass:")
Global("BOTNUMBER_PREFIX","MyNumber:")
Global("BOTLEVEL_PREFIX","YourLevel:")
Global("BOTSTART_PREFIX","ZooStartBot:")
Global("BOTENEMY_PREFIX","YourEnemy:")
Global("BOTCODE_PREFIX","TaskCode:")
Global("BOTWRONG_ENEMY","ZooWrongEnemy:")
Global("BOTWRONG_FIGHT","ZooWrongFight:")
Global("BOTRESULT_PREFIX","WithResult:")
Global("BOTKILLTIME_PREFIX","KillTime:")
Global("BOTDAMAGE_PREFIX","DmgAvatar:")
Global("BOTDAMAGEUNIT_PREFIX","DmgUnit:")
Global("BOTMOBKIND_PREFIX","MobKind:")

Global("BOTDAMAGEUNITAA_PREFIX","DmgUnitAA:")
Global("BOTABILITIES_PREFIX","UnitAbil:")
Global("BOTACTION_QUIT","Quit")
Global("BOTACTION_PREFIX","Action:")
Global("BOTACTION_TIMEOUT","TimeOut")
Global("BOTTIMEOUT_ANSWER","ZooTimeout:")



--From Adddon
Global("BOT_TAKT",nil)
Global("BOT_NUMBER",nil)
Global("TEST_NAME","ZOO BOT : ")


--from avatar.Created
Global("BOT_CLASS",nil)
Global("BOT_NAME",nil)
Global("AVATAR_ID",nil)
Global("BOT_MAP_NAME",nil)

--from DebugShardNotify
Global("ENEMY_NAME",nil)
Global("TASK_CODE",nil)
Global("BOT_LEVEL",nil)
--for errors
Global("COUNT_BOT_RESTART",0)
Global("COUNT_BOT_RESTART_MAX",20)
Global("BOT_RESTART_ERROR","")
Global("ZOO_KILLMOB_ALIVE",true)
--for pos
Global("ZOOBOT_DELTA_X",50)
Global("ZOOBOT_INIT_X",150)
Global("ZOOBOT_MAX_X",950)
Global("ZOOBOT_DELTA_Y",150)
Global("ZOOBOT_INIT_Y",150)
Global("ZOOBOT_MAX_Y",950)


-- from Summon
Global("ENEMY_ID",nil)
Global("ENEMY_SECOND_ID", nil)
Global("MOB_POSITITON",nil)
Global("BOT_SUMMON_ERROR",nil)
Global("BOT_RANGE_ERR_FUNC",nil)
Global("BOT_RANGE_PASS_FUNC",nil)

-------===================================================================
------------------------==================================================
function BotError( msg )
	LogResult({isError = true, test = "Zoo", text = msg})
	DeSummonAllSummoned(BotQuit,BotQuit)
end
function BotQuit()
	StopAllTimers()
	BotLog("QUIT BOT!!!")
	Warn( "Zoo", "See log", true )
end

function BotRestart()
	BotLog("Restart BOT!!!")
	
	StartTimer2(2000,DesummonAll,RestartAfterDesummon)
end
function DesummonAll(nextFunc)
	DeSummonAllSummoned(nextFunc,RestartAfterDesummon)
end

function RestartAfterDesummon(text)
	BotLog(tostring(text))
	StartTimer2(1000,Restart,nil)
end

function BotSuccess( params )
	--kill = unitdie, killTime = KILL_TIME, dmgAvatar = DAMAGE_POINTS_AVATAR, dmgUnit = DAMAGE_POINTS_UNIT, dmgUnitAA = DAMAGE_POINTS_UNIT_AA, unitAbilities = abilki, mobKind = KILLMOB_ENEMY_KIND

	local str = BOTKILLTIME_PREFIX..tostring(params.killTime).."!"..BOTDAMAGE_PREFIX..tostring(params.dmgAvatar).."!"..BOTDAMAGEUNIT_PREFIX..tostring(params.dmgUnit).."!"..BOTDAMAGEUNITAA_PREFIX..tostring(params.dmgUnitAA).."!"..BOTMOBKIND_PREFIX..tostring(params.mobKind).."!"..BOTABILITIES_PREFIX..params.unitAbilities
	BotLog(str)
	if params.kill then
		qaMission.DebugNotify( BOTCODE_PREFIX..TASK_CODE.."!"..BOTRESULT_PREFIX.."Kill!"..str, false )
	else
		qaMission.DebugNotify( BOTCODE_PREFIX..TASK_CODE.."!"..BOTRESULT_PREFIX.."Die!"..str, false )
	end
	DesummonAll(BotRestart)
end
function BotRestartError(text)
	qaMission.DebugNotify( BOTWRONG_FIGHT..TASK_CODE.."!", false )
	if text == nil then
		LogToAccountFile(BOT_RESTART_ERROR)
		BotLog(BOT_RESTART_ERROR)
	else
		LogToAccountFile(text)
		BotLog(text)
	end
	if COUNT_BOT_RESTART < COUNT_BOT_RESTART_MAX then
		COUNT_BOT_RESTART = COUNT_BOT_RESTART + 1
		return BotRestart()
	else
		COUNT_BOT_RESTART = 0
		return BotError("BOT_RESTART - MAX_COUNT")
	end
end

function BotLog(msg)
	Log(msg,"Zoo")
end
function ErrorLog(msg)
	LogResult({isError = true, test = "Zoo", text = msg})
end


-------------------------------------------------------------
-------------- Range function -------------------------------
-------------------------------------------------------------

function PreSetRange(func, errorFunc, dist)
	--BotLog("Summon mob at distance:"..tostring(dist))
	local ldist = tonumber(dist) - 2
    MOB_POSITITON = GetPositionAtDistance(avatar.GetPos(), avatar.GetDir(), ldist)
	BOT_SUMMON_ERROR = "Cant summon mob first time" 
	BOT_RANGE_ERR_FUNC = errorFunc
	BOT_RANGE_PASS_FUNC = func
    SummonMob( ENEMY_NAME, BOT_MAP_NAME, MOB_POSITITON, 0, AfterSummon, errorFunc)
end

function PreSetRangeError()
	BOT_RANGE_ERR_FUNC(BOT_SUMMON_ERROR)
end

function AfterSummon(id)
	local isEnemy = unit.IsEnemy( id )
	local faction = unit.GetFaction( id )
	local isFriend = unit.IsFriend( id )
	if BOT_LEVEL ~= unit.GetLevel( id ) then
		BOT_SUMMON_ERROR = "cant dessumon mob after summon"
        return DeSummon(id, AfterDesummonLvl, PreSetRangeError)
	end
	--BotLog("FACTION!!!! - "..faction.sysTutorialName)
	local param = 0
	if not isEnemy then
		param = param + 1
	end
	if faction.isFriend then
		param = param + 1
	end
	if isFriend then
		param = param + 1
	end
	local isUsable = unit.IsUsable( id )
	BotLog("enemy "..tostring(not isEnemy).." faction.isFriend "..tostring(faction.isFriend).."isFriend "..tostring(isFriend).." usable "..tostring(isUsable) )
	if param > 1 or isUsable then
		qaMission.DebugNotify( BOTWRONG_ENEMY..TASK_CODE.."!", false )
		BOT_SUMMON_ERROR = "cant desummon mob WrongEnemy"
		KillMobStopEvents()
		return DeSummon(id, RestartAfterDesummon, RestartAfterDesummon) -------------------
	else
		ENEMY_ID = id
		local mana = CheckManaUse(ENEMY_ID)
		if not mana then
		    LogToAccountFile("WRONG \tmana type\t"..ENEMY_NAME)
		end
		local secPos = GetPositionAtDistance(debugMission.InteractiveObjectGetPos( id ), avatar.GetDir(), 20)
		return SummonSecond(secPos)
	end
end

function AfterDesummonLvl()
	BOT_SUMMON_ERROR = "cant summon mob after desummon lvl"
    return SummonMob( ENEMY_NAME, BOT_MAP_NAME, MOB_POSITITON, 0, AfterSummon, PreSetRangeError)
end

function SummonSecond(pos)
	--BotLog("Summon second mob..")
	BOT_SUMMON_ERROR = "Cant summon sec mob"
    SummonMob( ENEMY_NAME, BOT_MAP_NAME, pos, 0, RangeSummonPass, PreSetRangeError)
end

function RangeSummonPass(id)
	ENEMY_SECOND_ID = id
    BOT_RANGE_PASS_FUNC(ENEMY_ID,ENEMY_SECOND_ID)
end

function CheckManaUse(id)
    local class = unit.GetClass( id )
    if class.className == "DRUID" and class.manaType == MANA_TYPE_MANA then
        return true
    elseif class.className == "MAGE" and class.manaType == MANA_TYPE_MANA then
    	return true
    elseif class.className == "NECROMANCER" and class.manaType == MANA_TYPE_MANA then
        return true
    elseif class.className == "PALADIN" and class.manaType == MANA_TYPE_ENERGY then
        return true
    elseif class.className == "PRIEST" and class.manaType == MANA_TYPE_MANA then
    	return true
    elseif class.className == "PSIONIC" and class.manaType == MANA_TYPE_MANA then
        return true
    elseif class.className == "STALKER" and class.manaType == MANA_TYPE_ENERGY then
        return true
    elseif class.className == "WARRIOR" and class.manaType == MANA_TYPE_ENERGY then
        return true
    else
        return false
    end
end

-----------------------------------------------------------------
-------------- ENd Range function -------------------------------
-----------------------------------------------------------------

function GetPosForBot(num, z)
	local numX_inLine = math.floor((ZOOBOT_MAX_X - ZOOBOT_INIT_X) / ZOOBOT_DELTA_X)
	local numY_inLine = math.floor((ZOOBOT_MAX_Y - ZOOBOT_INIT_Y) / ZOOBOT_DELTA_Y)
	local numPoints = numX_inLine * numY_inLine
	if numPoints < num then
		return nil
	end
	local y_coord = math.floor(num/ numX_inLine)
	local x_coord = num - (y_coord * numX_inLine)
	return {X = (x_coord * ZOOBOT_DELTA_X) + ZOOBOT_INIT_X, Y = (y_coord * ZOOBOT_DELTA_Y) + ZOOBOT_INIT_Y, Z = z}
end

function CleanPlace()
	local units = avatar.GetUnitList()
	Log("units around ")
	for key, value in units do
		Log(tostring(value))
		if not unit.IsPlayer( value ) then
			Log("not player")
			if not unit.IsDead( value ) then
				Log("not dead")
				local pos = GetPositionAtDistance(avatar.GetPos(), avatar.GetDir(), 30)
				local dist = GetDistanceFromPosition( value, pos )
				Log("dist"..tostring(dist))
				if dist < 40 then
					Log("need desummon")
					BOT_RESTART_ERROR = "Cant desummon in cleanPlace at distance"..tostring(dist)
					DeSummon( value, CleanPlace, BotRestartError)
					return
				end
			end
		end
	end
	StartInCleanPlace()
end

function StartInCleanPlace()
	qaMission.AvatarRevive()
	local id = avatar.GetId()
	local class = unit.GetClass( id )
	BOT_CLASS = class.className
	BOT_NAME = debugCommon.FromWString(object.GetName(id))
	
	BotLog("Ask Task Class:"..BOT_CLASS)
	BOT_RESTART_ERROR = "Cant get answer from manager"
	StartTimer2(60000,BotError,"Cant get answer from manager")
	qaMission.DebugNotify( BOTNAME_PREFIX..BOT_NAME.."!"..BOTCLASS_PREFIX..BOT_CLASS.."!"..BOTNUMBER_PREFIX..BOT_NUMBER.."!", false )
end

function GetSpellsFromTaktika(takt)
	local spells = {}
	local temp_spell = ""
	local temp_id = nil
	for i, action in takt do
    	for j, value in action.spells do
    		temp_spell = debugCommon.FromWString(value.name)
    	    if temp_spell ~= "step" and temp_spell ~= "maxEnergy" and temp_spell ~= "waitEnergy" then
				temp_id = GetSpellId(temp_spell)
				if temp_id ~= nil then
					table.insert(spells, { spell = temp_spell, id = temp_id})
				else
					BotError( "Spell not found "..temp_spell )
				end
    	    end
        end
        for k, value in action.conditions do
            if debugCommon.FromWString(value.rule) == "active" then
				temp_spell = debugCommon.FromWString(value.param)
				temp_id = GetSpellId(temp_spell)
				if temp_id ~= nil then
					table.insert(spells, { spell = temp_spell, id = temp_id})
				else
					BotError( "Spell not found "..temp_spell )
				end
            end
        end
	end
	return spells
end

function BotNormalization()
	Log("Normalize ")
	qaMission.SendCustomMsg("normalize 0 0 0")
	--GetSpellsFromTaktika(BOT_TAKT)
	StartTimer2(1500, StartKillMob, nil)
end

function StartKillMob()
	--------------------------- START ZOO KILL MOB -----------------------------------------
	BotLog("Start task "..TASK_CODE.." enemy XDB: "..ENEMY_NAME)
	InitKillMob(nil,BOT_TAKT,1000,BotSuccess,BotRestartError,PreSetRange,BotError, 5000)
end
--------------------------------------------------------------------------------
------------------------------------------------------------%% EVENTS %%--------
--------------------------------------------------------------------------------
--------------------------------------------------%%% EVENT_AVATAR_CREATED %%%--
function OnAvatarCreated( params )
	ENEMY_ID = nil
	local map = debugMission.GetMap()
	BOT_MAP_NAME = map.debugName
	ZOO_KILLMOB_ALIVE = true
	local pos = GetPosForBot(tonumber(BOT_NUMBER),0)
	LogToAccountFile("X - "..tostring(pos.X).." Y - "..tostring(pos.Y))
	MoveToPos( pos, CleanPlace, nil,3000)
	--StartTimer2(2000,CleanPlace,nil)
end

function GetNotifyMessage( params, prefix )
	if debugCommon.FromWString( params.sender ) ~= BOT_NAME then
		local message = debugCommon.FromWString( params.message )
		local a, b = string.find( message, prefix )
		if a ~= nil and b ~= nil then
		    local endInd = string.find(message,"!",b+1 )
		    message = string.sub( message, b+1,endInd-1 )
			return message
		end
	end
	return nil
end

function ZooMobAlive()
	ZOO_KILLMOB_ALIVE = true
end

function OnDebugNotify( params )
	--BotLog("Debug Notify "..debugCommon.FromWString(params.sender).." msg: "..debugCommon.FromWString(params.message))
	--sender: WString - имя отправителя
	--message: WString - текст сообщения
	local enemyXdb = GetNotifyMessage(params,BOTENEMY_PREFIX)
	local botStart = GetNotifyMessage(params,BOTSTART_PREFIX)
	local taskCode = GetNotifyMessage(params,BOTCODE_PREFIX)
	local botLevel = GetNotifyMessage(params,BOTLEVEL_PREFIX)
	local action = GetNotifyMessage(params,BOTACTION_PREFIX)
	if action ~= nil and botStart ~= nil then
	    StopTimer2()
		if botStart == BOT_NAME then
			if action == BOTACTION_QUIT then
				BotQuit()
			elseif action == BOTACTION_TIMEOUT then
				-- TODO ответ c именем
				if ZOO_KILLMOB_ALIVE then
					ZOO_KILLMOB_ALIVE = false
					qaMission.DebugNotify( BOTTIMEOUT_ANSWER..BOT_NUMBER.."!", false )
					ZooKillMobCheckAlive(ZooMobAlive)
				end
			else
				BotErr("Wrong action from Manager")
			end
		end
	end
	if botStart ~= nil then
		if botStart == BOT_NAME and enemyXdb ~= nil and taskCode ~= nil and botLevel ~= nil then
		    StopTimer2()
			ENEMY_NAME = enemyXdb
			TASK_CODE = taskCode
			BOT_LEVEL = tonumber(botLevel)
			--BotLog("LevelUp to "..tostring(LEVEL).." level")
			BOT_RESTART_ERROR = "cant level_up"
			local learn_takt = GetTaktiks(BOT_CLASS,BOT_LEVEL)
			if learn_takt ~= nil then
				LevelUp( BOT_LEVEL, learn_takt, BotNormalization, BotRestartError )
			end
		end
	end

end

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
		for key, value in takt[1].conditions do
			
			if debugCommon.FromWString(value.rule) == "class" then
				if class == string.upper(debugCommon.FromWString(value.param)) then
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
				if level <= tonumber(debugCommon.FromWString(value.param)) then
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
--
-- main initialization function
--
function Init()
	local pathname = developerAddon.GetName()
		
	local startSlesh = string.find( pathname, "Zoo")
	startSlesh = startSlesh + 3
	local factionSlesh = string.find( pathname, "/", startSlesh + 1 )
	local numSlesh = string.find( pathname, "/", factionSlesh + 1 )
	local finishSlesh = string.find( pathname, "/", numSlesh + 1 )
	local class = string.sub(pathname, startSlesh + 1, factionSlesh - 1)
	local faction = string.sub(pathname, factionSlesh + 1, numSlesh - 1)
	local number = string.sub(pathname, numSlesh + 1, finishSlesh - 1)
	local numPos = string.find(number, "%d")
	local num = string.sub(number, numPos)

	BOT_NUMBER = num

	local factionAdd = ""
	if faction == "Empire" then
		factionAdd = "Empire"
	end

	BOT_CLASS = class
	TEST_NAME = TEST_NAME..class.." - "..number
	local avatar_name = "Zoo"..BOT_NUMBER..class
	local bot_login = "zoo"..BOT_NUMBER
	
	local login = {login = bot_login,pass = bot_login, avatar = avatar_name, create = "Auto"..class..factionAdd, delete = true, flagExit = true, errorFunc = Warn}
	InitLoging(login)
	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	common.RegisterEventHandler( OnDebugNotify, "EVENT_DEBUG_NOTIFY")
end

--
-- main initialization
--

Init()
