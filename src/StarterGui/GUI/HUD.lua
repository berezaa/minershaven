local module = {}

local Busy = false

module.menuOpen = false


function module.hideHUD(override)
	override = override or false

	script.Parent.HUDLeft:TweenPosition(UDim2.new(0,-200,0,0),nil,nil,nil,true)
	script.Parent.HUDBottom:TweenPosition(UDim2.new(0,0,1,10),nil,nil,nil,true)
	--script.Parent.HUDTop:TweenPosition(UDim2.new(0,0,0,-100),nil,nil,nil,true)
	if not override then
		script.Parent.HUDRight:TweenPosition(UDim2.new(1,50,0,0),nil,nil,nil,true)
	end
	--game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All,false)
end
local hideHUD = module.hideHUD

function module.showHUD()

	script.Parent.HUDBottom.Visible = true
	script.Parent.HUDRight.Visible = true

	script.Parent.HUDBottom:TweenPosition(UDim2.new(0,0,1,-50),nil,nil,nil,true)
	script.Parent.HUDRight:TweenPosition(UDim2.new(1,-100,0,0),nil,nil,nil,true)
	if game.Players.LocalPlayer.ActiveTycoon.Value then
		script.Parent.HUDAway:TweenPosition(UDim2.new(0,-300,0,0),nil,nil,nil,true)
		script.Parent.HUDLeft.Visible = true
		script.Parent.HUDTop.Visible = true
		script.Parent.HUDTop:TweenPosition(UDim2.new(0,0,0,0),nil,nil,nil,true)
		script.Parent.HUDLeft:TweenPosition(UDim2.new(0,0,0,0),nil,nil,nil,true)
	end
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,true)
	--game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All,true)
end
local showHUD = module.showHUD

module.oreLimitBar = script.Parent.HUDTop.Money.OreLimit



function module.tween(Object, Properties, Value, Time)
	Time = Time or 0.5

	local propertyGoals = {}

	local Table = (type(Value) == "table" and true) or false

	for i,Property in pairs(Properties) do
		propertyGoals[Property] = Table and Value[i] or Value
	end
	local tweenInfo = TweenInfo.new(
		Time,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out
	)
	local tween = game:GetService("TweenService"):Create(Object,tweenInfo,propertyGoals)
	tween:Play()
end

local Tween = module.tween


function module.closeMenu()
	warn("function closeMenu is not ready yet")
end

