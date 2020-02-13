--
-- Global vars
--


Global("LOGGING", true)
Global("LOGIN", nil)
Global("PASS", "")
Global("AVATAR", nil)
Global("STATE", 0 )
Global("GET_LIST", 1)
Global("LOGIN_AUTH", 2)

Global("LOGIN_LIST", "oxid")

--
--------- EVENTS -------------------------------------------------------------
--

-- EVENT_DEBUG_LIST_AVATARS

function ListAvatars(params)
--table of key, value
--key: number (int) - индекс [0..]
--value: WString - имя персонажа
--TODO polu4it LOGIN i AVATAR po sisteme
	ParamsToConsole(params,"EVENT_DEBUG_LIST_AVATARS" )
	local matching = nil
	local list = {}
	local avatarName = nil
	for key, value in params do
		avatarName = debugCommon.FromWString(value)
		matching = string.find (avatarName, "(Avatar)" )
		if matching~=nil then
			matching = string.find(avatarName, "[0-9]+")
			list[value] = string.sub(avatarName,matching)
		end
	end
	ParamsToConsole(list,"list")
	local index = 8
	local find = true
	while find do
	    find = false
		index = index + 1
		for key, value in list do
	    	if index == tonumber(value) then
				find = true
				break
	    	end
		end
	end

	AVATAR = debugCommon.ToWString("Avatar"..tostring(index))
	LOGIN = "Auth"..tostring(index)
	common.LogInfo("LOGIN: "..LOGIN)
	common.LogInfo("AVATAR: "..debugCommon.FromWString(AVATAR))
	LOGGING = true
	STATE = LOGIN_AUTH
	--TODO normal logout
	preMission.Logout()
end                             

--- EVENT_SHARD_CHANGED
function OnLoginShardChanged(params)
	ParamsToConsole(params, "EVENT_SHARD_CHANGED")
  local isBusy = shard.IsBusy()
  if isBusy then
	common.LogInfo("shard is busy")
	return
  end
	common.LogInfo("STATE "..tostring(STATE))	
  if LOGGING then
	if STATE == GET_LIST then
		LOGGING = false
		debugShard.ListAvatars()
		--local avatars = shard.GetAvatars()
		--ListAvatars(avatars)
	elseif STATE == LOGIN_AUTH then
		LOGGING = false
		shard.StartGame( AVATAR )
	end
  end
end

-- "EVENT_GAME_STATE_CHANGED"

function OnLoginGameStateChanged( params )
	ParamsToConsole(params, "EVENT_GAME_STATE_CHANGED")
	if LOGGING and params.registered and params.stateDebugName == "class Game::MainMenu" then
		mainMenu.Login( debugCommon.ToWString(LOGIN), debugCommon.ToWString(PASS) )
	end
end

--
-- main initialization function --------------------------------------------------------   
--

function InitLoginAdv()
	LOGIN = LOGIN_LIST
	STATE = GET_LIST
	common.RegisterEventHandler( ListAvatars, "EVENT_DEBUG_LIST_AVATARS")
	common.RegisterEventHandler( OnLoginShardChanged, "EVENT_SHARD_CHANGED")
    common.RegisterEventHandler( OnLoginGameStateChanged, "EVENT_GAME_STATE_CHANGED" )
end

--
-- main initialization
--


