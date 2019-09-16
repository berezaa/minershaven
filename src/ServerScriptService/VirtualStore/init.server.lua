--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

function getPlayer(id)
	for i,v in pairs(game.Players:GetChildren()) do
		if v.userId == id then
			return v
		end
	end
	return nil
end

function getItem(Id)
	for i,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
		if v.ItemId.Value == Id then
			return v
		end
	end
	return nil
end

function awardItem(Player, ItemId, Amount)
	Amount = Amount or 1
	local Item = getItem(ItemId)
	if Item then
		if _G["Inventory"][Player.Name] ~= nil and _G["Inventory"][Player.Name][ItemId] ~= nil and _G["Inventory"][Player.Name][ItemId].Quantity ~= nil then
			_G["Inventory"][Player.Name][ItemId].Quantity = _G["Inventory"][Player.Name][ItemId].Quantity + Amount
		else
			_G["Inventory"][Player.Name][ItemId].Quantity = Amount
		end
		game.ReplicatedStorage.ItemObtained:FireClient(Player,Item,Amount)
		--game.ReplicatedStorage.Hint:FireClient(Player,"You were awarded "..Amount.." "..Item.Name..".",nil,Color3.new(0.5,0.5,0),"Obtained")
		game.ReplicatedStorage.InventoryChanged:FireClient(Player,_G["Inventory"][Player.Name],ItemId)
		return true
	else
		print("Could not find item")
	end
	return false
end




game.ServerStorage.AwardItem.OnInvoke = awardItem

local Badges = {}

local function getBadgeById(BadgeId)
	for i,Badge in pairs(game.ReplicatedStorage.Badges:GetChildren()) do
		if Badge.Value == BadgeId then
			return Badge
		end
	end
end

function game.ServerStorage.AwardBadge.OnInvoke(Player, BadgeId)
	spawn(function()
		local BadgeString = "Badge"..tostring(BadgeId)
		if Player:FindFirstChild(BadgeString) == nil then
			local Tag = Instance.new("BoolValue")
			Tag.Name = BadgeString
			Tag.Parent = Player
			if not game.BadgeService:UserHasBadge(Player.userId, BadgeId) then
				if Badges[BadgeString] == nil then
					Badges[BadgeString] = game.MarketplaceService:GetProductInfo(BadgeId)
				end
				local Badge = Badges[BadgeString]
				if Badge then
					game.BadgeService:AwardBadge(Player.userId, BadgeId)
					game.ReplicatedStorage.BadgeEarned:FireClient(Player, BadgeId)

					local Real = getBadgeById(BadgeId)
					if Real then
						game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." got the "..Real.Name.." badge!")
					end

					--game.ReplicatedStorage.Hint:FireClient(Player,"Badge obtained: "..Badge.Name,nil,Color3.new(0,0.2,0.5))
					local Tag = Instance.new("BoolValue")
					Tag.Name = BadgeString
					Tag.Parent = Player

					game.ReplicatedStorage.BadgeAwardedNew:FireClient(Player, BadgeId)

				end
			end
		end
	end)
end

game.ReplicatedStorage.RemoteDrop.OnServerEvent:Connect(function(Player)
	game.ServerStorage.AwardBadge:Invoke(Player,1993527293)
end)

function PlayerAdded(Player)
	local GivingTo = Instance.new("ObjectValue",Player)
	GivingTo.Name = "Giving"
	GivingTo.Value = nil

	for i,Badge in pairs(game.ReplicatedStorage.Badges:GetChildren()) do
		local BadgeString = "Badge"..tostring(Badge.Value)
		if Player:FindFirstChild(BadgeString) == nil then
			if game.BadgeService:UserHasBadge(Player.userId, Badge.Value) then
				local Tag = Instance.new("BoolValue")
				Tag.Name = BadgeString
				Tag.Parent = Player
			end
		end
	end
end
game.Players.PlayerAdded:connect(PlayerAdded)
for i,v in pairs(game.Players:GetPlayers()) do
	PlayerAdded(v)
