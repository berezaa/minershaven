-- Mystery Box Menu

--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

local module = {}



local function setup()
	script.Parent.Items.SampleItem.Visible = false
	for i,Box in pairs(game.ReplicatedStorage.Boxes:GetChildren()) do
		local Button = script.Parent.Items.SampleItem:Clone()
		Button.Thumbnail.Image = "rbxassetid://"..Box.ThumbnailId.Value
		Button.Name = Box.Name
		Button.Parent = script.Parent.Items
		local col = Box.BoxColor.Value
		Button.ImageColor3 = Color3.new(col.r/2,col.g/2,col.b/2)
		Button.Count.BackgroundColor3 = Color3.new(col.r/2,col.g/2,col.b/2)
--		Button.Count.TextColor3 = Color3.new(col.r+0.3,col.g+0.3,col.b+0.3)
	end
end

local function update()
	local Count = 0
	for i,Box in pairs(script.Parent.Items:GetChildren()) do
		if Box:IsA("GuiButton") then
			local Val = game.Players.LocalPlayer.Crates:FindFirstChild(Box.Name)
			if Val and Val.Value > 0 then
				Box.Count.Text = "x"..Val.Value
				Box.Visible = true
				Count = Count + 1
			else
				Box.Visible = false
			end
		end
	end
	script.Parent.Items.Count.Value = Count
end


local DB = true

