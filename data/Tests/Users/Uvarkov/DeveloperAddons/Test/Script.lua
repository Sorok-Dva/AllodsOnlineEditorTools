function OnLoginGameStateChanged( params )
	common.LogInfo( "common", "OnLoginGameStateChanged" )

  if params.stateDebugName == "class Game::MainState" then
    local shards = account.GetShardsInfo()
  end
end

function Init()
	common.RegisterEventHandler( OnLoginGameStateChanged, "EVENT_GAME_STATE_CHANGED" )
end


Init()
