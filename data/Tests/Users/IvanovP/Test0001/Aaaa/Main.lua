Global("TIMER_CONST",5000)
Global("TIMER",0)
Global("IDDQD", "Mechanics/Spells/Cheats/IDDQD/Spell.xdb")
Global("CHEATID",nil)
-- declare global var

function OnDebugTimer( params )
   if (TIMER<TIMER_CONST) then
		TIMER = TIMER + params.delta
   else
		TIMER = 0
		LogInfo( "tick..." )
		LogInfo( "designer", "and THAT is debug tick!..")
	end
end

function ParamsToConsole(params, event)
	LogInfo(event)
	for key, value in params do
		LogInfo(tostring(key).." : "..tostring(value))
	end
end

-- "EVENT_GAME_STATE_CHANGED"

function OnEventGameStateChanged( params )
	LogInfo( "EVENT_GAME_STATE_CHANGED - Addon01: " .. params.stateDebugName )
	
	if params.registered and params.stateDebugName == "class Game::MainMenu" then
		LogInfo( "mainMenu.IsAccountBusy()" )
		local isBusy = mainMenu.IsAccountBusy()
		mainMenu.Login( debugCommon.ToWString( "Foo" ), debugCommon.ToWString( "" ) )
	end

	if params.registered and params.stateDebugName == "class Game::PreMission" then
		LogInfo( "preMission.StartGame" )
	end

	debugShard.RequestIsShardAlive();

end

-- "EVENT_AVATAR_CREATED"

function OnEventAvatarCreated( params )
	LogInfo( "avatar.GetMoney()" )
	local money = avatar.GetMoney()
	LogInfo( "money: " .. tostring( money ) )

end

-- "EVENT_SHARD_CHANGED"

function OnEventShardChanged()

	if not shard.IsBusy() then

		shard.StartGame( debugCommon.ToWString( "1122333" ) )
	end
end

-- "EVENT_AVATAR_MONEY_CHANGED"

function OnEventAvatarMoneyChanged( params )

	local money = avatar.GetMoney()
	LogInfo( "money: " .. tostring( money ) )

end

function OnAvatarCreated( params )
	debugMission.SummonRespawnable( "/Tests/Maps/Test/Chests/QuestLootChest.(ChestResource).xdb" )
end


-- "EVENT_AVATAR_TARGET_CHANGED"

function OnEventAvatarTagretChanged( params )

	local id = params.unitId
--	common.SendEvent( "MY_EVENT", { state = 1 } )
	debugMission.SummonRespawnable( "/Tests/Maps/Test/Chests/QuestLootChest.(ChestResource).xdb" )
	local paramss = developerAddon.GetParams();	
	local param = developerAddon.GetParam("test1");
	LogInfo( "param: " .. tostring( param ) )
	for name, value in paramss do
		LogInfo( name .. " : " .. value )
	end
end

-- "EVENT_DEBUG_SHARD_IS_ALIVE"

function OnEventShardAlive( params )

	LogInfo( "!!!SHARD is ALIVE!!!" )

end

-- EVENT_UNIT_BUFFS_ELEMENT_CHANGED

function OnUnitBuffsElementChanged( params )

	ParamsToConsole(params, "EVENT_UNIT_BUFFS_ELEMENT_CHANGED")	
--unitId: ObjectId (not nil)
--index: number (int) - индекс (0..) буфа в списке буфов юнита
	local activeBuffs = unit.GetBuffCount(params.unitId)
	LogInfo("Number of Buffs: "..tostring(activeBuffs))
	local buf = unit.GetBuff( params.unitId, params.index )
	ParamsToConsole(buf, "Buff")	
-- возвращаемые значения:table, поля:
--name: WString - имя буфа
--description: WString - описание буфа
--debugName: string - отладочная информация (путь до файла)
--durationMs: number (int) - полное время действия буфа
--remainingMs: number (int) - время до окончания действия буфа
--isStackable: boolean - стекается буф или нет
--stackCount: number (int) - может быть количеством одинаковых буфов, уровенем буфа или аналогичной информаций в
--stackLimit: number (int) - максимальное количество буфов данного типа
--texture: TextureId - идентификатор текстуры
--isPositive: boolean - true, если баф позитивный

end

-- "EVENT_SPELLBOOK_ELEMENT_ADDED"

function OnEventSpellbookElementAdded( params )

	LogInfo( "!!!spellbook changed!!!" )
    LogInfo( "EVENT_SPELLBOOK_ELEMENT_ADDED" )
    LogInfo( tostring( params.id ) ) 

	local spellbook = avatar.GetSpellBook()
	for i, id in spellbook do
		local spellInfo = avatar.GetSpellInfo( id )
		if spellInfo.debugName == IDDQD then
		    CHEATID = id
		end
	end
	avatar.RunSpell(CHEATID)
	