end

function Check(Target)
	if Target ~= nil then
		return Target.Name
	end
	return nil
end

local DataStore = game:GetService("DataStoreService"):GetDataStore("GlobalAnnouncement")


local AssetCache = {}

function GetCache(AssetId)
	for i,Ast in pairs(AssetCache) do
		if Ast.AssetId == AssetId then
			return Ast
		end
	end
end

game.MarketplaceService.PromptPurchaseFinished:connect(function(Player, assetId, isPurchased)
	if isPurchased then
		if assetId == 268427885 then
			Player:LoadCharacter()
			if Player:FindFirstChild("Premium") == nil then
				local tag = Instance.new("BoolValue",Player)
				tag.Name = "Premium"
			end
			spawn(function()
				wait(1)
				game.ReplicatedStorage.Hint:FireClient(Player,"Premium Miner perks unlocked!",nil,Color3.new(0.4,0.4,0),"TierUnlock")
			end)
			local Data = {Player.Name.." is now a Premium miner!",{1,1,0.7},{0.3,0.3,0},{0.5,0.5,0}}
			DataStore:SetAsync("Announcement",Data)
		elseif assetId == 280971169 then
			Player:LoadCharacter()
			if Player:FindFirstChild("SwordMaster") == nil then
				local tag = Instance.new("BoolValue",Player)
				tag.Name = "SwordMaster"
			end
			local Data = {Player.Name.." is now a Sword Master!",{1,0.7,1},{0.3,0,0.3},{0.5,0,0.5}}
			DataStore:SetAsync("Announcement",Data)
		elseif assetId == 270999180 then
			Player:LoadCharacter()
			if Player:FindFirstChild("Executive") == nil then
				local tag = Instance.new("BoolValue",Player)
				tag.Name = "Executive"
			end
			spawn(function()
				wait(1)
				game.ReplicatedStorage.Hint:FireClient(Player,"Executive Miner perks unlocked!",nil,Color3.new(0.5,0,0),"TierUnlock")
				if Player:FindFirstChild("BaseSize") and Player.BaseSize.Value ~= 186 then
					Player.BaseSize.Value = 186
				end
			end)


			local Data = {Player.Name.." is now an Executive miner!",{1,0.7,0.7},{0.3,0,0},{0.5,0,0}}

			DataStore:SetAsync("Announcement",Data)
		elseif assetId == 271558969 then
			if Player:FindFirstChild("ShoutColor") == nil then
				local tag = Instance.new("BoolValue",Player)
				tag.Name = "ShoutColor"
			end
			game.ReplicatedStorage.Hint:FireClient(Player,"Colored shouting unlocked!")
		elseif assetId == 1044027953 then
			if Player:FindFirstChild("BaseRadio") == nil then
				local tag = Instance.new("BoolValue",Player)
				tag.Name = "BaseRadio"
			end
			game.ReplicatedStorage.Hint:FireClient(Player,"Base radio unlocked!")
		elseif assetId == 304936437 then
			local tag = Instance.new("BoolValue",Player)
			tag.Name = "VIP"
			tag.Value = true
			game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." is now a V.I.P. Miner!")
			spawn(function()
				wait(1)
				game.ReplicatedStorage.Hint:FireClient(Player,"V.I.P. Miner perks unlocked!",nil,Color3.new(0,0.1,0.4),"TierUnlock")
			end)
		end

		local AssetInfo = GetCache(assetId)
		if AssetInfo == nil then
			AssetInfo = game:GetService("MarketplaceService"):GetProductInfo(assetId)
			if AssetInfo["AssetId"] and AssetInfo["AssetId"] == assetId then
				table.insert(AssetCache,AssetInfo)
			end
		end
		if AssetInfo["IsForSale"] and AssetInfo["Name"] and AssetInfo["PriceInRobux"] then
			game.ServerStorage.PurchaseMade:Fire(Player, "Item", AssetInfo["Name"], AssetInfo["PriceInRobux"])
		end
	end
end)

