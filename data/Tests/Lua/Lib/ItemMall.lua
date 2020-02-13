-- author: Liventsev Andrey, date: 10.04.2009
-- Библиотека для торговли в итемМоле

Global( "IM_PASS_FUNC", nil )
Global( "IM_ERROR_FUNC", nil )
Global( "IM_UPDATE_SUCCESS", nil )
Global( "IM_COUNT_TRYES", nil )

Global( "IM_SUB_CATEGORY_ID", nil )
Global( "IM_CATEGORY_ID", nil )
Global( "IM_ITEM_ID", nil )
Global( "IM_COUNT_ITEMS", nil )

-- получает список подкатегорий. Если надо - обновляетс список
function ItemMallGetSubCategories( categoryId, passFunc, errorFunc )
	IM_Log()
	IM_Log( "Get subcategories of category=" .. tostring( categoryId ))

	IM_Start()
	IM_PASS_FUNC = passFunc
	IM_ERROR_FUNC = errorFunc
	IM_CATEGORY_ID = categoryId
	IM_COUNT_TRYES = 0
	IM_GetSubCategories( IM_CATEGORY_ID )
end

function IM_GetSubCategories()
	if IM_COUNT_TRYES >= 3 then 
		IM_Error( "Get subcategroies list in 3 times - still not valid" )
		return
	end
	
	local categories = itemMall.GetCategories()
	for index, cId in categories do
		if cId == IM_CATEGORY_ID then
			local cInfo = itemMall.GetCategoryInfo( cId )
			local subCats = itemMall.GetSubCategories( cId )
			if subCats.valid == false then
				IM_Log( "subcategories list is not valid. Need to refresh" )
				IM_COUNT_TRYES = IM_COUNT_TRYES + 1
				IM_UPDATE_SUCCESS = false
				StartPrivateCheckTimer( 60000, IM_CheckUpdatingProcess, nil, IM_Error, "Can't update subCategories list for 60 sec", IM_GetSubCategories, nil )

			else
				IM_Log( "category: id=" .. tostring(cId) .. "  name=" .. FromWString( cInfo.name ) .. "   desc=" .. FromWString( cInfo.description ))
				IM_Log( "  subCategories.valid=" .. tostring( subCats.valid ) )
				for index2, scId in subCats.subcategories do
					local scInfo = itemMall.GetSubCategoryInfo( scId )
					IM_Log( "   subCat: id=" .. tostring( scId ) .. "  name=" .. FromWString( scInfo.name ))
				end
				IM_Done( subCats.subcategories )
			end	
			
			return
		end
	end
	
	IM_Error( "Can't find category by id=" .. tostring( IM_CATEGORY_ID ))
end

-- получает список предметов по подкатегории
function ItemMallGetItemsBySubCategoryId( subCategoryId, passFunc, errorFunc )
	IM_Log()
	IM_Log( "Get items of subcategories =" .. tostring( subCategoryId ))
	
	IM_Start()
	IM_PASS_FUNC = passFunc
	IM_ERROR_FUNC = errorFunc
	IM_SUB_CATEGORY_ID = subCategoryId
	IM_COUNT_TRYES = 0	
	IM_GetItems()
end
function IM_GetItems()
	if IM_COUNT_TRYES >= 3 then 
		IM_Error( "Get items list in 3 times - still not valid" )
		return
	end

	local items = itemMall.GetItems( IM_SUB_CATEGORY_ID )
	if items.valid == false then
		IM_Log( "items list is not valid. Need to refresh..." )
		IM_COUNT_TRYES = IM_COUNT_TRYES + 1
		IM_UPDATE_SUCCESS = false
		StartPrivateCheckTimer( 60000, IM_CheckUpdatingProcess, nil, IM_Error, "Can't update items list for 60 sec", IM_GetItems, nil )
	else
		for index, itemInfo in items.items do 
			IM_Log( "  item: price=" .. tostring( itemInfo.price ) .. "  itemId=" .. tostring( itemInfo.itemId ) )
		end
		IM_Done( items.items )
	end
end

function ItemMallBuyItem( itemId, passFunc, errorFunc )
	IM_Log()
	IM_Log( "Buy item: id=" .. tostring( itemId ))
	
	IM_Start()
	IM_PASS_FUNC = passFunc
	IM_ERROR_FUNC = errorFunc
	IM_ITEM_ID = itemId
	IM_COUNT_ITEMS = GetCountItemById( IM_ITEM_ID )
	Log( "start count=" .. tostring( IM_COUNT_ITEMS ))
	
	StartPrivateTimer( 10000, IM_Error, "event EVENT_ITEM_MALL_BUY_RESULT did not come after buying item using item mall" )
	itemMall.BuyItem( IM_ITEM_ID )
