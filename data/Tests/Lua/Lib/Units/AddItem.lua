-- author: Liventsev Andrey; date: 08.12.2008

Global( "ADD_ITEM_ITEM_NAME", nil )
Global( "ADD_ITEM_ITEM_COUNT", nil )
Global( "ADD_ITEM_PASS_FUNCTION", nil )
Global( "ADD_ITEM_ERROR_FUNCTION", nil )

Global( "ADD_ITEM_START_COUNT_ITEM", nil )

-- Добавляет итем в рюкзак аватара. 
function AddItem( itemName, itemCount, passFunc, errorFunc )
	ADD_ITEM_ITEM_NAME = itemName
	ADD_ITEM_ITEM_COUNT = itemCount
	ADD_ITEM_START_COUNT_ITEM = GetCountItem( ADD_ITEM_ITEM_NAME )
	
	ADD_ITEM_PASS_FUNCTION = passFunc
	ADD_ITEM_ERROR_FUNCTION = errorFunc
	
	for i = 1, ADD_ITEM_ITEM_COUNT do 
		Log( "adding item:" .. ADD_ITEM_ITEM_NAME .. "  count:" .. tostring(ADD_ITEM_ITEM_COUNT), "Units.AddItem" )
		qaMission.AvatarCreateItem( ADD_ITEM_ITEM_NAME )
	end

	local strError = "Can't add item: " .. tostring(GetCountItem( ADD_ITEM_ITEM_NAME )) .. " != " .. tostring(ADD_ITEM_START_COUNT_ITEM) .. "+" .. tostring(ADD_ITEM_ITEM_COUNT)
	StartPrivateCheckTimer( 5000, AI_CheckCountItems, nil, ADD_ITEM_ERROR_FUNCTION, strError, ADD_ITEM_PASS_FUNCTION, nil )
end
function AI_CheckCountItems()
	if GetCountItem( ADD_ITEM_ITEM_NAME ) == ADD_ITEM_START_COUNT_ITEM + ADD_ITEM_ITEM_COUNT then
		Log( "done", "Units.AddItem" )
	end
	return GetCountItem( ADD_ITEM_ITEM_NAME ) == ADD_ITEM_START_COUNT_ITEM + ADD_ITEM_ITEM_COUNT
end
