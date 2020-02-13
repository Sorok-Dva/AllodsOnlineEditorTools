-- Script for ValuedTextAddon

--[[
--			Script tests text and text container
--]]

-- GLOBAL

Global( "valueKey", "name1" )
Global( "classValueKey", "class1" )

Global( "wtValueEdit", nil )
Global( "wtClassEdit", nil )
Global( "wtFormatEdit", nil )
Global( "wtTextContainer", nil )
Global( "wtTextView", nil )
Global( "wtObject1", nil )
Global( "wtObject2", nil )
Global( "wtValuedObjectTestClick1", nil )
Global( "wtValuedObjectTestClick2", nil )

Global( "isDefaultWidth", true )
Global( "defaultWidth", 500 )
Global( "nondefaultWidth", 100 )

Global( "isDefaultHeight", true )
Global( "defaultHeight", 300 )
Global( "nondefaultHeight", 100 )

Global( "ellipsis", true )
Global( "linespacing", 0 )
Global( "maxLinespacing", 50 )
Global( "clippedLine", true )
Global( "clippedSymbol", false )
Global( "multiline", true )
Global( "wrapText", true )

Global( "objectCount1", 0 )
Global( "objectCount2", 0 )

--////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////
--//
--// Helpers
--//

-- HELPER: 
function LoadDefaultValue( text, wtEdit )
	local value = common.GetAddonRelatedText( text )
	wtEdit:SetText( value )
end

--////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////
--//
--// Handlers
--//


-- REACTION: "load_values"
function OnReactionLoadValues( params )
	LoadDefaultValue( "DefaultFormat", wtFormatEdit )
	LoadDefaultValue( "DefaultValue", wtValueEdit )
	LoadDefaultValue( "DefaultClass", wtClassEdit )
end


-- REACTION: "clear_values"
function OnReactionClearValues( params )
	wtTextView:ClearValues()
end


-- REACTION: "set_width"
function OnReactionSetWidth( params )
	isDefaultWidth = not isDefaultWidth

	local placement = wtTextView:GetPlacementPlain()

	if isDefaultWidth then
		placement.sizeX = defaultWidth
	else
		placement.sizeX = nondefaultWidth
	end

	wtTextView:SetPlacementPlain( placement )
end


-- REACTION: "set_height"
function OnReactionSetHeight( params )
	isDefaultHeight = not isDefaultHeight

	local placement = wtTextView:GetPlacementPlain()

	if isDefaultHeight then
		placement.sizeY = defaultHeight
	else
		placement.sizeY = nondefaultHeight
	end

	wtTextView:SetPlacementPlain( placement )
end


-- REACTION: "set_style_align_top"
function OnReactionSetStyleAlignTop( params )
	wtTextView:SetAlignY( 0 )
end


-- REACTION: "set_style_align_middle"
function OnReactionSetStyleAlignMiddle( params )
	wtTextView:SetAlignY( 1 )
end


-- REACTION: "set_style_align_bottom"
function OnReactionSetStyleAlignBottom( params )
	wtTextView:SetAlignY( 2 )
end


-- REACTION: "set_style_ellipsis"
function OnReactionSetStyleEllipsis( params )
	ellipsis = not ellipsis
	wtTextView:SetEllipsis( ellipsis )
end


-- REACTION: "set_style_multiline"
function OnReactionSetStyleMultiline( params )
	multiline = not multiline
	wtTextView:SetMultiline( multiline )
end


-- REACTION: "set_style_linespacing"
function OnReactionSetStyleLinespacing( params )
	linespacing = linespacing + 10
	if linespacing > maxLinespacing then
		linespacing = 0
	end
	wtTextView:SetLinespacing( linespacing )
end


-- REACTION: "set_style_clipped_line"
function OnReactionSetStyleClippedLine( params )
	clippedLine = not clippedLine
	wtTextView:ShowClippedLine( clippedLine )
end


-- REACTION: "set_style_clipped_symbol"
function OnReactionSetStyleClippedSymbol( params )
	clippedSymbol = not clippedSymbol
	wtTextView:ShowClippedSymbol( clippedSymbol )
end


-- REACTION: "set_style_wrap_text"
function OnReactionSetStyleWrapText( params )
	wrapText = not wrapText
	wtTextView:SetWrapText( wrapText )
end


-- REACTION: "set_format"
function OnReactionSetFormat( params )
	local format = wtFormatEdit:GetText()

	wtTextView:SetFormat( format )
end


-- REACTION: "set_value"
function OnReactionSetValue( params )
	local value = wtValueEdit:GetText()

	wtTextView:SetVal( valueKey, value )
end


-- REACTION: "set_class"
function OnReactionSetClass( params )
	local value = wtClassEdit:GetText()

	wtTextView:SetClassVal( classValueKey, value )
end


--////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////
--//
--// Initialisation
--//


-- REACTION "add_string"
function OnReactionAddString( params )
	wtTextContainer:PushBackRawText( wtValueEdit:GetText() )
