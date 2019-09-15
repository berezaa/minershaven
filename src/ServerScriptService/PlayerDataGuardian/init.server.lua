-- Player Data Guardian



local LegacyInventoryStore = game:GetService("DataStoreService"):GetDataStore("Inventory20")
local LegacyBaseStore = game:GetService("DataStoreService"):GetDataStore("BaseLayout4")
local LegacyMiscStore = game:GetService("DataStoreService"):GetDataStore("MiscStore6")
local LegacyRebirthStore = game:GetService("DataStoreService"):GetDataStore("RebirthData")

local Closing = false

local DataLib = require(script.DataLib)

local Saving = require(script.Parent.Saving)

local MoneyLib = require(game.ReplicatedStorage.MoneyLib)

local Tags = require(script.FastVals)



local function SaveData(Player)

	local Rewards = {}
	local Success = false
	local Error

	if Player:FindFirstChild("CriticalError") then
		return false
	end

	local Slot = nil
	if Player:FindFirstChild("DataSlot") then
		Slot = Player.DataSlot.Value
	else
		error("INVALID SAVE SLOT")
		return false
	end

	if Player ~= nil and Player:FindFirstChild("BaseDataLoaded") and Player:FindFirstChild("PlayerData") then
		local Tycoon = DataLib.GetTycoon(Player)
		local PlayerData = require(Player.PlayerData)
		if Tycoon and PlayerData then

			if Tycoon:FindFirstChild("SpecialMusic") then
				PlayerData.SpecialMusic = Tycoon.SpecialMusic.Value
			end

			if Player:FindFirstChild("UpdateScreen") then
				PlayerData.UpdateScreen = Player.UpdateScreen.Value
			end

			if Player:FindFirstChild("Layouts") then
				PlayerData.Layouts = PlayerData.Layouts or {}
				for i,Layout in pairs(Player.Layouts:GetChildren()) do
					PlayerData.Layouts[Layout.Name] = Layout.Value
				end
			end

			if (PlayerData.Nebulaaa == nil or PlayerData.Nebulaaa == false) and Rewards["Nebulaaa"] == nil then
				if Player:FindFirstChild("Nebula") then
					Rewards["Nebulaaa"] = true
					PlayerData.Nebulaaa = true
					Player.Crystals.Value = Player.Crystals.Value + 500
					game.ReplicatedStorage.CurrencyPopup:FireClient(Player, "500 uC", Color3.fromRGB(255, 216, 217), "rbxassetid://1028723613")
					local Message = "The Ore Nebula set is now obtainable from the Masked Man. You've been granted 500 uC for purchasing the original gamepass."
					game.ReplicatedStorage.Prompt:FireClient(Player,Message)
					local ProductName = "nebula"
					game.ServerStorage.CurrencyEvent:Fire(Player, "Crystals", 500, "refund", ProductName)
				end
			end

			if (PlayerData.BerToyAwarded == nil or PlayerData.BerToyAwarded == false) and Rewards["BerToy"] == nil then
				if Player:FindFirstChild("BerToy") then
					Rewards["BerToy"] = true
					PlayerData.BerToyAwarded = true
					game.ReplicatedStorage.Hint:FireClient(Player,"Here's a cool item to match your cool berezaa toy!")
					game.ServerStorage.AwardItem:Invoke(Player,468,1)
				end
			end
			--[[
			if (PlayerData.PizzaAwarded == nil or PlayerData.PizzaAwarded == false) and Rewards["Pizza"] == nil then
				if true then
					Rewards["Pizza"] = true
					PlayerData.PizzaAwarded = true
					game.ServerStorage.AwardItem:Invoke(Player,569,1)
				end
			end
			]]

			if (PlayerData.VesterianAwarded == nil or PlayerData.VesterianAwarded == false) and Rewards["Vesterian"] == nil then
				if Player:FindFirstChild("Vesterian") then
					Rewards["Vesterian"] = true
					PlayerData.VesterianAwarded = true
					game.ServerStorage.AwardItem:Invoke(Player,568,1)
				end
			end

			if PlayerData.FoolAwarded == nil or PlayerData.FoolAwarded == false and Rewards["Fool"] == nil then
				if Player:FindFirstChild("Fool") then
					Rewards["Fool"] = true
					PlayerData.FoolAwarded = true
					game.ReplicatedStorage.Hint:FireClient(Player,"Here's your reward for beating Miner's Haven 2:")
					game.ServerStorage.AwardItem:Invoke(Player,388,3)
				end
			end

			if PlayerData.FrogAwarded == nil or PlayerData.FrogAwarded == false and Rewards["Frog"] == nil then
				if Player:FindFirstChild("LoneFrog") then
					Rewards["Frog"] = true
					PlayerData.FrogAwarded = true
					game.ServerStorage.AwardItem:Invoke(Player,490,2)
					game.ServerStorage.AwardItem:Invoke(Player,491,2)
				end
			end
			if PlayerData.CircusAwarded == nil or PlayerData.CircusAwarded == false and Rewards["Circus"] == nil then
				if Player:FindFirstChild("CircusTent") then
					Rewards["Circus"] = true
					PlayerData.CircusAwarded = true
					game.ServerStorage.AwardItem:Invoke(Player,488,2)
					game.ServerStorage.AwardItem:Invoke(Player,489,4)
				end
			end
			if PlayerData.PearlAwarded == nil or PlayerData.PearlAwarded == false and Rewards["Pearl"] == nil then
				if Player:FindFirstChild("CursedPearl") then
					Rewards["Pearl"] = true
					PlayerData.PearlAwarded = true
					game.ServerStorage.AwardItem:Invoke(Player,487,2)
				end
			end

			--RbxDev


			if PlayerData.RbxDevAwarded == nil or PlayerData.RbxDevAwarded == false and Rewards["RbxDev"] == nil then
				if Player:FindFirstChild("RbxDev") then
					Rewards["RbxDev"] = true
					PlayerData.RbxDevAwarded = true
					game.ReplicatedStorage.Hint:FireClient(Player,"Welcome to Miner's Haven, RbxDev member!")
					game.ServerStorage.AwardItem:Invoke(Player,447,1)
				end
			end

			-- AddictedMiner

			if PlayerData.AddictedMinerAwarded == nil or PlayerData.AddictedMinerAwarded == false and Rewards["AddictedMiner"] == nil then
				if Player:FindFirstChild("AddictedMiner") then
					Rewards["AddictedMiner"] = true
					PlayerData.AddictedMinerAwarded = true
					game.ServerStorage.AwardItem:Invoke(Player,448,1)
				end
			end

			if PlayerData.KnowledgeAwarded == nil or PlayerData.KnowledgeAwarded == false and Rewards["Knowledge"] == nil then
				if Player:FindFirstChild("Badge1055729351") then
					Rewards["Knowledge"] = true
					PlayerData.KnowledgeAwarded = true
					game.ServerStorage.AwardItem:Invoke(Player,461,1)
				end
			end

			if PlayerData.SacrificeAwarded == nil or PlayerData.SacrificeAwarded == false and Rewards["Sacrifice"] == nil then
				if Player:FindFirstChild("Sacrificed") then
					Rewards["Sacrifice"] = true
					PlayerData.SacrificeAwarded = true
					game.ServerStorage.AwardItem:Invoke(Player,382,10)
				end
			end

			if PlayerData.SubAwarded == nil or PlayerData.SubAwarded == false and Rewards["Sub"] == nil then
				if Player:FindFirstChild("Submitter") then
					Rewards["Sub"] = true
					PlayerData.SubAwarded = true
					game.ServerStorage.AwardItem:Invoke(Player,356)
					Player.Crates.Inferno.Value = Player.Crates.Unreal.Value + 5
					game.ReplicatedStorage.Hint:FireClient(Player,"Congrats on being an Official Submitter! (5 Unreal awarded)")
				end
			end

			if PlayerData.ExecAwarded == nil or PlayerData.ExecAwarded == false and Rewards["Exec"] == nil then
				if Player:FindFirstChild("Executive") then
					Rewards["Exec"] = true
					PlayerData.ExecAwarded = true
					game.ServerStorage.AwardItem:Invoke(Player,243)
					game.ServerStorage.AwardItem:Invoke(Player,265)
					Player.Crates.Inferno.Value = Player.Crates.Inferno.Value + 5
					game.ReplicatedStorage.Hint:FireClient(Player,"Thanks for buying exec! 5 free Infernos awarded!")
					local Box = game.ReplicatedStorage.Boxes.Inferno
					game.ReplicatedStorage.CurrencyPopup:FireClient(Player,"5 "..Box.Name.." Box",Box.BoxColor.Value,"rbxassetid://"..Box.ThumbnailId.Value)
				end
			end

			if PlayerData.IslandAwarded == nil or PlayerData.IslandAwarded == false and Rewards["Island"] == nil then
				if game.VIPServerOwnerId == Player.userId then
					Rewards["Island"] = true
					PlayerData.IslandAwarded = true
					Player.Crates.Unreal.Value = Player.Crates.Unreal.Value + 3
					Player.Crystals.Value = Player.Crystals.Value + 100
					-- Game Analytics Currency Reporting
					local CrystalsGained = 100
					local ProductName = "vipserver"
					if true then
						ProductName = ProductName or "unknown"
						game.ServerStorage.CurrencyEvent:Fire(Player, "Crystals", CrystalsGained, "granted", ProductName)
					end
					-- Game Analytics Currency Reporting
					game.ReplicatedStorage.Hint:FireClient(Player,"Welcome to your VIP server. Enjoy these free perks:")
					game.ServerStorage.AwardItem:Invoke(Player,125,1)
					game.ReplicatedStorage.Hint:FireClient(Player,"100 uC Credited.")
					game.ReplicatedStorage.Hint:FireClient(Player,"3 Unreal Boxes Credited.")

					local Box = game.ReplicatedStorage.Boxes.Unreal
					game.ReplicatedStorage.CurrencyPopup:FireClient(Player,"3 "..Box.Name.." Box",Box.BoxColor.Value,"rbxassetid://"..Box.ThumbnailId.Value)

				end
			end

			if PlayerData.SwordGhost == nil or PlayerData.SwordGhost == false and Rewards["SwordGhost"] == nil then
				if Player:FindFirstChild("SwordMaster") then
					Rewards["SwordGhost"] = true
					PlayerData.SwordGhost = true

					game.ReplicatedStorage.Hint:FireClient(Player,"Sorry sword master became useless. Here's something to make up for that -ber")
					game.ServerStorage.AwardItem:Invoke(Player,298)


				end
			end

			if PlayerData.IslandRefund == nil or PlayerData.IslandRefund == false and Rewards["IslandRefund"] == nil then
				if Player:FindFirstChild("MultiIsland") then
					Rewards["IslandRefund"] = true
					PlayerData.IslandRefund = true

					Player.Crystals.Value = Player.Crystals.Value + 350
					-- Game Analytics Currency Reporting
					local CrystalsGained = 100
					local ProductName = "islandrefund"
					if true then
						ProductName = ProductName or "unknown"
						game.ServerStorage.CurrencyEvent:Fire(Player, "Crystals", CrystalsGained, "granted", ProductName)
					end
					-- Game Analytics Currency Reporting

					game.ReplicatedStorage.Hint:FireClient(Player,"Multiplayer Island Gamepass refunded: 350 crystals")


					Player.Crates.Inferno.Value = Player.Crates.Inferno.Value + 1

					game.ReplicatedStorage.Hint:FireClient(Player,"Sorry that took so long. Here's a free inferno too.")

				end
			end

			-- Save money
			local Money = game.ServerStorage.MoneyStorage:FindFirstChild(Player.Name)
			local FinalMoneyVal = "0"
			if Money and Money.Value > 10^200 then
				Money.Value = 10^200
			end
			if Money then
				FinalMoneyVal = tostring(Money.Value)
			end

			if string.len(FinalMoneyVal) > 100 then
				FinalMoneyVal = "0"
			end

			-- SAVE TWITTER CODES
			local TwitterData = _G["Twitter"][Player.Name]
			if TwitterData then
				PlayerData.SecretCodes = TwitterData
			end

			PlayerData.Money = FinalMoneyVal
			-- Save inventory
			if _G["Inventory"][Player.Name] ~= nil and _G["Inventory"][Player.Name] ~= {} then
				PlayerData.Inventory = _G["Inventory"][Player.Name]
			end
			if _G["Safekeeping"][Player.Name] ~= nil and _G["Safekeeping"][Player.Name] ~= {} then
				PlayerData.Safekeeping = _G["Safekeeping"][Player.Name]
			end



			--SACRIFICE TAG
			if Player:FindFirstChild("Sacrificed") then
				PlayerData.Sacrifice = true
			end

			if Player:FindFirstChild("SecondSacrifice") then
				PlayerData.SecondSacrifice = true
			end

			-- Make settings real ez
			PlayerData.PlayerSettings = PlayerData.PlayerSettings or {}
			if Player:FindFirstChild("PlayerSettings") then
				for i,Setting in pairs(Player.PlayerSettings:GetChildren()) do
					PlayerData.PlayerSettings[Setting.Name] = Setting.Value
				end
			end

			if Player:FindFirstChild("LastGift") then
				PlayerData.LastGift = Player.LastGift.Value
			end
			if Player:FindFirstChild("LoginStreak") then
				PlayerData.LoginStreak = Player.LoginStreak.Value
			end

			-- Save crystals
			if Player:FindFirstChild("Megaphones") then
				PlayerData.Megaphones = Player.Megaphones.Value
			end
			if Player:FindFirstChild("Crystals") then
				PlayerData.Crystals = Player.Crystals.Value
			end
			if Player:FindFirstChild("TwitchPoints") then
				PlayerData.TwitchPoints = Player.TwitchPoints.Value
			end
			if Player:FindFirstChild("Pumpkins") then
				PlayerData.Pumpkins = Player.Pumpkins.Value
			end
			if Player:FindFirstChild("Boxman") then
				PlayerData.Boxman = Player.Boxman.Value
			end
			if Player:FindFirstChild("Santa") then
				PlayerData.Santa = Player.Santa.Value
			end
			if Player:FindFirstChild("DiscordAward") then
				PlayerData.DiscordAward = Player.DiscordAward.Value
			end

			if Player:FindFirstChild("EasterEggs") then
				PlayerData.EasterEggs = Player.EasterEggs.Value
			end

			if Player:FindFirstChild("TrialMode") then
				PlayerData.TrialMode = Player.TrialMode.Value
			end

			if Player:FindFirstChild("EventStage") then
				PlayerData.EventStage = Player.EventStage.Value
			end

			if PlayerData.EventStage == 2 then
				spawn(function()
					local Success, Error = pcall(function()
						game:GetService("BadgeService"):AwardBadge(Player.userId, 684166979)
					end)
					if Success then
						Player.EventStage.Value = 3
						PlayerData.EventStage = 3
					end
				end)
			end

			-- Save base
			local BaseData = DataLib.TycoonToTable(Tycoon) --DataLib.TycoonToTable(Tycoon)
			if BaseData ~= nil then
				PlayerData.Base = BaseData
			else
				print("IDK WHAT TO DO MAN")
			end
			-- Save DropLevel
			local TycoonInfo = game.ReplicatedStorage.PlayerData:FindFirstChild(Tycoon.Name)
			if TycoonInfo ~= nil and TycoonInfo.DropLevel ~= nil then
				PlayerData.DropLevel = TycoonInfo.DropLevel.Value
			end
			-- Save SeenTutorial
			if Player:FindFirstChild("GamepadTutorial") then
				PlayerData.SeenTutorial = Player.GamepadTutorial.Value
			end
			-- Save Rebirths
			if Player:FindFirstChild("Rebirths") then
				PlayerData.Rebirths = Player.Rebirths.Value
			end
			--[[
			if Player:FindFirstChild("Crates") then
				PlayerData.RegularBox = Player.Crates.Regular.Value
				PlayerData.UnrealBox = Player.Crates.Unreal.Value
				PlayerData.InfernoBox = Player.Crates.Inferno.Value
			end
			]]
			PlayerData.Boxes = PlayerData.Boxes or {}
			for i,Box in pairs(game.ReplicatedStorage.Boxes:GetChildren()) do
				local Val = Player.Crates:FindFirstChild(Box.Name)
				if Val then
					PlayerData.Boxes[Box.Name] = Val.Value
				end
			end

			if Player:FindFirstChild("BaseSize") then
				PlayerData.BaseSize = Player.BaseSize.Value
			end

			if Player:FindFirstChild("Clovers") then
				PlayerData.Clovers = Player.Clovers.Value
			end
			if Player:FindFirstChild("GoldClovers") then
				PlayerData.GoldClovers = Player.GoldClovers.Value
			end

			if Player:FindFirstChild("ChatVisible") then
				PlayerData.ChatVisible = Player.ChatVisible.Value
			end
			if Player:FindFirstChild("UseClover") then
				PlayerData.UseClover = Player.UseClover.Value
			end

			if Player:FindFirstChild("UseTwitch") then
				PlayerData.UseTwitch = Player.UseTwitch.Value
			end

			if Player:FindFirstChild("RadioMode") then
				PlayerData.RadioMode = Player.RadioMode.Value
			end
			if Player:FindFirstChild("RadioVolume") then
				PlayerData.RadioVolume = Player.RadioVolume.Value
			end

			if Player:FindFirstChild("MOTD") then
				PlayerData.MOTD = Player.MOTD.Value
			end

			if Player:FindFirstChild("AverageIncome") then
				if Player.AverageIncome.Value > 10^100 then
					Player.AverageIncome.Value = 10^100
				end
				PlayerData.Income = Player.AverageIncome.Value
			end

			for i,Tag in pairs(Tags) do
				local Real = Player:FindFirstChild(Tag.Name)
				if Real then
					PlayerData["FTag"..Tag.Name] = Real.Value
				end
			end

			PlayerData.TimeStamp = os.time()

			Success, Error = Saving.SaveData(Player, PlayerData, Slot)

			if not Success then
				game.ServerStorage.ReportEvent:Invoke(Player, "savingerror",1)
				game.ReplicatedStorage.Error:FireClient(Player,"Error saving data: "..Error)
				print("Error saving "..Player.Name.."'s data: "..Error)
			end
		else
			print("Failed to save data")
		end
	end
	return Success, Error
