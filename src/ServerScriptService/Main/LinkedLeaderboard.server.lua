--rbxsig%XYC6H9oKVLF//1itmbaGn5wI5a4YNtkf4beIsIVZsrT29WveOsrP4YfpYDED5Xa8A1oBA/5oDwtjy4/wlvl/DH0rigLCzfNVjszNya26GajrkOvCFifnNhOCVAOLBySGJ7z5gMoZR/XQjW5EO+K1zDWiQi5CLNwBOxOTMDLS8dU=%
--rbxassetid%1018966%
print("LinkedLeaderboard script version 5.00 loaded")

stands = {}
CTF_mode = false

local ShortenMoneyString = require(game.ReplicatedStorage.MoneyLib).HandleMoney



function onPlayerEntered(newPlayer)


		local stats = Instance.new("IntValue")
		stats.Name = "leaderstats"

		local life = Instance.new("StringValue")
		life.Name = "Life"
		life.Value = "Loading"

		local cash = Instance.new("StringValue")
		cash.Name = "Cash"
		cash.Value = "Loading"


		spawn(function()
			local moneyval = game.ServerStorage.MoneyStorage:WaitForChild(newPlayer.Name)
			cash.Value = ShortenMoneyString(moneyval.Value)
		end)


		life.Parent = stats
		cash.Parent = stats



		stats.Parent = newPlayer

		local val = game.ServerStorage.MoneyStorage:WaitForChild(newPlayer.Name)
		cash.Value = ShortenMoneyString(val.Value)

		val.Changed:connect(function()
			cash.Value = ShortenMoneyString(val.Value)


			if val.Value >= (10^39) then
				game.ServerStorage.AwardBadge:Invoke(newPlayer,285103430)

			elseif val.Value >= 1000000000000 then
				game.ServerStorage.AwardBadge:Invoke(newPlayer,1613546105)
			elseif val.Value >= 1000000 then
				game.ServerStorage.AwardBadge:Invoke(newPlayer,258261279)
			end

		end)

end



game.ServerStorage.PlayerDataLoaded.Event:connect(onPlayerEntered)
--game.Players.ChildAdded:connect(onPlayerEntered)



