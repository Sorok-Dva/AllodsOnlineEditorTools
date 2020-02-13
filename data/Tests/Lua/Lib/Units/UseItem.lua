-- ф-ция для использования предмета из инвентря

-- есть метод для использования на цель (для этого используется SelectTarget и AvatarCustomInput для поворота к мобу)
-- если моб стоит слишком далеко - вызовется funcError с текстом ошибки
-- перед использованием вызвать InitAvatarCustomInput()

Global( "USE_ITEM_FUNC_PASS",  nil )
Global( "USE_ITEM_FUNC_ERROR", nil )
Global( "USE_ITEM_MOB_ID", nil )
Global( "USE_ITEM_ITEM_NAME", nil )
Global( "USE_ITEM_USE_TIME", nil )

function UseItem( itemName, useTime, funcPass, funcError )
	UseItemLog( "start using item" )

    USE_ITEM_ITEM_NAME = itemName
	USE_ITEM_USE_TIME = useTime
    USE_ITEM_FUNC_PASS = funcPass
    USE_ITEM_FUNC_ERROR = funcError	

    UseItemUseItem()
end

function UseItemToTarget( mobId, itemName, useTime, funcPass, funcError )
	UseItemLog( "start using item to target" )
	
    USE_ITEM_MOB_ID = mobId
    USE_ITEM_ITEM_NAME = itemName
	USE_ITEM_USE_TIME = useTime
    USE_ITEM_FUNC_PASS = funcPass
    USE_ITEM_FUNC_ERROR = funcError	

	local newPos = GetPositionAtDistance( debugMission.InteractiveObjectGetPos( USE_ITEM_MOB_ID ), avatar.GetDir() - math.pi/2, 0.5 )
	qaMission.AvatarSetPos( newPos )
	StartPrivateTimer( 2000, UseItemSelectTarget )
end

function UseItemSelectTarget()
	SelectTarget( USE_ITEM_MOB_ID, UseItemBeforeUsing, USE_ITEM_FUNC_ERROR )
end

function UseItemBeforeUsing()
	local mobPos = debugMission.InteractiveObjectGetPos( USE_ITEM_MOB_ID )
	local myPos = avatar.GetPos()
	
	if GetDistanceBetweenPoints( mobPos, myPos, true ) > 0.1 then
		qaMission.AvatarSetScriptControl( true )
		local dir = GetAngleBetweenPoints( mobPos, myPos )
		local moveParams = {
			deltaX = 0,
			deltaY = 0,
			deltaZ = 0,
			yaw = dir
		}
		qaMission.AvatarMoveAndRotate( moveParams )
		
		StartPrivateTimer( 1000, UseItemUseItem )
	else
		UseItemUseItem()
	end	
end

function UseItemUseItem()
	local slot = GetItemSlot( USE_ITEM_ITEM_NAME )
	if slot == nil then
		USE_ITEM_FUNC_ERROR( "Avatar does not have an required item (" .. USE_ITEM_ITEM_NAME .. ")" )
	else 
		UseItemLog( "using item... slot=" .. tostring( slot ))
		avatar.InventoryUseItem( slot )
		StartTimer( USE_ITEM_USE_TIME, USE_ITEM_FUNC_PASS )
	end
end

function UseItemLog( text )
	Log( text, "Units.UseItem" )
end
