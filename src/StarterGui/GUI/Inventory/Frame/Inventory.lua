-- Inventory Module

--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

local module = {}

local Inventory


local function getInventory()
	print("Fetching inventory")
	local inv = game.ReplicatedStorage.FetchInventory:InvokeServer()
	print("Got inventory")
	return inv
end

module.sortedItems = nil

local SortType = "Id"

local Tween
local Sounds

local NewestItems = {}

local function isNewItem(Id)
	for i,ed in pairs(NewestItems) do
		if Id == ed then
			return true
		end
	end
end


local ItemTotal = #game.ReplicatedStorage.Items:GetChildren()


local tutorialColor0 = Color3.fromRGB(84,255,95)
local tutorialColor1 = Color3.fromRGB(255, 176, 80)

local currentTutorialItem
local inventoryFrame = script.Parent.Parent
local Items = script.Parent.Items
local tutorialFrame = inventoryFrame.Tutorial
function module.highlightTutorialItem(itemId)

	if not tonumber(itemId) and itemId ~= nil then
		error("Attempt to tutorial highlight with an invalid value")
	end

	local function findFrame(itemId)
		for _,frame in next,Items:GetChildren() do
			if frame:FindFirstChild("ItemId") and frame.ItemId.Value == itemId then
				return frame
			end
		end
	end

	local function updateInventoryForHighlight(newItem)
		local lastItem = currentTutorialItem

		--if last,
			--if next,
				--next replaces last
			--else
				--remove last
		--else
			--if next,
				--next replaces last
			--else
				--dont do anything

		local a = (tick()*.8)%2
		a = .5 - .5 * math.cos(math.pi*a)

		local nextFrame,lastFrame
		if lastItem then
			if newItem then
				--replacing mechanic
				nextFrame = findFrame(newItem)
				if nextFrame then
					nextFrame.TutorialGlow.Visible = true
					nextFrame.Arrow.Visible = true
				end
			end
			lastFrame = findFrame(lastItem)
			if lastFrame and lastFrame ~= nextFrame then
				lastFrame.TutorialGlow.Visible = false
				lastFrame.Arrow.Visible = false
			end
		else
			if newItem then
				--replace
				nextFrame = findFrame(newItem)
				if nextFrame then
					nextFrame.TutorialGlow.Visible = true
					nextFrame.Arrow.Visible = true
				end
			end
		end

		tutorialFrame.Visible = nextFrame ~= nil

		if lastFrame == nextFrame then
			nextFrame = lastFrame
		end

		if nextFrame then
			--Update arrows based on nextFrame position
			local frameTopEdge = nextFrame.AbsolutePosition.y
			local frameBottomEdge = frameTopEdge + nextFrame.AbsoluteSize.y

			local mainTopEdge = Items.AbsolutePosition.y
			local mainBottomEdge = mainTopEdge + Items.AbsoluteSize.y

			--bottom arrow
			tutorialFrame.Down.Visible = frameTopEdge > mainBottomEdge
			tutorialFrame.Up.Visible = frameBottomEdge < mainTopEdge

			local doBottom = frameTopEdge + (frameBottomEdge - frameTopEdge)*.5 < mainTopEdge + (mainBottomEdge - mainTopEdge)*.5
			nextFrame.Arrow.Position = doBottom and UDim2.new(.5,0,1,0) or UDim2.new(.5,0,0,0)
			nextFrame.Arrow.Image = doBottom and "rbxassetid://1976183142" or "rbxassetid://1976183443"

			--Color
			local currentColor = tutorialColor0:Lerp(tutorialColor1,a)
			local a1 = (tick()*1.75)%2
			a1 = .5 - .5 * math.cos(math.pi*a1)
			nextFrame.TutorialGlow.ImageColor3 = currentColor
			nextFrame.Arrow.ImageColor3 = currentColor
			nextFrame.TutorialGlow.ImageTransparency = a1*.8
			tutorialFrame.Down.ImageColor3 = currentColor
			tutorialFrame.Up.ImageColor3 = currentColor

			--Position
			--tutorialFrame.Down.Position = UDim2.new(.5,0,1,-5 - a*5)
			--tutorialFrame.Up.Position = UDim2.new(.5,0,0,a*5)
		end
	end


	if itemId == nil and currentTutorialItem then
		updateInventoryForHighlight()
		currentTutorialItem = nil
	elseif itemId ~= nil and not currentTutorialItem or itemId ~= currentTutorialItem then
		updateInventoryForHighlight(itemId)
		currentTutorialItem = itemId
	elseif itemId == currentTutorialItem then
		updateInventoryForHighlight(itemId)
	end
