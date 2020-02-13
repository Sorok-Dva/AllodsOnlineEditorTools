Global( "TEST_NAME", "SmokeTest.Quest.TakeQuestAfterSomebody; author: Liventsev Andrey, date: 15.07.08, bug 32216" )

Global( "NPC_NAME", "Tests/Maps/Test/Instances/QuestGiver_TalkWithMe.(MobWorld).xdb" )
Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )
Global( "QUEST_NAME", "Tests/FunctionalTests/Lua/Quests/TalkWithMe/TalkWithMe.xdb" )

Global( "ADDON_PREFIX", "TakeAfter" )
Global( "ERROR_TEXT",   "TakeAfterError" )
Global( "DONE_TEXT",    "TakeAfterDone" )

Global( "CHILD_NAME", "Take1" )


function BeforeAccept( unitId )
	StartTimer( 2000, Accept, unitId )
end

function Accept( unitId )
	Log( "parent - accept"  )
	AcceptQuest( unitId, QUEST_NAME, Done, ErrorFunc )
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
					Log( "parent - error"  )
					DisintagrateMob( NPC_NAME )
					Warn( TEST_NAME, text )				
					return
				end
				
				a, b = string.find( message, DONE_TEXT )
				if a ~= nil and b ~= nil then
					Log( "parent - done"  )
					DisintagrateMob( NPC_NAME )
					Success( TEST_NAME )
					return
				end
			
				Log( "parent - summon npc"  )
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
		class = "AutoMage"
	}
	InitLoging( login )
	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	common.RegisterEventHandler( OnChatMessage, "EVENT_CHAT_MESSAGE" )
end

Init()