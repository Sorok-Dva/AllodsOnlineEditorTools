Global( "TEST_NAME", "UnitTest AvatarMoveAndRotate" )
Global( "TIME_CONST", 500 )

--------------------------------------- EVENTS ------------------------------------

function OnAvatarCreated()
	StartTest( TEST_NAME )
	--StartTimer(7000, StartScriptControl,nil)
	StartTimer(7000, SetScriptControl,{time = 500, lag = 100, dX = 6, func = Success, errorFunc = Warn})
end

---------------------- FUNCTIONS ------------------------------------
function StartScriptControl()
	Log("SetScriptControl")
	qaMission.AvatarSetScriptControl( true )
	StartTimer(2000, StartRotate,nil)
end

function StartRotate()
	Log("First Rotate ")
	local avPos = avatar.GetPos()
	local avDir = avatar.GetDir()
	local uPos = {	localX = -1,
					localY = 0,
					localZ = 0,
					globalX = 0,
					globalY = 0,
					globalZ = 0}
	local dir = GetAngleBetweenPoints( avPos, uPos)	
	Log("Need dir "..tostring(dir))
	local moveParams = {
		deltaX = 0,
		deltaY = 0,
		deltaZ = 0,
		yaw = dir
	}
	qaMission.AvatarMoveAndRotate ( moveParams )	
	StartTimer( TIME_CONST, RotateCheck , { curdir = dir, count = 1, func = SecondRotate})
end

function SecondRotate()
	Log("Second Rotate ")
	local avPos = avatar.GetPos()
	local avDir = avatar.GetDir()
	local uPos = {	localX = 1,
					localY = 0,
					localZ = 0,
					globalX = 0,
					globalY = 0,
					globalZ = 0}
	local dir = GetAngleBetweenPoints( avPos, uPos)	
	Log("Need dir "..tostring(dir))
	local moveParams = {
		deltaX = 0,
		deltaY = 0,
		deltaZ = 0,
		yaw = dir
	}
	qaMission.AvatarMoveAndRotate ( moveParams )	
	StartTimer( TIME_CONST, RotateCheck , { curdir = dir, count = 1, func = FirstStep})
end
function RotateCheck(params)
	local avDir = avatar.GetDir()
	Log(tostring(params.count).." time dir "..tostring(avDir))
	if math.abs(math.abs(params.curdir) - math.abs(avDir)) < 0.2 then
		params.func()
	else
		if params.count < 5 then
			params.count = params.count + 1
			return StartTimer( TIME_CONST, RotateCheck , params)
		else
			return Warn( TEST_NAME, "Dir not changed" )
		end
	end
end

function FirstStep()
	Log("First Step ")
	Log("Need pos x = 3")
	local moveParams = {
		deltaX = 3,
		deltaY = 0,
		deltaZ = 0,
		yaw = 0
	}
	qaMission.AvatarMoveAndRotate ( moveParams )	
	StartTimer( TIME_CONST, MoveCheck , { curx = 3, count = 1, func = Success})
end

function MoveCheck(params)
	local avPos = avatar.GetPos()
	local avX = avPos.localX
	Log(tostring(params.count).." time dir "..tostring(avX))
	if math.abs(math.abs(params.curx) - math.abs(avX)) < 0.2 then
		params.func()
	else
		if params.count < 5 then
			params.count = params.count + 1
			return StartTimer( 500, MoveCheck , params)
		else
			return Warn( TEST_NAME, "Pos not changed" )
		end
	end
end
function OnServerLatency(params)
	Log("Current Latency "..tostring(params.latency))
end

function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" ),
		create = "AutoWarrior",
		delete = true
	}
	InitLoging(login)
	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	common.RegisterEventHandler( OnServerLatency, "EVENT_SERVER_LATENCY" )
end

Init()