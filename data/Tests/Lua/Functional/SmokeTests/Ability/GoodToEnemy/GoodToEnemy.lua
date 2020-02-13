Global( "TEST_NAME", "Smoke test.GoodToEnemy. author: Liventsev Andrey. date: 22.07.2008. task: 37319" )

-- param from xdb
Global( "ENEMY_NAME", nil )
Global( "SPELL_NAME",  nil )
Global( "BUFF_NAME",   nil )
Global( "BUFF_DEBUG_NAME",   nil )
-- /param from xdb

Global( "DAMAGE_SPELL", "Mechanics/Spells/Necromancer/AcidBolt/Spell01.xdb" )
Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )
Global( "IMMUNE_SPELL", "Mechanics/Spells/Cheats/IDDQD/Spell.xdb" )
Global( "SPELL_INDEX", 0 )
Global( "ERROR_TEXT", nil )

function LearnSpells()
	if SPELL_INDEX == 0 then
		SPELL_INDEX = 1
		LearnSpell( DAMAGE_SPELL, LearnSpells, ErrorFunc )
		
	elseif SPELL_INDEX == 1 then
		SPELL_INDEX = 2
		LearnSpell( SPELL_NAME, LearnSpells, ErrorFunc )
		
	elseif SPELL_INDEX == 2 then
		SPELL_INDEX = 3
		LearnSpell( BUFF_NAME, LearnSpells, ErrorFunc )
		
	elseif SPELL_INDEX == 3 then
		SPELL_INDEX = 4
		LearnAndCastSpell( IMMUNE_SPELL, TEST_NAME )
		StartTimer( 500, LearnSpells )		
		
	elseif SPELL_INDEX == 4 then
		LevelUp( 20, nil, BeforeCastDamage, ErrorFunc )
	end	
end

function BeforeCastDamage()
	StartTimer( 2000, CastDamage )
end

function CastDamage()
	Log( "" )
	Log( "cast damage" )
	
	local effects = {}
	table.insert( effects, {
		type = EFFECT_DAMAGE,
		damageSource = CHECKDMG_SOURCE_SPELL,
		targetId = GetMobId( ENEMY_NAME ),
		sourceId = avatar.GetId() }
	)
	
    qaMission.AvatarRevive()
	CastSpellToTarget( GetMobId( ENEMY_NAME ), GetSpellId( DAMAGE_SPELL ), nil, 4000, BeforeCastHealing, ErrorFunc, effects )
end

function BeforeCastHealing()
	StartTimer( 1000, CastHealing )
end

function CastHealing()
	Log( "" )
	Log( "cast healing" )
	local effects = {}
	local effect = {
		type = EFFECT_HEAL,
		unitId = GetMobId( ENEMY_NAME ),
		healerId = avatar.GetId()
	}
	table.insert( effects, effect )

    ERROR_TEXT = "Casting " .. SPELL_NAME .. " to enemy mob is possible"
	CastSpell( GetSpellId( SPELL_NAME ), nil, 6000,  CustomErrorFunc, BeforeCastBuffSpell, effects )
end

function BeforeCastBuffSpell()
	StartTimer( 2000, CastBuffSpell )
end

function CastBuffSpell()
	Log( "" )
	Log( "cast buff spell" )

	local effects = {}
	local effect = {
		type = EFFECT_BUFF,
		unitId = GetMobId( ENEMY_NAME ),
		buffName = BUFF_DEBUG_NAME
	}
	table.insert( effects, effect )

    ERROR_TEXT = "Casting " .. BUFF_NAME .. " to enemy mob is possible"
  	CastSpell( GetSpellId( BUFF_NAME ), nil, 4000, CustomErrorFunc, Done, effects )
end

function CustomErrorFunc()
	ErrorFunc( ERROR_TEXT )
end

function Done()
	DisintagrateMob( ENEMY_NAME )
	StartTimer( 2000, Success, TEST_NAME )
end

function ErrorFunc( text )
	DisintagrateMob( ENEMY_NAME )
	StartTimer( 2000, ErrorFunc2, text )
end

function ErrorFunc2( text )
	Warn( TEST_NAME, text )
end


----------------------------------- EVENTS -------------------------------------

function OnAvatarCreated( params )
	StartTest( TEST_NAME )

	local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
	SummonMob( ENEMY_NAME, MAP_RESOURCE, newPos, 0, LearnSpells, ErrorFunc )
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
	BUFF_NAME = developerAddon.GetParam( "BuffName" )
	BUFF_DEBUG_NAME = developerAddon.GetParam( "BuffDebugName" )

	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()