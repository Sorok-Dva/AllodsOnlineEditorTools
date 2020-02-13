-- Script for Effects Addon

--[[
			Script tests widgets effects
--]]

-- GLOBAL
Global( "play", true )
Global( "initPlacement", nil )
Global( "TEST_BUTTON_NAME", "CooldownTestButton" )

Global( "wtCastBlip", nil )

-- EVENT_CHANGE_EFFECTS_VISIBILITY handler
function OnEventAddonVisibilityChanged( params )

	mainForm:Show( not mainForm:IsVisible() )
	
end

-- EVENT_EFFECT_FINISHED
function OnEventEffectFinished( params )

--	LogInfo( "EVENT_EFFECT_FINISHED: id=" .. tostring( params.effectID ) ..", type=" .. tostring( params.effectType ) )

end


-- "run_cooldown" reaction handler
function OnReactionCooldownButtonPressed( reactionParams )

--	local wtTestButton = mainForm:GetChildChecked( TEST_BUTTON_NAME, true )

--	if play then
--		local toPlacement = {}
--		for i,val in initPlacement do
--		    toPlacement[i] = val
--	 	end

--		toPlacement.sizeX = 10
--		toPlacement.posX = 800
--		--toPlacement.posY = 10

--		--wtTestButton:PlayResizeEffect( initPlacement, toPlacement, 2000, EA_SYMMETRIC_FLASH )
--		wtTestButton:PlayMoveEffect( initPlacement, toPlacement, 1000, EA_SYMMETRIC_FLASH )
--		play = false
--	else
--		wtTestButton:FinishResizeEffect()
--		wtTestButton:FinishMoveEffect()
--		play = true
--	end

	local fromPlacement = wtCastBlip:GetPlacementPlain()
	local toPlacement = {}
	for i,val in fromPlacement do
	    toPlacement[i] = val
 	end
 	toPlacement.posX = 259
 	wtCastBlip:PlayMoveEffect( fromPlacement, toPlacement, 500, EA_SYMMETRIC_FLASH )

end

-- Initialization
function Init()
	
	common.SetCursor( "default" )
	
  	common.RegisterEventHandler( OnEventAddonVisibilityChanged, "EVENT_CHANGE_EFFECTS_VISIBILITY" )
  	common.RegisterEventHandler( OnEventEffectFinished, "EVENT_EFFECT_FINISHED" )
  	common.RegisterReactionHandler( OnReactionCooldownButtonPressed, "run_cooldown" )
  	
  	local wtTestButton = mainForm:GetChildChecked( TEST_BUTTON_NAME, true )
  	initPlacement = wtTestButton:GetPlacementPlain()
  	
  	wtCastBlip = mainForm:GetChildChecked( "CastBlip", true )
  	
  	local tiledTextureId = common.GetAddonRelatedTexture( "tiled" )
  	local wtTiledPanel = mainForm:GetChildChecked( "Tiled", true )
  	wtTiledPanel:SetBackgroundTexture( tiledTextureId )  
  	
end

-- custom initialization
Init()
