Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )
Global( "TEST_NAME", "Test Spells" )
Global( "g_Item", nil )
Global( "g_sEnemyName", "Tests/Mobs/AllLevels/TestSatyr/Satyr4.xdb" )
Global( "g_sFriendName", "Characters/Kania_female/Instances/ArchipelagoLeague1/NPC1_3.xdb" )
Global( "g_nLevel", nil )
Global( "g_nNormalize", nil )
Global( "g_nDistance", nil )
Global( "g_SpellsArray", nil )
Global( "g_nAvatarID", nil )
Global( "g_nAEAngle", nil )
Global( "g_nSpellIterator", 1 )
Global( "g_sTargetSide", nil )
Global( "g_nSummonIter", 0 )
Global( "g_bTestSpellUseLearn", false )
Global( "g_nFirstMobID", nil )
Global( "g_nSecondMobID", nil )
Global( "g_sTestSpellName", nil )
Global( "g_sClassAvatar", "AutoWarrior" )

function LogConstructor( sMsg, bSuccess )
	if ( bSuccess == nil ) then
		bSuccess = false
	end
	local srStr = "Try"
	if( bSuccess == true )then
		srStr = "Success"
	end
	Log( "						"..srStr.." "..sMsg )
end

function CastTarget()
	if( ( g_sTargetSide == "ToEnemy" ) or ( g_sTargetSide == "ToFriend" ) ) then
		return g_nFirstMobID		
	elseif( g_sTargetSide == "ToSelf" ) then
		return g_nAvatarID
	end
	return nil
end

function CastNameTarget()
	if ( g_sTargetSide == "ToEnemy" )  then
		return g_sEnemyName		
	elseif( g_sTargetSide == "ToFriend" ) then
		return g_sFriendName
	end
	return nil
end

function ErrorFunc( text )
	StartTimer( 3000, ErrorFunc2, text )
end

function ErrorFunc2( text )
	Warn( TEST_NAME, text )
end

function OnClean( params )
	LogConstructor( "On Clean", true )
	LevelUp( g_nLevel, nil, PassLevelUp, ErrorFunc )
end

function OnAvatarTeleported()
	LogConstructor( "On Teleported", true )
	CleanPlaceInRadius( { ActionFunc = OnClean } )		
end

function PassLevelUp()
	Normalize( { normalize = g_nNormalize }, NormalizePass, NormalizeError )	
end

function PrepareAttachBuff()
	g_nSpellIterator = 1
	LogConstructor( "Prepare ResetPrepareDuration" )
	AttachBuff( { szBuffName = "Mechanics/Spells/Cheats/ResetPrepareDuration/Buff.xdb", nUnitID = g_nAvatarID }, SummonMobs, ErrorFunc )		
end

function GoodBaseSpellCast()
	LearnSpells( true )
end

function AfterCast()
	LogConstructor( "Cast SPELLS", true )
	LogConstructor( "After Base Cast" )		
	DeClick( { szBuffName = "Mechanics/Spells/Cheats/ResetPrepareDuration/Buff.xdb", nUnitID = g_nAvatarID }, Selection, ErrorFunc )			
end

function GoPing()
	LogConstructor( "Ping" )
	Ping( { passFunc = OnPing, passParams = "OnPing", failFunc = ErrorFunc } )
end

function GoodSpellCast()
	LogConstructor( "Good Cast Test Spell", true )
	GoPing()	
end

function OnPing( param )
	LogConstructor( "Ping", true )	
	local str = "Success "..TEST_NAME
	CleanPlaceInRadius( { ActionFunc = Success, ActionParams = str } )		
end

function BadCastSpell( params )
	ErrorFunc2( "Bad Cast Spell" )
end

--[[function PrepareCast()
	local nSrcID = g_nAvatarID
	local nDstID = CastTarget()	
	LogConstructor( "Target ID: "..tostring( nDstID ).." SrcID: "..tostring( nSrcID ) )
	local effects = {}
		table.insert( effects, {
		type = EFFECT_DAMAGE,
		damageSource = CHECKDMG_SOURCE_SPELL,
		targetId = nDstID,
		sourceId = nSrcID }
		)
		return effects		
end]]

function CastTestSpell()
	if ( g_sTestSpellName == nil )then
		ErrorFunc2( "Can`t Find Test Spell Name " )
		return
	end
	local nDst = CastTarget()
	if ( nDst == nil ) then
		ErrorFunc2( "Can`t Cast Dst Entity" )
		return
	end
	local SPELL_INDEX = GetSpellId( g_sTestSpellName )
	if( SPELL_INDEX == nil )then
		ErrorFunc2( "Can`t Find Learn Spell "..tostring( g_sTestSpellName ) )
		return
	end
	CastSpell20Times( SPELL_INDEX , nDst, 10000, GoodSpellCast, BadCastSpell )				
end

function OnSelected()
	CastTestSpell()
