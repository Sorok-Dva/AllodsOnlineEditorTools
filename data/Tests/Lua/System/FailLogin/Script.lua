Global("LOGGING", true)
Global("LOGIN", nil)
Global("PASS", nil)

function MainMenuLogin()
	debugCommon.SetErrorReturn( -1 )
	mainMenu.Login( LOGIN, LOGIN )
end

--------- EVENTS -------------------------------------------------------------

function OnLoginGameStateChanged( params )
	if OnCustomGameStateChanged then
       OnCustomGameStateChanged( params )
    end
	if LOGGING and params.registered and params.stateDebugName == "class Game::MainMenu" then
  		MainMenuLogin()
	end
	if LOGGING and params.registered and params.stateDebugName == "class Game::MainState" then
  		local shards = account.GetShardsInfo()
	end
end

function InitLoging(params)
    LOGIN = debugCommon.ToWString(developerAddon.GetParam( "login" ))
	PASS = debugCommon.ToWString(developerAddon.GetParam( "password"))
	if common.GetStateDebugName() == "class Game::MainMenu" then
		MainMenuLogin()
	end
	
    common.RegisterEventHandler( OnLoginGameStateChanged, "EVENT_GAME_STATE_CHANGED" )
end

InitLoging()


