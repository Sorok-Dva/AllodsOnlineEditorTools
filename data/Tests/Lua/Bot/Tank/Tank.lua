Global("TEST_NAME", "TankTest.LiventsevAndrey.20.05.08")

Global("STATE",-1)
Global("WAITING",0)
Global("TURNING",1)
Global("RUNNING",2)

Global("FIGHT", false)

Global("TIME",0)
Global("TIME_FINISH",0)
Global("TIMER", false)

Global("TURN_KOEF", 0)

Global("CUR_UNIT_ID", nil)
Global("TELEPORTED", false)
Global("RANGE", 12)


function StartTimer(millisec)
	TIME = 0
	TIME_FINISH = millisec
	TIMER = true
end

function MovePerson( time )
	STATE = RUNNING
	StartTimer(time)
	qaMission.AvatarCustomInputMove( true )
end

function WaitPerson( time )
	local dir = avatar.GetDir()

	STATE = WAITING
	StartTimer(time)
	qaMission.AvatarCustomInputMove( false )
end

function turnPerson( rads, time )
	STATE = TURNING
	StartTimer(time)
	qaMission.AvatarCustomInputMove( false )
	qaMission.AvatarCustomInputEnable( rads )
end

function CreateBee()
    avatar.SendChatMessage( debugCommon.ToWString("creating a bee" ))
    
	local newPos = PositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
	qaMission.SummonMob( "Creatures/Bee/Instances/Bee.xdb", "/Tests/Maps/Lua/MapResource.xdb", newPos, 0 )
end

function IsAggressive( unitId )
    local aggro = debugMission.UnitGetAggroList( unitId )
    if aggro then
    	for key, value in aggro do
			if key == avatar.GetId() then
                avatar.SendChatMessage( debugCommon.ToWString("Unit aggresive value =".. tostring(value)) )
				if value > 0 then
				    return true
				else
				    return false
				end
			end
	    end
	end

    avatar.SendChatMessage( debugCommon.ToWString("Unit don't care about you" ))
	return false
end

                                                                    -- EVENTS --

function OnAvatarCreated( params )
	qaMission.AvatarLearnSpell("Mechanics/Spells/Cheats/IDDQD/Spell.xdb")

	local tmpPos = {X=100, Y=100, Z=0}
	local absTmpPos = ToStandartPosition(tmpPos)
	qaMission.AvatarSetPos( absTmpPos )

    qaMission.AvatarCustomInputEnable( true )
end

function OnDebugTimer( params )
	if FIGHT and TIMER then
		TIME = TIME + params.delta
    	if TIME >= TIME_FINISH then
	    	if STATE == WAITING then
	    		MovePerson(7000)
	    	elseif STATE == RUNNING then
    	    	TURN_KOEF = TURN_KOEF+1
	    		turnPerson((TURN_KOEF * math.pi * 90) / 180, 1000)
	    	elseif STATE == TURNING then
	    		WaitPerson(500)
	    	end
        end
	end
end

function OnUnitAgroListChanged( params )
	local unitId = GetUnitId("Creatures/Bee/Instances/Bee.xdb")
	if params.unitId == unitId then
		if IsAggressive(params.unitId) then

			FIGHT = true
			MovePerson(7000)
		else
			FIGHT = false
			
			avatar.SendChatMessage( debugCommon.ToWString("Disintegrate mob" ))
            qaMission.DisintegrateMob( unitId )
            CreateBee()
		end
	end
end

function OnUnitSpawned( params )
	CUR_UNIT_ID = params.unitId
	avatar.SelectTarget( params.unitId )
end

function OnAvatarPrimaryTargetChanged( params )
	local spellBook = avatar.GetSpellBook()
	avatar.RunSpell( spellBook[0] )
end

function OnAvatarPosChanged(params)
	if not TELEPORTED then
  		local spellId = GetSpellId("Mechanics/Spells/Cheats/IDDQD/Spell.xdb")
		avatar.RunSpell( spellId )
	
	    TELEPORTED = true
		local spellBook = avatar.GetSpellBook()
		avatar.RunSpell( spellBook[0] )
	    CreateBee()
	end
end

                                                           -- ф-ции из библиотек
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

function RandomPos()
	local dX = math.random()
	dX = dX * RANGE
	local dY = math.random()
	dY = dY * RANGE
	local tmpPos = avatar.GetPos()
	tmpPos = AbsolutlyPosition(tmpPos)

	local pos = {}
	pos.X = tmpPos.X + dX
	pos.Y = tmpPos.Y + dY
	pos.Z = tmpPos.Z
	return ToStandartPosition(pos)
end

function GetUnitId( name )
 	local units = avatar.GetUnitList()
    local id = nil
	if units == nil then
	    return nil
	else
		for key, value in units do
			local curname = qaMission.UnitGetXDB(value)
  			local dead = unit.IsDead( value )
  			if (curname == name) and ( not dead ) then
  			    return units[key]
  			end
		end
		return nil
	end
end

function GetSpellId( nameSpell)
	local spellBook = avatar.GetSpellBook()
	for i, idSpell in spellBook do
	  local spellInfo = avatar.GetSpellInfo( idSpell )
		local length = string.len( nameSpell )
	  if string.sub( spellInfo.debugName, 1, length ) == nameSpell then
	     return idSpell
	  end
	end
	
	return nil
end

function PositionAtDistance(position, direction, distance)
	local dy = math.sin(direction)
    local dx = math.cos(direction)
	local apos = AbsolutlyPosition(position)
	apos.X = apos.X + (dx*distance)
	apos.Y = apos.Y + (dy*distance)
	local spos = ToStandartPosition(apos)
	return spos
end


function Init()
	--common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	common.RegisterEventHandler( OnDebugTimer, "EVENT_DEBUG_TIMER" )
	common.RegisterEventHandler( OnUnitAgroListChanged, "EVENT_UNIT_AGGRO_LIST_CHANGED" )
	common.RegisterEventHandler( OnUnitSpawned, "EVENT_UNIT_SPAWNED" )
	common.RegisterEventHandler( OnAvatarPrimaryTargetChanged, "EVENT_AVATAR_SECONDARY_TARGET_CHANGED" )
	common.RegisterEventHandler( OnAvatarPosChanged, "EVENT_AVATAR_POS_CHANGED" )
	OnAvatarCreated()
end


Init()