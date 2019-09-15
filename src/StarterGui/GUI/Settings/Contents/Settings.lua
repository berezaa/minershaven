-- Settings
--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

local module = {}



function module.init(Modules)
	local Sounds = Modules["Menu"]["sounds"]
	local OreLimitBar = Modules["HUD"]["oreLimitBar"]
	local Debounce = true

	local Player = game.Players.LocalPlayer

	local MoneyLib = Modules["MoneyLib"]
	local TycoonLib = Modules["TycoonLib"]
	local Tycoon = Modules["Tycoon"].getTycoon()

	if Tycoon == nil then
		Tycoon = Player.PlayerTycoon.Value
	end

	local function lifeskiprefresh()
		local Cost = MoneyLib.RebornPrice(Player.Rebirths.Value)
		local Money = script.Parent.Parent.Parent.Money.Value
		local skips = MoneyLib.LifeSkips(Player.Rebirths.Value, Money)
		if skips >= 1 then
			local suffix = (skips == 1 and " life") or " lives"
			script.Parent.Rebirth.Desc.Text = "You will skip "..skips..suffix.." if you Rebirth"
			script.Parent.Rebirth.Desc.TextColor3 = Color3.fromRGB(255, 175, 47)
			script.Parent.Rebirth.Desc.TextStrokeTransparency = 0.8
			script.Parent.Rebirth.Desc.TextTransparency = 0
		else
			script.Parent.Rebirth.Desc.Text = "Destroy your base and advance into the next life, stronger."
			script.Parent.Rebirth.Desc.TextColor3 = Color3.new(0,0,0)
			script.Parent.Rebirth.Desc.TextStrokeTransparency = 1
			script.Parent.Rebirth.Desc.TextTransparency = 0.7
		end
		local Progress = math.log10(Money)/math.log10(Cost)
		if Progress > 1 then
			Progress = 1
		end
		script.Parent.Rebirth.Contents.Progress.Bar.Size = UDim2.new(Progress,0,1,0)
	end
	lifeskiprefresh()
	script.Parent.Parent.Parent.Money.Changed:connect(lifeskiprefresh)
	game.Players.LocalPlayer.Rebirths.Changed:connect(lifeskiprefresh)

	script.Parent.Extra.Contents.Badges.MouseButton1Click:connect(function()
		Modules.Menu.sounds.Click:Play()
		Modules.Focus.change(script.Parent.Parent.Parent.Badges)
	end)

	script.Parent.Extra.Contents.Layout.MouseButton1Click:connect(function()
		Modules.Menu.sounds.Click:Play()
		Modules.Focus.change(script.Parent.Parent.Parent.Layouts)
	end)

	script.Parent.Parent.Top.Close.MouseButton1Click:connect(function()
		Modules.Focus.close()
		Modules.Menu.sounds.Click:Play()
	end)

	local PlayerData = game.ReplicatedStorage.PlayerData:FindFirstChild(Tycoon.Name)

	script.Parent.Extra.Contents.Withdraw.MouseButton1Click:connect(function()
		if Debounce then
			Debounce = false
			Sounds.Click:Play()
			if Modules.InputPrompt.prompt("Are you sure you want to withdraw all items?") then
				local Success = game.ReplicatedStorage.DestroyAll:InvokeServer()
				if Success then
					Sounds.Withdraw:Play()
				else
					Sounds.Error:Play()
				end
			end
			Debounce = true
		end
	end)

	local Settings = game.Players.LocalPlayer:FindFirstChild("PlayerSettings")

	local function RefreshPlace()
		if Settings.SmoothPlace.Value then
			script.Parent.TogglePlace.Contents.Toggle.On.Visible = true
			script.Parent.TogglePlace.Contents.Toggle.Off.Visible = false
		else
			script.Parent.TogglePlace.Contents.Toggle.On.Visible = false
			script.Parent.TogglePlace.Contents.Toggle.Off.Visible = true
		end
	end
	Settings.SmoothPlace.Changed:connect(RefreshPlace)
	RefreshPlace()

	script.Parent.TogglePlace.Contents.Toggle.MouseButton1Click:connect(function()
		Sounds.Click:Play()
		local Success = game.ReplicatedStorage.ChangeSetting:InvokeServer("SmoothPlace",not Settings.SmoothPlace.Value)
		--local Success = game.ReplicatedStorage.ToggleMines:InvokeServer()
		if not Success then
			Sounds.Error:Play()
		end
	end)


	local function RefreshMines()
		if game.Players.LocalPlayer.MinesActivated.Value then
			script.Parent.ToggleMines.Contents.Toggle.On.Visible = true
			script.Parent.ToggleMines.Contents.Toggle.Off.Visible = false
			script.Parent.ToggleMines.Contents.Title.Text = "Mines: Enabled"
		else
			script.Parent.ToggleMines.Contents.Toggle.On.Visible = false
			script.Parent.ToggleMines.Contents.Toggle.Off.Visible = true
			script.Parent.ToggleMines.Contents.Title.Text = "Mines: Disabled"
		end
	end
	game.Players.LocalPlayer.MinesActivated.Changed:connect(RefreshMines)
	RefreshMines()

	script.Parent.ToggleMines.Contents.Toggle.MouseButton1Click:connect(function()
		Sounds.Click:Play()
		local Success = game.ReplicatedStorage.ToggleMines:InvokeServer()
		if not Success then
			Sounds.Error:Play()
		end
	end)


	local function PermCheck()
		script.Parent.Locked.Visible = not TycoonLib.hasPermission(Player, "Owner")
	end
	PermCheck()
	game.ReplicatedStorage.PermissionsChanged.OnClientEvent:connect(PermCheck)

	local function RefreshCount()
		local Premium = false
		local Limit = PlayerData.DropLimit.Value
		script.Parent.OreLimit.Contents.Premium.Visible = false
		if Player:FindFirstChild("Premium") then
			Premium = true
			script.Parent.OreLimit.Contents.Premium.Visible = true
		end


		script.Parent.OreLimit.Contents.Amount.Text = PlayerData.DropCount.Value.."/"..Limit
		OreLimitBar.Amount.Text = PlayerData.DropCount.Value.." Ore / "..Limit
		if PlayerData.DropCount.Value > 0 then
			OreLimitBar.Visible = true
			local Progress = PlayerData.DropCount.Value/Limit
			OreLimitBar.Progress.Size = UDim2.new(Progress,0,1,0)
			OreLimitBar.Progress.BackgroundColor3 = Color3.new(Progress,1-Progress,0)
		else
			OreLimitBar.Visible = false
		end
	end
	PlayerData.DropCount.Changed:connect(RefreshCount)
	RefreshCount()

	local function RefreshLevel()
		script.Parent.OreLimit.Contents.Level.Text = "Level "..PlayerData.DropLevel.Value
		local PriceText = "(MAX)"
		local PriceColor = Color3.new(0.7,0.7,0.7)
		if PlayerData.DropLevel.Value < #game.ReplicatedStorage.Upgrades:GetChildren() then
			PriceText = MoneyLib.HandleMoney(game.ReplicatedStorage.Upgrades:FindFirstChild(tostring(PlayerData.DropLevel.Value+1)).Value)
			PriceColor = Color3.new(115/255, 213/255, 132/255)
		end
		script.Parent.OreLimit.Contents.Cost.Text = PriceText
		script.Parent.OreLimit.Contents.Cost.TextColor3 = PriceColor
		script.Parent.OreLimit.Contents.Buy.BackgroundColor3 = PriceColor
	end
	PlayerData.DropLevel.Changed:connect(RefreshLevel)
	RefreshLevel()

	script.Parent.OreLimit.Contents.Buy.MouseButton1Click:connect(function()
		if Debounce then
			Debounce = false
			Sounds.Click:Play()
			local Success = game.ReplicatedStorage.Upgrade:InvokeServer()
			if Success then
				Sounds.Purchase:Play()
				wait(0.3)
			else
				Sounds.Error:Play()
				script.Parent.OreLimit.Contents.Buy.BackgroundColor3 = Color3.new(1,0.5,0.5)
				wait(0.5)
				RefreshLevel()
			end
			Debounce = true
		end
	end)

	script.Parent.Rebirth.Contents.Buy.MouseButton1Click:connect(function()
		Sounds.Click:Play()
		local Money = game.ReplicatedStorage.MoneyMirror:FindFirstChild(Player.Name)
		if Money.Value >= MoneyLib.RebornPrice(Player.Rebirths.Value) then
			script.Parent.Rebirth.Confirm.Visible = true
			script.Parent.Rebirth.Contents.Visible = false
		else
			Sounds.Error:Play()
			local OldColor = script.Parent.Rebirth.Contents.Buy.BackgroundColor3
			script.Parent.Rebirth.Contents.Buy.BackgroundColor3 = Color3.new(1,0.5,0.5)
			wait(0.3)
			script.Parent.Rebirth.Contents.Buy.BackgroundColor3 = OldColor
		end
	end)

	local function RefreshLife()
		script.Parent.Rebirth.Contents.Cost.Text = MoneyLib.HandleMoney(MoneyLib.RebornPrice(Player.Rebirths.Value))
		script.Parent.Rebirth.Contents.Life.Text = MoneyLib.HandleLife(Player.Rebirths.Value + 1).." Life"
		script.Parent.Sacrifice.Visible = false
		if Player.Rebirths.Value >= 1000 then
			if Player:FindFirstChild("Sacrificed") == nil then
				script.Parent.Sacrifice.Visible = true
				script.Parent.Sacrifice.BackgroundColor3 = Color3.new(112/255, 55/255, 159/255)
				script.Parent.Sacrifice.Desc.Text = "Give up everything. Start over at life s-1"
				script.Parent.Sacrifice.Contents.Title.Text = "The Ultimate Sacrifice"
				script.Parent.Sacrifice.Confirm.Desc.Text = "All of your items and Rebirths will be wiped. Unobtainable items (Exotics, etc.) will be returned at life s-100"
				script.Parent.Sacrifice.Confirm.Title.Text = "Are you REALLY sure?"
			elseif Player:FindFirstChild("SecondSacrifice") == nil then
				script.Parent.Sacrifice.Visible = true
				script.Parent.Sacrifice.BackgroundColor3 = Color3.new(159/255, 51/255, 53/255)
				script.Parent.Sacrifice.Desc.Text = "Start over at life S+1. No reward until S+10."
				script.Parent.Sacrifice.Contents.Title.Text = "The Second Sacrifice"
				script.Parent.Sacrifice.Confirm.Desc.Text = "This time will be much harder. No reward until S+10. Limited items returned at S+100"
				script.Parent.Sacrifice.Confirm.Title.Text = "You know the drill."
			end
		end
	end
	RefreshLife()
	Player.Rebirths.Changed:connect(RefreshLife)

	script.Parent.Rebirth.Confirm.Cancel.MouseButton1Click:connect(function()
		Sounds.Click:Play()
		script.Parent.Rebirth.Confirm.Visible = false
		script.Parent.Rebirth.Contents.Visible = true
	end)


	script.Parent.Rebirth.Confirm.Go.MouseButton1Click:connect(function()
		if Debounce then
			Sounds.Click:Play()
			Debounce = false
			local Success = game.ReplicatedStorage.Rebirth:InvokeServer()
			if Success then
				Sounds.Rebirth:Play()
				script.Parent.Rebirth.Contents.Visible = true
				script.Parent.Rebirth.Confirm.Visible = false
				-- TODO: Add reward
			else
				Sounds.Error:Play()
			end
			Debounce = true
		end
	end)

	script.Parent.Sacrifice.Contents.Go.MouseButton1Click:connect(function()
		Sounds.Click:Play()
		script.Parent.Sacrifice.Contents.Visible = false
		script.Parent.Sacrifice.Confirm.Visible = true
	end)

	script.Parent.Sacrifice.Confirm.Cancel.MouseButton1Click:connect(function()
		Sounds.Click:Play()
		script.Parent.Sacrifice.Contents.Visible = true
		script.Parent.Sacrifice.Confirm.Visible = false
	end)

	script.Parent.Sacrifice.Confirm.Go.MouseButton1Click:connect(function()
		Sounds.Click:Play()
		script.Parent.Sacrifice.Confirm.Visible = false
		script.Parent.Sacrifice.Confirm2.Visible = true
	end)

	script.Parent.Sacrifice.Confirm2.Cancel.MouseButton1Click:connect(function()
		Sounds.Click:Play()
		script.Parent.Sacrifice.Confirm2.Visible = false
		script.Parent.Sacrifice.Contents.Visible = true
	end)

	script.Parent.Sacrifice.Confirm2.Go.MouseButton1Click:connect(function()
		Sounds.Click:Play()
		local Success = game.ReplicatedStorage.Sacrifice:InvokeServer()
		if Success then
			Sounds.Sacrifice:Play()
			script.Parent.Sacrifice.Confirm2.Go.BackgroundColor3 = Color3.fromRGB(50,0,40)
			Modules.Menu.tween(workspace.CurrentCamera,{"FieldOfView"},120,4.3)
			wait(4.3)
			Modules.Menu.tween(workspace.CurrentCamera,{"FieldOfView"},5,0.4)
			wait(0.4)
			pcall(function()
				game.Players.LocalPlayer.Character:BreakJoints()
				Instance.new("Explosion",workspace).Position = game.Players.LocalPlayer.Character.Head.Position
			end)

		else
			script.Parent.Sacrifice.Confirm2.Go.BackgroundColor3 = Color3.fromRGB(200,100,100)
			Sounds.Error:Play()
		end
		wait(0.2)
		script.Parent.Sacrifice.Contents.Visible = true
		script.Parent.Sacrifice.Confirm2.Visible = false
		script.Parent.Sacrifice.Confirm2.Go.BackgroundColor3 = Color3.fromRGB(213,200,103)
	end)


	script.Parent.Social.Contents.Claim.MouseButton1Click:connect(function()
		if Debounce then
			Sounds.Click:Play()
			Debounce = false
			script.Parent.Social.Contents.TextBox.Active = false
			local Result = game.ReplicatedStorage.TryCode:InvokeServer(script.Parent.Social.Contents.TextBox.Text)
			if Result == true then
				Sounds.Ding:Play()
				script.Parent.Social.Contents.TextBox.Text = "Code Redeemed!"
				script.Parent.Social.Contents.TextBox.BackgroundColor3 = Color3.new(76/255, 127/255, 82/255)
			elseif Result == "NoPermission" then
				Sounds.Error:Play()
				script.Parent.Social.Contents.TextBox.Text = "Not Allowed!"
				script.Parent.Social.Contents.TextBox.BackgroundColor3 = Color3.new(127/255, 75/255, 76/255)
				wait(0.3)
			elseif Result == nil then
				Sounds.Error:Play()
				script.Parent.Social.Contents.TextBox.Text = "Already Redeemed!"
				script.Parent.Social.Contents.TextBox.BackgroundColor3 = Color3.new(127/255, 75/255, 76/255)
				wait(0.3)
			else
				Sounds.Error:Play()
				script.Parent.Social.Contents.TextBox.Text = "Invalid Code!"
				script.Parent.Social.Contents.TextBox.BackgroundColor3 = Color3.new(127/255, 75/255, 76/255)
			end

			script.Parent.Social.Contents.TextBox.Active = true

			wait(0.5)
			Debounce = true
			script.Parent.Social.Contents.TextBox.BackgroundColor3 = Color3.new(127/255,127/255,127/255)
		end
	end)

	local Rebirths = game.Players.LocalPlayer:WaitForChild("Rebirths")
	Rebirths.Changed:connect(function()
		script.Parent.Rebirth.LayoutOrder = math.random(1,6)
	end)

end

return module