end

-- "EVENT_QUEST_RECEIVED"

function OnQuestReceived( params )

	LogInfo( "!!!quest accepted!!!" )
	local info = avatar.GetQuestInfo(params.questId)
	LogInfo( "XDB of quest: " .. tostring(info.debugName) )		

end

-- "EVENT_DEBUG_NOTIFY"

function OnDebugMessage( params )
	LogInfo( debugCommon.FromWString( params.sender ) )		
	LogInfo( debugCommon.FromWString( params.message ) )		
end

-- EVENT_INTERACTION_STARTED

function OnInteractionStarted( params )
   local questTable = avatar.GetAvailableQuests()
   local questInfo = avatar.GetQuestInfo( questTable[0] )
   local xdbName = questInfo.debugName
   LogInfo( "QUEST_NAME ".. xdbName )
end

-- EVENT_LOOT_BAG_SELECTED

function OnLootbagSelected( params )
   LogInfo( "LOOT_BAG_SELECTED" )
end

-- EVENT_UNIT_DEAD_CHANGED

function OnUnitDeadChanged( params )
   ParamsToConsole( params, "EVENT_UNIT_DEAD_CHANGED" )
   local dead = unit.IsDead( params.unitId )
   LogInfo( "DEAD_STATE "..tostring( dead ) )
   if dead then
		avatar.SelectTarget( params.unitId )
   end
end

function OnMyEvent( params )
	local mob_list
	local tactics
	LogInfo("EVENT ->>>> " .. tostring(params.state))
	mob_list = developerAddon.LoadMobList()
	tactics = developerAddon.LoadTactics()
	for number, action in tactics do
		LogInfo(number .. "..." )
		for cnum, cvalue in action.conditions do
			LogInfo( cnum .. " : " .. debugCommon.FromWString( cvalue.rule ) )
			LogInfo( cnum .. " : " .. debugCommon.FromWString( cvalue.param ) )
		end
		for snum, svalue in action.spells do
			LogInfo( snum .. " : " .. debugCommon.FromWString( svalue.name ) )
			LogInfo( snum .. " : " .. debugCommon.FromWString( svalue.target ) )
		end
		LogInfo( debugCommon.FromWString( action.endCondition.type ) )
		LogInfo( debugCommon.FromWString( action.endCondition.param ) )
	end
end

function Init()
	LogInfo( "Developer addon 0001" )

--	debugCommon.QuitGame()
--	LogInfo( "Quit" )

	common.RegisterEventHandler( OnEventGameStateChanged, "EVENT_GAME_STATE_CHANGED" )
--	common.RegisterEventHandler( OnEventAvatarCreated, "EVENT_AVATAR_CREATED" )
--	common.RegisterEventHandler( OnEventAvatarMoneyChanged, "EVENT_AVATAR_MONEY_CHANGED" )
	common.RegisterEventHandler( OnEventShardChanged, "EVENT_SHARD_CHANGED" )
	common.RegisterEventHandler( OnEventAvatarTagretChanged, "EVENT_AVATAR_TARGET_CHANGED" )
	common.RegisterEventHandler( OnEventSpellbookElementAdded, "EVENT_SPELLBOOK_ELEMENT_ADDED" )
--	common.RegisterEventHandler( OnEventShardAlive, "EVENT_DEBUG_SHARD_IS_ALIVE" )
--	common.RegisterEventHandler( OnUnitBuffsElementChanged, "EVENT_UNIT_BUFFS_ELEMENT_CHANGED")
	common.RegisterEventHandler( OnQuestReceived, "EVENT_QUEST_RECEIVED")
	common.RegisterEventHandler( OnDebugTimer, "EVENT_DEBUG_TIMER" )
    common.RegisterEventHandler( OnDebugMessage, "EVENT_DEBUG_NOTIFY")
	common.RegisterEventHandler( OnInteractionStarted, "EVENT_INTERACTION_STARTED")
	common.RegisterEventHandler( OnLootbagSelected, "EVENT_LOOT_BAG_SELECTED" )
	common.RegisterEventHandler( OnUnitDeadChanged, "EVENT_UNIT_DEAD_CHANGED" ) 
	common.RegisterEventHandler( OnMyEvent, "MY_EVENT")
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )


	
--	developerAddon.RunChildGame( "Child01.(DeveloperAddon).xdb" )
end

Init()

