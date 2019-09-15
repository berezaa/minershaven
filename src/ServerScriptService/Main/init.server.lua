-- Miner's Haven Main Script

--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

--game.StarterGui.GUI.Parent = game.ReplicatedStorage -- this is dumb and youre also dumb
--game.StarterGui.OldGui.Parent = game.ReplicatedStorage

workspace:WaitForChild("Tycoons")
game.ReplicatedStorage:WaitForChild("Items")
print("Loaded")
_G["Safekeeping"] = {}
_G["Inventory"] = {}

local StartingGui = game.StarterGui.GUI
StartingGui.Parent = game.ReplicatedStorage
StartingGui.Cover.Visible = true
StartingGui.Cover.BackgroundTransparency = 0
--[[
game.Players.PlayerAdded:connect(function(Player)

	Player.CharacterAdded:connect(function(Character)
		if Player:FindFirstChild("BaseDataLoaded") then
			StartingGui:Clone().Parent = Player.PlayerGui
		end
	end)

	Player.ChildAdded:connect(function(Child)
		if Child.Name == "BaseDataLoaded" then
			wait(0.3)
			StartingGui:Clone().Parent = Player.PlayerGui
		end
	end)
end)
]]

local RemoveItem = game.ReplicatedStorage.RemoveItem
local HasItem = game.ReplicatedStorage.HasItem
local GetItems = game.ReplicatedStorage.GetItems
local GetItemModel = game.ReplicatedStorage.GetItemModel
local PlaceItem = game.ReplicatedStorage.PlaceItem
local DestroyItem = game.ReplicatedStorage.DestroyItem
local FetchInventory = game.ReplicatedStorage.FetchInventory
local SellItem = game.ReplicatedStorage.SellItem
local BuyItem = game.ReplicatedStorage.BuyItem
local GetSortedItems = game.ReplicatedStorage.GetSortedItems
local Upgrade = game.ReplicatedStorage.Upgrade

local InventoryChanged = game.ReplicatedStorage.InventoryChanged


--CODE FROM LOCARD
--Modifying the Invoke function for PlaySolo to attempt to travel to a player's friend's session.

function game.ReplicatedStorage.PlaySolo.OnServerInvoke(Player,possibleFriendUserId)

	if true then
		local Success = pcall(function()
			local ReserveServer = game:GetService("TeleportService"):ReserveServer(game.PlaceId)
			game:GetService("TeleportService"):TeleportToPrivateServer(game.PlaceId,ReserveServer,{Player})
		end)
		return Success
	end

	--NEW CODE

	local function getReservedServer(userId)
		--This is where we need to attempt to get the user's ReservedServer
			--Possible options
				--Directly from data store
					--Expensive towards data store calls
				--From the player data
					--Requires fetching the player's data
		userId = userId or Player.UserId
		local reservedServer

		return reservedServer
	end

	local function Teleport(ReserveServer)
		if not ReserveServer then
			ReserveServer = game:GetService("TeleportService"):ReserveServer(game.PlaceId)
		end
		return pcall(function()
			return game:GetService("TeleportService"):TeleportToPrivateServer(game.PlaceId,ReserveServer,{Player})
		end)
	end

	if not possibleFriendUserId then

		--Player attempts to teleport to their own island
		local reservedServer

		--CODE TO GET reservedServer
		local reservedServer = getReservedServer()
		return Teleport(reservedServer)
	else
		local isAFriend = Player:IsFriendsWith(possibleFriendUserId)
		if isAFriend then

			local reservedServer = getReservedServer(possibleFriendUserId)
			return Teleport(reservedServer)
		else
			return false
		end
	end
	return false
end

for i,v in pairs(workspace.Tycoons:GetChildren()) do
	local model = Instance.new("Folder")
	model.Name = v.Name
	model.Parent = workspace.DroppedParts
end

local TycoonLib = require(game.ReplicatedStorage.TycoonLib)
getTycoon = TycoonLib.getTycoon

function getItem(Id)
	for i,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
		if v.ItemId.Value == Id then
			return v
		end
	end
	return nil
end

local getItemFromId = getItem

function game.ReplicatedStorage.MOTDRead.OnServerInvoke(Player)
	Player.MOTD.Value = game.ReplicatedStorage.MOTD.Value
end

function game.ReplicatedStorage.ToggleBoxItem.OnServerInvoke(Player, Item)
	local Value = Player:FindFirstChild("Use"..Item)
	if Value then
		Value.Value = not Value.Value
	end
end

function game.ReplicatedStorage.FakeCrate.OnServerInvoke(Player, Pos)
	if Player:FindFirstChild("Nebula") then
		local FakeCrate = game.ServerStorage.FartCrate:Clone()
		FakeCrate.Parent = workspace
		FakeCrate.CFrame = Pos
		FakeCrate.BrickColor = BrickColor.Random()
		game.Debris:AddItem(FakeCrate, 120)
	end
end

local function RoundByThree(Number)
	if math.floor(Number) == Number then
		if Number%3 == 0 then
			return Number
		elseif (Number - 1)%3 == 0 then
			return Number - 1
		elseif (Number + 1)%3 == 0 then
			return Number + 1
		end
	end
	return Number
end


