--
-- Global vars
--

-- declare global var
Global("RANGE", 12)

Global("TEST_NAME", "TravellerTest")
Global("STATE",-1)
Global("SETTING_DIR",1)
Global("RUNNING",2)
Global("FIND_POINT",3)
Global("WAITING",0)

Global("TIME",0)
Global("TIME_FINISH",0)
Global("TIMER", false)

Global("POS", nil)

Global("RUN", false)

Global("LEFT_DOWN_POS",nil)

Global("DIST_TO_POINT",nil)

-- EVENT_DEBUG_TIMER

function OnDebugTimer( params )

	if TIMER then
		TIME = TIME + params.delta
    	if TIME >= TIME_FINISH then
    	    TIMER = false
    	    Traveller()
        end
    end

end

function startTimer(millisec)
	TIME = 0
	TIME_FINISH = millisec
	TIMER = true
end

function Traveller()
	if STATE == FIND_POINT then
		RUN = false
		local dX = math.random()
		dX = dX * (RANGE-2)
		local dY = math.random()
		dY = dY * (RANGE-2)
  		local pos = {}
		pos.X = LEFT_DOWN_POS.X + dX + 1
		pos.Y = LEFT_DOWN_POS.Y + dY + 1
		pos.Z = LEFT_DOWN_POS.Z
		POS = ToStandartPosition(pos)
		common.LogInfo("X: "..tostring(POS.localX).."Y: "..tostring(POS.localY).."--"..tostring(LEFT_DOWN_POS.X).."--"..tostring(LEFT_DOWN_POS.Y))
		STATE = SETTING_DIR
		startTimer(100)
	elseif STATE == SETTING_DIR then
		local avatarPos = avatar.GetPos()
		local firstPoint = AbsolutlyPosition (avatarPos)
		local secPoint = AbsolutlyPosition (POS)
        local yaw = (secPoint.Y-firstPoint.Y)/(secPoint.X-firstPoint.X)
		yaw = math.atan(yaw)
		if (secPoint.X-firstPoint.X) < 0 then
		yaw = yaw + math.pi
		end
		qaMission.AvatarCustomInputEnable( yaw )
		STATE = RUNNING
		startTimer(1000)
	elseif STATE == RUNNING then
		DIST_TO_POINT = Distance()
		RUN = true
	    STATE = FIND_POINT
	    qaMission.AvatarCustomInputMove( true )
	end
end

-- EVENT_AVATAR_CREATED
function OnAvatarCreated( params )
 	qaMission.AvatarCustomInputEnable(true )

	local avatarPos = avatar.GetPos()
	LEFT_DOWN_POS = AbsolutlyPosition(avatarPos)

	STATE = FIND_POINT
	startTimer(1000)
end

function OnAvatarPosChanged( params )
	if RUN then
	    local dist = Distance()
		if dist < DIST_TO_POINT then
			DIST_TO_POINT = dist
		else
			qaMission.AvatarCustomInputMove( false )
			startTimer(100)
		end
	end
end

function Distance()
		local pos = avatar.GetPos()
		local GlobalDiff = math.abs(POS.globalX - pos.globalX) + math.abs(POS.globalY - pos.globalY)
		local LocalDiff = math.abs(POS.localX - pos.localX) + math.abs(POS.localY - pos.localY)
		return (GlobalDiff*32) + LocalDiff
end

function AbsolutlyPosition(pos)
	local ret = {}
	ret.X = pos.globalX*32 + pos.localX
	ret.Y = pos.globalY*32 + pos.localY
	ret.Z = pos.globalZ*32 + pos.localZ
	return ret
end

function ToStandartPosition(pos)
	local ret = {}
	local del = modf(pos.X,32)
	ret.localX = del.drob
	ret.globalX = del.cel
	del = modf(pos.Y,32)
	ret.localY = del.drob
	ret.globalY = del.cel
	del = modf(pos.Z,32)
	ret.localZ = del.drob
	ret.globalZ = del.cel
	return ret
end

function modf(x,d)
	local ret = {cel = 0, drob = 0}
	local t = x/d
	if x>0 then
		ret.cel = math.floor(t)
		ret.drob = x - (ret.cel*d)
	else
		ret.cel = math.ceil(t)
		ret.drob = x - (ret.cel*d)
	end
	return ret
end
--
-- main initialization function
--

function Init()

	--common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	common.RegisterEventHandler( OnAvatarPosChanged, "EVENT_AVATAR_POS_CHANGED" )
    common.RegisterEventHandler( OnDebugTimer, "EVENT_DEBUG_TIMER" )
    OnAvatarCreated()

end

--
-- main initialization
--

Init()
