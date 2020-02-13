Global( "TEST_NAME", "Noldor first TEST!!" )
Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )


Global( "CUR_MOB_ID", nil )

local m_nIterWrite = 0

function TimerFunc()
	common.LogInfo("common","TIMER_FUNC")				
	if m_nIterWrite < 10 then			
		ProcessTimer()		
		m_nIterWrite = m_nIterWrite + 1
		group.ChatSay( debugCommon.ToWString( "Hello World!!!" ) )
	else
		group.ChatSay( debugCommon.ToWString( "STOP" ) )
		Success( TEST_NAME )
	end 
end

function OnAvatarCreated()
	StartTest( TEST_NAME )	
	ProcessTimer()	
end


function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" ),
		create = "AutoMage"
	}
	InitLoging(login)

	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	
end


function ProcessTimer()
	StartTimer( 1000, TimerFunc, TEST_NAME )
end


Init()
