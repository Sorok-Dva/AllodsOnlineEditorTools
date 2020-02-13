
Global( "TEST_NAME", "UNIT TEST GetAvatarClasses" )
Global( "TIMER_ALIVE", true )
Global( "TIMER_NUM_ALIVE", 2000 )
Global( "TIMER_CONST", 2000 )
Global( "LOGIN", "unit" )
Global( "PASS", "" )
Global( "TIMER", false )
Global( "TIMER_NUM", 2000 )
Global( "LOGGING", true )
Global( "TEXT_CODE", "")

--
-- event handlers
--

-- EVENT_DEBUG_TIMER

function OnDebugTimer( params )
   if TIMER_ALIVE then
		if TIMER_NUM_ALIVE > 0 then
		   TIMER_NUM_ALIVE = TIMER_NUM_ALIVE - 1
		else
		   TIMER_ALIVE = false 		   
		   Error(TEST_NAME, "Shard is dead" )
		end
   end
   if TIMER then
      if TIMER_NUM > 0 then
         TIMER_NUM = TIMER_NUM - 1   
      else
         TIMER = false
         Error(TEST_NAME, "Cant login" )
	  end
   end	
end

-- EVENT_GAME_STATE_CHANGED

function OnGameStateChanged( params )
	common.LogInfo( "STATE "..params.stateDebugName.." "..tostring( params.registered ) )
	if params.stateDebugName == "class Game::MainState" then
		mainMenu.Login( debugCommon.ToWString( LOGIN ), debugCommon.ToWString( PASS ) )
		TIMER = true
		TIMER_NUM = TIMER_CONST
	end
end

-- EVENT_DEBUG_SHARD_IS_ALIVE

function OnDebugShardIsAlive( params )
   if params.shardAlive then
	  TIMER_NUM_ALIVE = TIMER_CONST
	  debugShard.RequestIsShardAlive()
   end
end

--- EVENT_SHARD_CHANGED
function OnShardChanged(params)
	if LOGGING then
		TIMER = false
		local isBusy = shard.IsBusy()
		if not isBusy then
			LOGGING = false
            local classes = shard.GetAvatarClasses()
			if classes ~= nil then
			   local id = classes[0].id ~= nil
			   local name = classes[0].name ~= nil
			   local class = classes[0].class ~= nil
			   if id and class and name then
			      Success( TEST_NAME )
                  developerAddon.FinishAddon()
			   else
				  if not id then
					 TEXT_CODE = TEXT_CODE.." class.id is empty "
				  end
				  if not name then
                     TEXT_CODE = TEXT_CODE.." class.name is empty "
				  end
				  if not class then
                     TEXT_CODE = TEXT_CODE.." class.class is empty "
				  end
				  common.LogInfo( TEST_NAME.." failed :"..TEXT_CODE )
				  developerAddon.FinishAddon()
			   end
			else
			   common.LogInfo( TEST_NAME.." failed :Table of avatar classes is empty" )
			   developerAddon.FinishAddon()
			end
		end
    end
end

--
-- main initialization function
--

function Init()          
   common.RegisterEventHandler( OnGameStateChanged, "EVENT_GAME_STATE_CHANGED" )
   common.RegisterEventHandler( OnDebugTimer, "EVENT_DEBUG_TIMER" )
   common.RegisterEventHandler( OnDebugShardIsAlive, "EVENT_DEBUG_SHARD_IS_ALIVE" )
   common.RegisterEventHandler( OnShardChanged, "EVENT_SHARD_CHANGED" )
end


--
-- main initialization
--

Init()