local function Colliding(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and x2 < x1+w1 and y1 < y2+h2 and y2 < y1+h1
end

local function CanPlace(NewItem, Cframe, PlayerTycoon)

	local CheckRay = Ray.new(Cframe.p, Vector3.new(0,-500,0))
	local Hit = workspace:FindPartOnRayWithIgnoreList(CheckRay,{PlayerTycoon, NewItem, workspace.DroppedParts})
	if Hit and Hit:FindFirstChild("Base") and Hit.Name == PlayerTycoon.Name then

		local Test1 = Cframe:vectorToObjectSpace(NewItem.Hitbox.Size)
		local Test = Vector3.new(math.abs(Test1.x),math.abs(Test1.y),math.abs(Test1.z))


		local Region = Region3.new(Cframe.p - Test*0.49, Cframe.p + Test*0.49)

		local Parts = workspace:FindPartsInRegion3(Region, NewItem, math.huge)

		for i,Part in pairs(Parts) do
			if Part:IsDescendantOf(PlayerTycoon) and Part.Name == "Hitbox" then
				return false
			end
		end
		return true
	else
		return false
	end

end


function game.ReplicatedStorage.ToggleChatVisible.OnServerInvoke(Player)
	if Player:FindFirstChild("ChatVisible") then
		Player.ChatVisible.Value = not Player.ChatVisible.Value
	end
end

function game.ReplicatedStorage.ChangeVolume.OnServerInvoke(Player, Volume)
	Player.RadioVolume.Value = Volume
end

local function isTycoonEmpty(Tycoon)
	for i,Child in pairs(Tycoon:GetChildren()) do
		if Child:FindFirstChild("Hitbox") then
			return false
		end
	end
	return true
end

local function getNeeds(Player, Layout)
	local Inventory = _G["Inventory"][Player.Name]

	local status = true
	--local missing = ""
	local missing = {}

	local Info = game.HttpService:JSONDecode(Layout.Value)
	if Info == nil then
		return false
	end

	local Needs = {}

	for i,Item in pairs(Info) do
		local ItemId = Item.ItemId
		if Needs[ItemId] then
			Needs[ItemId] = Needs[ItemId] + 1
		else
			Needs[ItemId] = 1
		end
	end

	for ItemId,Requirement in pairs(Needs) do


		local Real = getItemFromId(ItemId)
		if Real then

			if not (Real.Tier.Value == 78 and Real.ItemType.Value == 10) then

				if Inventory[ItemId].Quantity == nil then
					status = false
					--if missing ~= "" then
						--missing = missing .. ", "
					--end
					table.insert(missing, {Id = ItemId, ItemName = Real.Name, Amount = Requirement} )

					--missing = missing .. Real.Name .. " (x "..tostring(Requirement)..")"
				elseif Inventory[ItemId].Quantity < Requirement then
					--if missing ~= "" then
					--	missing = missing .. ", "
					--end


					status = false
					local dif = Requirement - Inventory[ItemId].Quantity

					table.insert(missing, {Id = ItemId, ItemName = Real.Name, Amount = dif} )
				--	missing = missing .. Real.Name .. " (x "..tostring(dif)..")"
				end
			end

		end
	end
	return status, missing, Needs
end

local DataLib = require(game.ServerScriptService.PlayerDataGuardian.DataLib)

-- Server-side layouts
game.ReplicatedStorage.Layouts.OnServerInvoke = function(Player, Func, Arg, Arg2)

	local Tycoon = Player.ActiveTycoon.Value

	if Tycoon == nil or Tycoon ~= Player.PlayerTycoon.Value then
		return false
	end

	local Inventory = _G["Inventory"][Player.Name]

	if Func == "Check" then
		--print("Checking")

		local results = {}

		for i,Layout in pairs(Player.Layouts:GetChildren()) do
			--print(Layout.Name)

			if Layout.Value == "" or Layout.Value == "[]" then
				--print("false")
				results[Layout.Name] = false
			else
				--print("true")
				local status, missing = getNeeds(Player, Layout)

				if status then
					results[Layout.Name] = true
				else
					--print(game.HttpService:JSONEncode(missing))
					results[Layout.Name] = missing
				end
			end

		end

		return results

	elseif Func == "Load" then

		if Player:FindFirstChild("Rebirthing") or Player:FindFirstChild("Leaving") or Player:FindFirstChild("Busy") then
			return false
		end

		local ItemsToBuy = Arg2
		if ItemsToBuy and type(ItemsToBuy) == "table" and #ItemsToBuy > 0 then
			local Money = game.ServerStorage.MoneyStorage:FindFirstChild(Player.Name)
			if Money then
				local Cost = 0

				for i,Item in pairs(ItemsToBuy) do

					-- check for bad input
					if Item.Amount > 0 then
						local Real = game.ReplicatedStorage.Items:FindFirstChild(Item.Name)
						if (Real.ItemType.Value >= 1 and Real.ItemType.Value <= 4) or Real.ItemType.Value == 11 then
							Cost = Cost + Real.Cost.Value * Item.Amount
						end
					end
				end

				if Money.Value >= Cost then

					local Inventory = _G["Inventory"][Player.Name]
					if Inventory then

						Money.Value = Money.Value - Cost

						for i,Item in pairs(ItemsToBuy) do
						local Real = game.ReplicatedStorage.Items:FindFirstChild(Item.Name)
							if (Real.ItemType.Value >= 1 and Real.ItemType.Value <= 4) or Real.ItemType.Value == 11 then


						if Inventory[Real.ItemId.Value].Quantity then
							Inventory[Real.ItemId.Value].Quantity = Inventory[Real.ItemId.Value].Quantity + Item.Amount
						else
							Inventory[Real.ItemId.Value].Quantity = Item.Amount
						end
							end
						end
					end

				else
					game.ReplicatedStorage.Hint:FireClient(Player,"Failed to buy missing items (not enough money)",Color3.new(1,0.2,0.2))
				end
			end
		end


		local collisions = {}

		if Tycoon --[[and isTycoonEmpty(Tycoon)]] then

			local Layout = Player.Layouts:FindFirstChild(Arg)
			if Layout then

				local Info = game.HttpService:JSONDecode(Layout.Value)
				if Info == nil then
					return false
				end

				local Tag = Instance.new("BoolValue")
				Tag.Name = "Busy"
				Tag.Parent = Player


				--local status, _, needs = getNeeds(Player, Layout)

				local missingitems = {}

				--if status then
				if true then

					local TycoonBase = Tycoon.Base
					local TycoonTopLeft = TycoonBase.CFrame * CFrame.new(Vector3.new(TycoonBase.Size.x/2, 0, TycoonBase.Size.z/2))

					for i,Object in pairs(Info) do
						local ItemId = Object.ItemId
						local Real = getItemFromId(ItemId)

						if Real and Inventory[ItemId].Quantity and Inventory[ItemId].Quantity > 0 then

							if not (Real.Tier.Value == 78 and Real.ItemType.Value == 10) then

								Object.Position[1] = tonumber(Object.Position[1])
								Object.Position[2] = tonumber(Object.Position[2])
								Object.Position[3] = tonumber(Object.Position[3])

								local HitboxDirection = Vector3.new()
								local DirectionValue = Object.Position[4]

								local Item = Real:clone()

								local Position = TycoonTopLeft * Vector3.new(Object.Position[1], Object.Position[2], Object.Position[3])
								local lookVector = Vector3.new(Object.Position[4],Object.Position[5],Object.Position[6])
								local CoordinateFrame = CFrame.new(Position, Position + (lookVector * 5))


								-- Redundant check
								if CanPlace(Item, CoordinateFrame, Tycoon) and Inventory[ItemId].Quantity and Inventory[ItemId].Quantity > 0 then
									Item.Parent = Tycoon
									Item.PrimaryPart = Item.Hitbox
									Item:SetPrimaryPartCFrame(CoordinateFrame)

									Inventory[ItemId].Quantity = Inventory[ItemId].Quantity - 1

									for i,v in pairs(Item.Model:GetChildren()) do
										if v:IsA("BasePart") and v.Name == "Colored" then
											v.BrickColor = Player.TeamColor
										end
										if v:IsA("Script") then
											v.Disabled = false
										end
									end

									Item.Hitbox.Transparency = 1
									Item.Hitbox.CanCollide = false
								else
									game.ReplicatedStorage.Hint:FireClient(Player,"Failed to place "..Real.Name.." (collision)",Color3.new(1,0.5,0.5))
									local collision = {Item.Hitbox.Size, CoordinateFrame}
									table.insert(collisions, collision)
									Item:Destroy()
								end

							end
						else
							missingitems[Real.Name] = (missingitems[Real.Name] and (missingitems[Real.Name] + 1)) or 1
						end
					end
					for name,amount in pairs(missingitems) do
						game.ReplicatedStorage.Hint:FireClient(Player,"Failed to place "..name.." (missing)(x"..tostring(amount)..")",Color3.new(1,0.5,0.5))
					end
					--Erases a layout after using it:
					--Layout.Value = "[]"
					Tag:Destroy()
					return true, collisions
				end
			end
		end
	elseif Func == "Save" then

		if Player:FindFirstChild("Rebirthing") or Player:FindFirstChild("Leaving") then
			return false
		end

		--print("Saving")
		local Layout = Player.Layouts:FindFirstChild(Arg)
		if Layout and Tycoon then
			if Layout.Value == "" or Layout.Value == "[]" then
				--print("Tycoon's good")
				local Items = Tycoon:GetChildren()
				if #Items <= 202 then
					--print("Right amount of items")

					local Table = DataLib.TycoonToTable(Tycoon)
					if Table and #Table > 0 and #Table < 202 then
						--print("ok")
						Layout.Value = game.HttpService:JSONEncode(Table)
						--print(Layout.Value)
						--print("Done")
						return true
					end

				end
			else
				Layout.Value = "[]"
				return true
			end
		end
	end
	return false
end



function BuyItem.OnServerInvoke(Player, ItemName, Quantity)


	Quantity = Quantity or 1
	if Quantity < 1 then
		Quantity = 1
	end
	if Quantity > 99 then
		Quantity = 99
	end

	local RealItem = game.ReplicatedStorage.Items:FindFirstChild(ItemName) -- We're not going to trust them with item info!

	if RealItem and RealItem.ItemType.Value == 6 and RealItem.Tier.Value == 100 then
		local Inventory = _G["Inventory"][Player.Name]

		if RealItem:FindFirstChild("EnchantCost") and Inventory then
			-- Check if they can buy it
			for i,Child in pairs(RealItem.EnchantCost:GetChildren()) do

				local Cost = Child.Value

				if Child.Name == "Shards" then
					if Player.Shards.Value < Cost then
						return false
					end
				else
					local Id = tonumber(Child.Name)
					if Id then
						local Real = getItemFromId(tonumber(Child.Name))
						if Real then
							local Entry = Inventory[Id]
							if not(Entry and Entry.Quantity and Entry.Quantity >= Cost) then
								return false
							end
						end
					end
				end
			end
			-- They've got it, now charge them
			for i,Child in pairs(RealItem.EnchantCost:GetChildren()) do
				local Cost = Child.Value

				if Child.Name == "Shards" then
					Player.Shards.Value = Player.Shards.Value - Cost

					--GameAnalytics reporting
					spawn(function()
						local Change = -Cost
						local ProductName = RealItem.ItemName.Value:gsub(" ", "_"):lower()

						ProductName = ProductName or "unknown"
						game.ServerStorage.CurrencyEvent:Fire(Player, "Shards", Change, "enchantment", ProductName)
					end)
				else
					local Id = tonumber(Child.Name)
					if Id then
						local Real = getItemFromId(tonumber(Child.Name))
						if Real then
							local Entry = Inventory[Id]
							Entry.Quantity = Entry.Quantity - Cost
						end
					end
				end
			end
			-- Done charging them, lets award the item.
			game.ServerStorage.AwardItem:Invoke(Player,RealItem.ItemId.Value)
			game.ServerStorage.AwardBadge:Invoke(Player,1911925958)
			game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." forged a "..RealItem.Name.."!")
			return true

		end

		return false
	end

	if not TycoonLib.hasPermission(Player, "Buy") then
		return false
	end

	local Tycoon = Player.ActiveTycoon.Value
	if Tycoon == nil then
		return false
	end

	local Owner = game.Players:FindFirstChild(Tycoon.Owner.Value)
	if Owner == nil then
		return false
	end

	if RealItem and RealItem.ItemType.Value ~= 6 and RealItem.ItemType.Value ~= 99 and RealItem.ItemType.Value ~= 10 then
		if RealItem:FindFirstChild("Crystals") == nil then
			local cost = RealItem.Cost.Value * Quantity
			local money = game.ServerStorage.MoneyStorage:FindFirstChild(Owner.Name)
			if money then
				if Player.Points.Value < RealItem.ReqPoints.Value and Player:FindFirstChild("Premium") == nil then
					return false
				end
				if RealItem:FindFirstChild("RATRequirement") and Player:GetRankInGroup(7013) < RealItem.RATRequirement.Value then
					return false
				end
				if money.Value > cost then
					if RealItem.ItemId.Value == 7 then
						game.ServerStorage.AwardBadge:Invoke(Player, 258264216)
					end
					money.Value = money.Value - cost

					game.ServerStorage.AwardItem:Invoke(Owner,RealItem.ItemId.Value,Quantity)
					--
					--local Inventory = _G["Inventory"][Owner.Name]

				--	if Inventory[RealItem.ItemId.Value].Quantity then
				--		Inventory[RealItem.ItemId.Value].Quantity = Inventory[RealItem.ItemId.Value].Quantity + Quantity
				--	else
				--		Inventory[RealItem.ItemId.Value].Quantity = Quantity
				--	end

				--	_G["Inventory"][Owner.Name] = Inventory
					-- todo: completely redo inventorychanged to fire to everyone on the base
				--	InventoryChanged:FireClient(Player,RealItem.ItemId.Value)
					return true
				end
			end
		else
			local cost = RealItem.Crystals.Value * Quantity



			if Owner.Crystals.Value >= cost and Player.Points.Value >= RealItem.ReqPoints.Value then
				Owner.Crystals.Value = Owner.Crystals.Value - cost
				--[[
				local Inventory = _G["Inventory"][Owner.Name]
				if Inventory[RealItem.ItemId.Value].Quantity then
					Inventory[RealItem.ItemId.Value].Quantity = Inventory[RealItem.ItemId.Value].Quantity + Quantity
				else
					Inventory[RealItem.ItemId.Value].Quantity = Quantity
				end

				_G["Inventory"][Owner.Name] = Inventory
				InventoryChanged:FireClient(Owner,Inventory,RealItem.ItemId.Value)
				]]
				game.ServerStorage.AwardItem:Invoke(Owner,RealItem.ItemId.Value,Quantity)
				-- Game Analytics Currency Reporting
				local CrystalsGained = -cost
				local ProductName = RealItem.Name:gsub(" ", "_"):lower()
				if true then
					ProductName = ProductName or "unknown"
					game.ServerStorage.CurrencyEvent:Fire(Player, "Crystals", CrystalsGained, "ucshop", ProductName)
				end
				-- Game Analytics Currency Reporting

				return true
			end

		end
	end

	return false
