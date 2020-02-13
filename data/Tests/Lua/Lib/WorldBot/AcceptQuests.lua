-- author: Liventsev Andrey, date: 01.04.2009, task#52335
-- Библиотека для имитации жизни - Принятие квестов

Global( "WBAQ_MOB_LIST", nil )
Global( "WBAQ_QUEST_LIST", nil )
Global( "WBAQ_NPC_NAME", nil )
Global( "WBAQ_COMPLETED_QUEST_LIST", nil )

Global( "WBAQ_MAP", nil ) -- список НПС для выполнения задания
Global( "WBAQ_QUEST_LEVEL", nil ) -- максимальный левел задания
Global( "WBAQ_CUR_QUEST_NAME", nil ) -- максимальный левел задания
Global( "WBAQ_NOT_ACCEPTED_QUESTS_LIST", nil ) -- количество принятых квестов

Global( "WBAQ_PASS_FUNC", nil )
Global( "WBAQ_ERROR_FUNC", nil )

Global( "WBAQ_INVISIBILITY_CHEAT_SPELL", "Mechanics/Spells/Cheats/GreaterInvisibility/Spell.xdb" )
Global( "WBAQ_INVISIBILITY_CHEAT_BUFF",  "Mechanics/Spells/Cheats/GreaterInvisibility/Buff.xdb" )

Global( "WBAQ_INT_STARTED_CAME", nil )
Global( "WBAQ_COUNT_MOVES", nil )

Global( "WBAQ_NPC_POS", nil )
Global( "WBAQ_NPC_MOVABLE", nil )


-- в passFunc передается список info невзятых квестов (когда не хватило lvl)
function AcceptQuests( mobList, questList, npcName, level, map, completedQuestList, passFunc, errorFunc )
	Log( "Accept quest from NPC=" .. npcName, "WorldBot.AcceptQuests" )
	
 	WBAQ_MOB_LIST = mobList
	WBAQ_QUEST_LIST = questList
	
	WBAQ_NPC_NAME = npcName
	WBAQ_QUEST_LEVEL = level
	WBAQ_MAP = map
	WBAQ_COMPLETED_QUEST_LIST = completedQuestList

	WBAQ_PASS_FUNC = passFunc
	WBAQ_ERROR_FUNC = errorFunc
	WBAQ_NOT_ACCEPTED_QUESTS_LIST = {}
	
	WBAQ_Start()
	
	if GetBuffInfo( avatar.GetId(), WBAQ_INVISIBILITY_CHEAT_BUFF ) == nil then
		LearnSpell( WBAQ_INVISIBILITY_CHEAT_SPELL, WBAQ_CastInvis, WBAQ_ERROR_FUNC )
	else
		WBAQ_MoveToNPCPlace()
	end	 
end

function WBAQ_CastInvis()
	CastSpellToTarget( avatar.GetId(), GetSpellId(WBAQ_INVISIBILITY_CHEAT_SPELL), nil, 2000, WBAQ_MoveToNPCPlace, WBAQ_ERROR_FUNC, nil, true )
end

function WBAQ_MoveToNPCPlace()
	WBAQ_COUNT_MOVES = 1
	local mobCoord = GetMobCoords( WBAQ_MOB_LIST, WBAQ_NPC_NAME )[1]
	WBAQ_NPC_POS = mobCoord
	WBAQ_NPC_MOVABLE = false

	WBAQ_Log( "Move to giver place. npcName=" .. WBAQ_NPC_NAME .. " pos=" .. PrintCoord( WBAQ_NPC_POS ))
	
	MoveToMob( WBAQ_NPC_POS, WBAQ_NPC_NAME, WBAQ_TryTalkWithNPC, nil, WBAQ_MobNotFound, "Can't find NPC in place. NPC: " .. WBAQ_NPC_NAME .. "  place: " .. PrintCoord(WBAQ_NPC_POS), WBAQ_MAP )