end

function GetSum(Crates)
	local Total = 0
	for i,v in pairs(Crates:GetChildren()) do
		Total = Total + v.Value
	end
	return Total
end

local function QuickLoad(Player,Slot)

	if Player:FindFirstChild("BaseDataLoaded") then
		return false
	end

	if Player:FindFirstChild("LoadRequests") then
		if Player.LoadRequests.Value > 5 then
			return false
		end
	else
		local Tag = Instance.new("IntValue")
		Tag.Name = "LoadRequests"
		Tag.Parent = Player
	end

	local Success, PlayerDataRaw, Error = Saving.LoadData(Player, Slot)

	if Success then
		game.ServerStorage.ReportEvent:Invoke(Player, "quicklock:success",1)
		local SaveString = "nil"

		if PlayerDataRaw ~= nil then
			SaveString = game.HttpService:JSONEncode(PlayerDataRaw)
		end
		--[[
		local Tag = Instance.new("StringValue")
		Tag.Name = "DataSaveSlot"..tostring(Slot)
		Tag.Value = SaveString
		Tag.Parent = Player
		]]

		local Tag = Instance.new("BindableFunction")
		Tag.Name = "DataSaveSlot"..tostring(Slot)
		Tag.OnInvoke = function()
			return SaveString
		end
		Tag.Parent = Player

		-- temp precaution for transporting
		if PlayerDataRaw then
			PlayerDataRaw.Base = {}
		end

		Player.LoadRequests.Value = Player.LoadRequests.Value -- only count successful requests
	else
		game.ServerStorage.ReportEvent:Invoke(Player, "quicklock:fail",1)
		Error = Error or "Unknown error quickloading save file"
		game.ServerStorage.ReportError:Fire(Player, "error", Error)

	end

	return Success, PlayerDataRaw
