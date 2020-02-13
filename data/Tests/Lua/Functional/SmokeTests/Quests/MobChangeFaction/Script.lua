Global( "TEST_NAME", "SmokeTest.Quest.MobChangeFaction; author: Liventsev Andrey, date: 12.08.08, task 32211" )


Global( "NPC_NAME", "Tests/Maps/Test/Instances/QuestGiver_Change_Mob_World_OnItem_Use_Fraction.(MobWorld).xdb" )
Global( "QUEST_NAME", "Tests/FunctionalTests/Lua/Quests/Change_Mob_World_OnItem_Use_Fraction/Change_Mob_World_OnItem_Use_Fraction.xdb" )
Global( "MOB_NAME", "Tests/Maps/Test/Instances/Change_Mob_World_OnItem_Use_Fraction_Before.(MobWorld).xdb" )
Global( "MOB_AFTER_NAME", "Tests/Maps/Test/Instances/Change_Mob_World_OnItem_Use_Fraction_After.(MobWorld).xdb" )

Global( "ITEM_NAME", "Tests/Items/Change_Mob_World_OnItem_Use_Fraction.(ItemResource).xdb" )
Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )

Global( "COUNT_MOB", 0 )
Global( "MAX_COUNT_MOB", 5 )
Global( "CUR_MOB_ID", nil )

function SummonNPC()
	local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
	SummonMob( NPC_NAME, MAP_RESOURCE, newPos, 0, BeforeAccept, ErrorFunc )
end

function BeforeAccept( unitId )
	StartTimer( 1000, Accept, unitId )
end

function Accept( unitId )
	AcceptQuest( unitId, QUEST_NAME, ChangeFactionOfNextMob, ErrorFunc )
end

function ChangeFactionOfNextMob()
	Log()
	Log( "Quest progress: " .. tostring(COUNT_MOB) .. "/" .. tostring( MAX_COUNT_MOB ))
	if COUNT_MOB < MAX_COUNT_MOB then
		local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
		SummonMob( MOB_NAME, MAP_RESOURCE, newPos, 0, SetDamage, ErrorFunc )

	else
		Return()
	end
end

function SetDamage( mobId )
	CUR_MOB_ID = mobId
	KickMob( mobId, 20, ChangeFaction, ErrorFunc )
end

function ChangeFaction()
	Log()
	Log( "using item..." )
	Log("-----------------------" )
	Log("-----------------------" )
	Log( "mobId= " .. tostring( GetMobId( MOB_NAME )))
	if GetMobId( MOB_NAME ) ~= nil then 
		Log( "target=" .. tostring( avatar.GetTarget()))
		local pos = debugMission.InteractiveObjectGetPos( GetMobId(MOB_NAME) )
		local aPos =  debugMission.InteractiveObjectGetPos( avatar.GetId())
		Log( "distance=" .. tostring( GetDistanceBetweenPoints( pos, aPos, true )))
		
		pos = ToAbsCoord( pos )
		aPos = ToAbsCoord( aPos )
		Log( "x=" .. tostring(pos.X) .. " y=" .. tostring(pos.Y) .. " z=" ..tostring(pos.Z) )
		Log( "x=" .. tostring(aPos.X) .. " y=" .. tostring(aPos.Y) .. " z=" ..tostring(aPos.Z) )
		
	end
	Log("-----------------------" )
	Log("-----------------------" )
	
	local slot = GetItemSlot( ITEM_NAME )
	avatar.InventoryUseItem( slot )
	
	StartTimer( 4000, CheckForChangingFaction )
end

function CheckForChangingFaction()
	if GetMobId( MOB_AFTER_NAME ) ~= nil then
		Log( "faction successfullly changed" )
		DisintagrateMob( MOB_AFTER_NAME  )
		COUNT_MOB = COUNT_MOB + 1
		StartTimer( 1000, ChangeFactionOfNextMob )

	else
		ErrorFunc( "Mob did not change faction" )
	end
end

function Return()
	ReturnQuest( GetMobId( NPC_NAME ), QUEST_NAME, Done, ErrorFunc )
end


function Done()
	DisintagrateMob( NPC_NAME )
	DisintagrateMob( MOB_NAME )
	DisintagrateMob( MOB_AFTER_NAME )
	
	StartTimer( 2000, Success, TEST_NAME )
end

function ErrorFunc( text )
	DisintagrateMob( NPC_NAME )
	DisintagrateMob( MOB_NAME )
	DisintagrateMob( MOB_AFTER_NAME )

	StartTimer( 2000, ErrorFunc2, text )
end

function ErrorFunc2( text )
	Warn( TEST_NAME, text )
end


------------------------------------- EVENTS ---------------------------------------

function OnAvatarCreated()
	StartTest( TEST_NAME )
	
	ImmuneAvatar( SummonNPC, ErrorFunc )
end


function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" ),
		class = "AutoMage"
	}
	InitLoging(login)

	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()
 