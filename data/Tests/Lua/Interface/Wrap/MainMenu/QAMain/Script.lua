--
-- Global vars
--

Global( "HTTP_REQUEST", "http://192.168.10.81:8080/twf/test.do?request=" )

--
-- main initialization function
--

function Init()
--	LogInfo( "Main Menu QA addon" )

--	mainMenu.FastEnterServer( "", "", "" )

	common.DebugHttpGET( HTTP_REQUEST .. "MainMenuQAMainAddon" )
end

--
-- main initialization
--

Init()
