--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

local module = {}



function module.init(Modules)
	local Sounds = Modules["Menu"]["sounds"]

	local HUD = Modules["HUD"]

	local Tween = Modules["Menu"]["tween"]

	game.ReplicatedStorage.CurrencyPopup.OnClientEvent:connect(function(Text, Color, Thumbnail)
		local Template = script.Parent.Currency:Clone()
		Sounds.Obtained:Play()
		Template.Parent = script.Parent
		Template.Visible = true
		Template.Title.Text = Text
		Template.ImageTransparency = 1
		Template.Icon.ImageTransparency = 1
		Template.Icon.Inner.ImageTransparency = 1
		Template.Icon.Image = Thumbnail
		Template.ImageColor3 = Color
		Template.Icon.Inner.ImageColor3 = Color
		Template.Size = UDim2.new(0,50,0,50)
		Tween(Template,{"ImageTransparency"},{0.1},0.3)
		Tween(Template.Icon,{"ImageTransparency"},{0},0.3)
		Tween(Template.Icon.Inner,{"ImageTransparency"},{0},0.3)
		wait(0.6)
		Sounds.SwooshFast:Play()
		Tween(Template,{"Size"},UDim2.new(1,0,0,50),0.5)
		wait(2.5)
		Tween(Template,{"Size"},UDim2.new(0,0,0,50),0.5)
		wait(0.5)
		Template:Destroy()
	end)


	game.ReplicatedStorage.ItemObtained.OnClientEvent:connect(function(Item, Amount)
		Amount = Amount or 1
		local Template = script.Parent.NewItem:Clone()
		Sounds.Obtained:Play()
		Template.ImageTransparency = 1
		Template.Icon.Inner.ImageTransparency = 1
		Template.Icon.ImageTransparency = 1



		Template.Title.Text = Item.Name
		Template.Parent = script.Parent
		Template.Visible = true
		Template.Icon.Image = "rbxassetid://"..Item.ThumbnailId.Value
		local Tier = game.ReplicatedStorage.Tiers:FindFirstChild(tostring(Item.Tier.Value))
		if Tier then
			local col = Tier.TierColor.Value
			Template.ImageColor3 = Color3.new((col.r*0.7) + 0.2, (col.g*0.7) + 0.2, (col.b*0.7) + 0.2)
			Template.Icon.Inner.ImageColor3 = Template.ImageColor3
			if Item.Tier.Value == 40 or Item.Tier.Value == 41 then
				Template.Tier.TextColor3 = Tier.TierBackground.Value
			else
				Template.Tier.TextColor3 = Color3.new(col.r*0.3,col.g*0.3,col.b*0.3)
			end

			Template.Tier.Text = Tier.TierName.Value
		end

		if Amount > 1 then
			Template.Icon.Amount.TextTransparency = 1
			Template.Icon.Amount.TextStrokeTransparency = 1
			Template.Icon.Amount.Text = "x"..Amount
			Template.Icon.Amount.Visible = true
			Tween(Template.Icon.Amount,{"TextTransparency","TextStrokeTransparency"},0,0.3)
		else
			Template.Icon.Amount.Visible = false
		end

		Template.Size = UDim2.new(0,100,0,100)
		Tween(Template,{"ImageTransparency"},{0.1},0.3)
		Tween(Template.Icon,{"ImageTransparency"},{0},0.3)
		Tween(Template.Icon.Inner,{"ImageTransparency"},{0},0.3)
		wait(0.6)
		Sounds.SwooshFast:Play()
		Tween(Template,{"Size"},UDim2.new(1,0,0,100),0.5)
		wait(4)
		Tween(Template,{"Size"},UDim2.new(0,0,0,100),0.5)
		wait(0.5)
		Template:Destroy()
	end)

	game.ReplicatedStorage.Hint.OnClientEvent:connect(function(Message,Color,BGColor,Sound,TimeMulti)

		TimeMulti = TimeMulti or 1

		Sound = Sound or "Message"

		Color = Color or Color3.new(1,1,1)
		BGColor = BGColor or Color3.new(0,0,0)

		local RealSound = Sounds[Sound]
		if RealSound then
			RealSound:Play()
		end

		local Template = script.Parent.Template:Clone()
		Template.Parent = script.Parent
		Template.Text = Message

		Template.TextColor3 = Color
		Template.BG.ImageColor3 = BGColor


		local Bounds = Template.TextBounds
		Template.Size = UDim2.new(0,Bounds.X,0,Bounds.Y)
		Template.Visible = true

		Template.TextTransparency = 1
		Template.TextStrokeTransparency = 1
		Template.BG.ImageTransparency = 1

		local bg = Template.BG.ImageColor3
		Template.TextStrokeColor3 = Color3.new(bg.r/2,bg.b/2,bg.g/2)

		Template.Fancy.ImageColor3 = bg
		Template.Fancy.ImageTransparency = 1
		Template.Fancy.Visible = true

		Template.Fancy.BorderColor3 = bg
		Template.BorderColor3 = bg

		Template.Fancy.Size = UDim2.new(3,0,3,0)


		HUD.tween(Template.Fancy,{"Size","ImageTransparency"},{UDim2.new(1,14,1,0),0.5},0.3)
		HUD.tween(Template,{"TextTransparency","TextStrokeTransparency"},{0,0},0.5)

		wait((3 + string.len(Message)/25) * TimeMulti)

		Template.BG.ImageTransparency = 0.5
		Template.Fancy.Visible = false


		HUD.tween(Template,{"TextTransparency","TextStrokeTransparency"},1,0.5)
		HUD.tween(Template.BG, {"ImageTransparency"},1,0.5)

		wait(0.5)

		Template:Destroy()
	end)

	script.Parent.Progress.Visible = false
	local Player = game.Players.LocalPlayer

	local function update()
		script.Parent.Progress.Visible = true
		local val = Player.InnoEventProgress.Value
		script.Parent.Progress.Text = "Generator Charge: "..val.." / 1000"

		wait(10)
		if Player.InnoEventProgress.Value == val then
			script.Parent.Progress.Visible = false
		end
	end

	Player.InnoEventProgress.Changed:connect(update)
end

return module
