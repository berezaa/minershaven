-- Shop
--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

local module = {}

local getItemById

local Player = game.Players.LocalPlayer

local Sounds


local MoneyLib = require(game.ReplicatedStorage.MoneyLib)
local ShopLib = require(game.ReplicatedStorage.ShopControl)



--Shop tutorial UI stuff-------------


local tutorialColor0 = Color3.fromRGB(84,255,95)
local tutorialColor1 = Color3.fromRGB(24, 220, 219)

local itemIdToType = {}

local shopFrame = script.Parent
local Items = script.Parent.Frame.Items
local tutorialFrame = shopFrame.Tutorial
function module.highlightTutorialItem(itemId)

	if not tonumber(itemId) and itemId ~= nil then
		error("Attempt to tutorial highlight with an invalid value")
	end

	local function updateTop(itemId)
		local thisType
		if itemId then
			thisType = itemIdToType[itemId]
			if not thisType then
				for i,v in next,game.ReplicatedStorage.Items:GetChildren() do
					if v.ItemId.Value == itemId then
						itemIdToType[itemId] = ShopLib.RawTypes[v.ItemType.Value]
						thisType = itemIdToType[itemId]
						break
					end
				end
			end
		end
		for _,c in next,shopFrame.Frame.Top:GetChildren() do
			if c.ClassName == "ImageButton" then
				c.Arrow.Visible = itemId == nil and false or thisType == c.Name
			end
		end
	end

	local a = (tick()*.8)%2
	a = .5 - .5 * math.cos(math.pi*a)


	--So here's how we're doing this:
	--If newItem is nil, get rid of everything
	--If it's an item, change it to that
	--Loop through all item UI cards in the shop
	local makeOneHighlight = itemId ~= nil

	updateTop(itemId)

	for _,frame in next,shopFrame.Frame.Items:GetChildren() do
		if frame:FindFirstChild("ItemId") then

			if frame.ItemId.Value == itemId then
				--Start highlighting
				frame.Arrow.Visible = true
				frame.TutorialGlow.Visible = true

				local frameTopEdge = frame.AbsolutePosition.y
				local frameBottomEdge = frameTopEdge + frame.AbsoluteSize.y

				local mainTopEdge = shopFrame.Frame.AbsolutePosition.y
				local mainBottomEdge = mainTopEdge + shopFrame.Frame.AbsoluteSize.y

				tutorialFrame.Down.Visible = frameTopEdge > mainBottomEdge
				tutorialFrame.Up.Visible = frameBottomEdge < mainTopEdge
				tutorialFrame.Visible = tutorialFrame.Down.Visible or tutorialFrame.Up.Visible

				local doBottom = frameTopEdge + (frameBottomEdge - frameTopEdge)*.5 < mainTopEdge + (mainBottomEdge - mainTopEdge)*.5
				frame.Arrow.Position = doBottom and UDim2.new(.5,0,1,0) or UDim2.new(.5,0,0,0)
				frame.Arrow.Image = doBottom and "rbxassetid://1976183142" or "rbxassetid://1976183443"

				--Color
				local currentColor = tutorialColor0:Lerp(tutorialColor1,a)
				local a1 = (tick()*1.75)%2
				a1 = .5 - .5 * math.cos(math.pi*a1)
				frame.TutorialGlow.ImageColor3 = currentColor
				frame.Arrow.ImageColor3 = currentColor
				frame.TutorialGlow.ImageTransparency = a1*.3
				tutorialFrame.Down.ImageColor3 = currentColor
				tutorialFrame.Up.ImageColor3 = currentColor

				--Position
				--tutorialFrame.Down.Position = UDim2.new(.5,0,1,-5 - a*5)
				--tutorialFrame.Up.Position = UDim2.new(.5,0,0,a*5)
			else
				--make it look normal
				frame.Arrow.Visible = false
				frame.TutorialGlow.Visible = false
			end
		end
	end
end


-------------------------------------



local Sets = ShopLib.Sets

local function Index(Mode)
	for i, Set in pairs(Sets) do
		if Set == Mode then
			return i
		end
	end
end

local mods