local Connection = DataStore:OnUpdate("Announcement", function(value)
	if value then
		local Message = value[1]
		local TextColor = (value[2] and Color3.new(value[2][1],value[2][2],value[2][3])) or Color3.new(1,1,1)
		local Background = (value[3] and Color3.new(value[3][1],value[3][2],value[3][3])) or Color3.new(0.3,0.3,0.3)
		local Stroke = (value[4] and Color3.new(value[4][1],value[4][2],value[4][3])) or Color3.new(0.1,0.1,0.6)
		game.ReplicatedStorage.SystemAlert:FireAllClients(Message,TextColor,Background,Stroke)
	end
end)

-- Ugly hack to keep it from being read as an array instead of a table
local ProductCache = {d = "1"}


local function maskedman(Player,ItemId)
	for i,v in pairs(workspace.Market.Items:GetChildren()) do
		if v:FindFirstChild("ProductId") and v.ProductId.Value == ItemId then
			v.Stock.Value = v.Stock.Value - 1
			workspace.Market.TotalStock.Value = workspace.Market.TotalStock.Value - 1
			game.ServerStorage.AwardBadge:Invoke(Player,1613782880)
		end
	end
end

game.MarketplaceService.ProcessReceipt = function(receiptInfo)
	print("Purchase")
    local playerProductKey = receiptInfo.PlayerId .. ":" .. receiptInfo.PurchaseId
	local Player = getPlayer(receiptInfo.PlayerId)
	if Player then
		print("Player found")

		-- Wait until player loads in
		repeat wait() until Player == nil or Player:FindFirstChild("BaseDataLoaded") ~= nil
		if Player == nil then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		local Target = Player
		if Player:FindFirstChild("Giving") and Player.Giving.Value ~= nil then
			Target = Player.Giving.Value
		end





		local Tycoon = Player.ActiveTycoon.Value
		local BaseOwner
		if Tycoon then
			BaseOwner = game.Players:FindFirstChild(Tycoon.Owner.Value)
		end

		local CrystalsGained = 0
		local ProductName

		local function report()
			if true then
				ProductName = ProductName or "unknown"
				game.ServerStorage.CurrencyEvent:Fire(Player, "Crystals", CrystalsGained, "purchase", ProductName)
			end
		end

		local PurchaseCompleted = false


		if receiptInfo.ProductId == 24245922 or receiptInfo.ProductId == 23781709 then
			print("Purchase found")
			game.ReplicatedStorage.UpdateIsland:Invoke(Player)
			print("Invoked")
			PurchaseCompleted = true
		elseif receiptInfo.ProductId == 24262357 then
			game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." purchased a second gift!", Color3.new(1,1,1),Color3.new(0.3,0,0.15),Color3.new(0.6,0.1,0.2))
			if Player:FindFirstChild("Gifted") and Player:FindFirstChild("SecondGift") == nil then
				Player.Gifted:Destroy()
				local tag = Instance.new("BoolValue",Player)
				tag.Name = "SecondGift"
				if Player:FindFirstChild("GiftStatus") then
					Player.GiftStatus.Value = true
				end
				PurchaseCompleted = true
			end
		elseif receiptInfo.ProductId == 82337331 then
			game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." purchased a ROCKET LAUNCHER!", Color3.new(1,1,1),Color3.new(0.3,0,0.15),Color3.new(0.6,0.1,0.2))
			game.ServerStorage.AwardItem:Invoke(Player,423)
			PurchaseCompleted = true

		-- Nebula System
		-- TODO CHANGE PLEASE DEAR GOD CHANGE
		elseif receiptInfo.ProductId == 270630987 then
			game.ServerStorage.AwardItem:Invoke(Player,329)
			game.ServerStorage.AwardItem:Invoke(Player,330)
			game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." purchased the Nebula System from the Masked Man!", Color3.new(1,1,1))
			maskedman(Player,receiptInfo.ProductId)
			PurchaseCompleted = true

		elseif receiptInfo.ProductId == 100466450 then
			Player.Megaphones.Value = Player.Megaphones.Value + 3
			game.ReplicatedStorage.Hint:FireClient(Player,"3x Megaphone acquired.")
			game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." purchased 3 Megaphones.", Color3.new(1,1,1))

			PurchaseCompleted = true


