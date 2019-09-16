--Craftsman Menu
--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

local module = {}

local function getItemById(ItemId)
	for i,Item in pairs(game.ReplicatedStorage.Items:GetChildren()) do
		if Item:FindFirstChild("ItemId") and Item.ItemId.Value == ItemId then
			return Item
		end
	end
end


function module.init(Modules)

	local Buttons = {}

	local MoneyLib = Modules.MoneyLib

	local Items = {}
	for i,Item in pairs(game.ReplicatedStorage.Items:GetChildren()) do
		if Item:FindFirstChild("Tier") and Item.Tier.Value == 100 and Item:FindFirstChild("EnchantCost") then
			table.insert(Items,Item)
		end
	end

	local function show(Item)
		Buttons = {}
		script.Parent.Contents.Item.Thumbnail.Image = "rbxassetid://"..Item.ThumbnailId.Value
		for i,Cost in pairs(script.Parent.Contents.Cost:GetChildren()) do
			if Cost:IsA("GuiObject") then
				Cost:Destroy()
			end
		end
		for i,Cost in pairs(Item.EnchantCost:GetChildren()) do
			local Button = script.Parent.Contents.SampleItem:Clone()
			Button.Name = Cost.Name

			Button.Amount.Text = "x"..MoneyLib.DealWithPoints(Cost.Value)
			if Button.Name == "Shards" then
				Button.LayoutOrder = 3
				Button.Thumbnail.Image = "rbxassetid://1679226088"
				Button.BackgroundColor3 = Color3.fromRGB(169, 248, 255)
				Button.Hover.Text = "Shards of Life (you have ".. game.Players.LocalPlayer.Shards.Value .. ")"
			else
				Button.LayoutOrder = 1
				Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				local Real = getItemById(tonumber(Cost.Name))
				Button.Hover.Text = "Item"
				if Real then
					Button.Thumbnail.Image = "rbxassetid://"..Real.ThumbnailId.Value
					local Amount = 0
					local Suffix = ""
					local Inventory = Modules.Inventory.localInventory
					if Inventory and Inventory[Real.ItemId.Value] and Inventory[Real.ItemId.Value].Quantity then
						Suffix = " (you have "..Inventory[Real.ItemId.Value].Quantity..")"
					end
					local HoverText = Real.Name .. Suffix
					Button.Hover.Text = HoverText
					local Tag = Instance.new("IntValue")
					Tag.Name = "RealItemId"
					Tag.Value = Real.ItemId.Value
					Tag.Parent = Button
				end
			end
			Button.Hover.Visible = false
			Button.Parent = script.Parent.Contents.Cost
			Button.Visible = true
			table.insert(Buttons, Button)
			local function showHover()
				for i,oButton in pairs(Button.Parent:GetChildren()) do
					if oButton:IsA("GuiObject") and oButton:FindFirstChild("Hover") then

						oButton.Hover.Visible = false
					end
				end
				if Button:FindFirstChild("RealItemId") then
					local Real = getItemById(Button.RealItemId.Value)
					local Suffix = ""
					local Inventory = Modules.Inventory.localInventory
					if Real and Inventory and Inventory[Real.ItemId.Value] and Inventory[Real.ItemId.Value].Quantity then
						Suffix = " (you have "..Inventory[Real.ItemId.Value].Quantity..")"
						Button.Hover.Text = Real.Name .. Suffix
					end

				end
				Button.Hover.Visible = true
			end
			Button.MouseEnter:Connect(showHover)
			Button.SelectionGained:Connect(showHover)
			Button.MouseLeave:Connect(function()
				Button.Hover.Visible = false
			end)
			Button.SelectionLost:Connect(function()
				Button.Hover.Visible = false
			end)
		end
	end

	local Index = 1
	show(Items[Index])

	script.Parent.Contents.Frame.Last.MouseButton1Click:Connect(function()
		Index = Index - 1
		if Index <= 0 then
			Index = #Items
		end
		show(Items[Index])
	end)

	script.Parent.Contents.Frame.Next.MouseButton1Click:Connect(function()
		Index = Index + 1
		if Index > #Items then
			Index = 1
		end
		show(Items[Index])
	end)

	script.Parent.Contents.Buy.MouseButton1Click:Connect(function()
		local Button = script.Parent.Contents.Buy
		if Button.Active then
			if not Modules.InputPrompt.prompt("Are you sure you want to forge this item?") then
				return false
			end
			Button.Active = false
			Modules.Menu.sounds.Click:Play()
			local Item = Items[Index]
			if Item then
				local Success = game.ReplicatedStorage.BuyItem:InvokeServer(Item.Name, 1)
				if Success then
					script.Parent.Contents.Buy.BackgroundColor3 = Color3.new(0,0,0)
					Modules.Menu.tween(script.Parent.Contents.Buy,{"BackgroundColor3"},Color3.fromRGB(255, 206, 166),1)
					Modules.Menu.sounds.Enchant:Play()

					script.Parent.ImageColor3 = Color3.new(0,0,0)
					Modules.Menu.tween(script.Parent,{"ImageColor3"},Color3.fromRGB(72, 43, 43),1)

					local Fade = script.Parent.Contents.Item.Fade
					Fade.Image = script.Parent.Contents.Item.Thumbnail.Image
					Fade.Size = UDim2.new(1,-10,1,-10)
					Fade.ImageTransparency = 0
					Fade.Visible = true
					Modules.Menu.tween(Fade,{"ImageTransparency","Size"},{1,UDim2.new(2,0,2,0)},0.3)
					wait(0.5)
					Fade.Visible = false
				else
					Modules.Menu.sounds.Error:Play()
					Button.BackgroundColor3 = Color3.new(1,0.7,0.7)
					wait(0.3)
					Button.BackgroundColor3 = Color3.fromRGB(255, 206, 166)
				end
			end
			Button.Active = true
		end
	end)

	script.Parent.Top.Close.MouseButton1Click:Connect(function()
		Modules.Menu.sounds.Click:Play()
		Modules.Focus.close()
	end)
end

return module