end
-- если не можем найти НПС - берем квест читом, запоминаем варнинг
function WBAQ_MobNotFound( text )
	local quests = GetQuestsByGiver( WBAQ_QUEST_LIST, WBAQ_NPC_NAME, nil, WBAQ_COMPLETED_QUEST_LIST ) 
	Log( " -----------------------------------a-sd- aflja s;dlfi has;ldhfi ;asldhf aksuhd flkasuh dlkfh aslkdfh ulsakuh dflask" )
	Log( " -----------------------------------a-sd- aflja s;dlfi has;ldhfi ;asldhf aksuhd flkasuh dlkfh aslkdfh ulsakuh dflask" )
	Log( " -----------------------------------a-sd- aflja s;dlfi has;ldhfi ;asldhf aksuhd flkasuh dlkfh aslkdfh ulsakuh dflask" )
	Log( " -----------------------------------a-sd- aflja s;dlfi has;ldhfi ;asldhf aksuhd flkasuh dlkfh aslkdfh ulsakuh dflask" )
	Log( "     mob not found: count quests: " .. tostring( GetTableSize(quests) ))
	Log( " -----------------------------------" .. tostring( quests[0] ) )
	Log( " -----------------------------------" .. tostring( quests[1] ) )
	Log( " -----------------------------------a-sd- aflja s;dlfi has;ldhfi ;asldhf aksuhd flkasuh dlkfh aslkdfh ulsakuh dflask" )
	Log( " -----------------------------------a-sd- aflja s;dlfi has;ldhfi ;asldhf aksuhd flkasuh dlkfh aslkdfh ulsakuh dflask" )
	local quest = quests[0]
	
	local params = {
		text = text,
		quest = quests[0]
	}
	WBAQ_Stop()
	WB_Warn( params )
	GiveQuestByCheat( questName, passFunc )
end


function WBAQ_TryTalkWithNPC()
	local unitId = GetMobId( WBAQ_NPC_NAME )
	
	if WBAQ_COUNT_MOVES > 10 then
		local quests = GetQuestsByGiver( WBAQ_QUEST_LIST, WBAQ_NPC_NAME, WBAQ_QUEST_LEVEL, WBAQ_COMPLETED_QUEST_LIST )
		Log( "Can't follow movable NPC. name=" .. WBAQ_NPC_NAME .. ", taking quest by cheat. Quest=" .. quests[0] )
		
		local params = {
			text = "Can't follow movable NPC. name=" .. WBAQ_NPC_NAME,
			quest = quests[0]
		}
		WBAQ_Stop()
		WB_Warn( params )
		GiveQuestByCheat( quests[0], passFunc )
		return
	end
	
	if GetDistanceFromPosition( avatar.GetId(), debugMission.InteractiveObjectGetPos( unitId )) <= 1 then
		SelectTarget( unitId, WBAQ_SetReputation, unitId )
		
	else
		StartPrivateTimer( 1000, WBAQ_MoveToNPC )
	end
end

function WBAQ_SetReputation( unitId )
	SetMaxReputationToTarget( WBAQ_TryStartTalk, unitId )
end

function WBAQ_TryStartTalk( unitId )
	WBAQ_Log( "NPC founded. starting talk..." )

	StartPrivateTimer( 3000, WBAQ_CheckNPCForMoving )
	StartTimer( 1000, avatar.StartInteract, unitId )
end

function WBAQ_CheckNPCForMoving()
	local mobId = GetMobId( WBAQ_NPC_NAME )
	-- если НПС ходит, то пытаемся его догнать
	if WBAQ_NPC_MOVABLE == true or GetDistanceFromPosition( mobId, WBAQ_NPC_POS ) >= 0.1 then
		WBAQ_NPC_MOVABLE = true
		WBAQ_Log( "NPC is movable. Try to follow him" )
		WBAQ_MoveToNPC()
	end
	
	WBAQ_Pass( false )
end

