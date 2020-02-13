function ShowQuestInfo( questId )
	local info = avatar.GetQuestInfo( questId )
	if info then
		LogInfo( "  Quest Info: " )
		LogInfo( "    quest.id: "..info.id );
		LogInfo( "    quest.name: "..info.name );
		LogInfo( "    quest.goal: "..info.goal );
		LogInfo( "    quest.startText: "..info.startText );
		LogInfo( "    quest.checkText: "..info.checkText );
		LogInfo( "    quest.finishText: "..info.finishText );
		LogInfo( "    quest.kickText: "..info.kickText );
	end
end


function ShowQuestProgress( questId )
	local progress = avatar.GetQuestProgress( questId )
	if progress then
		LogInfo( "Quest Progress: " )
		LogInfo( "  quest.id: "..progress.id );
		LogInfo( "  quest.state: "..progress.state );

		LogInfo( "  Objectives: " )
		local items = progress.objectives;
		if items then
			for k, v in items do
				LogInfo( "    k: "..k )
				LogInfo( "    v.id: "..v.id )
				LogInfo( "    v.name: "..v.name )
				LogInfo( "    v.progress: "..v.progress )
				LogInfo( "    v.required: "..v.required )
			end
		end
	end
end


function ShowQuestBook()
	LogInfo( "QuestBook values:" )
	local book = avatar.GetQuestBook()
	if book then
		for k, v in book do
			LogInfo( "  book.k: "..k )
			LogInfo( "  book.v: "..v )
 			ShowQuestInfo( v )
 			ShowQuestProgress( v )
		end
	end
end

function OnEventQuestReceived( params )
	LogInfo( "Script_QuestReceived: "..params.questId )
 	ShowQuestBook()
end

function OnEventQuestUpdated( params )
	LogInfo( "Script_QuestUpdated: "..params.questId )
 	ShowQuestBook()
end

function OnEventQuestDiscarded( params )
	LogInfo( "Script_QuestDiscarded: "..params.questId )
 	ShowQuestBook()
end

function OnEventQuestCompleted( params )
	LogInfo( "Script_QuestCompleted: "..params.questId )
 	ShowQuestBook()
end

function OnEventQuestFailed( params )
	LogInfo( "Script_QuestFailed: "..params.questId )
 	ShowQuestBook()
end

function OnEventAvatarClass( params )
 	local group = "visobjects"
 	local groupId = mission.GetResGroup( group )
 	if groupId then
		LogInfo( "Script: VisObjects groupId = "..groupId )
		
		local resName = "questMark"
		local resId =  common.GetResVisObject( groupId, resName )
		if resId then
			LogInfo( "Script: VisObjects resId = "..resId )
		else
			LogInfo( "Script: No VisObject resource("..resName..")" )
		end
		
	else
		LogInfo( "Script: NO VisObjects groupId("..group..")" )
 	end
end

function ShowPrimaryStats()
	local strength = avatar.GetStrength()
	LogInfo( "Script: strength base: "..strength.base.." strength effective:"..strength.effective )
	local agility = avatar.GetAgility()
	LogInfo( "Script: agility base: "..agility.base.." agility effective:"..agility.effective )
	local stamina = avatar.GetStamina()
	LogInfo( "Script: stamina base: "..stamina.base.." stamina effective:"..stamina.effective )
	local intellect = avatar.GetIntellect()
	LogInfo( "Script: intellect base: "..intellect.base.." intellect effective:"..intellect.effective )
	local wisdom = avatar.GetWisdom()
	LogInfo( "Script: wisdom base: "..wisdom.base.." wisdom effective:"..wisdom.effective )				
end

function ShowResistances()
	local armor = avatar.GetArmor()
	LogInfo( "Script: armor base: "..armor.base.." armor effective:"..armor.effective )
	local elemental = avatar.GetElemental()
	LogInfo( "Script: elemental base: "..elemental.base.." elemental effective:"..elemental.effective )
	local divine = avatar.GetDivine()
	LogInfo( "Script: divine base: "..divine.base.." divine effective:"..divine.effective )
	local nature = avatar.GetNature()
	LogInfo( "Script: nature base: "..nature.base.." nature effective:"..nature.effective )
end


function OnEventTargetChanged( params )
--------------------------------------------------------------------------------
--	local size = unit.GetSizeDebug( avatar.GetTarget() )
--	LogInfo( "Script: size base: "..size.base.." size effective:"..size.effective )					
--	local speed = unit.GetSpeedDebug( avatar.GetTarget() )
--	LogInfo( "Script: speed base: "..speed.base.." speed effective:"..speed.effective )					
--------------------------------------------------------------------------------
--	 unit.SetLootMark( params.id, true )
--------------------------------------------------------------------------------
--	local inMeleeRange = avatar.IsTargetInMeleeRange()
--	if inMeleeRange then
--		LogInfo( "Script: target IN MELEE RANGE: " )
--	else
--		LogInfo( "Script: target OUT MELEE RANGE: " )	
--	end
--------------------------------------------------------------------------------
--	local targetId = unit.GetTarget( params.id )
--	if targetId then
--		LogInfo( "Script: targetId: "..targetId )
--	end
--------------------------------------------------------------------------------
--	local class = unit.GetClass( params.id )
--	if class then
--		LogInfo( "Script: Character Class.isManaCaster: "..tostring( class.isManaCaster ) )
--		LogInfo( "Script: Character Class.name: "..class.name )
--	end
--------------------------------------------------------------------------------	
--	LogInfo( "Script: TargetChanged: "..params.id )
--	unit.SetQuestMark( params.target, 4 )	
--
--	local targetName = unit.GetName( params.target )
--	LogInfo( "Script: unit.GetName = "..targetName )
--
--	LogInfo( "unit.AvailableQuests" )
-- 	local quests = unit.GetReturnableQuests( params.target )
--	LogInfo( "unit.ReturnableQuests" )
-- 		for k, v in quests do
--		LogInfo( "  quest.k: "..k )
--		LogInfo( "  quest.v: "..v )
--	end
--
-- 	unit.RequestAvailableQuests( params.target )
end

