Global("LEVEL",0)
Global("D_Y",50)
Global("X_COORD",500)
--------------------------------------------------------------------------------
--------------------------------------------------%%% EVENT_AVATAR_CREATED %%%--
function OnAvatarCreated( params )
	if LEVEL >= 20 then
		LEVEL = LEVEL - 19
	end
    local pos = {X = X_COORD,Y = D_Y*LEVEL,Z=1}
	local stPos = ToStandartCoord(pos)
	debugMission.AvatarSetPos(stPos)
	StartTimer(2000,Savis,nil)

end

function Savis()
	--debugMission.SendCustomMsg("fsave")
	StartTimer(2000,Logout,false)
end


function OnChatMessage(params)
	if debugCommon.FromWString(params.msg) == "next" then
		Logout(false)
	end
end
--
-- main initialization function
--
function Init()
	local level = developerAddon.GetParam( "level" )
	if level ~= "" then
		LEVEL = tonumber(level)
	end
	local login1 = developerAddon.GetParam( "login" )
	X_COORD = 500
	if string.find(login1,"zooz") then
		X_COORD = 800
	end
	local login = {login = developerAddon.GetParam( "login" ),
	pass = developerAddon.GetParam( "password" ), 
	avatar = developerAddon.GetParam( "avatar" ),
	create = true}
	InitLoging(login)
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	common.RegisterEventHandler( OnChatMessage, "EVENT_CHAT_MESSAGE" )
end

--
-- main initialization
--

Init()