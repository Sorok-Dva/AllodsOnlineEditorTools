--Весьма полезная библиотека
Global( "NORMALIZE_ERROR_FUNC", nil )
Global( "NORMALIZE_PASS_FUNC", nil )
Global( "CLEAN_PARAMS", nil )
Global( "g_ListClasses", { "AutoNecromancer", "AutoDruid", "AutoPsionic", "AutoMage", "AutoPaladin", "AutoWarrior", "AutoStalker", "AutoPriest" } )

function FindClassTemplate( sClassName )
	for key, value in g_ListClasses do
		if ( value == sClassName ) then
			return true
		end
	end
	return false
end

function CheckBuff( params )
	local bKill = false
	if( params == nil )then
		return false
	end		
		if( params.bForKill ~= nil  )then
			bKill = params.bForKill
		end
		local nActiveBuffs = unit.GetBuffCount( params.nUnitID )
		for i=0, nActiveBuffs-1 do
	    local buff = unit.GetBuff( params.nUnitID, i )
	    if buff.debugName == params.szBuffName or string.find( buff.debugName, params.szBuffName ) then
		    return ( bKill == false )
	    end
	end
	return bKill
end

function AttachBuff( params, PassFunc, ErrorFunc )
	if( ( params == nil ) or ( params.szBuffName == nil ))then
		ErrorFunc()
		return
	end
	qaMission.SendCustomMsg( "attach_buff "..params.szBuffName )
	StartCheckTimer(500, CheckBuff, params, ErrorFunc , nil, PassFunc )	
end

function DeClick( params, PassFunc, ErrorFunc )
	if( ( params == nil ) or ( params.szBuffName == nil ) ) then
		common.LogInfo( "common","Declicks Params NIL!!!!!! " )		
		return
	end
	common.LogInfo( "common","Declicks "..tostring( params.szBuffName ) )		
	local count = unit.GetBuffCount( params.nUnitID )
	local i=0
	for i=0, count-1 do
	    local buff = unit.GetBuff( params.nUnitID, i )
	    if buff.debugName == params.szBuffName or string.find( buff.debugName, params.szBuffName ) then
	        avatar.RemoveBuff( i )
			break
	    end
	end	
	StartCheckTimer(500, CheckBuff, { szBuffName = params.szBuffName, nUnitID = params.nUnitID, bForKill = true }, ErrorFunc , nil, PassFunc )	
end

function Normalize( params, PassFunc, ErrorFunc )
	NORMALIZE_PASS_FUNC = PassFunc
	NORMALIZE_ERROR_FUNC = ErrorFunc
	qaMission.SendCustomMsg("normalize "..tostring( g_nNormalize ).." 0 0")
	StartCheckTimer(5000, CheckNormalize, nil, NORMALIZE_ERROR_FUNC , nil, NORMALIZE_PASS_FUNC )	
end

function CheckNormalize( params )
	local stats = avatar.GetInnateStats()
	if( stats == nil ) then
	 return false
	end
	local prev = nil
	for key, value in stats do
		if( ( prev ~= nil ) and ( prev ~= value.effectiv ) )then			
			return false
		end
		prev = value.effectiv
	end
	return true	
end

function GetAEdir(angle)
 local pi = math.pi
 local dir = tonumber(avatar.GetDir()) + DegrToRad( angle )
 if dir < 0 then
  dir = 2*pi + dir
 elseif dir > 2*pi  then
  dir = dir - 2*pi
 end
return dir
end

function CastAction()
	local params = CLEAN_PARAMS
	if( params ~= nil ) then
		if( params.ActionFunc ~= nil ) then
			params.ActionFunc( params.ActionParams )
		end
	end
	CLEAN_PARAMS = nil
end

function ErrorCleanPlace( params )
	Log( "Error Clean Place" )
end

function CleanPlaceInRadius( params )
 if( params ~= nil )then
	CLEAN_PARAMS = params
 end
 local units = avatar.GetUnitList()
 Log("units around ")
 for key, value in units do
  Log(tostring(value))
  if not unit.IsPlayer( value ) then
   if not unit.IsDead( value ) then
    local pos = GetPositionAtDistance(avatar.GetPos(), avatar.GetDir(), 30)
    local dist = GetDistanceFromPosition( value, pos )
    Log("dist"..tostring(dist))
    if dist < 100 then
     Log("need desummon")
     DeSummon( value, CleanPlaceInRadius, ErrorCleanPlace )
     return
    end
   end
  end
 end
 CastAction() 
end


