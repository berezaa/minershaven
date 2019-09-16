--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

game.ReplicatedStorage:WaitForChild("Items")
local ItemList = {}
local Awardables = {}

for i,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
	ItemList[v.ItemId] = v
	if v.Tier.Value == 30 or v.Tier.Value == 33 then
		table.insert(Awardables,v)
	end
end

rand = Random.new()

local function today()
	return math.floor(os.time()/(60*60*24))
end

local TycoonLib = require(game.ReplicatedStorage.TycoonLib)
getTycoon = TycoonLib.getTycoon

local MoneyLib = require(game.ReplicatedStorage.MoneyLib)

HandleLife = MoneyLib.HandleLife

local Announce = game:GetService("DataStoreService"):GetDataStore("GlobalAnnouncement")

game.ServerStorage.PlayerDataLoaded.Event:connect(function(Player)
	print("Done")
	local tTag = Instance.new("IntValue")
	tTag.Name = "DataStorePosts"
	tTag.Value = 5
	tTag.Parent = Player
	print(tTag)
end)

spawn(function()
	while wait(60) do
		for i,Player in pairs(game.Players:GetPlayers()) do
			if Player:FindFirstChild("DataStorePosts") and Player.DataStorePosts.Value < 10 then
				Player.DataStorePosts.Value = Player.DataStorePosts.Value + 1
			end
		end
	end
end)

game.Players.PlayerRemoving:connect(function(Player)
	local Tag = Instance.new("BoolValue",Player)
	Tag.Name = "Leaving"
end)

local function RebirthAwards(Player, Jump)
	local SpecificAwards = {}
	for i,v in pairs(Awardables) do
		if v:FindFirstChild("ReqLife") then
			if Player.Rebirths.Value >= v.ReqLife.Value and ((v:FindFirstChild("ReqPoints") and Player.Points.Value >= v.ReqPoints.Value) or true) then
				local Chance = v.RebornChance.Value
				if v.Tier.Value == 33 then
					Chance = math.floor(Chance * (Jump * 0.5) )
				end
				for i=1,Chance do
					table.insert(SpecificAwards,v)
				end
			end
		else
			table.insert(SpecificAwards,v)
		end
	end
	return SpecificAwards
end

function containsHuman(Item)
	if Item then
		if Item:IsA("Humanoid") or Item:FindFirstChild("Humanoid") then
			return true
		end

		for i,Child in pairs(Item:GetChildren()) do
			if Child:IsA("Humanoid") or Child:FindFirstChild("Humanoid") then
				return true
			end
		end
	end
	return false

end

