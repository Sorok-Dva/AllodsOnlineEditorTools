-- author: Liventsev Andrey, date: 01.04.2009, task#52335
-- Библиотека для имитации жизни - Сдача квестов

Global( "WBRQ_MOB_LIST", nil )
Global( "WBRQ_QUEST_LIST", nil )

Global( "WBRQ_COMPLETED_QUEST_NAMES", nil ) 
Global( "WBRQ_COMPLETED_QUEST_INDEX", nil ) 
Global( "WBRQ_CUR_QUEST_INFO", nil ) 

Global( "WBRQ_PASS_FUNC", nil )
Global( "WBRQ_ERROR_FUNC", nil )

Global( "WBRQ_INT_STARTED_CAME", nil )
Global( "WBRQ_COUNT_MOVES", nil )
Global( "WBRQ_NPC_MOVABLE", nil )
Global( "WBRQ_NPC_POS", nil )
Global( "WBRQ_NPC_NAME", nil )

function ReturnCompletedQuests( mobList, questList, passFunc, errorFunc )
	Log()
	Log( "Returning all completed quests...", "WorldBot.ReturnQuests" )
	
	WBRQ_MOB_LIST = mobList
	WBRQ_QUEST_LIST = questList
	
	WBRQ_PASS_FUNC = passFunc
	WBRQ_ERROR_FUNC = errorFunc
	
	WBRQ_Start()
	
	WBRQ_COMPLETED_QUEST_NAMES = GetCompletedQuests()
	WBRQ_COMPLETED_QUEST_INDEX = 1
	
	if GetTableSize( WBRQ_COMPLETED_QUEST_NAMES ) > 0 then
		WBRQ_MoveToNPCPlace()
	else
		WBRQ_Log( "No completed quests" )
		WBRQ_Pass()
	end
end

function ReturnCompletedQuest( mobList, questList, questName, passFunc, errorFunc )
	Log()
	Log( "Return quest: " .. questName, "WorldBot.ReturnQuests" )
	WBRQ_MOB_LIST = mobList
	WBRQ_QUEST_LIST = questList
	
	WBRQ_PASS_FUNC = passFunc
	WBRQ_ERROR_FUNC = errorFunc
	
	WBRQ_Start()
	
	WBRQ_COMPLETED_QUEST_NAMES = {}
	table.insert( WBRQ_COMPLETED_QUEST_NAMES, questName )
	WBRQ_COMPLETED_QUEST_INDEX = 1
	
	WBRQ_MoveToNPCPlace()
end

function WBRQ_IncreaseQuestIndex()
	WBRQ_COMPLETED_QUEST_INDEX = WBRQ_COMPLETED_QUEST_INDEX + 1
	
	if WBRQ_COMPLETED_QUEST_INDEX > GetTableSize( WBRQ_COMPLETED_QUEST_NAMES ) then -- прошли всех НПС
		WBRQ_Pass()

	else
		WBRQ_Log( "increase quest index. index=" .. tostring( WBRQ_COMPLETED_QUEST_INDEX ) )	
		WBRQ_MoveToNPCPlace()
	end
end

function WBRQ_MoveToNPCPlace()
	WBRQ_NPC_NAME = GetQuestFinisher( WBRQ_QUEST_LIST, WBRQ_COMPLETED_QUEST_NAMES[WBRQ_COMPLETED_QUEST_INDEX] )
	WBRQ_CUR_QUEST_INFO = avatar.GetQuestInfo( GetQuestId( WBRQ_COMPLETED_QUEST_NAMES[WBRQ_COMPLETED_QUEST_INDEX] ) )
	
	WBRQ_COUNT_MOVES = 1
	local mobCoord = GetMobCoords( WBRQ_MOB_LIST, WBRQ_NPC_NAME )[1]
	WBRQ_NPC_POS = mobCoord
	WBRQ_NPC_MOVABLE = false

	WBRQ_Log( "Move to finisher place. npcName=" .. WBRQ_NPC_NAME .. " pos=" .. PrintCoord( WBRQ_NPC_POS ))
	
	MoveToMob( WBRQ_NPC_POS, WBRQ_NPC_NAME, WBRQ_TryTalkWithNPC, nil, WBRQ_Error, nil )
end

