--MOTD system
--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

local module = {}

function module.open()
	warn("MOTDModule.open not ready yet")
end

function module.init(Modules)
	local Sounds = Modules.Menu.sounds

	local closed = false

	local function close(String, Type)

		if Type == Enum.UserInputState.Cancel then
			return false
		end

		if not closed then
			closed = true
			Sounds.Click:Play()
			Modules.Focus.close()
		end
	end



	script.Parent.Bottom.Close.MouseButton1Click:connect(close)
	script.Parent.Top.Close.MouseButton1Click:connect(close)

	function module.open()
		if not closed then
			Modules.Focus.change(script.Parent)
			script.Parent.Visible = true
			Modules.HUD.hideHUD()
		end
	end

	script.Parent.Parent.HUDRight.OpenMotd.MouseButton1Click:connect(module.open)

	local function check()
		if game.Players.LocalPlayer.MOTD.Value < game.ReplicatedStorage.MOTD.Value then
			script.Parent.Parent.HUDRight.OpenMotd.Visible = true

		else
			script.Parent.Parent.HUDRight.OpenMotd.Visible = false
		end
	end
	check()
	game.Players.LocalPlayer.MOTD.Changed:connect(check)

	spawn(function()
		wait(3)
		--[[
		if script.Parent.Parent.NewPlayer.Visible then
			closed = true

			game.ReplicatedStorage.MOTDRead:InvokeServer()


		elseif game.Players.LocalPlayer.MOTD.Value < game.ReplicatedStorage.MOTD.Value then
			Modules.Focus.change(script.Parent)

			script.Parent.Visible = true
			Modules.HUD.hideHUD()

		end
		]]
	end)

	local function getItemFromId(Id)
		for i,Item in pairs(game.ReplicatedStorage.Items:GetChildren()) do
			if Item.ItemId.Value == Id then
				return Item
			end
		end
	end

	if script.Parent.Body.newitems.Visible then
		local max = #game.ReplicatedStorage.Items:GetChildren()
		local min = script.Parent.NewItemId.Value
		local count = (max - min + 1)
		local total = count

		if count > 1 then
			for i = 0,((max-min)) do
				local Item = getItemFromId(min + i)
				if Item and Item:FindFirstChild("Omit") then
					total = total - 1
				end
			end
		end

		if count > 1 then
			for i = 0,((max-min)) do
				local Item = getItemFromId(min + i)
				if Item and Item:FindFirstChild("Omit") == nil then
					local Button = script.Parent.Body.newitems.SampleItem:Clone()
					Button.Name = Item.Name
					Button.ItemId.Value = Item.ItemId.Value
					Button.Thumbnail.Image = "rbxassetid://"..Item.ThumbnailId.Value
					local Tier = game.ReplicatedStorage.Tiers:FindFirstChild(Item.Tier.Value)
					if Tier then
						Button.ImageColor3 = Tier.TierBackground.Value
						Button.Inner.ImageColor3 = Tier.TierBackground.Value
					end
					if count * 92 > script.Parent.Body.newitems.Items.AbsoluteSize.X then
						Button.Size = UDim2.new(1/total,0,1,0)
					else
						Button.Size = UDim2.new(0,92,0,92)
					end
					Button.Visible = true
					if Button.AbsoluteSize.Y > Button.AbsoluteSize.X then
						Button.Thumbnail.SizeConstraint = Enum.SizeConstraint.RelativeYY
					else
						Button.Thumbnail.SizeConstraint = Enum.SizeConstraint.RelativeXX
					end
					Button.Parent = script.Parent.Body.newitems.Items
				end
			end

			for i,Button in pairs(script.Parent.Body.newitems.Items:GetChildren()) do
				if Button:IsA("GuiButton") then

					Button.MouseEnter:connect(function()
						if Modules.Input.mode.Value ~= "Mobile" then
							Modules.ItemInfo.show(Button)
						end
					end)

					Button.MouseLeave:connect(function()
						if Modules.Input.mode.Value ~= "Mobile" then
							Modules.ItemInfo.hide(Button)
						end
					end)

				end
			end

		else
			script.Parent.Body.newitems.Visible = false
		end
	end

end
return module
