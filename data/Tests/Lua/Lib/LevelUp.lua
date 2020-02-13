-- LevelUp( level, spells, funcPass, funcError ) повышает уровень и учит все возможные заклинания
-- после того как у аватара повышается уровень и заклинания выучиваются, она запускат функцию funcPass
-- в spells передаем таблицу спеллов которые ожидаете увидеть после LearnUP. xdb, или название спелла в value. таблицу заполнять через table.insert

Global("LEVEL_UP_PASS_FUNC", nil)
Global("LEVEL_UP_ERROR_FUNC", nil)
Global("LEVEL_UP_SPELLS", nil)

function LevelUp( level, spells, funcPass, funcError )
   LEVEL_UP_PASS_FUNC = funcPass
   LEVEL_UP_ERROR_FUNC = funcError
   LEVEL_UP_SPELLS = spells
   --StateLoadManagedAddon( TEST_NAME )
   StartPrivateCheckTimer( 10000, LU_CheckLevel, level, LEVEL_UP_ERROR_FUNC, "Can't level up", LU_LearnSpell, nil )
   qaMission.AvatarLevelUp( level ) 
end
function LU_CheckLevel( lvl )
	return lvl <= unit.GetLevel( avatar.GetId()) 
end

function LU_LearnSpell()
	if LEVEL_UP_SPELLS ~= nil and GetTableSize(LEVEL_UP_SPELLS) > 0 then
		--StartPrivateCheckTimer( 10000, LU_CheckSpellBook, nil, LEVEL_UP_ERROR_FUNC, "Can't learn spells after level up", LEVEL_UP_PASS_FUNC, nil )	    
		StartPrivateTimer( 2000, LEVEL_UP_PASS_FUNC )
		qaMission.AvatarLevelUp()
	else		
		StartPrivateTimer( 2000, LEVEL_UP_PASS_FUNC )
	end	
end
function LU_CheckSpellBook()
	local spellBook = avatar.GetSpellBook()
	local numSpells = 0
	common.LogInfo( "debug", "TYPE AR_PRE "..tostring( type(LEVEL_UP_SPELLS) ))
	for k in LEVEL_UP_SPELLS do
        numSpells = numSpells + 1
	end

	common.LogInfo( "debug", "TYPE SB "..tostring( type(spellBook) ))
 	for i, idSpell in spellBook do
    	local spellInfo = avatar.GetSpellInfo( idSpell )
		common.LogInfo( "debug", "TYPE AR "..tostring( type(LEVEL_UP_SPELLS) ))
		for j, nameSpell in LEVEL_UP_SPELLS do
			if string.find( spellInfo.debugName, nameSpell ) then
			    table.remove( LEVEL_UP_SPELLS, j )
				numSpells = numSpells - 1
			    common.LogInfo( "debug", "Spell learned " .. nameSpell .. " to learn " .. tostring( numSpells ))
    		end
		end
		if numSpells == 0 then			
		    return true
		end
	end	
	return false
end
