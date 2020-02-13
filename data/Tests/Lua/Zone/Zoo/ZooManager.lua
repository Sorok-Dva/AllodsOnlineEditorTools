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
Global("BOTDAMAGEUNITAA_PREFIX","DmgUnitAA:")
Global("BOTMOBKIND_PREFIX","MobKind:")
Global("BOTABILITIES_PREFIX","UnitAbil:")
Global("BOTACTION_QUIT","Quit")
Global("BOTACTION_TIMEOUT","TimeOut")
Global("BOTTIMEOUT_ANSWER","ZooTimeout:")
Global("BOTACTION_PREFIX","Action:")
Global("BOTACTION_CONTINUE","continue zoo!")
Global("BOTTASK_ENEMY","ZooTask:")
Global("PREFIX_ZOO_STOP","stop zoo!")
Global("PREFIX_ZOO_START","start zoo!")
Global("PREFIX_ZOO_LOG","log zoo!")

Global("TEST_NAME","Zoo:")
Global("MYNAME",nil)
Global("ZOO_STOP_COMMAND",false)
Global("RESULTS",{})
Global("TASKS",{})
Global("BOTS",{})
Global("RUN_BOTS",{})
Global("MANUAL_TASK",nil)

Global("MAX_COUNT", 3)
Global("BOT_NUMBER", 1)
Global("AVAILABLE_TASKS", 0)

Global("BOT_TASK_TIME", 60)
Global("BOT_SKILL", nil)
Global("BOT_CLASS", nil)
Global("BOT_FACTION", nil)
Global("RUNBOT_DEMON_LAG",8000)

Global("BUILDER",true)
Global("AMOUNT_TASKS",0)

function MobInList(wstring)
	local xdb = debugCommon.FromWString(wstring)
	local separatorInd = string.find(xdb,":")
	if separatorInd ~= nil then
		local type = string.sub(xdb,1,separatorInd-1)
		if type == "MobWorld" then
			return string.sub( xdb, separatorInd+2 )
		else
			return nil
		end
	else
		-- ACHTUNG!!! Wrong MobList cant find "MobWorld"
	end
end

function GetNotifyMessage( params, prefix )
	if debugCommon.FromWString( params.sender ) ~= MYNAME then
		local message = debugCommon.FromWString( params.message )
		local a, b = string.find( message, prefix )
		if a ~= nil and b ~= nil then
		    local endInd = string.find(message,"!",b+1 )
    	    if endInd == nil then
		        return nil
		    end
		    message = string.sub( message, b+1,endInd-1 )
			return message
		end
	end
	return nil
end

function BotToList(botnum,botname)
	for i, v in BOTS do
		if v.num == botnum then
			v.lasttime = TIME_SEC
			return
		end
	end
	table.insert(BOTS,{name = botname, num = botnum, lasttime = TIME_SEC})
end

function GetNameBotFromList(num)
	for i, v in BOTS do
		if v.num == num then
			v.lasttime = TIME_SEC
			return v.name
		end
	end
	return "nil"
end

