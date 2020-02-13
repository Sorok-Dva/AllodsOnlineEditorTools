qaMission.AvatarSetPos-- author: Liventsev Andrey, date: 19.09.2008
-- Билиотека для принятия/сдачи квестов

Global( "AR_STATUS", nil )
Global( "AR_STATUS_ACCEPTING_QUEST", 0 )
Global( "AR_STATUS_RETURNING_QUEST", 1 )

Global( "AR_REQ_QUESTS", nil )
Global( "AR_CUR_QUEST_INDEX", nil )


Global( "AR_NPC_NAME", nil )
Global( "AR_ITEM_NAME", nil )
Global( "AR_MOB_LIST", nil )
Global( "AR_QUEST_NAME", nil )
Global( "AR_PASS_FUNCTION", nil )
Global( "AR_ERROR_FUNCTION", nil )


function AcceptQuest( questList, questName, mobList, passFunc, errorFunc )
	Log( "" )
	Log( "" )
	Log( "" )
	Log( "accepting quest... name=" .. questName, "Quest.AcceptReturn" )
	
	AR_Start()

	AR_MOB_LIST = mobList
	AR_QUEST_NAME = questName
 	AR_STATUS = AR_STATUS_ACCEPTING_QUEST
 	AR_PASS_FUNCTION = passFunc
 	AR_ERROR_FUNCTION = errorFunc

	local name, giverType = GetQuestGiver( questList, questName )
	if name == nil then
		AR_ERROR_FUNCTION( "Can't find quest giver for quest " .. questName )
		
	elseif giverType == OBJ_TYPE_MOB_WORLD then
		AR_NPC_NAME = name
		local coord = GetMobCoords( AR_MOB_LIST, AR_NPC_NAME )[1]
		qaMission.AvatarSetPos( coord )
		StartPrivateTimer( 15000, AR_StartTalk )

	else 
		AR_ERROR_FUNCTION( "Unknown quest giver type (" .. giverType .. ") name=" .. name )
	end
end

function ReturnQuest( questList, questName, mobList, passFunc, errorFunc )
	Log( "" )
	Log( "" )
	Log( "" )
    Log( "returning quest... name=" .. questName, "Quest.AcceptReturn" )

	AR_Start()
	
	AR_MOB_LIST = mobList
	AR_QUEST_NAME = questName
 	AR_STATUS = AR_STATUS_RETURNING_QUEST
 	AR_PASS_FUNCTION = passFunc
 	AR_ERROR_FUNCTION = errorFunc

	local name, finisherType = GetQuestFinisher( questList, questName )
	if name == nil then
		AR_ERROR_FUNCTION( "Can't find quest giver for quest " .. questName )
		
	elseif finisherType == OBJ_TYPE_MOB_WORLD then
		AR_NPC_NAME = name
		local coord = GetMobCoords( AR_MOB_LIST, AR_NPC_NAME )[1]
		qaMission.AvatarSetPos( coord )
		StartPrivateTimer( 15000, AR_StartTalk )
		
	else 
		AR_ERROR_FUNCTION( "Unknown quest giver type (" .. finisherType .. ") name=" .. name )
	end
end

-- заглушка для тех квестов на которые нет библиотек
function CompleteQuest( questName, passFunc )
	AR_QUEST_NAME = questName
	AR_PASS_FUNCTION = passFunc
	TargetSelf( AR_CompleteQuest, ErrorFunc )
end

function CompleteAndFinishQuest( questName, passFunc )
	qaMission.AvatarTargetCompleteAndFinishQuest( questName )
	StartPrivateTimer( 1000, passFunc )
end

function AcceptQuestFromItem( questName, itemName, passFunc, errorFunc )
	Log( "" )
	Log( "accepting quest from item... name=" .. questName, "Quest.AcceptReturn" )

	AR_Start()
	
	AR_ITEM_NAME = itemName
	AR_QUEST_NAME = questName
 	AR_PASS_FUNCTION = passFunc
 	AR_ERROR_FUNCTION = errorFunc
	
	if GetItemSlot( AR_ITEM_NAME ) == nil then
		Log( "adding item...", "Quest.AcceptReturn" )
		AddItem( AR_ITEM_NAME, 1, AR_AcceptQuestFromItem, AR_ERROR_FUNCTION )
	else
		AR_AcceptQuestFromItem()
	end
end

function DoReqConditions( questName, questList, passFunc, errorFunc )
	AR_PASS_FUNCTION = passFunc
	AR_ERROR_FUNCTION = errorFunc
	
	local questInfo = GetQuestInfo( questList, questName )
	if questInfo == nil then
		errorFunc( "can't find quest in list. name=" .. questName )
	else
		AR_REQ_QUESTS = questInfo.line
		if AR_REQ_QUESTS == nil then
			AR_REQ_QUESTS = {}
		end
		Log( "DoReqConditions:  count req quests: " .. tostring(GetTableSize(AR_REQ_QUESTS)), "Quest.AcceptReturn" )		
		AR_CUR_QUEST_INDEX = 0
		LevelUp( questInfo.level, nil, DoImmuneAvatar, AR_ERROR_FUNCTION )
	end
end

function DoImmuneAvatar()
	ImmuneAvatar( DoNextQuest, AR_ERROR_FUNCTION )
end



