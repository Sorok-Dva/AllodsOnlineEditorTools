-- Script for ThreatMeter (debug for core) mod

--trace.enable()

-- GLOBALS

Global( "targetId", nil )
Global( "grayGaugeId", nil )
Global( "orangeGaugeId", nil )
Global( "MAX_ENTRIES_TRACKED", 6 )
Global( "ENTRY_PREFIX", "Entry" )
Global( "THREAT_GAUGE_FULL_SIZE", 218 )

-- UTILITY: update threat

function UpdateThreat()

	local aggroList = protectedMission.UnitGetAggroList( targetId )
	--trace( "aggroList = ", tabletolog( aggroList ) )
	
	-- clean and empty aggrolist on nil aggrolist
	if not aggroList then
	 aggroList = {}
	end
	
	-- forming sorted aggro list and counting total aggro sum
	local totalAggro = 0
	local aggroListSorted = {}
	aggroListSorted.id = {}
	aggroListSorted.threat = {}
	local count = 0
	
	for id, threat in aggroList do
		
		count = count + 1
		totalAggro = totalAggro + threat
		
		aggroListSorted.id[ count ] = id
		aggroListSorted.threat[ count ] = threat
		
	end
	
	-- now bubbling
	for i = 1, count - 1 do
		for j = 1, i do
 
 			if aggroListSorted.threat[ j ] < aggroListSorted.threat[ j + 1 ] then
				
				local swap = aggroListSorted.threat[ j ]
				aggroListSorted.threat[ j ] = aggroListSorted.threat[ j + 1]
				aggroListSorted.threat[ j + 1] = swap
				
				swap = aggroListSorted.id[ j ]
				aggroListSorted.id[ j ] = aggroListSorted.id[ j + 1]
				aggroListSorted.id[ j + 1 ] = swap
			
			end
		
		end
	end
	
	-- hiding those not needed
	if count < MAX_ENTRIES_TRACKED then
		for i = count + 1, MAX_ENTRIES_TRACKED do
		
			local wtEntry = mainForm:GetChildChecked( ENTRY_PREFIX .. i, false )
			wtEntry:Show( false )			
		
		end
	end

	-- showing relevant threat indicators
	if count > MAX_ENTRIES_TRACKED then
		count = MAX_ENTRIES_TRACKED
	end
	
	local aggroHolder = unit.GetTarget( targetId )	
	
	for i = 1, count do
	
		local wtEntry = mainForm:GetChildChecked( ENTRY_PREFIX .. i, false )
		
		-- set bad guy name
		local wtName = wtEntry:GetChildChecked( "CharacterName", false )
		local badGuyName = object.GetName( aggroListSorted.id[ i ] )
		local badGuyClass = unit.GetClass( aggroListSorted.id[ i ] )
		
		wtName:SetVal( "character_name", badGuyName or common.GetEmptyWString() )
		wtName:SetVal( "class_name", badGuyClass.name or common.GetEmptyWString() )
		
		-- set threat value
		local wtThreat = wtEntry:GetChildChecked( "ThreatValue", false )
		wtThreat:SetVal( "threat_value", common.FormatFloat( aggroListSorted.threat[ i ], "%g" ) )
		
		-- set gauge color
		local wtGauge = wtEntry:GetChildChecked( "ThreatBar", false )
		if aggroHolder == aggroListSorted.id[ i ] then
			wtGauge:SetBackgroundTexture( orangeGaugeId )
		else
			wtGauge:SetBackgroundTexture( grayGaugeId )
		end
		
		-- slide gaguge length
		local placement = wtGauge:GetPlacementPlain()
		placement.sizeX = math.ceil( THREAT_GAUGE_FULL_SIZE * ( aggroListSorted.threat[ i ] / totalAggro ) )
		wtGauge:SetPlacementPlain( placement )

		-- show it
		wtEntry:Show( true )
		
	end

end

-- EVENT_AVATAR_TARGET_CHANGED

function OnEventAvatarTargetChanged( params )

	targetId = avatar.GetTarget()

	if not( targetId ) or targetId == avatar.GetId() then
		mainForm:Show( false )
		return
	end

	mainForm:Show( true )

	UpdateThreat()

end

-- EVENT_UNIT_AGGRO_LIST_CHANGED

function OnEventUnitAggroListChanged( params )

	-- filter target related
	if targetId ~= params.unitId then
	  return
	end
	
	UpdateThreat()

end

-- INITIALIZATION

function Init()

	-- registering event handlers
	common.RegisterEventHandler( OnEventAvatarTargetChanged, "EVENT_AVATAR_TARGET_CHANGED" )
	common.RegisterEventHandler( OnEventUnitAggroListChanged, "EVENT_UNIT_AGGRO_LIST_CHANGED" )
	
	-- registering resources
	grayGaugeId = common.GetAddonRelatedTexture( "GrayGauge" )
	orangeGaugeId = common.GetAddonRelatedTexture( "OrangeGauge" )

end

Init()