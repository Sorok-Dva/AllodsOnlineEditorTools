Global( "TEST_NAME", "Prorab suka hitriy" )

Global( "SLAVE", "Slave" )
Global( "NUM", nil )
Global( "SLAVES_NUM", 6 )
Global( "RUN_NUM", 1 )

Global( "STEP" , nil )
Global( "STEP_TEXT" , "Запускаем аддоны" )
Global( "PULL" , nil )
Global( "PULL_ERRORS" , nil )

function Done()
	Success( TEST_NAME )
end

function InitNum()
	Log("Number of bots: "..SLAVES_NUM)
	NUM = {}
	local i
	for i = 1 , SLAVES_NUM, 1 do
		table.insert(NUM,tostring(i))
	end
end

function ErrorFunc( text )
	for i,num in NUM do
		QuitBotCommand(SLAVE..num)
	end
	Warn( TEST_NAME, text)
end

function RunChildBots()
	if RUN_NUM <= SLAVES_NUM then
		return StartTimer2(100,RunChildBot,SLAVE..NUM[RUN_NUM])
	end
end

function RunChildBot(botName)
	Log ("Run child: "..botName)
	developerAddon.RunChildGame( "../"..botName.."/Main.(DeveloperAddon).xdb", " -silentMode")	
	RUN_NUM = RUN_NUM + 1
	RunChildBots()
end

function OnAvatarCreated()
	PULL = {}
	PULL_ERRORS = {}
	StartTest(TEST_NAME)
	Log("run bots")
	RUN_NUM = 1
	for i,n in NUM do
		table.insert(PULL,{name = SLAVE..n,command = DONE,come = false})
	end
	RunChildBots()
	
	STEP = 0
	StartTimer(100000, ErrorFunc20sec, nil )
end
function IsNameInPull(name)
	for i, unit in PULL do
		if unit.name == name then
			return  true
		end
	end
	return false
end

function IsCommandInPullForName( name, command )
	for i, unit in PULL do
		if unit.name == name then
			if unit.command == command then
				unit.come = true
				return true
			end
		end
	end
	return false
end

function CheckPull()
	local null = true
	local str = ""
	for i, unit in PULL do
		if not unit.come then
			str = str.." "..unit.name.." command: "..unit.command
			null = false
		end
	end
	if null then
		StopTimer()
		Log("Step Ok!")
		return StartTimer(10000, NextStep, nil)
	--else
		--Log("Dont come from"..str)
	end
end

function CheckPullForRoger()
	for i, unit in PULL do
		if unit.command == ROGER and not unit.come then
			return true
		end
	end
	return false
end

function CheckErrorsPull()
	local null = true
	for i, unit in PULL_ERRORS do
		null = false
	end
	return null
end

function crTable(a,b,c,d,e,f)
	local t = {}
	if a ~= nil then
		table.insert(t,a)
	end
	if b ~= nil then
		table.insert(t,b)
	end
	if c ~= nil then
		table.insert(t,c)
	end
	if d ~= nil then
		table.insert(t,d)
	end
	if e ~= nil then
		table.insert(t,e)
	end
	if f ~= nil then
		table.insert(t,f)
	end
	return t
end

function GetErrorsFromPull()
	local str = ""
	local flag = false
	for i, unit in PULL do
		if not unit.come then
			if unit.command == DONE then
				flag = true
				for k,j in PULL_ERRORS do
					if j.name == unit.name then
						flag = false
						str = str .. j.name .. ": "..j.text
					end
				end
				if flag then
					str = str .. unit.name .. ": Silencing! "
				end
			elseif unit.command == ROGER then
				str = str .. unit.name .. "dont Roger! "
			end
		end
	end
	return str
end
function OnDebugNotify( params )
	local sender = debugCommon.FromWString( params.sender )
	
	if IsNameInPull( sender ) then
		local message = debugCommon.FromWString( params.message )
		cLog( "message=" .. message )
		local messageParams = ParseMessage( message )
		--Log("notify name in pull "..sender)
		if IsCommandInPullForName( sender, messageParams.command )  then
			--Log("notify command in pull" .. messageParams.command)
			CheckPull()
		elseif messageParams.command == ERROR then
			--Log("notify error from bot "..sender)
			table.insert( PULL_ERRORS, {name = sender, text = messageParams.params[1]})
		--else
			
			--ERROR
		end
	end
end

