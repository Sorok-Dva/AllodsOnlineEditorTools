Global( "TEST_NAME", "LoginToSameShardWithSameLoginName_1_Parent; author: Liventsev Andrey, date: 14.01.09, bug 53508" )

-- главный коннектится нашард и запускает чилда. тот коннектится на ЭТОТ ЖЕ шард, проверка на то, что первого выкинет из игры
-- из-за невозможности общаться между аддонами пользоваться только в паре с LoginLotsAvatar_32

function ErrorFunc( text )
	Warn( TEST_NAME, text )
end

----------------------------- EVENTS -----------------------------------

function OnAvatarCreated()
	developerAddon.RunChildGame( "Child.(DeveloperAddon).xdb" , "  -silentMode" )
	StartCheckTimer( 60000, CheckStateMainMenu, nil, ErrorFunc, "Avatar not in MainMenu state for 60 sec", Success, TEST_NAME )
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