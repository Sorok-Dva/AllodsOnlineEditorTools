
Global( "TEST_NAME", "UNIT TEST Create Avatar by class" )
Global( "TIMER_ALIVE", true )
Global( "TIMER_NUM_ALIVE", 2000 )
Global( "TIMER_CONST", 3000 )
Global( "LOGIN", "unit" )
Global( "PASS", "" )
Global( "TIMER", false )
Global( "TIMER_NUM", 3000 )
Global( "LOGGING", true )
Global( "CLASS_NAME", "MZL1" )
Global( "AVATAR_NAME", "TestCreateAvatar" )
Global( "CODE_TEXT", nil )
Global( "TIMER_CREATE", false )
Global( "TIMER_NUM_CREATE", 500 )

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
         Error(TEST_NAME, CODE_TEXT )
	  end
   end	
   if TIMER_CREATE then
      if TIMER_NUM_CREATE > 0 then
         TIMER_NUM_CREATE = TIMER_NUM_CREATE - 1
      else
		 TIMER_CREATE = false
		 TIMER = false
		 local avatars = shard.GetAvatars()
         for key, value in avatars do
            if debugCommon.FromWString( value ) == AVATAR_NAME then
               shard.DeleteAvatar( debugCommon.ToWString( AVATAR_NAME ) )
               Success( TEST_NAME )
               developerAddon.FinishAddon()
            end
         end
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
		CODE_TEXT = "Cant login"
	end
end

-- EVENT_DEBUG_SHARD_IS_ALIVE

function OnDebugShardIsAlive( params )
   if params.shardAlive then
	  TIMER_NUM_ALIVE = TIMER_CONST
	  debugShard.RequestIsShardAlive()
   end
end

-- EVENT_SHARD_CHANGED
function OnShardChanged(params)
	if LOGGING then
		TIMER = false
		local isBusy = shard.IsBusy()
		if not isBusy then
			LOGGING = false
            shard.CreateAvatarByClassName( debugCommon.ToWString( AVATAR_NAME ), debugCommon.ToWString( CLASS_NAME ) )
            TIMER = true
            TIMER_NUM = TIMER_CONST
            CODE_TEXT = "Cant create avatar"
            TIMER_CREATE = true
		end
    end
end

-- EVENT_SHARD_CANT_CREATE_AVATAR

function OnShardCantCreateAvatar( params )
   if params.invalidName then
	  common.LogInfo( TEST_NAME.." failed :Cant create avatar: invalid name" )
	  developerAddon.FinishAddon()
   else
      common.LogInfo( TEST_NAME.." failed :Cant create avatar: server problem" )
	  developerAddon.FinishAddon()
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


