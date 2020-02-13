-- Перед использованием библиотеки вызвать в событии OnAvatarCreated ф-цию InitAvatarCustomInput

function InitNoClip()
 	common.SendEvent("EVENT_ENABLE_UI_ADDON",{addon = "NoClip"})
end

function SetNoClip(set_enable)
	common.SendEvent("EVENT_SET_NO_CLIP",{func = "SET_NO_CLIP",enable = set_enable})
end
