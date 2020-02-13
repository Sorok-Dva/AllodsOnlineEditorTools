Global( "TEST_NAME", "Smoke test.GoodToFriend. author: Liventsev Andrey. date: 30.06.2008. task: 37320" )

-- param from xdb
Global( "FRIEND_NAME", nil )
Global( "SPELL_NAME",  nil )
Global( "BUFF_NAME",   nil )
Global( "BUFF_DEBUG_NAME",   nil )
-- /param from xdb

Global( "DAMAGE_SPELL", "Mechanics/Spells/Cheats/Dmg70/spell.xdb" )

Global( "SPELL_INDEX", 0 )
Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )
Global( "CUR_TARGET", nil )

function LearnSpells()
	if SPELL_INDEX == 0 then
		SPELL_INDEX = 1
		LearnSpell( DAMAGE_SPELL, LearnSpells, ErrorFunc)
		
	elseif SPELL_INDEX == 1 then
		SPELL_INDEX = 2
		LearnSpell( SPELL_NAME, LearnSpells, ErrorFunc)
		
	elseif SPELL_INDEX == 2 then
		SPELL_INDEX = 3
		LearnSpell( BUFF_NAME, LearnSpells, ErrorFunc)
		
	elseif SPELL_INDEX == 3 then
		LevelUp( 20, nil, Summon1, ErrorFunc )
	end	
end

function Summon1()
	Log()
	Log( "avatarId=" .. tostring(avatar.GetId()))
	Log()
	
	local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
	SummonMob( FRIEND_NAME, MAP_RESOURCE, newPos, 0, SelectingTarget1, ErrorFunc )
end

function SelectingTarget1( mobId )
	CUR_TARGET = mobId
	SelectTarget( CUR_TARGET, BeforeCastDamage1, ErrorFunc )
end

function SelectAvatarInTarget()
	CUR_TARGET = avatar.GetId()
	SelectTarget( CUR_TARGET, BeforeCastDamage1, ErrorFunc )
end

function BeforeCastDamage1()
	qaMission.AvatarRevive()
	StartTimer( 2000, CastDamage1 )
end

function CastDamage1()
	Log( "" )
	Log( "cast damage 1" )
	
	local effects = {}
	table.insert( effects, {
		type = EFFECT_DAMAGE,
		damageSource = CHECKDMG_SOURCE_OTHER,
		targetId = CUR_TARGET,
		sourceId = avatar.GetId() }
	)

	Log( "target=" .. tostring( unit.GetTarget( avatar.GetId())))
	CastSpell( GetSpellId( DAMAGE_SPELL ), nil, 2000, BeforeCastHealing, ErrorFunc, effects, true )
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
		unitId = CUR_TARGET,
		healerId = avatar.GetId()
	}
	table.insert( effects, effect )

	Log( "target=" .. tostring( unit.GetTarget( avatar.GetId())))
	if CUR_TARGET ~= avatar.GetId() then
		CastSpell( GetSpellId( SPELL_NAME ), nil, 6000, BeforeCastDamage2, ErrorFunc, effects )
	else
		CastSpell( GetSpellId( SPELL_NAME ), nil, 6000, CastDamage2, ErrorFunc, effects )
	end	
end

function BeforeCastDamage2()
	DisintagrateMob( FRIEND_NAME )
	StartTimer( 2000, Summon2 )
end

function Summon2()
	local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
	SummonMob( FRIEND_NAME, MAP_RESOURCE, newPos, 0, SelectingTarget2, ErrorFunc )
end

function SelectingTarget2( mobId )
	CUR_TARGET = mobId
	SelectTarget( CUR_TARGET, CastDamage2, ErrorFunc )
end

function CastDamage2()
	Log( "" )
	Log( "cast damage 2" )
	qaMission.AvatarRevive()
	
	local effects = {}
	table.insert( effects, {
		type = EFFECT_DAMAGE,
		damageSource = CHECKDMG_SOURCE_OTHER,
		targetId = CUR_TARGET,
		sourceId = avatar.GetId() }
	)

	Log( "target=" .. tostring( unit.GetTarget( avatar.GetId())))
	CastSpell( GetSpellId( DAMAGE_SPELL ), nil, 2000, BeforeCastBuffSpell, ErrorFunc, effects, true )
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
		unitId = CUR_TARGET,
		buffName = BUFF_DEBUG_NAME
	}
	table.insert( effects, effect )

	Log( "target=" .. tostring( unit.GetTarget( avatar.GetId())))
    if CUR_TARGET ~= avatar.GetId() then
    	CastSpell( GetSpellId( BUFF_NAME ), nil, 2000, SelectAvatarInTarget, ErrorFunc, effects )
    else
    	CastSpell( GetSpellId( BUFF_NAME ), nil, 2000, Done, ErrorFunc, effects )
    end
end

function Done()
	DisintagrateMob( FRIEND_NAME )
	StartTimer( 2000, Success, TEST_NAME )
end

function ErrorFunc( text )
	DisintagrateMob( FRIEND_NAME )
	StartTimer( 2000, ErrorFunc2, text )
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
	cLog( "agoitjti" )
	
	FRIEND_NAME = developerAddon.GetParam( "FriendName" )
	SPELL_NAME = developerAddon.GetParam( "SpellName" )
	BUFF_NAME = developerAddon.GetParam( "BuffName" )
	BUFF_DEBUG_NAME = developerAddon.GetParam( "BuffDebugName" )
	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

cLog( "asdasd" )
Init()