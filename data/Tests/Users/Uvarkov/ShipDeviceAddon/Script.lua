-- GLOBALS
Global( "wtDebugControlPanel", nil )
Global( "wtDebugControlInfo", nil )
Global( "debugActions", {} )
Global( "CONTROL_NAME", "Control" )
Global( "INFO_NAME", "Info" )

-- EVENT_AVATAR_USED_OBJECT_CHANGED

function OnEventAvatarUsedObjectChanged( params )
	common.LogInfo( "common", "EVENT_AVATAR_USED_OBJECT_CHANGED" )

	local info = avatar.GetActiveUsableDeviceInfo()
	
	wtDebugControlPanel:Show( false )
	if info then
		for i = 0, GetTableSize( debugActions ) - 1 do
			debugActions[i].wtAction:Show( false )
		end
	end
	
	if info then
		wtDebugControlInfo:SetVal( "name", info.name )

		local actions = info.actions

		common.LogInfo( "common", " used" )
		common.LogInfo( "common", "  name: " .. debugCommon.FromWString( info.name ) .. ", actions count: " .. GetTableSize( actions ) )

		for i = 0, GetTableSize( actions ) - 1 do
			local action = actions[i]
			common.LogInfo( "common", "  action: " .. i )
			common.LogInfo( "common", "   name: " .. debugCommon.FromWString( action.name ) )
			common.LogInfo( "common", "   desc: " .. debugCommon.FromWString( action.description ) )
			common.LogInfo( "common", "   image: " .. tostring( action.image ) )

			if i < GetTableSize( debugActions ) then
				local debugAction = debugActions[i]
				debugAction.wtAction:Show( true )
				debugAction.wtInfo:SetVal( "name", action.name )
				debugAction.wtInfo:SetVal( "desc", action.description )
			end
		end

		wtDebugControlPanel:Show( true )
	else
		common.LogInfo( "common", " unused" )
	end
end

function DebugControl( index )
	local info = avatar.GetActiveUsableDeviceInfo()
	if not info then
		common.LogInfo( "common", "Can't run command: no active device" )
		return
	end

	local actions = info.actions

	if index < 0 or index >= GetTableSize( actions ) then
		common.LogInfo( "common", "Can't run command: wrong action index: " .. tostring( index ) )
		return
	end

	common.LogInfo( "common", "Run command with action index: " .. tostring( index ) )
	avatar.RunUsableDeviceAction( index )
end

-- REACTION: "debug_control_panel_close"

function OnReactionDebugControlPanelClose( params )
	local info = avatar.GetActiveUsableDeviceInfo()
	if not info then
		common.LogInfo( "common", "Can't close device: no active device" )
		return
	end

	common.LogInfo( "common", "Close device" )
	avatar.DeactivateUsableDevice()
end

-- REACTION "debug_control"

function OnReactionDebugControl( params )
	local subName = string.sub( params.sender, string.len( CONTROL_NAME ) + 1 )
	local index = tonumber( subName )
	if not index then
		common.LogError( "common", "Wrong params.sender: " .. params.sender .. " sub: " .. subName )
		return
	end

	DebugControl( index )
end

-- INITIALIZATION

function Init()
	common.RegisterEventHandler( OnEventAvatarUsedObjectChanged, "EVENT_AVATAR_USED_OBJECT_CHANGED" )

	wtDebugControlPanel = mainForm:GetChildChecked( "DebugControlPanel", true )
	wtDebugControlInfo = wtDebugControlPanel:GetChildChecked( "DeviceInfo", true )
	wtDebugControlPanel:Show( false )
	for i = 0, 5 do
		local action = {}
		action.wtAction = wtDebugControlPanel:GetChildChecked( string.format ( "Action%02d", i + 1 ), true )
		action.wtControl = action.wtAction:GetChildChecked( CONTROL_NAME, true )
		action.wtControl:SetName( CONTROL_NAME .. tostring( i ) )
		action.wtInfo = action.wtAction:GetChildChecked( INFO_NAME, true )
		debugActions[i] = action
	end

	common.RegisterReactionHandler( OnReactionDebugControlPanelClose, "debug_control_panel_close" )
	common.RegisterReactionHandler( OnReactionDebugControl, "debug_control" )
end

Init()
