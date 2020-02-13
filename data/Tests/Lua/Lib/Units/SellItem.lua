-- author: LiventsevAndrey; date: 09.12.2008

Global( "SI_VENDOR_NAME", nil )
Global( "SI_ITEM_NAME", nil )
Global( "SI_ITEM_COUNT", nil )
Global( "SI_IS_ALL_ITEMS", nil )
Global( "SI_PASS_FUNC", nil )
Global( "SI_ERROR_FUNC", nil )

Global( "SI_SELLED", nil )
Global( "SI_START_COUNT", nil )

-- начинает диалог с торговцем и продает нужное кол-во предметов
function SellItem( vendorName, itemName, itemCount, funcPass, funcError )
	Log()
	Log( "SellItem " .. itemName, "Units.SellItem" )
	
	SI_IS_ALL_ITEMS = nil
	SI_VENDOR_NAME = vendorName
	SI_ITEM_NAME = itemName
	SI_ITEM_COUNT = itemCount
	SI_PASS_FUNC = funcPass
	SI_ERROR_FUNC = funcError
	
	SellItemStart()
	Log( "--- isVendor=" .. tostring(object.IsVendor( GetMobId(SI_VENDOR_NAME) )) )
	StartTalk( GetMobId(SI_VENDOR_NAME), SellItemOnTalking, SI_ERROR_FUNC )	
end

function SellAllItems( vendorName, funcPass, funcError )
	Log()
	Log( "SellAllItems", "Units.SellItem" )
	
	SI_IS_ALL_ITEMS = true
	SI_VENDOR_NAME = vendorName
	SI_PASS_FUNC = funcPass
	SI_ERROR_FUNC = funcError
	
	Log( "Start talk with" .. tostring( GetMobId(SI_VENDOR_NAME) ))
	Log( "d=" .. tostring( GetDistanceFromPosition( GetMobId( SI_VENDOR_NAME ), debugMission.InteractiveObjectGetPos( avatar.GetId()))))

	SellItemStart()
	
	StartTalk( GetMobId(SI_VENDOR_NAME), SellItemOnTalking, SI_ERROR_FUNC )	
end

function SellItemOnTalking()
	Log( "--- isVendor=" .. tostring(object.IsVendor( GetMobId(SI_VENDOR_NAME) )) )
	StartPrivateTimer( 5000, SI_ERROR_FUNC, "EVENT_VENDOR_LIST_UPDATED did not come" )

	SI_SELLED = false
	avatar.RequestVendor()
end

function CheckCountItemAfterSell()
	StopPrivateTimer()
	SellItemStop()
	if SI_START_COUNT - GetCountItem( SI_ITEM_NAME ) == SI_ITEM_COUNT then
		avatar.StopInteract()
		Log( "Success", "Units.SellItem" )
		StartPrivateTimer( 1000, SI_PASS_FUNC )
	else
		SI_ERROR_FUNC( "Selling item error: Wrong item count: " .. tostring(SI_START_COUNT) .. "-" .. tostring(GetCountItem( SI_ITEM_NAME ) ) .. " != " .. tostring(SI_ITEM_COUNT) )
	end
end

function SellItemStart()
	common.RegisterEventHandler( SI_OnVendorListUpdated, "EVENT_VENDOR_LIST_UPDATED" )
end

function SellItemStop()
	common.UnRegisterEventHandler( "EVENT_VENDOR_LIST_UPDATED" )
end


------------------------------------------ EVENTS ----------------------------------------------

function SI_OnVendorListUpdated( params )
	if SI_SELLED == false then
		SI_SELLED = true
		StopPrivateTimer()
		
		if SI_IS_ALL_ITEMS == true then
			for slot = 0, avatar.GetInventorySize()-1 do
				local itemId = avatar.GetInventoryItemId( slot )
				if itemId ~= nil then
					local info = avatar.GetItemInfo( itemId )
					avatar.Sell( slot, info.stackCount )
				end	
			end	
			SellItemStop()
			StartPrivateTimer( 1000, SI_PASS_FUNC )

		else
			SI_START_COUNT = GetCountItem( SI_ITEM_NAME )
			avatar.Sell( GetItemSlot( SI_ITEM_NAME ), SI_ITEM_COUNT )
			StartPrivateTimer( 2000, CheckCountItemAfterSell )
		end	
	end	
end
