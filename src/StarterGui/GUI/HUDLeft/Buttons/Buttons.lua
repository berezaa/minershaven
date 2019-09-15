local module = {}

local Buttons = {}



function module.addArrow(s)

	local frame = script.Parent

	for i,v in next,frame:GetChildren() do
		if v.ClassName == "ImageButton" and v:FindFirstChild("Arrow") then
			if v.Name == s then
				local tutorialColor0 = Color3.fromRGB(84,255,95)
				local tutorialColor1 = Color3.fromRGB(24, 220, 219)
				v.Arrow.Visible = true
				--Update arrow color
				local a = (tick()*.8)%2
				a = .5 - .5 * math.cos(math.pi*a)
				local currentColor = tutorialColor0:Lerp(tutorialColor1,a)
				local a1 = (tick()*1.75)%2
				a1 = .5 - .5 * math.cos(math.pi*a1)
				v.Arrow.ImageColor3 = currentColor
			else
				v.Arrow.Visible = false
			end
		end
	end
end

function module.init(Modules)

	local Tween = Modules.Menu.tween

	local ListLayout = script.Parent:FindFirstChild("ListLayout") or script:FindFirstChild("ListLayout")
	local GridLayout = script.Parent:FindFirstChild("GridLayout") or script:FindFirstChild("GridLayout")

	local function close(Button)
		local Goal = UDim2.new(-1,0,0,0)
		if Button.Hover.Active then
			Button.Hover.Active = false

			if Button.Hover:FindFirstChild("Title") and Button.Hover.Title.Position ~= Goal then
				Tween(Button.Hover.Title,{"Position"},Goal,1,Enum.EasingStyle.Quint,Enum.EasingDirection.In)
			end
		elseif Button.Hover.Title.Position ~= Goal then
			Tween(Button.Hover.Title,{"Position"},Goal,1,Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		end
	end

	local function open(Button)
		if not Button.Hover.Active then
			Button.Hover.Active = true
			local Goal = UDim2.new(0,10,0,0)
			if Button.Hover:FindFirstChild("Title") and Button.Hover.Title.Position ~= Goal then
				Tween(Button.Hover.Title,{"Position"},Goal,1,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
			end
		end
	end

	for i,Button in pairs(script.Parent:GetChildren()) do
		if Button:IsA("GuiButton") then
			table.insert(Buttons, Button)

			local opened = false

			if Button:FindFirstChild("Pulse") then
				Button.Pulse.Visible = false
				Button.Pulse.ImageColor3 = Button.ImageColor3
			end

			if Button:FindFirstChild("Hover") then
				Button.Hover.Visible = true
				if Modules.Input.mode.Value == "Mobile" then
					if Button.Hover:FindFirstChild("Title") then
						Button.Hover.Title.Position = UDim2.new(-1,0,0,0)
						Button.Hover.Active = false
					end
					opened = true
				else
					if Button.Hover:FindFirstChild("Title") then
						Button.Hover.Title.Position = UDim2.new(0,10,0,0)
						Button.Hover.Active = true
					end
				end

			end



			spawn(function()
				wait(5 - Button.LayoutOrder / 4)
				if not opened then
					close(Button)
				end
			end)

			Button.MouseEnter:connect(function()

				opened = true
				if Modules.Input.mode.Value == "PC" then
					for o,Other in pairs(Buttons) do
						if Other ~= Button then
							close(Other)
						end
					end
					open(Button)
				end
				if not Button.Pulse.Visible then
					Button.Pulse.Size = UDim2.new(1,0,1,0)
					Button.Pulse.ImageTransparency = 0
					Button.Pulse.Visible = true
					Tween(Button.Pulse,{"ImageTransparency","Size"},{1,UDim2.new(2,0,2,0)},0.3)
					wait(0.3)
					Button.Pulse.Visible = false
				end
			end)

			Button.MouseLeave:connect(function()
				close(Button)
			end)

			Button.MouseButton1Click:connect(function()
				Modules.Menu.sounds.Click:Play()
				Button.Active = false
				close(Button)
				wait(0.3)
				Button.Active = true
			end)

		end
	end

	local function moderefresh()
		if Modules.Input.mode.Value == "Mobile" then
			ListLayout.Parent = script
			GridLayout.Parent = script.Parent
			GridLayout:ApplyLayout()
		else
			ListLayout.Parent = script.Parent
			GridLayout.Parent = script
			ListLayout:ApplyLayout()
		end
	end
	moderefresh()
	Modules.Input.mode.Changed:connect(moderefresh)

	Modules.Focus.current.Changed:connect(function()
		for i,Button in pairs(Buttons) do
			--Button.Hover.Visible = false
			close(Button)
		end
	end)

	script.Parent.Inventory.MouseButton1Click:connect(function()
		Modules.Input.toggleInventory()
	end)

	script.Parent.Shop.MouseButton1Click:connect(function()
		Modules.Input.toggleShop()
	end)

	script.Parent.Settings.MouseButton1Click:connect(function()
		Modules.Input.toggleSettings()
	end)

	script.Parent.Premium.MouseButton1Click:connect(function()
		Modules.Input.togglePremium()
	end)
end

return module