local Sort = function(Table)
	local NewTable = {}
	for i,v in pairs(Table) do
		if v:FindFirstChild("Crystals") then
			v.Cost.Value = v.Crystals.Value
		end
		--[[
		if v:FindFirstChild("New") then
			table.insert(NewTable,v)
			table.remove(Table,i)
		end
		]]
	end

	for e=1,#Table do
		local LowestPrice = Table[1]
		local LowestPos = 1
		for i,v in pairs(Table) do
			if (v.Cost.Value < LowestPrice.Cost.Value) then
				LowestPrice = v
				LowestPos = i
			end
		end
		table.remove(Table,LowestPos)
		table.insert(NewTable,LowestPrice)
	end
	return NewTable
end

--[[
	local Active = true
	if string.len(script.Parent.Frame.Desc.Search.Text) > 0 and script.Parent.Frame.Desc.Search.Text ~= "Search..." then
		Active = matches(RealItem, script.Parent.Frame.Desc.Search.Text)
	end
]]
local function matches(Item, Search)
	local Num = tonumber(Search)
	if Num ~= nil then
		if Item.ItemType.Value == Num then
			return true
		end
	end

	Search = string.lower(Search)
	if (Search == "mine" or Search == "mine ") and Item.Model:FindFirstChild("Drop") then
		return true
	end
	if string.find(string.lower(Item.Name), Search) ~= nil then
		return true
	else
		local Tier = game.ReplicatedStorage.Tiers:FindFirstChild(tostring(Item.Tier.Value))
		if Tier then
			if string.find(string.lower(Tier.TierName.Value), Search) ~= nil then
				return true
			end
		end
	end
	return false
end



function module.reset()
	script.Parent.Mode.Value = "New"
end