function module.init(Modules)

	script.Parent.HUDAway.Visible = true
	script.Parent.HUDLeft.Visible = true


	function module.closeMenu(skipAnim)
		if Modules.Input.mode.Value == "Xbox" then
			game.GuiService.SelectedObject = nil
			game.GuiService.GuiNavigationEnabled = false

		end
		Modules.ItemInfo.hide()
		skipAnim = skipAnim or false
		if not Busy then
			Busy = true
			if not Modules.Placement.placing then
				showHUD()
			end
			if not skipAnim then
				script.Parent.Menu:TweenPosition(UDim2.new(-0.1,-script.Parent.Menu.AbsoluteSize.X,0,0),nil,nil,0.35)
				wait(0.3)
			end
			module.MenuOpen = false
			script.Parent.Menu.Visible = false
			Busy = false
		end
	end

	local Preview = Modules["Preview"]
	local Placement = Modules["Placement"]

	function module.closeAll(override)
		override = override or false
		if Modules.Input.mode.Value == "Xbox" then
			game.GuiService.GuiNavigationEnabled = false
		end
		module.MenuOpen = false
		Modules.Focus.close()
		script.Parent.Menu.Visible = false
		Modules.ItemInfo.hide()
		module.hideHUD(override)
	end

	function module.leaveBase()
		module.closeAll(true) -- hideHUD
		script.Parent.HUDAway:TweenPosition(UDim2.new(0,0,0,0),nil,nil,nil,true)
		script.Parent.HUDTop:TweenPosition(UDim2.new(0,0,0,-100),nil,nil,nil,true)
		if script.Parent.Inventory.Visible then
			Modules.Input.toggleInventory()
		end

		if script.Parent.Shop.Visible then
			Modules.Input.toggleShop()
		end
		if script.Parent.Settings.Visible then
			script.Parent.Settings.Visible = false
			Modules.Focus.close()
		end
		game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All,true)
		Placement.placing = false
	end

	local Player = game.Players.LocalPlayer

	Player.ActiveTycoon.Changed:connect(function()
		if Player.ActiveTycoon.Value == nil then
			module.leaveBase()
		else
			if not Player:FindFirstChild("Rebirthing") then
				module.showHUD()
			end
		end
	end)

	Player.ChildAdded:connect(function(Child)
		if Child.Name == "Rebirthing" then
			module.leaveBase()
		end
	end)

	Player.ChildRemoved:connect(function(Child)
		if Child.Name == "Rebirthing" then
			wait(5)
			if Player.ActiveTycoon.Value ~= nil then
				module.showHUD()
			end
		end
	end)

	script.Parent.HUDTop.Money.Currency.Crystals.More.MouseButton1Click:connect(function()
		Modules.Menu.sounds.Click:Play()
		Modules.Premium.show()
	end)

	function module.openMenu()
		if game.Players.LocalPlayer.ActiveTycoon.Value ~= nil and not Busy then
			--script.Parent.MenuOpened.Value = true
			Modules.Focus.change(script.Parent.Menu)
			Preview.collapse()
			Busy = true
			script.Parent.Menu.Position = UDim2.new(-0.1,-script.Parent.Menu.AbsoluteSize.X,0,0)
		--	script.Parent.Menu.Position = UDim2.new(-0.5,-50,0,0)
			script.Parent.Menu.Visible = true
			script.Parent.Menu:TweenPosition(UDim2.new(0,0,0,0),nil,nil,0.35)



			hideHUD()
			module.MenuOpen = true
			wait(0.3)

			if Modules.Input.mode.Value == "Xbox" then
				game.GuiService.GuiNavigationEnabled = true
				game.GuiService.SelectedObject = script.Parent.Menu.Contents.NavBar:FindFirstChild(script.Parent.Menu.Contents.ActiveFrame.Value)
			end

			Busy = false
		end
	end

	local MoneyLib = Modules["MoneyLib"]
	script.Parent.HUDLeft.OpenMenu.MouseButton1Click:connect(module.openMenu)
	script.Parent.Menu.Contents.aTitle.Close.MouseButton1Click:connect(module.closeMenu)
	module.closeMenu(true)

	showHUD()

	local Money = script.Parent:WaitForChild("Money")
	Money.Changed:connect(function()
		script.Parent.HUDTop.Money.Value.Text = MoneyLib.HandleMoney(Money.Value)
	end)
	script.Parent.HUDTop.Money.Value.Text = MoneyLib.HandleMoney(Money.Value)

	local Points = script.Parent:WaitForChild("Points")
	Points.Changed:connect(function()
		script.Parent.HUDTop.Money.Currency.Points.Value.Text = MoneyLib.DealWithPoints(Points.Value).." RP"
	end)
	script.Parent.HUDTop.Money.Currency.Points.Value.Text = MoneyLib.DealWithPoints(Points.Value).." RP"

	local Crystals = script.Parent:WaitForChild("Crystals")
	Crystals.Changed:connect(function()
		script.Parent.HUDTop.Money.Currency.Crystals.Value.Text = MoneyLib.DealWithPoints(Crystals.Value).." uC"
	end)
	script.Parent.HUDTop.Money.Currency.Crystals.Value.Text = MoneyLib.DealWithPoints(Crystals.Value).." uC"

	local Shards = script.Parent:WaitForChild("Shards")
	Shards.Changed:connect(function()
		if Shards.Value > 0 then
			script.Parent.HUDTop.Money.Currency.Shards.Visible = true
			script.Parent.HUDTop.Money.Currency.Shards.Value.Text = MoneyLib.DealWithPoints(Shards.Value)
			script.Parent.HUDTop.Money.Currency.Shards.Value.Size = UDim2.new(1,1000,1,0)
			local Len = script.Parent.HUDTop.Money.Currency.Shards.Value.TextBounds.X
			script.Parent.HUDTop.Money.Currency.Shards.Value.Size = UDim2.new(1,-22,1,0)
			script.Parent.HUDTop.Money.Currency.Shards.Size = UDim2.new(0,Len + 34,1,0)
		else
			script.Parent.HUDTop.Money.Currency.Shards.Visible = false
		end
	end)
	if Shards.Value > 0 then
		script.Parent.HUDTop.Money.Currency.Shards.Visible = true
		script.Parent.HUDTop.Money.Currency.Shards.Value.Text = MoneyLib.DealWithPoints(Shards.Value)
		script.Parent.HUDTop.Money.Currency.Shards.Value.Size = UDim2.new(1,1000,1,0)
		local Len = script.Parent.HUDTop.Money.Currency.Shards.Value.TextBounds.X
		script.Parent.HUDTop.Money.Currency.Shards.Value.Size = UDim2.new(1,-22,1,0)
		script.Parent.HUDTop.Money.Currency.Shards.Size = UDim2.new(0,Len + 34,1,0)
	end

	local Expanded = true
	local function collapse()
		if Expanded then
			Expanded = false
			Tween(script.Parent.HUDTop.Money.Change,{"TextTransparency"},1,0.5)
			Tween(script.Parent.HUDTop.Money.Value,{"Size"},UDim2.new(1,0,1,0),0.5)
			--script.Parent.HUDTop.Money.Value:TweenPosition(UDim2.new(0.5,0,0,0),nil,nil,0.5,true)
		end
	end
	local function expand()
		if not Expanded then
			Expanded = true
			Tween(script.Parent.HUDTop.Money.Change,{"TextTransparency"},0,0.5)
			Tween(script.Parent.HUDTop.Money.Value,{"Size"},UDim2.new(0.7,0,1,0),0.5)
			--script.Parent.HUDTop.Money.Value:TweenPosition(UDim2.new(0.26,0,0,0),nil,nil,0.5,true)
		end
	end

	collapse()

	local Change = script.Parent:WaitForChild("Change")
	Change.Changed:connect(function()
		script.Parent.HUDTop.Money.Change.Text = string.gsub(MoneyLib.HandleMoney(script.Parent.Change.Value),"%$","").."/s"
		if script.Parent.Change.Value > 0.1 then
			expand()
		else
			collapse()
		end
	end)

	local GStat = game.Players.LocalPlayer:WaitForChild("GiftStatus")

	local function UpdateGift()
		if GStat.Value == true then

			script.Parent.HUDRight.OpenGift.Visible = true
			script.Parent.HUDRight.OpenGift.GiftBox.ImageTransparency = 0

			if game.Players.LocalPlayer:FindFirstChild("SecondGift") then
				script.Parent.HUDRight.OpenGift.GiftBox.ImageColor3 = Color3.new(1,1,0)
			elseif game.Players.LocalPlayer:FindFirstChild("Executive") then
				script.Parent.HUDRight.OpenGift.GiftBox.ImageColor3 = Color3.fromRGB(255, 71, 74)
			elseif game.Players.LocalPlayer:FindFirstChild("VIP") then
				script.Parent.HUDRight.OpenGift.GiftBox.ImageColor3 = Color3.fromRGB(73, 225, 255)
			else
				script.Parent.HUDRight.OpenGift.GiftBox.ImageColor3 = Color3.fromRGB(255, 98, 248)
			end
		else
			script.Parent.HUDRight.OpenGift.Visible = false
		end
	end
	UpdateGift()
	GStat.Changed:connect(UpdateGift)


	local function findbestbox()
		local Max = 0
		local Res
		for i,Box in pairs(game.Players.LocalPlayer.Crates:GetChildren()) do
			if Box.Value > 0 then
				local Real = game.ReplicatedStorage.Boxes:FindFirstChild(Box.Name)
				if Real then
					if Real:FindFirstChild("VintageChance") and Real.VintageChance.Value > Max then
						Max = Real.VintageChance.Value
						Res = Real
					end
				end
			end
		end
		return Res
	end

	local function refreshicon()
		local Box = findbestbox()
		if Box then
			script.Parent.HUDRight.OpenBox.GiftBox.Image = "rbxassetid://"..Box.ThumbnailId.Value
		end
	end
	refreshicon()


	local DB = true

	function module.openboxes(String, Type)
		if Type == Enum.UserInputState.Cancel then
			return false
		end

		if module.menuOpen then
			return false
		end

		if DB and script.Parent.HUDRight.OpenBox.Visible then
			DB = false

			Modules.Menu.sounds.OpenMenu:Play()

			Modules.Focus.change(script.Parent.Boxes)

			script.Parent.Boxes.Visible = true
			if Modules.Input.mode.Value == "Xbox" then
				game.GuiService.GuiNavigationEnabled = true
				game.GuiService.SelectedObject = script.Parent.Boxes.Close
			end
			wait(0.2)
			DB = true
		end
	end

	script.Parent.HUDRight.OpenBox.MouseButton1Click:connect(module.openboxes)

	local function boxesrefresh()
		if game.Players.LocalPlayer.Crates.Value > 0 then
			script.Parent.HUDRight.OpenBox.Visible = true
			script.Parent.HUDRight.OpenBox.Amount.Visible = true
			script.Parent.HUDRight.OpenBox.Amount.Text = game.Players.LocalPlayer.Crates.Value
			refreshicon()
		else
			--script.Parent.HUDRight.OpenBox.Visible = false
			script.Parent.HUDRight.OpenBox.Amount.Visible = false
			script.Parent.HUDRight.OpenBox.GiftBox.Image = "http://www.roblox.com/asset/?id=1510057635"
		end
	end
	boxesrefresh()
	game.Players.LocalPlayer.Crates.Changed:connect(boxesrefresh)

	function module.opengift(String, Type)

		if module.menuOpen then
			return false
		end

		if Type == Enum.UserInputState.Cancel then
			return false
		end

		if DB and script.Parent.HUDRight.OpenGift.GiftBox.ImageTransparency < 0.4 then
			DB = false
			Modules.Menu.sounds.UnlockGift:Play()
			game.ReplicatedStorage.RewardReady:FireServer()
			script.Parent.HUDRight.OpenGift.GiftBox.ImageColor3 = Color3.new(0.3,0.3,0.3)
			script.Parent.HUDRight.OpenGift.GiftBox.ImageTransparency = 0.5
		end
		wait(0.5)
		DB = true
	end
	script.Parent.HUDRight.OpenGift.MouseButton1Click:connect(module.opengift)

	spawn(function()
		while script.Parent.HUDRight.OpenGift.Visible and script.Parent.HUDRight.OpenGift.GiftBox.ImageTransparency < 0.4 do
			wait(5)
			local GiftBox = script.Parent.HUDRight.OpenGift:FindFirstChild("GiftBox")
			if GiftBox then
				GiftBox:TweenPosition(UDim2.new(0.5,0,0.5,-30),nil,nil,0.5,true)
				wait(0.6)
				GiftBox:TweenPosition(UDim2.new(0.5,0,0.5,0),nil,Enum.EasingStyle.Bounce,0.8,true)
			else
				break
			end
		end
	end)
end

return module
