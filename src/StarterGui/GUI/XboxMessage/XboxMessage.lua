--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

local module = {}

function module.init(Modules)

	local function Close()
		game:GetService("GuiService"):RemoveSelectionGroup("XboxChat")
		game:GetService("GuiService").SelectedObject = nil
		game:GetService("GuiService").GuiNavigationEnabled = false
		script.Parent.Visible = false
		script.Parent.TextBox.Text = ""
	end

	local Debounce = true

	script.Parent.Send.MouseButton1Click:connect(function()
		local Message = script.Parent.TextBox.Text
		if string.len(Message) > 0 then
			local success = game.ReplicatedStorage.SendChat:InvokeServer(Message)
			if success then
				Close()
			else
				script.Parent.Parent.Error:Play()
			end
		end
	end)
end

return module
