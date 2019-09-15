--[[
Menu Module. This is where I'd put my funny comment - if I had one.
~Andrew Bereza
]]

--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

local module = {}

module.sounds = script.Sounds

module.current = script.Parent.Contents.ActiveFrame


function module.tween(Object, Properties, Value, Time, Style, Direction)
	Style = Style or Enum.EasingStyle.Quad
	Direction = Direction or Enum.EasingDirection.Out

	Time = Time or 0.5

	local propertyGoals = {}

	local Table = (type(Value) == "table" and true) or false

	for i,Property in pairs(Properties) do
		propertyGoals[Property] = Table and Value[i] or Value
	end
	local tweenInfo = TweenInfo.new(
		Time,
		Style,
		Direction
	)
	local tween = game:GetService("TweenService"):Create(Object,tweenInfo,propertyGoals)
	tween:Play()
end

local tween = module.tween


local function iDiv(a,b)
	return math.floor(a/b)
end



local function findActiveMenu()
	for i,Menu in pairs(script.Parent.Contents:GetChildren()) do
		if Menu:FindFirstChild("MenuObject") and Menu.MenuObject.Value then
			script.Parent.Contents.ActiveFrame.Value = Menu.Name -- Update the value while we're at it
			return Menu
		end
	end
end






function module.openMenu()
	warn("Function openMenu not ready yet.")
end

function module.init(Modules)

	local function resize()
		local Size = workspace.CurrentCamera.ViewportSize - Vector2.new(0,36)
		if --[[(Size.X * Size.Y) <= 250125]] Modules.Input.mode.Value == "Mobile" then -- For small mobile devices, make it fullscreen
			script.Parent.SizeCon.MaxSize = Vector2.new(10000,10000)
			script.Parent.SizeCon.MinSize = Size
			script.Parent.SizeCon.MaxSize = Vector2.new(Size.X+1, script.Parent.Parent.Measure.AbsoluteSize.Y + 1)

		else
			script.Parent.SizeCon.MinSize = Vector2.new(0,0)
			script.Parent.SizeCon.MaxSize = Vector2.new(700, script.Parent.Parent.Measure.AbsoluteSize.Y + 1)

		end


		local Length = script.Parent.Contents.Inventory.Frame.Items.AbsoluteSize.X - 22
		local Collums = iDiv(Length,110)
		local Extra = Length - (Collums * 110)
		local Cell = 100 + iDiv(Extra,Collums)
		script.Parent.Contents.Inventory.Frame.Items.UIGridLayout.CellSize = UDim2.new(0, Cell, 0, Cell)
		script.Parent.Contents.Shop.Frame.Items.UIGridLayout.CellSize = UDim2.new(0, Cell, 0, Cell)
		script.Parent.Contents.Boxes.Items.UIGridLayout.CellSize = UDim2.new(0, Cell, 0, Cell)

		local Buttons = script.Parent.Contents.Inventory.Frame.Items.Count.Value
		script.Parent.Contents.Inventory.Frame.Items.CanvasSize = UDim2.new(0,0,0,10 + (Cell + 10) * math.ceil(Buttons / Collums))

		local ShopButtons = script.Parent.Contents.Shop.Frame.Items.Count.Value
		script.Parent.Contents.Shop.Frame.CanvasSize = UDim2.new(0,0,0,130 + (Cell + 10) * math.ceil(ShopButtons/Collums))

		local BoxButtons = script.Parent.Contents.Boxes.Items.Count.Value
		script.Parent.Contents.Boxes.Items.CanvasSize = UDim2.new(0,0,0,130 + (Cell + 10) * math.ceil(BoxButtons/Collums))


	end

	function module.openMenu(MenuName,skipAnim)
		if game.Players.LocalPlayer.ActiveTycoon.Value then
			skipAnim = skipAnim or false
			local Menu = script.Parent.Contents:FindFirstChild(MenuName)
			if MenuName ~= "Inventory" and Modules.Placement.Placing then
				Modules.Placement.stopPlacing()
			end
			if Menu and Menu:FindFirstChild("MenuObject") then
				local CurrentMenu = findActiveMenu()
				if CurrentMenu ~= Menu then
					-- Figure out where the menus are relative to eachother
					local CurMenuButton = script.Parent.Contents.NavBar:FindFirstChild(CurrentMenu.Name)
					local MenuButton = script.Parent.Contents.NavBar:FindFirstChild(Menu.Name)
					if CurMenuButton and MenuButton then

						if Modules.Input.mode.Value == "Xbox" then
							game.GuiService.GuiNavigationEnabled = true
							game.GuiService.SelectedObject = MenuButton
						end

						Modules.ItemInfo.hide()

						-- Animation direction depends on tab button position
						script.Sounds.Slide:Play()

						CurMenuButton.ZIndex = 2
						MenuButton.ZIndex = 3

						local Diff = MenuButton.AbsolutePosition.X - CurMenuButton.AbsolutePosition.X
						local CurEndPosition = UDim2.new(-1,-15,0.015,76)
						local StartPosition = UDim2.new(1,15,0.015,76)
						if Diff < 0 then
							CurEndPosition = UDim2.new(1,15,0.015,76)
							StartPosition = UDim2.new(-1,-15,0.015,76)
						end

						local CurBPos = CurMenuButton.Position
						local NewBPos = MenuButton.Position

						CurMenuButton.Position = UDim2.new(CurBPos.X.Scale,CurBPos.X.Offset,CurBPos.Y.Scale,-10)
						MenuButton.Position = UDim2.new(NewBPos.X.Scale,NewBPos.X.Offset,NewBPos.Y.Scale,0)

						local CurCol = CurMenuButton.BackgroundColor3
						CurMenuButton.Button.ImageColor3 = Color3.new(CurCol.r * 1.5, CurCol.g * 1.5, CurCol.b * 1.5)

						MenuButton.Button.ImageColor3 = Color3.new(1,1,1)

						script.Parent.Contents.aTitle.Text = MenuName

						Menu.Position = StartPosition
						Menu.Visible = true
						Menu.MenuObject.Value = true
						CurrentMenu.MenuObject.Value = false
						local Color = MenuButton.BackgroundColor3
						script.Parent.Contents.ActiveFrame.Value = Menu.Name
						if skipAnim then -- in case an instant transision is needed
							Menu.Position = UDim2.new(0,0,0.015,76)
							CurrentMenu.Position = CurEndPosition
							script.Parent.Contents.aTitle.BackgroundColor3 = Color
							script.Parent.Contents.aTitle.TextStrokeColor3 = Color
							script.Parent.Background.ImageColor3 = Color
						else
							Menu:TweenPosition(UDim2.new(0,0,0.015,76),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.5,true)
							CurrentMenu:TweenPosition(CurEndPosition,Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.5,true)
							tween(script.Parent.Contents.aTitle,{"BackgroundColor3","TextStrokeColor3"},Color)
							tween(script.Parent.Background,{"ImageColor3"},Color)
							wait(0.5)
						end

						if CurrentMenu ~= script.Parent.Contents.ActiveFrame.Value then
							CurrentMenu.Visible = false
						end




						return true
					else
						--print("Failed to find button for either " .. CurrentMenu.Name .. " or " .. MenuName)
					end

				else
					--print(MenuName.." is already open.")
				end
			else
				--print(MenuName.." is not a valid menu.")
			end
			return false
		end
	end

	local MoneyLib = Modules.MoneyLib

	-- Close all tabs
	for i,Menu in pairs(script.Parent.Contents:GetChildren()) do
		if Menu:FindFirstChild("MenuObject") then
			Menu.Visible = false
			Menu.MenuObject.Value = false
		end
	end
	-- Open inventory
	script.Parent.Contents.Inventory.Visible = true
	script.Parent.Contents.Inventory.MenuObject.Value = true
	script.Parent.Contents.ActiveFrame.Value = "Inventory"
	resize()
	script.Parent.Parent.ScreenSize:GetPropertyChangedSignal("AbsoluteSize"):connect(resize)
	--script.Parent:GetPropertyChangedSignal("AbsoluteSize"):connect(resize)