function module.init(Modules)

	local AllItems = {}
	for i,Item in pairs(game.ReplicatedStorage.Items:GetChildren()) do
		if (Item.ItemType.Value >= 1 and Item.ItemType.Value <= 4) or Item.ItemType.Value == 7 then
			table.insert(AllItems,Item)
		end
	end

	local function Fill()
		local Tween = Modules.Menu.tween
		local Mode = script.Parent.Mode.Value
		local Items
		local Tycoon = game.Players.LocalPlayer.ActiveTycoon.Value or game.Players.LocalPlayer.PlayerTycoon.Value
		local Money = script.Parent.Parent.Money

		script.Parent.Frame.CanvasPosition = Vector2.new(0,0)

		script.Parent.XboxControls.Close.TextLabel.Text = "Back"

		if Mode == "New" then
			script.Parent.XboxControls.Close.TextLabel.Text = "Close"
			Items = {}
			local down = Money.Value ^ 0.8
			local up = Money.Value ^ 1.2
			local lowest = 10^100
			for i,Item in pairs(game.ReplicatedStorage.Items:GetChildren()) do

				if Modules.Layouts.missing[Item.Name] then

					local t = Item.ItemType.Value
					if t == 1 or t == 2 or t == 3 or t == 4 or t == 7 or t == 11 then
						table.insert(Items,Item)
					end
				elseif Item:FindFirstChild("New") then
					local t = Item.ItemType.Value
					if t == 1 or t == 2 or t == 3 or t == 4 or t == 7 then
						table.insert(Items,Item)
					end
				else
					local t = Item.ItemType.Value
					if t == 1 or t == 2 or t == 3 then

						local p = Item.Cost.Value / Money.Value
						local dis = math.abs(Item.Cost.Value - Money.Value)

						if ((p >= 0.1 or (Item.Cost.Value >= down)) and (p < 5 or (Item.Cost.Value <= up))) or dis <= 500 then

							table.insert(Items,Item)
						end
					end
				end



			end

			Items = Sort(Items)
			script.Parent.Frame.Top.Visible = true
			script.Parent.Frame.TopCurve.Visible = false
			script.Parent.Frame.Desc.Title.Text = "Recommended"
			script.Parent.Frame.Desc.Return.Visible = false

		elseif Mode == "Custom" then
			script.Parent.Frame.Top.Visible = true
			script.Parent.Frame.TopCurve.Visible = false
			script.Parent.Frame.Desc.Title.Text = "Custom Search"
			script.Parent.Frame.Desc.Return.Visible = true
			Items = AllItems

		else
			script.Parent.Frame.Top.Visible = false
			script.Parent.Frame.TopCurve.Visible = true
			script.Parent.Frame.Desc.Return.Visible = true

			if mods.Input.mode.Value == "Xbox" then
				game.GuiService.SelectedObject = script.Parent.Frame.Desc.Return
			end

			Items = ShopLib["Sorted"..Mode]
		end

		local count = 1
		for i,Item in pairs(Items) do

			local Button = script.Parent.Frame.Items:FindFirstChild("Button"..tostring(count))
			if Button then
				if Item.ItemType.Value == 7 and Item:FindFirstChild("Crystals") then
					Button.Price.Text = MoneyLib.DealWithPoints(Item.Crystals.Value).." uC"
					Button.Price.TextColor3 = Color3.fromRGB(36, 5, 75)
					Button.Price.TextStrokeColor3 = Color3.fromRGB(255, 102, 143)
					Button.Price.TextStrokeTransparency = 0.5
				else
					Button.Price.Text = MoneyLib.HandleMoney(Item.Cost.Value)
					local Cost = Item.Cost.Value
					local sCost = tostring(Cost)
					Button.Price.TextColor3 = Color3.fromRGB(27,42,53)
					Button.Price.TextStrokeTransparency = 1

				end


				local Active = true
				if string.len(script.Parent.Frame.Desc.Search.Text) > 0 then
					Active = matches(Item, script.Parent.Frame.Desc.Search.Text)
				end

				Button.ItemId.Value = Item.ItemId.Value
				Button.Thumbnail.Image = "rbxassetid://"..Item.ThumbnailId.Value


				Button.CrateIcon.Visible = Item.ItemType.Value == 11

				local Tier = game.ReplicatedStorage.Tiers:FindFirstChild(tostring(Item.Tier.Value))
				if Tier then
					Button.Price.BackgroundColor3 = Tier.TierColor.Value
					Button.Locked.BackgroundColor3 = Tier.TierColor.Value
				end
				local Locked = Player.Points.Value < Item.ReqPoints.Value and Player:FindFirstChild("Premium") == nil

				Button.Price.Visible = not Locked
				Button.Locked.Visible = Locked



				if Item:FindFirstChild("New") and not Locked then
					Button.Tags.New.Visible = true
			--		Button.Price.BorderColor3 = Color3.new(1,1,1)
				else
					Button.Tags.New.Visible = false
			--		Button.Price.BorderColor3 = Color3.new(0,0,0)
				end

				local Max = #Items

				if Modules.Layouts.missing[Item.Name] and Mode == "New" then
					Button.Tags.Layout.Visible = true
					Button.LayoutOrder = 1
					Button.Tags.New.Visible = false
				elseif Item:FindFirstChild("New") and Mode == "New" then
					Button.Tags.New.Visible = true
					Button.Tags.Layout.Visible = false
					Button.LayoutOrder = Max + 2
				else
					Button.Tags.Layout.Visible = false
					Button.LayoutOrder = i
				end

				if not Locked then -- Special

					--[[
					print('Model: '..Item.Name..'; children: ')
					for i,v in next,Item:GetChildren() do print(i,v) end
					print('--------')
					]]--

					local Special = ""
					if Item.ItemType.Value == 7 and Item.Tier.Value == 22 then
						Special = "Event"
					elseif Item:FindFirstChild("Coal") then
						Special = "Uses Coal"
					elseif Item:FindFirstChild("Research") then
						Special = "Research"
					elseif Item:FindFirstChild("Cell") then
						Special = "Cell Furnace"
					elseif Item.Model:FindFirstChild("Infuse") then
						Special = "Infuser"
					elseif Item.Model:FindFirstChild("Button") and Item.Model.Button:FindFirstChild("ClickDetector") then
						Special = "Manual"
					elseif Item.Model:FindFirstChild("Upgrade") then
						Special = "Upgrader"
					elseif Item:FindFirstChild("RemoteDrop") then
						Special = "Remote"
					end



					local ItemType = script.Parent.ItemTypes:FindFirstChild(Special)
					local TypeColor = Tier.TierBackground.Value
					if ItemType then
						Button.BorderSizePixel = 2
						Button.BorderColor3 = ItemType.BackgroundColor3
						-- new stuff
						Button.Outline.Visible = true
						Button.Outline.ImageColor3 = ItemType.BackgroundColor3
						Button.Depth.Position = UDim2.new(0,0,0,9)
						--TypeColor = ItemType.BackgroundColor3
						--
						Button.Tags.Special.Image = ItemType.Image
						Button.Tags.Special.BorderColor3 = ItemType.BackgroundColor3
						Button.Tags.Special.BackgroundColor3 = ItemType.BackgroundColor3
						Button.Tags.Special.Visible = true
			--		elseif Item:FindFirstChild("New") then
			--			Button.Special.Visible = false
			--			Button.BorderSizePixel = 2
			--			Button.BorderColor3 = Color3.new(1,1,1)
					else
						Button.Outline.Visible = false
						Button.Depth.Position = UDim2.new(0,0,0,6)
						Button.BorderSizePixel = 1
						Button.BorderColor3 = Color3.new(0,0,0)
						Button.Tags.Special.Visible = false
					end
					Button.ImageColor3 = TypeColor
					Button.Inner.ImageColor3 = TypeColor
					Button.Price.BackgroundColor3 = TypeColor
				else
					Button.BorderSizePixel = 1
					Button.BorderColor3 = Color3.new(0,0,0)
					Button.Price.BorderColor3 = Button.BorderColor3
					Button.Tags.Special.Visible = false
				end


				Button.Visible = Active
				count = count + 1
			end

		end
		script.Parent.Frame.Items.Count.Value = count
		for i=count,#script.Parent.Frame.Items:GetChildren() do
			local Button = script.Parent.Frame.Items:FindFirstChild("Button"..tostring(i))
			if Button then
				Button.Visible = false
				Button.ItemId.Value = 0
			end
		end
	end

		mods = Modules
		local Inventory = Modules["Inventory"]
		Sounds = Modules["Menu"]["sounds"]
		local tween = Modules["Menu"]["tween"]
	local TycoonLib = Modules["TycoonLib"]

	Modules.Layouts.changed:Connect(Fill) -- When layout info changes, reset shop

	getItemById = function(id)
		if Inventory.sortedItems then
			return Inventory.sortedItems[id]
		end
	end

	--script.Parent.Top.Close.MouseButton1Click:connect(function()
	script.Parent.Close.MouseButton1Click:connect(function()
		--Modules.Focus.close()
		Modules.Input.toggleShop()
		Modules.Menu.sounds.Click:Play()
	end)



	local function PermCheck()
		script.Parent.Locked.Visible = not TycoonLib.hasPermission(Player, "Buy")
	end
	PermCheck()
	game.ReplicatedStorage.PermissionsChanged.OnClientEvent:connect(PermCheck)

	for i, Button in pairs(script.Parent.Frame.Top:GetChildren()) do
		if Button:IsA("GuiButton") then

			if Button:FindFirstChild("Pulse") then
				Button.Pulse.Visible = false
				Button.Pulse.ZIndex = Button.ZIndex - 1
			end

			Button.MouseButton1Click:connect(function()
				Sounds.Click:Play()

				script.Parent.Mode.Value = Button.Name
				script.Parent.SelectedItem.Value = 0 -- close preview when switching tabs

				script.Parent.Frame.Desc.Title.TextStrokeTransparency = 0
				script.Parent.Frame.Desc.Title.TextTransparency = 0

				script.Parent.Frame.Desc.Title.Text = Button.Desc.Text



			end)
			Button.MouseEnter:Connect(function()
				local Pulse = Button:FindFirstChild("Pulse")
				if Pulse and not Pulse.Visible then
					Pulse.ImageColor3 = Button.ImageColor3
					Pulse.Size = UDim2.new(1,0,1,0)
					Pulse.ImageTransparency = 0
					Pulse.Visible = true
					tween(Pulse,{"ImageTransparency","Size"},{1,UDim2.new(2,0,2,0)},0.3)
					wait(0.3)
					Pulse.Visible = false
				end
			end)

		end
	end

	script.Parent.Frame.Desc.Return.MouseButton1Click:connect(function()
		Sounds.Click:Play()
		script.Parent.SelectedItem.Value = 0
		if Modules.Input.mode.Value == "Xbox" then
			local Button = script.Parent.Frame.Top:FindFirstChild(script.Parent.Mode.Value)
			if Button then
				game.GuiService.SelectedObject = Button
			end
		end
		script.Parent.Mode.Value = "New"

	end)



	local function buttonSetup()
		local SampleButton = script.Parent.Frame.Items.SampleItem

		for i=1,100 do
			local Button = SampleButton:Clone()
			Button.Name = "Button"..tostring(i)
			Button.Parent = script.Parent.Frame.Items
			Button.MouseButton1Click:connect(function()
				if Button.Visible and Button.ItemId.Value > 0 then
					Sounds.Click:Play()
					--print("Changed to "..tostring(Button.ItemId.Value))
					script.Parent.SelectedItem.Value = Button.ItemId.Value
				end
			end)
			Button.MouseEnter:connect(function()
				if not script.Parent.Confirm.Visible then
					if Modules.Input.mode.Value ~= "Mobile" and not Button.Locked.Visible then
						Modules.ItemInfo.show(Button)
					end
				end
			end)

			Button.MouseLeave:connect(function()
				if Modules.Input.mode.Value ~= "Mobile" then
					Modules.ItemInfo.hide(Button)
				end
			end)
		end


		SampleButton:Destroy()
	end

	buttonSetup()

	script.Parent.Mode.Changed:connect(function()
		if script.Parent.Mode.Value == "New" then
			script.Parent.Frame.Desc.Search.Text = ""
		end
		Fill()
		if script.Parent.Mode.Value ~= "New" and script.Parent.Mode.Value ~= "Custom" then
			local Color = Color3.fromRGB(139, 139, 139)
			local Real = script.Parent.Frame.Top:FindFirstChild(script.Parent.Mode.Value)
			if Real then
				local Col = Real.ImageColor3
				Color = Color3.new(Col.r * 0.8 + 0.15, Col.g * 0.8 + 0.15, Col.b * 0.8 + 0.15)
				tween(script.Parent,{"ImageColor3"},Color,0.5)
				tween(script.Parent.Frame.Desc,{"BackgroundColor3"},Color3.new(Col.r - 0.1, Col.g - 0.1, Col.b - 0.1),0.5)
				tween(script.Parent.Frame.TopCurve,{"ImageColor3"},Color3.new(Col.r - 0.2, Col.g - 0.2, Col.b - 0.2),0.5)
			end
			local Button = script.Parent.Frame.Items:FindFirstChild("Button1")
			if Button and Modules.Input.mode.Value == "Xbox" then
				game.GuiService.SelectedObject = Button
			end
		else
			tween(script.Parent,{"ImageColor3"},Color3.fromRGB(139, 139, 139),0.5)
			tween(script.Parent.Frame.Desc,{"BackgroundColor3"},Color3.fromRGB(99, 99, 99),0.5)
			tween(script.Parent.Frame.TopCurve,{"ImageColor3"},Color3.fromRGB(85, 85, 85),0.5)
		end
	end)

	function module.onOpen()
		script.Parent.SelectedItem.Value = 0
		if script.Parent.Mode.Value ~= "New" then
			script.Parent.Mode.Value = "New"
		else
			Fill()
		end
	end


	script.Parent.Mode.Value = "New"

	local Money = script.Parent.Parent.Money

	local function compareCash()
		local Item = getItemById(script.Parent.SelectedItem.Value)
		if Money and Item then
			if Money.Value >= Item.Cost.Value * script.Parent.Amount.Value then
				script.Parent.Confirm.Buy.BackgroundColor3 = Color3.new(82/255,1,70/255)
			else
				script.Parent.Confirm.Buy.BackgroundColor3 = Color3.new(150/255,150/255,150/255)
			end
		end
	end

	Money.Changed:connect(compareCash)

	local function costCheck()
		compareCash()
		local id = script.Parent.SelectedItem.Value
		if id > 0 then
			local Item = getItemById(id)
			if Item then
				if Item.ItemType.Value == 7 and Item:FindFirstChild("Crystals") then
					local cost = Item.Crystals.Value * script.Parent.Amount.Value
					script.Parent.Confirm.Cost.Text = MoneyLib.DealWithPoints(cost).." uC"
				else
					local cost = Item.Cost.Value * script.Parent.Amount.Value
					script.Parent.Confirm.Cost.Text = MoneyLib.HandleMoney(cost)
				end

			end
		end
	end

	script.Parent.Confirm.Locked.Contents.Close.MouseButton1Click:connect(function()
		Modules.Menu.sounds.Click:Play()
		script.Parent.SelectedItem.Value = 0
	end)

	script.Parent.Confirm.Locked.Contents.Buy.MouseButton1Click:connect(function()
		Modules.Menu.sounds.Click:Play()
		Modules.Focus.change(script.Parent.Parent.PremiumAd)
	end)

	script.Parent.Amount.Changed:connect(costCheck)

	script.Parent.SelectedItem.Changed:connect(function()
		--print("Changed")
		local id = script.Parent.SelectedItem.Value
		if id > 0 then
			--print("ID")
			local Item = getItemById(id)
			if Item then

				local Locked = Player.Points.Value < Item.ReqPoints.Value and Player:FindFirstChild("Premium") == nil

				if not Locked then
					script.Parent.Confirm.Locked.Visible = false
					--print("Item")
					script.Parent.Confirm.Icon.ItemName.Text = Item.Name
					script.Parent.Confirm.Icon.Image = "rbxassetid://"..Item.ThumbnailId.Value

					local Tier = game.ReplicatedStorage.Tiers:FindFirstChild(tostring(Item.Tier.Value))
					if Tier then
						script.Parent.Confirm.Icon.Tier.Text = Tier.TierName.Value
						script.Parent.Confirm.Icon.Tier.BackgroundColor3 = Tier.TierColor.Value
					end

					local Type = ""
					if Item.ItemType.Value == 7 and Item.Tier.Value == 22 then
						Type = "Event"
					elseif Item:FindFirstChild("Coal") then
						Type = "Uses Coal"
					elseif Item:FindFirstChild("Research") then
						Type = "Research"
					elseif Item:FindFirstChild("Cell") then
						Type = "Cell Furnace"
					elseif Item.Model:FindFirstChild("Infuse") then
						Type = "Infuser"
					elseif Item.Model:FindFirstChild("Button") and Item.Model.Button:FindFirstChild("ClickDetector") then
						Type = "Manual"
					elseif Item.Model:FindFirstChild("Upgrade") then
						Type = "Upgrader"
					elseif Item:FindFirstChild("RemoteDrop") then
						Type = "Remote"
					end
					local RealType = script.Parent.ItemTypes:FindFirstChild(Type)
					if RealType then
						script.Parent.Confirm.Icon.Special.Icon.Image = RealType.Image
						script.Parent.Confirm.Icon.Special.Title.Text = RealType.Name
						script.Parent.Confirm.Icon.Special.BackgroundColor3 = RealType.BackgroundColor3
						script.Parent.Confirm.Icon.Special.Visible = true
					else
						script.Parent.Confirm.Icon.Special.Visible = false
					end

					script.Parent.Confirm.Description.Text = Modules.Translate.Item(Item)
					costCheck()
					script.Parent.Confirm.Visible = true -- redundency for xbox
					script.Parent.Cover.Visible = true
					if Modules.Input.mode.Value == "Xbox" then
						game.GuiService.SelectedObject = script.Parent.Confirm.Buy
					end
				else
					script.Parent.Confirm.Locked.Visible = true
					script.Parent.Confirm.Locked.Contents.Amount.Text = "(Requires "..MoneyLib.DealWithPoints(Item.ReqPoints.Value).." RP)"
					if Modules.Input.mode.Value == "Xbox" then
						game.GuiService.SelectedObject = script.Parent.Confirm.Locked.Contents.Close
					end
				end
				script.Parent.Confirm.Visible = true
				script.Parent.Cover.Visible = true
				Modules.ItemInfo.hide()

			end
		else
			script.Parent.Confirm.Visible = false
			script.Parent.Cover.Visible = false
		end
	end)

	script.Parent.Confirm.Cancel.MouseButton1Click:connect(function()
		Sounds.Click:Play()
		script.Parent.SelectedItem.Value = 0
		if Modules.Input.mode.Value == "Xbox" then
			for i,Button in pairs(script.Parent.Frame.Items:GetChildren()) do
				if Button.Visible and Button:FindFirstChild("ItemId") and Button.ItemId.Value == script.Parent.Shop.SelectedItem.Value then
					game.GuiService.SelectedObject = Button
				end
			end
		end

	end)

	script.Parent.Amount.Changed:connect(function()
		script.Parent.Confirm.Amount.Value.Text = tostring(script.Parent.Amount.Value)
	end)

	script.Parent.Confirm.Amount.Value:GetPropertyChangedSignal("Text"):connect(function()
		local Num = tonumber(script.Parent.Confirm.Amount.Value.Text)
		Num = Num or 0
		local Value = math.ceil(Num)
		if Value == nil or Value <= 0 then
			Value = 1
		elseif Value > 99 then
			Value = 99
		end
		script.Parent.Amount.Value = Value
	end)

	script.Parent.Confirm.Amount.Increase.MouseButton1Click:connect(function()
		Sounds.Tick:Play()
		local Value = math.ceil(script.Parent.Amount.Value * 1.3) + 1
		if Value > 99 then
			Value = 99
		end
		script.Parent.Amount.Value = Value
	end)

	script.Parent.Confirm.Amount.Decrease.MouseButton1Click:connect(function()
		Sounds.Tick:Play()
		local Value = math.ceil(script.Parent.Amount.Value * 0.7) - 1
		if Value <= 0 then
			Value = 1
		end
		script.Parent.Amount.Value = Value
	end)

	local Debounce = true

	local function findButtonById(Id)
		for i,Button in pairs(script.Parent.Frame.Items:GetChildren()) do
			if Button:FindFirstChild("ItemId") and Button.ItemId.Value == Id then
				return Button
			end
		end
	end

	function module.Buy()
		if Debounce then
			Debounce = false

			local old = script.Parent.SelectedItem.Value

			local Item = getItemById(script.Parent.SelectedItem.Value)

			if Item then

				if Item.ItemType.Value == 7 and Item:FindFirstChild("Crystals") and (Item.Crystals.Value * script.Parent.Amount.Value) >= 100 then
					local uccost = (Item.Crystals.Value * script.Parent.Amount.Value)
					if not Modules.InputPrompt.prompt("Are you sure you want to spend ".. MoneyLib.DealWithPoints(uccost) .. " uC?") then
						Debounce = true
						return false
					end
				end

				local Success = game.ReplicatedStorage.BuyItem:InvokeServer(Item.Name,script.Parent.Amount.Value)
				if Success then
					script.Parent.Confirm.Buy.BackgroundColor3 = Color3.new(30/255,1,30/255)
					Sounds.Purchase:Play()

					local Button = findButtonById(script.Parent.SelectedItem.Value)
					if Button then
						local Rep = Instance.new("ImageLabel")
						Rep.ZIndex = 5
						Rep.BackgroundTransparency = 1
						Rep.ImageTransparency = 1

						Rep.Size = UDim2.new(0,script.Parent.Confirm.Icon.AbsoluteSize.X,0,script.Parent.Confirm.Icon.AbsoluteSize.Y)

						local StartPos = script.Parent.Confirm.Icon.AbsolutePosition

						Rep.Position = UDim2.new(0,StartPos.X,0,StartPos.Y)
						Rep.Image = Button.Thumbnail.Image
						Rep.Parent = script.Parent.Parent
						Rep.BorderSizePixel = 0

						tween(Rep,{"ImageTransparency"},0,0.3)
						wait(0.3)

						Sounds.SwooshFast:Play()

						--local Pos = script.Parent.NavBar.Inventory.AbsolutePosition + (script.Parent.NavBar.Inventory.AbsoluteSize / 2)
						Rep:TweenPosition(UDim2.new(0,0,0.5,0),nil,Enum.EasingStyle.Linear,1)
						Rep:TweenSize(UDim2.new(0,0,0,0),nil,Enum.EasingStyle.Bounce,1)
						game.Debris:AddItem(Rep,1)
					end


					wait(0.3)
					if script.Parent.SelectedItem.Value == old then
						script.Parent.SelectedItem.Value = 0
					end
				else
					script.Parent.Confirm.Buy.BackgroundColor3 = Color3.new(1,70/255,70/255)
					Sounds.Error:Play()
					if Item and Item:FindFirstChild("Crystals") then
						Modules.Premium.show()
					end
					wait(0.5)
				end
			end
			compareCash()
			Debounce = true
		end
	end

	script.Parent.Confirm.Buy.MouseButton1Click:connect(function()
		Sounds.Click:Play()
		module.Buy()
	end)

	script.Parent.SelectedItem.Value = -1

	-- Search setup

	script.Parent.Frame.Desc.Search.Cancel.MouseButton1Click:connect(function()
		Sounds.Click:Play()
		script.Parent.Frame.Desc.Search.Cancel.Visible = false

		script.Parent.Frame.Desc.Search.Text = ""
	end)

	script.Parent.Frame.Desc.Search:GetPropertyChangedSignal("Text"):Connect(function()
		-- Apply changes
		Fill()
		if script.Parent.Frame.Desc.Search.Text == "Search..." or script.Parent.Frame.Desc.Search.Text == "" then
			script.Parent.Frame.Desc.Search.Cancel.Visible = false

			if script.Parent.Mode.Value == "Custom" then
				script.Parent.Mode.Value = "New"
			end
		else
			script.Parent.Frame.Desc.Search.Cancel.Visible = true

			if script.Parent.Mode.Value == "New" then
				script.Parent.Mode.Value = "Custom"
			end
		end
	end)


end

return module