end

game.ReplicatedStorage.QuickLoad.OnServerInvoke = QuickLoad



local function LoadPlayerData(Player,Slot)

	if Player:FindFirstChild("CurrentlyLoadingData") then
		return false
	end

	if Player:FindFirstChild("BaseDataLoaded") then
		return false
	end

	if Player:FindFirstChild("CriticalError") then
		return false
	end


	local currentTag = Instance.new("BoolValue")
	currentTag.Name = "CurrentlyLoadingData"
	currentTag.Parent = Player

	print("SLOT: "..tostring(Slot))

	local SlotTag = Instance.new("IntValue")
	SlotTag.Name = "DataSlot"
	SlotTag.Value = Slot
	SlotTag.Parent = Player
--[[
	if game.ReplicatedStorage.Waitlist:FindFirstChild(Player.Name) then
		return false
	else
		local Tag = Instance.new("BoolValue")
		Tag.Name = Player.Name
		Tag.Parent = game.ReplicatedStorage.Waitlist
	end

	local Success, PlayerDataRaw, Error = Saving.LoadData(Player, Slot)
]]
	local Error = "none"
	local Success = false
	local DataTag = Player:FindFirstChild("DataSaveSlot"..tostring(Slot))
	local PlayerDataRaw

	if DataTag then
		local Value = DataTag:Invoke()
		if Value then
			Success = true
			if Value ~= "nil" then
				PlayerDataRaw = game.HttpService:JSONDecode(Value)
			end
		end
	else
		Error = "Cant find lol"
	end
	if Success then

		local PlayerDataFormat = game.ReplicatedStorage.PlayerDataFormat:Clone()
		PlayerDataFormat.Name = "PlayerData"
		PlayerDataFormat.Parent = Player
		local PlayerData = require(PlayerDataFormat)

		if PlayerDataRaw == nil then -- No data saved with new system. Check for legacy data (if slot ==1) or assume new player
			print("Legacy")
			local LegacyInventory = (Slot == 1 and LegacyInventoryStore:GetAsync("InventoryStore"..Player.userId)) or nil
			LegacyInventory = LegacyInventory or {}
			PlayerData.Money = LegacyInventory[1] or "500" 		-- PlayerData.Money
			PlayerData.Inventory = LegacyInventory[2]   	-- PlayerData.Inventory
			PlayerData.Crystals = LegacyInventory[3] or 0		 -- PlayerData.Crystals
			PlayerData.RadioMode = PlayerData.RadioMode or 2 -- start people on that good vibe music
			PlayerData.RadioVolume = PlayerData.RadioVolume or 0.2
			PlayerData.EasterEggs = PlayerData.EasterEggs or 0
			PlayerData.TrialMode = PlayerData.TrialMode or ""
			PlayerData.DiscordAward = PlayerData.DiscordAward or 0
			PlayerData.EventStage = PlayerData.EventStage or 0
			local LegacyBase = (Slot == 1 and LegacyBaseStore:GetAsync("BaseStore"..Player.userId)) or nil
			PlayerData.Base = LegacyBase	 -- PlayerData.Base
			local LegacyMisc = (Slot == 1 and LegacyMiscStore:GetAsync("MiscStore"..Player.userId)) or nil
			LegacyMisc = LegacyMisc or {}
			PlayerData.DropLevel = LegacyMisc.DropLevel or 1 -- PlayerData.DropLevel
			PlayerData.SeenTutorial = LegacyMisc.GamepadTutorial or false -- PlayerData.SeenTutorial
			local LegacyRebirths = (Slot == 1 and LegacyRebirthStore:GetAsync(Player.userId)) or nil
			LegacyRebirths = LegacyRebirths or 0
			PlayerData.Rebirths = LegacyRebirths --PlayerData.Rebirths

			local Newp = Instance.new("BoolValue")
			Newp.Name = "NewPlayer"
			Newp.Parent = Player
			game.ReplicatedStorage.NewPlayer:FireClient(Player)

		else -- Transfer
			for Index,Value in pairs(PlayerDataRaw) do
				PlayerData[Index] = Value
			end
		end

		local Tycoon = DataLib.GetTycoon(Player)

		local UpdateScreen = Instance.new("BoolValue")
		UpdateScreen.Name = "UpdateScreen"
		UpdateScreen.Parent = Player
		UpdateScreen.Value = PlayerData.UpdateScreen or false

		local BaseSize = Instance.new("IntValue")
		BaseSize.Name = "BaseSize"
		BaseSize.Value = PlayerData.BaseSize or 168
		BaseSize.Parent = Player

		local function resizeBase(NewSize)
			if NewSize < 168 then
				NewSize = 168
			elseif NewSize > 186 then
				NewSize = 186
			end
			local Tycoon = Player.PlayerTycoon.Value
			if Tycoon then
				local Bases = {}
				table.insert(Bases,Tycoon.Base)
				table.insert(Bases,Tycoon.Base.FakeBase)
				table.insert(Bases,workspace.FakeBases:FindFirstChild(Tycoon.Name))
				for i,Base in pairs(Bases) do
					local CF = Base.CFrame
					local Size = Base.Size
					Base.Size = Vector3.new(NewSize, Size.Y, NewSize)
					Base.CFrame = CF
				end
			end
		end

		local OldBaseSize = BaseSize.Value
		BaseSize.Changed:Connect(function()
			local NewSize = BaseSize.Value
			if NewSize > 186 then
				NewSize = 186
			end
			if NewSize > OldBaseSize then
				if (NewSize - OldBaseSize) % 6 == 0 then -- If it a change of 6, then we can apply it right away
					local OldArea = (OldBaseSize / 3) ^ 2
					local NewArea = (NewSize / 3) ^ 2
					local Difference = NewArea - OldArea
					resizeBase(NewSize)
					game.ReplicatedStorage.Hint:FireClient(Player,"The size of your base has increased by "..Difference .. " cells!")
				elseif (NewSize - OldBaseSize) % 3 == 0 then
					game.ReplicatedStorage.Hint:FireClient(Player,"Your base got bigger! Rejoin the game for it to go into effect.")
				else
					-- Reject it
					warn("Something tried to make "..Player.Name.."'s base a weird size!")
					NewSize = OldBaseSize
				end
			else
			--	warn("Something tried to make "..Player.Name.."'s base smaller!")
			--	NewSize = OldBaseSize
			end
			OldBaseSize = NewSize
			BaseSize.Value = NewSize
		end)

		if Player:FindFirstChild("Executive") and Player.BaseSize.Value ~= 186 then
			game.ReplicatedStorage.Hint:FireClient(Player,"Executive Base Size increase applied",nil,Color3.new(0.5,0,0),"Digital")
			BaseSize.Value = 186
		end

		if Tycoon then -- Begin loading data into the game
			-- Clear the tycoon before you load anything in to be safe
			for i,v in pairs(Tycoon:GetChildren()) do
				if v:IsA("Model") or v:IsA("BoolValue") then
					v:Destroy()
				end
			end

			-- Variable Base
			resizeBase(BaseSize.Value)

			--L
			--[[
			local function updateHydraulic(child)
				local adjustableHeight = child:FindFirstChild("AdjustableHeight",true)
				if adjustableHeight then
					for i,part in next,child.Model:GetChildren() do
						if part:IsA"BasePart" and part.Name == "Leg" then
							local hitbox = child.PrimaryPart
							local topOfLeg = part.Position + Vector3.new(0,part.Size.y*.5,0)
							local topVector = Vector3.FromNormalId(Enum.NormalId.Top)
							local rayBegin = topOfLeg + Vector3.new(0,hitbox.Size.y*.9,0)
							local r = Ray.new(rayBegin,-topVector*999)

							local whitelist = {}
							for i,v in next,Tycoon:GetChildren() do
								--if is the base or is a platform
								local isAPlatform = v.ClassName == "Model" and v ~= child and v:FindFirstChild("Platform") ~= nil
								if isAPlatform or v:IsA"BasePart" and v.Name == "Base" then
									whitelist[#whitelist+1] = v
								end
							end

							local _,intersect = workspace:FindPartOnRayWithWhitelist(r,whitelist)
							local totalSize = intersect and topOfLeg.y - intersect.y or .1
							totalSize = totalSize < .1 and .1 or totalSize

							part.Size = Vector3.new(part.Size.x,totalSize,part.Size.z)
							part.CFrame = CFrame.new(part.Position.x,topOfLeg.y - totalSize*.5,part.Position.z) * (part.CFrame - part.Position)
						end
					end
				end
			end
			]]--

			-- Load in the player's base
			if PlayerData.Base == nil then
				print(Player.Name.." had no base to load in, so a default base was loaded")
				PlayerData.Base = {}
				UpdateScreen.Value = true -- they get this by default
				for Key,Value in pairs(DataLib.DefaultBase) do
					PlayerData.Base[Key] = Value
				end
			end
			if PlayerData.Base ~= nil then
				local BaseLoadSuccess = DataLib.TableToTycoon(PlayerData.Base,Tycoon,Player)
				if BaseLoadSuccess then
					print(Player.Name.."'s base loaded in.")
				else
					print(Player.Name.."'s base failed to load in.")
					game.ReplicatedStorage.Error:FireClient(Player,"Base failed to load in")
					return false
				end
			else
				print("Player had no base to load in")
				game.ReplicatedStorage.Error:FireClient(Player,"No base data found")
			end

			if PlayerData.Safekeeping ~= nil then
				_G["Safekeeping"][Player.Name] = PlayerData.Safekeeping
			else
				_G["Safekeeping"][Player.Name] = {}
			end



			-- Load in the player's inventory
			if PlayerData.Inventory ~= nil and PlayerData.Inventory ~= {} then
				_G["Inventory"][Player.Name] = PlayerData.Inventory
			else -- First time inventory
				local Inventory = {}
				Inventory[1] = {Quantity = 4}
				Inventory[2] = {Quantity = 1}
				Inventory[3] = {Quantity = 10}
				Inventory[87] = {Quantity = 1}
				_G["Inventory"][Player.Name] = Inventory
			end
			-- Finish up the player's inventory
			for i,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
				if _G["Inventory"][Player.Name][i] == nil then
					_G["Inventory"][Player.Name][i] = {Quantity = nil}
				end
				if _G["Safekeeping"][Player.Name][i] == nil then
					_G["Safekeeping"][Player.Name][i] = {Quantity = nil}
				end
			end
			for i,v in pairs(_G["Inventory"][Player.Name]) do
				if v.Quantity and v.Quantity <= 0 then
					v.Quantity = nil
				end
			end
			for i,v in pairs(_G["Safekeeping"][Player.Name]) do
				if v.Quantity and v.Quantity <= 0 then
					v.Quantity = nil
				end
			end

			-- Load in the player's money
			local Money = Instance.new("NumberValue")

			local RealMon = tonumber(PlayerData.Money)

			if RealMon == nil or RealMon < 0 then -- don't let a player be bankrupt
				RealMon = 300
			end
			if RealMon > 10^200 then
				RealMon = 10^200
			end
			if not (RealMon == RealMon) then
				RealMon = 300
			end

			PlayerData.Money = RealMon

			Money.Value = RealMon
			Money.Name = Player.Name
			Money.Parent = game.ServerStorage.MoneyStorage

			Money.Changed:connect(function()
				if Money.Value > 10^300 then
					Money.Value = 10^300
				end
			end)
			-- BASE LAYOUTS
			local Layouts = Instance.new("Folder")
			Layouts.Name = "Layouts"
			PlayerData.Layouts = PlayerData.Layouts or {Layout1 = {},Layout2 = {},Layout3 = {}}
			for LayoutName,Layout in pairs(PlayerData.Layouts) do
				local Tag = Instance.new("StringValue")
				Tag.Name = LayoutName
				if type(Layout) == "table" then
					Tag.Value = game.HttpService:JSONEncode(Layout)
				elseif type(Layout) == "string" and Layout ~= "" then
					Tag.Value = Layout
				else
					Tag.Value = "[]"
				end

				Tag.Parent = Layouts
			end
			Layouts.Parent = Player

			-- EVENT STEEL
			local TrialMode	= Instance.new("StringValue")
			TrialMode.Name = "TrialMode"
			TrialMode.Value = PlayerData.TrialMode or ""
			TrialMode.Parent = Player

			local EasterEggs = Instance.new("IntValue")
			EasterEggs.Name = "EasterEggs"
			EasterEggs.Value = PlayerData.EasterEggs or 0
			EasterEggs.Parent = Player

			local EventStage = Instance.new("IntValue")
			EventStage.Name = "EventStage"
			EventStage.Value = PlayerData.EventStage or 0
			EventStage.Parent = Player

			local GoldClovers = Instance.new("IntValue")
			GoldClovers.Name = "GoldClovers"
			GoldClovers.Value = PlayerData.GoldClovers or 0
			GoldClovers.Parent = Player

			local DiscordAward = Instance.new("IntValue")
			DiscordAward.Name = "DiscordAward"
			DiscordAward.Value = PlayerData.DiscordAward or 0
			DiscordAward.Parent = Player

			if PlayerData.Sacrifice then
				local FiceTag = Instance.new("BoolValue")
				FiceTag.Name = "Sacrificed"
				FiceTag.Value = true
				FiceTag.Parent = Player
			end

			if PlayerData.SecondSacrifice then
				local FiceTag = Instance.new("BoolValue")
				FiceTag.Name = "SecondSacrifice"
				FiceTag.Value = true
				FiceTag.Parent = Player
			end
			--[[
			if Player:FindFirstChild("LastGift") then
				PlayerData.LastGift = Player.LastGift.Value
			end
			if Player:FindFirstChild("LoginStreak") then
				PlayerData.LoginStreak = Player.LoginStreak.Value
			end
			]]

			local LastGift = Instance.new("StringValue")
			LastGift.Name = "LastGift"
			LastGift.Value = PlayerData.LastGift or ""
			LastGift.Parent = Player

			local LoginStreak = Instance.new("IntValue")
			LoginStreak.Name = "LoginStreak"
			LoginStreak.Value = PlayerData.LoginStreak or 0
			LoginStreak.Parent = Player


			-- Load in twitter codes
			_G["Twitter"][Player.Name] = PlayerData.SecretCodes or {}


			-- Load in MOTD value
			local MOTD = Instance.new("IntValue")
			MOTD.Name = "MOTD"
			MOTD.Value = PlayerData.MOTD or 0
			MOTD.Parent = Player
			-- Load in the player's crystals
			local Crystals = Instance.new("NumberValue")
			Crystals.Name = "Crystals"
			Crystals.Value = PlayerData.Crystals or 0
			Crystals.Parent = Player

			local Megaphones = Instance.new("IntValue")
			Megaphones.Name = "Megaphones"
			Megaphones.Value = PlayerData.Megaphones or 0
			Megaphones.Parent = Player

			local TwitchPoints = Instance.new("NumberValue")
			TwitchPoints.Name = "TwitchPoints"
			TwitchPoints.Value = PlayerData.TwitchPoints or 0
			TwitchPoints.Parent = Player

			local Pumpkins = Instance.new("IntValue")
			Pumpkins.Name = "Pumpkins"
			Pumpkins.Value = PlayerData.Pumpkins or 0
			Pumpkins.Parent = Player

			local Boxman = Instance.new("IntValue")
			Boxman.Name = "Boxman"
			Boxman.Value = PlayerData.Boxman or 0
			Boxman.Parent = Player

			local Santa = Instance.new("IntValue")
			Santa.Name = "Santa"
			Santa.Value = PlayerData.Santa or 0
			Santa.Parent = Player

			local ChatVisible = Instance.new("BoolValue")
			ChatVisible.Name = "ChatVisible"
			ChatVisible.Value = (PlayerData.ChatVisible == nil and true) or PlayerData.ChatVisible
			ChatVisible.Parent = Player

			local UseClover = Instance.new("BoolValue")
			UseClover.Name = "UseClover"
			UseClover.Value = (PlayerData.UseClover == nil and true) or PlayerData.UseClover
			UseClover.Parent = Player

			local UseTwitch = Instance.new("BoolValue")
			UseTwitch.Name = "UseTwitch"
			UseTwitch.Value = (PlayerData.Twitch == nil and true) or PlayerData.UseTwitch
			UseTwitch.Parent = Player

			local RadioMode = Player:FindFirstChild("RadioMode")
			RadioMode.Value = PlayerData.RadioMode or 1

			local RadioVolume = Instance.new("NumberValue")
			RadioVolume.Name = "RadioVolume"
			RadioVolume.Value = PlayerData.RadioVolume or 0.2
			RadioVolume.Parent = Player


			for i,Tag in pairs(Tags) do
				local Real = Instance.new(Tag.Type)
				Real.Name = Tag.Name
				Real.Value = PlayerData["FTag"..Tag.Name] or Tag.Default
				Real.Parent = Player
			end

			if Tycoon:FindFirstChild("SpecialMusic") then
				Tycoon.SpecialMusic.Value = PlayerData.SpecialMusic or 0
			end


			-- Load player settings
			PlayerData.PlayerSettings = PlayerData.PlayerSettings or {}
			local Folder = script.StarterSettings:Clone()
			for i,Setting in pairs(Folder:GetChildren()) do
				local Val = PlayerData.PlayerSettings[Setting.Name]
				if Val ~= nil then
					Setting.Value = Val
				end
			end
			Folder.Name = "PlayerSettings"
			Folder.Parent = Player


			-- Prep the player's tycoon information
			local PlayerDrops
			if workspace.DroppedParts:FindFirstChild(Tycoon.Name) == nil then
				PlayerDrops = Instance.new("Folder",workspace.DroppedParts)
				PlayerDrops.Name = Tycoon.Name
			else
				PlayerDrops = workspace.DroppedParts:FindFirstChild(Tycoon.Name)
			end
			local TycoonData = Instance.new("ObjectValue",game.ReplicatedStorage.PlayerData)
			TycoonData.Value = Tycoon
			TycoonData.Name = Tycoon.Name
			-- Load in the player's ore limit
			local DropCount = Instance.new("IntValue")
			DropCount.Name = "DropCount"
			local DropLimit = Instance.new("IntValue")
			DropLimit.Name = "DropLimit"
			local DropLevel = Instance.new("IntValue")
			DropLevel.Name = "DropLevel"
			if PlayerData.DropLevel ~= nil then
				DropLimit.Value = 50 + 25 * (PlayerData.DropLevel - 1)
				if Player:FindFirstChild("Premium") then
					DropLimit.Value = DropLimit.Value + 25
				end
				DropLevel.Value = PlayerData.DropLevel
			else
				DropLimit.Value = 50
				DropLevel.Value = 1
			end
			DropCount.Parent = TycoonData
			DropLimit.Parent = TycoonData
			DropLevel.Parent = TycoonData

			local function dropfresh()
				DropLimit.Value = 50 + 25*(DropLevel.Value-1)
				if Player:FindFirstChild("Premium") then
					DropLimit.Value = DropLimit.Value + 25
				end
			end

			DropLevel.Changed:connect(dropfresh)

			Player.ChildAdded:connect(function(Child)
				if Child.Name == "Premium" then
					dropfresh()
				end
			end)

			local Producing = Tycoon:FindFirstChild("Producing") or Instance.new("BoolValue",Tycoon)
			Producing.Name = "Producing"
			Producing.Value = true

			local MinesActivated = Instance.new("BoolValue")
			MinesActivated.Name = "MinesActivated"
			MinesActivated.Value = true
			MinesActivated.Parent = Player

			DropCount.Changed:connect(function()
				if MinesActivated.Value then
					if DropCount.Value >= DropLimit.Value then
						Producing.Value = false
					else
						Producing.Value = true
					end
				end
			end)

			MinesActivated.Changed:connect(function()
				if MinesActivated.Value then
					if DropCount.Value >= DropLimit.Value then
						Producing.Value = false
					else
						Producing.Value = true
					end
				else
					Producing.Value = false
				end
			end)

			PlayerDrops.ChildAdded:connect(function()
				DropCount.Value = #PlayerDrops:GetChildren()
			end)

			PlayerDrops.ChildRemoved:connect(function()
				DropCount.Value = #PlayerDrops:GetChildren()
			end)
			-- Load in player rebirth count
			local RebirthValue = Instance.new("IntValue")
			RebirthValue.Name = "Rebirths"
			RebirthValue.Value = PlayerData.Rebirths
			RebirthValue.Parent = Player


			spawn(function()

				Player:WaitForChild("leaderstats"):WaitForChild("Life")
				RebirthValue.Changed:connect(function()
					local Life = RebirthValue.Value + 1
					local Prefix = ""
					if Player:FindFirstChild("SecondSacrifice") then
						Prefix = "S+"
					elseif Player:FindFirstChild("Sacrificed") then
						Prefix = "s-"
					end
					Player.leaderstats.Life.Value = Prefix..tostring(Life)..DataLib.LifeSuffix(Life)
				end)
				local Life = RebirthValue.Value + 1
				local Prefix = ""
				if Player:FindFirstChild("SecondSacrifice") then
					Prefix = "S+"
				elseif Player:FindFirstChild("Sacrificed") then
					Prefix = "s-"
				end
				Player.leaderstats.Life.Value = Prefix..tostring(Life)..DataLib.LifeSuffix(Life)
			end)
			-- Load in player's tutorial status
			local TutorialStat = Instance.new("BoolValue")
			TutorialStat.Name = "GamepadTutorial"
			if PlayerData.SeenTutorial ~= nil then
				TutorialStat.Value = PlayerData.SeenTutorial
			else
				TutorialStat.Value = false
			end
			TutorialStat.Parent = Player
			-- Load in crate Data
			spawn(function()
				if Player:FindFirstChild("Crates") == nil then
					local Crates = Instance.new("IntValue")
					Crates.Name = "Crates"
					local Regular = Instance.new("IntValue",Crates)
					Regular.Name = "Regular"
					local Unreal = Instance.new("IntValue",Crates)
					Unreal.Name = "Unreal"
					local Inferno = Instance.new("IntValue",Crates)
					Inferno.Name = "Inferno"
					Crates.Parent = Player
					local Clovers = Instance.new("IntValue")
					Clovers.Name = "Clovers"
					Clovers.Parent = Player


					for i,v in pairs(Crates:GetChildren()) do
						v.Changed:connect(function()
							Crates.Value = GetSum(Crates)
						end)
					end
				end
				wait()
				Player.Crates.Regular.Value = PlayerData.RegularBox
				PlayerData.RegularBox = 0
				Player.Crates.Unreal.Value = PlayerData.UnrealBox
				PlayerData.UnrealBox = 0
				Player.Crates.Inferno.Value = PlayerData.InfernoBox
				PlayerData.InfernoBox = 0

				PlayerData.Boxes = PlayerData.Boxes or {}
				for Box, Value in pairs(PlayerData.Boxes) do
					local Val = Player.Crates:FindFirstChild(Box)
					if Val then
						Val.Value = Value
					end
				end


				Player.Clovers.Value = PlayerData.Clovers
			end)

			-- FULLY LOADED IN
			-- Print player's data size (debug)
			local DataCount
			pcall(function()
				local JSONPlayerData = game.HttpService:JSONEncode(PlayerData)
				DataCount = string.len(JSONPlayerData)
				print(Player.Name.."'s data is "..DataCount.." characters long.")
			end)

			--[[
			--Update hydraulics
			for i,child in next,Tycoon:GetChildren() do
				if child:FindFirstChild("AdjustableHeight",true) then
					updateHydraulic(child)
				end
			end]]--

			wait(2)

			spawn(function()
				wait(1.5)
				if Player then
					local SuccessTag = Instance.new("BoolValue")
					SuccessTag.Name = "BaseDataLoaded"
					SuccessTag.Parent = Player

					--Player:LoadCharacter()
					--[[
					-- Innovation Event Stuff
					spawn(function()
						wait(5)
						script.SplashScreen:Clone().Parent = Player.PlayerGui
						print("Splashed")
						wait(10)
						if Player.EventStage.Value == 0 then
							game.ReplicatedStorage.Hint:FireClient(Player,"Seek out the Innovator in the middle of the map to begin your quest!")
						end
					end)
					]]
					game.ReplicatedStorage.DataLoadedIn:FireClient(Player)
					game.ServerStorage.PlayerDataLoaded:Fire(Player)
				--	game.ReplicatedStorage.Hint:FireClient(Player,"Welcome to the Miner's Haven testing server. Please note some features are incomplete. Report bugs and exploits to utopia@bergames.com",nil,nil,nil,2)

					-- INCOME
					local TimeAway = 0
					if PlayerData.TimeStamp and PlayerData.TimeStamp > 1 then
						TimeAway = os.time() - PlayerData.TimeStamp
					end

					spawn(function()
						wait(2)

						if TimeAway >= 600 and PlayerData.Income and PlayerData.Income > 0 then
							if TimeAway > 259200 then -- Cap at 3 days
								TimeAway = 259200
							end

							local Earnings = PlayerData.Income * (TimeAway / 10)
							if Earnings > RealMon * 500 then
								Earnings = RealMon * 500
							end
							Money.Value = Money.Value + Earnings
							game.ReplicatedStorage.Hint:FireClient(Player,"Your base made "..MoneyLib.HandleMoney(Earnings).." while you were away.",nil,Color3.new(0,0.5,0),"Money")
						else
							print("No money for ya")
						end
					end)

					while wait(60) do
						if Player ~= nil and Player.Parent == game.Players and Player:FindFirstChild("Leaving") == nil and DataLib.GetTycoon(Player) ~= nil and not Closing then
							if Player:FindFirstChild("Rebirthing") == nil then
								SaveData(Player, PlayerData)
							end
						else
							break;
						end
					end
				end
			end)

			if currentTag then
				currentTag:Destroy()
			end
			return true, DataCount
		end

	else
		if currentTag then
			currentTag:Destroy()
		end
		game.ReplicatedStorage.Error:FireClient(Player, Error)
		return false
	end

end

function game.ReplicatedStorage.LoadPlayerData.OnServerInvoke(Player, Slot) -- Player requests to load in
	if Player:FindFirstChild("BaseDataLoaded") == nil then -- make sure they haven't already loaded in
		local Result = false
		local DataCount
		local Success,Errormsg = pcall(function()
			Result,DataCount = LoadPlayerData(Player, Slot)
		end)

		if not Success then
			local tag = Instance.new("BoolValue")
			tag.Name = "CriticalError"
			tag.Parent = Player
			Errormsg = Errormsg or "Unknown error loading player data"
			game.ServerStorage.ReportError:Fire(Player, "critical", Errormsg)
			warn("CRITICAL ERROR LOADING DATA: "..Errormsg)
		end

		return Result, Success, Errormsg, DataCount
	end
end

local function PlayerLeaving(Player)
	local PlayerName = Player.Name
	local LeavingTag = Instance.new("BoolValue")
	LeavingTag.Name = "Leaving"
	LeavingTag.Parent = Player
	if not Closing then
		-- Save data
		if Player:FindFirstChild("BaseDataLoaded") and Player:FindFirstChild("Rebirthing") == nil then
			SaveData(Player)
			spawn(function()
				wait(120)
				local Tag = game.ReplicatedStorage.Waitlist:FindFirstChild(PlayerName)
				if Tag then
					Tag:Destroy()
				end
			end)
		end
		-- Clear base
		local Tycoon = DataLib.GetTycoon(Player)
		if Tycoon then
			for i,v in pairs(Tycoon:GetChildren()) do
				if v:IsA("Model") or v:IsA("BoolValue") then
					v:Destroy()
				end
			end
			-- Clean all their ore
			local Parts = workspace.DroppedParts:FindFirstChild(Tycoon.Name)
			if Parts then
				Parts:ClearAllChildren()
			end
			Tycoon.Owner.Value = ""
		end
		-- Clear inventory
		_G["Inventory"][Player.Name] = nil
		_G["Safekeeping"][Player.Name] = nil
		-- Clear money
		local Money = game.ServerStorage.MoneyStorage:FindFirstChild(Player.Name)
		if Money then
			Money:Destroy()
		end

	end
end

game.Players.PlayerRemoving:connect(PlayerLeaving)

-- for some reason this exists:
function game.ReplicatedStorage.SavePlayer.OnInvoke(Player)
	return SaveData(Player)
end
-- Unimportant tutorial stuff here:
game.ReplicatedStorage.TutorialAccepted.OnServerEvent:connect(function(Player)
	if Player:FindFirstChild("GamepadTutorial") then
		Player.GamepadTutorial.Value = true
	end
end)


game:BindToClose(function()
	Closing = true
	spawn(function()
	for i,v in pairs(game.Players:GetChildren()) do
		spawn(function()
			script.Shutdown:Clone().Parent = v.PlayerGui
			SaveData(v)

		end)
		-- Phone back home about shutdown
		local Error = "Player kicked from game by shutdown"
		game.ServerStorage.ReportError:Fire(v, "debug", Error)
	end
	end)

	local isOffline = game.JobId == ""
	if not isOffline then
		while wait() do -- keep server open for as long as possible
			print("we're all gonna die, we're all gonna die.")
		end
	else
		print("Offline mode")
	end
end)
