-- Отказыавется от задания

Global( "DISCARDQUEST_QUEST_ID", nil )
Global( "DISCARDQUEST_QUEST_NAME", nil )
Global( "DISCARDQUEST_FUNC_PASS", nil )
Global( "DISCARDQUEST_FUNC_ERROR", nil )

function DiscardQuest( questName, funcPass, funcError )
	DISCARDQUEST_FUNC_PASS = funcPass
	DISCARDQUEST_FUNC_ERROR = funcError
	DISCARDQUEST_QUEST_NAME = questName

	DISCARDQUEST_QUEST_ID = GetQuestId( questName )
	Log( "trying to discard quest" )
	if DISCARDQUEST_QUEST_ID == nil then
		funcError( "can not discard quest: there is not quest in quest book" )
		
	else
		StartPrivateCheckTimer( 10000, CheckDiscardedQuest, nil, DISCARDQUEST_FUNC_ERROR, "Cant discard quest", DISCARDQUEST_FUNC_PASS, nil )
	    avatar.DiscardQuest( DISCARDQUEST_QUEST_ID )
	end
end

function CheckDiscardedQuest()
	return GetQuestId( DISCARDQUEST_QUEST_NAME ) == nil
end