-- Сдает мобу unitId квест. Если квест в течении 10 сек. не исчезает из квест-бука - делаем ошибку

Global( "RETURNQUEST_FUNC_PASS", nil )
Global( "RETURNQUEST_FUNC_ERROR", nil )
Global( "RETURNQUEST_QUEST_NAME", nil )

function ReturnQuest( unitId, questName, funcPass, funcError )
	RETURNQUEST_FUNC_PASS = funcPass
	RETURNQUEST_FUNC_ERROR = funcError
	RETURNQUEST_QUEST_NAME = questName
	
	Log( "Returning quest : " .. questName, "Units.ReturnQuest" )
	if GetQuestId( RETURNQUEST_QUEST_NAME ) == nil then
		RETURNQUEST_FUNC_ERROR( "Avatar does not have a req quest: " .. RETURNQUEST_QUEST_NAME )
	else
		Log( "Start talk with " .. tostring( unitId ))
		StartTalk( unitId, ReturnQuestReturn, RETURNQUEST_FUNC_ERROR )
	end	
end

function ReturnQuestReturn()
	avatar.ReturnQuest( GetQuestId( RETURNQUEST_QUEST_NAME ), nil )
	StartPrivateCheckTimer( 10000, ReturnQuestCheckQuest, nil, RETURNQUEST_FUNC_ERROR, "Cant return quest", RETURNQUEST_FUNC_PASS, nil )
end
function ReturnQuestCheckQuest()
	return GetQuestId( RETURNQUEST_QUEST_NAME ) == nil
end