function WBRQ_TryTalkWithNPC()
	local mobId = GetMobId( WBRQ_NPC_NAME )
	
	if WBRQ_COUNT_MOVES > 10 then
		WBRQ_Error( "Can't follow movable NPC" )
		return
	end
	
	if GetDistanceFromPosition( avatar.GetId(), debugMission.InteractiveObjectGetPos( mobId ) ) <= 1 then
		WBRQ_Log( "NPC founded. starting talk..." )
	
		StartPrivateTimer( 5000, WBRQ_CheckNPCForMoving )
		avatar.StartInteract( mobId )
	else
		StartPrivateTimer( 1000, WBRQ_MoveToNPC )
	end
end
	
function WBRQ_CheckNPCForMoving()
	local mobId = GetMobId( WBRQ_NPC_NAME )
	-- если НПС ходит, то пытаемся его догнать
	if WBRQ_NPC_MOVABLE == true or GetDistanceFromPosition( mobId, WBRQ_NPC_POS ) >= 0.1 then
		WBRQ_NPC_MOVABLE = true
		WBRQ_Log( "NPC is movable. Try to follow him" )
		WBRQ_MoveToNPC()
	end
	
	WBRQ_Error( "Can't return quest (unknown reason)" )
end

-- если после первого телепорта моб далеко, то телепортимся к нему - а вдруг он ходит?
function WBRQ_MoveToNPC()
	WBRQ_COUNT_MOVES = WBRQ_COUNT_MOVES + 1

	local mobId = GetMobId( WBRQ_NPC_NAME )
	WBRQ_NPC_POS = GetPositionAtDistance( debugMission.InteractiveObjectGetPos( mobId ), avatar.GetDir() - math.pi/2, 0.5 )
	MoveToMob( WBRQ_NPC_POS, WBRQ_NPC_NAME, WBRQ_TryTalkWithNPC, nil, WBRQ_Error, nil )
end


function WBRQ_Start()
	common.RegisterEventHandler( WBRQ_OnTalkStarted,        "EVENT_TALK_STARTED"         )
	common.RegisterEventHandler( WBRQ_OnInteractionStarted, "EVENT_INTERACTION_STARTED"  )
	common.RegisterEventHandler( WBRQ_OnQuestCompleted,     "EVENT_QUEST_COMPLETED"      )
end

function WBRQ_Stop()
	common.UnRegisterEventHandler( "EVENT_TALK_STARTED"         )
	common.UnRegisterEventHandler( "EVENT_INTERACTION_STARTED"  )
	common.UnRegisterEventHandler( "EVENT_QUEST_COMPLETED"      )
end

function WBRQ_Error( text )
	WBRQ_Stop()
	WBRQ_Log( "Done. Quest returned" )
	StartPrivateTimer( 1000, WBRQ_ERROR_FUNC, text )	
end

function WBRQ_Pass()
	WBRQ_Stop()
	StartPrivateTimer( 1000, WBRQ_PASS_FUNC, WBRQ_CUR_QUEST_INFO )
end

function WBRQ_Log( text )
	Log( "   " .. tostring( text ), "WorldBot.ReturnQuests" )
end

-------------------------------- events 

function WBRQ_OnTalkStarted( params )
	local finisher = GetQuestFinisher( WBRQ_QUEST_LIST, WBRQ_COMPLETED_QUEST_NAMES[WBRQ_COMPLETED_QUEST_INDEX] )
	StartPrivateTimer( 10000, WBRQ_Error, "EVENT_TALK_STARTED did not come for npc=" .. finisher )
	
	WBRQ_INT_STARTED_CAME = false
    avatar.RequestInteractions()
end

function WBRQ_OnInteractionStarted( params )
	if WBRQ_INT_STARTED_CAME == false then
		WBRQ_INT_STARTED_CAME = true
		StopPrivateTimer()
			
		StartPrivateTimer( 10000, WBRQ_Error, "EVENT_QUEST_COMPLETED did not come for quest=" .. WBRQ_CUR_QUEST_INFO.debugName )
		WBRQ_Log( "Return completed quest: " .. WBRQ_CUR_QUEST_INFO.debugName )
		avatar.ReturnQuest( WBRQ_CUR_QUEST_INFO.id, nil )
	end	
end

function WBRQ_OnQuestCompleted( params )
 	local quest = avatar.GetQuestInfo( params.questId )
	if quest.debugName == WBRQ_CUR_QUEST_INFO.debugName then
		StopPrivateTimer()
		WBRQ_Log( "quest completed" )
		WBRQ_IncreaseQuestIndex()
	end
end



