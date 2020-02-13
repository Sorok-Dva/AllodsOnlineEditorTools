Global("REVISION","")
Global("LOOT_REGISTER",false)
Global("THREAT_REGISTER",true)
Global("TESTERS_QUESTS",nil)
Global("TESTERS_QUESTS_ID",nil)
Global("LAST_QUEST", "")
Global("TESTERS_TOOLTIP_XDB",nil)

-------------------------------------------------------------------------------
-- REACTION HANDLERS
-------------------------------------------------------------------------------
-- on reaction toggle_tab (default key: [TAB]) -- generate SCRIPT_TOGGLE_TAB
function strKoor(c,d)
	return tostring(c).."."..tostring(d)
end
function cell( x )
	if x>0 then
		return math.floor( x )
	else
		return math.ceil( x )
	end
end


function OnReactionTestersChoice( reactionParams )
    common.LogInfo("common","Testers Choice generate clipboard text")
	local pos = avatar.GetPos()
    local posNew = avatar.GetPosNew()
    local map = debugMission.GetMap()
	local mapName = map.debugName
	local currentMap = cartographer.GetCurrentMap() 
	local curMapStr = StrConc( "Карта:",currentMap.name )
	local currentZone = cartographer.GetCurrentZone()
	local curZoneStr = StrConc("Zone:",{currentZone.zoneName, "SubZone:",currentZone.subZoneName, "Allod:",currentZone.allod})
	
    local p = ToAbsCoord(pos)
	local cX = cell(p.X)
	local cY = cell(p.Y)
	local cZ = cell(p.Z)
	local dX = cell(math.abs(p.X - cX)*10)
	local dY = cell(math.abs(p.Y - cY)*10)
	local dZ = cell(math.abs(p.Z - cZ)*10)
	
	local strMap = curZoneStr.."\n"
	local strKoor = StrConc("tpmap",{mapName, strKoor(cX,dX), strKoor(cY,dY), strKoor(cZ,dZ)})
	
	
	local avId = avatar.GetId()
	local priTarget = unit.GetPrimaryTarget( avId )
	local secTarget = unit.GetTarget( avId )
    local Target = nil
    
	if priTarget ~= nil then
		Target = priTarget
	else
		Target = secTarget
	end
    local tgtStr = ""
	if Target ~= nil then
		tgtStr = GetTgtStr(Target)
		local questStr = GetQuestStr()
		local unBuff = GetBuffStr( Target )
		local svnRev = debugCommon.GetRevision()
		local revStr = StrConc("\n\nnet_version:",{debugCommon.FromWString(REVISION),"svn Rev:",svnRev})
		common.LogInfo("common","TargetId "..tostring(Target))
		debugCommon.SetClipboardText(strMap..strKoor..tgtStr.."\n"..unBuff..questStr..revStr)
	else
		debugCommon.SetClipboardText(strKoor)
	end
end

function GetTgtStr(id)
    if unit.IsPlayer( id ) then
		local zonesMapId = unit.GetZonesMapId( id )
		local curMap = cartographer.GetZonesMapInfo( zonesMapId )
		local zoneXdbStr = StrConc("\nMapSys:",{curMap.mapSysName,"ZoneSys:", curMap.zoneSysName})
		local spells = GetSpellsHistory()
        return zoneXdbStr..spells
	else
        local xdb = qaMission.UnitGetXDB( id )
		local kind = qaMission.UnitGetKind( id )
		return StrConc("\nMob",{"Kind:",kind,"\nXdb:",xdb})
	end
end


function GetQuestStr()
	local book = avatar.GetQuestBook()
	local info = nil
	local str = "Quests:\n"
	for key, questId in book do
		info = avatar.GetQuestInfo( questId )
		str = StrConc(str,{debugCommon.FromWString(info.name),"level:",info.level,"Зона:",info.zoneName,"\n",info.debugName})
	end
	return str
end


function OnReactionTestersQuests( reactionParams )

	local clipboard = debugCommon.GetClipboardText()
	TESTERS_QUESTS = {}
	local i = 1
	local j = 1
	local match = ""
	while true do
		i = string.find(clipboard,"\n", j)
		if i ~= nil then
			match = string.sub(clipboard,j,i)
			table.insert(TESTERS_QUESTS,match)
			j = i + 1
		else
			break
		end
	end
	TESTERS_QUESTS_ID = 1
	StartTimer(200,GiveQuest,nil)
	StartTimer2(10000,CleanQuests,nil)
end

function CleanQuests(text)
	TESTERS_QUESTS = nil
	TESTERS_QUESTS_ID = nil
	if text ~= nil then
		-- SAY in CHAT
		group.ChatYell( debugCommon.ToWString( "Quests finish!" ) )
	else
		group.ChatYell( debugCommon.ToWString( "WrongQuest" ) )
	end
end

function GiveQuest()
	if TESTERS_QUESTS[TESTERS_QUESTS_ID] ~= nil then
		StartTimer(3000,NextQuest,nil)
		qaMission.SendCustomMsg("give_quest "..TESTERS_QUESTS[TESTERS_QUESTS_ID])
	else
		--STOP
		CleanQuests(true)
	end
