-- author: Liventsev Andrey, date: 01.04.2009, task#52335
-- Библиотека для имитации жизни. типо AI. Общие методы
-- 1. Бот не может причинить вред аватару или своим бездействием допустить, чтобы аватару был причинён вред
-- 2. Бот должен повиноваться всем lua-скриптам, кроме тех случаев, когда эти приказы противоречат Первому Закону
-- 3. Бот должен заботиться о своей безопасности, кроме тех случаев, когда эти приказы противоречат Первому и Второму Закону

Global( "WB_MOB_LIST", nil )
Global( "WB_QUEST_LIST", nil )

Global( "WB_PASS_FUNCTION", nil )
Global( "WB_ERROR_FUNCTION", nil )
Global( "WB_ZONE", nil )
Global( "WB_MAP", nil )

Global( "WB_WARNINGS", nil )
Global( "BOT_LOGIN_NAME", "LuaBot" )

Global( "WB_NPC_LIST", nil )
Global( "WB_NPC_INDEX", nil )
Global( "WB_CUR_ROUND_INDEX", nil )
Global( "WB_COUNT_QUESTS_FROM_CUR_NPC", nil )

Global( "WB_CUR_QUEST_ID", nil )
Global( "WB_CUR_QUEST_NAME", nil )
Global( "WB_NOT_ACCEPTED_QUESTS_LIST", nil ) -- квесты которые не подходят по уровню
Global( "WB_COMPLETED_QUEST_LIST", nil ) -- квесты которые выполнили
Global( "WB_WARN_QUEST_LIST", nil ) -- таблица типа [квест - таблица ошибок]
Global( "WB_COUNT_ACCEPTED_QUESTS", nil )
Global( "WB_IS_ONE_QUEST_ACCEPTED", nil )

function WorldBotLogin( faction, errorFunc )
	WB_ERROR_FUNCTION = errorFunc
	
	local botShards = {}
	if BOT_SHARD_NAME ~= nil then
		table.insert( botShards, BOT_SHARD_NAME )
	else
		botShards = SHARD_NAMES
	end
	
	local login
	if BOT_ACCOUNT_NAME ~= nil then
		local numb = 0
		if type( BOT_ACCOUNT_NAME ) == "string" then
			numb = string.find( BOT_ACCOUNT_NAME, "[0-9]+" )
			if numb == nil then
				return WB_ERROR_FUNCTION( "wrong BOT_ACCOUNT_NAME - " .. tostring( BOT_ACCOUNT_NAME ) )
			end
			numb = string.sub( BOT_ACCOUNT_NAME, numb )
			numb = tonumber( numb )
			if type( numb ) ~= "number" then
				WB_ERROR_FUNCTION( "wrong BOT_ACCOUNT_NAME - "..tostring( BOT_ACCOUNT_NAME ) )
				return
			end
		elseif type( BOT_ACCOUNT_NAME ) == "number" then
			numb = BOT_ACCOUNT_NAME
		else
			WB_ERROR_FUNCTION( "wrong BOT_ACCOUNT_NAME - "..tostring( BOT_ACCOUNT_NAME ) )
			return 
		end
		
		local template = "AutoMage"
		if faction == "Hadagan" then
			template = template .. faction
		end
		
		BOT_LOGIN_NAME = BOT_LOGIN_NAME .. tostring( numb )
		login = { login = "luabot"..tostring( numb ),
					pass = "luabot"..tostring( numb ),
					avatar = BOT_LOGIN_NAME,
					create = template,
					delete = "true",
					shards = botShards }
	else
		WB_ERROR_FUNCTION( "BOT_ACCOUNT_NAME is null" )
		return
	end
	
	SendHttpMsg( BOT_LOGIN_NAME, "ImComingIn!" )
	InitLoging( login )
end

function InitWorldBot( questList, mobList, zone, map, passFunc, errorFunc )
	WB_QUEST_LIST = questList
	WB_MOB_LIST = mobList
	WB_ZONE = zone
	WB_MAP = map
	WB_WARNINGS = {}
	
	WB_PASS_FUNCTION = passFunc
	WB_ERROR_FUNCTION = errorFunc
	
	WB_COMPLETED_QUEST_LIST = {}
	WB_NOT_ACCEPTED_QUESTS_LIST = {}
