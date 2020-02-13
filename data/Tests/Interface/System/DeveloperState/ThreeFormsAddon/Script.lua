--
-- run reaction "test_highlight" to move button
--

-- REACTION: "test_highlight"

function OnReactionTestHightlight( params )
	local wtBtn = mainForm:GetChildChecked( "StartTest", true )
	local placement = wtBtn:GetPlacementPlain()
	placement.posX = placement.posX + 1
	wtBtn:SetPlacementPlain( placement )
end

function Init()
	common.RegisterReactionHandler( OnReactionTestHightlight, "test_highlight" )
end

-- custom initialization

Init()