--     FRDAY NIGHT
--		elseif receiptInfo.ProductId == 24361749 then -- 55
		elseif receiptInfo.ProductId == 24361749 then
			ProductName = "100uC"
			if BaseOwner and BaseOwner ~= Player then
				Target = BaseOwner
				game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." bought "..ProductName.." for "..BaseOwner.Name.."!", Color3.new(1,0.7,1))
				game.ReplicatedStorage.Hint:FireClient(Target,Player.Name.." bought you "..ProductName.."!")
			else
				game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." bought "..ProductName.."!", Color3.new(1,0.7,1))
				--game.ReplicatedStorage.Hint:FireClient(Target,"You have been credited "..ProductName..".")
			end
			Target.Crystals.Value = Target.Crystals.Value + 100
			CrystalsGained = 100

-- rbxassetid://1028723613

			game.ReplicatedStorage.CurrencyPopup:FireClient(Target, "100 uC", Color3.fromRGB(255, 216, 217), "rbxassetid://1028723613")


			report()
			PurchaseCompleted = true

		elseif receiptInfo.ProductId == 33031932 then -- 720

			ProductName = "1000uC"
			if BaseOwner and BaseOwner ~= Player then
				Target = BaseOwner
				game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." bought "..ProductName.." for "..BaseOwner.Name.."!", Color3.new(1,0.7,1))
				game.ReplicatedStorage.Hint:FireClient(Target,Player.Name.." bought you "..ProductName.."!")
			else
				game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." bought "..ProductName.."!", Color3.new(1,0.7,1))
				--game.ReplicatedStorage.Hint:FireClient(Target,"You have been credited "..ProductName..".")
			end
			Target.Crystals.Value = Target.Crystals.Value + 1000
			CrystalsGained = 1000

game.ReplicatedStorage.CurrencyPopup:FireClient(Target, "1000 uC", Color3.fromRGB(255, 176, 178), "rbxassetid://1028723620")

			report()
			PurchaseCompleted = true
		elseif receiptInfo.ProductId == 33032004 then -- 1500

			ProductName = "2000uC"
			if BaseOwner and BaseOwner ~= Player then
				Target = BaseOwner
				game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." bought "..ProductName.." for "..BaseOwner.Name.."!", Color3.new(1,0.7,1))
				game.ReplicatedStorage.Hint:FireClient(Target,Player.Name.." bought you "..ProductName.."!")
				game.ReplicatedStorage.Hint:FireClient(Target,"Obtained 200 bonus uC")
			else
				game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." bought "..ProductName.."!", Color3.new(1,0.7,1))
				--game.ReplicatedStorage.Hint:FireClient(Target,"You have been credited "..ProductName..".")
				--game.ReplicatedStorage.Hint:FireClient(Target,"Obtained 200 bonus uC")
			end
			Target.Crystals.Value = Target.Crystals.Value + (2000 + 200)
			CrystalsGained = (2000 + 200)

