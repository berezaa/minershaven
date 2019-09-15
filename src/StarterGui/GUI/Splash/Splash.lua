--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

local module = {}

function module.init(Modules)

	local function close()
		Modules.Focus.close()
		Modules.Menu.sounds.Click:Play()
	end

	script.Parent.Top.Close.MouseButton1Click:connect(close)
	script.Parent.Button.MouseButton1Click:connect(close)

	game.ReplicatedStorage.Splash.OnClientEvent:connect(function(Splash)
		if true then
			return false
		end
		local Screen = script.Parent.Screens:FindFirstChild(Splash)
		if Screen then
			for i,Scr in pairs(script.Parent.Screens:GetChildren()) do
				Scr.Visible = false
			end
			Screen.Visible = true
			script.Parent.Visible = true
			Modules.Focus.change(script.Parent)
			game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
			Modules.HUD.hideHUD()
		end
	end)

end

return module