end

function module.favorite(Button)
	local Id = Button.ItemId.Value
	Button.Amount.Visible = false
	Button.Tier.Visible = false

	local SortVal = Id
	if SortType == "New" then
		SortVal = ItemTotal - Id
	elseif SortType == "Tier" then
		local RealItem = module.sortedItems[Id]
		if RealItem then
			SortVal = (200 - RealItem.Tier.Value)
		else
			SortVal = -1
		end
	end

	if Inventory[Id].Favorite then
		Inventory[Id].Favorite = nil
		Sounds.Tick:Play()
		Button.Favorite.Visible = false



		if Button.New.Visible then
			Button.BorderSizePixel = 2
			Button.BorderColor3 = Button.New.BackgroundColor3
			Button.LayoutOrder = 1000 + SortVal
		else
			Button.BorderSizePixel = 0
			Button.LayoutOrder = 2000 + SortVal
			if SortType == "Tier" then
				local RealItem = module.sortedItems[Id]
				local RealTier = game.ReplicatedStorage.Tiers:FindFirstChild(tostring(RealItem.Tier.Value))
				if RealTier then
					Button.BorderSizePixel = 2
					Button.Tier.Visible = true
					Button.Tier.BackgroundColor3 = RealTier.TierColor.Value
					Button.BorderColor3 = RealTier.TierColor.Value
				end
			end
		end
	else
		Inventory[Id].Favorite = true
		Button.Favorite.ImageTransparency = 1
		Button.Favorite.Size = UDim2.new(1,0,1,0)
		Button.Favorite.Position = UDim2.new(1,0,1,0)
		Button.Favorite.Visible = true
		Button.BorderSizePixel = 3
		Button.BorderColor3 = Button.Favorite.BackgroundColor3
		Tween(Button.Favorite,{"ImageTransparency"},0,0.3)
		Sounds.Favorite:Play()
		wait(0.3)
		Button.LayoutOrder = SortVal
		Button.Favorite:TweenSizeAndPosition(UDim2.new(0.3,0,0.3,0),UDim2.new(1,0,1,0),nil,nil,0.3)
	end
end

local ToggleFav = module.favorite



local function findId(Items,Id)
	for i,Item in pairs(Items) do
		if Item.ItemId.Value == Id then
			return Item
		end
	end
end

local function sortItems()
	local Items = {}
	local RealItems = game.ReplicatedStorage.Items:GetChildren()
	for i=1,#RealItems do
		Items[i] = findId(RealItems,i)
	end
	return Items
end

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



local function refreshInventory(NewItemId)

	if NewItemId and not isNewItem(NewItemId) then
		if #NewestItems > 5 then
			table.remove(NewestItems,1)
		end
		table.insert(NewestItems,NewItemId)
	end

	if Inventory then
		local Count = 1

		for id,Item in pairs(Inventory) do

			if Item then

				if Item.Quantity and Item.Quantity > 0 then
					local RealItem = module.sortedItems[id]
					if RealItem then



						local Active = true
						if string.len(script.Parent.Bottom.Search.Text) > 0 and script.Parent.Bottom.Search.Text ~= "Search..." then
							Active = matches(RealItem, script.Parent.Bottom.Search.Text)
						end

						local Button = script.Parent.Items:FindFirstChild("Button"..tostring(Count))

						-- get to this
						--local SortVal = id
						local SortVal = id
						if SortType == "New" then
							SortVal = ItemTotal - id
						elseif SortType == "Tier" then
							SortVal = (200 - RealItem.Tier.Value)
						end

						if Button and Active then

							Button.Amount.Text = "x"..Item.Quantity

							Button.Tier.Visible = false
							--Button.Image = "rbxassetid://"..RealItem.ThumbnailId.Value
							Button.Thumbnail.Image = "rbxassetid://"..RealItem.ThumbnailId.Value
							Button.ItemId.Value = id
							Button.ImageTransparency = 0
							Button.Visible = true

							local BorderCol = Color3.fromRGB(255,255,255)
							local RealTier = game.ReplicatedStorage.Tiers:FindFirstChild(tostring(RealItem.Tier.Value))
							if RealTier then
								BorderCol = RealTier.TierBackground.Value
							end

							Button.ImageColor3 = BorderCol
							Button.Inner.ImageColor3 = BorderCol

							if isNewItem(id) then
								Button.New.Visible = true
								Button.BorderSizePixel = 2
								Button.BorderColor3 = Button.New.BackgroundColor3
								Button.New.Visible = true
								Button.LayoutOrder = 1000 + SortVal
							else
								Button.New.Visible = false
							end

							if Item.Favorite then
								Button.Favorite.Visible = true
								Button.BorderSizePixel = 3
								Button.BorderColor3 = Button.Favorite.BackgroundColor3

								Button.LayoutOrder = SortVal-- Put favorited items first
							elseif not Button.New.Visible then
								Button.Favorite.Visible = false
								Button.BorderSizePixel = 0
								--[[
								if SortType == "Tier" then
									local RealTier = game.ReplicatedStorage.Tiers:FindFirstChild(tostring(RealItem.Tier.Value))
									if RealTier then
										Button.BorderSizePixel = 2
										Button.Tier.Visible = true
										Button.Tier.BackgroundColor3 = RealTier.TierColor.Value
										Button.BorderColor3 = RealTier.TierColor.Value
									end
								end
								]]
								Button.LayoutOrder = 2000 + SortVal
							end
							Count = Count + 1
						end
					end
				end

			end
		end
		for i=Count,#script.Parent.Items:GetChildren() do
			local Button = script.Parent.Items:FindFirstChild("Button"..tostring(i))
			if Button then
				Button.Visible = false
				Button.ItemId.Value = 0
			end
		end
		script.Parent.Items.Count.Value = Count
	end

