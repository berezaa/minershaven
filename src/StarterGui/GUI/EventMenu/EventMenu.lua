-- Event Menu
--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

local module = {}

local Player = game.Players.LocalPlayer

function module.init(Modules)

	local function reset()
		local len = 0
		for i,Child in pairs(script.Parent.Contents.Items:GetChildren()) do
			if Child:IsA("GuiObject") and Child.Visible then
				len = len + Child.AbsoluteSize.X + 5
			end
		end
		script.Parent.Contents.Items.CanvasSize = UDim2.new(0,len,0,0)
	end

	Modules.Focus.current.Changed:connect(function()
		if Modules.Focus.current.Value == script.Parent then
			reset()
		end
	end)

	script.Parent.Top.Close.MouseButton1Click:connect(function()
		Modules.Menu.sounds.Click:Play()
		Modules.Focus.close()
	end)

	script.Parent.Parent.HUDRight.OpenEvent.MouseButton1Click:connect(function()
		Modules.Focus.change(script.Parent)
		script.Parent.Visible = true
	end)

	local function update()
		script.Parent.Contents.Amount.Value.Text = Player.MagicClovers.Value
		--script.Parent.Parent.HUDRight.OpenEvent.Amount.Text = Player.MagicClovers.Value
		--script.Parent.Parent.HUDRight.OpenEvent.Amount.Visible = (Player.MagicClovers.Value > 0)
		if Player.MagicClovers.Value >= 5 then
			script.Parent.Parent.HUDRight.OpenEvent.Visible = true
		else
			script.Parent.Parent.HUDRight.OpenEvent.Visible = false
		end
	end
	update()
	Player.MagicClovers.Changed:connect(update)

	for i,Item in pairs(game.ReplicatedStorage.Items:GetChildren()) do
		if Item:FindFirstChild("MagicClover") then
			local Button = script.Parent.Contents.Items.Sample:Clone()
			Button.Name = Item.Name
			Button.Icon.Image = "rbxassetid://"..Item.ThumbnailId.Value
			Button.Icon.Cost.Value.Text = Item.MagicClover.Value
			Button.LayoutOrder = Item.MagicClover.Value
			Button.Visible = true
			Button.Parent = script.Parent.Contents.Items
		end
	end

	for i,Button in pairs(script.Parent.Contents.Items:GetChildren()) do
		if Button:IsA("GuiButton") then

			Button.MouseButton1Click:connect(function()

				-- todo: request
				local Success = game.ReplicatedStorage.BuyEventItem:InvokeServer(Button.Name)
				if Success then
					Button.Icon.Cost.BackgroundColor3 = Color3.new(0.8,1,0.8)
					Modules.Menu.sounds.Purchase:Play()
					wait(0.2)
					Button.Icon.Cost.BackgroundColor3 = Color3.new(1,1,1)
				else
					Button.Icon.Cost.BackgroundColor3 = Color3.new(1,0.8,0.8)
					Modules.Menu.sounds.Error:Play()
					wait(0.2)
					Button.Icon.Cost.BackgroundColor3 = Color3.new(1,1,1)
				end
			end)
		end
	end

	reset()

end

return module