end

local UpgradeLevel = function(Player)

	if not TycoonLib.hasPermission(Player, "Owner") then
		return false
	end

	local Tycoon = Player.PlayerTycoon.Value
	local PlayerData = game.ReplicatedStorage.PlayerData:FindFirstChild(Tycoon.Name)
	if PlayerData then
		local level = PlayerData.DropLevel.Value
		local price = game.ReplicatedStorage.Upgrades:FindFirstChild(tostring(level+1))
		if price then
			local cashmoney = game.ServerStorage.MoneyStorage:FindFirstChild(Player.Name)
			if cashmoney then
				if cashmoney.Value > price.Value then
					cashmoney.Value = cashmoney.Value - price.Value
					PlayerData.DropLevel.Value = PlayerData.DropLevel.Value + 1
					return true
				end
			end
		end
	end
	return false
end

Upgrade.OnServerInvoke = UpgradeLevel

function itemInTycoon(Player,Id)
	local Tycoon = Player.PlayerTycoon.Value
	if Tycoon then
		for i,v in pairs(Tycoon:GetChildren()) do
			if v:FindFirstChild("ItemId") and v.ItemId.Value == Id then
				return true
			end
		end
	end
	return false
end

function game.ReplicatedStorage.ChangeSetting.OnServerInvoke(Player, Setting, Value)
	if Player and Player:FindFirstChild("PlayerSettings") then
		local Obj = Player.PlayerSettings:FindFirstChild(Setting)
		if Obj then
			local Success = pcall(function()
				Obj.Value = Value
			end)
			return Success
		end
	end
