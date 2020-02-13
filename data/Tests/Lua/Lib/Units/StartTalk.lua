Global( "STARTTALK_PASS_FUNC", nil )
Global( "STARTTALK_PASS_TYPE", nil )
Global( "STARTTALK_ERROR_FUNC", nil )

-- Mob types
Global( "VENDOR",     0 )
Global( "TRAINER",    1 )
Global( "QUESTGIVER", 2 )
Global( "NOBODY",     3 )

-- начинает разговор с НПС, последний параметр необязателен (поумолчанию true)
function StartTalk( unitId, funcPass, funcError, checkingForTarget )
    STARTTALK_ERROR_FUNC = funcError
    STARTTALK_PASS_FUNC = funcPass
    StartTalkStart()
	if unitId ~= nil then
		if checkingForTarget == nil or checkingForTarget == true then
			local isVendor = object.IsVendor( unitId )
			local isTrainer = unit.IsTrainer( unitId )
			local hasQuest = object.HasQuest( unitId )
			if isVendor or isTrainer or hasQuest then
				StartTalkLog("Starting Interact...")
				StartPrivateTimer( 10000, STARTTALK_ERROR_FUNC, "EVENT_TALK_STARTED not coming" )
				avatar.StartInteract( unitId )

			else
				StartTalkStop()
				STARTTALK_ERROR_FUNC( "cant talk with not vendor, not trainer and not questGiver" )
			end
		else
			StartTalkLog( "Starting Interact..." )
			StartPrivateTimer( 10000, STARTTALK_ERROR_FUNC, "EVENT_TALK_STARTED not coming" )
			avatar.StartInteract( unitId )
		end		
	else
		StartTalkStop()
		STARTTALK_ERROR_FUNC( "cant talk with nil unitId" )
	end
end


function StartTalkLog( text )
	Log( text, "Units.StartTalk" )
end

function StartTalkStart()
	common.RegisterEventHandler( ST_OnTalkStarted, "EVENT_TALK_STARTED" )
	common.RegisterEventHandler( ST_OnInteractionStarted, "EVENT_INTERACTION_STARTED" )
end

function StartTalkStop()
	common.UnRegisterEventHandler( "EVENT_TALK_STARTED" )
	common.UnRegisterEventHandler( "EVENT_INTERACTION_STARTED" )
end



--------------------------------- EVENTS --------------------------------------------------

function ST_OnTalkStarted( params )
	StartTalkLog( "On talk started --> request interactions" )
    avatar.RequestInteractions()
	StartPrivateTimer( 10000, STARTTALK_ERROR_FUNC, "EVENT_INTERACTION_STARTED not coming" )
end

function ST_OnInteractionStarted( params )
	StartTalkLog( "interaction started" )
	StopPrivateTimer()
	StartTalkStop()

    if params.isVendor then
    	STARTTALK_PASS_FUNC( VENDOR )
    elseif params.isTrainer then
		STARTTALK_PASS_FUNC( TRAINER )
	elseif params.isQuestGiver then
		STARTTALK_PASS_FUNC( QUESTGIVER )
	else
		STARTTALK_PASS_FUNC( NOBODY )
	end
end