end
function NextQuest()
	TESTERS_QUESTS_ID = TESTERS_QUESTS_ID + 1
	StartTimer(200,GiveQuest,nil)
end
function FinishQuest()
	qaMission.SendCustomMsg("finish_quest "..TESTERS_QUESTS[TESTERS_QUESTS_ID])
	NextQuest()
end

function OnQuestReceived( params )
	local info = avatar.GetQuestInfo( params.questId )
	LAST_QUEST = StrConc("",{debugCommon.FromWString(info.name),"level:",info.level,"Зона:",info.zoneName,"\n",info.debugName})

	if TESTERS_QUESTS_ID ~= nil and TESTERS_QUESTS ~= nil then
		local info = avatar.GetQuestInfo( params.questId )
		common.LogInfo("common",info.debugName..TESTERS_QUESTS[TESTERS_QUESTS_ID])
		if TESTERS_QUESTS ~= nil then
			if string.find(TESTERS_QUESTS[TESTERS_QUESTS_ID],info.debugName) or string.find(info.debugName,TESTERS_QUESTS[TESTERS_QUESTS_ID]) then
				StopTimer2()
				FinishQuest()
			end
		end
	end
end

function OnReactionTestersSpeed( reactionParams )
	local speed = debugMission.UnitGetSpeed( avatar.GetId() )
	local dir = avatar.GetDir()
	common.LogInfo( "common", "speed base: "..speed.base.." speed effective:"..speed.effective.." direction "..tostring(dir) )
	local avBuff = GetBuffStr( avatar.GetId() )
	local toclip = ""
	if LAST_QUEST ~= "" then
		toclip = toclip..LAST_QUEST.."\n"
	end
	if avBuff ~= "" then
		toclip = toclip..avBuff
	end
	debugCommon.SetClipboardText( toclip )
end

function GetBuffStr(unitId)
	local activeBuffs = unit.GetBuffCount( unitId )
	local strBuf = ""
	while activeBuffs > 0 do
		local buff = unit.GetBuff( unitId, activeBuffs - 1)
		local groups = StrConc("\nGroups:",buff.debugGroups)
		strBuf = StrConc(strBuf,{"\n",buff.debugName,"stackLimit:", buff.stackLimit,"buff.stackCount",buff.stackCount,groups})
		activeBuffs = activeBuffs - 1
	end
	return "Buffs: "..strBuf
end

function OnReactionTestersEquip( reactionParams )
	common.LogInfo("common","Testers Equip ")
	local itemName = debugCommon.GetClipboardText()
	local mm = string.find(itemName,"xdb")
	if mm ~= nil then
		qaMission.SendCustomMsg("create_item "..itemName)
		StartTimer(2000, OnCreateItem, itemName)
	else
		FailCreateItem(itemName)
	end
end

function FailCreateItem(name)
	common.LogInfo("common","FAIL create Item "..tostring(name))
end

function OnCreateItem(itemName)
	local slot = GetItemSlot( itemName )
	if slot ~= nil then
		avatar.EquipItem(slot)
	else
		FailCreateItem(itemName)
	end
end

function OnReactionTestersLootRegister( reactionParams )
	common.LogInfo("common","send to managerAddon LootStatisticsBot")
	if not LOOT_REGISTER then
		common.SendEvent("EVENT_ENABLE_UI_ADDON",{addon = "LootStatisticsBot"})
	else
		common.SendEvent("EVENT_DISABLE_UI_ADDON",{addon = "LootStatisticsBot"})
	end
	LOOT_REGISTER = not LOOT_REGISTER
end

function OnReactionTestersThreat( reactionParams )
	common.LogInfo("common","send to managerAddon ThreatMeter")
	if not THREAT_REGISTER then
		common.SendEvent("EVENT_ENABLE_UI_ADDON",{addon = "ThreatMeter"})
	else
		common.SendEvent("EVENT_DISABLE_UI_ADDON",{addon = "ThreatMeter"})
	end
	THREAT_REGISTER = not THREAT_REGISTER
end

function OnReactionTestersBag (reactionParams )
	local str = ""
	str = str.."On Avatar:".."\n"
	local equIds = unit.GetEquipmentItemIds( avatar.GetId() )
	for i, id in equIds do
		local info = avatar.GetItemInfo(id)
		str = str..info.debugInstanceFileName.."\n"
	end
	str = str.."In Bag:".."\n"
	local bagIds = avatar.GetInventoryItemIds()
	for i, id in bagIds do
		local info = avatar.GetItemInfo(id)
		str = str..info.debugInstanceFileName.."\n"
	end
	common.LogInfo("common","Set to Clipbord - Item Xdb's ")
	
	debugCommon.SetClipboardText(str)
end

function OnReactionTestersXDB( reactionParams )
	if type(TESTERS_TOOLTIP_XDB) == "string" then
		debugCommon.SetClipboardText( TESTERS_TOOLTIP_XDB )
	else
		local isWString = common.IsWString( TESTERS_TOOLTIP_XDB )
		if isWString then
			local devices = avatar.GetDeviceList()
			for key, value in devices do
				local devName = object.GetName( value )
				local result = common.CompareWString( TESTERS_TOOLTIP_XDB, devName )
				if result == 0 then
					local xdb = qaMission.DeviceGetDebugName(value)
					debugCommon.SetClipboardText( xdb )
					break
				end
			end
		end
	end
