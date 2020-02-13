
-- объ€вление общеупотребительных глобальных переменных

-- quest states
Global( "QUEST_IN_PROGRESS",	0 ) -- default
Global( "QUEST_READY_TO_RETURN", 1 )
Global( "QUEST_COMPLETED",	  2 )
Global( "QUEST_FAILED",				3 )

-- quest marks
Global( "QUEST_MARK_READY_TO_ACCEPT", 1 )
Global( "QUEST_MARK_SOON_TO_ACCEPT", 2 )
Global( "QUEST_MARK_READY_TO_GIVE", 3 )
Global( "QUEST_MARK_SOON_TO_GIVE", 4 )

-- quest counter type
Global( "QUEST_COUNT_KILL", 0 ) -- default
Global( "QUEST_COUNT_ITEM", 1 ) 
Global( "QUEST_COUNT_SPECIAL", 2 ) 

-- keyboard flags
-- can be used in combinations like (KBF_SHIFT + KBF_ALT) etc.

Global( "KBF_NONE",  0 ) -- default
Global( "KBF_SHIFT", 1 )
Global( "KBF_ALT",   2 )
Global( "KBF_CTRL",  4 )
Global( "KBF_ANY",   255 )

-- additional bind parameters

Global( "BIND_ACTIVATE_ONLY",           0 ) -- default
Global( "BIND_ACTIVATE_AND_DEACTIVATE", 1 )

-- widget alignment
Global( "WIDGET_ALIGN_LOW",    0 )
Global( "WIDGET_ALIGN_HIGH",   1 )
Global( "WIDGET_ALIGN_CENTER", 2 )
Global( "WIDGET_ALIGN_BOTH",   3 )
Global( "WIDGET_ALIGN_LOW_ABS", 4 )

-- effect types
Global( "EA_MONOTONOUS_INCREASE", 0 ) -- равномерное изменение параметра
Global( "EA_SYMMETRIC_FLASH"	, 1 ) -- эффект вспышки

-- spelldamage
Global( "PHYSICAL",  0 )
Global( "FIRE",      1 )
Global( "COLD",      2 )
Global( "LIGHTNING", 3 )
Global( "HOLY",      4 )
Global( "SHADOW",    5 )
Global( "POISON",    6 )
Global( "DISEASE",   7 )

-- damage source
Global( "DAMAGE_SOURCE_SPELL",      0 )
Global( "DAMAGE_SOURCE_DOT",	      1 )
Global( "DAMAGE_SOURCE_MAINATTACK", 2 )
Global( "DAMAGE_SOURCE_OFFATTACK",  3 )
Global( "DAMAGE_SOURCE_OTHER",      4 )

Global( "RACE_HUMANOID",  0 )
Global( "RACE_BEAST",     1 )
Global( "RACE_UNDEAD",    2 )
Global( "RACE_GIANT",     3 )
Global( "RACE_DRAGON",    4 )
Global( "RACE_ELEMENTAL", 5 )
Global( "RACE_DEMON",     6 )
Global( "RACE_ABERRATION",7 )

Global( "SEX_UNKNOWN",  0 )
Global( "SEX_MALE",  1 )
Global( "SEX_FEMALE",  2 )

-- player or mob mana type
Global( "MANA_TYPE_MANA", 0 )
Global( "MANA_TYPE_ENERGY", 1 )
Global( "MANA_TYPE_HONOR", 2 )