function OnDebugNotify( params )
	--sender: WString - имя отправителя
	--message: WString - текст сообщения
	local botName = GetNotifyMessage(params,BOTNAME_PREFIX)
	local botClass = GetNotifyMessage(params,BOTCLASS_PREFIX)
	local botNumber = GetNotifyMessage(params,BOTNUMBER_PREFIX)
	
	local task = GetNotifyMessage(params,BOTCODE_PREFIX)
	local result = GetNotifyMessage(params,BOTRESULT_PREFIX)
    local wrongEnemy = GetNotifyMessage(params,BOTWRONG_ENEMY)
	local wrongFight = GetNotifyMessage(params,BOTWRONG_FIGHT)
	local timeoutAnswer = GetNotifyMessage(params,BOTTIMEOUT_ANSWER)
	

	if botName ~= nil and botClass ~= nil and botNumber ~= nil then
		BotToList(botNumber,botName)
		if MANUAL_TASK == nil then
			local key = GetTask(botClass)
		    --cLog("KEY: "..tostring(key))
			if key == nil or ZOO_STOP_COMMAND then
	            qaMission.DebugNotify( BOTSTART_PREFIX..botName.."!"..BOTACTION_PREFIX..BOTACTION_QUIT.."!", false )
				local noActiveTasks = true
				for i,v in TASKS do
					if ( not v.finish ) then
						noActiveTasks = false
					end
				end
				if noActiveTasks then
					LogZooResults(not ZOO_STOP_COMMAND)
				end
			else
				for j,v in RESULTS[key] do
			        if type(v) == "table" then
						if v.class == botClass then
							v.iTry = v.iTry + 1
							table.insert(TASKS, {mobKey = key, class = botClass, finish = false, time_finish = TIME_SEC + BOT_TASK_TIME, bot = botNumber})
							local mobXdb = RESULTS[key].xdb
							local keyTask = maxn(TASKS)
							qaMission.DebugNotify( BOTSTART_PREFIX..botName.."!"..BOTENEMY_PREFIX..mobXdb.."!"..BOTCODE_PREFIX..tostring(keyTask).."!"..BOTLEVEL_PREFIX..RESULTS[key].level.."!", false )
			            end
			        end
			    end
		    end
	    else
	        if ZOO_STOP_COMMAND then
	            qaMission.DebugNotify( BOTSTART_PREFIX..botName.."!"..BOTACTION_PREFIX..BOTACTION_QUIT.."!", false )
				LogZooResults(false)
	        else
		        InsertResults(0,MANUAL_TASK,"custom")
				table.insert(TASKS, {mobKey = maxn(RESULTS), class = botClass, finish = false, time_finish = TIME_SEC + BOT_TASK_TIME, bot = botNumber})
				qaMission.DebugNotify( BOTSTART_PREFIX..botName.."!"..BOTENEMY_PREFIX..MANUAL_TASK.."!"..BOTCODE_PREFIX..tostring(maxn(TASKS)).."!", false )
			end
	    end
	end
	
	if task ~= nil and result ~= nil then
		local KillTime = GetNotifyMessage(params,BOTKILLTIME_PREFIX)
		local avDmg = GetNotifyMessage(params,BOTDAMAGE_PREFIX)
		local unDmg = GetNotifyMessage(params,BOTDAMAGEUNIT_PREFIX)
		local unDmgAA = GetNotifyMessage(params,BOTDAMAGEUNITAA_PREFIX)
		local unAbil = GetNotifyMessage(params,BOTABILITIES_PREFIX)
		local unKind = GetNotifyMessage(params,BOTMOBKIND_PREFIX)
		

		local succKey = tonumber(task)
		TASKS[succKey].finish = true
		EnterResult(TASKS[succKey].mobKey, TASKS[succKey].class, result, KillTime, avDmg, unDmg, unDmgAA, unAbil, unKind)
		--table.remove(TASKS,succKey)
	end
	if wrongFight ~= nil then
		local fkey = tonumber(wrongFight)
		TASKS[fkey].finish = true
		Log("WrongFight "..TASKS[fkey].bot)
	end
	if wrongEnemy ~= nil then
		local wrongKey = tonumber(wrongEnemy)
		local kkey = TASKS[wrongKey].mobKey
		TASKS[wrongKey].finish = true
		RESULTS[kkey].flagWrong = true
		--Log("Wrong enemy "..RESULTS[kkey].xdb)
	end
	
	if timeoutAnswer ~= nil then
		for i,v in TASKS do
			if v.bot == timeoutAnswer then
				v.time_finish = v.time_finish + BOT_TASK_TIME
			end
		end
	end
	
end

function CheckCompleteTasks()
	Log("CheckCompleteTasks..")
	if TASKS ~= nil then
		local cur_time = TIME_SEC
		for i,v in TASKS do
			if ( not v.finish ) then
				local delta = cur_time - v.time_finish
				if ( delta > 0 and delta < BOT_TASK_TIME) then
					Log("Not Complete Num :"..v.bot.." mob: "..v.mobKey.." xdb "..RESULTS[v.mobKey].xdb.." time "..tostring(delta))
					qaMission.DebugNotify( BOTSTART_PREFIX..GetNameBotFromList(v.bot).."!"..BOTACTION_PREFIX..BOTACTION_TIMEOUT.."!", false )
				elseif ( delta >= BOT_TASK_TIME ) then
					Log("Restart num:"..v.bot)
					v.finish = true
					qaMission.DebugNotify( BOTSTART_PREFIX..GetNameBotFromList(v.bot).."!"..BOTACTION_PREFIX..BOTACTION_QUIT.."!", false )
					RunZooBot(tonumber(v.bot), TIME_SEC)
				end
			end
		end
	end
	CheckActiveBots()
	StartTimer2(60000, CheckCompleteTasks, nil )
