Global( "TEST_NAME", "SmokeTest.Quest.TrackerNotChanged; author: Liventsev Andrey, date: 21.08.08, bug 32218" )

Global( "NPC_NAME", "Tests/Maps/Test/Instances/QuestGiver_Kill_N_Targets.(MobWorld).xdb" )
Global( "MOB_NAME", "Tests/Maps/Test/Instances/FarmTarget.(MobWorld).xdb" )
Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )
Global( "QUEST_NAME", "Tests/FunctionalTests/Lua/Quests/Kill_N_Targets/Kill_N_Targets.xdb" )

Global( "ADDON_PREFIX", "Tracker" )
Global( "ERROR_TEXT",   "TrackerError" )
Global( "DONE_TEXT",    "TrackerDone" )

Global( "CHILD_NAME", "KillMobs1" )

function BeforeAccept( unitId )
	StartTimer( 2000, Accept, unitId )
end

function Accept( unitId )
	AcceptQuest( unitId, QUEST_NAME, KillOneMob, ErrorFunc )
end

function KillOneMob()
	Log()
	Log( "quest accepted, try increase tracker" )
	SummonAndKillMob( MOB_NAME, MAP_RESOURCE, BeforeSendMessageToChild, ErrorFunc )
end

function BeforeSendMessageToChild()
	StartTimer( 1000, SendMessageToChild )
end

function SendMessageToChild()
	local progress = avatar.GetQuestProgress( GetQuestId( QUEST_NAME ) )
	local obj = progress.objectives[0]
	Log()
	Log( "tracker values. progress=" .. tostring( obj.progress ) .. " required=" .. tostring( obj.required ))
	if obj.progress ~= 1 then
		Log( "invalid value of tracker - error" )
		ErrorFunc( "Parent tracker - invalid value (not 1): " .. tostring( obj.progress ))
	else
		Log( "valid value of tracker. ask child for check his tracker" )
		StartTimer( 10000, ErrorFunc, "EVENT EVENT_ON_CHAT_MESSAGE (for child) did not come" )
		group.ChatWhisper( debugCommon.ToWString( CHILD_NAME ), debugCommon.ToWString( ADDON_PREFIX .. " check your tracker" ) )
	end
end

function Done()
	group.ChatWhisper( debugCommon.ToWString( CHILD_NAME ), debugCommon.ToWString( ADDON_PREFIX .. " " .. DONE_TEXT ) )
	DisintagrateMob( NPC_NAME )
	Success( TEST_NAME )
end

function ErrorFunc( text )
	group.ChatWhisper( debugCommon.ToWString( CHILD_NAME ), debugCommon.ToWString( ADDON_PREFIX .. " " .. ERROR_TEXT ) )
	DisintagrateMob( NPC_NAME )
	Warn( TEST_NAME, text )
end


----------------------------- EVENTS -----------------------------------

function OnAvatarCreated()
	StartTest( TEST_NAME )
	
	StartTimer( 60000, ErrorFunc, "Can't run child addon" )
	developerAddon.RunChildGame( "Child.(DeveloperAddon).xdb", " -silentMode" )
end

-- если отправитель - child, проверяем текст - ошибка или готово?
function OnChatMessage( params )
	if params.chatType == CHAT_TYPE_WHISPER then
		if debugCommon.FromWString( params.sender ) ~= debugCommon.FromWString( unit.GetName( avatar.GetId() )) then
			local message = debugCommon.FromWString( params.msg )
			local a, b = string.find( message, ADDON_PREFIX )
			if a~= nil and b ~= nil then

				StopTimer()
				
				local text = string.sub( message, b )
				
				a, b = string.find( message, ERROR_TEXT )
				if a ~= nil and b ~= nil then
					Log()
					Log( "error from child: " .. message )	
					ErrorFunc( text )
					return
				end
				
				a, b = string.find( message, DONE_TEXT )
				if a ~= nil and b ~= nil then
					Log()
					Log( "done from child: " .. message )	
					Done()
					return
				end

				Log()
				Log( "message from child. Accepting quest..."  )				
				local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
				SummonMob( NPC_NAME, MAP_RESOURCE, newPos, 0, BeforeAccept, ErrorFunc )
			end
		end	
	end	
end

function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" ),
		create = "AutoMage"
	}
	InitLoging( login )
	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	common.RegisterEventHandler( OnChatMessage, "EVENT_CHAT_MESSAGE" )
end

Init()