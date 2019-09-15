-- Event Script
--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

local module = {}

local MoneyLib

--[[
local function RefreshQeust()

	if workspace.Market.Online.Value == false then
		script.Parent.BillboardGui.Enabled = false
	else

	end

end
]]

function module.init(Modules)

	MoneyLib = Modules.MoneyLib
	local Sounds = Modules.Menu.sounds

	script.Parent.CloseButton.MouseButton1Click:connect(function()
		Modules.Focus.close()
	end)

	script.Parent.Top.Close.MouseButton1Click:connect(function()
		Modules.Focus.close()
	end)



	local BuyDB = true
	for i,v in pairs(script.Parent.Options:GetChildren()) do
		if v:FindFirstChild("Item") then
			v.Button.MouseButton1Click:connect(function()
				if BuyDB then
					Sounds.Click:Play()
					BuyDB = false



					if v.Item.Value ~= nil then

						local Cost = v.Item.Value.Cost.Value
						if v.Item.Value.CostType.Value == "Crystals" and Cost >= 100 then
							if not Modules.InputPrompt.prompt("Are you sure you want to spend ".. MoneyLib.DealWithPoints(Cost) .. " uC?") then
								BuyDB = true
								return false
							end
						elseif v.Item.Value.CostType.Value == "Shards" and Cost >= 10 then
							if not Modules.InputPrompt.prompt("Are you sure you want to spend ".. MoneyLib.DealWithPoints(Cost) .. " Shards?") then
								BuyDB = true
								return false
							end
						end

						v.Button.BackgroundColor3 = Color3.fromRGB(0,0,0)
						v.Button.BackgroundTransparency = 0.5
						local Result = game.ReplicatedStorage.BuyMarketItem:InvokeServer(v.Item.Value.Name)
						if Result then
							v.Button.BackgroundColor3 = Color3.fromRGB(50,255,100)
							v.Button.BackgroundTransparency = 0.7
							Sounds.Purchase:Play()
							wait(0.25)
							v.Button.BackgroundTransparency = 1
						else
							v.Button.BackgroundColor3 = Color3.fromRGB(255,50,50)
							v.Button.BackgroundTransparency = 0.7
							Sounds.Error:Play()
							wait(0.25)
							v.Button.BackgroundTransparency = 1
						end
					end
					BuyDB = true
				end
			end)
		end
	end

	local function GetItemFromId(Id)
		for i,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
			if v.ItemId.Value == Id then
				return v
			end
		end
	end
	local PriceColors = {
		Crystals = Color3.new(255/255, 92/255, 135/255),
		Points = Color3.new(50/255, 200/255, 255/255),
		Clovers = Color3.new(19/255, 255/255, 184/255),
		Robux = Color3.new(85/255, 255/255, 110/255),
		Money = Color3.new(255/255, 199/255, 55/255),
		Shards = Color3.fromRGB(0, 243, 255)
	}
	local Suffixes = {
		Crystals = "uC",
		Points = " RP",
		Clovers = " Clovers",
		Shards = " Shards",
	}
	local Prefixes = {
		Robux = "R$",
	}
	local function AssignItemToButton(Item,Button)
		if Item then
			if Item:FindFirstChild("Special") then

				Button.Title.Text = Item.ItemName.Value

				Button.Type.Visible = true
				Button.Type.Text = "Misc"
				Button.Green.Visible = true
				Button.Green.BackgroundColor3 = Color3.new(0.5,0.5,0.5)

				Button.Image.Visible = true
				Button.Title.Visible = true

				Button.Image.Image = "rbxassetid://"..Item.ThumbnailId.Value

				local CostString = Item.Cost.Value

				local CostColor = PriceColors[Item.CostType.Value] or Color3.new(0.3,0.3,0.3)

				if Item.CostType.Value == "Money" then
					CostString = MoneyLib.HandleMoney(Item.Cost.Value)
				elseif Item.CostType.Value == "Points" or Item.CostType.Value == "Crystals" or Item.CostType.Value == "Shards" then
					CostString = MoneyLib.DealWithPoints(Item.Cost.Value)
				end

				local FinalString =(Prefixes[Item.CostType.Value] or "")..CostString..(Suffixes[Item.CostType.Value] or "")
				Button.Price.Text = FinalString
				Button.Price.TextColor3 = CostColor


				Button.Item.Value = Item

				Button.Quantity.Text = Item.Stock.Value.." Remaining"

				if Item:FindFirstChild("Tier") then
					local Tier = game.ReplicatedStorage.Tiers:FindFirstChild(Item.Tier.Value)
					if Tier then
						Button.Type.Visible = true
						Button.Green.Visible = true
						Button.Type.Text = Tier.TierName.Value
						if Tier.TierName.Value == "Luxury" then
							Button.Type.TextColor3 = Color3.new(0,0,0)
						else
							Button.Type.TextColor3 = Color3.new(1,1,1)
						end
						Button.Green.BackgroundColor3 = Tier.TierColor.Value
					end
				end

			elseif Item:FindFirstChild("ItemId") then

				local RealItem = GetItemFromId(Item.ItemId.Value)

				local Tier = game.ReplicatedStorage.Tiers:FindFirstChild(RealItem.Tier.Value)
				if Tier then
					Button.Type.Visible = true
					Button.Green.Visible = true
					Button.Type.Text = Tier.TierName.Value
					if Tier.TierName.Value == "Luxury" then
						Button.Type.TextColor3 = Color3.new(0,0,0)
					else
						Button.Type.TextColor3 = Color3.new(1,1,1)
					end
					Button.Green.BackgroundColor3 = Tier.TierColor.Value
				end

				Button.Title.Text = Modules.Translate.ItemName(RealItem)
				Button.Image.Image = "rbxassetid://"..RealItem.ThumbnailId.Value

				Button.RebornProof.Visible = false

				Button.Image.Visible = true
				Button.Title.Visible = true

				if RealItem.ItemType.Value == 6 or RealItem.ItemType.Value == 99 then
					Button.RebornProof.Visible = true
				end



		--		Cover = Button:FindFirstChild(Item.CostType.Value)

				local CostString = Item.Cost.Value

				local CostColor = PriceColors[Item.CostType.Value] or Color3.new(0.3,0.3,0.3)

				if Item.CostType.Value == "Money" then
					CostString = MoneyLib.HandleMoney(Item.Cost.Value)
				elseif Item.CostType.Value == "Points" or Item.CostType.Value == "Crystals" or Item.CostType.Value == "Shards" then
					CostString = MoneyLib.DealWithPoints(Item.Cost.Value)
				end

				local FinalString =(Prefixes[Item.CostType.Value] or "")..CostString..(Suffixes[Item.CostType.Value] or "")
				Button.Price.Text = FinalString
				Button.Price.TextColor3 = CostColor


				Button.Item.Value = Item

				Button.Quantity.Text = Item.Stock.Value.." Remaining"

			elseif Item:FindFirstChild("ProductId") then


				Button.Title.Text = Item.ItemName.Value

				Button.Type.Visible = true
				Button.Type.Text = "Misc"
				Button.Green.Visible = true
				Button.Green.BackgroundColor3 = Color3.new(0.4,0.4,0.4)

				Button.Image.Visible = true
				Button.Title.Visible = true

				Button.Image.Image = "rbxassetid://"..Item.ThumbnailId.Value
				local CostColor = PriceColors[Item.CostType.Value] or Color3.new(0.3,0.3,0.3)

				local FinalString =	"R$"..Item.Cost.Value
				Button.Price.Text = FinalString
				Button.Price.TextColor3 = CostColor

		--		Cover.Text = "R$"..Item.Cost.Value

				Button.Item.Value = Item

				Button.Quantity.Text = Item.Stock.Value.." Remaining"

				if Item:FindFirstChild("Tier") then
					local Tier = game.ReplicatedStorage.Tiers:FindFirstChild(Item.Tier.Value)
					if Tier then
						Button.Type.Visible = true
						Button.Green.Visible = true
						Button.Type.Text = Tier.TierName.Value
						if Tier.TierName.Value == "Luxury" then
							Button.Type.TextColor3 = Color3.new(0,0,0)
						else
							Button.Type.TextColor3 = Color3.new(1,1,1)
						end
						Button.Green.BackgroundColor3 = Tier.TierColor.Value
					end
				end
			end
		end

		if Item and Item.Stock.Value <= 0 then

			Button.SoldOut.Visible = true
		else
			Button.SoldOut.Visible = false

		end

	end

	local function Refresh()
		local Item1 = workspace.Market.Items:FindFirstChild("One")
		local Item2 = workspace.Market.Items:FindFirstChild("Two")
		local Item3 = workspace.Market.Items:FindFirstChild("Three")
		local Item4 = workspace.Market.Items:FindFirstChild("Four")

		AssignItemToButton(Item1,script.Parent.Options.Item1)
		AssignItemToButton(Item2,script.Parent.Options.Item2)
		AssignItemToButton(Item3,script.Parent.Options.Item3)
		AssignItemToButton(Item4,script.Parent.Options.Item4)
	end

	local function CountDown()
		if script.Parent.Visible then
			local RawTime = workspace.Market.Timer.Value
			local Hours = math.floor(RawTime/3600)
			RawTime = RawTime - (Hours * 3600)
			local Minutes = math.floor(RawTime/60)
			local Seconds = RawTime - (Minutes * 60)
			if string.len(tostring(Minutes)) == 1 then
				Minutes = "0"..Minutes
			end
			if string.len(tostring(Seconds)) == 1 then
				Seconds = "0"..Seconds
			end
			local TimeString = "Inventory refreshes in: ".. Hours..":"..Minutes..":"..Seconds
			script.Parent.Time.Remaining.Text = TimeString
		end
	end
	CountDown()
	workspace.Market.Timer.Changed:connect(CountDown)


	workspace.Market.TotalStock.Changed:connect(Refresh)
	Refresh()

	game.ReplicatedStorage.OpenMarket.OnClientEvent:connect(function()
		if script.Parent.Visible then
			Modules.Focus.close()
			if Modules.Input.mode.Value == "Xbox" then
				game.GuiService.SelectedObject = nil
				game.GuiService.GuiNavigationEnabled = false
			end
		else
			Modules.Focus.change(script.Parent)
			script.Parent.Visible = true
			if Modules.Input.mode.Value == "Xbox" then
				game.GuiService.GuiNavigationEnabled = true
				game.GuiService.SelectedObject = script.Parent.Options.Item1.Button
			end
		end
	end)

end

return module