function OnAvailableQuests( params )
	LogInfo( "Script_QuestAvailable" )
	LogInfo( "Quest.unitId"..params.unitId )
	for k, v in params.quests do
		LogInfo( "  quest.k: "..k )
		LogInfo( "  quest.v: "..v )
	end
end


function OnUnitSpawned( params )
	LogInfo( "Script: Unit spawned:"..params.unitId )
	--avatar.SelectTarget( params.unitId )
	--unit.SetQuestMark( params.unitId, 1 )
end


function OnUnitDespawned( params )
	LogInfo( "Script: Unit despawned:"..params.unitId )
end

function OnUnitLevelUp( params )
	LogInfo( "Script: Unit :"..params.unitId.." level up "..params.amount )
end

function OnUnitLevelChanged( params )
	LogInfo( "Script: Unit :"..params.unitId.." level changed "..params.amount )
	unit.SetQuestMark( params.id, 1 )
end

function OnPositionChanged( params )
	LogInfo( "Script: Avatar ID:"..avatar.GetId() )
	local dir = avatar.GetDir();
	LogInfo( "Script: Avatar dir:"..dir )
	local unitId = avatar.GetTarget()
	if unitId then
	  local dr = unit.GetDirDebug( unitId )
		LogInfo( "Script: Target dir: "..dr )
	end	
end

function OnAvatarCombatStatusChanged( params )
	LogInfo( "Script: Combat status changed:"..tostring( params.inCombat ) )
	local inCombat = avatar.IsInCombat()
	if params.inCombat ~= inCombat then
		LogInfo( "ERROR: params.inCombat ~= avatar.IsInCombat()"..tostring( params.inCombat )..tostring( inCombat ) )
	end
end

function OnPrimaryStatsEvent( params )
	LogInfo( "Script: OnPrimaryStatsEvent" )
	ShowPrimaryStats()
end

function OnResistancesChengedEvent( params )
	LogInfo( "Script: OnResistancesChengedEvent" )
	ShowResistances()
end

function OnAggroChanged( params )
	LogInfo( "+++++++++++++++++++++++++++++++++++++++++++++++++++++++" )
	LogInfo( "Script: OnAggroChanged"..params.unitId )
	
	local aggro = debugMission.GetAggroList( params.unitId )
	for k, v in aggro do
		LogInfo( "  aggro.key: "..k )
		LogInfo( "  aggro.value: "..v )
	end	
	LogInfo( "+++++++++++++++++++++++++++++++++++++++++++++++++++++++" )	
end

function OnComboPointsChanged( params )
	LogInfo( "+++++++++++++++++++++++++++++++++++++++++++++++++++++++" )
	LogInfo( "Script: OnComboPointsChanged: defence="..params.defence.." attack="..params.attack )
	
	local comboPoints = avatar.GetComboPoints()
	LogInfo( "Script: avatar.GetComboPoints(): defence="..comboPoints.defence.." attack="..comboPoints.attack )
	LogInfo( "+++++++++++++++++++++++++++++++++++++++++++++++++++++++" )
end

function Init()
-- Перед использование нужно отключить квестовые аддоны

--	LogInfo( "Test Addon" )
--	common.RegisterEventHandler( OnComboPointsChanged, "EVENT_AVATAR_COMBOPOINTS_CHANGED" )
--	common.RegisterEventHandler( OnAggroChanged, "EVENT_UNIT_AGGRO_LIST_CHANGED" )
--	common.RegisterEventHandler( OnPrimaryStatsEvent, "EVENT_AVATAR_PRIMARY_STATS_CHANGED" )
--	common.RegisterEventHandler( OnResistancesChengedEvent, "EVENT_AVATAR_RESISTANCES_CHANGED" )

--	common.RegisterEventHandler( OnEventAvatarClass, "EVENT_AVATAR_CLASS" )
--  common.RegisterEventHandler( OnAvatarCombatStatusChanged, "EVENT_AVATAR_COMBAT_STATUS_CHANGED" )
--	common.RegisterEventHandler( OnAvailableQuests, "EVENT_AVAILABLE_QUESTS" )	
--	common.RegisterEventHandler( OnEventTargetChanged, "EVENT_AVATAR_TARGET_CHANGED" )
--	common.RegisterEventHandler( OnEventQuestReceived, "EVENT_QUEST_RECEIVED" )
--	common.RegisterEventHandler( OnEventQuestUpdated, "EVENT_QUEST_UPDATED" )
--	common.RegisterEventHandler( OnEventQuestDiscarded, "EVENT_QUEST_DISCARDED" )
--	common.RegisterEventHandler( OnEventQuestCompleted, "EVENT_QUEST_COMPLETED" )
--	common.RegisterEventHandler( OnEventQuestFailed, "EVENT_QUEST_FAILED" )
--	common.RegisterEventHandler( OnUnitSpawned, "EVENT_UNIT_SPAWNED" )
--	common.RegisterEventHandler( OnUnitDespawned, "EVENT_UNIT_DESPAWNED" )
--	common.RegisterEventHandler( OnUnitLevelUp, "EVENT_UNIT_LEVEL_UP" )
--	common.RegisterEventHandler( OnUnitLevelChanged, "EVENT_UNIT_LEVEL_CHANGED" )
--	common.RegisterEventHandler( OnPositionChanged, "EVENT_AVATAR_POS_CHANGED" )
end

-- custom initialization

Init()
