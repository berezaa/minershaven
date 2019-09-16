-- Xbox Chat
--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

local module = {}


function module.init(Modules)


	local function modeRefresh()
		local Xbox = Modules.Input.mode.Value == "Xbox"
		script.Parent.XboxChat.Visible = Xbox
		game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, not Xbox)
	end

	Modules.Input.mode.Changed:Connect(modeRefresh)
	modeRefresh()

	local Player = game.Players.LocalPlayer



	local function MoveChatUp(Displacement)
		for i,Chat in pairs(script.Parent.XboxChat.Chats:GetChildren()) do
			local EndPos = UDim2.new(0,0,1,Chat.Position.Y.Offset - Displacement)
			if Chat.Position.Y.Scale < -script.Parent.XboxChat.Size.Y.Scale then
				Chat:Destroy() -- Clear old chat
			else
				Chat.Position = EndPos
				--[[
				Chat:TweenPosition(EndPos,nil,nil,0.1,true)
				TODO: FINISH TWEENING
				]]
			end
		end
	end

	local function SystemMessage(Msg, TextColor3, TextStrokeColor3, BGColor, BGTrans, Font)

		TextColor3 = TextColor3 or Color3.new(1,1,1)
		TextStrokeColor3 = TextStrokeColor3 or Color3.new(0,0,0)

		local Message = script.Parent.XboxChat.SystemMessage:Clone()
		Message.Text = Msg
		Message.Font = Font or Message.Font
		Message.TextColor3 = TextColor3
		Message.TextStrokeColor3 = TextStrokeColor3
		Message.Parent = script.Parent.XboxChat.Chats
		local YDisp = Message.TextBounds.Y
		Message.Size = UDim2.new(1,0,0,YDisp)
		Message.Position = UDim2.new(0,0,1,0)

		MoveChatUp(YDisp)

		Message.Visible = true
	end

	local function DisplayMessage(Chat, Sender)
		local Message = script.Parent.XboxChat.Chat:Clone()

		local Prefix = ""
		local PrefixColor = Color3.new(1,1,1)
		if Player:FindFirstChild("Executive") then
			Prefix = "[EXEC]"
			PrefixColor = Color3.new(1,0,0)
		elseif Player:FindFirstChild("Premium") then
			Prefix = "[PREM]"
			PrefixColor = Color3.new(1,1,0)
		elseif Player:FindFirstChild("VIP") then
			Prefix = "[VIP]"
		elseif Player:FindFirstChild("Fan") or Player:FindFirstChild("BerezaaGames") then
			Prefix = "[FAN]"
		end

		Message.Parent = script.Parent.XboxChat.Chats
		Message.Text = Prefix
		Message.TextColor3 = PrefixColor

		Message.Sender.Text = Sender.Name..":"
		Message.Sender.TextColor3 = Sender.TeamColor.Color
		Message.Sender.Position = UDim2.new(0, Message.TextBounds.X + 5, 0, 0)

		Message.Message.Text = Chat
		local XDisp = Message.TextBounds.X + Message.Sender.TextBounds.X + 10
		Message.Message.Size = UDim2.new(1,-XDisp,1,0)
		Message.Message.Position = UDim2.new(0,XDisp,0,0)

		local YDisp = Message.Message.TextBounds.Y
		Message.Size = UDim2.new(1,0,0,YDisp)
		Message.Position = UDim2.new(0,0,1,0)

		Message.Visible = true
		MoveChatUp(YDisp)
		Message.Visible = true
	end

	game.ReplicatedStorage.PlayerChatted.OnClientEvent:connect(function(Chat, Sender)
		DisplayMessage(Chat, Sender)
	end)


	game.ReplicatedStorage.SystemAlert.OnClientEvent:connect(function(Message, TextColor3, TextStrokeColor3, BGColor, Font)
		SystemMessage(Message, TextColor3, TextStrokeColor3, BGColor, nil, Font)
	end)

	local function ToggleVisible()
		if Player.ChatVisible.Value then
			script.Parent.XboxChat.Position = UDim2.new(0,0,0,0)
			script.Parent.XboxChat.Chats.Visible = true

		else
			script.Parent.XboxChat.Position = UDim2.new(0,0,0,-300)
			script.Parent.XboxChat.Chats.Visible = false

		end
	end
	ToggleVisible()
	Player.ChatVisible.Changed:connect(ToggleVisible)

end

return module
