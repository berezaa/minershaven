local module = {}



function module.init(Modules)

	game.ReplicatedStorage.TeleportPrompt.OnClientEvent:Connect(function(PlaceId)
		if not script.Parent.Visible or script.Parent.PlaceId.Value ~= PlaceId then
			script.Parent.PlaceId.Value = PlaceId
			Modules.Focus.change(script.Parent)
			script.Parent.Visible = true
		end
	end)

	script.Parent.No.MouseButton1Click:Connect(function()
		Modules.Menu.sounds.Click:Play()
		Modules.Focus.close()
	end)

	script.Parent.Yes.MouseButton1Click:Connect(function()
		Modules.Menu.sounds.Click:Play()
		script.Parent.Visible = false
		game:GetService("TeleportService"):Teleport(script.Parent.PlaceId.Value)
	end)

end


return module
