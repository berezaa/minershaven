--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

local DataStore = game:GetService("DataStoreService"):GetDataStore("GlobalAnnouncement")

local TycoonLib = require(game.ReplicatedStorage.TycoonLib)
getTycoon = TycoonLib.getTycoon

local SafeItems = {}
for i,Item in pairs(game.ReplicatedStorage.Items:GetChildren()) do
	if Item:FindFirstChild("Soulbound") then
		print(Item.Name.." is soulbound")
		SafeItems[Item.ItemId.Value] = true
	else
		SafeItems[Item.ItemId.Value] = false
	end
end

local RareItems = {}
for i,Item in pairs(game.ReplicatedStorage.Items:GetChildren()) do
	if (Item.ItemType.Value == 7 and Item.Tier.Value == 22) then
		RareItems[Item.ItemId.Value] = true
	elseif (Item.ItemType.Value == 99 and Item.Tier.Value == 41) then
		RareItems[Item.ItemId.Value] = true
	elseif Item.ItemType.Value == 6 and (Item.Tier.Value ~= 30 and Item.Tier.Value ~= 31 and Item.Tier.Value ~= 32 and Item.Tier.Value ~= 33 and Item.Tier.Value ~= 100 and Item.Tier.Value ~= 99) then
		RareItems[Item.ItemId.Value] = true
	else
		RareItems[Item.ItemId.Value] = false
	end
end

function Store(Inventory, Safekeeping, ItemId)
	local Amount = Inventory[ItemId]["Quantity"] or 0

	if Safekeeping[ItemId]["Quantity"] then
		Safekeeping[ItemId].Quantity = Safekeeping[ItemId].Quantity + Amount
	else
		Safekeeping[ItemId].Quantity = Amount
	end

	Inventory[ItemId]["Quantity"] = nil
end

function Add(Safekeeping, ItemId)
	print(Safekeeping)
	print(ItemId)
	print(Safekeeping[ItemId])
	if Safekeeping[ItemId]["Quantity"] then
		Safekeeping[ItemId].Quantity = Safekeeping[ItemId].Quantity + 1
	else
		Safekeeping[ItemId].Quantity = 1
	end
end

function Return(Safekeeping, Inventory, ItemId)
	local Amount = Safekeeping[ItemId]["Quantity"] or 0

	if Inventory[ItemId]["Quantity"] then
		Inventory[ItemId]["Quantity"] = Inventory[ItemId]["Quantity"] + Amount
	else
		Inventory[ItemId]["Quantity"]= Amount
	end

	Safekeeping[ItemId]["Quantity"] = nil
end

function game.ServerStorage.ReturnItems.OnInvoke(Player)

	local Safekeeping = _G["Safekeeping"][Player.Name]
	local Inventory = _G["Inventory"][Player.Name]

	for Id, Item in pairs(Safekeeping) do
		local Amount = Item.Quantity or 0
		if Amount > 0 then
			game.ServerStorage.AwardItem:Invoke(Player,Id,Amount)
		end
		Safekeeping[Id]["Quantity"] = nil
	end

	print("Done")
end