end

function RunWorldBot()
	WB_CUR_ROUND_INDEX = 0
	WB_BeforeAcceptQuests()
end

function WB_BeforeAcceptQuests()
	WB_IS_ONE_QUEST_ACCEPTED = false
	WB_NPC_INDEX = 1
	WB_COUNT_QUESTS_FROM_CUR_NPC = 0
	WB_CUR_ROUND_INDEX = WB_CUR_ROUND_INDEX + 1
	WB_COUNT_ACCEPTED_QUESTS = 0
	WB_NOT_ACCEPTED_QUESTS_LIST = {}
	WB_NPC_LIST = GetNpcList( WB_ZONE, WB_MOB_LIST, WB_QUEST_LIST, unit.GetLevel( avatar.GetId() ) )

	Log()
	Log()
	Log( " ============================= round " ..  tostring( WB_CUR_ROUND_INDEX ) .. " ================================= " )
	Log()
	Log()
	Log( " ================== next NPC" )
	Log()
	
	
	WB_AcceptFromNextNPC()
end

function WB_AcceptFromNextNPC()
	local countQuestsCompletedByGiver = GetTableSize( GetQuestsByGiver( WB_QUEST_LIST, WB_NPC_LIST[WB_NPC_INDEX], unit.GetLevel( avatar.GetId() ), WB_COMPLETED_QUEST_LIST ))
	if countQuestsCompletedByGiver > WB_COUNT_QUESTS_FROM_CUR_NPC then
		Log()
		Log( "==========" )
		Log( "inspect next npc for quests. "  .. tostring(WB_NPC_INDEX) .. "/" .. tostring(GetTableSize(WB_NPC_LIST)))
		AcceptQuests( WB_MOB_LIST, WB_QUEST_LIST, WB_NPC_LIST[WB_NPC_INDEX], unit.GetLevel( avatar.GetId() ), WB_MAP, WB_COMPLETED_QUEST_LIST, AfterAcceptQuests, WB_Error )
	else
		AfterAcceptQuests( {} )
	end
end

function AfterAcceptQuests( notAcceptedQuests )
	if GetTableSize( avatar.GetQuestBook()) > 0 then
		WB_COUNT_ACCEPTED_QUESTS = WB_COUNT_ACCEPTED_QUESTS + 1
		WB_CompleteQuest() 

	else
		for index, info in notAcceptedQuests do
			table.insert( WB_NOT_ACCEPTED_QUESTS_LIST, info.debugName )
		end
	
		WB_NPC_INDEX = WB_NPC_INDEX + 1
		WB_COUNT_QUESTS_FROM_CUR_NPC = 0
		if WB_NPC_INDEX > GetTableSize( WB_NPC_LIST ) then
			if WB_COUNT_ACCEPTED_QUESTS > 0 then
				WB_BeforeAcceptQuests()
			else
				WB_Pass()
			end
		else
			Log()
			Log( " ================== next NPC" )
	
			WB_AcceptFromNextNPC()
		end
	end
	-- if questAccepted == 0 then
		-- Log( "all quests completed" )
		-- WB_Pass()
	-- else
		-- Log()
		-- Log()
		-- Log( "Start compliting quests" )
		-- CompleteNextQuest() 
	-- end	
end



function WB_CompleteQuest() 
	if GetTableSize( avatar.GetQuestBook() ) == 0 then
		WB_AcceptFromNextNPC() 
		return
	end
	
	local questInfo = avatar.GetQuestInfo( avatar.GetQuestBook()[0] )
	local progress = avatar.GetQuestProgress( avatar.GetQuestBook()[0] )
	if progress.state == QUEST_READY_TO_RETURN then
		ReturnCompletedQuest( WB_MOB_LIST, WB_QUEST_LIST, questInfo.debugName, WB_AfterReturnCurQuest, WB_Error )

	elseif progress.state == QUEST_IN_PROGRESS then
		WB_CUR_QUEST_ID = avatar.GetQuestBook()[0]
		WB_CompleteNextCurQuestObjective()
	
	else
		-- todo
		WB_Error( "unknown quest state: " .. tostring( progress.state ))
	end