end

function ErrorFuncSelect()
	--ÕÀÊ!!!!!
	local nDstID = CastTarget()
	if( nDstID == nil ) then
		ErrorFunc2( "Error Cast Target" )
	end
	SelectTarget( nDstID, OnSelected, ErrorFunc2 )
end

function Selection()
	local nDstID = CastTarget()
	if( nDstID == nil ) then
		ErrorFunc2( "Error Cast Target" )
	end
	SelectTarget( nDstID, OnSelected, ErrorFuncSelect )
end

function OnLearnSpell()
	LogConstructor( "Learn Spell Or Attach Buff", true  )				
	LearnSpells( false )
end

function LearnSpells( bCast )
	if( bCast == nil ) then
		bCast = false
	end
	local nSpellsCount = GetSizeForLogin( g_Item.spells )
	if( ( g_nSpellIterator + 1 ) == nSpellsCount )then
		if( bCast == false )then
			PrepareAttachBuff()
		else
			AfterCast()
		end		
		return
	end
	if( ( nSpellsCount == 0 ) and ( bCast == false ) ) then
		PrepareAttachBuff()
		return
	end
	
	local testSpell = g_Item.endCondition
	
	if( ( testSpell ~= nil ) and ( g_bTestSpellUseLearn == false ) and ( bCast == false ) )then
		g_sTestSpellName = debugCommon.FromWString( testSpell.type )
		if( g_sTestSpellName ) then
			LogConstructor( "Learn Test Spell "..tostring( g_sTestSpellName ) )
			g_bTestSpellUseLearn = true
			LearnSpell( g_sTestSpellName, OnLearnSpell, ErrorFunc )	
		end
		return
	end
	
	local spellType = g_Item.spells[ g_nSpellIterator ]
	if( spellType == nil )then
		LogConstructor( "Error SpellType == nil" )
		g_nSpellIterator = g_nSpellIterator + 1
		LearnSpells( bCast )
	elseif( spellType.name == nil ) then
		LogConstructor( "Error SpellType.name == nil" )
		g_nSpellIterator = g_nSpellIterator + 1
		LearnSpells( bCast )
	elseif( spellType.target == nil ) then
		common.LogInfo( "common","spellType.target == nil" )			
		LogConstructor( "No Valid Value of "..tostring( debugCommon.FromWString( spellType.name ) ) )
		g_nSpellIterator = g_nSpellIterator + 1
		LearnSpells( bCast )
	else
		g_nSpellIterator = g_nSpellIterator + 1
		local szSpellName = debugCommon.FromWString( spellType.target )
		local szType = debugCommon.FromWString( spellType.name )
		if( CastStringParam( szSpellName, true )  == false ) then
			ErrorFunc2( "Set Path( *.xdb ) for spell "..tostring( szSpellName ) )
			return
		end
		if( ( szType == "SpellSelf" ) or ( szType == "SpellTarget" ) )then
			if( bCast == false )then
				LearnSpell( szSpellName, OnLearnSpell, ErrorFunc )	
				LogConstructor( "Begin Learn Spell "..tostring( szSpellName ) )
			else
				local SPELL_INDEX = GetSpellId( szSpellName )
				if( SPELL_INDEX ~= nil )then
					local nDst = CastTarget()
					CastSpell20Times( SPELL_INDEX , nDst, 10000, GoodBaseSpellCast, ErrorFunc )		
				end
			end
		elseif( ( szType == "BuffSelf" ) or ( szType == "BuffTarget" ) )then
			if( bCast == false )then
				AttachBuff( { szBuffName = szSpellName, nUnitID = g_nAvatarID }, OnLearnSpell , ErrorFunc )
				LogConstructor( "Begin Attach Buff "..tostring( szSpellName )  )				
			else
				GoodBaseSpellCast()
			end
		end		
	end		
end

function CastSpells( params )
	LogConstructor( "Cast SPELLS" )
	LearnSpells( true )	
end

function OnSummonMob( nID )
	LogConstructor( "OnSummon Mob" )
	if( g_nAEAngle ~= nil )then
		if( g_nSummonIter > 1 ) then
			g_nSecondMobID = nID
			CastSpells()			
		else
			g_nFirstMobID = nID
			SummonMobs()						
		end
	else
		g_nFirstMobID = nID
		CastSpells()
	end
end

function SummonMobs()
	if( g_sTargetSide == "ToSelf" )then
		CastSpells()					
	end
	local name = g_sEnemyName
	if( g_sTargetSide == "ToFriend" )then
		name = g_sFriendName
	end
	g_bTestSpellUseLearn = false		
	if( g_nAEAngle ~= nil )then
		local nDir = GetAEdir( g_nAEAngle )
		local funcName = SummonMobs
		if( g_nSummonIter > 0 ) then
			nDir = nDir * -1			
		end	
		local pos = GetPositionAtDistance( avatar.GetPos(), nDir, 5 )
		SummonMob( name, MAP_RESOURCE, pos, nDir, OnSummonMob, ErrorFunc, g_nDistance )								
		g_nSummonIter = g_nSummonIter + 1
		
	else
		local pos = GetPositionAtDistance( avatar.GetPos(), -avatar.GetDir(), 5 )
		SummonMob( name, MAP_RESOURCE, pos, 0, OnSummonMob, ErrorFunc, g_nDistance )
	end	
