--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

local Open = true -- Open up to everyone
local Exec = false -- If open is false, only open to Executives
local BerOnly = false -- Allow people to play only with berezaa


--"Xavitha_Albino"
local Whitelist = {"berezaa","chewbeccca","bertestingact76", "mymansbillybobjoe","RoboTest_1","Locard","ixteam","berezashelperbot","Blackcatmaxy","OutOfOrderFoxy","Mah_Bucket","Player","EvilArtist","Player1","bereza12","Hippie_OfDoom","Caaaaaaaaaaaaaaaarll","newtron_test05","ASAP_Nixo","thebutterboots153","Xhecktic","chessypickmen34","femou","","","zombieman147","RobuxLover1678","destroyomatic4000","eyeball7254","kokobus122","Aethexus","Fraulein_April","991mancrooper","legendsword359","maplestick","1_x","Locard_1","bertestingact94","ScroobIess"} -- Who is allowed in
--local Whitelist = {"berezaa","EvilArtist","bertestingact","Locard"}

local function CheckList(Player)
	if Player.userId == game.CreatorId then
		return true
	end
	for i,Name in pairs(Whitelist) do
		if string.lower(Player.Name) == string.lower(Name) then
			local Tag = Instance.new("BoolValue")
			Tag.Name = "Whitelisted"
			Tag.Parent = Player
			return true
		elseif Open then
			return true
		end
	end
	if Exec and (Player:FindFirstChild("Executive") or Player:FindFirstChild("Submitter")) then
		return true
	end
	return false
end

game.Players.PlayerAdded:connect(CheckList)

if BerOnly then
	local Tag = Instance.new("IntValue",game.ReplicatedStorage)
	Tag.Name = "BerOnly"
end

game.Players.PlayerRemoving:connect(function(Leaver)
	if Leaver.Name == "berezaa" and BerOnly then
		for i,Player in pairs(game.Players:GetPlayers()) do
			if not CheckList(Player) then
				Player:Kick("Berezaa has left the server.")
			end
		end
	end
end)
--
local function Allowed(Player)
	local Permission = CheckList(Player)
	if Permission or (BerOnly and game.Players:FindFirstChild("berezaa") ~= nil) or game.PlaceId == 258258996 then
		return true
	else
		spawn(function()
			wait(1)
			Player:Kick("Not allowed.")
		end)
		return false
	end
end

game.ReplicatedStorage.IsWhitelisted.OnServerInvoke = Allowed