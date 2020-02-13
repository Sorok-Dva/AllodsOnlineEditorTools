Global( "TEST_NAME", "SmokeTest.Quest.DiscardQuest; author: Liventsev Andrey, date: 15.07.08, bug 32216" )

Global( "QUEST_NAME", "Tests/FunctionalTests/Lua/Quests/TalkWithMe/TalkWithMe.xdb" )


function Done()
	Success( TEST_NAME )
end

function ErrorFunc( text )
	Warn( TEST_NAME, text )
end


----------------------------- EVENTS -----------------------------------

function OnAvatarCreated()
	StartTest( TEST_NAME )
	DiscardQuest( QUEST_NAME, Done, ErrorFunc )
end


function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" ),
		class = "AutoMage"
	}
	InitLoging(login)

	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()