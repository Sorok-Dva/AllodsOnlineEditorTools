Global( "TEST_NAME", "Smoke test. Check for casting bad ability to friendly mob and avatar. author: Liventsev Andrey. date: 22.07.2008. task: 37318" )

-- param from xdb
Global( "FRIEND_NAME", nil )
Global( "SPELL_NAME",  nil )
Global( "DEBUFF_NAME",   nil )
Global( "DEBUFF_DEBUG_NAME",   nil )
-- /param from xdb

Global( "SPELL_INDEX", 0 )
Global( "ERROR_TEXT", nil )
Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )
Global( "CUR_TARGET", nil )

function LearnSpells()
	if SPELL_INDEX == 0 then
		SPELL_INDEX = 1
		LearnSpell( SPELL_NAME, LearnSpells, ErrorFunc)
		
	elseif SPELL_INDEX == 1 then
		SPELL_INDEX = 2
		LearnSpell( DEBUFF_NAME, LearnSpells, ErrorFunc)
		
	elseif SPELL_INDEX == 2 then
		CUR_TARGET = GetMobId( FRIEND_NAME )
		LevelUp( 20, nil, BeforeCastingBadSpell, ErrorFunc )
	end	
end

function BeforeCastingBadSpell()
	StartTimer( 1000, CastingBadSpell )
end

function CastingBadSpell()
	Log( "" )
	Log( "casting bad spell..." )
	
	local effects = {}
	table.insert( effects, {
		type = EFFECT_DAMAGE,
		damageSource = CHECKDMG_SOURCE_SPELL,
		targetId = CUR_TARGET,
		sourceId = avatar.GetId() }
	)

	local target = nil
	if CUR_TARGET == avatar.GetId() then
		target = "avatar"
	else
		target = "friendly mob"
	end
    ERROR_TEXT = "Casting " .. SPELL_NAME .. " to " .. target .. " is possible"
    
    qaMission.AvatarRevive()
	CastSpellToTarget( CUR_TARGET, GetSpellId( SPELL_NAME ), nil, 4000, ErrorFunc, BeforeCastingDebuffSpell, effects )
end

function BeforeCastingDebuffSpell()
	StartTimer( 1000, CastingDebuffSpell )
end

function CastingDebuffSpell()
	Log( "" )
	Log( "casting debuff spell" )
	
	local effects = {}
	local effect = {
		type = EFFECT_BUFF,
		unitId = CUR_TARGET,
		buffName = DEBUFF_DEBUG_NAME
	}
	table.insert( effects, effect )
	
	local target = nil
	if CUR_TARGET == avatar.GetId() then
		target = "avatar"
	else
		target = "friendly mob"
	end
    ERROR_TEXT = "Casting " .. DEBUFF_NAME .. " to " .. target .. " is possible"
	
    if CUR_TARGET ~= avatar.GetId() then
    	CUR_TARGET = avatar.GetId()
    	CastSpell( GetSpellId( DEBUFF_NAME ), nil, 2000, ErrorFunc, BeforeCastingBadSpell, effects )
    else
    	CastSpell( GetSpellId( DEBUFF_NAME ), nil, 2000, ErrorFunc, Done, effects )
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
	if ERROR_TEXT ~= nil then
		Warn( TEST_NAME, ERROR_TEXT )
	else 
		Warn( TEST_NAME, text )
	end	
end


----------------------------------- EVENTS -------------------------------------

function OnAvatarCreated( params )
	StartTest( TEST_NAME )

	local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
	SummonMob( FRIEND_NAME, MAP_RESOURCE, newPos, 0, LearnSpells, ErrorFunc )
end

function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" ),
		create = "AutoMage"
	}
	InitLoging(login)
	
	FRIEND_NAME = developerAddon.GetParam( "FriendName" )
	SPELL_NAME = developerAddon.GetParam( "SpellName" )
	DEBUFF_NAME = developerAddon.GetParam( "DeBuffSpell" )
	DEBUFF_DEBUG_NAME = developerAddon.GetParam( "DeBuffDebugName" )

	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()