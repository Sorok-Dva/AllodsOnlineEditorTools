-- Берет у моба unitId квест. Если квест в течении 10 сек. не появляется в квест-буке - делаем ошибку
-- Метод AcceptPostCheckAddItem также проверяет, что указанный предмет добавился в инвентарь

Global( "ACCEPTQUEST_FUNC_PASS", nil )
Global( "ACCEPTQUEST_FUNC_ERROR", nil )
Global( "ACCEPTQUEST_QUEST_NAME", nil )
Global( "ACCEPTQUEST_ITEM_NAME", nil )

Global( "ACCEPTQUEST_ITEM_ADDED", false )
Global( "ACCEPTQUEST_QUEST_ACCEPTED", false )

function AcceptQuest( unitId, questName, funcPass, funcError )
	ACCEPTQUEST_ITEM_NAME = nil
	ACCEPTQUEST_ITEM_ADDED = false
	ACCEPTQUEST_FUNC_PASS = funcPass
	ACCEPTQUEST_FUNC_ERROR = funcError
	ACCEPTQUEST_QUEST_NAME = questName
	
	StartTalk( unitId, AcceptQuestTakeQuest, funcError )
end

function AcceptPostCheckAddItem( unitId, itemName, questName, funcPass, funcError )
	ACCEPTQUEST_QUEST_ACCEPTED = false
	ACCEPTQUEST_ITEM_NAME = itemName
	ACCEPTQUEST_FUNC_PASS = funcPass
	ACCEPTQUEST_FUNC_ERROR = funcError
	ACCEPTQUEST_QUEST_NAME = questName

	StartTalk( unitId, AcceptQuestTakeQuest, funcError )
	common.RegisterEventHandler( ACCEPTQUEST_OnInventortItemAdded, "EVENT_INVENTORY_ITEM_ADDED" )
	common.RegisterEventHandler( ACCEPTQUEST_OnInventortItemChanged, "EVENT_INVENTORY_ITEM_CHANGED" )
end

function AcceptQuestTakeQuest( mobType )
	Log( "Accept quest:" , "AcceptQuest")
	if mobType == QUESTGIVER then
		local questId = GetAvailableQuestId( ACCEPTQUEST_QUEST_NAME )
		if questId ~= nil then
			avatar.AcceptQuest( questId )
			StartPrivateCheckTimer( 10000, AcceptQuestCheckQuest, nil, ACCEPTQUEST_FUNC_ERROR, "Cant take quest", AcceptQuestPassFunc, nil )

		else
			ACCEPTQUEST_FUNC_ERROR( "summoned npc does not have required quest" )
		end
	else 
		ACCEPTQUEST_FUNC_ERROR( "summoned npc is not quest giver" )
	end
end

function AcceptQuestCheckQuest()
	if GetQuestId( ACCEPTQUEST_QUEST_NAME ) ~= nil then
		if ACCEPTQUEST_ITEM_NAME == nil then
			Log( "   quest accepted" , "AcceptQuest")
   			return true
		else
			if ACCEPTQUEST_ITEM_ADDED == true then
				common.UnRegisterEventHandler( "EVENT_INVENTORY_ITEM_ADDED" )
				common.UnRegisterEventHandler( "EVENT_INVENTORY_ITEM_CHANGED" )
				return true
			elseif ACCEPTQUEST_QUEST_ACCEPTED == false then
		    	ACCEPTQUEST_QUEST_ACCEPTED = true
		    	Log( "   quest accepted", "AcceptQuest" )
		    	StartPrivateCheckTimer( 10000, AcceptQuestCheckQuest, nil, ACCEPTQUEST_FUNC_ERROR, "Quest item did not added", AcceptQuestPassFunc, nil )
		    	return false
			end
		end
	else
	    return false
	end
end

function ACCEPTQUEST_CheckChangedSlot( slot )
	local itemId = avatar.GetInventoryItemId( slot )
	local itemInfo = avatar.GetItemInfo( itemId )
	if itemInfo.debugInstanceFileName == ACCEPTQUEST_ITEM_NAME then
	    Log( "   quest item added" , "AcceptQuest")
		ACCEPTQUEST_ITEM_ADDED = true
	end
end

function AcceptQuestPassFunc()
	avatar.StopInteract()
	ACCEPTQUEST_FUNC_PASS()
end

------------------------------------------ EVENTS --------------------------------------------


function ACCEPTQUEST_OnInventortItemAdded( params )
    ACCEPTQUEST_CheckChangedSlot( params.slot )
end

function ACCEPTQUEST_OnInventortItemChanged( params )
	ACCEPTQUEST_CheckChangedSlot( params.slot )
end