end

-- REACTION "front_string"
function OnReactionFrontString( params )
	wtTextContainer:PushFrontRawText( wtValueEdit:GetText() )
end

-- REACTION "pop_back_text"
function OnReactionPopBack( params )
	wtTextContainer:PopBack()
end

-- REACTION "pop_front_text"
function OnReactionPopFront( params )
	wtTextContainer:PopFront()
end


-- REACTION "add_valued_text"
function OnReactionAddValuedText( params )

	local valuedText = common.CreateValuedText()
	valuedText:SetFormat( wtFormatEdit:GetText() )
	valuedText:SetClassVal( "class1", wtClassEdit:GetText() )
	valuedText:SetVal( "name1", wtValueEdit:GetText() )

  wtTextContainer:PushBackValuedText( valuedText )

end


-- REACTION "clear_container"
function OnReactionClearContainer( params )

	wtTextContainer:RemoveItems()

end

-- REACTION: "valued_object_test_click_checker"

function OnReactionValuedObjectTestClickChecker( params )
	objectCount1 = objectCount1 + 100
	wtObject1:SetVal( "val", common.FormatInt( objectCount1, "%d" ) )

	objectCount2 = objectCount2 + 100
	wtObject2:SetVal( "val", common.FormatInt( objectCount2, "%d" ) )
end

-- Event EVENT_TEXT_OBJECT_CLICKED

function EVENT_TEXT_OBJECT_CLICKED( params )
	if params.object:GetId() == 1 then
		objectCount1 = objectCount1 + 1
		wtObject1:SetVal( "val", common.FormatInt( objectCount1, "%d" ) )
	elseif params.object:GetId() == 2 then
		objectCount2 = objectCount2 + 1
		wtObject2:SetVal( "val", common.FormatInt( objectCount2, "%d" ) )
	end
end

function Init()
	common.RegisterReactionHandler( OnReactionLoadValues, "load_values" )
	common.RegisterReactionHandler( OnReactionClearValues, "clear_values" )

	common.RegisterReactionHandler( OnReactionSetWidth, "set_width" )
	common.RegisterReactionHandler( OnReactionSetHeight, "set_height" )

	common.RegisterReactionHandler( OnReactionSetStyleAlignTop, "set_style_align_top" )
	common.RegisterReactionHandler( OnReactionSetStyleAlignMiddle, "set_style_align_middle" )
	common.RegisterReactionHandler( OnReactionSetStyleAlignBottom, "set_style_align_bottom" )
	common.RegisterReactionHandler( OnReactionSetStyleEllipsis, "set_style_ellipsis" )
	common.RegisterReactionHandler( OnReactionSetStyleLinespacing, "set_style_linespacing" )
	common.RegisterReactionHandler( OnReactionSetStyleMultiline, "set_style_multiline" )
	common.RegisterReactionHandler( OnReactionSetStyleClippedLine, "set_style_clipped_line" )
	common.RegisterReactionHandler( OnReactionSetStyleClippedSymbol, "set_style_clipped_symbol" )
	common.RegisterReactionHandler( OnReactionSetStyleWrapText, "set_style_wrap_text" )

	common.RegisterReactionHandler( OnReactionSetFormat, "set_format" )
	common.RegisterReactionHandler( OnReactionSetValue, "set_value" )
	common.RegisterReactionHandler( OnReactionSetClass, "set_class" )

	common.RegisterReactionHandler( OnReactionAddString, "add_string" )
	common.RegisterReactionHandler( OnReactionAddValuedText, "add_valued_text" )
	common.RegisterReactionHandler( OnReactionFrontString, "front_string" )
	common.RegisterReactionHandler( OnReactionClearContainer, "clear_container" )
	common.RegisterReactionHandler( OnReactionPopBack, "pop_back_text" )
	common.RegisterReactionHandler( OnReactionPopFront, "pop_front_text" )

	common.RegisterReactionHandler( OnReactionValuedObjectTestClickChecker, "valued_object_test_click_checker" )

	common.RegisterEventHandler( EVENT_TEXT_OBJECT_CLICKED, "EVENT_TEXT_OBJECT_CLICKED" )
	
	wtValueEdit = mainForm:GetChildChecked( "ValueEdit", true )
	wtClassEdit = mainForm:GetChildChecked( "ClassValueEdit", true )
	wtFormatEdit = mainForm:GetChildChecked( "TextEdit", true )
	wtTextContainer = mainForm:GetChildChecked( "TextContainer", true )
	wtTextView = mainForm:GetChildChecked( "TextView", true )
	wtObject1 = mainForm:GetChildChecked( "Object1", true )
	wtObject2 = mainForm:GetChildChecked( "Object2", true )
	wtValuedObjectTestClick1 = mainForm:GetChildChecked( "ValuedObjectTestClick1", true )
	wtValuedObjectTestClick2 = mainForm:GetChildChecked( "ValuedObjectTestClick2", true )
end

-- custom initialization

Init()
