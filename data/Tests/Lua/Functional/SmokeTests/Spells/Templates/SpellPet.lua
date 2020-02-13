--Призывает миньона и изгоняет его.
Global( "TEST_NAME", "SmokeTest.Template.SpellPet; author: Grigoriev Anton, date: 25.08.08, task # 41236" )

-- params
Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )
-- /params
            
--spells
Global( "TEST_SPELL_SUMMON", nil)   --Призвать миньона
Global( "TEST_SPELL_DISMISS", nil)  --Изгнать миньона
--/spells

Global( "LEVEL", nil)

--Призывает миньона
function RunSummonPet()
	local summonId = GetSpellId(TEST_SPELL_SUMMON)
	CastSpell(summonId, nil, 10000, WachTime, ErrorFunc)
end

function WachTime()
	StartTimer(5000, RunDismissPet)
end

--Изгоняет миньона
function RunDismissPet()
	local dismissId = GetSpellId(TEST_SPELL_DISMISS)
	CastSpell(dismissId, nil, 10000, Done, ErrorFunc)	
end

function Done()
	Success( TEST_SPELL_SUMMON .. " " .. TEST_SPELL_DISMISS .. " " .. TEST_NAME )
end

function ErrorFunc( text )
	Warn( TEST_SPELL_SUMMON .. " " .. TEST_SPELL_DISMISS .. " " .. TEST_NAME, text )
end


--------------------------------------- EVENTS ------------------------------------

--Запускается по событию EVENT_AVATAR_CREATED
function OnAvatarCreated()
	StartTest( TEST_NAME )
   
	local spells = {}
	table.insert( spells, TEST_SPELL_SUMMON )
	table.insert( spells, TEST_SPELL_DISMISS )
	LevelUp( LEVEL, spells, RunSummonPet, ErrorFunc)	
end

--Инициализация Аватара
function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging(login)

    local level = developerAddon.GetParam ( "Level" )
    if level ~= "" then
    	LEVEL = tonumber(level)
    end

    TEST_SPELL_DISMISS = developerAddon.GetParam( "DismissPet" )
	TEST_SPELL_SUMMON = developerAddon.GetParam( "SummonPet" )
	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()