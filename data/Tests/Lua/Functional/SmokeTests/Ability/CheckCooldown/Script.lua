Global( "TEST_NAME", "SmokeTest.Ability.Cooldown; author: Liventsev Andrey, date: 13.08.08, task# 37328" )

-- params
Global( "SPELL1", nil )
Global( "SPELL2", nil )
Global( "SPELL2_BUFF", nil )
Global( "SPELL2_TIME", nil )

Global( "MOB_NAME",   "Tests/Maps/Test/Instances/FarmTarget.(MobWorld).xdb" )
Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )
--/ params

Global( "ERROR_TEXT", nil )
Global( "CUR_UNIT_ID", nil )
Global( "LEARN_INDEX", nil )



function LearnSpells()
	if LEARN_INDEX == 0 then
		LEARN_INDEX = 1
		LearnSpell( SPELL1, LearnSpells, ErrorFunc )
     
	elseif LEARN_INDEX == 1 then
		LEARN_INDEX = 2
		LearnSpell( SPELL2, LearnSpells, ErrorFunc )	
		
	elseif LEARN_INDEX == 2 then
		ImmuneAvatar( Summon1, ErrorFunc )	
	end
end

function Summon1()
     local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
     SummonMob( MOB_NAME, MAP_RESOURCE, newPos, avatar.GetDir() - math.pi/2, BeforeCast11, ErrorFunc )
end

function BeforeCast11( unitId )
	StartTimer( 2000, Cast11, unitId )
end

function Cast11( unitId )
	Log()
	Log( "casting ability#1: " .. SPELL1 )
	qaMission.AvatarRevive()
	CUR_UNIT_ID = unitId
	
	local effects = {}
	table.insert( effects, {
		type = EFFECT_DAMAGE,
		damageSource = CHECKDMG_SOURCE_SPELL,
		targetId = CUR_UNIT_ID,
		sourceId = avatar.GetId() }
	)
	CastSpellToTarget( CUR_UNIT_ID, GetSpellId( SPELL1 ), nil, 2000, Cast12, ErrorFunc, effects )
end

function Cast12()
	Log( "casting ability#1 - good" )
	Log()
	Log( "casting ability#1 again" )	
	local effects = {}
	table.insert( effects, {
		type = EFFECT_DAMAGE,
		damageSource = CHECKDMG_SOURCE_SPELL,
		targetId = CUR_UNIT_ID,
		sourceId = avatar.GetId() }
	)
	
	ERROR_TEXT = "No cooldown for spell: "  .. SPELL1
	CastSpellToTarget( CUR_UNIT_ID, GetSpellId( SPELL1 ), nil, 2000, CustomErrorFunc, BeforeCast21, effects )
end

function BeforeCast21()
	Log( "can't casting ability#1 again - thats good" )
	DisintagrateMob( MOB_NAME )
	StartTimer( 4000, Cast21 )
end

function Cast21()
	Log()
	Log( "casting ability#2" )
	qaMission.AvatarRevive()
	
	local effects = {}
	local effect = {
		type = EFFECT_BUFF,
		unitId = avatar.GetId(),
		buffName = SPELL2_BUFF
	}
	table.insert( effects, effect )
	
	CastSpellToTarget( avatar.GetId(), GetSpellId( SPELL2 ), nil, 1000, BeforeCast22, ErrorFunc, effects )
end

function BeforeCast22()
	Log( "casting ability#2 - good" )
	StartTimer( SPELL2_TIME * 1000, Cast22 )
end

function Cast22()
	Log()
	Log( "casting ability#2 again" )	
	local effects = {}
	local effect = {
		type = EFFECT_BUFF,
		unitId = avatar.GetId(),
		buffName = SPELL2_BUFF
	}
	table.insert( effects, effect )

	ERROR_TEXT = "No cooldown for spell: "  .. SPELL2
	CastSpellToTarget( avatar.GetId(), GetSpellId( SPELL2 ), nil, 1000, CustomErrorFunc, Done, effects )
end

function CustomErrorFunc()
	ErrorFunc( ERROR_TEXT )
end

function Done()
	Success( TEST_NAME )
end

function ErrorFunc( text )
	DisintagrateMob( MOB_NAME )
	StartTimer( 4000, ErrorFunc2, text )
end

function ErrorFunc2( text )
	Warn( TEST_NAME, text )
end

--------------------------------------- EVENTS ------------------------------------

function OnAvatarCreated()
     StartTest( TEST_NAME )
	 
	 LEARN_INDEX = 0
	 LevelUp( 10, nil, LearnSpells, ErrorFunc )
end

function Init()
     local login = {
          login = developerAddon.GetParam( "login"),
          pass = developerAddon.GetParam( "password" ),
          avatar = developerAddon.GetParam( "avatar" ),
		  create = "AutoMage"
     }
     InitLoging(login)
     
     SPELL1 = developerAddon.GetParam( "AbilityName" )
     SPELL2 = developerAddon.GetParam( "CooldownAbilityName" )
     SPELL2_BUFF = developerAddon.GetParam( "CooldownAbilityBuffName" )
     SPELL2_TIME = developerAddon.GetParam( "CooldownAbilityTime" )

     common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()