-- если после первого телепорта моб далеко, то телепортимся к нему - а вдруг он ходит?
function WBAQ_MoveToNPC()
	WBAQ_COUNT_MOVES = WBAQ_COUNT_MOVES + 1

	local mobId = GetMobId( WBAQ_NPC_NAME )
	WBAQ_NPC_POS = GetPositionAtDistance( debugMission.InteractiveObjectGetPos( mobId ), avatar.GetDir() - math.pi/2, 0.5 )
	MoveToMob( WBAQ_NPC_POS, WBAQ_NPC_NAME, WBAQ_TryTalkWithNPC, nil, WBAQ_ERROR_FUNC, nil, WBAQ_MAP )
end



function WBAQ_Start()
	common.RegisterEventHandler( WBAQ_OnTalkStarted,        "EVENT_TALK_STARTED"         )
	common.RegisterEventHandler( WBAQ_OnInteractionStarted, "EVENT_INTERACTION_STARTED"  )
	common.RegisterEventHandler( WBAQ_OnQuestReceived,      "EVENT_QUEST_RECEIVED"       )
end

function WBAQ_Stop()
	common.UnRegisterEventHandler( "EVENT_TALK_STARTED"         )
	common.UnRegisterEventHandler( "EVENT_INTERACTION_STARTED"  )
	common.UnRegisterEventHandler( "EVENT_QUEST_RECEIVED"       )
end

function WBAQ_Pass( isQuestAccepted )
--	RemoveBuff( WBAQ_INVISIBILITY_CHEAT_BUFF )
	WBAQ_Stop()
	StopPrivateTimer()
	if isQuestAccepted == true then
		WBAQ_Log( "Done. 1 quest accepted, " .. tostring(GetTableSize(WBAQ_NOT_ACCEPTED_QUESTS_LIST)) .. " quests not available" )
	else
		WBAQ_Log( "Done. No available quests, " .. tostring(GetTableSize(WBAQ_NOT_ACCEPTED_QUESTS_LIST)) .. " quests not available" )
	end	
	WBAQ_PASS_FUNC( WBAQ_NOT_ACCEPTED_QUESTS_LIST )	
end

function WBAQ_Log( text )
	Log( "  " .. tostring( text ), "WorldBot.AcceptQuests" )
end


-------------------------------- events 

function WBAQ_OnTalkStarted( params )
	StartPrivateTimer( 10000, WBAQ_Pass, false )
	WBAQ_INT_STARTED_CAME = false
    avatar.RequestInteractions()
end

function WBAQ_OnInteractionStarted( params )
	if WBAQ_INT_STARTED_CAME == false then
		WBAQ_INT_STARTED_CAME = true
		StopPrivateTimer()
		
		if params.isQuestGiver == true then
			local quests = avatar.GetAvailableQuests()
			if GetTableSize( quests ) > 0 then
				for index, questId in quests do
					local info = avatar.GetQuestInfo( questId )
					if info.level <= WBAQ_QUEST_LEVEL then
						if IsTableContents( WBAQ_COMPLETED_QUEST_LIST, info.debugName ) == false then
							WBAQ_CUR_QUEST_NAME = info.debugName
							WBAQ_Log( "accepting quest " .. WBAQ_CUR_QUEST_NAME )

							avatar.AcceptQuest( questId )
							StartPrivateCheckTimer( 5000, WBAQ_TryAcceptQuest, nil, WBAQ_ERROR_FUNC, "Can't accept quest (unknown reason)", WBAQ_Pass, true )
							return
						else
							WBAQ_Log( "quest is in completed list" )
						end	
					else
						table.insert( WBAQ_NOT_ACCEPTED_QUESTS_LIST, info )
						WBAQ_Log( "  too low level (" .. tostring( WBAQ_QUEST_LEVEL ) .. "). need " .. tostring( info.level ))
					end
				end
			end
		end

		WBAQ_Pass( false )
	end	
end

function WBAQ_TryAcceptQuest( )
	return GetQuestId( WBAQ_CUR_QUEST_NAME ) ~= nil
end

function WBAQ_OnQuestReceived( params )
    local info = avatar.GetQuestInfo( params.questId )
	if info.debugName == WBAQ_CUR_QUEST_NAME then
		avatar.StopInteract()
		WBAQ_Log( "Quest received" )
	end
end