end

function SellItem.OnServerInvoke(Player, Object)

	if not TycoonLib.hasPermission(Player, "Sell") then
		return false
	end

	local Tycoon = Player.ActiveTycoon.Value
	if Tycoon == nil then
		return false
	end

	local Owner = game.Players:FindFirstChild(Tycoon.Owner.Value)
	if Owner == nil then
		return false
	end

	if Tycoon and Object ~= nil and Object.Parent ~= nil and Object:IsDescendantOf(Tycoon) then
		if Object.ItemType.Value ~= 6 and Object.ItemType.Value ~= 99 then
			local Id = Object.ItemId.Value
			local Price = math.floor(Object.Cost.Value * 0.35)

			if Object.ItemType.Value == 4 then
				Price = 0
			end

			local Money = game.ServerStorage.MoneyStorage:FindFirstChild(Owner.Name)
			if Money then
				Money.Value = Money.Value + Price
			end
			local Inventory = _G["Inventory"][Owner.Name]
			if Inventory[Id].Quantity then
				if Inventory[Id].Quantity == 0 and not itemInTycoon(Owner,Id) then
					Inventory[Id].Quantity = nil
				end
			end
			InventoryChanged:FireClient(Player,Inventory)
			Object:Destroy()
			return true
		end
	end
	return false