function TeleportCommand(botName,x,y,z,map)
	table.insert(PULL,{name = botName,command = ROGER,come = false})
	table.insert(PULL,{name = botName,command = DONE,come = false})
	local msg = nil
	if map == nil then
		msg = CreateMessage( botName, TELEPORT, {X = x, Y = y, Z = z, Map = "Tests/Maps/Lua/MapResource.xdb"} )
	else
		msg = CreateMessage( botName, TELEPORT, {X = x, Y = y, Z = z, Map = map} )
	end
	qaMission.DebugNotify( msg, false )	
end

function CheckPlaceForVisibleCommand(botName, params)
	table.insert(PULL,{name = botName,command = ROGER,come = false})
	table.insert(PULL,{name = botName,command = DONE,come = false})
	local msg = CreateMessage( botName, CHECK_PLACE, params )
	qaMission.DebugNotify( msg, false )	
end

function CheckPlaceForUnvisibleCommand(botName, params)
	table.insert(PULL,{name = botName,command = ROGER,come = false})
	table.insert(PULL,{name = botName,command = DONE,come = false})
	local msg = CreateMessage( botName, CHECK_PLACE_UN, params )
	qaMission.DebugNotify( msg, false )	
end

function AcceptInviteCommand(invBot, botName)
	table.insert(PULL,{name = botName,command = ROGER,come = false})
	local params = {}
	table.insert(params, invBot)
	local msg = CreateMessage( botName, ACCEPT_INVITE, params )
	qaMission.DebugNotify( msg, false )	
end

function InviteInGroupCommand(botName, invBots)
	table.insert(PULL,{name = botName,command = ROGER,come = false})
	table.insert(PULL,{name = botName,command = DONE,come = false})
	for i, bot in invBots do
		table.insert(PULL,{name = bot,command = DONE,come = false})
	end
	local msg = CreateMessage( botName, INVITE, invBots)
	qaMission.DebugNotify( msg, false )	
end

---------  Exchange

function AcceptExchangeCommand( botName, fromBot )
	table.insert( PULL, { name = botName, command = ROGER, come = false })
	local params = {}
	table.insert( params, fromBot )
	local msg = CreateMessage( botName, ACCEPT_EXCHANGE, params )
	qaMission.DebugNotify( msg, false )	
end

function InviteToExchangeCommand( botName, invBot )
	table.insert( PULL, { name = botName, command = ROGER, come = false })
	table.insert( PULL, { name = botName, command = DONE,  come = false })
	table.insert( PULL, { name = invBot,  command = DONE,  come = false })
	local params = {}
	table.insert(params, invBot)
	local msg = CreateMessage( botName, EXCHANGE_INVITE, params )
	qaMission.DebugNotify( msg, false )	
end






function QuitBotCommand( botName )
	table.insert(PULL,{name = botName,command = ROGER,come = false})
	local msg = CreateMessage( botName, EXIT, nil )
	qaMission.DebugNotify( msg, false )	
end

function RelogBotCommand(botName)
	table.insert(PULL,{name = botName,command = ROGER,come = false})
	table.insert(PULL,{name = botName,command = DONE,come = false})
	local msg = CreateMessage( botName, RELOGIN, nil )
	qaMission.DebugNotify( msg, false )	
end

function LeaveBotCommand(botName)
	table.insert(PULL,{name = botName,command = ROGER,come = false})
	table.insert(PULL,{name = botName,command = DONE,come = false})
	local msg = CreateMessage( botName, LEAVE_GROUP, nil )
	qaMission.DebugNotify( msg, false )	
end

function ErrorFunc10sec()
	if CheckPullForRoger() then
		ErrorFunc("20sec "..GetErrorsFromPull())
	else
		if CheckErrorsPull() then
			ErrorFunc("20sec "..GetErrorsFromPull())
		else
			StartTimer(20000, ErrorFunc20sec,nil)
		end
	end
end

function ErrorFunc20sec()
	ErrorFunc("40sec "..GetErrorsFromPull())
end

function Init()
	SetTestName()
	local num_bots = developerAddon.GetParam( "bots" )
	if num_bots ~= nil then
		local num = tonumber(num_bots)
		if type(num) == "number" then
			SLAVES_NUM = num
		end
	end
	
	InitNum()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging(login)

	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	common.RegisterEventHandler( OnDebugNotify, "EVENT_DEBUG_NOTIFY" )
end

Init()