end

function WB_CompleteNextCurQuestObjective()
	local questProgress = avatar.GetQuestProgress( WB_CUR_QUEST_ID )

	for index, obj in questProgress.objectives do
		if obj.progress < obj.required then
			local questDebugName = avatar.GetQuestInfo( WB_CUR_QUEST_ID ).debugName
			Log()
			Log( "do next quest objective:" )
			Log( "  quest name: " .. FromWString( avatar.GetQuestInfo( WB_CUR_QUEST_ID ).name ))
			Log( "  debug name: " .. questDebugName )
			Log( "  objective name: " .. FromWString( obj.name ))
			Log( "  type: " .. tostring( obj.type ) .. " sysDebugName: " .. obj.sysDebugName )
			Log( "  progress: " .. tostring(obj.progress) .. "/" .. tostring(obj.required) )

				-- CompleteQuestByCheat( questDebugName, WB_CompleteQuest )
				-- return	

			if (obj.type == QUEST_COUNT_KILL or obj.type == QUEST_COUNT_ITEM ) and StringIsBlank( obj.sysDebugName ) == true then
				Log( "wrong quest info: " .. questDebugName )
				table.insert( WB_WARNINGS, "wrong quest info. questName=" .. FromWString( avatar.GetQuestInfo( questProgress.id ).name ) .. "  obj=" .. FromWString( obj.name ) )
				CompleteQuestByCheat( questDebugName, WB_CompleteQuest )
				return	
			end


			if obj.type == QUEST_COUNT_KILL then
				local targetInfo = GetQuestTargetInfoByName( WB_MOB_LIST, obj.sysDebugName )
				if targetInfo.isMob == true then
					KillMobs( WB_MOB_LIST, questDebugName, obj.sysDebugName, WB_CompleteQuest )
					return
				else
					UseDevs( WB_MOB_LIST, questDebugName, obj.sysDebugName, WB_CompleteQuest )
					return
				end
				
			elseif obj.type == QUEST_COUNT_ITEM then
				local targetInfo = GetQuestTargetInfoByItem( WB_MOB_LIST, obj.sysDebugName )
				if targetInfo.isMob == true then
					LootMobs( WB_MOB_LIST, questDebugName, obj.sysDebugName, WB_CompleteQuest )
					return
				else
					LootDevs( WB_MOB_LIST, questDebugName, obj.sysDebugName, WB_CompleteQuest )
					return
				end	

			elseif obj.type == QUEST_COUNT_SPECIAL then
				CompleteQuestByCheat( questDebugName, WB_CompleteQuest )
				return	
			end
		end
	end
	
	
end


function WB_ReturnCurQuest()
	ReturnQuestByCheat( avatar.GetQuestInfo( CUR_QUEST_ID ).debugName, WB_AfterReturnCurQuest )
end

function WB_AfterReturnCurQuest( questInfo )
	table.insert( WB_COMPLETED_QUEST_LIST, questInfo.debugName )	

	CheckBag( WB_MOB_LIST, WB_ZONE, WB_AcceptFromNextNPC, WB_Error )
end






function WB_Pass()
	Log()
	Log()
	Log()
	Log( " ------------------------------- RESULTS: -------------------------------" )
	Log()
	
	Log( "Completed and returned quests (" .. GetTableSize(WB_COMPLETED_QUEST_LIST) .. ") :" )
	for index, name in WB_COMPLETED_QUEST_LIST do
		local info = GetQuestInfoByName( name )
		Log( "  " .. info.debugName .. "   " .. FromWString( info.name ))
	end
	
	Log()
	Log( "Not accepted quests (" .. tostring(GetTableSize(WB_NOT_ACCEPTED_QUESTS_LIST)) ..  ") :" )
	for index, name in WB_NOT_ACCEPTED_QUESTS_LIST do
		local info = GetQuestInfoByName( name )
		Log( "  " .. info.debugName .. "   " .. FromWString( info.name ))
	end
	
	Log()
	if GetTableSize( WB_WARNINGS ) > 0 then
		Log()
		Log( "WARNINGS:" )
		for index, quest in WB_WARNINGS do
			Log( " quest=" .. tostring( quest ) .. " index=" .. tostring( index ) )
		end
	end		
	
	WB_PASS_FUNCTION()
