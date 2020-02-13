Global( "TEST_NAME", "UnitTests.GetAvailiableQuests" )

Global( "NPC_NAME", "Tests/Maps/Test/Instances/QuestGiver_Kill_N_Targets.(MobWorld).xdb" )
Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )

Global( "EVENT_PASSED", false )

function BeforeStartInteract( unitId )
	avatar.StartInteract( unitId )
	StartTimer( 5000, ErrorFunc, "Event OnTalkStarted did not come" )
end

function Done()
	DisintagrateMob( NPC_NAME )
	Success( TEST_NAME )
end

function ErrorFunc( text )
	DisintagrateMob( NPC_NAME )
	Warn( TEST_NAME, text )
end


----------------------------- EVENTS -----------------------------------

function OnAvatarCreated()
	StartTest( TEST_NAME )

	local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
	SummonMob( NPC_NAME, MAP_RESOURCE, newPos, 0, BeforeStartInteract, ErrorFunc )
end

function OnTalkStarted( params )
	StartTimer( 5000, ErrorFunc, "Event OnInteractionStarted did not come" )
	avatar.RequestInteractions()
end

function OnInteractionStarted( params )
	StopTimer()
	if EVENT_PASSED == false then
		EVENT_PASSED = true
		if params.isQuestGiver == true then
			local list = avatar.GetAvailableQuests()
			if GetTableSize( list ) == 0 then
				ErrorFunc( "Npc doesn't have a quests" )
			else
				Log( "available quest: " )
				for index, id in list do
					Log( "  name: " .. avatar.GetQuestInfo( id ).debugName )
				end
				Done()
			end		
		else
			ErrorFunc( "Npc is not a quest giver" )
		end
	end	
end

function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging(login)

	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	common.RegisterEventHandler( OnTalkStarted, "EVENT_TALK_STARTED" )
	common.RegisterEventHandler( OnInteractionStarted, "EVENT_INTERACTION_STARTED" )

end

Init()