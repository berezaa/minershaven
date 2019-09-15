local Radio = game.ReplicatedStorage.Radio
Radio.Value = 835988778

local DataStore = game:GetService("DataStoreService"):GetDataStore("GlobalAnnouncement")

game.Players.PlayerAdded:connect(function(Player)
	local RadioMode = Instance.new("IntValue")
	RadioMode.Name = "RadioMode"
	if game.ReplicatedStorage.Radio.Value > 0 then
		RadioMode.Value = 2
	else
		RadioMode.Value = 1
	end
	RadioMode.Parent = Player
end)

function game.ReplicatedStorage.ChangeRadioMode.OnServerInvoke(Player,Mode)
	Player.RadioMode.Value = Mode
end

local connection = DataStore:OnUpdate("Song", function(value)
	if value then
		local MusicId = value[1]
		local SongName = value[2]
		local DJ = value[3]
		game.ReplicatedStorage.GlobalRadio.SongName.Value = SongName
		game.ReplicatedStorage.GlobalRadio.DJ.Value = DJ
		game.ReplicatedStorage.GlobalRadio.Value = MusicId
		for i,v in pairs(game.Players:GetPlayers()) do
			if v.RadioMode.Value == 3 then
				game.ReplicatedStorage.Hint:FireClient(v,"Global radio changed by "..DJ..".")
			end
		end
	end
end)


local Debounce = true

function game.ReplicatedStorage.ChangeGlobalRadio.OnServerInvoke(Player,MusicId)
	if Player.Crystals.Value >= 120 and Debounce then
		local Asset = game:GetService("MarketplaceService"):GetProductInfo(MusicId)
		if Asset ~= nil then
			if Asset.AssetTypeId ~= 3 then
				game.ReplicatedStorage.Error:FireClient(Player,"Now, you know I can't allow you to play that on the radio")
				return false
			end
			Debounce = false

			local SongName = ""
			if string.len(Asset.Name) > 30 then -- Shorten the name of the song so the msg isn't too long.
				SongName = string.sub(Asset.Name,1,30) .. "..."
			else
				SongName = Asset.Name
			end

			local MusicData = {MusicId,SongName,Player.Name}
			DataStore:SetAsync("Song",MusicData)

			local Message = Player.Name .. " changed the global radio to \"" .. SongName .. "\"."
			local BGColor = Color3.new(0,math.random(190,255)/255,math.random(150,255)/255)

			local Data = {Player.Name.." set global radio to "..SongName.."!",{0,0,0},{0,1,0.8},{BGColor.r,BGColor.g,BGColor.b}}
			DataStore:SetAsync("Announcement",Data)

			Player.Crystals.Value = Player.Crystals.Value - 120

			game.ReplicatedStorage.Hint:FireClient(Player,"Your music is playing on the global radio!")

			Player.RadioMode.Value = 3

			Debounce = true

	--		game.ReplicatedStorage.SystemAlert:FireAllClients(Message,Color3.new(0,0,0),Color3.new(0.5,0,0.3),BGColor)

			return true
		end
	end
	return false
end

function game.ReplicatedStorage.ChangeRadio.OnServerInvoke(Player,MusicId)
	if Player:FindFirstChild("BaseRadio") then
		if MusicId ~= 0 then
			local Asset = game:GetService("MarketplaceService"):GetProductInfo(MusicId)
			if Asset ~= nil then
				if Asset.AssetTypeId ~= 3 then
					game.ReplicatedStorage.Error:FireClient(Player,"Now, you know I can't allow you to play that on the radio")
					return false
				end
			end
		end
		local Tycoon = Player.PlayerTycoon.Value
		if Tycoon then
			Tycoon.SpecialMusic.Value = MusicId
			return true
		end
	end
	--[[
	if (Radio.Ready.Value and
		(Player.Crystals.Value >= 10 or Player:FindFirstChild("Executive" ~= nil)) or
		((Player.Crystals.Value >= 5 and Radio.Boring.Value) or Player:FindFirstChild("Executive" ~= nil) )) or
	   (Player.Crystals.Value >= 30) then

		local Asset = game:GetService("MarketplaceService"):GetProductInfo(MusicId)
		if Asset ~= nil then
			if Asset.AssetTypeId ~= 3 then
				game.ReplicatedStorage.Error:FireClient(Player,"Now, you know I can't allow you to play that on the radio")
				return false
			end
			-- Get their moneyyy
			if Radio.Ready.Value then
				if Player:FindFirstChild("Executive") == nil then
					if Radio.Boring.Value then
						Player.Crystals.Value = Player.Crystals.Value - 5
					else
						Player.Crystals.Value = Player.Crystals.Value - 10
					end
				end
			else
				Player.Crystals.Value = Player.Crystals.Value - 30
				-- Return money if someone was skipped
				local LastDJ = game.Players:FindFirstChild(Radio.DJ.Value)
				if LastDJ and LastDJ ~= Player then
					if LastDJ:FindFirstChild("Executive") == nil then
						LastDJ.Crystals.Value = LastDJ.Crystals.Value + 10
						game.ReplicatedStorage.Hint:FireClient(LastDJ,"Your music was skipped so your crystals were refunded.")
					end
				end
			end

			-- Set everything in place and play the music
			Radio.DJ.Value = Player.Name
			local PlayerName = Player.Name -- In case the player leaves
			spawn(function()
				Radio.Ready.Value = false
				Radio.Boring.Value = false
				wait(60)
				if Radio.DJ.Value == PlayerName then -- If its the same player let someone else buy their song.
					Radio.Ready.Value = true
				end
			end)
			spawn(function()
				local CurrentId = Radio.Value
				wait(600)
				if Radio.Value == CurrentId then
					Radio.Boring.Value = true
				end
			end)
			Radio.Value = MusicId

			-- Alert all players that the song has changed.
			local SongName
			if string.len(Asset.Name) > 30 then -- Shorten the name of the song so the msg isn't too long.
				SongName = string.sub(Asset.Name,1,30) .. "..."
			else
				SongName = Asset.Name
			end

			local Message = PlayerName .. " changed the radio to \"" .. SongName .. "\"."
			local BGColor = Color3.new(math.random(190,255)/255,0,math.random(150,255)/255)
			game.ReplicatedStorage.SystemAlert:FireAllClients(Message,Color3.new(0,0,0),Color3.new(0.5,0,0.3),BGColor)

			Player.RadioMode.Value = 2

			game.ReplicatedStorage.Hint:FireClient(Player,"Your music is playing on the radio!")
			return true
		end
	end
	]]
	return false
end