game.ReplicatedStorage.CurrencyPopup:FireClient(Target, "2200 uC", Color3.fromRGB(255, 142, 144), "rbxassetid://1028723633")

			report()
			PurchaseCompleted = true

		elseif receiptInfo.ProductId == 33078672 then -- 3200
			ProductName = "3750uC"
			if BaseOwner and BaseOwner ~= Player then
				Target = BaseOwner
				game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." bought "..ProductName.." for "..BaseOwner.Name.."!", Color3.new(1,0.7,1))
				game.ReplicatedStorage.Hint:FireClient(Target,Player.Name.." bought you "..ProductName.."!")
				game.ReplicatedStorage.Hint:FireClient(Target,"Obtained 500 bonus uC")
			else
				game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." bought "..ProductName.."!", Color3.new(1,0.7,1))
				--game.ReplicatedStorage.Hint:FireClient(Target,"You have been credited "..ProductName..".")
				--game.ReplicatedStorage.Hint:FireClient(Target,"Obtained 500 bonus uC")
			end
			Target.Crystals.Value = Target.Crystals.Value + (3750 + 500)
			CrystalsGained = (3750 + 500)

			game.ReplicatedStorage.CurrencyPopup:FireClient(Target, "4250 uC", Color3.fromRGB(255, 89, 92), "rbxassetid://1028723632")

			report()
			PurchaseCompleted = true

		--[[
		elseif receiptInfo.ProductId == 24361733 then -- for "..(Check(Player.Giving.Value) or "themselves".."!")
			Target.Crystals.Value = Target.Crystals.Value + math.floor(6*1)
			game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." purchased 6 Crystals!", Color3.new(1,0.7,1),Color3.new(0.3,0,0.3),Color3.new(0.2,0,0.2))
			game.ReplicatedStorage.Hint:FireClient(Target,"6 Crystals credited!")
		elseif receiptInfo.ProductId == 24361741 then
			Target.Crystals.Value = Target.Crystals.Value + math.floor(13*1)
			game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." purchased 13 Crystals!", Color3.new(1,0.7,1),Color3.new(0.3,0,0.3),Color3.new(0.2,0,0.2))
			game.ReplicatedStorage.Hint:FireClient(Target,"13 Crystals credited!")
		elseif receiptInfo.ProductId == 24361744 then
			Target.Crystals.Value = Target.Crystals.Value + math.floor(27*1)
			game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." purchased 27 Crystals!", Color3.new(1,0.7,1),Color3.new(0.3,0,0.3),Color3.new(0.2,0,0.2))
			game.ReplicatedStorage.Hint:FireClient(Target,"27 Crystals credited!")
		elseif receiptInfo.ProductId == 24361749 then
			Target.Crystals.Value = Target.Crystals.Value + math.floor(55*1)
			game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." purchased 55 Crystals!", Color3.new(1,0.7,1),Color3.new(0.3,0,0.3),Color3.new(0.2,0,0.2))
			game.ReplicatedStorage.Hint:FireClient(Target,"55 Crystals credited!")
		elseif receiptInfo.ProductId == 24654982 then
			Target.Crystals.Value = Target.Crystals.Value + math.floor(120*1)
			game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." purchased 120 Crystals!!", Color3.new(1,0.7,1),Color3.new(0.3,0,0.3),Color3.new(0.2,0,0.2))
			game.ReplicatedStorage.Hint:FireClient(Target,"120 Crystals credited!")
		elseif receiptInfo.ProductId == 24654988 then
			Target.Crystals.Value = Target.Crystals.Value + math.floor(280*1)
			game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." purchased 280 Crystals!!!", Color3.new(1,0.7,1),Color3.new(0.3,0,0.3),Color3.new(0.2,0,0.2))
			game.ReplicatedStorage.Hint:FireClient(Target,"280 Crystals credited!")
		elseif receiptInfo.ProductId == 33031932 then
			Target.Crystals.Value = Target.Crystals.Value + math.floor(720*1)
			game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." purchased 720 Crystals!!!", Color3.new(1,0.7,1),Color3.new(0.3,0,0.3),Color3.new(0.2,0,0.2))
			game.ReplicatedStorage.Hint:FireClient(Target,"720 Crystals credited!")
		elseif receiptInfo.ProductId == 33032004 then
			Target.Crystals.Value = Target.Crystals.Value + math.floor(1500*1)
			game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." purchased 1500 Crystals!!!!", Color3.new(1,0.7,1),Color3.new(0.3,0,0.3),Color3.new(0.2,0,0.2))
			game.ReplicatedStorage.Hint:FireClient(Target,"1500 Crystals credited!")
		elseif receiptInfo.ProductId == 33078672 then
			Target.Crystals.Value = Target.Crystals.Value + math.floor(3200*1)
			game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." purchased 3200 Crystals!!!!", Color3.new(1,0.7,1),Color3.new(0.3,0,0.3),Color3.new(0.2,0,0.2))
			game.ReplicatedStorage.Hint:FireClient(Target,"3200 Crystals credited!")
		elseif receiptInfo.ProductId == 33078689 then
			Target.Crystals.Value = Target.Crystals.Value + math.floor(6500*1)
			game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." purchased 6500 Crystals!!!!", Color3.new(1,0.7,1),Color3.new(0.3,0,0.3),Color3.new(0.2,0,0.2))
			game.ReplicatedStorage.Hint:FireClient(Target,"6500 Crystals credited!")
		]]
		elseif receiptInfo.ProductId == 109464543 then
			Player.Crates.Pumpkin.Value = Player.Crates.Pumpkin.Value + 1
			game.ReplicatedStorage.Hint:FireClient(Target,"Pumpkin Box Obtained!")
			game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." purchased a Pumpkin Box!", Color3.new(1,0.7,0.5),Color3.new(0.3,0,0.3),Color3.new(0.2,0,0.2))
			PurchaseCompleted = true

		elseif receiptInfo.ProductId == 109475772 then
			Player.Crates.Pumpkin.Value = Player.Crates.Pumpkin.Value + 5
			game.ReplicatedStorage.Hint:FireClient(Target,"5 Pumpkin Boxes Obtained!")
			game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." purchased a Pumpkin Box Bundle!", Color3.new(1,0.7,0.5),Color3.new(0.3,0,0.3),Color3.new(0.2,0,0.2))
			PurchaseCompleted = true

		elseif receiptInfo.ProductId == 39325623 then

			Player.Crates.Inferno.Value = Player.Crates.Inferno.Value + 2
			Player.Crystals.Value = Player.Crystals.Value + 300

			game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." purchased the Halloween Bundle!", Color3.new(1,0.7,0.5),Color3.new(0.3,0,0.3),Color3.new(0.2,0,0.2))
			game.ReplicatedStorage.Hint:FireClient(Target,"2 Inferno Boxes & 300uC Credited!")
			PurchaseCompleted = true

		elseif receiptInfo.ProductId == 27880177 then
			Player.Crates.Inferno.Value = Player.Crates.Inferno.Value + 1
			game.ReplicatedStorage.Hint:FireClient(Player,"Inferno Box Purchased")
			for i,v in pairs(workspace.Market.Items:GetChildren()) do
				if v:FindFirstChild("ProductId") and v.ProductId.Value == receiptInfo.ProductId then
					v.Stock.Value = v.Stock.Value - 1
					workspace.Market.TotalStock.Value = workspace.Market.TotalStock.Value - 1
					game.ServerStorage.AwardBadge:Invoke(Player,1613782880)
				end
			end
			PurchaseCompleted = true

		-- TODO: DEAR GOD CHANGE THIS
		elseif receiptInfo.ProductId == 144581326 then
			Player.Crates.Unreal.Value = Player.Crates.Unreal.Value + 4

			game.ReplicatedStorage.Hint:FireClient(Player,"x4 Unreal Box Bundle Purchased")

			local Box = game.ReplicatedStorage.Boxes.Unreal

			game.ReplicatedStorage.CurrencyPopup:FireClient(Player,"4 "..Box.Name.." Box",Box.BoxColor.Value,"rbxassetid://"..Box.ThumbnailId.Value)
			PurchaseCompleted = true

		elseif receiptInfo.ProductId == 38896565 then
			Player.Crates.Unreal.Value = Player.Crates.Unreal.Value + 5
			game.ReplicatedStorage.Hint:FireClient(Player,"x5 Unreal Box Bundle Purchased")

			local Box = game.ReplicatedStorage.Boxes.Unreal
			game.ReplicatedStorage.CurrencyPopup:FireClient(Player,"5 "..Box.Name.." Box",Box.BoxColor.Value,"rbxassetid://"..Box.ThumbnailId.Value)

			maskedman(receiptInfo.ProductId)
			PurchaseCompleted = true

		elseif receiptInfo.ProductId == 30828118 then
			Player.Clovers.Value = Player.Clovers.Value + 1
			game.ReplicatedStorage.Hint:FireClient(Player,"Lucky Clover Purchased")
			for i,v in pairs(workspace.Market.Items:GetChildren()) do
				if v:FindFirstChild("ProductId") and v.ProductId.Value == receiptInfo.ProductId then
					v.Stock.Value = v.Stock.Value - 1
					workspace.Market.TotalStock.Value = workspace.Market.TotalStock.Value - 1
					game.ServerStorage.AwardBadge:Invoke(Player,1613782880)
				end
			end
			PurchaseCompleted = true

		elseif receiptInfo.ProductId == 34112444 then
			Player.Clovers.Value = Player.Clovers.Value + 1
			game.ReplicatedStorage.Hint:FireClient(Player,"Crate Storm Inbound")
			game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." Called in a crate storm!", Color3.new(1,0.7,1),Color3.new(0.3,0,0.3),Color3.new(0.2,0,0.2))
			for i,v in pairs(workspace.Market.Items:GetChildren()) do
				if v:FindFirstChild("ProductId") and v.ProductId.Value == receiptInfo.ProductId then
					v.Stock.Value = v.Stock.Value - 1
					workspace.Market.TotalStock.Value = workspace.Market.TotalStock.Value - 1
					game.ServerStorage.AwardBadge:Invoke(Player,1613782880)
				end
			end
			spawn(function()
				for i=1,7 do
					wait(math.random(1,100)/20)
					local Crate = game.ServerStorage:FindFirstChild("DiamondCrate"):Clone()
					Crate.Parent = workspace
					Crate.CFrame =  workspace.Location.Value + Vector3.new(math.random(-400,400),math.random(-20,20),math.random(-400,400))
					game.Debris:AddItem(Crate,60)
				end
			end)
			spawn(function()
				for i=1,15 do
					wait(math.random(1,100)/45)
					local Crate = game.ServerStorage:FindFirstChild("GoldenCrate"):Clone()
					Crate.Parent = workspace
					Crate.CFrame =  workspace.Location.Value + Vector3.new(math.random(-400,400),math.random(-20,20),math.random(-400,400))
					game.Debris:AddItem(Crate,60)
				end
			end)
			spawn(function()
				for i=1,10 do
					wait(math.random(1,100)/35)
					local Crate = game.ServerStorage:FindFirstChild("CrystalCrate"):Clone()
					Crate.Parent = workspace
					Crate.CFrame =  workspace.Location.Value + Vector3.new(math.random(-400,400),math.random(-20,20),math.random(-400,400))
					game.Debris:AddItem(Crate,60)
				end
			end)
			spawn(function()
				for i=1,35 do
					wait(math.random(1,100)/65)
					local Crate = game.ServerStorage:FindFirstChild("ResearchCrate"):Clone()
					Crate.Parent = workspace
					Crate.CFrame =  workspace.Location.Value + Vector3.new(math.random(-400,400),math.random(-20,20),math.random(-400,400))
					game.Debris:AddItem(Crate,60)
				end
			end)
			PurchaseCompleted = true

		end

		if PurchaseCompleted then

			-- Report GameAnalytics Purchase

			spawn(function()
				local ProductName = ProductCache[receiptInfo.ProductId]
				if ProductName == nil then
					local Product = game.MarketplaceService:GetProductInfo(receiptInfo.ProductId,Enum.InfoType.Product)
					if Product then
						ProductName = Product.Name
						ProductCache[receiptInfo.ProductId] = ProductName
					else
						ProductName = "unknown"
					end
				end
				game.ServerStorage.PurchaseMade:Fire(Player, "Product", ProductName, receiptInfo.CurrencySpent)
			end)

			-- End Game Analytcs reporting

			return Enum.ProductPurchaseDecision.PurchaseGranted
		end

	    return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end