end

function OnDebugTooltip( params )
	if params == nil then
		return
	end
	if params.tooltip == nil then
		return
	end
	local xdbPath = nil
	if params.tooltip == 1 then -- UNIT
		if params.unitId ~= nil then
			xdbPath = qaMission.UnitGetXDB( params.unitId )
		end
	elseif params.tooltip == 2 then -- ITEM
		if params.itemId ~= nil then
			local itemInfo = avatar.GetItemInfo( params.itemId )
			xdbPath = itemInfo.debugInstanceFileName
		end
	elseif params.tooltip == 5 then -- SPELL
		if params.spellId ~= nil then
			local spellInfo = avatar.GetSpellInfo( params.spellId )
			xdbPath = spellInfo.debugName
		end
	elseif params.tooltip == 7 then -- ABILITY
		if params.abilityId ~= nil then
			local abilityInfo = avatar.GetAbilityInfo( params.abilityId )
			xdbPath = abilityInfo.sysInfo
		end
	elseif params.tooltip == 6 then -- BUFF
		if params.unitId ~= nil and params.index ~= nil then
			local buffInfo = unit.GetBuff( params.unitId, params.index )
			xdbPath = buffInfo.debugName
		end
	elseif params.tooltip == 15 then -- TALENT
		if params.column ~= nil and params.row ~= nil then
			local talent = nil
			if params.field == nil then -- BASE
				talent = avatar.GetBaseTalentInfo( params.row, params.column )
			else	-- FIELD
				talent = avatar.GetFieldTalentInfo( params.field, params.row, params.column )
			end
			if talent ~= nil then
				local talentInfo = nil
				if talent.next ~= nil then
					talentInfo = talent.next
				elseif talent.current ~= nil then
					talentInfo = talent.current
				end
				if talentInfo ~= nil then
					if talentInfo.spellId ~= nil then
						local talentSpellInfo = avatar.GetSpellInfo( talentInfo.spellId )
						xdbPath = talentSpellInfo.debugName	
					elseif talentInfo.abilityId ~= nil then
						local talentAbilityInfo = avatar.GetAbilityInfo( talentInfo.abilityId )
						xdbPath = talentAbilityInfo.sysInfo
					end
				end
			end
		end
	elseif params.tooltip == 10 then
		if params.name ~= nil then
			xdbPath = params.name
		end
	end
	if xdbPath ~= nil then
		--common.LogInfo("common","XDB: "..tostring(xdbPath))
		TESTERS_TOOLTIP_XDB = xdbPath
	else
		for ij, jj in params do
			--common.LogInfo("common", tostring(ij).." "..tostring(jj) )
		end
	end
	
end

Global("SPELL_HISTORY",{})

function OnActionSpellSpecialResult( params )
	if params.unitId == avatar.GetId() then
		if params.sysId == "ENUM_ACTION_RESULT_SPECIAL_LAUNCHED" then
			local spellInfo = avatar.GetSpellInfo(params.spellId)
			
			local str = StrConc(TIME_SEC,{spellInfo.name, spellInfo.debugName},"\t")
			table.insert(SPELL_HISTORY,str)
			common.LogInfo("common", str)
			local count = 0
			for i in SPELL_HISTORY do
				count = count + 1
			end
			if count > 10 then
				table.remove(SPELL_HISTORY,count - 10)
			end
		end
	end
end

function GetSpellsHistory()
	local str = ""
	for i, v in SPELL_HISTORY do
		str = str.."\n"..v
	end
	return str
end

-------------------------------------------------------------------------------
-- INITIALIZATION
-------------------------------------------------------------------------------
function Init()
	-- register keyboard reactions

	common.RegisterEventHandler( OnDebugTooltip, "SCRIPT_REQUEST_CONTEXT_TOOLTIP" )
	common.RegisterEventHandler( OnQuestReceived, "EVENT_QUEST_RECEIVED" )
	
	common.RegisterEventHandler( OnActionSpellSpecialResult, "EVENT_ACTION_RESULT_SPECIAL_SPELL" )
	--common.LogInfo("common","Testers Choice INIT")
	common.RegisterReactionHandler( OnReactionTestersChoice, "testersChoice" )
	common.RegisterReactionHandler( OnReactionTestersQuests, "testersQuests" )
	common.RegisterReactionHandler( OnReactionTestersSpeed, "testersSpeed" )
	common.RegisterReactionHandler( OnReactionTestersEquip, "testersEquip" )
	common.RegisterReactionHandler( OnReactionTestersThreat, "testersThreat" )
	common.RegisterReactionHandler( OnReactionTestersBag, "testersBag" )
	common.RegisterReactionHandler( OnReactionTestersXDB, "testersXdb" )
	common.RegisterReactionHandler( OnReactionTestersLootRegister, "testersLoot" )

	REVISION = common.GetGameVersion()
end
-------------------------------------------------------------------------------

Init()