end

function module.init(Modules)

	-- Refresh inventory when opened
	Modules.Focus.current.Changed:Connect(function()
		if Modules.Focus.current.Value == script.Parent.Parent then
			Inventory = getInventory()
			module.localInventory = getInventory()
			refreshInventory()
		end
	end)

	spawn(function()
		local Success, Error = pcall(function()
			Inventory = getInventory()
			module.localInventory = Inventory


			local Placement = Modules["Placement"]
			Sounds = Modules["Menu"]["sounds"]

			local TycoonLib = Modules["TycoonLib"]

			Tween = Modules["HUD"]["tween"]


			--script.Parent.Parent.Top.Close.MouseButton1Click:connect(function()
			script.Parent.Parent.Close.MouseButton1Click:connect(function()
				--Modules.Focus.close()
				Modules.Input.toggleInventory()
				Modules.Menu.sounds.Click:Play()
			end)
			--[[
			local function modecheck()
				if Modules.Input.mode.Value == "Xbox" then
					script.Parent.Bottom.LayoutOrder = 4
				else
					script.Parent.Bottom.LayoutOrder = 1
				end
			end
			modecheck()
			Modules.Input.mode.Changed:connect(modecheck)
			]]

			module.sortedItems = sortItems()


			local Settings = game.Players.LocalPlayer:FindFirstChild("PlayerSettings")

			local function SortCheck()



				for i,Button in pairs(script.Parent.Bottom.Sorts:GetChildren()) do
					if Button:IsA("GuiButton") then
						if Button.Name == Settings.InventorySort.Value then
							Button.BackgroundColor3 = Color3.fromRGB(171,171,171)
							SortType = Button.Name
						else
							Button.BackgroundColor3 = Color3.fromRGB(107,107,107)
						end
					end
				end

				refreshInventory()


			end

			if Settings then
				SortCheck()
				--Settings.InventorySort.Changed:connect(SortCheck)
			end

			for i,Button in pairs(script.Parent.Bottom.Sorts:GetChildren()) do
				if Button:IsA("GuiButton") then
					Button.MouseButton1Click:connect(function()
						Sounds.Click:Play()
						-- change the sort quickly locally
						Settings.InventorySort.Value = Button.Name
						SortCheck()
						game.ReplicatedStorage.ChangeSetting:InvokeServer("InventorySort",Button.Name)
					end)
				end
			end


			local function PermCheck()
				script.Parent.Bottom.Locked.Visible = not TycoonLib.hasPermission(game.Players.LocalPlayer, "Build")
			end
			PermCheck()
			game.ReplicatedStorage.PermissionsChanged.OnClientEvent:connect(PermCheck)

			local SampleButton = script.Parent.Items.SampleItem

			local Items = game.ReplicatedStorage.Items:GetChildren()
			for i=#Items,1,-1 do
				local Button = SampleButton:Clone()
				Button.Name = "Button"..tostring(i)
				Button.Parent = script.Parent.Items
				Button.ImageTransparency = 1

				Button.ItemId.Changed:connect(function()
					Button.Favorite.Visible = false
					Button.New.Visible = false
				end)

				-- Xbox
				Button.SelectionGained:connect(function()
					if Modules.Input.mode.Value ~= "Mobile" then
						--Tween(script.Parent.Parent.Cover,{"BackgroundTransparency"},0.5,0.3)
						--script.Parent.Parent.Cover.Visible = true
						Modules.ItemInfo.show(Button)
					end
				end)
				Button.SelectionLost:connect(function()
					if Modules.Input.mode.Value ~= "Mobile" then
						--Tween(script.Parent.Parent.Cover,{"BackgroundTransparency"},1,0.3)
						--script.Parent.Parent.Cover.Visible = false
						Modules.ItemInfo.hide(Button)
					end
				end)
				-- PC
				Button.MouseEnter:connect(function()
					if Modules.Input.mode.Value ~= "Mobile" then
						--Tween(script.Parent.Parent.Cover,{"BackgroundTransparency"},0.5,0.3)
						--script.Parent.Parent.Cover.Visible = true
						Modules.ItemInfo.show(Button)
					end
				end)

				Button.MouseLeave:connect(function()
					if Modules.Input.mode.Value ~= "Mobile" then
						--Tween(script.Parent.Parent.Cover,{"BackgroundTransparency"},1,0.3)
						--script.Parent.Parent.Cover.Visible = false
						Modules.ItemInfo.hide(Button)
					end
				end)

				Button.MouseButton1Click:connect(function()
					Sounds.Click:Play()
					Button.Amount.Visible = false
					if Button.ItemId.Value > 0 then
						if not script.Parent.Bottom.Locked.Visible then
							Placement.startPlacing(Button.ItemId.Value,Button)
						else
							Sounds.Error:Play()
						end
					end
				end)
				Button.MouseButton2Click:connect(function()
					Button.Active = false
					local Id = Button.ItemId.Value
					if Id > 0 then
						local Success = game.ReplicatedStorage.ToggleFavorite:InvokeServer(Button.ItemId.Value)
						if not Success then
							Sounds.Error:Play()
						else
							--Tween(script.Parent.Parent.Cover,{"BackgroundTransparency"},1,0.3)
							--script.Parent.Parent.Cover.Visible = false
							Modules.ItemInfo.hide(Button)

							ToggleFav(Button)
						end
					end
					Button.Active = true
				end)

			end


			script.Parent.Bottom.Search.Cancel.MouseButton1Click:connect(function()
				Sounds.Click:Play()
				script.Parent.Bottom.Search.Cancel.Visible = false
				script.Parent.Bottom.Search.TextTransparency = 0.5
				script.Parent.Bottom.Search.Font = Enum.Font.SourceSansItalic
				script.Parent.Bottom.Search.Text = "Search..."
			end)

			script.Parent.Bottom.Search:GetPropertyChangedSignal("Text"):Connect(function()
				refreshInventory()
				if script.Parent.Bottom.Search.Text == "Search..." or script.Parent.Bottom.Search.Text == "" then
					script.Parent.Bottom.Search.Cancel.Visible = false
					script.Parent.Bottom.Search.TextTransparency = 0.5
					script.Parent.Bottom.Search.Font = Enum.Font.SourceSansItalic
				else
					script.Parent.Bottom.Search.Cancel.Visible = true
					script.Parent.Bottom.Search.TextTransparency = 0.2
					script.Parent.Bottom.Search.Font = Enum.Font.SourceSansBold
				end
			end)

			SampleButton:Destroy()

			script.Parent.Items.UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder






			refreshInventory()


			game.ReplicatedStorage.InventoryChanged.OnClientEvent:connect(function(inv, newitemid)
				if inv then
					Inventory = inv
					module.localInventory = inv
				else
					Inventory = getInventory()
					module.localInventory = getInventory()
				end
				refreshInventory(newitemid)
			end)

			game.Players.LocalPlayer.ActiveTycoon.Changed:connect(function()
				if game.Players.LocalPlayer.ActiveTycoon.Value ~= nil then
					refreshInventory()
				end
			end)

			wait()

			Inventory = getInventory()
			module.localInventory = Inventory
			refreshInventory()
		end)
		if not Success then
			warn("Error setting up inventory: "..Error)
		end
	end)
end

return module
