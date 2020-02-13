-- REACTION: "start_test"

Global( "wtControl3D", nil )
Global( "wtTextPanel", nil )
Global( "wtText3DText", nil )
Global( "testPhase", "INITIAL" )

function StartTest( params )
	if testPhase == "INITIAL" then
		local size = { sizeX = 1; sizeY = 1 }
		local pos = { posX = 6.5; posY = 0.9; posZ = 3 }
		wtControl3D:AddWidget3D( wtTextPanel, size, pos, true, false )
		testPhase = "CHANGE_POS"
	elseif testPhase == "CHANGE_POS" then
		local pos = { posX = 7; posY = 1; posZ = 3.2 }
		wtControl3D:SetWidget3DPos( wtTextPanel, pos )
		testPhase = "CHANGE_SIZE"
	elseif testPhase == "CHANGE_SIZE" then
		local size = { sizeX = 1.3; sizeY = 1.3 }
		wtControl3D:SetWidget3DSize( wtTextPanel, size )
		testPhase = "TEMP_REMOVE"
	elseif testPhase == "TEMP_REMOVE" then
		wtControl3D:RemoveWidget3D( wtTextPanel )
		testPhase = "ADD_BACK"
	elseif testPhase == "ADD_BACK" then
		local size = { sizeX = 1; sizeY = 1 }
		local pos = { posX = 6.5; posY = 0.9; posZ = 3 }
		wtControl3D:AddWidget3D( wtTextPanel, size, pos, true, false )
		testPhase = "FINAL_REMOVE"
	elseif testPhase == "FINAL_REMOVE" then
		wtControl3D:RemoveAllWidget3D()
		testPhase = "FINISHED"
	elseif testPhase == "FINISHED" then
		testPhase = "INITIAL"
	end

	wtText3DText:SetVal( "phase", testPhase )
end

function Init()
	common.RegisterReactionHandler( StartTest, "start_test" )
	
	wtControl3D = mainForm:GetChildChecked( "Control3D", true )
	developer.CreateScene3DWithVisObj( wtControl3D, "Creatures/Troll/Troll.(VisObjectTemplate).xdb" )
	
	wtTextPanel = mainForm:GetChildChecked( "Text3D", true )
	wtText3DText = wtTextPanel:GetChildChecked( "Text3DText", true )
	wtText3DText:SetVal( "phase", testPhase )

	common.SetCursor( "default" )
end

-- custom initialization

Init()