end

function CheckActiveBots()
	Log("CheckActiveBots..")
	local silenceBot = nil
	if BOT_NUMBER > AVAILABLE_TASKS then
		BOT_NUMBER = AVAILABLE_TASKS
	end
	for ibot = 1, BOT_NUMBER, 1 do
		silenceBot = ibot
		-- смотрим есть ли он в таблице
		for i,bot in BOTS do
			if (tonumber(bot.num) == ibot) then
				if (( TIME_SEC - bot.lasttime ) > ( BOT_TASK_TIME * 2 )) then
					silenceBot = ibot
					Log("Silence Bot: "..tostring(ibot))
					--TODO надо посмотреть нет ли его в тасках.
					for i,v in TASKS do
						if (not v.finish) and (v.bot == bot.num) then
							Log("Bot find in TASKS : "..tostring(silenceBot))
							silenceBot = nil
							break
						end
					end
				else
					silenceBot = nil
				end
			end
		end
		if silenceBot ~= nil then
			Log("Restart no active bot : "..tostring(silenceBot))
			qaMission.DebugNotify( BOTSTART_PREFIX..GetNameBotFromList(tostring(silenceBot)).."!"..BOTACTION_PREFIX..BOTACTION_QUIT.."!", false )
			RunZooBot(silenceBot, TIME_SEC)
		end
	end
end

function EnterResult(key,class,result, killTime, avatarDmg, unitDmg, unitDmgAA, unitAbil, Kind)
	local errenemy = 0
	-- mob normalnii
	RESULTS[key].flagTrue = true
	RESULTS[key].mobKind = Kind
	for i,v in RESULTS[key] do
	    if type(v) == "table" then
	        if v.class == class then
				if killTime == "0" and avatarDmg == "0" and unitDmg == "0" then
					--errorEnemy!!!
					mob.flagError = true
				else
					if killTime ~= "nil" then
						table.insert(v.killTime, tonumber(killTime))
					end
					if avatarDmg ~= "nil" then
						v.avatarDmg = v.avatarDmg + tonumber(avatarDmg)
					end
					if unitDmg ~= "nil" then
						v.unitDmg = v.unitDmg + tonumber(unitDmg)
					end
					if unitDmgAA ~= "nil" then
						v.unitDmgAA = v.unitDmgAA + tonumber(unitDmgAA)
					end
					v.unitAbils = AddAbilToTable(unitAbil,v.unitAbils)
				end
				local statStr = v.class.."\t"..v.zone.."\t"..killTime.."\t"..avatarDmg.."\t"..unitDmg.."\t"..unitDmgAA.."\t"..unitAbil
				if result == "Kill" then
				    v.iKill = v.iKill + 1
				    LogToAccountFile(tostring(RESULTS[key].level).."\t"..RESULTS[key].xdb.."\t"..tostring(RESULTS[key].mobKind).."\tKill\t"..statStr)
				elseif result == "Die" then
					LogToAccountFile(tostring(RESULTS[key].level).."\t"..RESULTS[key].xdb.."\t"..tostring(RESULTS[key].mobKind).."\tKDie\t"..statStr)
				    v.iDie = v.iDie + 1
				else
				    --ACHTUNG
				end
	        end
	    end
	end
end

function TaskIsActive(key)
	local count = 0
	for i,v in TASKS do
		if key == v.mobKey and not v.finish then
			count = count + 1
		end
	end
	return count
end

function GetTask(class)
	local key_ret = nil
	local count = 0
	for key,mob in RESULTS do
		if not mob.flagWrong and not mob.flagError then
		    for i,v in mob do
		        if type(v) == "table" then
		            if v.class == class then
		                --cLog("key "..key.." lesser "..tostring(lesserTry).." curTry "..tostring(v.iTry))
		                local active = TaskIsActive(key)
						local curPass = v.iKill + v.iDie + active
						if curPass < MAX_COUNT then
							if mob.flagTrue or curPass == 0 then
								if key_ret == nil then
									key_ret = key
								end
							end
							count = count + 1
						end
		            end
		        end
		    end
		end
	end
	AVAILABLE_TASKS = count
	return key_ret
end

