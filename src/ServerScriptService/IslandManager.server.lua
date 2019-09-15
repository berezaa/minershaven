local mode
local isVip = false
if game.VIPServerId == "" or game.VIPServerOwnerId > 0 then
	mode = "Main"
	if game.VIPServerOwnerId > 0 then
		isVip = true
	end
else
	mode = "Private"
end

if game.VIPServerId ~= "" then
	Instance.new("BoolValue",workspace).Name = "Private"
end

for i,v in pairs(game.ServerStorage.Sets[mode]:GetChildren()) do
	v.Parent = workspace
end

local function GetDay()
	return math.floor(os.time() / 86400)
end

local Datastore = game:GetService("DataStoreService"):GetDataStore("IslandManage2")

local IslandPlayer = nil

local MarsColors = {
	BrickColor.new("Burnt Sienna"),
	BrickColor.new("Dark orange"),
	BrickColor.new("Burgundy"),
}

local function MarsScan(Subject)
	if Subject.Name == "Tree" then
		Subject:Destroy()
	else
		for i,Child in pairs(Subject:GetChildren()) do
			MarsScan(Child)
		end
	end

	if Subject:IsA("BasePart") then
		Subject.Material = Enum.Material.Slate
		local Index = math.random(1,#MarsColors)
		Subject.BrickColor = MarsColors[Index]
		if Subject:IsA("UnionOperation") then
			Subject.UsePartColor = true
		end
	end
end

game.Players.PlayerAdded:connect(function(Player)
	if mode == "Private" then
		IslandPlayer = Player
		game.ServerStorage.AwardBadge:Invoke(Player, 697767975)
	end
	spawn(function()
		wait(1)
		pcall(function()
			if isVip then
				game.ServerStorage.AwardBadge:Invoke(Player, 697776848)

				print("Awarding VIP Server Badge")
			end
			game.ServerStorage.AwardBadge:Invoke(Player, 697770868)
			print("Awarding Welcome")
		end)
	end)
end)

if workspace:FindFirstChild("Map") == nil then
	print("Starting map load")
	local Map
	local Mars = false
	if true then -- game.VIPServerId == ""
		if mode == "Main" then
			Map = "Map"
			if game.ServerStorage.Map:FindFirstChild("Complex") then
				game.ServerStorage.Map.Complex.Parent = game.ReplicatedStorage
			end
		else
			repeat wait() until IslandPlayer ~= nil
			if game.MarketplaceService:PlayerOwnsAsset(IslandPlayer,556758024) then
				Mars = true
			end
			Map = "SoloMap"
		end
		local ClientMap = game.ServerStorage[Map]:Clone()
		if Mars then
			game.Lighting.Sky:Destroy()
			local NewSky = game.ServerStorage.MarsSky:Clone()
			NewSky.Name = "Sky"
			NewSky.Parent = game.Lighting
			local Tag = Instance.new("BoolValue")
			Tag.Name = "Mars"
			Tag.Parent = game.ReplicatedStorage
			Tag.Value = true
			MarsScan(ClientMap)
			workspace.Gravity = 80
		end
		ClientMap.Name = "Map"
	    ClientMap.Parent = workspace
	    print("Map successfully loaded in!")
		if ClientMap:FindFirstChild("WaterFill") then
			workspace.Terrain:FillBlock(ClientMap.WaterFill.CFrame,ClientMap.WaterFill.Size,"Water")
			ClientMap.WaterFill.Transparency = 1
		end
	else
		spawn(function()
			for i=1,100 do
				wait(0.1)
				if game.ReplicatedStorage.IslandOwner.Value ~= 0 then
					break
				end
			end
			local IslandData = Datastore:GetAsync(game.ReplicatedStorage.IslandOwner.Value)
			IslandData = IslandData or {}
			local Theme = IslandData["Theme"] or "Default"
			local Map = game.ServerStorage.IslandMaps:FindFirstChild(Theme)
			Map.Name = "Map"
			Map.Parent = workspace

		end)
	end
end
--[[
local function SaveData(Player)
	local function Update(IslandData)
		IslandData = IslandData or {}
		IslandData["Expires"] = (Player:FindFirstChild("IslandExpires") and Player.IslandExpires.Value) or IslandData["Expires"]
		IslandData["Theme"] = (Player:FindFirstChild("IslandExpires") and Player.IslandExpires.IslandTheme.Value) or IslandData["Theme"]
		IslandData["IslandKey"] = (Player:FindFirstChild("IslandExpires") and Player.IslandExpires.IslandKey.Value) or IslandData["IslandKey"]
		IslandData["Sharing"] = (Player:FindFirstChild("IslandExpires") and Player.IslandExpires.IslandShare.Value) or IslandData["Sharing"]
		return IslandData
	end
	Datastore:UpdateAsync(Player.userId,Update)
end

local function PlayerJoined(Player)
	Player:WaitForChild("BaseDataLoaded") -- So we can safley use Get and SetAsync without worrying about server hopping

	local IslandExpires = Instance.new("NumberValue")
	IslandExpires.Name = "IslandExpires"
	IslandExpires.Value = 0
	local IslandTheme = Instance.new("StringValue",IslandExpires)
	IslandTheme.Name = "IslandTheme"
	IslandTheme.Value = "Default"
	local IslandShare = Instance.new("BoolValue",IslandExpires)
	IslandShare.Name = "IslandShare"
    IslandShare.Value = game.MarketplaceService:PlayerOwnsAsset(Player,271363421)

	local IslandKey = Instance.new("StringValue",IslandExpires)
	IslandKey.Name = "IslandKey"


	local function Update(IslandData)
		IslandData = IslandData or {}

		IslandExpires.Value = IslandData["Expires"] or 0
		IslandTheme.Value = IslandData["Theme"] or "Default"


		IslandData["Sharing"] = IslandShare.Value

		if (IslandData["IslandKey"] == nil or IslandData["IslandKey"] == "") and IslandExpires.Value > os.time() then
			-- We need to generate a new island!
			local NewId = game:GetService("TeleportService"):ReserveServer(game.PlaceId)
			IslandData["IslandKey"] = NewId
			IslandKey.Value = NewId
			print(NewId)
			print(IslandKey.Value)
		end



		IslandExpires.Parent = Player

		IslandExpires.Changed:connect(function() SaveData(Player) end)

		return IslandData
	end

	Datastore:UpdateAsync(Player.userId,Update)

end
game.Players.PlayerAdded:connect(PlayerJoined)

function game.ReplicatedStorage.IslandRenew.OnServerInvoke(Player, Days)
	if Days == 1 then
		if Player.Crystals.Value >= 5 then
			local function Update(IslandData)
				IslandData = IslandData or {}
				IslandData["Expires"] = IslandData["Expires"] or 0
				if IslandData["Expires"] > os.time() then
					IslandData["Expires"] = IslandData["Expires"] + 86400
				else
					IslandData["Expires"] = os.time() + 86400 - 5
				end
				Player.IslandExpires.Value = IslandData["Expires"]
				return IslandData
			end
			spawn(function()
				Datastore:UpdateAsync(Player.userId,Update)
				Player.Crystals.Value = Player.Crystals.Value - 5
			end)
			return true
		end
	elseif Days == 7 then
		if Player.Crystals.Value >= 25 then
			local function Update(IslandData)
				IslandData = IslandData or {}
				IslandData["Expires"] = IslandData["Expires"] or 0
				if IslandData["Expires"] > os.time() then
					IslandData["Expires"] = IslandData["Expires"] + (86400 * 7)
				else
					IslandData["Expires"] = os.time() + (86400 * 7) - 5
				end
				Player.IslandExpires.Value = IslandData["Expires"]
				return IslandData
			end
			spawn(function()
				Datastore:UpdateAsync(Player.userId,Update)
				Player.Crystals.Value = Player.Crystals.Value - 25
			end)
			return true
		end
	end
end

function game.ReplicatedStorage.CommunicateOwner.OnServerInvoke(Player, OwnerId)
	print(OwnerId)
	if game.ReplicatedStorage.IslandOwner.Value == 0 then
		print("Yay")
		local PlayerName = game.Players:GetNameFromUserIdAsync(OwnerId)
		if PlayerName ~= nil and PlayerName ~= "" then
			game.ReplicatedStorage.IslandOwner.Value = OwnerId
			game.ReplicatedStorage.IslandOwner.Username.Value = PlayerName
		end
	end
end


function game.ReplicatedStorage.TeleportToIsland.OnServerInvoke(Player, OwnerUserId)
	if game.ReplicatedStorage:FindFirstChild("IslandOwner") == nil or game.ReplicatedStorage.IslandOwner.Value ~= Player.userId then
		if OwnerUserId == Player.userId then
			if Player.IslandExpires.Value > os.time() then
				local Attempt,Error = pcall(function()
					game:GetService("TeleportService"):TeleportToPrivateServer(game.PlaceId,Player.IslandExpires.IslandKey.Value,{Player},"",{Player.userId},game.ReplicatedStorage.TeleportGui)
					game.ReplicatedStorage.Teleporting:FireClient(Player)
				end)
				if Attempt then
					game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." escaped to their private island!",Color3.new(1,1,1),Color3.new(0,0,0),Color3.new(0,0.5,0.3))
					return {"Teleporting!",Color3.new(1,1,1),99}
				else
					game.ReplicatedStorage.Error:FireClient(Player.Name,"Fail to teleport to own island: "..Error)
					return {"Error!",Color3.new(1,0,0),3}
				end
			else
				Player.IslandExpires.Value = 0
				return {"Island Expired!",Color3.new(1,0.4,0)}
			end
		else
			if Player:IsFriendsWith(OwnerUserId) then
				local IslandData = Datastore:GetAsync(OwnerUserId)
				if IslandData and IslandData["IslandKey"] then
					if IslandData["Sharing"] then
						if IslandData["Expires"] > os.time() then
							local Attempt,Error = pcall(function()
								game:GetService("TeleportService"):TeleportToPrivateServer(game.PlaceId,IslandData["IslandKey"],{Player},"",{OwnerUserId},game.ReplicatedStorage.TeleportGui)
								game.ReplicatedStorage.Teleporting:FireClient(Player)
							end)
							if Attempt then
								game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." escaped to a friend's island!",Color3.new(1,1,1),Color3.new(0,0,0),Color3.new(0,0.5,0.3))
								return {"Teleporting!",Color3.new(1,1,1)}
							else
								game.ReplicatedStorage.Error:FireClient(Player.Name,"Fail to teleport to friend's island: "..Error)
								return {"Error!",Color3.new(1,0,0),3}
							end

						else
							return {"Island Expired!",Color3.new(1,0,0.4)}
						end
					else
						return {"IslandShare Off!",Color3.new(1,0.4,0)}
					end
				else
					return {"Island Not Found!",Color3.new(1,0.4,0)}
				end
			else
				return {"Friends Only!",Color3.new(1,0.4,0)}
			end
		end
	else
		return {"Already here!",Color3.new(1,0,0.5)}
	end
end


]]