local function GetDayOfTheWeek(seconds)
	local Week = math.floor((seconds - (86400 * 3))  / 604800)
	local Day =  math.floor((seconds - (86400 * 3)) / 86400)
	local DaysBeforeThisWeek = Week * 7
	local DayOfTheWeek = Day - DaysBeforeThisWeek
	return DayOfTheWeek,Day
end

game.ReplicatedStorage.Click.OnServerEvent:connect(function(Player, Target)
	if Target.Parent == script.Parent then
		--game.ReplicatedStorage.OpenMarket:FireClient(Player)
	end
end)

local function GetTotalStock()
	local TotalStock = 0
	for i,v in pairs(script.Parent.Items:GetChildren()) do
		TotalStock = TotalStock + v.Stock.Value
	end
	return TotalStock
end

script.Parent.PrimaryPart = script.Parent.Torso

local Day = -1
local ItemNames = {"One","Two","Three","Four"}

local Active = true





function game.ReplicatedStorage.BuyMarketItem.OnServerInvoke(Player,ItemName)
	local Item = script.Parent.Items:FindFirstChild(ItemName)
	if Item and Item:FindFirstChild("CostType") and Item.Stock.Value > 0 and Active then
		if Item.CostType.Value == "Points" or Item.CostType.Value == "Clovers" or Item.CostType.Value == "Crystals" or Item.CostType.Value == "Money" then
			local Currency
			if Item.CostType.Value == "Money" then
				Currency = game.ServerStorage.MoneyStorage:FindFirstChild(Player.Name)
			else
				Currency = Player:FindFirstChild(Item.CostType.Value)
			end
			if Currency and Currency.Value > Item.Cost.Value then
				if Item:FindFirstChild("ItemId") then
					game.ServerStorage.AwardItem:Invoke(Player,Item.ItemId.Value)
					Currency.Value = Currency.Value - Item.Cost.Value
					if Item.CostType.Value == "Points" then
						game.PointsService:AwardPoints(Player.userId,-Item.Cost.Value)
					end
					Item.Stock.Value = Item.Stock.Value - 1
					script.Parent.TotalStock.Value = GetTotalStock()
					return true
				end
			else
				return false
			end
		elseif  Item:FindFirstChild("ProductId") then
			print("Prompting purchase")
			game.MarketplaceService:PromptProductPurchase(Player,Item.ProductId.Value)
			return true
		end
	else
		return false
	end
end

local function Restock(Today,WeekDay)
	math.randomseed((((Today + 0) /3) * 7.1) + ((WeekDay + 0) * 20))
	script.Parent.Items:ClearAllChildren()
	for _ = 1, 10 do
		math.random()
		math.random(1,10)
	end

--	local Locations = game.ServerStorage.MarketLocations:GetChildren()
--	local Location = Locations[math.random(1,#Locations)]
	local IsMultiplayer = (game.VIPServerId == "" or game.VIPServerOwnerId > 0)
	local Location

	if IsMultiplayer then
		local Locations = game.ServerStorage.MarketLocations:GetChildren()
		Location = Locations[math.random(1,#Locations)]
	end
	script.Parent:SetPrimaryPartCFrame(Location.Value)

	local RawItems = game.ServerStorage.MarketItems:GetChildren()
	local Items = {}
	for i=1,4 do
		local Index = math.random(1,#RawItems)
		local Item = RawItems[Index]:Clone()
		table.insert(Items,Item)
		table.remove(RawItems,Index)
		Item.Parent = script.Parent.Items
		Item.Name = ItemNames[i]
	end
	script.Parent.TotalStock.Value = GetTotalStock()
	math.randomseed(tick())
	for i,Item in pairs(script.Parent.Items:GetChildren()) do
		Item.Stock.Value = math.floor(Item.Stock.Value * (math.random(25,75)/50))
		if Item.CostType.Value == "Crystals" or Item.CostType.Value == "Points" or Item.CostType.Value == "Money" then
			Item.Cost.Value = math.ceil(Item.Cost.Value * (math.random(37,65)/50))
		end
	end
	script.Parent.Timer.Value = 600
	spawn(function()
		while Active and script.Parent.Timer.Value > 6 do
			wait(1)
			script.Parent.Timer.Value = script.Parent.Timer.Value - 1
		end
		if Active then
			script.Parent.Timer.Value = 5
		end
	end)
end

local newserver = true

wait(50) -- wait a minute for dramatic effect

while wait(5) do
	local DayOfTheWeek,RawDay = GetDayOfTheWeek(os.time())
	Active = ((DayOfTheWeek >= 5 or DayOfTheWeek == 0)) and (game.VIPServerId == "" or game.VIPServerOwnerId > 0)
	if Active and Day ~= DayOfTheWeek then
		-- New Day
		Day = DayOfTheWeek
		Restock(RawDay,DayOfTheWeek)
		local St = "The Masked Man has moved!"
		if newserver or Day == 5 then
			newserver = false
			St = "The Masked Man has arrived!"
		end
		game.ReplicatedStorage.Hint:FireAllClients(St,Color3.new(0,0,0),Color3.new(1,1,1),"MaskedMan")
--		game.ReplicatedStorage.SystemAlert:FireAllClients("The Innovator has arrived!",Color3.new(0.3,0,0),Color3.new(1,1,1))
	elseif script.Parent.Timer.Value == 5 then
		Restock(RawDay,DayOfTheWeek)
		game.ReplicatedStorage.SystemAlert:FireAllClients("The Masked Man has restocked his inventory!")
	elseif not Active then
		workspace.Market:SetPrimaryPartCFrame(CFrame.new(10000,5000,0))
	end
end