function game.ReplicatedStorage.Rebirth.OnServerInvoke(Player)

	if Player.ActiveTycoon.Value ~= Player.PlayerTycoon.Value then
		return false
	end

	local Money = game.ServerStorage.MoneyStorage:FindFirstChild(Player.Name)
	local Tycoon = getTycoon(Player)
	if Money and Tycoon and Player:FindFirstChild("Rebirths") and Player:FindFirstChild("Rebirthing") == nil then
		local Price = MoneyLib.RebornPrice(Player.Rebirths.Value)
		if Money.Value >= Price then

			local Tag = Instance.new("BoolValue")
			Tag.Name = "Rebirthing"
			Tag.Parent = Player

			local UniqueId = 0
			local Unique = false
			local Uniques = {}

			for i,Item in pairs(Tycoon:GetChildren()) do
				if Item:FindFirstChild("ItemId") then
					if UniqueId == 0 then

						UniqueId = Item.ItemId.Value
						Unique = true
						table.insert(Uniques,Item)

					elseif Item.ItemId.Value ~= UniqueId then
						Unique = false
					else
						table.insert(Uniques,Item)
					end
				end
			end

			local Evo
			if Unique then
				for i,Item in pairs(game.ReplicatedStorage.Items:GetChildren()) do
					if Item:FindFirstChild("RebornId") and Item:FindFirstChild("RebornCount") and Item.RebornId.Value == UniqueId then
						Evo = Item
					end
				end
			end

			if Evo ~= nil and #Uniques >= Evo.RebornCount.Value then
				for i,Item in pairs(Uniques) do
					Item:Destroy()
				end
				game.ReplicatedStorage.Hint:FireClient(Player,"Your reborn items were fused.")
				game.ServerStorage.AwardItem:Invoke(Player,Evo.ItemId.Value,1)
				game.ServerStorage.AwardBadge:Invoke(Player,1055766390)
			elseif Unique then
				game.ReplicatedStorage.Hint:FireClient(Player,"Failed to evolve Reborn items!")
				Evo = nil
			end

			local Jump = 1

			Jump = Jump + MoneyLib.LifeSkips(Player.Rebirths.Value, Money.Value)

			if Jump > 1 and Player.DataStorePosts.Value > 0 then
				Player.DataStorePosts.Value = Player.DataStorePosts.Value - 1
				spawn(function()
					local Today = math.floor(os.time()/(60*60*24))
					local OrderedDataStore = game:GetService("DataStoreService"):GetOrderedDataStore("LifeSkipped"..tostring(Today))
					OrderedDataStore:IncrementAsync(tostring(Player.userId),(Jump-1))
					local OrderedDataStore = game:GetService("DataStoreService"):GetOrderedDataStore("LifeSkippedAllTime")
					OrderedDataStore:IncrementAsync(tostring(Player.userId),(Jump-1))
				end)
			end

			local PlaySolo = (game.VIPServerId ~= "" and game.VIPServerOwnerId == 0)

			if Jump >= 11 then
				if PlaySolo then
					if Player.LastTropic.Value < today() then
						Player.LastTropic.Value = today()
						game.ServerStorage.AwardItem:Invoke(Player,531)
					end
				end
			end

			if Jump >= 4 then
				game.ServerStorage.AwardBadge:Invoke(Player,717159176)

			end
			if Jump >= 21 then
				game.ServerStorage.AwardBadge:Invoke(Player,1604869571)
			end

			for i,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
				if v.ItemType.Value ~= 6 and v.ItemType.Value ~= 7 and v.ItemType.Value ~= 99 then
					_G["Inventory"][Player.Name][v.ItemId.Value].Quantity = nil
				end
			end

			local DroppedOre = workspace.DroppedParts:FindFirstChild(Tycoon.Name)
			if DroppedOre then
				DroppedOre:ClearAllChildren()
			end

			local Overlord = false

			local DD = MoneyLib.ShortToLong("1DD")
			local Jackpot = 10^102
			if Money.Value > Jackpot and Player.LastTrueOverlord.Value < today() then
				game.ServerStorage.AwardItem:Invoke(Player,293)
				Overlord = "gameover"
				Player.LastTrueOverlord.Value = today()
			elseif Money.Value > DD and Player.LastOverlord.Value < today() then
				game.ServerStorage.AwardItem:Invoke(Player,283)
				Overlord = true
				Player.LastOverlord.Value = today()
			end

			local InfernoChance = rand:NextInteger(1,6)




			Money.Value = 50
			spawn(function()
				wait(2)
				Money.Value = 50
				wait(2)
				Money.Value = 50
			end)


			for i,v in pairs(Tycoon:GetChildren()) do


				if v:FindFirstChild("ItemType") then

					--if v:FindFirstChild("Decoration") == nil then

						if v.ItemType.Value == 6 or v.ItemType.Value == 7 or v.ItemType.Value == 99 then
							if _G["Inventory"][Player.Name][v.ItemId.Value].Quantity ~= nil then
								_G["Inventory"][Player.Name][v.ItemId.Value].Quantity = _G["Inventory"][Player.Name][v.ItemId.Value].Quantity + 1
							else
								_G["Inventory"][Player.Name][v.ItemId.Value].Quantity = 1
							end
						end
						if v:FindFirstChild("Model") and containsHuman(v.Model) then
							v:Destroy()
						else
							v.Parent = workspace.DoomedItems
							Instance.new("Fire",v.Hitbox)
							spawn(function()
								--wait(math.random(1,100)/30)
								wait(rand:NextInteger(1, 100)/30)
								local Explosion = Instance.new("Explosion",workspace)
								Explosion.Position = v.Hitbox.Position
								local Sound = script.Explode:Clone()
								Sound.Pitch = rand:NextInteger(80,120)/100
								Sound.Volume = rand:NextInteger(20,80)/100
								Sound.Parent = v
								Sound:Play()
								wait(1)
								v:Destroy()
							end)
						end


					--end
				end
			end


			wait()


			if Player ~= nil and Player.Parent == game.Players and Player:FindFirstChild("Leaving") == nil then



				local OldLife = Player.Rebirths.Value + 1

				Player.Rebirths.Value = Player.Rebirths.Value + Jump

				local Life = Player.Rebirths.Value + 1

				if OldLife == 1 then
					for i,Plr in pairs(game.Players:GetPlayers()) do
						if Plr:FindFirstChild("ActiveTycoon") and Plr.ActiveTycoon.Value == Player.PlayerTycoon.Value and Plr ~= Player then
							game.ServerStorage.AwardBadge:Invoke(Plr,1055729351)
						end
					end
				end


				if Player:FindFirstChild("Sacrificed") and (OldLife < 100 and Life >= 100) then
					game.ServerStorage.ReturnItems:Invoke(Player)
				end





				game.ServerStorage.AwardBadge:Invoke(Player,258260444)
				if Life >= 5 then
					game.ServerStorage.AwardBadge:Invoke(Player,258842557)
				end


				local SpecificAwards = {}
				local Lifev = Player.Rebirths

				local Chance = 0

				if Player:FindFirstChild("Sacrificed") then
					Chance = rand:NextInteger(1,20)
				end
				if Chance == 7 then

					for i,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
						if v.ItemType.Value == 6 and v.Tier.Value == 31 then
							table.insert(SpecificAwards,v)
						end
					end

				else
					SpecificAwards = RebirthAwards(Player, Jump)
				end



				local Reward = SpecificAwards[rand:NextInteger(1,#SpecificAwards)]
				if Evo then
					Reward = Evo
				end

				local ExtraChance = 0
				if Jump >= 18 then
					ExtraChance = rand:NextInteger(300,600)
				elseif Jump >= 15 then
					ExtraChance = rand:NextInteger(150,600)
				elseif Jump >= 12 then
					ExtraChance = rand:NextInteger(50,500)
				elseif Jump >= 10 then
					ExtraChance = rand:NextInteger(50,500)
				elseif Jump >= 7 then
					ExtraChance = rand:NextInteger(1,500)
				elseif Jump >= 3 then
					ExtraChance = rand:NextInteger(1,400)
				end


				if Player:FindFirstChild("SecondSacrifice") and (OldLife < 10 and Life >= 10) then
					game.ReplicatedStorage.Hint:FireClient(Player,"Behold, The Final Upgrader.")
					Reward = game.ReplicatedStorage.Items["The Final Upgrader"]
				--	game.ReplicatedStorage.RebornEarned:FireClient(Player,"The Final Upgrader",false)
				end

				local RewardId = Reward.ItemId.Value
				if Evo then
					RewardId = Evo.ItemId.Value
				end

				if not Evo then
					game.ServerStorage.AwardItem:Invoke(Player,RewardId,1)
				end

				-- Extra items for skipping lives.
				if ExtraChance >= 300 then
					SpecificAwards = RebirthAwards(Player, Jump)
					local Reward1 = SpecificAwards[rand:NextInteger(1,#SpecificAwards)]
					game.ServerStorage.AwardItem:Invoke(Player,Reward1.ItemId.Value,1)

					if ExtraChance >= 450 then
						local Reward2 = SpecificAwards[rand:NextInteger(1,#SpecificAwards)]
						game.ServerStorage.AwardItem:Invoke(Player,Reward2.ItemId.Value,1)
					end
				end

				local player = Player

				--[[
				if Player:FindFirstChild("GoldClovers") then
					local amount = math.random(-7,2)
					if amount > 0 then
						game.ReplicatedStorage.Hint:FireClient(Player,"You found "..amount.." gold clovers when Rebirthing.")
						Player.GoldClovers.Value = Player.GoldClovers.Value + amount
					end
				end
				]]


				local Slipstream = false
				local calc = Life
				if calc >= 1000 then
					calc = 200
				elseif calc >= 500 then
					calc = 500
				end
				if Life >= 2 then
					local Streamchance = rand:NextInteger(1,1000)
					if Streamchance > (1000 - calc) then
						Slipstream = true
						game.ServerStorage.AwardBadge:Invoke(Player,697732653)
					end
				end

				if Slipstream then
					local Slipstreams = {}
					for i,Item in pairs(game.ReplicatedStorage.Items:GetChildren()) do
						if Item.Tier.Value == 78 and Item.ItemType.Value == 10 then
							table.insert(Slipstreams,Item)
						end
					end
					local Slipreward = Slipstreams[rand:NextInteger(1,#Slipstreams)]
					game.ServerStorage.AwardItem:Invoke(Player,Slipreward.ItemId.Value,1)
				end


				if Life == 2 or Life == 3 or Life == 100 or Life == 500 or Life == 1000 or InfernoChance <= Jump then
					game.ReplicatedStorage.Hint:FireClient(Player,"As you ascend into a new life, an Inferno Box joins you.",Color3.new(1,0.3,0.3))
					Player.Crates.Inferno.Value = Player.Crates.Inferno.Value + 1
					local Box = game.ReplicatedStorage.Boxes.Inferno
					game.ReplicatedStorage.CurrencyPopup:FireClient(Player,Box.Name.." Box",Box.BoxColor.Value,"rbxassetid://"..Box.ThumbnailId.Value)
				end


				local Shards = math.floor(Jump / 2)
				if Shards > 0 then
					Player.Shards.Value = Player.Shards.Value + Shards
					local Suffix = Shards == 1 and "Shard" or "Shards"
					local Prefix = Shards == 1 and "" or tostring(Shards) .. " "
					game.ReplicatedStorage.CurrencyPopup:FireClient(Player,Prefix..Suffix.." of Life",Color3.new(0.4,0.4,0.4),"rbxassetid://1677553425")
					game.ServerStorage.CurrencyEvent:Fire(Player, "Shards", Shards, "earned", "rebirth")
				end



				local LastDigit = tonumber(string.sub(tostring(Life),string.len(tostring(Life))))
				local LifeString = HandleLife(Life)
			--	Player.leaderstats.Life.Value = tostring(Life)..Suffix
				--[[
					if Life <= 20 and Life >= 10 then
						Suffix = "th"
					elseif LastDigit == 1 then
						Suffix = "st"
					elseif LastDigit == 2 then
						Suffix = "nd"
					elseif LastDigit == 3 then
						Suffix = "rd"
					else
						Suffix = "th"
					end
				]]
				local Inventory = _G["Inventory"][Player.Name]
				Inventory[1] = {Quantity = 3}
				Inventory[2] = {Quantity = 1}
				Inventory[3] = {Quantity = 10}
				local Prefix = ""
				if Player:FindFirstChild("SecondSacrifice") then
					Prefix = "S+"
				elseif Player:FindFirstChild("Sacrificed") then
					Prefix = "s-"
				end
				-- NEW ANNOUNCEMENT SYSTEM
				local Skip = Jump - 1
				local ssuffix = Skip ~= 1 and " lives" or " life"
				local s = ((Skip > 0) and " (Skipped "..(Skip)..ssuffix	..")") or ""
				local Data = {Player.Name.." was born into their "..Prefix..LifeString.." life with a "..Reward.Name..s..".",{0.5,0.6,1},{0.2,0.1,0.1},{0.1,0.2,0.3}}


				Announce:SetAsync("Announcement",Data)

	--			DataStore:SetAsync("LastRebirth",{Player.Name,Prefix..Life..Suffix,Overlord,Reward.Name})
	--			Storage:SetAsync(Player.userId,Player.Rebirths.Value)
				wait()




				game.ServerStorage.ReportEvent:Invoke(Player, "Rebirth", Life)

				game.ReplicatedStorage.SavePlayer:Invoke(Player)
				game.ReplicatedStorage.InventoryChanged:FireClient(Player,_G["Inventory"][Player.Name])
				Tag:Destroy()
				return true
			end
		end
	end
return false
end