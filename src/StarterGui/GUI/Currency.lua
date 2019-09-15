local module = {}


function module.init(Modules)

	local Tween = Modules["Menu"]["tween"]


	local function display(Target,String,Color,Time,Audio,Texture)



		local Gui = Target:FindFirstChild("CurrencyGui")

		if Gui == nil then
			Gui = script.Parent.CurrencyGui:Clone()
			Gui.Parent = Target
			Gui.Adornee = Target
			Gui.Enabled = true
		end

		if Audio then


			local Sound = Instance.new("Sound")
			Sound.Volume = 0.05
			Sound.MaxDistance = 75
			Sound.SoundId = "rbxassetid://"..Audio
			Sound.Name = tostring(Audio)

			Sound.Parent = Target
			Sound:Play()
			game.Debris:AddItem(Sound,2)

		end


		local Msg = Gui.Sample:Clone()
		local X,Y = (math.random(15,85)/100), (math.random(50,100)/100)

		Msg.Icon.Visible = false
		if Texture ~= nil then
			Msg.TextXAlignment = Enum.TextXAlignment.Left
			Msg.Icon.Visible = true
			Msg.Icon.Image = Texture
			--print("Applying "..Texture)
			Msg.Icon.ImageTransparency = 1
			Tween(Msg.Icon,{"ImageTransparency"},0,Time/2,Enum.EasingStyle.Linear)
		end

		Msg.Position = UDim2.new(X,0,Y,0)

		Msg.TextTransparency = 1
		Msg.TextStrokeTransparency = 1

		Msg.Text = String
		Msg.TextColor3 = Color

		Msg.Parent = Gui

		Msg.Visible = true

		game.Debris:AddItem(Msg,Time)

		Tween(Msg,{"TextTransparency","TextStrokeTransparency","Position"},{0,0,UDim2.new(X,0,Y-0.25,0)},Time/2,Enum.EasingStyle.Linear)

		wait(Time/2)

		if Msg.Icon.Visible then
			Tween(Msg.Icon,{"ImageTransparency"},{1},Time/2,Enum.EasingStyle.Linear)
		end

		Tween(Msg,{"TextTransparency","TextStrokeTransparency","Position"},{1,1,UDim2.new(X,0,Y-0.5,0)},Time/2,Enum.EasingStyle.Linear)
	end


	game.ReplicatedStorage.CurrencyItem.OnClientEvent:connect(function(Target, Item, Time)

		local String = Modules.Translate.ItemName(Item)

		local Tier = game.ReplicatedStorage.Tiers:FindFirstChild(tostring(Item.Tier.Value))
		local Color = Color3.new(1,1,1)
		if Tier then
			Color = Tier.TierColor.Value
		end

		local Texture = "rbxassetid://"..Item.ThumbnailId.Value

		display(Target,String,Color,Time,nil,Texture)
	end)

	--game.ReplicatedStorage.CurrencyItem:FireClient(Player,script.Parent,Item,3)

	game.ReplicatedStorage.Currency.OnClientEvent:connect(display)
end

return module