end

function game.ReplicatedStorage.SellAll.OnServerInvoke(Player,Id)

	if not TycoonLib.hasPermission(Player, "Owner") then
		return false
	end

	local Item = getItem(Id)
	if Item and Item.ItemType.Value ~= 6 and Item.ItemType.Value ~= 99 then
		local Inventory = _G["Inventory"][Player.Name]
		if Inventory[Id] ~= nil and Inventory[Id].Quantity ~= nil then
			local count = Inventory[Id].Quantity
			local Object = getItem(Id)
			local Money = game.ServerStorage.MoneyStorage:FindFirstChild(Player.Name)
			if count > 0 and Object ~= nil and Object.Cost ~= nil and Object.Cost.Value > 0 and Money then
				Inventory[Id].Quantity = nil
				local Price = math.floor(Object.Cost.Value * 0.3 * count)

				if Item.ItemType.Value == 4 then
					Price = 0
				end

				Money.Value = Money.Value + Price
				InventoryChanged:FireClient(Player,Inventory)
				return true
			end
		end
	end
	return false
end

function FetchInventory.OnServerInvoke(Player)

	local Tycoon = getTycoon(Player)


	if Tycoon then
		local Inventory = _G["Inventory"][Tycoon.Owner.Value]
		if Inventory then
			return Inventory
		end
	end

	return nil
end

function GetSortedItems.OnServerInvoke(Player)
	return require(game.ReplicatedStorage.ShopControl)
end

local PlayerDebounce = {}

function game.ReplicatedStorage.DestroySelected.OnServerInvoke(Player, Items)

	if not TycoonLib.hasPermission(Player, "Build") then
		return false
	end

	local Tycoon = Player.ActiveTycoon.Value

	if Tycoon == nil then
		return false
	end

	local Owner = game.Players:FindFirstChild(Tycoon.Owner.Value)

	if Owner == nil then
		return false
	end

	if PlayerDebounce[Player.Name] ~= false then
		PlayerDebounce[Player.Name] = false
		spawn(function()
			wait(0.1)
			PlayerDebounce[Player.Name] = true
		end)
		local Tycoon = getTycoon(Player)
		for i,v in pairs(Items) do
			if Tycoon and v:IsDescendantOf(Tycoon) then
				local Id = v.ItemId.Value
				if _G["Inventory"][Owner.Name][Id].Quantity then
					_G["Inventory"][Owner.Name][Id].Quantity = _G["Inventory"][Owner.Name][Id].Quantity + 1
				else
					_G["Inventory"][Owner.Name][Id].Quantity = 1
				end
				v:Destroy()

			end
		end
		InventoryChanged:FireClient(Player,_G["Inventory"][Owner.Name])
		return true
	end
	return false
end

