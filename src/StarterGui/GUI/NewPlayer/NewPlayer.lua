-- New Player
--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

local module = {}

module.Complete = false


function module.init(Modules)

	if game.Players.LocalPlayer:FindFirstChild("NewPlayer") then
		module.Complete = false
	else
		module.Complete = true
	end

	game.ReplicatedStorage.NewPlayer.OnClientEvent:connect(function()
		module.Complete = false
		wait(1)
		Modules.Focus.change(script.Parent)
		script.Parent.Visible = true
		if Modules.Input.mode.Value == "Xbox" then
			game.GuiService.SelectedObject = script.Parent.TextButton
		end
		Modules.HUD.hideHUD()
	end)

	script.Parent.TextButton.MouseButton1Click:connect(function()

		Modules.Focus.close()
		Modules.HUD.showHUD()
		module.Complete = true

		wait(30)
		if not script.Parent.Parent.MenuOpened.Value then
			--script.Parent.Parent.HUDLeft.OpenMenu.Info.Visible = true
			script.Parent.Parent.HUDLeft.Buttons.Inventory.Info.Position = UDim2.new(-4, 0, -1, 0)
			script.Parent.Parent.HUDLeft.Buttons.Inventory.Info.Visible = true
			script.Parent.Parent.HUDLeft.Buttons.Inventory.Info:TweenPosition(UDim2.new(0,15,-1,0))
		end
	end)

	script.Parent.Parent.MenuOpened.Changed:connect(function()

		--script.Parent.Parent.HUDLeft.OpenMenu.Info.Visible = false
		script.Parent.Parent.HUDLeft.Buttons.Inventory.Info.Visible = false

	end)

end


return module
