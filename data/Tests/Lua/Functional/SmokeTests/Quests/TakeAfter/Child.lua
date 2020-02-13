Global( "TEST_NAME", "SmokeTest.Quest.TakeQuestAfterSomebody.Child; author: Liventsev Andrey, date: 15.07.08, bug 32216" )

Global( "NPC_NAME", "Tests/Maps/Test/Instances/QuestGiver_TalkWithMe.(MobWorld).xdb" )
Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )
Global( "QUEST_NAME", "Tests/FunctionalTests/Lua/Quests/TalkWithMe/TalkWithMe.xdb" )

Global( "ADDON_PREFIX", "TakeAfter" )
Global( "ERROR_TEXT",   "TakeAfterError" )
Global( "DONE_TEXT",    "TakeAfterDone" )

Global( "PARENT_NAME", "TakeQuest" )


function BeforeAccept( unitId )
	StartTimer( 2000, Accept, unitId )
end

function Accept( unitId )
	AcceptQuest( unitId, QUEST_NAME, SendMessageToParent, ErrorFunc )
end

function SendMessageToParent()
	StartTimer( 10000, ErrorFunc, "EVENT_ON_CHAT_MESSAGE (for parent) did not come" )
	Log( "Whisper to parent" )
	group.ChatWhisper( debugCommon.ToWString( PARENT_NAME ), debugCommon.ToWString( ADDON_PREFIX .. " you should to accept quest" ) )
end

function Done()
	group.ChatWhisper( debugCommon.ToWString( PARENT_NAME ), debugCommon.ToWString( ADDON_PREFIX .. " " .. DONE_TEXT ) )
	DisintagrateMob( NPC_NAME )
	Success( TEST_NAME, true )
end

function ErrorFunc( text )
	group.ChatWhisper( debugCommon.ToWString( PARENT_NAME ), debugCommon.ToWString( ADDON_PREFIX .. " " .. ERROR_TEXT ) )
	DisintagrateMob( NPC_NAME )
	Warn( TEST_NAME, text, true )
end




-------------------------------------- EVENTS ---------------------------------

function OnAvatarCreated()
	StartTest( TEST_NAME )

	local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
	SummonMob( NPC_NAME, MAP_RESOURCE, newPos, 0, BeforeAccept, ErrorFunc )
end

-- если отправитель - parent, проверяем текст - ошибка или готово?
function OnChatMessage( params )
	if params.chatType == CHAT_TYPE_WHISPER then
		if debugCommon.FromWString( params.sender ) ~= debugCommon.FromWString( unit.GetName( avatar.GetId() )) then
	    	StopTimer()
			
			local message = debugCommon.FromWString( params.msg )
			local a, b = string.find( message, ADDON_PREFIX )
			if a~= nil and b ~= nil then
				local text = string.sub( message, b )
				
				a, b = string.find( message, ERROR_TEXT )
				if a ~= nil and b ~= nil then
					DisintagrateMob( NPC_NAME )
					Warn( TEST_NAME, text, true )				
					return
				end
				
				a, b = string.find( message, DONE_TEXT )
				if a ~= nil and b ~= nil then
					DisintagrateMob( NPC_NAME )
					Success( TEST_NAME, true )
					return
				end
			
				local progress = avatar.GetQuestProgress( GetQuestId( QUEST_NAME ) )
				local obj = progress.objectives[0]
				Log( "tracker values. progress=" .. tostring( obj.progress ) .. " required=" .. tostring( obj.required ))
				if obj.progress ~= 0 then
					ErrorFunc( "Child tracker - invalid value (not 0): " .. tostring( obj.progress )  )
				else
					Done()	
				end
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
	InitLoging(login)

	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	common.RegisterEventHandler( OnChatMessage, "EVENT_CHAT_MESSAGE" )
end

Init()