Global( "ACTION_RESULT_UNKNOWN", 0 )
Global( "ACTION_FAILED_FIZZLED", 1 )
Global( "ACTION_FAILED_COOLDOWN", 2 )
Global( "ACTION_FAILED_DISABLED", 3 )
Global( "ACTION_FAILED_TOO_FAR", 4 )
Global( "ACTION_FAILED_NOT_IN_GROUP", 5 )
Global( "ACTION_FAILED_IMMUNE", 6 )
Global( "ACTION_FAILED_NOT_IN_FRONT", 7 )
Global( "ACTION_FAILED_NO_LOS", 8 )
Global( "ACTION_FAILED_NO_PATH", 9 )
Global( "ACTION_FAILED_NO_TARGET", 10 )
Global( "ACTION_FAILED_NO_TARGET_POINT", 11 )
Global( "ACTION_FAILED_OCCUPIED", 12 )
Global( "ACTION_FAILED_RESISTED", 13 )
Global( "ACTION_FAILED_NOT_FRIEND", 14 )
Global( "ACTION_FAILED_NOT_ENEMY", 15 )
Global( "ACTION_FAILED_BARRIER_IN_NOT_ACTIVE", 16 )
Global( "ACTION_FAILED_CANNOT_TAKE_ITEM", 17 )
Global( "ACTION_FAILED_WRONG_CHARACTER_CLASS", 18 )
Global( "ACTION_FAILED_ITEM_COUNT_TOO_SMALL", 19 )
Global( "ACTION_FAILED_ITEM_COUNT_TOO_BIG", 20 )
Global( "ACTION_FAILED_CREATURE_RACE", 21 )
Global( "ACTION_FAILED_NOT_EQUIPPED", 22 )
Global( "ACTION_FAILED_NO_ITEM", 23 )
Global( "ACTION_FAILED_NOT_IN_SCRIPT_ZONE", 24 )
Global( "ACTION_FAILED_NOT_MANA_CASTER", 25 )
Global( "ACTION_FAILED_NOT_ENERGY_USER", 26 )
Global( "ACTION_FAILED_WRONG_MOB_WORLD", 27 )
Global( "ACTION_FAILED_NOT_IN_COMBAT", 28 )
Global( "ACTION_FAILED_IN_COMBAT", 29 )
Global( "ACTION_FAILED_CANNOT_STRIKE", 30 )
Global( "ACTION_FAILED_TOO_CLOSE", 31 )
Global( "ACTION_FAILED_NO_SHIELD", 32 )
Global( "ACTION_FAILED_NO_MAINHAND_WEAPON", 33 )
Global( "ACTION_FAILED_NOT_ENOUGH_MANA", 34 )
Global( "ACTION_FAILED_NOT_ENOUGH_ENERGY", 35 )
Global( "ACTION_FAILED_NO_BUFF", 36 )
Global( "ACTION_FAILED_NOT_ENOUGH_DEFENCE_COMBO_POINT", 37 )
Global( "ACTION_FAILED_NOT_ENOUGH_OFFENCE_COMBO_POINT", 38 )
Global( "ACTION_FAILED_USER_MOVE", 39 )
Global( "ACTION_FAILED_USER_CANCEL", 40 )
Global( "ACTION_FAILED_INSTABILITY_STUNNED", 41 )
Global( "ACTION_BACKFIRE", 42 )
Global( "ACTION_BALEFUL_BACKFIRE", 43 )
Global( "ACTION_MANA_BURN", 44 )
Global( "ACTION_STARTED", 45 )
Global( "ACTION_LAUNCHED", 46 )
Global( "ACTION_FAILED_EVADED", 47 )
Global( "ACTION_FAILED_LOOTABLE_OCCUPIED", 48 )
Global( "ACTION_FAILED_NOT_ENOUGH_HONOR", 49 )
Global( "ACTION_FAILED_NO_RANGED_WEAPON", 50 )

-- action effects
Global( "EFFECT_TYPE_UNKNOWN", 0 )
Global( "EFFECT_TYPE_COOLDOWN_STARTED", 1 )
Global( "EFFECT_TYPE_COOLDOWN_FINISHED", 2 )

