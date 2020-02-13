
--Ќаложение заклинаний на моба или в точку.
Global( "TEST_NAME", "SpellForEnemy" )

Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )

Global( "MOB_NAME", nil )

Global( "TEST_SPELL", nil )

Global( "TARGET", nil )
Global( "MOB_ID", nil )
Global( "LEVEL", nil )
Global( "SPELL_FAIL_NOTARGET_FIRST_TIME", true )

Global( "TEST_SPELL_ID", nil )
Global( "DISTANCE", nil )
Global( "TEST_ERROR_TEXT", "" )

function Done()
	DeSummon( MOB_ID, ClearDone, ErrorBlya )
end
function ClearDone()
	Success( TEST_SPELL .. " " .. TEST_NAME )
end
function ErrorBlya()
	Log("Cant desuummon")
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
	CastPrepareSpells(MOB_ID, SelectMob)
end

function WaitTimeForTestSpell()
	StartCheckTimer( 30000, AvatarHaveDot, nil, ErrorFunc, "stack fail!!", Done, nil )
end
function SelectMob( )
	SelectTarget( MOB_ID, SpellCasting, ErrorFunc )
end
function SpellCasting()
	CastSpell( TEST_SPELL_ID, TARGET, 10000, SpellCastingSecond, ErrorTestSpell)	
end

function SpellCastingSecond()
	CastSpell( TEST_SPELL_ID, TARGET, 10000, WaitTimeForTestSpell, ErrorTestSpell)	
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

function AvatarHaveDot()                          
	local avatarId = avatar.GetId()
 	local activeBuffs = unit.GetBuffCount(avatarId)
	local stack = 0
	local time = 0
	local name = ""
	while activeBuffs > 0 do
		local buff = unit.GetBuff( avatarId, activeBuffs - 1)
	    stack = buff.stackCount
		time = buff.remainingMs
		name = buff.debugName
		activeBuffs = activeBuffs - 1
	end
	Log("Buff stack "..tostring(stack).." time "..tostring(time)..""..name)
	if stack == 2 then
		return true
	else
		return false
	end
end
function SummonTheMob()
    --SpellBookToLog()
	TEST_SPELL_ID = GetSpellId(TEST_SPELL)
	local info = avatar.GetSpellInfo(TEST_SPELL_ID)
	Log("\tSpell range: "..tostring(info.range))
	if info.range > 1 then
		DISTANCE = info.range - 1
	else
		DISTANCE = 5
	end
	local unitPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), DISTANCE )
   	SummonMob( MOB_NAME, MAP_RESOURCE, unitPos, avatar.GetDir() - math.pi/2, CastPrepare, ErrorFunc )
end



---------------------------EVENTS----------------------------

function OnAvatarCreated( params )
	StartTest(TEST_NAME)
	local spells = {}
	table.insert(spells,TEST_SPELL)
	
	LevelUp( LEVEL, nil, CheckForSelectSpell, ErrorFunc)
end

function Init()
	local login = {
		login = "luabot555",
		pass = "luabot555",
		avatar = "skldsdkf",
		create = "AutoMage",
		delete = true,
		flagExit = true
	}

    local level = developerAddon.GetParam ( "Level" )
    if level ~= "" then
    	LEVEL = tonumber(level)
    else
        TEST_ERROR_TEXT = "Wrong Level parametr"
		return ClearExitErr()
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
		elseif TARGET_TYPE == "demon" then
		    MOB_NAME = "Creatures/DemonScout/Instances/SecretLab/DemonScoutEliteKind_SL.xdb22_22.(MobWorld).xdb"
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