--
-- event handlers
--

function OnAvatarCreated( params )
	debugShard.DebugNotify("blah-blah-blah...", false)
end

function OnDebugNotify( params )
 	SendExitEvent()
end

--
-- main initialization function
--

function Init()          
	local login = {login = "test",pass = "", avatar = "test"}
	InitLoging(login) 
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )  	
	common.RegisterEventHandler( OnDebugNotify, "EVENT_DEBUG_NOTIFY" )
end


--
-- main initialization
--

Init()