function OnAvatarCreated(params)
   	local id = avatar.GetId()
	MYNAME = debugCommon.FromWString(object.GetName(id))
	--return Logout(false)
	RUNBOT_DEMON_LAG = 1000 * GetShardLag()
	RunZooBots()
	local statStr1 = "Level\txdb\tmobKind\tResult\tClass\tZone\tkillTime\tavatarDmg\tunitDmg\tunitDmgAA\tunitAbil"
	LogToAccountFile(statStr1)
end

function RunZooBot(inum,time_sec)
	local checkTable = true
	for k, bot in RUN_BOTS do
		if bot.num == inum then
			checkTable = false
		end
	end
	if checkTable then
		Log("RunZooBot "..tostring(inum))
		table.insert(RUN_BOTS,{num = inum, time = time_sec})
	end
end

function DemonRunBot()
	Log("RunBot Demon")
	local first = true
	local timeCheck = true
	for i, bot in RUN_BOTS do
		timeCheck = true
		if bot.time ~= nil then
			timeCheck = (TIME_SEC - bot.time) > 5
		end
		if first and timeCheck then
			first = false
			Log("RunChildGame "..tostring(bot.num))
			developerAddon.RunChildGame("../../../"..BOT_CLASS.."/"..BOT_FACTION.."/Number"..tostring(bot.num).."/Main.(DeveloperAddon).xdb", " -silentMode -minimize")
			table.remove(RUN_BOTS,i)
			break
		end
	end
	StartTimer1(RUNBOT_DEMON_LAG,DemonRunBot,nil)
end
function RunZooBots(num)
	local i = 1
	RUN_BOTS = nil
	RUN_BOTS = {}
	TASKS = nil
	TASKS = {}
	if BUILDER then
		for i = 1, BOT_NUMBER, 1 do
			RunZooBot(i)
		end
		DemonRunBot()
		local timeForStart = ( RUNBOT_DEMON_LAG * BOT_NUMBER ) + 45000
		StartTimer2(timeForStart,CheckCompleteTasks,nil)
	end
end

function GetChatMessage( params, prefix )
	local message = debugCommon.FromWString( params.msg )
	local a, b = string.find( message, prefix )
	if a ~= nil and b ~= nil then
	    local endInd = string.find(message,"!",b+1 )
	    if endInd == nil then
	        return nil
	    end
	    message = string.sub( message, b+1,endInd-1 )
		return message
	end
	return nil
end

function OnChatMessage(params)
	local message = debugCommon.FromWString( params.msg )
	local zooStop = string.find( message, PREFIX_ZOO_STOP )
	local zooStart = string.find( message, PREFIX_ZOO_START )
	local zooLog = string.find( message, PREFIX_ZOO_LOG )
	local zooNumber = string.find( message, "number zoo!" )
	local zooNumberMobs = GetChatMessage(params, "NumberMobs:" )
    local TaskEnemy = GetChatMessage(params, BOTTASK_ENEMY)
    local zooContinue = string.find( message, BOTACTION_CONTINUE)

	if zooStop ~= nil then
	    ZOO_STOP_COMMAND = true
	end
	if zooStart ~= nil then
	    ZOO_STOP_COMMAND = false
	end
	if zooLog ~= nil then
		LogZooResults(false)
	end
	if zooNumber ~= nil then
	    local num = numberMobs()
		avatar.ChatSay( debugCommon.ToWString( "Number Tasks: "..tostring(num) ) )
	end
	if zooNumberMobs ~= nil then
	    MAX_COUNT = tonumber(zooNumberMobs)
	end

	if TaskEnemy ~= nil then
		--Log(TaskEnemy)
		MANUAL_TASK = TaskEnemy
	end
	if zooContinue ~= nil then
	    MANUAL_TASK = nil
	end
end

function GetStatistiks( t )
	local num = 0
	for k,v in t do
		--Log("count "..tostring(k))
		num = num + 1
		--Log("count "..tostring(k).." v "..tostring(v).." num "..tostring(num))
	end
	local sum = 0
	local p = {}
	local psum = 0
	local delta = 0
	for i = 1, num, 1 do
		sum = 0
		for j = 1, num, 1 do
			delta = math.abs(t[i] - t[j])
			sum = sum + ( delta * delta )
		end
		--Log("sum "..tostring(sum))
		sum = 100 / sum
		--sum = sum * sum
		--sum = math.exp(sum)
		--Log("sum2 "..tostring(sum))
		psum = psum + sum
		table.insert(p, sum)
	end
	sum = 0
	local ave = 0
	for i = 1, num, 1 do
		ave = ave + t[i]
		sum = sum + (t[i]*(p[i]/psum))
	end
	ave = ave / num
	return {average = ave, mat = sum}
