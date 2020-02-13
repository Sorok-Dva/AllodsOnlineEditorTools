-- author: Liventsev Andrey, date: 14.07.2008, bug#34553
-- Ѕиблиотека дл€ выполнени€ квестов типа проводить npc
-- ¬се что требуетс€ - вызвать метод FollowMob с параметрами
-- —крипт провер€ет состо€ние квеста. ≈сли ready_to_return - запускает ф-цию из параметров

Global( "QFM_PASS_FUNCTION", nil )
Global( "QFM_ERROR_FUNCTION", nil )
Global( "QFM_MOB_ID", nil )

Global( "QFM_MOB_LAST_POSITION", nil )
Global( "QFM_FIRE_BALL", "Mechanics/Spells/Cheats/AreaOfDeath/Spell01.xdb" )

-- в момент вызова   должны находитьс€ р€дом с мобом с уде начатым заданием на сопровождение
-- признак завершени€ квеста - моб остановилс€
function FollowMob( mobId, passFunc, errorFunc )
	QFM_MOB_ID = mobId
	QFM_PASS_FUNCTION = passFunc
	QFM_ERROR_FUNCTION = errorFunc
	
	Log("")
	QFM_Log( "Start follow and defend mob" )

	local good = false
	local mobs = avatar.GetUnitList()
	for index, id in mobs do
		if id == mobId then
			good = true
			break
		end
	end
	if good == false then
		QFM_ERROR_FUNCTION( "Can't find mob. id=" .. tostring( mobId ))
	end

	qaMission.AvatarSetPos( debugMission.InteractiveObjectGetPos( QFM_MOB_ID ))
	LearnSpell( QFM_FIRE_BALL, QFM_FollowMob, QFM_ERROR_FUNCTION )
end

-- следуем за мобом и убиваем врагов
function QFM_FollowMob()
	local list = debugMission.UnitGetAggroList( QFM_MOB_ID )
	if list ~= nil then
		if GetTableSize( list ) > 0 then
			for id, value in list do
				if unit.IsDead( id ) == false then
					KillMob( id, QFM_FollowMob, QFM_ERROR_FUNCTION )
					return
				end	
			end
		end
	end
	
	list = debugMission.UnitGetAggroList( avatar.GetId() )
	if list ~= nil then
		if GetTableSize( list ) > 0 then
			for key, value in list do
				KillMob( key, QFM_FollowMob, QFM_ERROR_FUNCTION )
				return
			end
		end
	end
	
	MoveToNextPos()	
end

function MoveToNextPos()
	local exists = false
	local list = avatar.GetUnitList()
	for index, mobId in list do
		if mobId == QFM_MOB_ID then
			exists = true
			break
		end
	end
	
	if exists == true then
		qaMission.AvatarSetPos( debugMission.InteractiveObjectGetPos( QFM_MOB_ID ))
		StartPrivateTimer( 1000, QFM_FollowMob )
	else
		QFM_PASS_FUNCTION()
	end	
end

function QFM_Log( text )
	Log( text, "Quests.FollowMob" )
end
