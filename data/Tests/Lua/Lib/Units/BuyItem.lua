-- author: LiventsevAndrey; date: 09.12.2008

Global( "BUY_ITEM_VENDOR_NAME", nil )
Global( "BUY_ITEM_ITEM_NAME", nil )
Global( "BUY_ITEM_ITEM_COUNT", nil )
Global( "BUY_ITEM_IS_BUY_BACK", nil )
Global( "BUY_ITEM_PASS_FUNC", nil )
Global( "BUY_ITEM_ERROR_FUNC", nil )

Global( "BUY_ITEM_START_COUNT", nil )
Global( "BUY_ITEM_START_MONEY", nil )
Global( "BUY_ITEM_ITEM_PRICE", nil )

Global( "BUY_ITEM_ITEM_BOUGHT", nil )


-- начинает диалог с торговцем и покупает нужное кол-во предметов
-- isBuyBack - необязательный параметр - говорит о том что нужно выкупить предмет назад
function BuyItem( vendorName, itemName, itemCount, funcPass, funcError, isBuyBack )
	Log()
	Log( "Buy item " .. itemName, "Units.BuyItem" )
	
	BUY_ITEM_VENDOR_NAME = vendorName
	BUY_ITEM_ITEM_NAME = itemName
	BUY_ITEM_ITEM_COUNT = itemCount
	BUY_ITEM_START_MONEY = avatar.GetMoney()
	if isBuyBack then
		BUY_ITEM_IS_BUY_BACK = isBuyBack
	else
		BUY_ITEM_IS_BUY_BACK = false
	end
	
	BUY_ITEM_PASS_FUNC = funcPass
	BUY_ITEM_ERROR_FUNC = funcError
	
	BuyItemStart()
	StartTalk( GetMobId(BUY_ITEM_VENDOR_NAME), BuyItemOnTalking, BUY_ITEM_ERROR_FUNC )
end

function BuyItemOnTalking()
	StartPrivateTimer( 5000, BUY_ITEM_ERROR_FUNC, "EVENT_VENDOR_LIST_UPDATED did not come" )
	BUY_ITEM_ITEM_BOUGHT = false
	avatar.RequestVendor()
end

function CheckBuyResult()
	local passed = nil
	local msg = nil
	
	if GetCountItem( BUY_ITEM_ITEM_NAME ) == BUY_ITEM_START_COUNT + BUY_ITEM_ITEM_COUNT then
		passed = true
		Log( "count items:  " .. tostring(GetCountItem( BUY_ITEM_ITEM_NAME )) .. " == " .. tostring(BUY_ITEM_START_COUNT) .. "+" .. tostring(BUY_ITEM_ITEM_COUNT), "Units.BuyItem" )
	else
		passed = false
		msg = "Wrong item count after buying: " .. tostring(GetCountItem( BUY_ITEM_ITEM_NAME )) .. " != " .. tostring(BUY_ITEM_START_COUNT) .. "+" .. tostring(BUY_ITEM_ITEM_COUNT)
	end
	
	if avatar.GetMoney() == BUY_ITEM_START_MONEY - BUY_ITEM_ITEM_COUNT * BUY_ITEM_ITEM_PRICE then
		passed = passed and true
		Log( "money:  " .. tostring(avatar.GetMoney()) .. " == " .. tostring(BUY_ITEM_START_MONEY) .. "- (" .. tostring(BUY_ITEM_ITEM_COUNT) .. "*" .. tostring(BUY_ITEM_ITEM_PRICE) .. ")", "Units.BuyItem" )
	else
		passed = false
		msg = msg .. "/n Wrong money count after buying: " .. tostring(avatar.GetMoney()) .. " != " .. tostring(BUY_ITEM_START_MONEY) .. "- (" .. tostring(BUY_ITEM_ITEM_COUNT) .. "*" .. tostring(BUY_ITEM_ITEM_PRICE) .. ")"
	end
	
	if passed == true then
		Log( "Success", "Units.BuyItem" )
		avatar.StopInteract()
		StartPrivateTimer( 2000, BUY_ITEM_PASS_FUNC )
	else
		BUY_ITEM_ERROR_FUNC( msg )
	end
end

function BuyItemStart()
	common.RegisterEventHandler( BI_OnVendorListUpdated, "EVENT_VENDOR_LIST_UPDATED" )
end

function BuyItemStop()
	common.UnRegisterEventHandler( "EVENT_VENDOR_LIST_UPDATED" )
end



------------------------------------------- EVENTS -----------------------------------------------------

function BI_OnVendorListUpdated( params )
	if BUY_ITEM_ITEM_BOUGHT == false then
		BUY_ITEM_ITEM_BOUGHT = true
		StopPrivateTimer()
		
		local items = nil
		if BUY_ITEM_IS_BUY_BACK == true then
			Log( "get buy back vendor item list", "Units.BuyBack" )
			items = avatar.GetVendorBuyback()
		else
			Log( "get vendor item list" , "Units.BuyBack" )
			items = avatar.GetVendorList()
		end
		
		if items == nil or GetTableSize( items ) == 0 then
			BUY_ITEM_ERROR_FUNC( "Vendors item list is null or empty" )
		else
			local findItem = false
			for index, item in items do
				local itemInfo = avatar.GetItemInfo( item.id )
				if itemInfo.debugInstanceFileName == BUY_ITEM_ITEM_NAME then
					findItem = true
					Log( "  find item for buying", "Units.BuyItem" )

					BUY_ITEM_ITEM_PRICE = item.price
					BUY_ITEM_START_COUNT = GetCountItem( BUY_ITEM_ITEM_NAME )
					StartPrivateTimer( 5000, BUY_ITEM_ERROR_FUNC, "Item bought but not added to inventory" )				
					avatar.Buy( item.id, BUY_ITEM_ITEM_COUNT )
					break
				end
			end

			if findItem == true then
				StartPrivateTimer( 1000, CheckBuyResult )
			else
				BUY_ITEM_ERROR_FUNC( "Vendor don't have required item: " .. BUY_ITEM_ITEM_NAME )
			end
		end
	end	
end
