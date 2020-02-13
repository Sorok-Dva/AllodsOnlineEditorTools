Global("SET_STATE","SUCCESS")
Global("SET_AVATAR","SUCCESS")

function SendMsgHttp(text)
	LogToAccountFile(BOT_LISTENER_ADDRESS.."/msg?bot=".."Koordintor".."&msg="..text )
	qaCommon.HttpGET( BOT_LISTENER_ADDRESS.."/msg?bot=".."Koordintor".."&msg="..text )
end

function OnAvatarCreated()
	SendMsgHttp("SetState:"..tostring(SET_STATE))
	SET_STATE = "BOT:"..SET_STATE
	qaMission.DebugNotify( SET_STATE, false )
end

function OnDebugNotify(params)
	local sender = debugCommon.FromWString( params.sender )
	local message = debugCommon.FromWString( params.message )
	if sender == SET_AVATAR and message == SET_STATE then
		Success("State set "..SET_STATE)
	end
end

function Init()
	local botShards = {}
	if BOT_SHARD_NAME ~= nil then
		table.insert( botShards, BOT_SHARD_NAME )
	else
		botShards = SHARD_NAMES
	end
	SET_STATE = developerAddon.GetParam( "state" )
	SET_AVATAR = developerAddon.GetParam( "avatar" )
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = SET_AVATAR,
		create = "AutoWarrior",
		shards = botShards
	}
	InitLoging(login)
	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	common.RegisterEventHandler( OnDebugNotify, "EVENT_DEBUG_NOTIFY")
end


Init()
