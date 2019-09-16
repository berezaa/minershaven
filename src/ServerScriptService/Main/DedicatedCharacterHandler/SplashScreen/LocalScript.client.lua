local visible = false

print("LocalSplash")

visible = true
script.Parent.Frame.Position = UDim2.new(0.5,-450,1,15)
script.Parent.Frame.Visible = true
script.Parent.Frame:TweenPosition(UDim2.new(0.5,-450,0.5,-301))
wait(1)

if game:GetService("UserInputService").GamepadEnabled then
	game:GetService("GuiService"):AddSelectionParent(script.Parent.Frame,"Splash")
	game:GetService("GuiService").SelectedObject = script.Parent.Frame.Image.Click
end

script.Parent.Frame.Image.Click.MouseButton1Click:connect(function()
	if visible then
		visible = false
		script.Parent.Frame:TweenPosition(UDim2.new(0.5,-450,1,10))
		if game:GetService("UserInputService").GamepadEnabled then
			game:GetService("GuiService"):RemoveSelectionGroup("Splash")
		end
		wait(1)
		script.Parent:Destroy()
	end
end)

print("aaand donezo")
