Global("INIT_ADDON","")

function OnAvatarCreated( params )
	common.LogInfo("debug","send to managerAddon "..INIT_ADDON)
	common.SendEvent("EVENT_ENABLE_UI_ADDON",{addon = INIT_ADDON})
end

function Init()
	INIT_ADDON = developerAddon.GetParam( "addon" )
	local login = {login = developerAddon.GetParam( "login" ),pass = developerAddon.GetParam( "password" ), avatar = developerAddon.GetParam( "avatar" )}
	InitLoging(login)
  	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

--
-- main initialization
--

Init()
