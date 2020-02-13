
--Ќаложение заклинаний на моба или в точку.
Global( "TEST_NAME", "SpellForEnemyWithDist" )

Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )

Global( "MOB_NAME", nil )
Global( "SPELL_FAIL_NOTARGET_FIRST_TIME", true )
Global( "TEST_SPELL", nil )

Global( "TARGET", nil )
Global( "MOB_ID", nil )
Global( "LEVEL", nil )

Global( "TEST_SPELL_ID", nil )
Global( "SPELL_IS_ABILITY", false )
Global( "DISTANCE", nil )
Global( "TIME_PREPARE", 0 )
Global( "TEST_ERROR_TEXT", "" )

function Done()
	DeSummon( MOB_ID, ClearDone, ErrorBlya )
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
	if MOB_ID ~= nil then
		DeSummon( MOB_ID, ClearExitErr, ErrorBlya )
	else
	    ClearExitErr()
	end
end

function CheckForSelectSpell()
	LearnPrepareSpells(SummonTheMob)
end

function CastPrepare(id)
	MOB_ID = id
	CastPrepareSpells(MOB_ID, WaitTimeForPrepare)
end

function WaitTimeForPrepare()
	local waitTime = TIME_PREPARE
	Log("wait..."..tostring(waitTime))
	StartTimer(waitTime, SelectMob)
end

function WaitTimeForTestSpell()
	StartTimer(2000, Done)
end

function SpellCasting()
	if not SPELL_IS_ABILITY then
		CastSpell( TEST_SPELL_ID, TARGET, 10000, WaitTimeForTestSpell, ErrorTestSpell)	
	else
		WaitTimeForTestSpell()
	end
end

function ErrorTestSpell(text,code)
	if code == "ENUM_ActionFailCause_Resisted" then
		LogErr("Resisted Spell",TEST_NAME)
		Done()
	elseif code == "ENUM_ActionFailCause_NoTarget" then
		if SPELL_FAIL_NOTARGET_FIRST_TIME then
			SPELL_FAIL_NOTARGET_FIRST_TIME = false
			StartTimer(1000,SpellCasting,nil)
		else
			ErrorFunc(text)
		end
	else
		ErrorFunc(text)
	end
end

function SummonTheMob()
    --SpellBookToLog()
	if not SPELL_IS_ABILITY then
		TEST_SPELL_ID = GetSpellId(TEST_SPELL)
		local info = avatar.GetSpellInfo(TEST_SPELL_ID)
		Log("\tSpell range: "..tostring(info.range).." Distance "..tostring(DISTANCE))
		DISTANCE = DISTANCE - 0.5
	end
	local unitPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), DISTANCE )
   	SummonMob( MOB_NAME, MAP_RESOURCE, unitPos, avatar.GetDir() - math.pi/2, CastPrepare, ErrorFunc )
end

function SelectMob( )
	SelectTarget( MOB_ID, SpellCasting, ErrorFunc )
end

---------------------------EVENTS----------------------------

function OnAvatarCreated( params )
	StartTest(TEST_NAME)
	local spells = {}
	local abilki = {}
	if SPELL_IS_ABILITY then
		table.insert(abilki,TEST_SPELL)
	else
		table.insert(spells,TEST_SPELL)
	end
	LevelUp( LEVEL, spells, CheckForSelectSpell, ErrorFunc, abilki)
end

function Init()
	local login = {
		login = developerAddon.GetParam( "login" ),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}

    local level = developerAddon.GetParam ( "Level" )
    if level ~= "" then
    	LEVEL = tonumber(level)
    else
        TEST_ERROR_TEXT = "Wrong Level parametr"
		return ClearExitErr()
    end

    local dist = developerAddon.GetParam ( "Distance" )
    if dist ~= "" then
    	DISTANCE = tonumber(dist)
    else
        TEST_ERROR_TEXT = "Wrong Distance parametr"
		return ClearExitErr()
    end
    local time1 = developerAddon.GetParam ( "Time" )
    if time1 ~= "" then
    	TIME_PREPARE = tonumber(time1)
    else
        TEST_ERROR_TEXT = "Wrong Time parametr"
		return ClearExitErr()
    end
	local ability = developerAddon.GetParam( "SpellIsAbility" )
	if ability ~= "" then
		if ability == "true" then
			SPELL_IS_ABILITY = true
		elseif ability == "false" then
			SPELL_IS_ABILITY = false
		else
			TEST_ERROR_TEXT = "Wrong SpellIsAbility parametr"
			return ClearExitErr()
		end
	end
	TEST_SPELL = developerAddon.GetParam( "Spell" )
	if TEST_SPELL == nil then
        TEST_ERROR_TEXT = "Wrong Spell parametr"
		return ClearExitErr()
	end
	TEST_NAME = TEST_SPELL.." - "..developerAddon.GetParam( "avatar" )..". Template: "..TEST_NAME
	
	local TARGET_TYPE = developerAddon.GetParam ( "TargetType" )
	if TARGET_TYPE ~= "" then
		if TARGET_TYPE == "passiv" then
		    MOB_NAME = "Tests/Mobs/AllLevels/Bee/Bee"..tostring(LEVEL)..".xdb"
		elseif TARGET_TYPE == "aggro" then
		    MOB_NAME = "Creatures/Bear/Instances/Bear5MiniBoss.xdb"
		elseif TARGET_TYPE == "friend" then
			MOB_NAME = "Characters/Kania_female/Instances/ArchipelagoLeague1/NPC1_3.xdb"
		elseif TARGET_TYPE == "humanoid" then
		    MOB_NAME = "Characters/Kania_male/Instances/ArchipelagoLeague1/RuffianWarrior4_5.xdb"
		elseif TARGET_TYPE == "undead" then
		    MOB_NAME = "Creatures/SkeletonWarrior/Instances/SkeletonWarrior4_5AL1.xdb"
		elseif TARGET_TYPE == "hilvl" then
		    MOB_NAME = "Creatures/ZombieWarrior/Instances/AstralHub03/ZombieWarriorElite40_40.(MobWorld).xdb"
		else
	        TEST_ERROR_TEXT = "Wrong TargetType parametr"
			return ClearExitErr()
		end
	else
        TEST_ERROR_TEXT = "Wrong TargetType parametr"
		return ClearExitErr()
	end
	GetPrepareSpellsFromAddon()
	InitLoging(login)
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()