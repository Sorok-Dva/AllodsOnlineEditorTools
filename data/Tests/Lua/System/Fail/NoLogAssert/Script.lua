Global( "TEST_NAME", "Fail test. author: Liventsev Andrey" )


function OnAvatarCreated( params )
    StartTest( TEST_NAME )

	qaMission.AvatarSetScriptControl( true ) 
end

function Init()
    local login = {
        login = developerAddon.GetParam( "login" ),
        pass = developerAddon.GetParam( "password" ),
        avatar = developerAddon.GetParam( "avatar" )
    }
    InitLoging( login )

    common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()