end

function NormalizePass()
	LearnSpells()
end

function NormalizeError( params )
	ErrorFunc( "Normalize Error" )
end

function OnAvatarCreated( params )
	StartTest( TEST_NAME )
	g_nAvatarID = avatar.GetId()
	local map = debugMission.GetMap()
	local mapName = map.debugName	
	MoveToPos( {X = 100, Y = 100, Z = 0}, OnAvatarTeleported, 3000, nil, nil, nil, OnBadTeleport, nil, mapName )			
end

function OnBadTeleport( params )
	ErrorFunc2( "Bad Teleport" )
end

function CastNumParam( nParam, nLowLimit, nHiLimit, bLive )
	if( bLive == nil ) then
		bLive = false
	end
	if( nParam == nil ) then
		if( bLive == false )then
			ErrorFunc2( "Num Param not found value" )
		end
		return false
	elseif( ( nParam < nLowLimit ) or ( nParam > nHiLimit ) ) then
		if( bLive == false )then
			ErrorFunc2( "Num Param not in limit "..tostring( nParam ).." Low: "..tostring( nLowLimit ).." Hi: "..tostring( nHiLimit ) )
		end
		return false
	end
	return true
end

function CastStringParam( szParam, isXdb )
	if( szParam == nil )then
		ErrorFunc2( "Str Param not found value" )
		return false
	end
	
	if( ( isXdb ~= nil ) and ( isXdb == true ) )then
		if ( string.find( szParam, ".xdb" ) == nil ) then
			return false
		end
	end
	return true
end


function FillParams( params )
	if( ( params == nil ) or ( params.item == nil ) ) then
		return
	end	
	local value = params.item
	if( debugCommon.FromWString( value.rule ) == "level" )then
		g_nLevel = tonumber( debugCommon.FromWString( value.param ) )				
		if ( CastNumParam( g_nLevel, 2, 40 ) == false ) then
			return
		end		
	elseif ( debugCommon.FromWString( value.rule ) == "normalize" )then
		g_nNormalize = tonumber( debugCommon.FromWString( value.param ) )				
		if ( CastNumParam( g_nNormalize, 0, 2 ) == false ) then
			return
		end		
	elseif ( debugCommon.FromWString( value.rule ) == "distance" )then
		g_nDistance = tonumber( debugCommon.FromWString( value.param ) )
		if ( CastNumParam( g_nDistance, 1, 100 ) == false ) then
			return
		end		
	elseif ( debugCommon.FromWString( value.rule ) == "aeangle" )then
		g_nAEAngle = tonumber( debugCommon.FromWString( value.param ) )
		if ( CastNumParam( g_nAEAngle, 1, 90, true ) == false ) then
			return
		end
	elseif ( debugCommon.FromWString( value.rule ) == "target" )then
		g_sTargetSide = debugCommon.FromWString( value.param )
		if ( CastStringParam( g_sTargetSide ) == false ) then
			return
		end
	elseif ( debugCommon.FromWString( value.rule ) == "class" )then
		g_sClassAvatar = debugCommon.FromWString( value.param )
		if ( CastStringParam( g_sClassAvatar ) == false ) then
			return
		else
			g_sClassAvatar = "Auto"..g_sClassAvatar
		end		
	end		
end

function ParsingBaseParams()
	for i,itemElement in g_Item.conditions do
		if ( itemElement.rule == nil )	then
			LogConstructor( "Bad Item In Condition" )						
		else
			FillParams( { item = itemElement } )
		end
	end
end


function Init()
	local behavior = developerAddon.LoadTactics( 0 )
	if( ( behavior == nil ) or ( behavior[1] == nil )  )then
		ErrorFunc2( "Not Found File TestCase" )
		return
	end
	
	g_Item = behavior[1]
	
	
	if( g_Item == nil )then
		ErrorFunc2( "Not Found File Item`s" )
		return
	end	
		
	if( g_Item.conditions == nil )then
		ErrorFunc2( "Not Found Base Params" )
		return
	end
	
	ParsingBaseParams()
	
	if( FindClassTemplate ( g_sClassAvatar ) == false )then
		ErrorFunc2( "Unknown Class "..g_sClassAvatar )
		return
	else
		LogConstructor( "Valid Type "..g_sClassAvatar )
	end
	
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" ),
		create = g_sClassAvatar,
		delete = true		
	}
		
	InitLoging(login)
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()