-- dress slots
Global( "DRESS_SLOT_HELM", 0 )
Global( "DRESS_SLOT_ARMOR", 1 )
Global( "DRESS_SLOT_PANTS", 2 )
Global( "DRESS_SLOT_BOOTS", 3 )
Global( "DRESS_SLOT_MANTLE", 4 )
Global( "DRESS_SLOT_GLOVES", 5 )
Global( "DRESS_SLOT_BRACERS", 6 )
Global( "DRESS_SLOT_BELT", 7 )
Global( "DRESS_SLOT_RING1", 8 )
Global( "DRESS_SLOT_RING2", 9 )
Global( "DRESS_SLOT_EARRINGS", 10 )
Global( "DRESS_SLOT_NECKLACE", 11 )
Global( "DRESS_SLOT_CLOAK", 12 )
Global( "DRESS_SLOT_SHIRT", 13 )
Global( "DRESS_SLOT_MAINHAND", 14 )
Global( "DRESS_SLOT_OFFHAND", 15 )
Global( "DRESS_SLOT_RANGED", 16 )
Global( "DRESS_SLOT_AMMO", 17 )
Global( "DRESS_SLOT_TABARD", 18 )
Global( "DRESS_SLOT_TRINKET", 19 )
Global( "DRESS_SLOT_UNDRESSABLE", 20 )
Global( "DRESS_SLOT_ONEHANDED", 21 )
Global( "DRESS_SLOT_TWOHANDED", 22 )
Global( "DRESS_SLOT_RING", 23 )

Global( "ITEM_QUALITY_JUNK", 0 )
Global( "ITEM_QUALITY_COMMON", 1 )
Global( "ITEM_QUALITY_UNCOMMON", 2 )
Global( "ITEM_QUALITY_RARE", 3 )
Global( "ITEM_QUALITY_EPIC", 4 )

Global( "EQUIP_RESULT_SUCCESS", 0 )
Global( "EQUIP_RESULT_UNKNOWN", 1 )
Global( "EQUIP_FAILED_UNDRESSABLE", 2 )
Global( "EQUIP_FAILED_WRONG_SLOT", 3 )
Global( "EQUIP_FAILED_WRONG_CHARACTER_CLASS", 4 )
Global( "EQUIP_FAILED_WRONG_CREATURE_LEVEL", 5 )
Global( "EQUIP_FAILED_NO_SPACE", 6 )


-- login result codes
Global( "LOGINRESULT_LOGINSUCCESS", 0 )
Global( "LOGINRESULT_AUTHSERVICENOTFOUND", 1 )
Global( "LOGINRESULT_OTHERCLIENTINGAME", 2 )
Global( "LOGINRESULT_WRONGVERSION", 3 )
Global( "LOGINRESULT_SERIALIZATIONERROR", 4 )
Global( "LOGINRESULT_UNEXPECTEDDATA", 5 )
Global( "LOGINRESULT_CLIENTNOTFOUND", 6 )

-- event ON_LOGIN_END result Strings
Global( "LOGIN_END_LOGIN_SUCCESS", "ENUM_LoginResult_LOGINSUCCESS" )
Global( "LOGIN_END_AUTHSERVICENOTFOUND", "ENUM_LoginResult_AUTHSERVICENOTFOUND" )
Global( "LOGIN_END_OTHERCLIENTINGAME", "ENUM_LoginResult_OTHERCLIENTINGAME" )
Global( "LOGIN_END_WRONGVERSION", "ENUM_LoginResult_WRONGVERSION" )
Global( "LOGIN_END_ERROR", "ENUM_LoginResult_ERROR" )
Global( "LOGIN_END_UNEXPECTEDDATA", "ENUM_LoginResult_UNEXPECTEDDATA" )
Global( "LOGIN_END_CLIENTNOTFOUND", "ENUM_LoginResult_CLIENTNOTFOUND" )
Global( "LOGIN_END_WRONGPASSWORD", "ENUM_LoginResult_WRONGPASSWORD" )
Global( "LOGIN_END_BANNED", "ENUM_LoginResult_BANNED" )