end

function IM_CheckCountItems()
	Log( tostring(GetCountItemById( IM_ITEM_ID )) .. " == " .. tostring(IM_COUNT_ITEMS + 1) )
	return GetCountItemById( IM_ITEM_ID ) == IM_COUNT_ITEMS + 1
end

function IM_CheckUpdatingProcess()
	return IM_UPDATE_SUCCESS
end

function IM_Done( params )
	IM_Log( "done" )
	IM_Stop()
	IM_PASS_FUNC( params )
end

function IM_Error( text )
	IM_Stop()
	IM_ERROR_FUNC( text )
end

function IM_Start()
	common.RegisterEventHandler( IM_OnItemMallCategoryUpdateResult, "EVENT_ITEM_MALL_CATEGORY_UPDATE_RESULT" )
	common.RegisterEventHandler( IM_OnItemMallSubCategoryUpdateResult, "EVENT_ITEM_MALL_SUBCATEGORY_UPDATE_RESULT" )
	common.RegisterEventHandler( IM_OnItemMallAccountUpdateResult, "EVENT_ITEM_MALL_ACCOUNT_UPDATE_RESULT" )
	common.RegisterEventHandler( IM_OnItemMallCanNotBuyItems, "EVENT_ITEM_MALL_CANNOT_BUY_ITEMS" )
	common.RegisterEventHandler( IM_OnItemMallBuyResult, "EVENT_ITEM_MALL_BUY_RESULT" )
end

function IM_Stop()
	common.UnRegisterEventHandler( "EVENT_ITEM_MALL_SUBCATEGORY_UPDATE_RESULT" )
	common.UnRegisterEventHandler( "EVENT_ITEM_MALL_CATEGORY_UPDATE_RESULT" )
	common.UnRegisterEventHandler( "EVENT_ITEM_MALL_ACCOUNT_UPDATE_RESULT" )
	common.UnRegisterEventHandler( "EVENT_ITEM_MALL_CANNOT_BUY_ITEMS" )
	common.UnRegisterEventHandler( "EVENT_ITEM_MALL_BUY_RESULT" )
end

function IM_Log( text )
	Log( text, "ItemMall" )
end


function IM_OnItemMallCategoryUpdateResult( params )
	if params.id == IM_CATEGORY_ID then
		IM_Log( "OnItemMallCategoryUpdateResult: id=" .. tostring( params.id ) .. "  result=" .. params.sysStatus  )
		if params.sysStatus == "ENUM_ItemMallGetCategoriesResultMsgStatus_SUCCESS" or params.sysStatus == "ENUM_ItemMallGetCategoriesResultMsgStatus_NOTCHANGED" then
			IM_UPDATE_SUCCESS = true
		else
			IM_Error( "Can't update item mall sub categories: " .. params.sysResult )
		end
	end	
end

function IM_OnItemMallSubCategoryUpdateResult( params )
	if params.id == IM_SUB_CATEGORY_ID then
		IM_Log( "OnItemMallSubCategoryUpdateResult: id=" .. tostring( params.id ) .. "  result=" .. params.sysStatus  )
		if params.sysStatus == "ENUM_ItemMallGetItemsResultMsgStatus_SUCCESS" or params.sysStatus == "ENUM_ItemMallGetItemsResultMsgStatus_NOTCHANGED" then
			IM_UPDATE_SUCCESS = true
		else
			IM_Error( "Can't update item mall items list: " .. params.sysResult )
		end
	end	
end

function IM_OnItemMallAccountUpdateResult( params )
	IM_Log( "OnItemMallAccountUpdateResult: result=" .. params.sysStatus )
end

function IM_OnItemMallCanNotBuyItems( params )
	for index, itemId in params do
		if IM_ITEM_ID == itemId then
			IM_Error( "Can not buy item mall: Wrong id or not updated items list. itemId=" .. tostring( itemId ))
		end
	end
end

function IM_OnItemMallBuyResult( params )
	StopPrivateTimer()
	if params.sysStatus == "ENUM_ItemMallBuyResultMsgStatus_SUCCESS" then
		StartPrivateCheckTimer( 10000, IM_CheckCountItems, nil, IM_Error, "Item bought in item mall, bot not added to inventory", IM_Done )
	else
		IM_Error( "Can not buy item in item mall: " .. params.sysStatus )
	end
end
