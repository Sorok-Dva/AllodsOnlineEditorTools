
 
--
-- Global vars   
--

Global( "NPC_NAME", "Tests/Maps/Test/Instances/QuestGiver_TalkWithMe.(MobWorld).xdb" )
Global( "NPC_ID", nil )
Global( "TIMER_ALIVE", true )
Global( "TIMER_CONST", 2000 )
Global( "TIMER_NUM_ALIVE", 2000 )
Global( "DIST", 0 )
Global( "TIMER", false )
Global( "TIMER_NUM", 0 )
Global( "CODE", nil )
Global( "TEST_NAME", "Take Quest" )
Global( "QUEST_NAME", "World/Quests/Test/TalkWithMe/TalkWithMe.xdb" )
Global( "COUNT", 0 )

--
-- event handlers
--

-- EVENT_DEBUG_TIMER

function OnDebugTimer( params )	
    if TIMER then
		if TIMER_NUM > 0 then
		   TIMER_NUM = TIMER_NUM - 1
		else
		   TIMER = false
		   if NPC_ID ~= nil then
		      qaMission.DisintegrateMob( NPC_ID )  
		   end
		   missionError(TEST_NAME, CODE)
		   SendExitEvent()
		end
	end
	
	if TIMER_ALIVE then
		if TIMER_NUM_ALIVE > 0 then
		   TIMER_NUM_ALIVE = TIMER_NUM_ALIVE - 1
		else
		   TIMER_ALIVE = false
		   if NPC_ID ~= nil then
		      qaMission.DisintegrateMob( NPC_ID )
		   end
		   missionError(TEST_NAME,"Shard is dead" )
		   SendExitEvent()
		end
	end
end

-- EVENT_AVATAR_CREATED

function OnAvatarCreated( params )
   ParamsToConsole(params, "EVENT_AVATAR_CREATED")
   debugShard.RequestIsShardAlive()    
   local pos = debugMission.UnitGetPos( avatar.GetId() )
   local dir = debugMission.UnitGetDir( avatar.GetId() )
   local npcPos = PositionAtDistance(pos, dir, DIST)
   local npc = qaMission.SummonMob( NPC_NAME, "/Tests/Maps/Lua/MapResource.xdb", npcPos, dir )
end

-- EVENT_UNIT_SPAWNED

function OnUnitSpawned( params )
    ParamsToConsole(params, "EVENT_UNIT_SPAWNED")
	local name = qaMission.UnitGetXDB( params.unitId ) 	
	local dead = unit.IsDead( params.unitId )
	if name == NPC_NAME and not dead then
	    NPC_ID = params.unitId
		avatar.SelectTarget(params.unitId)
	end
end

-- EVENT_AVATAR_TARGET_CHANGED

function OnAvatarTargetChanged( params )
    common.LogInfo( "TARGET_CHANGED" )
   if COUNT == 0 then
      if params.unitId == NPC_ID then
		  COUNT = 1
          avatar.StartInteract( NPC_ID )
      end
   end
end

-- EVENT_TALK_STARTED

function OnTalkStarted( params )
    common.LogInfo( "TALK_STARTED" )
   avatar.RequestInteractions()
   TIMER = true
   TIMER_NUM = TIMER_CONST
   CODE = "Cant start interact"
end

-- EVENT_INTERACTION_STARTED   

function OnInteractionStarted( params )
   common.LogInfo( "INTERACTION_STARTED" )   
   TIMER_NUM = TIMER_CONST     
   local questTable = avatar.GetAvailableQuests()
   if questTable == nil then
      missionError(TEST_NAME, "Cant get availiable quests" )
      qaMission.DisintegrateMob( NPC_ID )
	  SendExitEvent()
   else          
      local idQuest =  GetQuestIdByName( QUEST_NAME )
      local questInfo = avatar.GetQuestInfo( idQuest )
      common.LogInfo( "ID_QUEST"..tostring( idQuest ) )         
      avatar.AcceptQuest( idQuest )
      CODE = "Cant accept quest"
   end           
end

-- EVENT_QUEST_RECEIVED
function OnQuestReceived( params )
   common.LogInfo( "QUEST_RECEIVED" )
   TIMER = false      
   qaMission.DisintegrateMob( NPC_ID )
   TIMER_NUM = TIMER_CONST
   CODE = "Cant disintegrate npc "
end

-- EVENT_UNIT_DESPAWNED

function OnUnitDespawned( params )
   ParamsToConsole(params, "EVENT_UNIT_DESPAWNED")
   if params.unitId == NPC_ID then
      TIMER = false	  
      Success( TEST_NAME )
      SendExitEvent()
   end
end

-- EVENT_DEBUG_SUMMON_MOB_OK

function OnSummonMobOk( params )
	ParamsToConsole(params, "EVENT_DEBUG_SUMMON_MOB_OK")
end

-- EVENT_DEBUG_SUMMON_MOB_FAILED

function OnSummonMobFailed(params)
	ParamsToConsole(params, "EVENT_DEBUG_SUMMON_MOB_FAILED")
	CODE = "Vendor Summon Failed"
	missionError(TEST_NAME,CODE)
	SendExitEvent()
end

-- EVENT_DEBUG_SHARD_IS_ALIVE

function OnDebugShardIsAlive( params )      
   if params.shardAlive then
	  TIMER_NUM_ALIVE = TIMER_CONST
	  debugShard.RequestIsShardAlive()
   end
end

--
-- main initialization function            
--

function Init()   
   local login = {login = "quests", pass = "", avatar = "Take"}
   InitLoging(login)
   common.RegisterEventHandler( OnDebugTimer, "EVENT_DEBUG_TIMER" )
   common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
   common.RegisterEventHandler( OnSummonMobOk, "EVENT_DEBUG_SUMMON_MOB_OK" )
   common.RegisterEventHandler( OnAvatarTargetChanged, "EVENT_AVATAR_TARGET_CHANGED" )
   common.RegisterEventHandler( OnTalkStarted, "EVENT_TALK_STARTED" )
   common.RegisterEventHandler( OnInteractionStarted, "EVENT_INTERACTION_STARTED" )
   common.RegisterEventHandler( OnSummonMobFailed, "EVENT_DEBUG_SUMMON_MOB_FAILED" )
   common.RegisterEventHandler( OnDebugShardIsAlive, "EVENT_DEBUG_SHARD_IS_ALIVE" )
   common.RegisterEventHandler( OnUnitSpawned, "EVENT_UNIT_SPAWNED" )
   common.RegisterEventHandler( OnUnitDespawned, "EVENT_UNIT_DESPAWNED" )
   common.RegisterEventHandler( OnQuestReceived, "EVENT_QUEST_RECEIVED" )     
end


--
-- main initialization
--

Init()