function DestroyItem.OnServerInvoke(Player, v)


	if not TycoonLib.hasPermission(Player, "Build") then
		return false
	end

	local Tycoon = Player.ActiveTycoon.Value

	if Tycoon == nil then
		return false
	end

	local Owner = game.Players:FindFirstChild(Tycoon.Owner.Value)

	if Owner == nil then
		return false
	end

	if PlayerDebounce[Player.Name] ~= false and v ~= nil and v.Parent ~= nil then
		PlayerDebounce[Player.Name] = false
		spawn(function()
			wait(0.1)
			PlayerDebounce[Player.Name] = true
		end)
		local Tycoon = getTycoon(Player)
		if Tycoon and v:IsDescendantOf(Tycoon) then

			--todo: implement special methods
			if v:FindFirstChild("OnDestroy") then
				require(v.OnDestroy)()
			end

			local Id = v.ItemId.Value
			if _G["Inventory"][Owner.Name][Id].Quantity then
				_G["Inventory"][Owner.Name][Id].Quantity = _G["Inventory"][Owner.Name][Id].Quantity + 1
			else
				_G["Inventory"][Owner.Name][Id].Quantity = 1
			end
			InventoryChanged:FireClient(Player,_G["Inventory"][Owner.Name])
			v:Destroy()
			return true
		end
	end
	return false
end



function game.ReplicatedStorage.DestroyAll.OnServerInvoke(Player)

	if not TycoonLib.hasPermission(Player, "Owner") then
		return false
	end

	if PlayerDebounce[Player.Name] ~= false then
		PlayerDebounce[Player.Name] = false
		local tycoon = getTycoon(Player)
		if tycoon then
			local count = 1
			for i,v in pairs(tycoon:GetChildren()) do
				if v:FindFirstChild("ItemId") then
					local Id = v.ItemId.Value
					if _G["Inventory"][Player.Name][Id].Quantity then
						_G["Inventory"][Player.Name][Id].Quantity = _G["Inventory"][Player.Name][Id].Quantity + 1
					else
						_G["Inventory"][Player.Name][Id].Quantity = 1
					end
					v:Destroy()
					count = count + 1
					if count >= 50 then
						wait()
						count = 1
					end
				end
			end
			InventoryChanged:FireClient(Player,_G["Inventory"][Player.Name])
		end
		wait(0.3)
		PlayerDebounce[Player.Name] = true
	end
end
--[[

function AddItem.OnServerInvoke(Player, Id, Quantity)
	if not _G["Inventory"][Player.Name][Id] then
		_G["Inventory"][Player.Name][Id] = {}
	end
	_G["Inventory"][Player.Name][Id].Quantity = _G["Inventory"][Player.Name][Id].Quantity + Quantity
	InventoryChanged:FireClient(Player)
end
]]

function RemoveItem.OnServerInvoke(Player, Id, Quantity)
	return false -- smh
	--[[
	if not _G["Inventory"][Player.Name][Id] then
		_G["Inventory"][Player.Name][Id] = {}
	end
	_G["Inventory"][Player.Name][Id].Quantity = _G["Inventory"][Player.Name][Id].Quantity - Quantity
	InventoryChanged:FireClient(Player)
	]]
end

workspace.ChildAdded:connect(function(Child)
	if Child:IsA("Tool") then
		spawn(function()
			wait(20)
			if Child and Child.Parent == workspace then
				Child:Destroy()
			end
		end)
	end
end)



function HasItem.OnServerInvoke(Player, Id)
	local Tycoon = Player.ActiveTycoon.Value
	if Tycoon then
		if Id == -1 then
			return -1
		elseif _G["Inventory"][Tycoon.Owner.Value] and _G["Inventory"][Tycoon.Owner.Value][Id] and _G["Inventory"][Tycoon.Owner.Value][Id].Quantity then
			return _G["Inventory"][Tycoon.Owner.Value][Id].Quantity
		else
			return -1
		end
	end
end

function GetItemModel.OnServerInvoke(Player, Id)

	for i, Item in pairs(game.ReplicatedStorage.Items:GetChildren()) do

		if Item:IsA("Model") and Item:FindFirstChild("ItemId") then

			if Item.ItemId.Value == Id then
				return Item
			end
		end
	end
	return nil
end

function GetItems.OnServerInvoke(Player)
	local Tycoon = getTycoon(Player)
	if Tycoon then
		return _G["Inventory"][Tycoon.Owner.Value]
	end
end


function PlayerHasItem(Player,ItemId)
	local Tycoon = getTycoon(Player)
	if Tycoon then
		return _G["Inventory"][Tycoon.Owner.Value][ItemId].Quantity ~= nil and _G["Inventory"][Tycoon.Owner.Value][ItemId].Quantity > 0
	end
end

function game.ReplicatedStorage.ToggleMines.OnServerInvoke(Player)
	if Player:FindFirstChild("MinesActivated") then
		Player.MinesActivated.Value = not Player.MinesActivated.Value
		return true
	end
end




function PlaceItem.OnServerInvoke(Player, ItemName, Cframe)
	local Parent = Player.ActiveTycoon.Value
--	print("HI")
	if not TycoonLib.hasPermission(Player, "Build") then
		print('does not have build permission')
		return false
	end
