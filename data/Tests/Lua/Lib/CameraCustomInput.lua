-- Перед использованием библиотеки вызвать в событии OnAvatarCreated ф-цию InitAvatarCustomInput
-- Перед использованием ф-ций движения вызвать ACIEnable( true )

function CCIEnable(set_enable)
	common.SendEvent("EVENT_CAMERA_CUSTOM_INPUT",{func = "CCI_ENABLE",enable = set_enable})
end

function CCISetDir(set_angle)
	common.SendEvent("EVENT_CAMERA_CUSTOM_INPUT",{func = "CCI_SETANGLE",angle = set_angle})
end

function CCIMove( position )
	common.SendEvent("EVENT_CAMERA_CUSTOM_INPUT",{func = "CCI_SETPOSITION",pos = position})
end

function InitCameraCustomInput()
 	common.SendEvent("EVENT_ENABLE_UI_ADDON",{addon = "CameraCustomInput"})
end
