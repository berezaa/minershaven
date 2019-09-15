--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

function GetSum(Crates)
	local Total = 0
	for i,v in pairs(Crates:GetChildren()) do
		Total = Total + v.Value
	end
	return Total
end

local LotteryLib = require(game.ReplicatedStorage.LotteryLib)


-- DEAR GOD TODO REMOVE THIS AFTER HALLOWEEN
function game.ReplicatedStorage.BuyBox.OnServerInvoke(Player,Type)
	-- ber too lazy to make something for non-box products
	if Type == "Megaphone" then
		if Player.Crystals.Value >= 80 then
			Player.Crystals.Value = Player.Crystals.Value - 80
			Player.Megaphones.Value = Player.Megaphones.Value + 1

			-- Game Analytics Currency Reporting
			local CrystalsGained = -80
			local ProductName = Type
			if true then
				ProductName = ProductName or "unknown"
				game.ServerStorage.CurrencyEvent:Fire(Player, "Crystals", CrystalsGained, "miscbuy", ProductName)
			end
			-- Game Analytics Currency Reporting
			return true
		end
	elseif Type == "Regular" then
		if Player.Crystals.Value >= 15 then
			Player.Crystals.Value = Player.Crystals.Value - 15
			Player.Crates.Regular.Value = Player.Crates.Regular.Value + 1
			-- Game Analytics Currency Reporting
			local CrystalsGained = -15
			local ProductName = Type
			if true then
				ProductName = ProductName or "unknown"
				game.ServerStorage.CurrencyEvent:Fire(Player, "Crystals", CrystalsGained, "boxbuy", ProductName)
			end
			-- Game Analytics Currency Reporting
			return true
		else
			return false
		end
	elseif Type == "Unreal" then
		if Player.Crystals.Value >= 40 then
			Player.Crystals.Value = Player.Crystals.Value - 40
			Player.Crates.Unreal.Value = Player.Crates.Unreal.Value + 1
			-- Game Analytics Currency Reporting
			local CrystalsGained = -40
			local ProductName = Type
			if true then
				ProductName = ProductName or "unknown"
				game.ServerStorage.CurrencyEvent:Fire(Player, "Crystals", CrystalsGained, "boxbuy", ProductName)
			end
			-- Game Analytics Currency Reporting
			return true
		else
			return false
		end
	end
end


rand = Random.new()


game.Players.PlayerAdded:connect(function(Player)

	local Crates = Instance.new("IntValue")
	Crates.Name = "Crates"

	local function Sum()
		local Total = 0
		for i,Child in pairs(Crates:GetChildren()) do
			Total = Total + Child.Value
		end
		Crates.Value = Total
	end

	for i,Box in pairs(game.ReplicatedStorage.Boxes:GetChildren()) do
		local Value = Instance.new("IntValue")
		Value.Name = Box.Name
		Value.Parent = Crates
		Value.Changed:connect(Sum)
	end

	Sum()

	Crates.Parent = Player


	local Clovers = Instance.new("IntValue")
	Clovers.Name = "Clovers"
	Clovers.Parent = Player

	for i,v in pairs(Crates:GetChildren()) do
		v.Changed:connect(function()
			Crates.Value = GetSum(Crates)
		end)
	end
end)

local DataStore = game:GetService("DataStoreService"):GetDataStore("GlobalAnnouncement")

local Rand = Random.new(os.time())

