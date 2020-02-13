Global( "TEST_NAME", "Smoke test. Check for casting bad ability to enemy mob. author: Liventsev Andrey. date: 22.07.2008. task: 37317" )

-- param from xdb
Global( "ENEMY_NAME", nil )
Global( "SPELL_NAME",  nil )
Global( "DEBUFF_NAME",   nil )
Global( "DEBUFF_DEBUG_NAME",   nil )
-- /param from xdb

Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )
Global( "IMMUNE_SPELL", "Mechanics/Spells/Cheats/IDDQD/Spell.xdb" )
Global( "SPELL_INDEX", nil )

function LearnSpells()
	if SPELL_INDEX == 0 then
		SPELL_INDEX = 1
		LearnSpell( SPELL_NAME, LearnSpells, ErrorFunc)
		
	elseif SPELL_INDEX == 1 then
		SPELL_INDEX = 2
		LearnSpell( DEBUFF_NAME, LearnSpells, ErrorFunc)
		
	elseif SPELL_INDEX == 2 then
		SPELL_INDEX = 3
		LearnAndCastSpell( IMMUNE_SPELL, TEST_NAME )
		StartTimer( 3000, LearnSpells )
		
	elseif SPELL_INDEX == 3 then
		LevelUp( 20, nil, Summon, ErrorFunc )
	end	
end

function Summon()
	local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
	SummonMob( ENEMY_NAME, MAP_RESOURCE, newPos, 0, BeforeCastingBadSpell, ErrorFunc )
end

function BeforeCastingBadSpell()
	Log( "before casting bad spell" )
	StartTimer( 2000, CastingBadSpell )
end

function CastingBadSpell()
	Log( "" )
	Log( "casting bad spell..." )
	
	local effects = {}
	table.insert( effects, {
		type = EFFECT_DAMAGE,
		damageSource = CHECKDMG_SOURCE_SPELL,
		targetId = GetMobId( ENEMY_NAME ),
		sourceId = avatar.GetId() }
	)

    qaMission.AvatarRevive()
	CastSpellToTarget( GetMobId( ENEMY_NAME ), GetSpellId( SPELL_NAME ), nil, 5000, BeforeCastingDebuffSpell, ErrorFunc, effects )
end

function BeforeCastingDebuffSpell()
	Log( "before casting debuff spell" )
	StartTimer( 1000, CastingDebuffSpell )
end

function CastingDebuffSpell()
	Log( "" )
	Log( "casting debuff spell" )
	
	local effects = {}
	local effect = {
		type = EFFECT_BUFF,
		unitId = GetMobId( ENEMY_NAME ),
		buffName = DEBUFF_DEBUG_NAME
	}
	table.insert( effects, effect )

    CastSpell( GetSpellId( DEBUFF_NAME ), unitId, 5000, Done, ErrorFunc, effects )
end

function Done()
	DisintagrateMob( ENEMY_NAME )
	StartTimer( 3000, Success, TEST_NAME )
end

function ErrorFunc( text )
	DisintagrateMob( ENEMY_NAME )
	StartTimer( 3000, ErrorFunc2, text )
end

function ErrorFunc2( text )
	Warn( TEST_NAME, text )
end


----------------------------------- EVENTS -------------------------------------

function OnAvatarCreated( params )
	StartTest( TEST_NAME )
	
	SPELL_INDEX = 0
	LearnSpells()
end


function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" ),
		create = "AutoMage"
	}
	InitLoging(login)
	
	ENEMY_NAME = developerAddon.GetParam( "EnemyName" )
	SPELL_NAME = developerAddon.GetParam( "SpellName" )
	DEBUFF_NAME = developerAddon.GetParam( "DeBuffSpell" )
	DEBUFF_DEBUG_NAME = developerAddon.GetParam( "DeBuffDebugName" )

	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()