--[[

	Thanks for using my GameAnalytics module! PM me (ByDefault) with any suggestions, bugs or feedback in
	general!

	To start using the module, follow these steps:

	1. Create an account on gameanalytics.com and create a game
	2. Get your game key and secret key
	3. Require this module ( require(GameAnalytics) )
	4. Call :Init(GameKey, SecretKey) on the module
	5. You're ready!


	To send events, follow these steps:

	1. Create a table for the event, like so:
		local eventTable = {
			["category"] = "design",
			["event_id"] = "Game:RoundStart:Spleef",
		}
	2. Call :SendEvent(EventTable) on the module, letting the only parameter be the eventTable you just made
	3. That's it! Your event will automatically be sent within 15 seconds!


	It may take a few minutes for your event to appear in the gameanalytics realtime page and every
	other page gets refreshed with the newest data daily.

	Resources:
	 REST API Docs: http://www.gameanalytics.com/docs/rest-api
	 Account Management: http://www.gameanalytics.com/docs/account-management
	 FAQ: http://www.gameanalytics.com/docs/faq

--]]

script:remove()