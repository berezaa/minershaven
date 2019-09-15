local Saving = {}

local self = game.ServerScriptService.Saving

local DataStorage = game:GetService("DataStoreService"):GetDataStore("PlayerData")

local function GetMostRecentSaveTime(OrderedStore)
	local pages = OrderedStore:GetSortedAsync(false, 1)
	for _, Pair in pairs(pages:GetCurrentPage()) do
		return Pair.value
	end
	--return pages:GetCurrentPage()[1].Value
end

function Saving.LoadData(Player, Slot)
	local Data
	local Success, Error = pcall(function()

		--[[
		local ExistingData = self.PlayerData:FindFirstChild(tostring(Player.userId))
		if ExistingData then
			ExistingData:Destroy()
		end
		]]

		if Slot ~= 1 and Slot ~= 2 and Slot ~= 3 then
			error("WARNING: INVALID SLOT (LOADING)")
			return false
		end

		local Suffix = ""

		if Slot == 2 then
			Suffix = "-two"
		elseif Slot == 3 then
			Suffix = "-three"
		end

		local OrderedStore = game:GetService("DataStoreService"):GetOrderedDataStore(tostring(Player.userId),"PlayerSaveTimes2"..Suffix)
		OrderedStore:SetAsync("Default",1)

		local LastSave = GetMostRecentSaveTime(OrderedStore)

		if LastSave > 1 then
			print(LastSave)
			print("Loading "..Player.Name.." data from new format")
			local DataStore = game:GetService("DataStoreService"):GetDataStore(tostring(Player.userId),"PlayerData2"..Suffix)
			Data = DataStore:GetAsync(tostring(LastSave))
			if Data ~= nil then
				print("Success")
			else
				print("Not found")
			end
		elseif Slot == 1 then -- Legacy only exists on slot 1
			local DatData = game:GetService("DataStoreService"):GetDataStore("WatUpDatData")
			print("Loading "..Player.Name.." data from old format")
			Data = DataStorage:GetAsync(Player.userId)
			if Data ~= nil then
				print("Success")
			else
				print("Not found")
			end
		end
	end)
	return Success, Data, Error
end

function Saving.SaveData(Player, Data, Slot)

	local Success, Error = pcall(function()
		local TimeStamp = os.time()

		if Slot ~= 1 and Slot ~= 2 and Slot ~= 3 then
			error("WARNING: INVALID SLOT (LOADING)")
			return false
		end

		local Suffix = ""
		if Slot == 2 then
			Suffix = "-two"
		elseif Slot == 3 then
			Suffix = "-three"
		end

		local OrderedStore = game:GetService("DataStoreService"):GetOrderedDataStore(tostring(Player.userId),"PlayerSaveTimes2"..Suffix)
		local DataStore = game:GetService("DataStoreService"):GetDataStore(tostring(Player.userId),"PlayerData2"..Suffix)
		DataStore:SetAsync(tostring(TimeStamp),Data)
		OrderedStore:SetAsync("s"..tostring(TimeStamp),TimeStamp)
	end)
	return Success, Error
end

return Saving
