-- Lottery Library

--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

local LotteryLib = {}


math.randomseed(os.time())

spawn(function()
	for _ = 1, 10 do
		math.random()
		wait(1)
	end
end)

local rand = Random.new()

LotteryLib.Cache = nil	

function LotteryLib.Run(Player,Mode,Client)
	
	local Clovers = (Player.UseClover.Value and Player.Clovers.Value > 0)
	
	local Real = game.ReplicatedStorage.Boxes:FindFirstChild(Mode)
	
	if Real == nil then
		print("YOUCH")
		return false
	end
	
	local Items = {}
	
	if game.Players.LocalPlayer ~= nil and LotteryLib.Cache ~= nil then -- If ran on a localscript
		Items = LotteryLib.Cache
		-- Play the odds!
		local Range = Items[#Items][4]
		local Winning 
		local Selection = rand:NextInteger(1,Range)
		for i,v in pairs(Items) do
			if Selection >=  v[3] and Selection <= v[4] then
				Winning = v
				break;
			end
		end
		if Winning ~= nil then
			return Winning
		end	
	end	
	
	
	local Money
	if game.Players.LocalPlayer ~= nil then
		Money = game.ReplicatedStorage.MoneyMirror:FindFirstChild(Player.Name).Value
	else
		Money = game.ServerStorage.MoneyStorage:FindFirstChild(Player.Name).Value
	end
	
	if Money == nil or Money <= 0 then
		Money = 500
	end	
	
	
-- Fill Items
	for i,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
	
		local Rarity = 10

		if Real.Name == "Festive" and v:FindFirstChild("Holiday") and v.Holiday.Value > 0 then
			local Chance = v.Holiday.Value * 110 -- adjust this
			if v:FindFirstChild("Holiday") then
				if v.Holiday.Value >= 20 then
					Rarity = 4
				elseif v.Holiday.Value >= 8 then
					Rarity = 3
				else 
					Rarity = 2
				end
			end

			if Chance > 0 then
				local RangeStart
				if #Items > 0 then
					RangeStart = Items[#Items][4] + 1
				else
					RangeStart = 0
				end
				local RangeEnd = RangeStart + Chance
				table.insert(Items, {v, Chance, RangeStart, RangeEnd, Rarity})
			end
		end		
		
		if Real.Name == "Pumpkin" and v:FindFirstChild("Halloween") and v.Halloween.Value > 0 then
			local Chance = v.Halloween.Value * 45 -- adjust this
			if v:FindFirstChild("Halloween") then
				if v.Halloween.Value >= 20 then
					Rarity = 4
				elseif v.Halloween.Value >= 8 then
					Rarity = 3
				else 
					Rarity = 2
				end
			end

			if Chance > 0 then
				local RangeStart
				if #Items > 0 then
					RangeStart = Items[#Items][4] + 1
				else
					RangeStart = 0
				end
				local RangeEnd = RangeStart + Chance
				table.insert(Items, {v, Chance, RangeStart, RangeEnd, Rarity})
			end
		end
	
	
		if v.ItemType.Value == 6 and v.Tier.Value == 66 then	
			local Chance = 0
			if Real:FindFirstChild("LuxChance") and Real.LuxChance.Value > 0 then
				Chance = Real.LuxChance.Value
				if Clovers then
					Chance = math.floor(Chance * 1.5)
				end
				if Client then
					Chance = math.floor(Chance * 2.5)
				end
				Rarity = 1
			end
			
			if Chance > 0 then
				local RangeStart
				if #Items > 0 then
					RangeStart = Items[#Items][4] + 1
				else
					RangeStart = 0
				end
				local RangeEnd = RangeStart + Chance
						
			
			
				table.insert(Items, {v, Chance, RangeStart, RangeEnd, Rarity})
			end
			
		end	
		-- Twitch Items (just dont touch this i guess)		
			
		if Player.TwitchPoints.Value > 0 and v:FindFirstChild("Twitch") and Player.UseTwitch.Value then
			local Chance = 0
			if v.ItemId.Value == 277 then
				Chance = 3
				Rarity = 1
			elseif v.ItemId.Value == 148 then
				Chance = 150
				Rarity = 5
			elseif v.ItemId.Value == 279 then
				Chance = 2
				Rarity = 1
			elseif v.ItemId.Value == 280 then
				Chance = 500
				Rarity = 5
			elseif v.ItemId.Value == 305 then
				Chance = 15
				Rarity = 2
			end
			if Chance > 0 then
				local RangeStart
				if #Items > 0 then
					RangeStart = Items[#Items][4] + 1
				else
					RangeStart = 0
				end
				local RangeEnd = RangeStart + Chance
				table.insert(Items, {v, Chance, RangeStart, RangeEnd, Rarity})	
			end
		end	
		
		-- Contraband Items
		if v.ItemType.Value == 10 and v.Tier.Value == 77 and Real.ContraMulti.Value > 0 then
			local Chance = math.floor(5 * Real.ContraMulti.Value)
			Rarity = 3
			local RangeStart
			if #Items > 0 then
				RangeStart = Items[#Items][4] + 1
			else
				RangeStart = 0
			end
			local RangeEnd = RangeStart + Chance
			table.insert(Items, {v, Chance, RangeStart, RangeEnd, Rarity})		
		end		
		
    -- 	Crystal shop items
		if v.ItemType.Value == 7 and Real.CrystalMulti.Value > 0 and v.Tier.Value ~= 22 then
			local RareVal = 0
			if v.Crystals.Value <= 7 and not (Clovers or Real.Name == "Inferno") then
				RareVal = 200
				Rarity = 9
			elseif v.Crystals.Value <= 15 and not (Clovers and Real.Name == "Inferno") then
				RareVal = 80
				Rarity = 7
			elseif v.Crystals.Value <= 35 then
				RareVal = 45
				if Client then
					RareVal = 60
				end
				Rarity = 5
			elseif v.Crystals.Value <= 150 then
				RareVal = 12
				if Client then
					RareVal = 20
				end
				Rarity = 3
			else
				RareVal = 5
				Rarity = 2
			end
			
			local Chance = math.floor((RareVal ^ (1/Real.CrystalMulti.Value)) * Real.CrystalMulti.Value * 3)
			
			if Chance > 0 then					
				local RangeStart
				if #Items > 0 then
					RangeStart = Items[#Items][4] + 1
				else
					RangeStart = 0
				end
				local RangeEnd = RangeStart + Chance
				table.insert(Items, {v, Chance, RangeStart, RangeEnd, Rarity})
			end
			
	--  Vintage items
		elseif v.ItemType.Value == 99 and Real.VintageChance.Value > 0 then
			local Chance = math.floor((1 * Real.VintageChance.Value) + rand:NextInteger(10,55)/100)
			if Client then
				Chance = math.ceil(Chance * 3)
			end
			if Clovers then
				Chance = math.floor(Chance * 1.5)
			end			
			Rarity = 1
			local RangeStart
			if #Items > 0 then
				RangeStart = Items[#Items][4] + 1
			else
				RangeStart = 0
			end
			local RangeEnd = RangeStart + Chance
			table.insert(Items, {v, Chance, RangeStart, RangeEnd, Rarity})	
						
	-- 	Regular items in price range
		elseif v.ItemType.Value <= 5 and Real.ShopChance.Value > 0 then
			local Chance = 0
			if v.Cost.Value <= Money * 3 then
				
				local RareVal = 0
				if v.Cost.Value >= Money * 2.4 then
					local RareVal = 3
					Rarity = 2
				elseif v.Cost.Value >= Money * 2 then
					local RareVal = 7
					Rarity = 3
				elseif v.Cost.Value >= Money * 1.6 then
					local RareVal = 10
					Rarity = 4
				elseif v.Cost.Value >= Money * 1.3 then
					local RareVal = 25
					Rarity = 5.5
				elseif v.Cost.Value >= Money * 0.7 then
					local RareVal = 50
					Rarity = 7
				elseif v.Cost.Value >= Money * 0.4 and not (Clovers and Real.Name == "Inferno") then
					local RareVal = 120
					Rarity = 8
				elseif v.Cost.Value >= Money * 0.2 and not (Clovers or Real.Name == "Inferno") then
					local RareVal = 200
					Rarity = 9
				end
				
				Chance = math.floor((RareVal ^ (1/Real.ShopChance.Value)) * Real.ShopChance.Value * 2)
				
			end
			if Chance > 0 then
				local RangeStart
				if #Items > 0 then
					RangeStart = Items[#Items][4] + 1
				else
					RangeStart = 0
				end
				local RangeEnd = RangeStart + Chance
				table.insert(Items, {v, Chance, RangeStart, RangeEnd, Rarity})
			end			
		end
	end	
	

	-- Play the odds!
	local Range = Items[#Items][4]
	
	local Winning 
	

	local Selection = rand:NextInteger(1,Range)
	for i,v in pairs(Items) do
		if Selection >=  v[3] and Selection <= v[4] then
			Winning = v
			break;
		end
	end

	if game.Players.LocalPlayer ~= nil then
		LotteryLib.Cache = Items
		spawn(function()
			wait(1)
			LotteryLib.Cache = nil
		end)
	end
	
	if Winning then
		return Winning
	end	
	
end

--[[
	function LotteryLib.Run(Player,Mode,Client)
		
		Client = Client or false
		-- Declare
		local Items = {}
		if game.Players.LocalPlayer ~= nil and LotteryLib.Cache ~= nil then -- If ran on a localscript
			Items = LotteryLib.Cache
			-- Play the odds!
			local Range = Items[#Items][4]
			local Winning 
			local Selection = math.random(1,Range)
			for i,v in pairs(Items) do
				if Selection >=  v[3] and Selection <= v[4] then
					Winning = v
					break;
				end
			end
			if Winning then
				return Winning
			end	
		end
		
		local Money = game.ServerStorage.MoneyStorage:FindFirstChild(Player.Name)
		if Money <= 0 then
			Money = 500
		end 
	
		local Money
		if game.Players.LocalPlayer ~= nil then
			
			local MoneyVal = Player.leaderstats.Cash.Value
			Money = require(game.ReplicatedStorage.MoneyLib).ShortToLong(string.sub(MoneyVal,2)) or tonumber(string.sub(MoneyVal,2))
		else
			Money = game.ServerStorage.MoneyStorage:FindFirstChild(Player.Name).Value
		end
		if Money == nil or Money <= 0 then
			Money = 500
		end
		if Mode == "Unrigged" then
		-- Fill Items
			for i,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
	
					
			--  Vintage items
				if v.ItemType.Value == 99 then
					local Chance = 1
					local RangeStart
					if #Items > 0 then
						RangeStart = Items[#Items][4] + 1
					else
						RangeStart = 0
					end
					local RangeEnd = RangeStart + Chance
					table.insert(Items, {v, Chance, RangeStart, RangeEnd})	
				end	
			end		
			
		elseif Mode == "Regular" then
			
		-- Fill Items
			for i,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
			
			-- Twitch Items
				if Player.TwitchPoints.Value > 0 and v:FindFirstChild("Twitch") and Player.UseTwitch.Value then
					local Chance = 0
					if v.ItemId.Value == 277 then
						Chance = 3
						if Client then
							Chance = 6
						end
					elseif v.ItemId.Value == 148 then
						Chance = 150
					elseif v.ItemId.Value == 279 then
						Chance = 2
					elseif v.ItemId.Value == 280 then
						Chance = 500
					elseif v.ItemId.Value == 305 then
						Chance = 15
					end
					if Chance > 0 then
						local RangeStart
						if #Items > 0 then
							RangeStart = Items[#Items][4] + 1
						else
							RangeStart = 0
						end
						local RangeEnd = RangeStart + Chance
						table.insert(Items, {v, Chance, RangeStart, RangeEnd})	
					end
				end	
				
				if v.ItemType.Value == 10 and v.Tier.Value == 77 then
					local Chance = 5
					local RangeStart
					if #Items > 0 then
						RangeStart = Items[#Items][4] + 1
					else
						RangeStart = 0
					end
					local RangeEnd = RangeStart + Chance
					table.insert(Items, {v, Chance, RangeStart, RangeEnd})		
				end		
				
		    -- 	Crystal shop items
				if v.ItemType.Value == 7 then
					local Chance = 5
					if Client then
						Chance = 9
					end
					if v.Crystals.Value <= 7 and (Player.Clovers.Value <= 0 or Player.UseClover.Value == false) then
						Chance = 200
					elseif v.Crystals.Value <= 15 then
						Chance = 85
					elseif v.Crystals.Value <= 35 then
						Chance = 45
					elseif v.Crystals.Value <= 150 then
						Chance = 12
					end
					local RangeStart
					if #Items > 0 then
						RangeStart = Items[#Items][4] + 1
					else
						RangeStart = 0
					end
					local RangeEnd = RangeStart + Chance
					table.insert(Items, {v, Chance, RangeStart, RangeEnd})
					
			--  Vintage items
				elseif v.ItemType.Value == 99 then
					local Chance = 1
					local RangeStart
					if #Items > 0 then
						RangeStart = Items[#Items][4] + 1
					else
						RangeStart = 0
					end
					local RangeEnd = RangeStart + Chance
					table.insert(Items, {v, Chance, RangeStart, RangeEnd})	
								
			-- 	Regular items in price range
				elseif v.ItemType.Value <= 5 then
					local Chance = 0
					if v.Cost.Value <= Money * 3 then
						if v.Cost.Value >= Money * 2.4 then
							Chance = 5
						elseif v.Cost.Value >= Money * 2 then
							Chance = 15
						elseif v.Cost.Value >= Money * 1.6 then
							Chance = 28
						elseif v.Cost.Value >= Money * 1.3 then
							Chance = 39
						elseif v.Cost.Value >= Money * 0.7 then
							Chance = 50
						elseif v.Cost.Value >= Money * 0.4 then
							Chance = 85
						elseif v.Cost.Value >= Money * 0.2 and (Player.Clovers.Value <= 0 or Player.UseClover.Value == false) then
							Chance = 120
						end
					end
					if Chance > 0 then
						local RangeStart
						if #Items > 0 then
							RangeStart = Items[#Items][4] + 1
						else
							RangeStart = 0
						end
						local RangeEnd = RangeStart + Chance
						table.insert(Items, {v, Chance, RangeStart, RangeEnd})
					end			
				end
			end
		elseif Mode == "Unreal" then
			
		-- Fill Items
			for i,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do

			-- Twitch Items
				if Player.TwitchPoints.Value > 0 and v:FindFirstChild("Twitch") and Player.UseTwitch.Value then
					local Chance = 0
					if v.ItemId.Value == 277 then
						Chance = 5
						if Client then
							Chance = 7
						end
					elseif v.ItemId.Value == 148 then
						Chance = 150
					elseif v.ItemId.Value == 279 then
						Chance = 4
						if Client then
							Chance = 5
						end
					elseif v.ItemId.Value == 305 then
						Chance = 15
					elseif v.ItemId.Value == 280 then
						Chance = 400
					end
					if Chance > 0 then
						local RangeStart
						if #Items > 0 then
							RangeStart = Items[#Items][4] + 1
						else
							RangeStart = 0
						end
						local RangeEnd = RangeStart + Chance
						table.insert(Items, {v, Chance, RangeStart, RangeEnd})	
					end
				end		
				if v.ItemType.Value == 10 and v.Tier.Value == 77 then
					local Chance = 7
					local RangeStart
					if #Items > 0 then
						RangeStart = Items[#Items][4] + 1
					else
						RangeStart = 0
					end
					local RangeEnd = RangeStart + Chance
					table.insert(Items, {v, Chance, RangeStart, RangeEnd})		
				end					
		    -- 	Crystal shop items
				if v.ItemType.Value == 7 then
					local Chance = 5
					if Client then
						Chance = 9
					end
					if v.Crystals.Value <= 7 and (Player.Clovers.Value <= 0 or Player.UseClover.Value == false) then
						Chance = 200
					elseif v.Crystals.Value <= 15 then
						Chance = 85
					elseif v.Crystals.Value <= 35 then
						Chance = 45
						if Client then
							Chance = 30
						end
					elseif v.Crystals.Value <= 150 then
						Chance = 15
						if Client then
							Chance = 24
						end
					end
					if v.Crystals.Value > 14 then
						local RangeStart
						if #Items > 0 then
							RangeStart = Items[#Items][4] + 1
						else
							RangeStart = 0
						end
						local RangeEnd = RangeStart + Chance
						table.insert(Items, {v, Chance, RangeStart, RangeEnd})
					end
					
			--  Vintage items
				elseif v.ItemType.Value == 99 then
					local Chance = 1
					
					if Client then
						Chance = 2
					end					
					
					local RangeStart
					if #Items > 0 then
						RangeStart = Items[#Items][4] + 1
					else
						RangeStart = 0
					end
					local RangeEnd = RangeStart + Chance
					table.insert(Items, {v, Chance, RangeStart, RangeEnd})	
								
			-- 	Regular items in price range
				elseif v.ItemType.Value <= 5 then
					local Chance = 0
					if v.Cost.Value <= Money * 3 then
						if v.Cost.Value >= Money * 2.4 then
							Chance = 5
						elseif v.Cost.Value >= Money * 2.1 then
							Chance = 15
						elseif v.Cost.Value >= Money * 1.65 then
							Chance = 28
						elseif v.Cost.Value >= Money * 1.35 then
							Chance = 39
						elseif v.Cost.Value >= Money * 0.75 then
							Chance = 50
						elseif v.Cost.Value >= Money * 0.45 then
							Chance = 70
							if Player.Clovers.Value > 0 and Player.UseClover.Value == true then
								local removalchance = math.random(1,2)
								if removalchance == 1 then
									Chance = 0
								end
							end
						elseif v.Cost.Value >= Money * 0.2 and (Player.Clovers.Value <= 0 or Player.UseClover.Value == false) then
							Chance = 91
						end
					end
					if Chance > 0 then
						local RangeStart
						if #Items > 0 then
							RangeStart = Items[#Items][4] + 1
						else
							RangeStart = 0
						end
						local RangeEnd = RangeStart + Chance
						table.insert(Items, {v, Chance, RangeStart, RangeEnd})
					end			
				end
			end
		elseif Mode == "Inferno" then
			
		-- Fill Items
			for i,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do

			-- Twitch Items
				if Player.TwitchPoints.Value > 0 and v:FindFirstChild("Twitch") and Player.UseTwitch.Value then
					local Chance = 0
					if v.ItemId.Value == 277 then
						Chance = 8
						if Client then
							Chance = 9
						end
					elseif v.ItemId.Value == 148 then
						Chance = 150
					elseif v.ItemId.Value == 279 then
						Chance = 8
						if Client then
							Chance = 9
						end
					elseif v.ItemId.Value == 280 then
						Chance = 200
					elseif v.ItemId.Value == 305 then
						Chance = 15
					end
					if Chance > 0 then
						local RangeStart
						if #Items > 0 then
							RangeStart = Items[#Items][4] + 1
						else
							RangeStart = 0
						end
						local RangeEnd = RangeStart + Chance
						table.insert(Items, {v, Chance, RangeStart, RangeEnd})	
					end
				end		
				if v.ItemType.Value == 10 and v.Tier.Value == 77 then
					local Chance = 9
					local RangeStart
					if #Items > 0 then
						RangeStart = Items[#Items][4] + 1
					else
						RangeStart = 0
					end
					local RangeEnd = RangeStart + Chance
					table.insert(Items, {v, Chance, RangeStart, RangeEnd})		
				end					
		    -- 	Crystal shop items
				if v.ItemType.Value == 7 then
					local Chance = 0
					if v.Crystals.Value > 15 then
						if v.Crystals.Value <= 35 then
							Chance = 50
							if Client then
								Chance = 26
							end
						elseif v.Crystals.Value <= 150 then
							Chance = 19
							if Client then
								Chance = 12
							end
						elseif v.Crystals.Value > 150 then
							Chance = 5
							if Client then
								Chance = 9
							end
						end
					end
					if Chance > 0 then
						local RangeStart
						if #Items > 0 then
							RangeStart = Items[#Items][4] + 1
						else
							RangeStart = 0
						end
						local RangeEnd = RangeStart + Chance
						table.insert(Items, {v, Chance, RangeStart, RangeEnd})
					end
					
			--  Vintage items
				elseif v.ItemType.Value == 99 then
					local Chance = ((Player.Clovers.Value <= 0 or Player.UseClover.Value == false) and 2) or 3

					if Client then
						Chance = 7
					end
					
					local RangeStart
					if #Items > 0 then
						RangeStart = Items[#Items][4] + 1
					else
						RangeStart = 0
					end
					local RangeEnd = RangeStart + Chance
					table.insert(Items, {v, Chance, RangeStart, RangeEnd})	
								
			-- 	Regular items in price range
				elseif v.ItemType.Value <= 5 then
					local Chance = 0
					if v.Cost.Value <= Money * 3.6 then
						if v.Cost.Value >= Money * 3 then
							Chance = ((Player.Clovers.Value <= 0 or Player.UseClover.Value == false) and 0) or 3
						elseif v.Cost.Value >= Money * 2.6 then
							Chance = 5
						elseif v.Cost.Value >= Money * 2.4 then
							Chance = 15
						elseif v.Cost.Value >= Money * 1.65 then
							Chance = 28
						elseif v.Cost.Value >= Money * 1.35 then
							Chance = 39
						elseif v.Cost.Value >= Money * 0.75 then
							Chance = 50
						end
					end
					if Chance > 0 then
						local RangeStart
						if #Items > 0 then
							RangeStart = Items[#Items][4] + 1
						else
							RangeStart = 0
						end
						local RangeEnd = RangeStart + Chance
						table.insert(Items, {v, Chance, RangeStart, RangeEnd})
					end			
				end
			end
		elseif Mode == "Magnificent" then

		-- Fill Items
			for i,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do


			-- Twitch Items
				if Player.TwitchPoints.Value > 0 and Player.UseTwitch.Value then
					local Chance = 0
					if v.ItemId.Value == 277 then
						Chance = 9
						if Client then
							Chance = 9
						end
					elseif v.ItemId.Value == 148 then
						Chance = 25
					elseif v.ItemId.Value == 305 then
						Chance = 15
					end
					if Chance > 0 then
						local RangeStart
						if #Items > 0 then
							RangeStart = Items[#Items][4] + 1
						else
							RangeStart = 0
						end
						local RangeEnd = RangeStart + Chance
						table.insert(Items, {v, Chance, RangeStart, RangeEnd})	
					end	
				end	
				if v.ItemType.Value == 10 and v.Tier.Value == 77 then
					local Chance = 7
					local RangeStart
					if #Items > 0 then
						RangeStart = Items[#Items][4] + 1
					else
						RangeStart = 0
					end
					local RangeEnd = RangeStart + Chance
					table.insert(Items, {v, Chance, RangeStart, RangeEnd})		
				end	
				
		    -- 	Crystal shop items
				if v.ItemType.Value == 7 then
					local Chance = 0
					if v.Crystals.Value > 15 then
						if v.Crystals.Value <= 35 then
							Chance = 0
							if Client then
								Chance = 0
							end
						elseif v.Crystals.Value <= 150 then
							Chance = 19
							if Client then
								Chance = 12
							end
						elseif v.Crystals.Value > 150 then
							Chance = 5
							if Client then
								Chance = 9
							end
						end
					end
					if Chance > 0 then
						local RangeStart
						if #Items > 0 then
							RangeStart = Items[#Items][4] + 1
						else
							RangeStart = 0
						end
						local RangeEnd = RangeStart + Chance
						table.insert(Items, {v, Chance, RangeStart, RangeEnd})
					end
					
			--  Vintage items
				elseif v.ItemType.Value == 99 then
					local Chance = ((Player.Clovers.Value <= 0 or Player.UseClover.Value == false) and 3) or 2

					if Client then
						Chance = 9
					end
					
					local RangeStart
					if #Items > 0 then
						RangeStart = Items[#Items][4] + 1
					else
						RangeStart = 0
					end
					local RangeEnd = RangeStart + Chance
					table.insert(Items, {v, Chance, RangeStart, RangeEnd})	
								
			-- 	Regular items in price range
				elseif v.ItemType.Value <= 5 then
					local Chance = 0
					if v.Cost.Value <= Money * 3 then
						if v.Cost.Value >= Money * 2.6 then
							Chance = 5
						elseif v.Cost.Value >= Money * 2.4 then
							Chance = 15
						elseif v.Cost.Value >= Money * 1.65 then
							Chance = 28
						elseif v.Cost.Value >= Money * 1.35 then
							Chance = 0
						elseif v.Cost.Value >= Money * 0.75 then
							Chance = 0
						end
					end
					if Chance > 0 then
						local RangeStart
						if #Items > 0 then
							RangeStart = Items[#Items][4] + 1
						else
							RangeStart = 0
						end
						local RangeEnd = RangeStart + Chance
						table.insert(Items, {v, Chance, RangeStart, RangeEnd})
					end			
				end
			end
			
		end
		
		-- Play the odds!
		local Range = Items[#Items][4]
		
		local Winning 
		

		local Selection = math.random(1,Range)
		for i,v in pairs(Items) do
			if Selection >=  v[3] and Selection <= v[4] then
				Winning = v
				break;
			end
		end

		if game.Players.LocalPlayer ~= nil then
			LotteryLib.Cache = Items
			spawn(function()
				wait(1)
				LotteryLib.Cache = nil
			end)
		end
		
		if Winning then
			return Winning
		end	
	end


]]
	
return LotteryLib
