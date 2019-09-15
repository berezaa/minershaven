local function hitDat(toBeHit)
	local lastHit = toBeHit.Value
	local Player = game.Players:FindFirstChild(toBeHit.Name)
	if Player ~= nil then
		local ClientVal = Instance.new("NumberValue")
		ClientVal.Name = "RawChange"
		ClientVal.Parent = Player

		local Avg = Instance.new("NumberValue")
		Avg.Name = "AverageIncome"
		Avg.Parent = Player

		local Averages = {}

		local function wipe()
			Averages = {}
			Avg.Value = 0
			ClientVal.Value = 0
		end

		wait(60)



		Player.ChildAdded:connect(function(Child)
			if Child.Name == "Gifted" or Child.Name == "SecondGift" then
				wipe()
			end
		end)

		Player.Rebirths.Changed:connect(function() -- clear table for rebirth
			wipe()
		end)

		Player.ChildAdded:connect(function(Child)
			if Child.Name == "Sacrificed" or Child.Name == "SecondSacrifice" then
				wipe()
				wait(1)
				wipe()
			end
		end)

		while wait(2) do
			if toBeHit ~= nil and Player ~= nil and Player.Parent == game.Players then
				local deltaValue = (toBeHit.Value - lastHit) / 2

				if deltaValue >= 0 then
					table.insert(Averages,deltaValue)
					if #Averages > 20 then
						table.remove(Averages,1)
					end

					local Sum = 0
					for i,Val in pairs(Averages) do
						Sum = Sum + Val
					end
					Avg.Value = Sum / (#Averages * 2)


					if deltaValue >= 0 then
						ClientVal.Value = deltaValue
					end

				end
				lastHit = toBeHit.Value

			else
				break
			end
		end
	end
end

game.ServerStorage.PlayerDataLoaded.Event:connect(function(Player)
	hitDat(game.ServerStorage.MoneyStorage:WaitForChild(Player.Name))
end)