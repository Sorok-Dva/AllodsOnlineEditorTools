Global( "TEST_NAME", "SmokeTest.CreateAvatar; author: Liventsev Andrey, date: 30.09.08, task 37334" )

Global( "LOGIN", nil )
Global( "PASS", nil )
Global( "AVATAR", nil )

Global( "FACTION", nil )
Global( "RACE", nil )
Global( "SEX", nil )
Global( "CLASS", nil )

Global( "CREATING", false )
Global( "CREATED", false )


function Done()
	Success( TEST_NAME )
end

function ErrorFunc( text )
	Warn( TEST_NAME, text )
end

function CreateAvatar()
	local template = {
	    faction = FACTION,
	    race = RACE,
	    class = CLASS,
	    sex = SEX
	}

	local variation = {
	    skin = 0,
	    face = 0,
	    hairType = 0,
	    hairColor = 0,
		facialType = 0,
		facialVariant = 0
	}
    
    CREATED = true
    common.LogInfo( "common", "creating avatar" )
    PreMissionCreateAvatar( AVATAR, template, variation )
    StartTimer( 15000, ErrorFunc, "Avatar did not created" )
end

function DeleteAvatar()
	shard.DeleteAvatar( debugCommon.ToWString( AVATAR ))
	common.LogInfo( "common", "avatar not exist. creating" )
	StartTimer( 500, CreateAvatar )
end


--------------------------------------- EVENTS --------------------------------------------

function OnGameStateChanged( params )
	if common.GetStateDebugName() == "class Game::Mission" then
		StartTimer( 2000, Success, TEST_NAME )
	end
end

function OnShardChanged()
	if common.GetStateDebugName() == "class Game::PreMission" then
		if CREATING == false then
			InitPreMissionCreateAvatar()
	        CREATING = true
	        
	        local flag = false
	        local avatars = shard.GetAvatars()
			for index, name in avatars do
				common.LogInfo( "common", debugCommon.FromWString( name ) .. " == " .. AVATAR .. " is " .. tostring( debugCommon.FromWString( name ) == AVATAR ))
				if debugCommon.FromWString( name ) == AVATAR then
					flag = true
					common.LogInfo( "common", "avatar exist. deleting" )
					DeleteAvatar()
					break
				end
			end
			if not flag then 
				common.LogInfo( "common", "avatar not exist. creating" )
				CreateAvatar()
			end

	        
	    elseif CREATED == true then
			if not shard.IsBusy() then
				CREATED = false
				common.LogInfo( "common", "start play" )
				StartTimer( 10000, ErrorFunc, "Can't start game with new avatar" )
				shard.StartGame( debugCommon.ToWString( AVATAR ))
			end
		end
	end
end

function OnLoginEnd(params)
	if params.sysResult ~= LOGIN_END_LOGIN_SUCCESS then
    	ErrorFunc( "Cant Login: " .. tostring( params.sysResult ))
	end
end

function OnConnectionFailed( params )
	if params.sysResult ~= "ENUM_ECS_OK" then
		ErrorFunc( "Connection lost: " .. params.sysResult )
	end
end


function Init()
	LOGIN = developerAddon.GetParam( "login")
	PASS = developerAddon.GetParam( "password" )
	AVATAR = developerAddon.GetParam( "avatarName" )
	
	FACTION = tonumber( developerAddon.GetParam( "faction" ))
	RACE = tonumber( developerAddon.GetParam( "race" ))
	CLASS = tonumber( developerAddon.GetParam( "class" ))
	SEX = tonumber( developerAddon.GetParam( "sex" ))
	
	common.RegisterEventHandler( OnGameStateChanged, "EVENT_GAME_STATE_CHANGED" )
	common.RegisterEventHandler( OnShardChanged, "EVENT_SHARD_CHANGED" )
	common.RegisterEventHandler( OnLoginEnd, "EVENT_LOGIN_END")
	common.RegisterEventHandler( OnConnectionFailed, "EVENT_CONNECTION_FAILED")
	
	common.LogInfo( "common", "logining..." )
	mainMenu.Login( debugCommon.ToWString( LOGIN ), debugCommon.ToWString( PASS ) )
end

Init()
