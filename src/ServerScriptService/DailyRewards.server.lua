local code = "HAL" -- change to reset daily gift

local function day()
	return math.floor(os.time()/(60*60*24))
end

game.ReplicatedStorage:WaitForChild("Items")
local Items = {}
for i,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
	if v.ItemType.Value == 1 or v.ItemType.Value == 2 or v.ItemType.Value == 3 then
		table.insert(Items,v)
	end
end
function getItemFromId(id)
	for i,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
		if v.ItemId.Value == id then
			return v
		end
	end
end


function award(player)
	if player:FindFirstChild("Gifted") == nil then
		if player.userId > 0 then
			spawn(function()
				game.PointsService:AwardPoints(player.userId,1000)
			end)
		end

		local ExtraRewards = {}

		local Money = game.ServerStorage.MoneyStorage:FindFirstChild(player.Name)
		if Money then
			local tag = Instance.new("BoolValue",player)
			tag.Name = "Gifted"

			local Round = 7 * math.floor(player.LoginStreak.Value / 7)
			local Progress = 0



			local RealBox = game.ReplicatedStorage.Boxes.Pumpkin
--			table.insert(ExtraRewards,{Name="1 Pumpkin Box (Event)",Image="rbxassetid://"..RealBox.ThumbnailId.Value,Color=RealBox.BoxColor.Value})

			if player.LoginStreak.Value == 7 then
				game.ServerStorage.AwardBadge:Invoke(player, 1195310080)
			end

			if player.LoginStreak.Value > 1 and player:FindFirstChild("SecondGift") == nil then
				game.ReplicatedStorage.SystemAlert:FireAllClients(player.Name.." has opened their daily gift "..player.LoginStreak.Value.." days in a row!", Color3.fromRGB(255, 102, 204),Color3.new(0,0,0))
			end

			if player.LoginStreak.Value > 1 and (player.LoginStreak.Value - Round == 3) then
				spawn(function()
					wait()
					player.Crates.Unreal.Value = player.Crates.Unreal.Value + 1
					game.ReplicatedStorage.Hint:FireClient(player,"Login streak: 1 Unreal Awarded.")

					local Box = game.ReplicatedStorage.Boxes.Unreal
					game.ReplicatedStorage.CurrencyPopup:FireClient(player,Box.Name.." Box",Box.BoxColor.Value,"rbxassetid://"..Box.ThumbnailId.Value)

					local RealBox = game.ReplicatedStorage.Boxes.Unreal
					table.insert(ExtraRewards,{Name="1 Unreal Box ("..player.LoginStreak.Value.." Days)",Image="rbxassetid://"..RealBox.ThumbnailId.Value,Color=RealBox.BoxColor.Value})
				end)
			end
			if player.LoginStreak.Value > 1 and (player.LoginStreak.Value - Round == 5) then
				spawn(function()
					wait()
					player.Crates.Inferno.Value = player.Crates.Inferno.Value + 1
					game.ReplicatedStorage.Hint:FireClient(player,"Login streak: 1 Inferno Awarded.")

					local Box = game.ReplicatedStorage.Boxes.Inferno
					game.ReplicatedStorage.CurrencyPopup:FireClient(player,Box.Name.." Box",Box.BoxColor.Value,"rbxassetid://"..Box.ThumbnailId.Value)

					local RealBox = game.ReplicatedStorage.Boxes.Inferno
					table.insert(ExtraRewards,{Name="1 Inferno Box ("..player.LoginStreak.Value.." Days)",Image="rbxassetid://"..RealBox.ThumbnailId.Value,Color=RealBox.BoxColor.Value})
				end)
			end
			if player.LoginStreak.Value > 1 and (player.LoginStreak.Value - Round == 0) then
				spawn(function()
					wait()
					player.Crates.Spectral.Value = player.Crates.Spectral.Value + 1
					game.ReplicatedStorage.Hint:FireClient(player,"Login streak: 1 Spectral Awarded.")

					local Box = game.ReplicatedStorage.Boxes.Spectral
					game.ReplicatedStorage.CurrencyPopup:FireClient(player,Box.Name.." Box",Box.BoxColor.Value,"rbxassetid://"..Box.ThumbnailId.Value)

					local RealBox = game.ReplicatedStorage.Boxes.Spectral
					table.insert(ExtraRewards,{Name="1 Spectral Box ("..player.LoginStreak.Value.." Days)",Image="rbxassetid://"..RealBox.ThumbnailId.Value,Color=RealBox.BoxColor.Value})
				end)
			end


			-- Crate from above
			if player:FindFirstChild("VIP") then
				local Chance = math.random(1,20)
				local CrateName
				if Chance == 10 then
					CrateName = "DiamondCrate"
				elseif Chance >= 19 then
					CrateName = "CrystalCrate"
				else
					CrateName = "GoldenCrate"
				end
				local Crate = game.ServerStorage:FindFirstChild(CrateName):Clone()
				Crate.Parent = workspace
				pcall(function()
					Crate.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(math.random(-6,6),50,math.random(-6,6))
				end)
			end



			if player:FindFirstChild("Executive") then
				local CrateName = "ExecutiveCrate"
				local Crate = game.ServerStorage:FindFirstChild(CrateName):Clone()
				Crate.Parent = workspace
				pcall(function()
					Crate.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(math.random(-6,6),50,math.random(-6,6))
				end)
			end



			if player then
				local CrateName = "GiftCrate"
				local Crate = game.ServerStorage:FindFirstChild(CrateName):Clone()
				Crate.Owner.Value = player
				Crate.Parent = workspace
				pcall(function()
					Crate.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(math.random(-6,6),35,math.random(-6,6))
				end)
			end

			if player:FindFirstChild("Shoddy") then
				spawn(function()
					for i=1,math.random(1,3) do
						local CrateName = "ResearchCrate"
						local Crate = game.ServerStorage:FindFirstChild(CrateName):Clone()
						Crate.Parent = workspace
						pcall(function()
							Crate.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(math.random(-6,6),50,math.random(-6,6))
						end)
						wait(0.1)
					end
				end)
			end

			if player:FindFirstChild("GiantCrate") then
				local CrateName = "GiantCrate"
				local Crate = game.ServerStorage:FindFirstChild(CrateName):Clone()
				Crate.Parent = workspace
				pcall(function()
					Crate.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(math.random(-6,6),50,math.random(-6,6))
				end)
			end

			if player:FindFirstChild("CursedPearl") then
				local CrateName = "DarkCrate"
				local Crate = game.ServerStorage:FindFirstChild(CrateName):Clone()
				Crate.Parent = workspace
				pcall(function()
					Crate.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(math.random(-6,6),50,math.random(-6,6))
				end)
			end

			if player:FindFirstChild("CircusTent") and (player.LoginStreak.Value % 3 == 0) then
				player.Megaphones.Value = player.Megaphones.Value + 1
				game.ReplicatedStorage.Hint:FireClient(player,"Obtained a megaphone.")
				table.insert(ExtraRewards,{Name="1 Megaphone (Artifact)",Image="rbxassetid://135199055",Color=Color3.new(0.5,0.5,0.5)})
			end

			--[[
			if player:FindFirstChild("GoldClovers") then
				local amount = math.random(3,7)
				game.ReplicatedStorage.Hint:FireClient(player,"You found "..amount.." gold clovers in your gift!")
				player.GoldClovers.Value = player.GoldClovers.Value + amount
			end
			]]

			local uCAmount
			if player:FindFirstChild("Crystals") then
				local upperlimit = 3

				if player.LoginStreak.Value > 100 then
					upperlimit = 50
				elseif player.LoginStreak.Value > 75 then
					upperlimit = 40
				elseif player.LoginStreak.Value > 50 then
					upperlimit = 30
				elseif player.LoginStreak.Value > 30 then
					upperlimit = 25
				elseif player.LoginStreak.Value > 20 then
					upperlimit = 20
				elseif player.LoginStreak.Value > 15 then
					upperlimit = 15
				elseif player.LoginStreak.Value > 10 then
					upperlimit = 10
				elseif player.LoginStreak.Value > 5 then
					upperlimit = 7
				elseif player.LoginStreak.Value > 3 then
					upperlimit = 6
				elseif player.LoginStreak.Value > 1 then
					upperlimit = 5
				end

				uCAmount = math.random(1,upperlimit)

				if player:FindFirstChild("Premium") then
					uCAmount = uCAmount + 9
				end



				-- LIMITED-TIME ARTIFACT:
				if player:FindFirstChild("Gambler") then
					uCAmount = uCAmount + math.random(-3,6)
				end
				if player:FindFirstChild("Snowflake") then
					pcall(function()
						player.Character.Humanoid.WalkSpeed = player.Character.Humanoid.WalkSpeed + 10
						Instance.new("Sparkles",player.Character.HumanoidRootPart)
						game.ReplicatedStorage.Hint:FireClient(player,"You're SUPER fast!")
					end)
				end

				if player:FindFirstChild("BerezaaGames") then
					uCAmount = uCAmount + 2
					player.Crates.Regular.Value = player.Crates.Regular.Value + 1
					game.ReplicatedStorage.Hint:FireClient(player,"1 Regular Box Awarded")
					local RealBox = game.ReplicatedStorage.Boxes.Regular
					table.insert(ExtraRewards,{Name="1 Regular Box (Bergames)",Image="rbxassetid://"..RealBox.ThumbnailId.Value,Color=RealBox.BoxColor.Value})
				end



				if player:FindFirstChild("Executive") then
					uCAmount = uCAmount + math.random(10,20)
					spawn(function()
						wait()
						player.Crates.Inferno.Value = player.Crates.Inferno.Value + 1
						local Box = game.ReplicatedStorage.Boxes.Inferno
						game.ReplicatedStorage.CurrencyPopup:FireClient(player,Box.Name.." Box",Box.BoxColor.Value,"rbxassetid://"..Box.ThumbnailId.Value)
						local RealBox = game.ReplicatedStorage.Boxes.Inferno
						table.insert(ExtraRewards,{Name="1 Inferno Box (Exec)",Image="rbxassetid://"..RealBox.ThumbnailId.Value,Color=RealBox.BoxColor.Value})

					end)
				end
				player.Crystals.Value = player.Crystals.Value + uCAmount
                game.ReplicatedStorage.Hint:FireClient(player,uCAmount.." uCrystal awarded!")

				-- Game Analytics Currency Reporting
				local CrystalsGained = uCAmount
				local ProductName = "dailygift"
				if true then
					ProductName = ProductName or "unknown"
					game.ServerStorage.CurrencyEvent:Fire(player, "Crystals", CrystalsGained, "granted", ProductName)
				end
				-- Game Analytics Currency Reporting

			end

			local RanVal = math.random(3,45)
			if player:FindFirstChild("VIP") and RanVal < 40 then
				RanVal = RanVal + 5
			end
			local NewMoney = math.floor(Money.Value*(RanVal/100))+math.random(700,3500)
			Money.Value = Money.Value + NewMoney
			if RanVal > 35 then
				game.ReplicatedStorage.SystemAlert:FireAllClients("Woah! ".. player.Name.." won the money jackpot!", Color3.new(1,1,1),Color3.new(0,0,0),Color3.new(0.4,0.1,0.4))
			end
			local ItemsToChoseFrom = {}
			for i,v in pairs(Items) do
				if (v.Cost.Value > Money.Value / 50) and (v.Cost.Value < Money.Value * 2.4) then
					table.insert(ItemsToChoseFrom,v)
				end
			end
			local Item
			if #ItemsToChoseFrom <= 1 then
				Item = Items[math.random(1,#Items)]
			else
				Item = ItemsToChoseFrom[math.random(1,#ItemsToChoseFrom)]
			end

			if Item then
				if Item.Cost.Value > Money.Value * 2 then
					game.ReplicatedStorage.SystemAlert:FireAllClients("Wow! ".. player.Name.." won an expensive gift!", Color3.new(1,1,1),Color3.new(0,0,0),Color3.new(0.1,0.1,0.4))
				end
				local ItemId = Item.ItemId.Value
				local Amount
				local Rando = math.random(1,1000)
				if Rando > 990 then
					Amount = 4
					game.ReplicatedStorage.SystemAlert:FireAllClients("No way! ".. player.Name.." won four items in their gift!", Color3.new(1,1,1),Color3.new(0,0,0),Color3.new(0.1,0.4,0.1))
				elseif Rando > 900 then
					Amount = 3
				elseif Rando > 600 then
					Amount = 2
				else
					Amount = 1
				end
				spawn(function()
					wait(1)
					game.ReplicatedStorage.EntryPerks:FireClient(player,NewMoney,ItemId,Amount,uCAmount,ExtraRewards)
				end)

				game.ServerStorage.AwardItem:Invoke(player,ItemId,Amount)
--[[
				if _G["Inventory"][player.Name][ItemId].Quantity then
					_G["Inventory"][player.Name][ItemId].Quantity = _G["Inventory"][player.Name][ItemId].Quantity + Amount
				else
					_G["Inventory"][player.Name][ItemId].Quantity = Amount
				end
				game.ReplicatedStorage.InventoryChanged:FireClient(player,ItemId)
]]
			end
		end
	end
end

local OrderedDataStore = game:GetService("DataStoreService"):GetOrderedDataStore("LoginStreakLeaders")

game.ReplicatedStorage.RewardReady.OnServerEvent:connect(function(player)

		if player:FindFirstChild("LastGift") == nil or player:FindFirstChild("LoginStreak") == nil then
			error("Failed to find important gift values")
			return false
		end

		local GiftStatus
		if player:FindFirstChild("GiftStatus") == nil then
			GiftStatus = Instance.new("BoolValue",player)
			GiftStatus.Name = "GiftStatus"
			GiftStatus.Value = true
		else
			GiftStatus = player.GiftStatus
		end
		if GiftStatus.Value == true then
			GiftStatus.Value = false


			-- ignore code for login streak
			local rawday = string.gsub(player.LastGift.Value,"[^0-9]", "")
			rawday = tonumber(rawday) or 0
			if rawday == day() - 1 then
				player.LoginStreak.Value = player.LoginStreak.Value + 1
			elseif rawday < (day() - 1) then
				player.LoginStreak.Value = 1
			end

			award(player)

			player.LastGift.Value = tostring(day())..code
		end

		if player:FindFirstChild("StreakLeaderboardTag") == nil then
			local Tag = Instance.new("BoolValue")
			Tag.Name = "StreakLeaderboardTag"
			Tag.Parent = player
			OrderedDataStore:UpdateAsync(tostring(player.userId),function(Streak)
				Streak = Streak or 0
				if player.LoginStreak.Value > Streak then
					Streak = player.LoginStreak.Value
				end
				return Streak
			end)
		end

end)

function check(player)
	if #game.Players:GetChildren() <= 6 then

		if player:FindFirstChild("LastGift") == nil or player:FindFirstChild("LoginStreak") == nil then
			error("Failed to find important gift values")
			return false
		end


		local Status = (player.LastGift.Value ~= tostring(day())..code)

		local GiftStatus
		if player:FindFirstChild("GiftStatus") == nil then
			GiftStatus = Instance.new("BoolValue",player)
			GiftStatus.Name = "GiftStatus"
		else
			GiftStatus = player.GiftStatus
		end

		GiftStatus.Value = Status

	end
end

game.ServerStorage.PlayerDataLoaded.Event:connect(check)