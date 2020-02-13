-- ScriptContextTooltipDebug.lua
-- Script for Context Tooltip Debug addon
-- 12:02 12.01.2009
--------------------------------------------------------------------------------
--trace.enable()
--------------------------------------------------------------------------------
-- GLOBALS
--------------------------------------------------------------------------------
Global( "onBase", {} )
--------------------------------------------------------------------------------
--EVENT HANDLERS
--------------------------------------------------------------------------------
onBase[ "SCRIPT_REQUEST_CONTEXT_TOOLTIP" ] = function( params )
	tooltip:Toggle( false )
	
	params = Normalize( params )
	local content = GetTemplateContent( params )
	
	if content then
		tooltip:Repaint( content )
		tooltip:SetupUpdate( content, params, onBase.SCRIPT_REQUEST_CONTEXT_TOOLTIP )
		tooltip:Toggle( true, params )
	end
end
--------------------------------------------------------------------------------
onBase[ "SCRIPT_HIDE_CONTEXT_TOOLTIP" ] = function( params )
	tooltip:Toggle( false, params )
end
--------------------------------------------------------------------------------
-- RESOURCES SETUP 
--------------------------------------------------------------------------------
function RegisterEventHandlers( handlers )
	for event, handler in handlers do
		----trace( "event = ", event )
		multevent.RegisterEventHandler( handler, event )
	end
end
--------------------------------------------------------------------------------
function UnRegisterEventHandlers( handlers )
	for event, handler in handlers do
		----trace( "event = ", event )
		multevent.UnRegisterEventHandler( handler, event )
	end
end
--------------------------------------------------------------------------------
--INITIALIZATION
--------------------------------------------------------------------------------
function Init()
	RegisterLayoutManagedAddon( { type = ADDON_TYPE_SUPER_HUD, side = SCREEN_SIDE_GENERAL } )
	RegisterEventHandlers( onBase )
	tooltipcontent:Init()
	tooltip:Init()
end
--------------------------------------------------------------------------------
if common.HasDebugLibs() then
	Init()
end