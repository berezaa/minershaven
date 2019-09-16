game.ReplicatedStorage:WaitForChild("Items")
local InventoryStore = game:GetService("DataStoreService"):GetDataStore("Inventory20") -- Inventory17
local BaseStore = game:GetService("DataStoreService"):GetDataStore("BaseLayout4") -- BaseLayout1
local MiscStore = game:GetService("DataStoreService"):GetDataStore("MiscStore6") -- MiscStore2
local Storage = game:GetService("DataStoreService"):GetDataStore("RebirthData")

_G["Inventory"] = {}

local Closing = false
--[[
	for i,v in pairs(Target:GetChildren()) do -- Clear all existing items
		if v:IsA("Model") or v:IsA("BoolValue") then
			v:Destroy()
		end
	end
]]

function checkVector(Vector,x,y,z)
	return math.floor(Vector.x) == x and math.floor(Vector.y) == y and math.floor(Vector.z) == z
end

function getTycoon(Player)
	for i,v in pairs(workspace.Tycoons:GetChildren()) do
		if Player.Name == v.Owner.Value then
			return v
		end
	end
	return nil
end

function TycoonToTable(Tycoon)
	local Return
	local TycoonBase = Tycoon.Base
	local TycoonTopLeft = TycoonBase.CFrame * CFrame.new(Vector3.new(TycoonBase.Size.x/2, 0, TycoonBase.Size.z/2))

	if Tycoon.Owner.Value ~= nil and Tycoon.Owner.Value.Parent ~= nil then
		Return = {}
		for i, Object in pairs(Tycoon:GetChildren()) do
			if Object:IsA("Model") and Object:FindFirstChild("Hitbox") then
				local PosVector = Object.Hitbox.Position - TycoonTopLeft.p

				local HitboxDirection = Object.Hitbox.CFrame.lookVector

				local DataTbl = {}
				DataTbl.ItemId = Object.ItemId.Value
				DataTbl.Position = {PosVector.x, PosVector.y, PosVector.z, HitboxDirection.x, HitboxDirection.y, HitboxDirection.z}

				Return[#Return + 1] = DataTbl
			end
		end
	end
	return Return
end

function TableToTycoon(Table, Target, Player)
	local TycoonBase = Target.Base
	local TycoonTopLeft = TycoonBase.CFrame * CFrame.new(Vector3.new(TycoonBase.Size.x/2, 0, TycoonBase.Size.z/2))

	for i, Object in pairs(Table) do


		if game.Players:FindFirstChild(Target.Owner.Value) == nil then
			print("Player missing, stopping base saving")
			return false
		end

		local Item
		for i, Thing in pairs(game.ReplicatedStorage.Items:GetChildren()) do
			if Object.ItemId == Thing.ItemId.Value then
				Item = Thing
			end
		end

		local HitboxDirection = Vector3.new()
		local DirectionValue = Object.Position[4]

		if Player ~= nil and Player.Parent == game.Players then
			if Item then
				Item = Item:clone()
				Item.Parent = Target
				Item.PrimaryPart = Item.Hitbox
				if Object.Position[5] == nil then -- Legacy for old saving system
					DirectionValue = DirectionValue * 90
					Item:SetPrimaryPartCFrame(CFrame.new(TycoonTopLeft * Vector3.new(Object.Position[1], Object.Position[2], Object.Position[3]))*CFrame.Angles(0, (math.pi * (DirectionValue/180)), 0))
				else -- New advanced saving system
					local Position = TycoonTopLeft * Vector3.new(Object.Position[1], Object.Position[2], Object.Position[3])
					local lookVector = Vector3.new(Object.Position[4],Object.Position[5],Object.Position[6])
					local CoordinateFrame = CFrame.new(Position, Position + (lookVector * 5))
					Item:SetPrimaryPartCFrame(CoordinateFrame)
				end
				for i,v in pairs(Item.Model:GetChildren()) do
					if v.Name == "Colored" then
						v.BrickColor = Player.TeamColor
					end
					if v:IsA("Script") then
						v.Disabled = false
					end
				end
				spawn(function()
					local Mesh = Instance.new("BlockMesh",Item.Hitbox)
					Mesh.Scale = Vector3.new(1,99999,1)
					Item.Hitbox.Transparency = 0.5
					for i=1,5 do
						Item.Hitbox.Transparency = Item.Hitbox.Transparency + 0.1
						wait(0.1)
					end
					Mesh:Destroy()
				end)
				wait()
			end
		else
			print("Player missing, stopping base saving")
			return false
		end
	end
	return true
end

function SaveData(Player)
	local Tycoon = getTycoon(Player)
	local Inventory = _G["Inventory"][Player.Name]
	if Player:FindFirstChild("BaseDataLoaded") then
		local money = game.ServerStorage.MoneyStorage:FindFirstChild(Player.Name)

			local SaveData = {}
			local MiscData = game.ReplicatedStorage.PlayerData:FindFirstChild(Tycoon.Name)

			if MiscData ~= nil then
				SaveData.DropLevel = MiscData.DropLevel.Value
				--[[
				if Player:FindFirstChild("leaderstats") ~= nil and Player.leaderstats:FindFirstChild("Kills") ~= nil then
					SaveData.Kills = Player.leaderstats.Kills.Value
				end
				--]]
				if Player:FindFirstChild("GamepadTutorial") then
					SaveData.GamepadTutorial = Player.GamepadTutorial.Value
				else
					SaveData.GamepadTutorial = false
				end
			end


			local msuccess,merror = pcall(function()
				if MiscData then
					MiscStore:SetAsync("MiscStore"..Player.userId, SaveData)
		--			MiscStore:UpdateAsync("MiscStore"..Player.userId, function(OldValue) return SaveData end)
				end
			end)
			if not msuccess then
				game.ReplicatedStorage.Error:FireClient(Player,"Your misc data failed to save:")
				game.ReplicatedStorage.Error:FireClient(Player,merror)
				print("MISC DATA FAILED TO SAVE :"..merror.." ("..Player.Name..")")
			end

			local Rebirth
			if Player:FindFirstChild("Rebirths") then
				Rebirth = Player.Rebirths.Value
				Storage:SetAsync(Player.userId,Rebirth)
			else
				warn("FAILED TO SAVE "..Player.Name.."'s REBIRTH VALUE")
			end

			local crystals = Player:FindFirstChild("Crystals")
			local isuccess = false
			local ierror = "could not find something"
				if money ~= nil and Inventory ~= nil and crystals ~= nil then
				isuccess,ierror = pcall(function()
					InventoryStore:SetAsync("InventoryStore"..Player.userId, {money.Value,Inventory,crystals.Value})
			--		InventoryStore:UpdateAsync("InventoryStore"..Player.userId, function(OldValue) return {money.Value,Inventory} end)
				end)
			end
			if not isuccess then
				game.ReplicatedStorage.Error:FireClient(Player,"Your inventory data failed to save:")
				game.ReplicatedStorage.Error:FireClient(Player,ierror)
				print("INVENTORY DATA FAILED TO SAVE :"..merror.." ("..Player.Name..")")
			end

			local bsuccess,berror = pcall(function()
				if Tycoon then
					local BaseData = TycoonToTable(Tycoon)
					if BaseData ~= nil then
						BaseStore:SetAsync("BaseStore"..Player.userId,BaseData)
					end
			--		BaseStore:UpdateAsync("BaseStore"..Player.userId, function(OldValue) return BaseData end)
				end
			end)
			if not bsuccess then
				game.ReplicatedStorage.Error:FireClient(Player,"Your base data failed to save:")
				game.ReplicatedStorage.Error:FireClient(Player,berror)
				print("BASE DATA FAILED TO SAVE :"..merror.." ("..Player.Name..")")
			end

	else
		game.ReplicatedStorage.Error:FireClient(Player,"Data save failed: no data loaded.")
	end
end

game.OnClose = function()
	Closing = true
	spawn(function()
	for i,v in pairs(game.Players:GetChildren()) do
		pcall(function()
			wait(math.random(0,1000)/1000)
			SaveData(v)
			script.Shutdown:Clone().Parent = v.PlayerGui
		end)
	end
	end)
	local offlineMode = game.JobId == ""
	if offlineMode then
		print("Offline Mode")
	else
		wait(15)
	end
end

-- Tutorial state. Keeping this here to keep things not confusing
game.ReplicatedStorage.TutorialAccepted.OnServerEvent:connect(function(Player)
	if Player:FindFirstChild("GamepadTutorial") then
		Player.GamepadTutorial.Value = true
	end
end)

function HandleLife(Life)
	local Suffix
	local LastDigit = tonumber(string.sub(tostring(Life),string.len(tostring(Life))))
	if Life <= 20 and Life >= 10 then
		Suffix = "th"
	elseif LastDigit == 1 then
		Suffix = "st"
	elseif LastDigit == 2 then
		Suffix = "nd"
	elseif LastDigit == 3 then
		Suffix = "rd"
	else
		Suffix = "th"
	end
	return Suffix
end

-- On player join
function PlayerAdded(Player)
	if #game.Players:GetChildren() <= 6 and (game.ReplicatedStorage.IslandOwner.Value == 0 or Player.userId == game.ReplicatedStorage.IslandOwner.Value) then
		if Player:FindFirstChild("BaseDataLoaded") == nil then
			local MoneyData
			local Data
			local InvData
			local MiscData
			local BaseData
			local Crystals

	--		local Stuff = InventoryStore:GetAsync("InventoryStore"..Player.userId)
			local Stuff
			InventoryStore:UpdateAsync("InventoryStore"..Player.userId,function(Value)
				Stuff = Value
			end)

			if Stuff ~= nil then
				MoneyData = Stuff[1] or 500
				Data = Stuff[2]
				Crystals = Stuff[3] or 0
			end

	--		BaseData = BaseStore:GetAsync("BaseStore"..Player.userId)
			local BaseData
			BaseStore:UpdateAsync("BaseStore"..Player.userId,function(Value)
				BaseData = Value
			end)

			local Tycoon = getTycoon(Player)
			if Tycoon then
				local TableToSave
				if BaseData ~= nil then
					TableToSave = TableToTycoon(BaseData,Tycoon,Player)
					if TableToSave then
						print(Player.Name.."'s base data loaded in.")
					else
						warn(Player.Name.."'s base failed to load in!")
						return false
					end
				else
					print(Player.Name.." had no base data.")
				end
			else
				return false
			end

			local CrysValue = Instance.new("IntValue",Player)
			CrysValue.Name = "Crystals"
			CrysValue.Value = Crystals

	--		MiscData = MiscStore:GetAsync("MiscStore"..Player.userId)
			local MiscData
			MiscStore:UpdateAsync("MiscStore"..Player.userId,function(Value)
				MiscData = Value
			end)

			--[[
			InventoryStore:UpdateAsync("InventoryStore"..Player.userId, function(savedValue)
				InvData = savedValue
				if InvData ~= nil then
					MoneyData = InvData[1]
					Data = InvData[2]
				end
				return nil
			end)
			local MiscData
			MiscStore:UpdateAsync("MiscStore"..Player.userId, function(savedValue)
				MiscData = savedValue
				return nil
			end)
			local BaseData

			BaseStore:UpdateAsync("BaseStore"..Player.userId, function(savedValue)

				if savedValue then
					BaseData = savedValue
				end
				return nil
			end)
			]]

			--local Data = InventoryStore:GetAsync(Player.userId)
			if Data ~= nil and Data ~= {} then
				_G["Inventory"][Player.Name] = Data
			--	local Inventory = _G["Inventory"][Player.Name]
			else
				_G["Inventory"][Player.Name] = {}
				local Inventory = _G["Inventory"][Player.Name]
				Inventory[1] = {Quantity = 4}
				Inventory[2] = {Quantity = 1}
				Inventory[3] = {Quantity = 10}
				Inventory[21] = {Quantity = 1}
				Inventory[22] = {Quantity = 1}
				Inventory[36] = {Quantity = 3}
			end
			local Cash = Instance.new("NumberValue")
			Cash.Name = Player.Name

				if MoneyData == nil then
					MoneyData = 500
				end

				if MoneyData < 0 then
					MoneyData = 0.1
				end

				if MoneyData == 0 then
					MoneyData = 500
				end

				if Player.Name == "IsInGroup" then
					MoneyData = require(game.ReplicatedStorage.MoneyLib).ShortToLong("666DD")
				end

				Cash.Value = MoneyData


			Cash.Parent = game.ServerStorage.MoneyStorage
			for i,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
				if not _G["Inventory"][Player.Name][i] or _G["Inventory"][Player.Name][i] == nil then
					_G["Inventory"][Player.Name][i] = {Quantity = nil}
				end
			end
			for i,v in pairs(_G["Inventory"][Player.Name]) do
				if v.Quantity and v.Quantity <= 0 then
					v.Quantity = nil
				end
			end

			print(Player.Name.."'s Inventory loaded")
			print("Attempting to load "..Player.Name.."'s base...")

			local PlayerDrops
			if workspace.DroppedParts:FindFirstChild(Tycoon.Name) == nil then
				PlayerDrops = Instance.new("Folder",workspace.DroppedParts)
				PlayerDrops.Name = Tycoon.Name
			else
				PlayerDrops = workspace.DroppedParts:FindFirstChild(Tycoon.Name)
			end

			local PlayerData = Instance.new("ObjectValue",game.ReplicatedStorage.PlayerData)
			PlayerData.Value = Tycoon
			PlayerData.Name = Tycoon.Name

			-- Ore limit loading
			local DropCount = Instance.new("IntValue",PlayerData)
			DropCount.Name = "DropCount"

			local DropLimit = Instance.new("IntValue",PlayerData)
			DropLimit.Name = "DropLimit"

			local DropLevel = Instance.new("IntValue",PlayerData)
			DropLevel.Name = "DropLevel"

			if MiscData ~= nil and MiscData.DropLevel ~= nil then
				DropLimit.Value = 50 + 25*(MiscData.DropLevel-1)
				if Player:FindFirstChild("Premium") then
					DropLimit.Value = DropLimit.Value + 25
				end
				DropLevel.Value = MiscData.DropLevel
			else
				DropLimit.Value = 50
				DropLevel.Value = 1
			end

			-- Kill loading
			--[[
			if MiscData ~= nil and MiscData.Kills ~= nil then
				spawn(function()
					Player:WaitForChild("leaderstats"):WaitForChild("Kills")
					Player.leaderstats.Kills.Value = MiscData.Kills
				end)
			end
			]]
			-- Gamepad tutorial state loading
			local TutorialStat = Instance.new("BoolValue")
			TutorialStat.Name = "GamepadTutorial"
			if MiscData ~= nil and MiscData.GamepadTutorial ~= nil then
				TutorialStat.Value = MiscData.GamepadTutorial
			else
				TutorialStat.Value = false
			end
			TutorialStat.Parent = Player


			-- More stuff
			DropLevel.Changed:connect(function()
				DropLimit.Value = 50 + 25*(DropLevel.Value-1)
			end)

			local Producing = Instance.new("BoolValue",Tycoon)
			Producing.Name = "Producing"
			Producing.Value = true

			DropCount.Changed:connect(function()
				if DropCount.Value >= DropLimit.Value then
					Producing.Value = false
				else
					Producing.Value = true
				end
			end)

			PlayerDrops.ChildAdded:connect(function()
				DropCount.Value = #PlayerDrops:GetChildren()
			end)

			PlayerDrops.ChildRemoved:connect(function()
				DropCount.Value = #PlayerDrops:GetChildren()
			end)

		-- Rebirth info

		--	local Rebirth = Storage:GetAsync(Player.userId) or 0

			local Rebirth
			Storage:UpdateAsync(Player.userId,function(Value)
				Rebirth = Value or 0
			end)


			local RebirthValue = Instance.new("IntValue",Player)
			RebirthValue.Name = "Rebirths"
			RebirthValue.Value = Rebirth
			local Life = RebirthValue.Value + 1
			spawn(function()
				Player:WaitForChild("leaderstats"):WaitForChild("Life")
				Player.leaderstats.Life.Value = tostring(Life)..HandleLife(Life)
			end)
			if Rebirth >= 4 then
				game.ServerStorage.AwardBadge:Invoke(Player,258842557)
			end

			-- Success tag

			wait(2)

			local SuccessTag = Instance.new("BoolValue")
			SuccessTag.Name = "BaseDataLoaded"
			SuccessTag.Parent = Player

			game.ReplicatedStorage.DataLoadedIn:FireClient(Player)

			while wait(60) do
				if Player ~= nil and Player.Parent == game.Players and getTycoon(Player) ~= nil and not Closing then
					SaveData(Player)
				else
					break
				end
			end
		end
	end
end
game.ReplicatedStorage.LoadedIn.OnServerEvent:connect(PlayerAdded)
--[[
game.Players.PlayerAdded:connect(PlayerAdded)
for i,v in pairs(game.Players:GetPlayers()) do
	PlayerAdded(v)
end
]]

game.Players.PlayerRemoving:connect(function(Player)
	if not Closing then
		local savesuccess,saveerror = pcall(function() SaveData(Player) end)
		if not savesuccess then
			warn(saveerror)
			game.ReplicatedStorage.Error:FireAllClients(saveerror)
		end
		local Tycoon = getTycoon(Player)
		spawn(function()
			if Tycoon ~= nil then
				Tycoon.Owner.Value="SAVINGSAVINGSAVINGSAVING"

				for i,v in pairs(Tycoon:GetChildren()) do
					if v:IsA("Model") or v:IsA("BoolValue") then
						v:Destroy()
					end
				end

				local Parts = workspace.DroppedParts:FindFirstChild(Tycoon.Name)
				if Parts then
					Parts:ClearAllChildren()
				end
				local Values = game.ReplicatedStorage.PlayerData:FindFirstChild(Tycoon.Name)
				if Values then
					Values:Destroy()
				end
				wait(0.3)
				Tycoon.Owner.Value=""
			else
				warn("Player left without tycoon being identified")
				game.ReplicatedStorage.Error:FireAllClients("CRIT: Player left without tycoon being identified")
				for i,v in pairs(workspace.Tycoons:GetChildren()) do -- Safeguard
					if v.Owner.Value ~= "SAVINGSAVINGSAVINGSAVING" and game.Players:FindFirstChild(v.Owner.Value) == nil then
						for e,o in pairs(v:GetChildren()) do
							if o:IsA("Model") or o:IsA("BoolValue") then
								o:Destroy()
							end
						end
					end
				end
			end
		end)
		local Cash = game.ServerStorage.MoneyStorage:FindFirstChild(Player.Name)
		if Cash then
			Cash:Destroy()
		end
	end
end)
--[[
spawn(function()
	local waitindex
	if game.PlaceId == 258258996 or game.PlaceId == 236204280 then
		waitindex = 90
	else
		waitindex = 60
	end

	while wait(waitindex) do
		if not Closing then
			for i,v in pairs(game.Players:GetChildren()) do
				SaveData(v)
			end
		end
	end
end)
]]
function game.ReplicatedStorage.RequestSave.OnServerInvoke(Player)
	SaveData(Player)
end

function game.ReplicatedStorage.SavePlayer.OnInvoke(Player)
	SaveData(Player)
end

local ShopLib = require(game.ReplicatedStorage.ShopControl)


