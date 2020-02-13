

--
--------- EVENTS -------------------------------------------------------------
--

-- EVENT_AVATAR_CREATED

function OnAvatarCreated( params )       
    debugMission.AvatarLearnSpell( "Mechanics/Spells/Cheats/Dmg70/spell.xdb" )      
end

-- EVENT_SPELLBOOK_ELEMENT_ADDED

function OnSpellbookElementAdded( params )
     LogInfo( "EVENT_SPELLBOOK_ELEMENT_ADDED" )
     LogInfo( tostring( params.id ) ) 
end



--
-- main initialization function --------------------------------------------------------
--

function InitGroupChannelingChild()
    common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
    common.RegisterEventHandler( OnSpellbookElementAdded, "EVENT_SPELLBOOK_ELEMENT_ADDED" )         
end

InitGroupChannelingChild()