function module.init(Modules)

	local Tween = Modules.Menu.tween

	script.Parent.TopForReal.Close.MouseButton1Click:connect(function()
		Modules.Menu.sounds.Click:Play()
		Modules.Focus.close()
	end)

	local function twitchcheck()
		script.Parent.Top.TwitchCoin.Active = (game.Players.LocalPlayer.TwitchPoints.Value > 0 and game.Players.LocalPlayer.UseTwitch.Value)
		if script.Parent.Top.TwitchCoin.Active then
			script.Parent.Top.TwitchCoin.BackgroundColor3 = Color3.fromRGB(207, 165, 255)
		else
			script.Parent.Top.TwitchCoin.BackgroundColor3 = Color3.fromRGB(110,110,110)
		end
		script.Parent.Top.TwitchCoin.Count.Text = game.Players.LocalPlayer.TwitchPoints.Value
	end
	game.Players.LocalPlayer.UseTwitch.Changed:connect(twitchcheck)
	game.Players.LocalPlayer.TwitchPoints.Changed:connect(twitchcheck)
	twitchcheck()

	script.Parent.Top.TwitchCoin.MouseButton1Click:connect(function()
		if DB then
			DB = false
			Modules.Menu.sounds.Click:Play()
			game.ReplicatedStorage.ToggleBoxItem:InvokeServer("Twitch")
			wait(0.3)
			DB = true
		end
	end)

	local function clovercheck()
		script.Parent.Top.Clover.Active = (game.Players.LocalPlayer.Clovers.Value > 0 and game.Players.LocalPlayer.UseClover.Value)
		if script.Parent.Top.Clover.Active then
			script.Parent.Top.Clover.BackgroundColor3 = Color3.fromRGB(93, 255, 134)
		else
			script.Parent.Top.Clover.BackgroundColor3 = Color3.fromRGB(99, 99, 99)
		end
		script.Parent.Top.Clover.Count.Text = game.Players.LocalPlayer.Clovers.Value
	end
	game.Players.LocalPlayer.UseClover.Changed:connect(clovercheck)
	game.Players.LocalPlayer.Clovers.Changed:connect(clovercheck)
	clovercheck()


	script.Parent.Top.Clover.MouseButton1Click:connect(function()
		if DB then
			DB = false
			Modules.Menu.sounds.Click:Play()
			game.ReplicatedStorage.ToggleBoxItem:InvokeServer("Clover")
			wait(0.3)
			DB = true
		end
	end)

	local Last = script.Parent.Open.Contents.Roll.AbsolutePosition.X
	script.Parent.Open.Contents.Roll:GetPropertyChangedSignal("AbsolutePosition"):connect(function()
		if script.Parent.Open.Visible then
			local Current = script.Parent.Open.Contents.Roll.AbsolutePosition.X
			if math.abs(Last - Current) > 15 then
				Modules.Menu.sounds.TickSoft:Play()
				Last = Current
			end

		end
	end)

	function module.close()
		Modules.ItemInfo.hide()

		Modules.Focus.close()

		if Modules.Input.mode.Value == "Xbox" then
			game.GuiService.SelectedObject = nil
			game.GuiService.GuiNavigationEnabled = false

		end
		if game.Players.LocalPlayer.ActiveTycoon.Value ~= nil then
			Modules.HUD.showHUD()

		end

	end

	script.Parent.Close.MouseButton1Click:connect(module.close)




	local Player = game.Players.LocalPlayer

	local Sounds = Modules.Menu.sounds
	local LotteryLib = Modules.LotteryLib

	setup()
	update()

	game.Players.LocalPlayer.Crates.Changed:connect(update)
	--[[
	for i,Button in pairs(script.Parent.Top:GetChildren()) do

		if Button:FindFirstChild("Price") then
			Button.MouseButton1Click:connect(function()
				local Success = game.ReplicatedStorage.BuyBox:InvokeServer(Button.Name)
				if Success then
					Sounds.Purchase:Play()
				else
					Sounds.Error:Play()
					Modules.Premium.show()
					--Modules.Menu.openMenu("Premium") -- thursday fun time
				end
			end)
		end
	end
	]]

	-- TODO: change to live product

	game.MarketplaceService.PromptGamePassPurchaseFinished:connect(function(Player, Id, Purchased)
		if Player == game.Players.LocalPlayer and Id == 144581326 and Purchased then
			Sounds.Purchase:Play()
			script.Parent.Buy.UnrealBundle.Bought.Visible = true
			wait(0.4)
			script.Parent.Buy.UnrealBundle.Bought.Visible = false
		end
	end)

	script.Parent.Buy.UnrealBundle.MouseButton1Click:connect(function()
		Sounds.Click:Play()
		game.MarketplaceService:PromptProductPurchase(Player,144581326)
	end)

	script.Parent.Buy.Regular.MouseButton1Click:connect(function()
		Sounds.Click:Play()
		local Success = game.ReplicatedStorage.BuyBox:InvokeServer("Regular")
		if Success then
			Sounds.Purchase:Play()
			script.Parent.Buy.Regular.Bought.Visible = true
			wait(0.2)
			script.Parent.Buy.Regular.Bought.Visible = false
		else
			Sounds.Error:Play()
			Modules.Premium.show()
		end
	end)

	script.Parent.Buy.Unreal.MouseButton1Click:connect(function()
		Sounds.Click:Play()
		local Success = game.ReplicatedStorage.BuyBox:InvokeServer("Unreal")
		if Success then
			Sounds.Purchase:Play()
			script.Parent.Buy.Unreal.Bought.Visible = true
			wait(0.2)
			script.Parent.Buy.Unreal.Bought.Visible = false
		else
			Sounds.Error:Play()
			Modules.Premium.show()
		end
	end)

	script.Parent.Top.Buy.MouseButton1Click:connect(function()
		Sounds.Click:Play()
		script.Parent.Top.Visible = false
		script.Parent.Buy.Visible = true
		if Modules.Input.mode.Value == "Xbox" then
			game.GuiService.SelectedObject = script.Parent.Buy.Regular
		end
	end)

	script.Parent.Buy.Close.MouseButton1Click:connect(function()
		Sounds.Click:Play()
		script.Parent.Top.Visible = true
		script.Parent.Buy.Visible = false
		if Modules.Input.mode.Value == "Xbox" then
			game.GuiService.SelectedObject = script.Parent.Top.Buy
		end
	end)

	local Rolling = false
	local function RollBox(Type)


		if Player:FindFirstChild("OpeningBox") then
			return false
		end

		if not Rolling and Player.Crates:FindFirstChild(Type) and Player.Crates[Type].Value > 0 then

			Modules.ItemInfo.hide()
			DB = false
			Rolling = true
			Sounds.UnlockGift:Play()

			script.Parent.Open.Loading.Visible = true

			local Real = game.ReplicatedStorage.Boxes:FindFirstChild(Type)
			script.Parent.Open.BackgroundColor3 = Real.BoxColor.Value

			script.Parent.Big.Image = "rbxassetid://"..Real.ThumbnailId.Value
			script.Parent.Big.ImageTransparency = 0
			Modules.Menu.tween(script.Parent.Big,{"ImageTransparency"},1)

			local Prefix = ""
			if Player.UseClover.Value and Player.Clovers.Value > 0 then
				Prefix = Prefix.."Lucky "
			end

			if Modules.Input.mode.Value == "Xbox" then
				game.GuiService.GuiNavigationEnabled = false
			end

			script.Parent.Open.Wings.Visible = false
			script.Parent.Open.Title.TextColor3 = Color3.new(1,1,1)
			script.Parent.Open.Title.TextStrokeColor3 = Color3.new(0,0,0)

			script.Parent.Open.Top.Image = "rbxassetid://"..Real.ThumbnailId.Value
			script.Parent.Open.Bottom.Image = "rbxassetid://"..Real.ThumbnailId.Value

			script.Parent.Open.Visible = true
			script.Parent.Cover.Visible = true

			script.Parent.Open.Title.Text = "..."


			script.Parent.Open.Contents.Roll:ClearAllChildren()

			local Target = math.random(15,23)



			local Prize,Mag = game.ReplicatedStorage.MysteryBox:InvokeServer(Type)
			if Mag or Type == "Magnificent" then
				Type = "Magnificent"
				script.Parent.Open.Wings.Visible = true
				script.Parent.Open.Title.TextColor3 = Color3.fromRGB(0,0,0)
				script.Parent.Open.Title.TextStrokeColor3 = Color3.fromRGB(170,235,255)
				Real = game.ReplicatedStorage.Boxes:FindFirstChild(Type)
				script.Parent.Open.Top.Image = "rbxassetid://"..Real.ThumbnailId.Value
				script.Parent.Open.Bottom.Image = "rbxassetid://"..Real.ThumbnailId.Value
				script.Parent.Open.BackgroundColor3 = Real.BoxColor.Value
				Sounds.Harp:Play()
			end





			script.Parent.Open.Contents.Roll.Position = UDim2.new(0,1500,0,0)


			script.Parent.Open.Title.Text = Prefix..Type.." Box"

			local RewardButton
			local RewardRarity

			if Prize == nil then
				Sounds.Error:Play()
				script.Parent.Open.Visible = false
				script.Parent.Cover.Visible = false
				return false
			end

			for i=1,30 do

				local Button = script.Parent.Open.Contents.SampleItem:Clone()
				local Item
				if i~=Target then
					Item = LotteryLib.Run(game.Players.LocalPlayer,Type,true)
				else
					Item = Prize
					RewardRarity = Item[5]
					RewardButton = Button
				end
				local RealItem = Item[1]
				Button.Parent = script.Parent.Open.Contents.Roll
				Button.Position = UDim2.new(0,(i-1)*100,0,0)
				Button.Icon.Image = "rbxassetid://"..RealItem.ThumbnailId.Value

				if RealItem:FindFirstChild("Halloween") then
					Button.Event.Visible = true
				else
					Button.Event.Visible = false
				end

				Button.Snowflake.Visible = (RealItem:FindFirstChild("Holiday") ~= nil)

				local Rarity = Item[5]
				local BGColor = Color3.new(0.9,0.9,0.9)
				if Rarity <= 2 then
					Button.Rays.Visible = true
					BGColor = Color3.new(1,0.3,0.7)
					if Rarity == 1 then
						Button.Diamond.Visible = true
						Button.Rays.ImageTransparency = 0.3
						Button.Icon.ImageTransparency = 0.3
						Button.Diamond.ImageTransparency = 0.8
						if RealItem.Tier.Value == 66 then
							Button.Diamond.ImageTransparency = 0.3
							Button.Rays.Visible = false
							BGColor = Color3.new(1,1,1)
						elseif RealItem.Tier.Value == 41 then
							BGColor = Color3.new(0,0.8,0.7)
							Button.Rays.ImageTransparency = 0.1
							Button.Diamond.ImageTransparency = 0.6
							Button.Icon.ImageTransparency = 0
							Button.Exotic.Visible = true
						elseif RealItem.Tier.Value == 40 then
							BGColor = Color3.new(0,0.5,1)
							Button.Icon.ImageTransparency = 0.1
						end
					end
				elseif Rarity <= 4 then
					BGColor = Color3.new(1,0.5,0.5)
				elseif Rarity <= 6 then
					BGColor = Color3.new(1,1,0.5)
				elseif Rarity <= 8 then
					BGColor = Color3.new(0.5,1,0.5)
				end

				if RealItem.Tier.Value == 77 then
					Button.Contraband.Visible = true
					BGColor = Color3.fromRGB(117, 76, 157)
				end


				Button.BackgroundColor3 = BGColor



				Button.Visible = true
			end

			script.Parent.Open.Loading.Visible = false

			local Offset = script.Parent.Open.Middle.AbsolutePosition.X - script.Parent.Open.Contents.AbsolutePosition.X

			script.Parent.Open.Contents.Roll:TweenPosition(UDim2.new(0,1500 - (100 * (Target - 1)) + Offset,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quint,5,true)
			wait(5)

			if RewardRarity >= 5 then
				Sounds.Unboxxed:Play()
			elseif RewardRarity >=2 then
				Sounds.UnboxxedRare:Play()
			else
				Sounds.UnboxxedExotic:Play()
			end

			if RewardButton then
				local Copy = RewardButton.Icon:Clone()
				local asize = RewardButton.Icon.AbsoluteSize
				local apos = RewardButton.Icon.AbsolutePosition
				Copy.Size = UDim2.new(0,asize.X,0,asize.Y)
				Copy.AnchorPoint = Vector2.new(0.5,0.5)
				Copy.Position = UDim2.new(0,apos.X + asize.X/2,0,apos.Y + asize.Y/2)
				Copy.Name = "RewardRepre"
				Copy.Parent = script.Parent.Parent
				Copy.ImageTransparency = 0
				Copy.BackgroundTransparency = 1

				Copy.ZIndex = 10

				Modules.Menu.tween(Copy,{"ImageTransparency","Size"},{1,UDim2.new(0, asize.X * 4, 0, asize.Y * 4)},0.3)




				game.Debris:AddItem(Copy, 0.4)


				RewardButton.Icon.ImageTransparency = 0
				script.Parent.Open.Top.Image = RewardButton.Icon.Image
				script.Parent.Open.Bottom.Image = RewardButton.Icon.Image
				RewardButton.BorderSizePixel = 4
				RewardButton.ZIndex = RewardButton.ZIndex + 3
				local Col = RewardButton.BackgroundColor3
				RewardButton.BackgroundColor3 = Color3.new(Col.r * 1.1, Col.g * 1.1, Col.b * 1.1)
				for i,Child in pairs(RewardButton:GetDescendants()) do
					if Child:IsA("GuiObject") then
						Child.ZIndex = Child.ZIndex + 3
					end
				end
			end
			wait(1.5)
			script.Parent.Open.Visible = false
			script.Parent.Cover.Visible = false
			if Modules.Input.mode.Value == "Xbox" and game.GuiService.SelectedObject ~= nil then
				game.GuiService.GuiNavigationEnabled = true
			end
			Rolling = false
			DB = true

		end
	end

	for i,Button in pairs(script.Parent.Items:GetChildren()) do
		if Button:IsA("GuiButton") then

			local function focus()
				if Modules.Input.mode.Value ~= "Mobile" and not script.Parent.Open.Visible then
					Modules.ItemInfo.show(Button)
				end
			end

			local function unfocus()
				if Modules.Input.mode.Value ~= "Mobile" then
					Modules.ItemInfo.hide(Button)
				end
			end

			Button.MouseEnter:connect(focus)
			Button.MouseLeave:connect(unfocus)
			Button.SelectionGained:connect(focus)
			Button.SelectionLost:connect(unfocus)

			Button.MouseButton1Click:connect(function()
				local Type = Button.Name
				if Player.Crates:FindFirstChild(Type) and Player.Crates[Type].Value > 0 then
					RollBox(Type)
				end
			end)
		end
	end

	local hue = 175
	local sat = 200
	local rad = 0
	local Run = game:GetService("RunService")


	Run.Heartbeat:connect(function()
		rad = rad + 0.025
		if rad > 2 * math.pi then
			rad = 0
		end
		local Color = Color3.fromHSV((hue + math.cos(rad) * 20)/255, (sat + math.sin(rad) * 20)/255,1)
		script.Parent.Top.Buy.BackgroundColor3 = Color
		script.Parent.Buy.BackgroundColor3 = Color
	end)


end


return module