-- disconnect codes
Global( "ECS_OK", 1 )
Global( "ECS_NOT_CONNECTED", 2 )
Global( "ECS_LOST", 3 )
Global( "ECS_KICKED", 4 )
Global( "ECS_WRONG_VERSION", 5 )
Global( "ECS_CANT_RESOLVE_HOSTNAME", 6 )
Global( "ECS_CANT_CREATE_SOCKET", 7 )
Global( "ECS_CANT_CONNECT", 8 )
Global( "ECS_TIMEOUT_EXPIRED", 9 )
Global( "ECS_CLOSED", 10 )
Global( "ECS_ERROR", 11 )


-- action types
Global( "ACTION_TYPE_UNKNOWN", 0 )
Global( "ACTION_TYPE_SPELL", 1 )
Global( "ACTION_TYPE_ITEM", 2 )

-- spell types
Global( "SPELL_TYPE_SELF", 0 )
Global( "SPELL_TYPE_CURRENT_TARGET", 1 )
Global( "SPELL_TYPE_POINT", 2 )

-- visible objects index
Global( "VIS_OBJ_QUEST_MARK", 0 )
Global( "VIS_OBJ_LOOT", 1 )
Global( "VIS_OBJ_LEVEL_UP_MARK", 2 )

-- visible objects position
Global( "VIS_OBJ_POS_DEFAULT", 0 )
Global( "VIS_OBJ_POS_BOTTOM", 1 )
Global( "VIS_OBJ_POS_CENTER", 2 )
Global( "VIS_OBJ_POS_UP", 3 )

-- mob qualities (eliteness)
Global( "UNIT_QUALITY_COMMON", 0 )
Global( "UNIT_QUALITY_ELITE", 1 )
Global( "UNIT_QUALITY_FLAVOR_ELITE", 2 )
Global( "UNIT_QUALITY_MINI_BOSS", 3 )

-- bag modes
Global( "BAG_MODE_DEFAULT", 0 )
Global( "BAG_MODE_VENDOR", 1 )
Global( "BAG_MODE_ALCHEMY", 2 )


-- drag & drop
Global( "DND_INVALID_ID", -1 )
Global( "DND_CONTAINER_STEP", 1000 )
Global( "DND_EQUIPMENT", 0 )
Global( "DND_INVENTORY", 1 )
Global( "DND_ACTIONBAR", 2 )
Global( "DND_SPELLBOOK", 3 )
Global( "DND_VENDOR", 4 )
Global( "DND_BANK", 5 )
Global( "DND_WORLD", 6 )

-- chat
Global( "CHAT_TYPE_CHAT", 0 )
Global( "CHAT_TYPE_WHISPER", 1 )

-- chat failed
Global( "CHAT_FAILED_NOT_EXISTENT", 0 )
Global( "CHAT_FAILED_NOT_LOGGED_IN", 1 )

-- leave mission
Global( "LEAVE_MISSION_NORMAL", 0 )
Global( "LEAVE_MISSION_ENTER_NOT_ALLOWED", 1 )
Global( "LEAVE_MISSION_INVALID_AVATAR", 2 )
Global( "LEAVE_MISSION_INTERNAL_ERROR", 3 )
Global( "LEAVE_MISSION_ANOTHER_AVATAR_IN_GAME", 10 )

-- pet movement type
Global( "PET_MOVE_FOLLOW", 0 )
Global( "PET_MOVE_STAY", 1 )

-- pet aggro type
Global( "PET_AGGRO_AGGRESIVE", 0 )
Global( "PET_AGGRO_DEFENSIVE", 1 )
Global( "PET_AGGRO_PASSIVE", 2 )

-- PvP Flag
Global( "PVP_NONE", 0 )
Global( "PVP_FACTION", 1 )
Global( "PVP_ALL", 2 )


-- ValuedObject type
Global( "VAL_OBJ_TYPE_UNKNOWN", 0 )
Global( "VAL_OBJ_TYPE_ITEM", 1 )
Global( "VAL_OBJ_TYPE_SPELL", 2 )
Global( "VAL_OBJ_TYPE_ABILITY", 3 )
Global( "VAL_OBJ_TYPE_CREATURE", 4 )
Global( "VAL_OBJ_TYPE_PLAYER", 5 )
