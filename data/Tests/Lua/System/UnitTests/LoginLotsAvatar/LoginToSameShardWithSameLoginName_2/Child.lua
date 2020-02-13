Global( "TEST_NAME", "LoginToSameShardWithSameLoginName_2_Child; author: Liventsev Andrey, date: 14.01.09, bug 53508" )

function ErrorFunc( text )
	Warn( TEST_NAME, text, true )
end

function Done()
	Success( TEST_NAME, true )
end

----------------------------- EVENTS -----------------------------------

function OnAvatarCreated()
	StartCheckTimer( 90000, CheckStateMainMenu, nil, ErrorFunc, "Avatar not in MainMenu state for 60 sec", Done )
end
function CheckStateMainMenu()
	return common.GetStateDebugName() == "class Game::MainMenu"
end

function Init()
	local login = {
		login = developerAddon.GetParam( "login" ),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging( login )

	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()

