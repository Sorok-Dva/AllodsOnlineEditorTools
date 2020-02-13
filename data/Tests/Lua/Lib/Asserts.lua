
Global( "ERROR_CODE", "-1" )

function Success( test )
    common.LogInfo( "Test: "..test.." SUCCESS")
    SendExitEvent()      
end   

function Fatal( textCode )
   common.LogInfo( "FATAL: "..tostring( textCode ).." Error code "..ERROR_CODE )
   common.QuitGame()
end

function Error( test, textCode )
   common.LogInfo( "ERROR: Test: "..test.." failed: "..tostring( textCode ).." Error code "..ERROR_CODE )
   common.QuitGame()
end

function Warn( test, textCode )
   common.LogInfo( "WARNING: Test: "..test.." failed: "..tostring( textCode ).." Error code "..ERROR_CODE )
   SendExitEvent()
end