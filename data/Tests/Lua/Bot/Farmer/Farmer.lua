--
-- Global vars
--

-- declare global var
Global("RANGE", 20)
Global("UNIT_NAME", "Creatures/Bee/Instances/Bee.xdb")
Global("IDDQD", "Mechanics/Spells/Cheats/IDDQD/Spell.xdb")
Global("TEST_NAME", "TravellerTest")
Global("STATE",0)
Global("SETTING_DIR",1)
Global("RUNNING",2)
Global("FIND_MOB",3)
Global("KILL_MOB",4)


Global("TIME",0)
Global("TIME_FINISH",0)
Global("TIMER", false)

Global("POS", nil)

Global("RUN", false)

Global("LEFT_DOWN_POS",nil)

Global("DIST_TO_POINT",4)
Global("ATTACKID",nil)
Global("CHEATID",nil)
Global("UNIT_ID",nil)

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

function RandomPos()
	local dX = math.random()
	dX = dX * RANGE
	local dY = math.random()
	dY = dY * RANGE
	local pos = {}
	pos.X = LEFT_DOWN_POS.X + dX
	pos.Y = LEFT_DOWN_POS.Y + dY
	pos.Z = LEFT_DOWN_POS.Z
	POS = ToStandartPosition(pos)
end

function Traveller()
	if STATE == FIND_MOB then
		RUN = false
		RandomPos()
		qaMission.SummonMob( UNIT_NAME, "/Tests/Maps/Lua/MapResource.xdb", POS, 0 )

		STATE = SETTING_DIR

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
		startTimer(100)
	elseif STATE == RUNNING then
		local dist = Distance()
		RUN = true
	    STATE = KILL_MOB
	    if dist > DIST_TO_POINT then
	    	qaMission.AvatarCustomInputMove( true )
	    else
			startTimer(100)
	    end
	elseif STATE == KILL_MOB  then
	    avatar.RunSpell(ATTACKID)
	end
end


-- EVENT_AVATAR_CREATED
function OnAvatarCreated( params )
	local spellbook = avatar.GetSpellBook()
	for i, id in spellbook do
		local spellInfo = avatar.GetSpellInfo( id )
		if spellInfo.debugName == "Client/GMUIHelper/AutoAttackMelee.(SpellSingleTarget).xdb" then
			ATTACKID = id
		end
	end

 	qaMission.AvatarCustomInputEnable(true )
    local avatarPos = avatar.GetPos()
	LEFT_DOWN_POS = AbsolutlyPosition(avatarPos)

	qaMission.AvatarLearnSpell( IDDQD )
	--STATE = FIND_MOB
	--startTimer(1000)
end

function OnAvatarPosChanged( params )
	if RUN then
	    local dist = Distance()
		if dist < DIST_TO_POINT then
			RUN = false
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

-- EVENT_UNIT_SPAWNED

function OnUnitSpawned( params )
	local name = qaMission.UnitGetXDB( params.unitId )
    local dead = unit.IsDead( params.unitId )
	if name == UNIT_NAME and not dead then
	    UNIT_ID = params.unitId
		avatar.SelectTarget(params.unitId)
		startTimer(100)
	end
end

function OnSpellBookAdded( params )

	local spellbook = avatar.GetSpellBook()
	for i, id in spellbook do
		local spellInfo = avatar.GetSpellInfo( id )
  		if spellInfo.debugName == IDDQD then
			CHEATID = id
		end
	end
	avatar.RunSpell(CHEATID)
	STATE = FIND_MOB
	startTimer(1000)
end

function OnUnitDead( params )
	if params.unitId == UNIT_ID then
	    STATE = FIND_MOB
	    startTimer(100)
	end
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

 	--local login = {login = "bots",pass = "", avatar = "traveller"}
	--InitLoging(login)
	--common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	common.RegisterEventHandler( OnAvatarPosChanged, "EVENT_AVATAR_POS_CHANGED" )
    common.RegisterEventHandler( OnDebugTimer, "EVENT_DEBUG_TIMER" )
    common.RegisterEventHandler( OnUnitSpawned, "EVENT_UNIT_SPAWNED" )
    common.RegisterEventHandler( OnSpellBookAdded, "EVENT_SPELLBOOK_ELEMENT_ADDED")
    common.RegisterEventHandler( OnUnitDead, "EVENT_UNIT_DEAD_CHANGED")
    OnAvatarCreated()
end

--
-- main initialization
--

Init()