end

function WB_Error( text )
	Log()
	Log()
	Log()
	Log( " ------------------------------- RESULTS: -------------------------------" )
	Log()
	
	Log( "Completed and returned quests (" .. GetTableSize(WB_COMPLETED_QUEST_LIST) .. ") :" )
	for index, name in WB_COMPLETED_QUEST_LIST do
		local info = GetQuestInfoByName( name )
		Log( "  " .. info.debugName .. "   " .. FromWString( info.name ))
	end
	
	Log()
	Log( "Not available quests - too low level (" .. tostring(GetTableSize(WB_NOT_ACCEPTED_QUESTS_LIST)) ..  ") :" )
	for index, name in WB_NOT_ACCEPTED_QUESTS_LIST do
		local info = GetQuestInfoByName( name )
		Log( "  " .. info.debugName .. "   " .. FromWString( info.name ))
	end
	
	Log()
	if GetTableSize( WB_WARNINGS ) > 0 then
		Log()
		Log( "WARNINGS:" )
		for quest, texts in WB_WARNINGS do
			Log( "  quest: " .. quest )
			for index, text in texts do
				Log( "    " .. text )
			end
		end
	end	
	
	Log()
	Log()
	WB_ERROR_FUNCTION( text )
end

-- Сюда поступают сообщения об некритичных ошибках
-- params: text - текст, quest - квест который выдал ошибку
function WB_Warn( params )
	Log( "Warn: " )
	Log( "    " .. tostring( params.text ) )
	Log( "    " .. tostring( params.quest ) )

	local questWarns = WB_WARNINGS[params.quest]
	if questWarns == nil then
		questWarns = {}
		WB_WARNINGS[params.quest] = {}
	end
	
	if not IsTableContents( questWarns, params.text ) then
		table.insert( questWarns, params.text )
		WB_WARNINGS[params.quest] = questWarns
	end
end


--------------------------


function GiveQuestByCheat( questName, passFunc )
	WB_CUR_QUEST_NAME = questName
	UnselectTargetAdv( CastGiveQuestCheat, passFunc, WB_Error )
end
function CastCompleteQuestCheat( passFunc )
	Log( "console command:  give_quest " .. WB_CUR_QUEST_NAME )
	qaMission.SendCustomMsg( "give_quest " .. WB_CUR_QUEST_NAME )
	StartPrivateCheckTimer( 5000, CheckGiveQuestByCheat, WB_CUR_QUEST_NAME, WB_Error, "Can't give quest by cheat using console comand", passFunc )
end
function CheckGiveQuestByCheat( debugName )
	return GetQuestId( debugName ) ~= nil
end

function CompleteQuestByCheat( questName, passFunc )
	WB_CUR_QUEST_ID = GetQuestId( questName )
	Log( "--- name=" .. tostring(questName) )
	Log( " --- id=" .. tostring(WB_CUR_QUEST_ID) )
	UnselectTargetAdv( CastCompleteQuestCheat, passFunc, WB_Error )
end
function CastCompleteQuestCheat( passFunc )
	local debugName = avatar.GetQuestInfo( WB_CUR_QUEST_ID ).debugName
	Log( "console command:  complete_quest " .. debugName )
	qaMission.SendCustomMsg( "complete_quest " .. debugName )
	StartPrivateCheckTimer( 5000, CheckCompleteQuestByCheat, debugName, WB_Error, "Can't complete quest by cheat using console comand", passFunc )
end
function CheckCompleteQuestByCheat( debugName )
	return avatar.GetQuestProgress( GetQuestId( debugName )).state == QUEST_READY_TO_RETURN
end


function ReturnQuestByCheat( questName, passFunc )
	WB_CUR_QUEST_ID = GetQuestId( questName )
	UnselectTargetAdv( CastReturnQuestCheat, passFunc, WB_Error )