--	print("OOPS")

	local PlayerTycoon = getTycoon(Player)

	local Owner = game.Players:FindFirstChild(PlayerTycoon.Owner.Value)
	if Owner == nil then
		return false
	end

	local Item = game.ReplicatedStorage.Items:FindFirstChild(ItemName)
	if Item then
		if PlayerHasItem(Owner,Item.ItemId.Value) then
			local NewItem = Item:Clone()

			NewItem.Hitbox.Transparency = 1
			NewItem.Hitbox.CanCollide = false

			NewItem.PrimaryPart = NewItem.Hitbox
			NewItem:SetPrimaryPartCFrame(Cframe)

			local Hitbox = NewItem.Hitbox

			if CanPlace(NewItem, Cframe, PlayerTycoon) then
				for i,v in pairs(NewItem.Model:GetChildren()) do
					if v.Name == "Colored" then
						v.BrickColor = Player.TeamColor
					elseif v:IsA("Script") then
						v.Disabled = false
					end
				end


				local Id = NewItem.ItemId.Value


				local Inventory = _G["Inventory"][Owner.Name]

				if Inventory[Id].Quantity and Inventory[Id].Quantity > 0 then
					Inventory[Id].Quantity = Inventory[Id].Quantity - 1
				else
					NewItem:Destroy()
					return false
				end


				InventoryChanged:FireClient(Player, Inventory)
				spawn(function()
					if Player.userId > 0 then
						game.ServerStorage.AwardBadge:Invoke(Player,258262122)
						if #PlayerTycoon:GetChildren() > 50 then
							game.ServerStorage.AwardBadge:Invoke(Player,697782412)
						end
					end
				end)
				NewItem.Parent = PlayerTycoon
				spawn(function()
					wait(0.1)
					if NewItem and NewItem:FindFirstChild("OnPlace") and NewItem.OnPlace:IsA("Sound") then
						NewItem.OnPlace:Play()
					end
				end)

				if NewItem.PrimaryPart:FindFirstChild("AdjustableHeight") then
					--Adjust the legs
					for i,v in next,NewItem.Model:GetChildren() do
						if v.Name == "Leg" then
							--Adjust the leg
							local topLeg = Vector3.new(v.Position.x,v.Position.y + v.Size.y*.5,v.Position.z)
							local rayStart = topLeg + Vector3.FromNormalId(Enum.NormalId.Top)
							local r = Ray.new(rayStart,Vector3.FromNormalId(Enum.NormalId.Bottom)*(v.Size.y + 1))

							local t = {}
							for i,v in next,Parent:GetChildren() do
								if (v.ClassName == "Model" and v ~= NewItem and v:FindFirstChild("Platform")) or v:IsA"BasePart" and v.Name == "Base" then
									t[#t+1] = v
								end
							end

							local part,intersect = workspace:FindPartOnRayWithWhitelist(r,t)
							if part and intersect then
								v.Size = Vector3.new(v.Size.x,topLeg.y - intersect.y,v.Size.z)
								v.CFrame = CFrame.new(v.Position.x,topLeg.y - v.Size.y*.5,v.Position.z)
							end
						end
					end
				end

				return NewItem
			else
				NewItem:Destroy()
				return nil
			end
		end


	end

end

function game.ReplicatedStorage.ToggleFavorite.OnServerInvoke(Player, ItemId)
	if not TycoonLib.hasPermission(Player, "Owner") then
		game.ReplicatedStorage.Hint:FireClient(Player,"Only the base owner can set favorite items.")
		return false
	end
	local Tycoon = getTycoon(Player)
	if Tycoon then
		local Inventory = _G["Inventory"][Tycoon.Owner.Value]
		if Inventory[ItemId].Favorite then
			Inventory[ItemId].Favorite = nil
		else
			Inventory[ItemId].Favorite = true
		end
--		game.ReplicatedStorage.InventoryChanged:FireClient(Player)
		return true
	end
end

function game.ReplicatedStorage.PlaceMultiple.OnServerInvoke(Player,Items)
	local Tycoon = Player.ActiveTycoon.Value
	if Tycoon == nil then
		return false
	end

	local Owner = game.Players:FindFirstChild(Tycoon.Owner.Value)
	if Owner == nil then
		return false
	end

	print("hi")

	if not TycoonLib.hasPermission(Player, "Build") then
		return false
	end



	print("ello")


	local Inventory = _G["Inventory"][Owner.Name]

	local Success = true

	local RealItems = {}

	for i,Item in pairs(Items) do

		local RealItem = game.ReplicatedStorage.Items:FindFirstChild(Item[1])

		print('coolio')

		local Id = RealItem.ItemId.Value
		if PlayerHasItem(Owner,Id) then
			print("lols")
			local Repre = RealItem:Clone()
			Repre.PrimaryPart = Repre.Hitbox
			Repre:SetPrimaryPartCFrame(Item[2])
			if CanPlace(Repre, Item[2], Tycoon) then
				Repre.Parent = Tycoon
				Repre.PrimaryPart = Repre.Hitbox
				Repre:SetPrimaryPartCFrame(Item[2])
				Repre.Hitbox.CanCollide = false
				Repre.Hitbox.Transparency = 1

				if Inventory[Id].Quantity then
					Inventory[Id].Quantity = Inventory[Id].Quantity - 1
				end

				for i,v in pairs(Repre.Model:GetChildren()) do
					if v.Name == "Colored" then
						v.BrickColor = Player.TeamColor
					elseif v:IsA("Script") then
						v.Disabled = false
					end
				end

				table.insert(RealItems,Repre)


			else
				Repre:Destroy()
			end
		end

	end
	InventoryChanged:FireClient(Player, Inventory)
	return RealItems

end

local Teams = game:GetService("Teams")

function GetTeamFromColor(Color)
	for i, Team in pairs(Teams:GetTeams()) do
		if Team.TeamColor == Color then
			return Team
		end
	end
	return nil
end

function teamCheck(Color)
	if tostring(Color):sub(#tostring(Color) - 5):lower() == "very black" or tostring(Color):sub(#tostring(Color) - 5):lower() == "black" or tostring(Color):sub(#tostring(Color) - 5):lower() == "white" then
		return false
	end
	for i,v in pairs(game.Teams:GetChildren()) do
		if v.TeamColor == Color then
			return false
		end
	end
	return true
end

function pickColor()
	local Colors = script.PossibleColors:GetChildren()
	for i=1,#Colors do
		local Color = Colors[math.random(1,#Colors)]
		if teamCheck(Color.Value) then
			return Color.Value
		end
	end
	return BrickColor.new("White")
end

local function getOwnerFromTycoon(Tycoon)
	for i,Player in pairs(game.Players:GetPlayers()) do
		if Player.PlayerTycoon.Value == Tycoon then
			return Player
		end
	end
end

workspace.DroppedParts.DescendantAdded:connect(function(Part)
	if Part:IsA("BasePart") then
		local Tycoon = workspace:FindFirstChild(Part.Parent.Name)
		if Tycoon then
			local Owner = getOwnerFromTycoon(Tycoon)
			if Owner then
				Part:SetNetworkOwner(Owner)
			end
		end
	end
end)


function playerAdded(Player)
	if #game.Players:GetChildren() > 6 then
		wait()
		Player:Kick("This server is full")
	else
		local OwnedTycoon
		for i, Tycoon in pairs(game.Workspace.Tycoons:GetChildren()) do
			if Tycoon.Owner.Value == "" then

				for i,v in pairs(Tycoon:GetChildren()) do -- Clear all existing items
					if v:IsA("Model") or v:IsA("BoolValue") or v:IsA("IntValue") then
						v:Destroy()
					end
				end

				Tycoon.Owner.Value = Player.Name
				OwnedTycoon = Tycoon
				local TycoonValue = Instance.new("ObjectValue")
				TycoonValue.Name = "PlayerTycoon"
				TycoonValue.Value = Tycoon
				TycoonValue.Parent = Player

				Tycoon.Base.Material = "Slate"
				Tycoon.Base.BrickColor = BrickColor.new("Medium stone grey")

				local OreDropTag = Instance.new("IntValue")
				OreDropTag.Name = "OreDropped"
				OreDropTag.Parent = Player

				local CustomMusic = Instance.new("IntValue")
				CustomMusic.Name = "SpecialMusic" -- thats not at all confusing
				CustomMusic.Value = 0
				CustomMusic.Parent = Tycoon

				local PartStore = workspace.DroppedParts:FindFirstChild(Tycoon.Name)
				if PartStore then
					PartStore.ChildAdded:connect(function()
						if OreDropTag.Value < 10000 then
							OreDropTag.Value = OreDropTag.Value + 1
						end
					end)
					local PlayerName = Player.Name
					spawn(function()
						while wait(600) do
							if OreDropTag and OreDropTag.Value > 0 and Tycoon and Tycoon.Owner.Value == PlayerName then
								pcall(function()
									local Today = math.floor(os.time()/(60*60*24))
									local OrderedDataStore = game:GetService("DataStoreService"):GetOrderedDataStore("OreMined"..tostring(Today))
									OrderedDataStore:IncrementAsync(tostring(Player.userId),(OreDropTag.Value))
									local OrderedDataStore = game:GetService("DataStoreService"):GetOrderedDataStore("OreMinedAllTime")
									OrderedDataStore:IncrementAsync(tostring(Player.userId),(OreDropTag.Value))
									print("leaderboard posted: "..OreDropTag.Value)
									OreDropTag.Value = 0
								end)
							else
								break
							end

						end
					end)
				end

				break
			end
		end

	--	Player.CharacterAdded:connect(function(Char)
	--		local Torso = Char:WaitForChild("Torso")
	--		wait()
	--		Torso.CFrame = Player.PlayerTycoon.Value.Base.CFrame + Vector3.new(0, 300, 0)
	--	end)

		local Team = Instance.new("Team")
		Team.Name = Player.Name .. "'s Factory"
		local TColor = pickColor()
		Team.TeamColor = TColor
		Player.TeamColor = Team.TeamColor
		Player.Neutral = false
		Team.Parent = game.Teams
	end
end

game.Players.PlayerAdded:connect(playerAdded)

for i,v in pairs(game.Players:GetChildren()) do
	playerAdded(v)
end

game.Players.PlayerRemoving:connect(function(Player)

	local Team = GetTeamFromColor(Player.TeamColor)
	wait()
	pcall(function()
		Team:Destroy()
	end)
end)

math.randomseed(tick())
local Collect = game:GetService("CollectionService")

for i, Factory in pairs(game.Workspace.Tycoons:GetChildren()) do
	local TycoonBase = Factory:FindFirstChild("Base")
	if TycoonBase then
		TycoonBase.CFrame = CFrame.new(TycoonBase.Position)
		TycoonBase.Touched:connect(function(hit)
			if Collect:HasTag(hit,"DroppedOre") then
				for i=1,5 do
					wait()
					hit.Transparency = hit.Transparency + 0.2
				end
				hit:Destroy()
			end
		end)
	end
end


