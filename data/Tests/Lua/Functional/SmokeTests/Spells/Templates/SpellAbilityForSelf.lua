--Наложение заклинаний на себя.
Global( "TEST_NAME", "SpellForSelf" )

Global( "TEST_SPELL", nil )

Global( "LEVEL", nil )
Global( "TEST_SPELL_ID", nil )
Global( "SPELL_IS_ABILITY", false )

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
	CastPrepareSpells(nil, TakeTarget)
end

function TakeTarget()
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
	InitLoging(login)
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