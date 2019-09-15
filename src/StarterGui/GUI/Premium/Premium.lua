local module = {}

function module.show()
	warn("Premium.show() not yet ready.")
end

function module.init(Modules)

	function module.show()
		script.Parent.Visible = true
		Modules.Focus.change(script.Parent)
		script.Parent.Contents.CanvasPosition = Vector2.new(0,0)
		Modules.Menu.sounds.SwooshFast:Play()
		if Modules.Input.mode.Value == "Xbox" then
			game.GuiService.GuiNavigationEnabled = true
			game.GuiService.SelectedObject = script.Parent.Contents.Top.Crystals["1"]
		end
	end

	script.Parent.Top.Close.MouseButton1Click:connect(function()
		Modules.Menu.sounds.Click:Play()
		Modules.Focus.close()
	end)

	local Sounds = Modules.Menu.sounds
	local Settings = game.Players.LocalPlayer:FindFirstChild("PlayerSettings")

	local function RefreshAd()
		if Settings then
			script.Parent.Contents.DiscordAd.Visible = Settings.DiscordAd.Value
		end
	end
	RefreshAd()
	if Settings then
		Settings.DiscordAd.Changed:connect(RefreshAd)
	end
	script.Parent.Contents.DiscordAd.Close.MouseButton1Click:connect(function()
		Sounds.Click:Play()
		game.ReplicatedStorage.ChangeSetting:InvokeServer("DiscordAd",false)
	end)


	local Tycoon = game.Players.LocalPlayer.PlayerTycoon.Value
	local function refreshmusic()
		local Text = ""
		if Tycoon:FindFirstChild("SpecialMusic") then
			if Tycoon.SpecialMusic.Value ~= 0 then
				local success = pcall(function()
					Text = game.MarketplaceService:GetProductInfo(Tycoon.SpecialMusic.Value).Name
				end)
				if not success then
					Text = "Error finding song"
				end
			else
				Text = "Nothing is playing..."
			end
		else
			Text = "Something went wrong..."
		end
		script.Parent.Contents.Goodies.BaseRadio.Owned.SongName.Text = Text
	end

	refreshmusic()
	Tycoon.SpecialMusic.Changed:connect(refreshmusic)

	local DB = true
	script.Parent.Contents.Goodies.BaseRadio.Owned.Set.MouseButton1Click:connect(function()
		if DB then
			DB = false
			Sounds.Click:Play()
			local Id = tonumber(script.Parent.Contents.Goodies.BaseRadio.Owned.TextBox.Text)
			if Id then
				local Success = game.ReplicatedStorage.ChangeRadio:InvokeServer(Id)
				if not Success then
					Sounds.Error:Play()
					script.Parent.Contents.Goodies.BaseRadio.Owned.Set.TextColor3 = Color3.new(1,0,0)
					wait(0.2)
					script.Parent.Contents.Goodies.BaseRadio.Owned.Set.TextColor3 = Color3.fromRGB(163, 135, 255)
				end
			else
				Sounds.Error:Play()
				script.Parent.Contents.Goodies.BaseRadio.Owned.Set.TextColor3 = Color3.new(1,0,0)
				wait(0.2)
				script.Parent.Contents.Goodies.BaseRadio.Owned.Set.TextColor3 = Color3.fromRGB(163, 135, 255)
			end
			DB = true
		end
	end)

	for i,Preset in pairs(script.Parent.Contents.Goodies.BaseRadio.Owned.Presets:GetChildren()) do
		if Preset:FindFirstChild("Id") then
			Preset.MouseButton1Click:connect(function()
				Sounds.Click:Play()
				script.Parent.Contents.Goodies.BaseRadio.Owned.TextBox.Text = tonumber(Preset.Id.Value)
			end)
		end
	end

	local function doPass(Pass)
		if Pass:IsA("GuiButton") and Pass:FindFirstChild("Owned") then
			Pass.Owned.Visible = game.Players.LocalPlayer:FindFirstChild(Pass.Name)
			Pass.Active = not Pass.Owned.Visible
		end
	end

	local function scan()
		for i,Pass in pairs(script.Parent.Contents.Top.Gamepasses:GetChildren()) do
			doPass(Pass)
		end
		for i,Pass in pairs(script.Parent.Contents.Goodies:GetChildren()) do
			doPass(Pass)
		end
	end
	scan()
	game.Players.LocalPlayer.ChildAdded:connect(scan)

	local function partTwo(Pass)
		if Pass:IsA("GuiButton") then
			Pass.MouseButton1Click:connect(function()
				Sounds.Click:Play()
				--PromptGamePassPurchase
				game.MarketplaceService:PromptPurchase(game.Players.LocalPlayer,Pass.PassId.Value)
			end)
		end
	end

	for i,Pass in pairs(script.Parent.Contents.Top.Gamepasses:GetChildren()) do
		partTwo(Pass)
	end
	for i,Pass in pairs(script.Parent.Contents.Goodies:GetChildren()) do
		partTwo(Pass)
	end

	for i,Product in pairs(script.Parent.Contents.Top.Crystals:GetChildren()) do
		if Product:IsA("GuiButton") then
			Product.MouseButton1Click:connect(function()
				Sounds.Click:Play()
				game.MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer,Product.ProductId.Value)
			end)
		end
	end

	local function megacheck()
		if game.Players.LocalPlayer.Megaphones.Value > 0 then
			script.Parent.Contents.Megaphone.Use.TextColor3 = Color3.fromRGB(65,198,255)
			script.Parent.Contents.Megaphone.Use.BorderColor3 = Color3.fromRGB(60,148,255)
		else
			script.Parent.Contents.Megaphone.Use.TextColor3 = Color3.fromRGB(125,125,125)
			script.Parent.Contents.Megaphone.Use.BorderColor3 = Color3.fromRGB(110,110,110)
		end
		script.Parent.Contents.Megaphone.Amount.Text = "x"..game.Players.LocalPlayer.Megaphones.Value
	end
	megacheck()
	game.Players.LocalPlayer.Megaphones.Changed:connect(megacheck)

	script.Parent.Contents.Megaphone.Use.MouseButton1Click:connect(function()
		if game.Players.LocalPlayer.Megaphones.Value > 0 then
			Sounds.Click:Play()
			script.Parent.Contents.Megaphone.Send.Visible = true
		else
			Sounds.Error:Play()
			script.Parent.Contents.Megaphone.Use.TextColor3 = Color3.fromRGB(255,125,125)
			script.Parent.Contents.Megaphone.Use.BorderColor3 = Color3.fromRGB(255,110,110)
			wait(0.2)
			megacheck()
		end
	end)

	script.Parent.Contents.Megaphone.Send.Cancel.MouseButton1Click:connect(function()
		Sounds.Click:Play()
		script.Parent.Contents.Megaphone.Send.Visible = false
	end)

	script.Parent.Contents.Megaphone.Buy.MouseButton1Click:connect(function()
		Sounds.Click:Play()
		local Success = game.ReplicatedStorage.BuyBox:InvokeServer("Megaphone")
		if Success then
			script.Parent.Contents.Megaphone.Buy.Bought.Visible = true
			Sounds.Purchase:Play()
			wait(0.3)
			script.Parent.Contents.Megaphone.Buy.Bought.Visible = false
		else
			Sounds.Error:Play()
			script.Parent.Contents.CanvasPosition = Vector2.new(0,0)
		end
		--game.MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer,100466450)
	end)

	script.Parent.Contents.Megaphone.Send.Send.MouseButton1Click:connect(function() -- naming is on point
		if DB then
			DB = false
			Sounds.Click:Play()
			local Text = script.Parent.Contents.Megaphone.Send.TextBox.Text
			if Text ~= "" and Text ~= " " and Text ~= "Enter a message..." then

				local Col
				local BGCol

				if script.Parent.Contents.Goodies.ShoutColor.Owned.Color.BackgroundColor3 ~= Color3.fromRGB(255,255,255) then
					Col = script.Parent.Contents.Goodies.ShoutColor.Owned.Color.BackgroundColor3
				end
				if script.Parent.Contents.Goodies.ShoutColor.Owned.StrokeColor.BackgroundColor3 ~= Color3.fromRGB(0,0,0) then
					BGCol = script.Parent.Contents.Goodies.ShoutColor.Owned.StrokeColor.BackgroundColor3
				end


				local Success = game.ReplicatedStorage.Shout:InvokeServer(Text,Col,BGCol)

				local Status = script.Parent.Contents.Megaphone.Send.Status
				Status.Visible = true
				if Success then
					Status.TextColor3 = Color3.fromRGB(100,255,100)
					Status.Text = "Message Sent!"
					Sounds.ShoutSend:Play()
					wait(0.5)
					script.Parent.Contents.Megaphone.Send.Visible = false
					script.Parent.Contents.Megaphone.Send.TextBox.Text = "Enter a message..."
				elseif game.Players.LocalPlayer.Megaphones.Value <= 0 then
					Status.TextColor3 = Color3.fromRGB(255,100,100)
					Status.Text = "You don't have any megaphones"
					Sounds.Error:Play()
					wait(1)
				else
					Status.TextColor3 = Color3.fromRGB(255,100,100)
					Status.Text = "Message not allowed by Roblox"
					Sounds.Error:Play()
					wait(1)
				end
				Status.Visible = false
			end
			DB = true
		end
	end)

	local Player = game.Players.LocalPlayer
	local function warningscan()
		if Player.ActiveTycoon.Value and Player.ActiveTycoon.Value ~= Player.PlayerTycoon.Value then
			script.Parent.Contents.Warning.Visible = true
		else
			script.Parent.Contents.Warning.Visible = false
		end
	end
	warningscan()
	game.Players.LocalPlayer.ActiveTycoon.Changed:connect(warningscan)


end


return module
