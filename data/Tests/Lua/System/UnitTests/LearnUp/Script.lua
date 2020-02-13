-- Поднять до 10 уровня мага, поднять только уровень.
-- Проверить на наличие спеллов Invisibility, FileBall, Ice Tomb и Enlarge (их нет)
-- Вызвать серверную команду learn_up (именно через механизм серверной консоли)
-- Проверить в спелбуке наличие спелов Invisibility и FileBall (они есть), Ice Tomb и Enlarge (их нет)
-- Поднять уровень до 15
-- Проверить что с спелбуке присутствуют Ice Tomb и Enlarge (они есть)

Global( "TEST_NAME", "SmokeTest.Quest.LearnUp; author: Grigoriev Anton, date: 19.08.08, task #38233" )

--params
Global( "SPELL1", nil)
Global( "SPELL2", nil)
Global( "SPELL3", nil)
Global( "SPELL4", nil)
--/params

Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )

Global("CHECK", true)
Global("LEVEL_UPPER1", 10)
Global("LEVEL_UPPER2", 15)

function Done()
	Success( TEST_NAME )
end

function ErrorFunc( text )
	Warn( TEST_NAME, text )
end

function CheckForSpell( spellName, shouldBe )
	if shouldBe then
		if GetSpellId( spellName ) == nil then
			ErrorFunc( "Avatar has not spell " .. spellName )
		end
	elseif GetSpellId( spellName ) ~= nil then
		ErrorFunc( "Avatar already has spell " .. spellName )
	end
end

function CheckSpells1()
	if GetSpellId( SPELL1 ) == nil then
    	ErrorFunc("Avatar can not learn spell " .. tostring(SPELL1))
	end
    if GetSpellId( SPELL2 ) == nil then
    	ErrorFunc("Avatar can not learn spell " .. tostring(SPELL2))
		return
	end

	Log("   LearnUp Success!")
	Log("   Avatar get spells:")
	Log("     " .. SPELL1)
	Log("     " .. SPELL2)
	
	CheckForSpell( SPELL3, false )
	CheckForSpell( SPELL4, false )

	Log("")
    Log( "level_up 15:" )
	qaMission.SendCustomMsg("level_up " .. tostring( LEVEL_UPPER2 ))
	StartTimer( 5000, ErrorFunc, "EVENT_UNIT_LEVEL_CHANGED did not come" )
end

function CheckSpells2()
	if GetSpellId( SPELL3 ) == nil then
 	 	ErrorFunc("Avatar can not learn spell " .. tostring(SPELL3))
	end
    if GetSpellId( SPELL4 ) == nil then
 		ErrorFunc("Avatar can not learn spell " .. tostring(SPELL4))
	end
	
	Log("   LearnUp Success!")
	Log("   Avatar get spells:")
	Log("     " .. SPELL3)
	Log("     " .. SPELL4)
	Log("")
	
	Done()
end

--------------------------------------- EVENTS ------------------------------------

function OnAvatarCreated()
	StartTest( TEST_NAME )

	Log("")
    Log( "level_up 10:" )
	qaMission.SendCustomMsg("level_up " .. tostring( LEVEL_UPPER1 ))
	StartTimer( 5000, ErrorFunc, "EVENT_UNIT_LEVEL_CHANGED did not come" )
end

function OnUnitLevelChanged( params )
	if params.unitId == avatar.GetId() then
    	StopTimer()
    	CHECK = false
    	local level = unit.GetLevel( avatar.GetId() )
		if level == 10 then
			
			Log("   LevelUp Success! Level = " .. level)	
			
			CheckForSpell( SPELL1, false )
			CheckForSpell( SPELL2, false )
			CheckForSpell( SPELL3, false )
			CheckForSpell( SPELL4, false )
			
			Log("")
			Log( "learn_up 1:" )
			qaMission.SendCustomMsg("learn_up ")
			StartTimer( 2000, CheckSpells1 )
		end
		if level == 15 then
			
			Log("   LevelUp Success! Level = " .. level)
			
			CheckForSpell( SPELL3, false )
			CheckForSpell( SPELL4, false )
			
			Log("")
			Log( "learn_up 2:" )
			qaMission.SendCustomMsg( "learn_up" )
			StartTimer( 2000, CheckSpells2 )
		end
	end	
end

function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging(login)


    SPELL1 = developerAddon.GetParam( "spell1" )
    SPELL2 = developerAddon.GetParam( "spell2" )
    SPELL3 = developerAddon.GetParam( "spell3" )
    SPELL4 = developerAddon.GetParam( "spell4" )
    
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	common.RegisterEventHandler( OnUnitLevelChanged, "EVENT_UNIT_LEVEL_CHANGED" )
end

Init()