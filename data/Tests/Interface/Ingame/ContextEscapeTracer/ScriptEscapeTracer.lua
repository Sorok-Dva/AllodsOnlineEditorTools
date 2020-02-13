-- ScriptZoneAnnounce.lua
-- Script for Zone Announce addon
-- 15:44 26.11.2008
--------------------------------------------------------------------------------
-- GLOBALS
--------------------------------------------------------------------------------
-- Global Constants
Global( "MESSAGE_Y_DISPLACEMENT", 20 )
-- Widgets
Global( "wtMain", {} )
Global( "wtText", {} )
Global( "wtTextDesc", nil )
-- Variables
Global( "wtRankIndex", {} )
--------------------------------------------------------------------------------
-- COMMON UTILITY
--------------------------------------------------------------------------------
function UpdateAttendee( rank )
	local wtId = wtRankIndex[ rank ]
	local name = strEscSeqRankId[ rank ]
	local active = tostring( escAttendeesActive[ rank ].active )
	local count = tostring( escAttendeesActive[ rank ].count )
	
	wtText[ wtId ]:SetVal( "value", ToWs( name .. ": count = " .. count .. ", " .. active ) )
	wtText[ wtId ]:SetClassVal( "class", escAttendeesActive[ rank ].active and "tip_green" or "tip_white" )
end
--------------------------------------------------------------------------------
-- EVENT HANDLERS
--------------------------------------------------------------------------------
-- SCRIPT_NOTIFY_OF_ESCAPE_SEQUENCE_ATTENDEE_STATE
function OnScriptNotifyOfEscapeSequenceAttendeeState( identifier )
	escAttendeesActive[ identifier.rank ].list[ identifier.name ] = identifier.active and identifier or nil
	escAttendeesActive[ identifier.rank ].count = GetAttendeesRankMaxCount( identifier.rank )
	escAttendeesActive[ identifier.rank ].active = GetAttendeesRankActiveState( identifier.rank )
	
	UpdateAttendee( identifier.rank )
end
--------------------------------------------------------------------------------
-- RESOURCES SETUP
--------------------------------------------------------------------------------
function GetWidgets()
	for id,rank in escapeSequence do
		if not wtTextDesc then
			wtText[ id ] = mainForm:GetChildChecked( "TextLine", false )
			wtTextDesc = wtText[ id ]:GetWidgetDesc()
		else
			wtText[ id ] = mainForm:CreateWidgetByDesc( wtTextDesc )
		end
		
		local placement = wtText[ id ]:GetPlacementPlain()
		placement.posY = placement.posY + MESSAGE_Y_DISPLACEMENT * ( id - 1 )
		wtText[ id ]:SetPlacementPlain( placement )
		
		wtText[ id ]:Show( true )
		wtRankIndex[ rank ] = id
		
		UpdateAttendee( rank )
	end
	mainForm:SetFade( 0.3 )
end
--------------------------------------------------------------------------------
-- INITIALIZATION
--------------------------------------------------------------------------------
function Init()
	if common.GetScriptCfgVar( "show_escape_tracer" ) then
		RegisterLayoutManagedAddon( { type = ADDON_TYPE_SUPER_HUD, side = SCREEN_SIDE_LEFT } )
		RegisterEscapeSequenceAttendee( { rank = ESCAPE_SEQUENCE_RANK_NONE } )
		
		GetWidgets()
		mainForm:Show( true )
	end
end
--------------------------------------------------------------------------------
Init()
