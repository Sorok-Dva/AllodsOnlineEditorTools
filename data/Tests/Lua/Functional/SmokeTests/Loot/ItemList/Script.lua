Global( "TEST_NAME", "SmokeTest.Loot.ItemList; author: Liventsev Andrey, date: 16.07.08, bug 32374" )

Global( "MOB_NAME", "Tests/Maps/Test/Instances/6ItemsLootBag.(MobWorld).xdb" )
Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )

Global( "DAGGER", "Mechanics/ItemClasses/Dagger.xdb" )
Global( "WEAPON1H", "Mechanics/ItemClasses/1HAxe.xdb" )
Global( "WEAPON2HL", "Mechanics/ItemClasses/2HSpear.xdb" )
Global( "WEAPON2H", "Mechanics/ItemClasses/2HSword.xdb" )
Global( "ARMOR", "Mechanics/ItemClasses/Plate.xdb" )
Global( "BELT", "Mechanics/ItemClasses/Cloth.xdb" )

Global( "CUR_MOB_ID", nil )

function OnAvatarCreated()
	StartTest( TEST_NAME )
	local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
	SummonMob( MOB_NAME, MAP_RESOURCE, newPos, 0, Step1, ErrorFunc )
end

function Step1( mobId )
	CUR_MOB_ID = mobId
	KillMob( mobId, EmptyFunction, ErrorFunc )
end

function LootingMob()
	if unit.IsDead( CUR_MOB_ID ) and unit.IsUsable( CUR_MOB_ID ) then
		object.Use( CUR_MOB_ID, 0 )
		StartPrivateTimer( 3000, ErrorFunc, "OnLootBagOpenStateChanged did not come" )
		
	else
		ErrorFunc( "Can not loot mob - mob is not dead or mob is not usable" )
	end
end

function Done()
	DisintagrateMob( ENEMY_NAME )
	StartTimer( 3000, Success, TEST_NAME )
end

function ErrorFunc( text )
	DisintagrateMob( ENEMY_NAME )
	StartTimer( 3000, ErrorFunc2, text )
end

function ErrorFunc2( text )
	Warn( TEST_NAME, text )
end


----------------------------------- EVENTS ------------------------------------------

function OnLootMark( params )
	if params.unitId == CUR_MOB_ID then
		if params.enabled == true then
			StartTimer( 1000, LootingMob )
		end
	end
end

function OnLootBagOpenStateChanged( params )
	Log( "Loot bag open state changed" )
	if avatar.IsLootBagOpen() then
		StopPrivateTimer()
	
		local dagger = false
		local weapon1 = false
		local weapon2 = false
		local weapon2L = false
		local armor = false
		local belt = false
		local loot = avatar.GetLootBagSlots()
		local lootTable = loot.items
		if lootTable ~= nil then
			for slot, itemId in lootTable do
				local itemInfo = avatar.GetItemInfo( itemId )
				local className = itemInfo.debugClassFileName
				Log( "   className=" .. tostring(className) )

				if className == DAGGER then
					dagger = true
					
				elseif className == WEAPON1H then
					weapon1 = true
					
				elseif className == WEAPON2HL then
					weapon2L = true
					
				elseif className == WEAPON2H then
					weapon2 = true
					
					
				elseif className == ARMOR then
					armor = true
					
				elseif className == BELT then
					belt = true
				end
			end	
		end
		
		if not( dagger and weapon1 and weapon2L and weapon2 and armor and belt ) then
			local resultString = "there is not following classes in loot:"
			if dagger == false then
				resultString = resultString .. " dagger"
			end
			if weapon1 == false then
				resultString = resultString .. " weapon1h"
			end
			if weapon2L == false then
				resultString = resultString .. " weapon2hl"
			end
			if weapon2 == false then
				resultString = resultString .. " weapon2h"
			end
			if armor == false then
				resultString = resultString .. " armor"
			end
			if belt == false then
				resultString = resultString .. " belt"
			end
			
			ErrorFunc( resultString )
		else
			Success( TEST_NAME )	
		end
	end	
end

function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" ),
		create = "AutoMage"
	}
	InitLoging(login)

	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	common.RegisterEventHandler( OnLootBagOpenStateChanged, "EVENT_LOOT_BAG_OPEN_STATE_CHANGED" )
	common.RegisterEventHandler( OnLootMark, "EVENT_LOOT_MARK" )
end

Init()