end
function CastReturnQuestCheat( passFunc )
	local debugName = avatar.GetQuestInfo( WB_CUR_QUEST_ID ).debugName
	Log( "console command:  finish_quest " .. debugName )
	qaMission.SendCustomMsg( "finish_quest " .. debugName )
	
	StartPrivateCheckTimer( 5000, CheckReturnQuestByCheat, debugName, WB_Error, "Can't return quest by cheat using console comand", passFunc )
end
function CheckReturnQuestByCheat( debugName )
	return GetQuestId( debugName ) == nil
end

function AbandonQuestByCheat( questName, passFunc )
	WB_CUR_QUEST_ID = GetQuestId( questName )
	UnselectTargetAdv( CastAbandonQuestCheat, passFunc, WB_Error )
end
function CastAbandonQuestCheat( passFunc )
	local debugName = avatar.GetQuestInfo( WB_CUR_QUEST_ID ).debugName
	Log( "console command:  abandon_quest " .. debugName )
	qaMission.SendCustomMsg( "abandon_quest " .. debugName )
	
	StartPrivateCheckTimer( 5000, CheckAbandonQuestByCheat, debugName, WB_Error, "Can't abandon quest by cheat using console comand", passFunc )
end
function CheckAbandonQuestByCheat( debugName )
	return GetQuestId( debugName ) == nil
end

function SetMaxReputationToTarget( passFunc, passFuncParam  )
	local unitId = avatar.GetTarget()
	Log( "id=" .. tostring(  unitId) )
	Log( "faction name=" .. tostring(unit.GetFaction( unitId ).sysTutorialName) )
	local repInfo = avatar.GetReputationInfo( unit.GetFaction( unitId ).sysTutorialName )
	if repInfo and repInfo.repNextLevel ~= nil then
		-- Log( "give reputation to target. Value=" .. tostring( repInfo.repNextLevel ) )
		-- qaMission.AvatarSetReputationForTarget( repInfo.repNextLevel )
		Log( "console command:  set_target_rep " .. tostring( repInfo.repNextLevel ))		
		qaMission.SendCustomMsg( "set_target_rep " .. tostring( repInfo.repNextLevel ))
	end	

	StartTimer( 1000, passFunc, passFuncParam )
end


-- возвращает список НПС которые выдают квесты нашего уровня, которых нет в нашем квестбуке
function GetNpcList( zoneName, mobList, questList, level )
	local result = {}
	for i, mob in mobList do
		local mobZone = ParseObjName( mob.zone, OBJ_TYPE_ZONE )
		if mobZone ~= nil then
--			Log( "compare " .. mobZone.. " " .. zoneName )
			if mobZone ~= nil and mobZone == zoneName then
				local npcName = ParseObjName( mob.name, OBJ_TYPE_MOB_WORLD )
				if npcName ~= nil then
					for j, quest in GetQuestsByGiver( questList, npcName, level ) do
						if IsQuestAccepted( quest ) == false and IsQuestCompleted( quest ) == false then
							table.insert( result, npcName )
							break
						end
					end
				end	
			end	
		end	
	end
	
	Log( "find " .. tostring( GetTableSize( result )) .. " givers" )
	return result
end

function GetMobsByZone( zoneName, mobList )
	local result = {}
	for i, mob in mobList do
		local mobZone = ParseObjName( mob.zone, OBJ_TYPE_ZONE )
		if mobZone ~= nil and mobZone == zoneName then
			local npcName = ParseObjName( mob.name, OBJ_TYPE_MOB_WORLD )
			if npcName ~= nil then
				table.insert( result, npcName )
			end	
		end	
	end
	
	return result
end

function GetCompletedQuests()
	local result = {}
	for index, questId in avatar.GetQuestBook() do
		if avatar.GetQuestProgress( questId ).state == QUEST_READY_TO_RETURN then
			table.insert( result, avatar.GetQuestInfo( questId ).debugName )
		end
	end
	
	return result
end

function GetQuestInfoByName( name )
	for index, id in avatar.GetQuestHistory() do
		local info = avatar.GetQuestInfo( id )
		if info.debugName == name then
			return info
		end
	end
	
	return nil
end
