--Наложение заклинаний на себя.
Global( "TEST_NAME", "SpellForSelf" )

Global( "TEST_SPELL", nil )

Global( "LEVEL", nil )
Global( "TEST_SPELL_ID", nil )

function Done()
	Success( TEST_SPELL .. " " .. TEST_NAME )
end

function ErrorFunc( text )
	Warn( TEST_SPELL .. " " .. TEST_NAME, text )
end

function CheckForSelectSpell()
	LearnPrepareSpells(CastPrepare)
end

function CastPrepare()
	CastPrepareSpells(nil, SelectSelfToTarget)
end

function SelectSelfToTarget()
	TargetSelf( SpellCasting, ErrorFunc )
end

function SpellCasting()
	TEST_SPELL_ID = GetSpellId(TEST_SPELL)
	CastSpell( TEST_SPELL_ID, nil, 10000, WachTime, ErrorFunc)	
end

function WachTime()
	StartTimer(2000, Done)
end


---------------------------EVENTS----------------------------

function OnAvatarCreated( params )
	StartTest(TEST_NAME)
	local spells = {}
	table.insert(spells,TEST_SPELL)
	LevelUp( LEVEL, spells, CheckForSelectSpell, ErrorFunc)
end

function Init()
	local login = {
		login = developerAddon.GetParam( "login" ),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging(login)

    local level = developerAddon.GetParam( "Level" )
    if level ~= "" then
    	LEVEL = tonumber(level)
    end
    
	TEST_SPELL = developerAddon.GetParam( "Spell" )
	TEST_NAME = TEST_SPELL.." - "..developerAddon.GetParam( "avatar" )..". Template: "..TEST_NAME
	GetPrepareSpellsFromAddon()	
	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()