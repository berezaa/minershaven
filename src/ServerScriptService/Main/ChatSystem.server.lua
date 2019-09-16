local PlayerChatted = game.ReplicatedStorage.PlayerChatted
local GetRecentChatHistory = game.ReplicatedStorage.GetRecentChatHistory
local MostRecentChats = {} -- eight is maximum

local Filter = function(Message,Player,Sender)
	if Player.Name ~= "Player" and Player.Name ~= "Player1" then
		return game:GetService("Chat"):FilterStringAsync(Message,Sender, Player)
	--	return game:GetService("Chat"):FilterStringForPlayerAsync(Message,Player)
	else
		return Message
	end
end

function GetRecentChatHistory.OnServerInvoke(Player)
	return MostRecentChats
end

game.Players.PlayerRemoving:connect(function(Player)
	game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." has left the server.", Color3.new(1,0.5,0.5))
end)

function Chatted(Player, Chat)
	for i,v in pairs(game.Players:GetPlayers()) do
		spawn(function()
			PlayerChatted:FireClient(v,Filter(Chat,v,Player),Player)
		end)
	end
	if #MostRecentChats < 8 then
		MostRecentChats[#MostRecentChats + 1] = {Chat, Player}
	else
		table.remove(MostRecentChats, 1)
		MostRecentChats[8] = {Chat, Player}
	end
end

game.Players.PlayerAdded:connect(function(Player)
	if #game.Players:GetChildren() <= 6 then
		local WelcomeNotification 	= Instance.new("BoolValue", Player)
		WelcomeNotification.Name 		= "WelcomeNotification"
		WelcomeNotification.Value 	= true
		game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." has joined the server.", Color3.new(0.5,1,0.5))
		Player.CharacterAdded:connect(function(Char)
			local Humanoid = Char:WaitForChild("Humanoid")
			Humanoid.Died:connect(function()
				if WelcomeNotification.Value then
					WelcomeNotification.Value = false
				end
			end)
		end)


		Player.Chatted:connect(function(Chat)
			Chatted(Player, Chat)
		end)

	end
end)

function game.ReplicatedStorage.SendChat.OnServerInvoke(Player,Message)
	Chatted(Player, Message)
	return true
end
