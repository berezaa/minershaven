-- Daily Gift
--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

local module = {}



function module.init(Modules)

	local Tween = Modules.Menu.tween
	local MoneyLib = Modules.MoneyLib


	script.Parent.Bottom.Done.MouseButton1Click:connect(function()
		Modules.Focus.close()

		if game.Players.LocalPlayer.ActiveTycoon.Value ~= nil then
			--Modules.HUD.showHUD()
		end
	end)

	script.Parent.Bottom.Buy.MouseButton1Click:connect(function()
		Modules.Focus.close()
		game.MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer, 24262357)
		if game.Players.LocalPlayer.ActiveTycoon.Value ~= nil then
			--Modules.HUD.showHUD()
		end
	end)

	local Count = 0

	local function clearcontents()
		for i,Child in pairs(script.Parent.Contents:GetChildren()) do
			if Child:FindFirstChild("Title") then
				Child:Destroy()
			end
		end
		Count = 0
	end

	local function addItem(Text,Image,Color)
		Color = Color or Color3.fromRGB(150,150,150)

		local Item = script.Parent.SampleItem:Clone()

		Item.Title.Text = Text
		Item.Title.TextColor3 = Color
		Item.BorderColor3 = Color

		Item.BackgroundColor3 = Color3.fromRGB(100 + Color.r*40, 100 + Color.g*40, 100 + Color.b*40)
		Item.Thumbnail.BackgroundColor3 = Color3.fromRGB(100 + Color.r*100, 100 + Color.g*100, 100 + Color.b*100)

		if Image then
			Item.Thumbnail.Visible = true
			Item.Thumbnail.Image = Image
			Item.BG.Visible = true
			Item.BG.Image = Image
		else
			Item.Thumbnail.Visible = false
			Item.BG.Visible = false
		end

		Item.Parent = script.Parent.Contents
		Item.Visible = true
		Item.LayoutOrder = Count

		Item.Position = UDim2.new(0,0,0,Count * (script.Parent.SampleItem.AbsoluteSize.Y + 10))

		Count = Count + 1

		script.Parent.Contents.CanvasSize = UDim2.new(0,0,0,10 + (Count * (script.Parent.SampleItem.AbsoluteSize.Y + 10)))
	end

	local function getItemFromId(Id)
		for i,Item in pairs(game.ReplicatedStorage.Items:GetChildren()) do
			if Item.ItemId.Value == Id then
				return Item
			end
		end
	end

	local function open(Money,ItemId,Amount,Crystals,ExtraRewards)
		script.Parent.Position = UDim2.new(0.5,0,1,0)

		Modules.Focus.change(script.Parent)

		script.Parent.Visible = true

		script.Parent.BG.ImageTransparency = 1
		Tween(script.Parent.BG,{"ImageTransparency"},0,1)


		--Modules.HUD.hideHUD()

			script.Parent.Bottom.Buy.Visible = true

			if game.Players.LocalPlayer:FindFirstChild("SecondGift") then
				script.Parent.Title.TextColor3 = Color3.new(1,1,0)
				script.Parent.Title.Text = "Bonus Gift"
				script.Parent.Bottom.Buy.Visible = false
			elseif game.Players.LocalPlayer:FindFirstChild("Executive") then
				script.Parent.Title.TextColor3 = Color3.fromRGB(255, 71, 74)
				script.Parent.Title.Text = "Executive Gift"
			elseif game.Players.LocalPlayer:FindFirstChild("VIP") then
				script.Parent.Title.TextColor3 = Color3.fromRGB(73, 225, 255)
				script.Parent.Title.Text = "V.I.P. Gift"
			else
				script.Parent.Title.TextColor3 = Color3.fromRGB(255, 98, 248)
				script.Parent.Title.Text = "Daily Gift"
			end

			script.Parent.BG.ImageColor3 = script.Parent.Title.TextColor3

		clearcontents()

	 	local RealItem = getItemFromId(ItemId)

		if RealItem and Amount > 0 then
			local Suffix = " "..Modules.Translate.ItemName(RealItem)
			if Amount > 1 then
				Suffix = Suffix.."s"
			end
			local TColor = Color3.new(0.7,0.7,0.7)
			local Tier = game.ReplicatedStorage.Tiers:FindFirstChild(tostring(RealItem.Tier.Value))
			if Tier then
				TColor = Tier.TierColor.Value
			end
			addItem(tostring(Amount)..Suffix,"rbxassetid://"..RealItem.ThumbnailId.Value,TColor)
		end

		if Crystals and Crystals > 0 then
			local Suffix = Crystals == 1 and " Crystal" or " Crystals"
			addItem(tostring(Crystals)..Suffix,"rbxassetid://1028723620",Color3.fromRGB(255, 23, 147))
		end

		if Money and Money > 0 then
			addItem("Money: "..MoneyLib.HandleMoney(Money),"rbxassetid://190472313",Color3.fromRGB(11, 180, 79))
		end

		if ExtraRewards then
			for i,Reward in pairs(ExtraRewards) do
				addItem(Reward.Name,Reward.Image,Reward.Color)
			end
		end

		-- Streak info
		local col = Color3.fromRGB(198, 198, 198)
		if game.Players.LocalPlayer.LoginStreak.Value <= 2 then
			script.Parent.Progress.Visible = false
			script.Parent.Streak.Visible = true
			if game.Players.LocalPlayer.LoginStreak.Value <= 1 then
				script.Parent.Streak.Text = "Thanks for playing! Log in tomorrow for a better gift."
			else
				local streak = game.Players.LocalPlayer.LoginStreak.Value
				script.Parent.Streak.Text = "You've opened your gift "..streak.." days in a row. Each day upgrades your gift."

				if streak >= 100 then
					col = Color3.fromRGB(255, 0, 230)
				elseif streak >= 75 then
					col = Color3.fromRGB(0, 255, 106)
				elseif streak >= 50 then
					col = Color3.fromRGB(116, 244, 255)
				elseif streak >= 25 then
					col = Color3.fromRGB(174, 180, 255)
				elseif streak >= 10 then
					col = Color3.fromRGB(206, 255, 188)
				elseif streak >= 5 then
					col = Color3.fromRGB(255, 253, 193)
				end
			end
		else
			script.Parent.Progress.Visible = true
			script.Parent.Streak.Visible = false
			script.Parent.Progress.Amount.Text = game.Players.LocalPlayer.LoginStreak.Value
			local Round = 7 * math.floor(game.Players.LocalPlayer.LoginStreak.Value / 7)
			local Progress = 0
			if (game.Players.LocalPlayer.LoginStreak.Value - Round) % 7 == 0 then
				Progress = 1
				script.Parent.Progress.Bar.Amount.BackgroundColor3 = Color3.fromRGB(28, 252, 255)
			else
				Progress = (game.Players.LocalPlayer.LoginStreak.Value - Round) / 7
				script.Parent.Progress.Bar.Amount.BackgroundColor3 = Color3.fromRGB(217, 119, 255)
			end
			script.Parent.Progress.Bar.Amount.Size = UDim2.new(Progress,0,1,0)
		end

		script.Parent.Streak.TextColor3 = col


		Modules.Menu.sounds.OpenedGift:Play()
		script.Parent:TweenPosition(UDim2.new(0.5,0,0.5,0),nil,nil,0.5)
		wait(0.5)


		if script.Parent.Visible and Modules.Input.mode.Value == "Xbox" then
			game.GuiService.GuiNavigationEnabled = true
			game.GuiService.SelectedObject = script.Parent.Bottom.Done
		end

		spawn(function()
			while script.Parent.Visible do
				game:GetService("RunService").Heartbeat:wait()
				script.Parent.Rays.Rotation = script.Parent.Rays.Rotation + 0.5
			end
		end)
	end

	game.ReplicatedStorage.EntryPerks.OnClientEvent:connect(open)

end


return module
