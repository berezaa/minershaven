local module = {}

function module.addArrow(b)
	local arrow = script.Parent.OpenGift.Arrow

	if b then
		local tutorialColor0 = Color3.fromRGB(84,255,95)
		local tutorialColor1 = Color3.fromRGB(24, 220, 219)
		arrow.Visible = true
		--Update arrow color
		local a = (tick()*.8)%2
		a = .5 - .5 * math.cos(math.pi*a)
		local currentColor = tutorialColor0:Lerp(tutorialColor1,a)
		local a1 = (tick()*1.75)%2
		a1 = .5 - .5 * math.cos(math.pi*a1)
		arrow.ImageColor3 = currentColor
	else
		arrow.Visible = false
	end
end

function module.init(Modules)

	local Tween = Modules.Menu.tween

	local Buttons = {}

	for i,Button in pairs(script.Parent:GetChildren()) do
		if Button:IsA("GuiObject") and Button:FindFirstChild("Hover") then

			table.insert(Buttons,Button)

			if Button:FindFirstChild("GiftBox") then
				local Pulse = Button.GiftBox:Clone()
				Pulse.Size = UDim2.new(1,0,1,0)
				Pulse.AnchorPoint = Vector2.new(0.5,0.5)
				Pulse.Name = "Pulse"
				Pulse.Parent = Button.GiftBox
				Pulse.Visible = false
			end

			Button.MouseEnter:connect(function()
				for i,oButton in pairs(Buttons) do
					oButton.Hover.Visible = false
				end
				Button.Hover.Visible = true
				if Button:FindFirstChild("GiftBox") then
					local Pulse = Button.GiftBox:FindFirstChild("Pulse")
					if Pulse and not Pulse.Visible then
						Pulse.ImageColor3 = Button.GiftBox.ImageColor3
						Pulse.Size = UDim2.new(1,0,1,0)
						Pulse.ImageTransparency = 0
						Pulse.Visible = true
						Tween(Pulse,{"ImageTransparency","Size"},{1,UDim2.new(2,0,2,0)},0.3)
						wait(0.3)
						Pulse.Visible = false
					end
				end
			end)
			Button.MouseLeave:connect(function()
				Button.Hover.Visible = false
			end)

		end
	end

	Modules.Focus.current.Changed:connect(function()
		for i,Button in pairs(Buttons) do
			Button.Hover.Visible = false
		end
	end)

end

return module
