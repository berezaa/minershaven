--[[
local Filter = function(Message,Player)
	if Player.Name ~= "berezaa" and Player.Name ~= "Player" then
		return game:GetService("Chat"):FilterStringForPlayerAsync(Message,Player)
	else
		return Message
	end
end ]]

local Whitelist = {
	["twitch.tv/bereza"] = "%[TWITCH%]",
}

local Filter = function(Message,Player)
	for Phrase,Replacement in pairs(Whitelist) do
		Message = string.gsub(Message,Phrase,Replacement)
	end
	return game:GetService("Chat"):FilterStringForBroadcast(Message,Player)
end

local DataStore = game:GetService("DataStoreService"):GetDataStore("Shouts")
local connection = DataStore:OnUpdate("Shout", function(Data)
	if Data then
		local Sender = Data[1]
		local Message = Data[2]
		local Color = Color3.new(Data[3],Data[4],Data[5])
		local BGColor
		if Data[6] ~= nil then
			BGColor = Color3.new(Data[6],Data[7],Data[8])
		end

		local Font
		if Sender == "berezaa" then
			Font = Enum.Font.Cartoon
		end
		game.ReplicatedStorage.SystemAlert:FireAllClients("["..Sender.."'s Shout]: "..Message,Color,Color3.new(0,0,0),BGColor,Font)
	end

--	game.ReplicatedStorage.SystemAlert:FireAllClients("["..Sender.."'s Shout]: "..Message,Color ,Color3.new(0,0,0),Color3.new(0,0,0.2))
end)

function game.ReplicatedStorage.Shout.OnServerInvoke(Player,Message,ShoutColor,BGColor)
	if Player.userId > 0 then
		if Player.Megaphones.Value > 0 then
--		if Player:FindFirstChild("Crystals") and ((Player.Crystals.Value >= 40) or (Player:FindFirstChild("Premium") ~= nil and Player.Crystals.Value >= 25)) then



			local r = math.random(50,100)/100
			local g = math.random(50,100)/100
			local b = math.random(50,100)/100
			local br = 0
			local bg = 0
			local bb = 0

			if Player:FindFirstChild("ShoutColor") and ShoutColor ~= nil then
				BGColor = BGColor or Color3.new(0,0,0)
				r = ShoutColor.r
				g = ShoutColor.g
				b = ShoutColor.b
				br = BGColor.r
				bg = BGColor.g
				bb = BGColor.b
			end

			local FinalMessage
			if Player.userId ~= game.CreatorId then	-- sorry lol
				FinalMessage = Filter(Message,Player)
			else
				FinalMessage = Message
			end

			if FinalMessage ~= Message then -- something went wrong
				return false
			end

			Player.Megaphones.Value = Player.Megaphones.Value - 1

			DataStore:SetAsync("Shout",{Player.Name,FinalMessage,r,g,b,br,bg,bb})

			game.ServerStorage.ReportEvent:Invoke(Player, "shout")
			return true
		end
	end
	return false
end