end

function LogZooResults(withQuit)
	developerAddon.LogTest("RESULTS")
	developerAddon.LogTest("level\txdb\tmobKind\tclass\tzone\tiTry\tiKill\tiDie\taverTime\tmatTime\tAvatarDmg\tUnitDmg\tUnitDmgAA\tUnitAbils")
    for key,mob in RESULTS do
        for i,v in mob do
            if type(v) == "table" then
                if v.iTry > 0 and not mob.flagWrong then
					local time_stat = GetStatistiks(v.killTime)
					local abilki = ""
					for i, a in v.unitAbils do
						abilki = abilki .. a.."\t"
					end
					local num = v.iKill + v.iDie
   					developerAddon.LogTest(tostring(mob.level).."\t"..mob.xdb.."\t"..tostring(mob.mobKind).."\t"..v.class.."\t"..v.zone.."\t"..tostring(v.iTry).."\t"..tostring(v.iKill).."\t"..tostring(v.iDie).."\t"..tostring(time_stat.average).."\t"..tostring(time_stat.mat).."\t"..tostring(v.avatarDmg/num).."\t"..tostring(v.unitDmg/num).."\t"..tostring(v.unitDmgAA/num).."\t"..abilki)
   				end
   			end
   		end
   	end
	developerAddon.LogTest("Wrong Enemys")
    for key,mob in RESULTS do
		if mob.flagWrong then
			developerAddon.LogTest(tostring(mob.level).."\t"..mob.xdb.."\twrong")
		end
	end
	developerAddon.LogTest("Error Enemys")
    for key,mob in RESULTS do
		if mob.flagError then
			developerAddon.LogTest(tostring(mob.level).."\t"..mob.xdb.."\terror")
		end
	end

   	if withQuit then
		StopAllTimers()
   		StartTimer(10000,Success,TEST_NAME)
   	end
end

function maxn(table)
	local res = 0
	for k,v in table do
	    res = k
	end
	return res
end

function numberMobs()
	local res = 0
    for key,mob in RESULTS do
        for i,v in mob do
            if type(v) == "table" then
                if v.iTry > 0 then
					res = res + 1
   				end
   			end
   		end
   	end
   	return res
end

function InsertResults(lvl,mobXdb, zoneName)
	Log("\t"..tostring(lvl).."\t"..mobXdb.."\t"..zoneName)
	table.insert(RESULTS,{level = lvl,xdb = mobXdb,flagWrong = false,flagError = false,flagTrue = false, mobKind = nil,
	classSkill = {class = string.upper(BOT_CLASS), zone = zoneName, iTry = 0, iKill = 0,iDie = 0,killTime = {},unitDmg = 0,unitDmgAA = 0, avatarDmg = 0, unitAbils = {}}})
end

function DescriptZoneName(zone)
		if zone == "AL1" then
			return "ArchipelagoLeague1"
		elseif zone == "AL2" then
			return "ArchipelagoLeague2"
		elseif zone == "AL3" then
			return "ArchipelagoLeague3"
		elseif zone == "ZL1" then
			return "ZoneLeague1"
		elseif zone == "ZL2" then
			return "ZoneLeague2"
		elseif zone == "ZL3" then
			return "ZoneLeague3"
		elseif zone == "AE1" then
			return "ArchipelagoEmpire1"
		elseif zone == "AE2" then
			return "ArchipelagoEmpire2"
		elseif zone == "AE3" then
			return "ArchipelagoEmpire3"
		elseif zone == "ZE1" then
			return "ZoneHadagan1"
		elseif zone == "ZE2" then
			return "ZoneEmpire2"
		elseif zone == "ZE3" then
			return "ZoneEmpire3"
		elseif zone == "ZC1" then
			return "ZoneContested1"
		elseif zone == "ZC2" then
			return "ZoneContested2"
		elseif zone == "ZC3" then
			return "ZoneContested3"
		elseif zone == "AC1" then
			return "ZoneContested4"
		elseif zone == "AC1" then
			return "ArchipelagoContested1"
		elseif zone == "AC2" then
			return "ArchipelagoContested2"
		elseif zone == "Satyr" then
			return "SatyrList"
		else
			return zone
		end
