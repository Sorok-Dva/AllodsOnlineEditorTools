-- Перед использованием библиотеки вызвать в событии OnAvatarCreated ф-цию InitAvatarCustomInput
-- Перед использованием ф-ций движения вызвать ACIEnable( true )

function ACIEnable(set_enable)
	common.SendEvent("EVENT_AVATAR_CUSTOM_INPUT",{func = "ACI_ENABLE",enable = set_enable})
end

function ACISetDir(set_yaw)
	common.SendEvent("EVENT_AVATAR_CUSTOM_INPUT",{func = "ACI_SETDIR",yaw = set_yaw})
end

function ACIMove(set_move)
	common.SendEvent("EVENT_AVATAR_CUSTOM_INPUT",{func = "ACI_MOVE",on = set_move})
end

function ACIJump(set_jump)
	common.SendEvent("EVENT_AVATAR_CUSTOM_INPUT",{func = "ACI_JUMP",on = set_jump})
end

function InitAvatarCustomInput()
 	common.SendEvent("EVENT_ENABLE_UI_ADDON",{addon = "AvatarCustomInput"})
end
