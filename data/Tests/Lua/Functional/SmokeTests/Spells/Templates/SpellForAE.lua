--Наложение заклинаний на AE.
Global( "TEST_NAME", "SpellForAE" )

Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )

-- убрать
Global( "IDDQD_XDB", "Mechanics/Spells/Cheats/IDDQD/Spell.xdb")

Global( "MOB_NAME", nil )
Global( "TEST_SPELL", nil )

Global( "TARGET", nil )
Global( "MOB_ID1", nil )
Global( "MOB_ID2", nil )
Global( "LEVEL", nil )
Global( "TEST_SPELL_ID", nil )
Global( "DISTANCE", nil )
Global( "ANGLE", nil )
Global( "MOB_COUNT",0)
Global( "TEST_ERROR_TEXT", "" )
Global( "FUNC_AFTER_DESUMMON",nil)

function Done()
	FUNC_AFTER_DESUMMON = ClearDone
	DeSummonAll( )
end
function ClearDone()
	Success( TEST_SPELL .. " " .. TEST_NAME )
end
function ErrorBlya()
	Log("Cant desummon")
	Success( TEST_SPELL .. " " .. TEST_NAME )
end
function ClearExitErr()
	Warn( TEST_SPELL .. " " .. TEST_NAME, TEST_ERROR_TEXT )
end

function ErrorFunc( text )
	TEST_ERROR_TEXT = text
	FUNC_AFTER_DESUMMON = ClearExitErr
	DeSummonAll( )
end

function DeSummonAll()
	Log("DesummonALL")
	if MOB_ID1 ~= nil then
		DeSummon( MOB_ID1, DeSummon1, ErrorBlya )
		return
	elseif MOB_ID2 ~= nil then
		DeSummon( MOB_ID2, DeSummon2, ErrorBlya )
		return
	else
	    FUNC_AFTER_DESUMMON()
	end
end

function DeSummon1()
	MOB_ID1 = nil
	--Log("MOB_ID1: "..tostring(MOB_ID1) )
	DeSummonAll()
end

function DeSummon2()
	MOB_ID2 = nil
	--Log("MOB_ID2: "..tostring(MOB_ID2) )
	DeSummonAll()
end

-------------------------------------------------------------



function WaitTimeForTestSpell()
	StartTimer(2000, Done)
end

function SpellCasting()
	TEST_SPELL_ID = GetSpellId(TEST_SPELL)
	local info = avatar.GetSpellInfo(TEST_SPELL_ID)
	if info.targetType == SPELL_TYPE_POINT then
		local point = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), DISTANCE )
		local absPos = ToAbsCoord(point)
		local avPos = ToAbsCoord( avatar.GetPos() )
		--Log(tostring(absPos.X).." "..tostring(absPos.Y).." "..tostring(absPos.Z))
		--Log(tostring(avPos.X).." "..tostring(avPos.Y).." "..tostring(avPos.Z))
		local newPoint = {posX = absPos.X,posY = absPos.Y,posZ = absPos.Z}
		CastSpell( TEST_SPELL_ID, newPoint, 10000, WaitTimeForTestSpell, ErrorTestSpell)	
	else
		CastSpell( TEST_SPELL_ID, nil, 10000, WaitTimeForTestSpell, ErrorTestSpell)	
	end
end
function ErrorTestSpell(text,code)
	if code == "ENUM_ActionFailCause_Resisted" then
		LogErr("Resisted Spell",TEST_NAME)
		Done()
	else
		ErrorFunc(text)
	end
end
function SummonMobs(id)
	MOB_COUNT = MOB_COUNT + 1
	if MOB_COUNT == 1 then
		SummonMob1(-(ANGLE/2))
	elseif MOB_COUNT == 2 then
		MOB_ID1 = id
		--Log("MOB_ID1: "..tostring(MOB_ID1) )
		SummonMob1(ANGLE/2)	
	else
		MOB_ID2 = id
		--Log("MOB_ID2: "..tostring(MOB_ID2) )
		CastPrepareSpells(MOB_ID1, SpellCasting)
	end
end

function SummonMob1(angle)
	local pi = math.pi
	local dir = tonumber(avatar.GetDir()) + DegrToRad( angle )
	--Log("current dir "..tostring(avatar.GetDir()).." angle "..tostring(DegrToRad( angle ) ))
	--Log("dir "..tostring(dir) )
	if dir < 0 then
		dir = 2*pi + dir
	elseif dir > 2*pi  then
		dir = dir - 2*pi
	end
	--Log("final dir "..tostring(dir) )
	local unitPos = GetPositionAtDistance( avatar.GetPos(), dir, DISTANCE )
	local absPos = ToAbsCoord(unitPos)
	--Log(tostring(absPos.X).." "..tostring(absPos.Y).." "..tostring(absPos.Z))
   	SummonMob( MOB_NAME, MAP_RESOURCE, unitPos, 0, SummonMobs, ErrorFunc, 0.5 )
end
function LearnPrepare()
	LearnPrepareSpells(SummonMobs)
end
---------------------------EVENTS----------------------------

function OnAvatarCreated( params )
	StartTest(TEST_NAME)
	local spells = {}
	table.insert(spells,TEST_SPELL)
	LevelUp( LEVEL, spells, LearnPrepare , ErrorFunc)
end

function Init()
	local login = {
		login = developerAddon.GetParam( "login" ),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	TEST_SPELL = developerAddon.GetParam( "Spell" )
	
	TEST_NAME = TEST_SPELL.." - "..developerAddon.GetParam( "avatar" )..". Template: "..TEST_NAME
	
	InitLoging(login)
	
    local level = developerAddon.GetParam ( "Level" )
    if level ~= "" then
    	LEVEL = tonumber(level)
    end
    local dist = developerAddon.GetParam ( "Distance" )
    if dist ~= "" then
    	DISTANCE = tonumber(dist)
    end
    local angle = developerAddon.GetParam ( "Angle" )
    if angle ~= "" then
    	ANGLE = tonumber(angle)
    end
	MOB_NAME = "Tests/Mobs/AllLevels/Bee/Bee"..tostring(LEVEL)..".xdb"
    
	GetPrepareSpellsFromAddon()
	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()