end

function CheckZone(zones,mobzone)
		for iZone, zoneName in zones do
			local zoneInList = debugCommon.FromWString(mobzone)
	        local zoneFind = string.find(zoneInList,zoneName)
			if zoneFind ~= nil then
				return zoneName
			end
		end
		return nil
end

function AddAbilToTable(abils,t)
	if abils ~= "" then
		local indAbilS = 1
		local abil = ""
		local indAbilF = 0
		local checknil = true		
		while indAbilF ~= nil do
			indAbilF = string.find(abils,",",indAbilS)
			if indAbilF ~= nil then
				indAbilF = indAbilF - 1
			end
			abil = string.sub(abils,indAbilS,indAbilF)
			--Log(abil)
			if indAbilF ~= nil then
				indAbilS = indAbilF + 2
			end
			checknil = true
			for kAbil,vAbil in t do
				if vAbil == abil then
					checknil = false
				end
			end
			if checknil then
				table.insert(t,abil)
			end
		end
	end
	return t
end

function Init()
	
	local count = developerAddon.GetParam( "NumberMobs" )
	if count ~= "" then
		MAX_COUNT = tonumber(count)
	end

	local lvl_hi = developerAddon.GetParam( "NumberBots" )
	if lvl_hi ~= "" then
	    BOT_NUMBER = tonumber(lvl_hi)
	end

	local mob_lvl_min = developerAddon.GetParam( "MobLevelMin" )
	if mob_lvl_min ~= "" then
	    mob_lvl_min = tonumber(mob_lvl_min)
	end
	
	local mob_lvl_max = developerAddon.GetParam( "MobLevelMax" )
	if mob_lvl_max ~= "" then
	    mob_lvl_max = tonumber(mob_lvl_max)
	end
	
	local class = developerAddon.GetParam( "BotClass" )
	if class ~= "" then
	    BOT_CLASS = class
	end
	local faction = developerAddon.GetParam( "BotFaction" )
	if faction ~= "" then
	    BOT_FACTION = faction
	end
	local run_bots = developerAddon.GetParam( "RunBots" )
	if run_bots ~= "" then
	    if run_bots == "true" then
	        BUILDER = true
	    elseif run_bots == "false" then
	        BUILDER = false
	    end
	end
	local zone_num = developerAddon.GetParam( "NumberZones" )
	if zone_num ~= nil then
		zone_num = tonumber(zone_num)
	end
	local zone_count = 0
	local zones = {}
	while zone_count < zone_num do
		local zone = developerAddon.GetParam( "Zone"..tostring(zone_count) )
		if zone ~= nil then
			TEST_NAME = TEST_NAME.." "..zone
			local descZone = DescriptZoneName(zone)
			Log(descZone)
			table.insert(zones,descZone)
		end
		zone_count = zone_count + 1
	end

	local mobList = developerAddon.LoadMobList()
	local mobXdb = ""
	local lvl = 0
	local zoneCheck = nil
	local ClassPlayer = nil
	
	for key, mob in mobList do
	    mobXdb = MobInList(mob.name)
		zoneCheck = CheckZone(zones,mob.zone)
	    if mobXdb ~= nil and zoneCheck ~= nil and mob.minLevel >= mob_lvl_min then
			lvl = mob.minLevel
			while lvl <= mob.maxLevel and lvl <= mob_lvl_max do
				InsertResults(lvl,mobXdb,zoneCheck)
				AMOUNT_TASKS = AMOUNT_TASKS + 1
			    lvl = lvl + 1
			end
		end
	end
	Log("Number of tasks from moblist - "..tostring(AMOUNT_TASKS))
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
    common.RegisterEventHandler( OnDebugNotify, "EVENT_DEBUG_NOTIFY")
    common.RegisterEventHandler( OnChatMessage, "EVENT_CHAT_MESSAGE")
	local login = { login = developerAddon.GetParam( "login" ),
	pass = developerAddon.GetParam( "password" ),
	avatar = developerAddon.GetParam( "avatar" ),
	create = "AutoWarrior",
	delete = true,
	errorFunc = false,
	flagExit = false}

	InitLoging(login)
end

--
-- main initialization
--

Init()