function DoNextQuest()
	Log( "do next quest... " .. tostring(AR_CUR_QUEST_INDEX) .. "/" .. tostring(GetTableSize( AR_REQ_QUESTS )) )
	if AR_CUR_QUEST_INDEX >= GetTableSize( AR_REQ_QUESTS ) then
		Log( "all quests completed" )
		AR_PASS_FUNCTION()
	else
		local questName = ParseObjName( AR_REQ_QUESTS[AR_CUR_QUEST_INDEX], "QuestResource" )
		Log( "try to complete quest: " .. questName, "Quest.AcceptReturn" )
		TakeAndCompleteQuest( questName, DoNextQuest )
		AR_CUR_QUEST_INDEX = AR_CUR_QUEST_INDEX + 1
	end	
end

function TakeAndCompleteQuest( questName, passFunc )
	AR_QUEST_NAME = questName

	qaMission.AvatarTargetGiveQuest( questName )
	StartPrivateTimer(1000, AR_BeforeCompleteQuest, passFunc )
end

function AR_CompleteQuest()
	Log( "completing quest", "Quest.AcceptReturn" )
	qaMission.AvatarTargetCompleteQuest( AR_QUEST_NAME )
	AR_PASS_FUNCTION()
end

function AR_BeforeCompleteQuest( passFunc )
	Log( "   completing quest " .. AR_QUEST_NAME, "Quest.AcceptReturn" )
	CompleteAndFinishQuest( AR_QUEST_NAME, passFunc )
end

function AR_AcceptQuestFromItem()
	local slot = GetItemSlot( AR_ITEM_NAME )
	StartPrivateTimer( 5000, ErrorFunc, "Item doesn't contain required quest...  itemName=" .. AR_ITEM_NAME .. "  questName=" .. AR_QUEST_NAME )
	
	Log( "requesting item quests...", "Quest.AcceptReturn" )
	avatar.RequestItemQuests( slot )
end

function AR_StartTalk()
	local mobId = GetMobId( AR_NPC_NAME )
	if mobId == nil then
		AR_ERROR_FUNCTION( "Can not find npc. name=" .. AR_NPC_NAME )

	else
		StartPrivateTimer( 10000, AR_ERROR_FUNCTION, "EVENT_TALK_STARTED did not come for npc=" .. tostring( AR_NPC_NAME ))
		avatar.StartInteract( mobId )
	end
end

function AR_Start()
	common.RegisterEventHandler( AR_OnTalkStarted,        "EVENT_TALK_STARTED"         )
	common.RegisterEventHandler( AR_OnInteractionStarted, "EVENT_INTERACTION_STARTED"  )
	common.RegisterEventHandler( AR_OnQuestCompleted,     "EVENT_QUEST_COMPLETED"      )
	common.RegisterEventHandler( AR_OnQuestReceived,      "EVENT_QUEST_RECEIVED"       )
	common.RegisterEventHandler( AR_OnItemQuestsReceived, "EVENT_ITEM_QUESTS_RECEIVED" )
end

function AR_Stop()
	common.UnRegisterEventHandler( "EVENT_TALK_STARTED"         )
	common.UnRegisterEventHandler( "EVENT_INTERACTION_STARTED"  )
	common.UnRegisterEventHandler( "EVENT_QUEST_COMPLETED"      )
	common.UnRegisterEventHandler( "EVENT_QUEST_RECEIVED"       )
	common.UnRegisterEventHandler( "EVENT_ITEM_QUESTS_RECEIVED" )
end

------------------------------------ EVENTS ------------------------------------

function AR_OnTalkStarted( params )
	StartPrivateTimer( 10000, AR_ERROR_FUNCTION, "EVENT_INTERACTION_STARTED did not come for npc=" .. tostring( AR_NPC_NAME ))
    avatar.RequestInteractions()
end

function AR_OnInteractionStarted(params)
	if AR_STATUS == AR_STATUS_ACCEPTING_QUEST then
		AR_STATUS = nil
	    local questId = GetAvailableQuestId( AR_QUEST_NAME )
	    if questId ~= nil then
	    	StartPrivateTimer( 10000, AR_ERROR_FUNCTION, "EVENT_QUEST_RECEIVED did not come" )

            avatar.AcceptQuest( questId )
            avatar.StopInteract()
	    else
	    	AR_ERROR_FUNCTION( "NPC doesnt have a required quest. quest=" .. tostring( AR_QUEST_NAME ))
	    end

	elseif AR_STATUS == AR_STATUS_RETURNING_QUEST then
		AR_STATUS = nil
		StartPrivateTimer( 10000, AR_ERROR_FUNCTION, "EVENT_QUEST_COMPLETED did not come" )
		avatar.ReturnQuest( GetQuestId( AR_QUEST_NAME ), nil )
	end
end

function AR_OnQuestReceived( params )
    local info = avatar.GetQuestInfo( params.questId )
	if info.debugName == AR_QUEST_NAME then
		StopPrivateTimer()
		Log( "quest successfully received", "Quest.AcceptReturn" )
		AR_Stop()
		AR_PASS_FUNCTION()
	end
end

function AR_OnQuestCompleted( params )
 	local quest = avatar.GetQuestInfo( params.questId )
	if quest.debugName == AR_QUEST_NAME then
		StopPrivateTimer()
		Log( "quest successfully completed", "Quest.AcceptReturn" )
		AR_Stop()
		AR_PASS_FUNCTION()
	end
end

function AR_OnItemQuestsReceived( params )
	local quests = avatar.GetAvailableItemQuests( params.slot )
	for index, id in quests do
		if avatar.GetQuestInfo( id ).debugName == AR_QUEST_NAME then
			StartPrivateTimer( 5000, AR_ERROR_FUNCTION, "EVENT_QUEST_RECEIVED did not come" )
			avatar.AcceptQuest( id )
			break
		end
	end
end
