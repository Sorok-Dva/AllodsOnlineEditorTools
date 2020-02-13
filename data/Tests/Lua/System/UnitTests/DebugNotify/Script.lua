Global( "TEST_NAME", "UnitTest.DebugNotify" )

function OnAvatarCreated( params )
	StartTest( TEST_NAME )
	qaMission.DebugNotify( "blah-blah-blah...", false )
end

function OnDebugNotify( params )
 	Success( TEST_NAME )
end

function Init()          
    local login = {
        login = developerAddon.GetParam( "login" ),
        pass = developerAddon.GetParam( "password" ),
        avatar = developerAddon.GetParam( "avatar" )
    }
    InitLoging( login )
	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )  	
	common.RegisterEventHandler( OnDebugNotify, "EVENT_DEBUG_NOTIFY" )
end

Init()