--	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):connect(resize)
	-- Set up nav bar
	for i,Button in pairs(script.Parent.Contents.NavBar:GetChildren()) do
		if Button:FindFirstChild("Button") and script.Parent.Contents:FindFirstChild(Button.Name) then
			Button.MouseButton1Click:connect(function()
				module.openMenu(Button.Name)
			end)
		end
	end
	script.Parent.Contents.Inventory.Frame.Items.Count.Changed:connect(resize)
	script.Parent.Contents.Shop.Frame.Items.Count.Changed:connect(resize)
	wait()

	local function setMoney()
		script.Parent.Bottom.Money.Text = MoneyLib.HandleMoney(script.Parent.Parent.Money.Value)
	end

	script.Parent.Parent.Money.Changed:connect(setMoney)
	setMoney()

	local function setPoints()
		script.Parent.Bottom.RP.Text = MoneyLib.DealWithPoints(script.Parent.Parent.Points.Value).." RP"
	end

	script.Parent.Parent.Points.Changed:connect(setPoints)
	setPoints()

	local function setCrystals()
		script.Parent.Bottom.Crystals.Text = MoneyLib.DealWithPoints(script.Parent.Parent.Crystals.Value).." uC"
	end

	script.Parent.Parent.Crystals.Changed:connect(setCrystals)
	setCrystals()

--	openMenu("Inventory",true)
end

module.sounds = script.Sounds

return module
