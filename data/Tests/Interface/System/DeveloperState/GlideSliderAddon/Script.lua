Global( "wtDiscreteSlider", nil )
Global( "wtDiscreteSliderEdit", nil )

function DiscreteSliderToEdit()
	local pos = wtDiscreteSlider:GetPos()
	wtDiscreteSliderEdit:SetText( common.FormatInt( pos, "%d" ) )
--	LogInfo( "wtDiscreteSlider:GetPos: ", pos )
end

-- REACTION: "discrete_slider_apply"
function OnReactionDiscreteSliderApply( params )
--	LogInfo( "discrete_slider_apply" )
	
	DiscreteSliderToEdit()
end

-- REACTION: "discrete_slider_edit_enter"
function OnReactionDiscreteSliderEditEnter( params )
--	LogInfo( "discrete_slider_edit_enter" )

	local text = wtDiscreteSliderEdit:GetText()
	local sysText = debugCommon.FromWString( text )
	local pos = tonumber( sysText )
	wtDiscreteSlider:SetPos( pos )

--	LogInfo( "wtDiscreteSliderEdit, text: ", sysText )
--	LogInfo( "wtDiscreteSliderEdit, pos: ", pos )
end

-- REACTION: "discrete_slider_changed"
function OnReactionDiscreteSliderChanged( params )
--	LogInfo( "OnReactionDiscreteSliderChanged" )

	DiscreteSliderToEdit()
end

function InitDiscreteSlider()
--	LogInfo( "InitDiscreteSlider" )

	local wtPanel = mainForm:GetChildChecked( "DiscreteSliderPanel", true )
	wtDiscreteSlider = wtPanel:GetChildChecked( "DiscreteSlider", true )
	wtDiscreteSliderEdit = wtPanel:GetChildChecked( "DiscreteSliderPosEdit", true )

	local pos = wtDiscreteSlider:GetPos()
	wtDiscreteSliderEdit:SetText( common.FormatInt( pos, "%d" ) )
	
	DiscreteSliderToEdit()
	
	common.RegisterReactionHandler( OnReactionDiscreteSliderApply, "discrete_slider_apply" )
	common.RegisterReactionHandler( OnReactionDiscreteSliderEditEnter, "discrete_slider_edit_enter" )
	common.RegisterReactionHandler( OnReactionDiscreteSliderChanged, "discrete_slider_changed" )
end

function Init()
	InitDiscreteSlider()
end

-- custom initialization
Init()