function game.ReplicatedStorage.Sacrifice.OnServerInvoke(Player)

	if Player.ActiveTycoon.Value ~= Player.PlayerTycoon.Value then
		return false
	end

	if Player:FindFirstChild("BaseDataLoaded") and Player:FindFirstChild("SecondSacrifice") == nil and Player:FindFirstChild("Rebirthing") == nil then
		if Player.Rebirths.Value >= 999 then

	--		if Player:FindFirstChild("Sacrificed") then
	--			return false
	--		end

			local FinalLife = Player.Rebirths.Value + 1

			local StoreItems = {}

			for i,Item in pairs(game.ReplicatedStorage.Items:GetChildren()) do
				StoreItems[i] = {Quantity = nil}
			end

			local Safekeeping = _G["Safekeeping"][Player.Name] or {}

			local Inventory = _G["Inventory"][Player.Name]

			local Tag = Instance.new("BoolValue")
			Tag.Name = "Rebirthing"
			Tag.Parent = Player

			local Tycoon = getTycoon(Player)

			--_G["Inventory"][Player.Name][i] = {Quantity = nil}

			for i,Item in pairs(Tycoon:GetChildren()) do
				if Item:IsA("Model") and Item:FindFirstChild("Hitbox") ~= nil and Item:FindFirstChild("ItemId") ~= nil then
					if SafeItems[Item.ItemId.Value] then
						Add(StoreItems,Item.ItemId.Value)
					elseif RareItems[Item.ItemId.Value] then
						Add(Safekeeping,Item.ItemId.Value)
					end

					local ItemScript = Item.Model:FindFirstChildOfClass("Script")
					if ItemScript then
						ItemScript.Disabled = true
					end

					Item.Parent = workspace.DoomedItems
					spawn(function()
						wait(1 + math.random(1,40)/50)
						if Item and Item:FindFirstChild("Model") then
							local Count = 0
							for e, Child in pairs(Item.Model:GetChildren()) do
								if Child:IsA("BasePart") and Count < 10 then
									Count = Count + 1
									Child.Anchored = false
								elseif Child:IsA("Script") then
									Child:Destroy()
								end
							end
						end
						wait(5)
						if Item then
							Item:destroy()
						end
					end)

				end

			end

			for Id, Item in pairs(Inventory) do
				if Item["Quantity"] and Item.Quantity > 0 then
					print("Inventory: "..tostring(Inventory).." Safe: "..tostring(Safekeeping).." Id: "..Id)
					if SafeItems[Id] then
						Store(Inventory,StoreItems,Id)
					elseif RareItems[Id] then
						print(Inventory,Safekeeping,Id)
						Store(Inventory,Safekeeping,Id)
					end
				end
				Inventory[Id] = {Quantity = nil}
			end

			-- Default inventory
			Inventory[1] = {Quantity = 4}
			Inventory[2] = {Quantity = 1}
			Inventory[3] = {Quantity = 10}
			Inventory[21] = {Quantity = 1}
			Inventory[22] = {Quantity = 1}
			Inventory[36] = {Quantity = 3}

		--	Inventory[354] = {Quantity = 1}

			if Player:FindFirstChild("Sacrificed") == nil then
				game.ServerStorage.AwardItem:Invoke(Player,354)
				game.ReplicatedStorage.RebornEarned:FireClient(Player,"The Ultimate Sacrifice",false)
			else
				game.ReplicatedStorage.Hint:FireClient(Player,"The Ultimate Sacrifice upgrader was destroyed!")
				game.ServerStorage.AwardItem:Invoke(Player,420)
				game.ReplicatedStorage.RebornEarned:FireClient(Player,"Statue of Sacrifice",false)
			end


			-- just for extra value

			-- Return the items they deserve

			for Id, Item in pairs(StoreItems) do
				if Item["Quantity"] and Item.Quantity > 0 then
					Return(StoreItems,Inventory,Id)
					print("Returning "..Id)
				end
				StoreItems[Id] = {Quantity = nil}
			end

			_G["Safekeeping"][Player.Name] = Safekeeping
			_G["Inventory"][Player.Name] = Inventory

			print(game:GetService("HttpService"):JSONEncode(Inventory))
			print(game:GetService("HttpService"):JSONEncode(Safekeeping))


			local MoneyLib = require(game.ReplicatedStorage.MoneyLib)

			local Cash = game.ServerStorage.MoneyStorage:FindFirstChild(Player.Name)
			if Cash then
				if Player:FindFirstChild("Sacrificed") == nil then
					if FinalLife > 10000 then
						Cash.Value = 10^102
					elseif FinalLife > 5000 then
						Cash.Value = MoneyLib.ShortToLong("1DD")
					elseif FinalLife > 2000 then
						Cash.Value = MoneyLib.ShortToLong("25Qn")
					else
						Cash.Value = 50
					end
				else
					Cash.Value = 50
				end

			end


			if Player:FindFirstChild("Sacrificed") == nil then
				local FiceTag = Instance.new("BoolValue")
				FiceTag.Name = "Sacrificed"
				FiceTag.Value = true
				FiceTag.Parent = Player
			else
				local FiceTag = Instance.new("BoolValue")
				FiceTag.Name = "SecondSacrifice"
				FiceTag.Value = true
				FiceTag.Parent = Player
			end

			Player.Rebirths.Value = 0

			game.ReplicatedStorage.InventoryChanged:FireClient(Player, _G["Inventory"][Player.Name])




			local Success, Error

			print("NOW ATTEMPTING TO SAVE SACRIFICE")

			repeat
				print("ATTEMPTED SAVE")
				Success, Error = game.ReplicatedStorage.SavePlayer:Invoke(Player)
				if not Success then
					print("ERROR SAVING SACRIFICE DATA: "..Error)
					wait(5)
				end

			until Success
			print("SAVED")

			Tag:Destroy()

			spawn(function()

				if Player:FindFirstChild("SecondSacrifice") then
					game.ServerStorage.AwardBadge:Invoke(Player,849040191)
				elseif Player:FindFirstChild("Sacrificed") then
					game.ServerStorage.AwardBadge:Invoke(Player,685937164)
				end

			end)

			spawn(function()
				local Data
				if Player:FindFirstChild("SecondSacrifice") then
					Data = {Player.Name.." just performed THE SECOND SACRIFICE",{math.random(0,300)/1000,math.random(0,300)/1000,math.random(0,100)/1000},{1,1,1},{1,1,1}}
				elseif Player:FindFirstChild("Sacrificed") then
					Data = {Player.Name.." just performed THE ULTIMATE SACRIFICE",{math.random(0,10)/1000,math.random(0,10)/1000,math.random(0,10)/1000},{1,1,1},{1,1,1}}
				end

				DataStore:SetAsync("Announcement",Data)
			end)

			return true

		end
	end
	return false
end