function game.ReplicatedStorage.MysteryBox.OnServerInvoke(Player,Type)
	local VintageReward = false
	local Mag = false
	if Type == "Unreal" and Player.Crates.Unreal.Value > 0 then
		local g = Rand:NextInteger(1,100)
		if g == 77 or ((g == 13 or g == 7 or g == 99) and Player:FindFirstChild("Premium")) then
			Type = "Magnificent"
			Mag = true
		end
	end
	local Real = game.ReplicatedStorage.Boxes:FindFirstChild(Type)
	if Real then
		if true then
			-- Checks if a player can open the crate
			local Val = Player.Crates:FindFirstChild(Type)
			if Val and Val.Value > 0 and not Mag then
				Val.Value = Val.Value - 1
			elseif Mag then
				Player.Crates.Unreal.Value = Player.Crates.Unreal.Value - 1
			else
				return false
			end

			if Player:FindFirstChild("OpeningBox") then
				return false
			end


			local tag = Instance.new("BoolValue")
			tag.Name = "OpeningBox"
			tag.Parent = Player

			-- Opens the crate

			spawn(function() -- ugly ugly hack, please dont yell at me
				wait(1)
				if Player and Player.Parent == game.Players then
					game.ServerStorage.PlayerOpenBox:Fire(Player, Type, VintageReward)
				end
			end)


			game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." unlocked a ".. Type.." Box.",Color3.new(1,1,1),Color3.new(0,0,0),Color3.new(0,0,0))
			game.ServerStorage.AwardBadge:Invoke(Player,286700428)
			local PrizeInfo = LotteryLib.Run(Player,Type)
			local Prize = PrizeInfo[1]
			spawn(function()
				wait(7)
				local BGColor = Color3.new(1,1,1)
				local Prefix = ""
				if Prize.Tier.Value == 77 and Prize.ItemType.Value == 10 then
					BGColor = Color3.new(0.6,0.1,0.1)
					Prefix = "Shhh! "
				elseif PrizeInfo[5] < 9 then
					if PrizeInfo[5] > 7 then
						BGColor = Color3.new(0.5,1,0.5)
						Prefix = "Cool! "
					elseif PrizeInfo[5] > 5 then
						BGColor = Color3.new(1,1,0.5)
						Prefix = "Wow! "
					elseif PrizeInfo[5] > 3 then
						BGColor = Color3.new(1,0.5,0.5)
						Prefix = "Woah!! "
					elseif Prize.Tier.Value == 66 then
						BGColor = Color3.new(1,1,1)
						Prefix = "My word! "
						game.ServerStorage.ReportEvent:Invoke(Player, "win:luxery:"..string.lower(Type),1)

					elseif Prize.Tier.Value ~= 41 and Prize.Tier.Value ~= 40 then
						BGColor = Color3.new(1,0.5,1)
						Prefix = "OMG!! "
					else
						BGColor = Color3.new(0.5,0.9,1)
						Prefix = "AAHHHHHH!!! "
						--Global announcement
						local Data
						if Prize.Tier.Value == 41 then
							Data = {Player.Name.." unboxed an exotic "..Prize.Name.."!",{0.3,1,0.8},{0,0,0},{0.5,0.9,1}}
							VintageReward = true
							game.ServerStorage.ReportEvent:Invoke(Player, "win:exotic:"..string.lower(Type),1)

						else
							VintageReward = true
							Data = {Player.Name.." unboxed a vintage "..Prize.Name.."!",{0,1,0.8},{0,0,0},{0.3,0.9,1}}
							game.ServerStorage.ReportEvent:Invoke(Player, "win:vintage:"..string.lower(Type),1)
						end

						pcall(function()
							DataStore:SetAsync("Announcement",Data)
						end)

					end
				end
				game.ReplicatedStorage.SystemAlert:FireAllClients(Prefix .. Player.Name.." won x1 "..Prize.Name.."!",BGColor)
				game.ServerStorage.AwardItem:Invoke(Player,Prize.ItemId.Value)
				tag:Destroy()

			end)
			spawn(function()
				wait(3)
				if Player.Clovers.Value > 0 and Player.UseClover.Value then
					Player.Clovers.Value = Player.Clovers.Value - 1
				end
				if Player.TwitchPoints.Value > 0 and Player.UseTwitch.Value then
					Player.TwitchPoints.Value = Player.TwitchPoints.Value - 1
				end
			end)
			return PrizeInfo, Mag
		else
			return nil
		end

	else
		return nil
	end



end
