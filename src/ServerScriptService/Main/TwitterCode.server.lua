--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

--local Store = game:GetService("DataStoreService"):GetDataStore("TwitterCodes")
_G["Twitter"] = {}

local function Award(Player, ItemId, Amount)
	game.ServerStorage.AwardItem:Invoke(Player, ItemId, Amount)
	return true
end



local function MaskedMan(Player)
	local result = false
	if Player:FindFirstChild("MaskedManMask") then
		local Box = "Luxury"
		local Amount = 3
		local Boxes = Player.Crates:FindFirstChild(Box)
		if Boxes then
			game.ReplicatedStorage.Hint:FireClient(Player,"Returned the Masked Man's Mask!", Color3.new(1,1,1), Color3.new(0,0,0),"MaskedMan")
			result = true
			Boxes.Value = Boxes.Value + Amount
			game.ReplicatedStorage.Hint:FireClient(Player,"Mystery Box attained: x"..Amount.." "..Box..".")
		end
	end
	return result
end


local function Artifacts(Player)
	local result = false
	if Player:FindFirstChild("Snowflake") then
		Award(Player,246,1)
		result = true
	end
	if Player:FindFirstChild("Shoddy") then
		Award(Player,245,15)
		result = true
	end
	if Player:FindFirstChild("Gambler") then
		Award(Player,244,1)
		result = true
	end
	if result == false then
		game.ReplicatedStorage.Hint:FireClient(Player,"You don't have any artifacts!")
	end
	return result
end

local function Artifacts2(Player)
	local result = false
	if Player:FindFirstChild("GiantCrate") then
		Award(Player,328,3)
		result = true
	end
	if Player:FindFirstChild("Mars") then
		Award(Player,331,1)
		result = true
	end
	if Player:FindFirstChild("Nebula") then
		Award(Player,329,1)
		Award(Player,330,1)
		result = true
	end
	if result == false then
		game.ReplicatedStorage.Hint:FireClient(Player,"You don't have any artifacts!")
	end
	return result
end


local function Points(Player, Amount)
	if Player.userId > 0 then
		game.PointsService:AwardPoints(Player.userId,Amount)
	end
	return true
end

local function ChanceAward(Player, ItemId, Amount, Chance)
	local Count = math.random(1,Chance)
	if Count == math.ceil(Chance/2) then
		game.ServerStorage.AwardItem:Invoke(Player, ItemId, Amount)
	end
	return true
end

local function Crystals(Player, Amount)
	if Player:FindFirstChild("Crystals") then
		Player.Crystals.Value = Player.Crystals.Value + Amount

		game.ReplicatedStorage.CurrencyPopup:FireClient(Player, Amount.." uC", Color3.fromRGB(255, 176, 178), "rbxassetid://1028723620")


		--game.ReplicatedStorage.Hint:FireClient(Player,tostring(Amount).." crystals credited.")

		-- Game Analytics Currency Reporting
		local CrystalsGained = Amount
		local ProductName = "secretcode"
		if true then
			ProductName = ProductName or "unknown"
			game.ServerStorage.CurrencyEvent:Fire(Player, "Crystals", CrystalsGained, "granted", ProductName)
		end
		-- Game Analytics Currency Reporting


	end
	return true
end

local function CrystalAward(Player, ItemId, Amount, CrystalAmount)
	if Player:FindFirstChild("Crystals") then
		Player.Crystals.Value = Player.Crystals.Value + CrystalAmount
		game.ReplicatedStorage.Hint:FireClient(Player,tostring(CrystalAmount).." crystals credited.")
		-- Game Analytics Currency Reporting
		local CrystalsGained = CrystalAmount
		local ProductName = "secretcode"
		if true then
			ProductName = ProductName or "unknown"
			game.ServerStorage.CurrencyEvent:Fire(Player, "Crystals", CrystalsGained, "granted", ProductName)
		end
		-- Game Analytics Currency Reporting
	end
	Award(Player, ItemId, Amount)
	return true
end

local function GiveTool(Player, Tool)
	local Tool = game.Lighting:FindFirstChild(Tool)
	if Tool and Player then
		Tool:Clone().Parent = Player.Backpack
		game.ReplicatedStorage.Hint:FireClient(Player,"You got a ".. Tool.Name .. " for one life, go wild!")
	end
	return true
end

local function Box(Player, Box, Amount)
	local Boxes = Player.Crates:FindFirstChild(Box)
	if Boxes then
		Boxes.Value = Boxes.Value + Amount
		--game.ReplicatedStorage.Hint:FireClient(Player,"Mystery Box attained: x"..Amount.." "..Box..".")
		local Prefix = ((Amount == 1) and "") or Amount .. " "
		local BoxSt = game.ReplicatedStorage.Boxes:FindFirstChild(Box)
		game.ReplicatedStorage.CurrencyPopup:FireClient(Player,Prefix..Box.." Box",BoxSt.BoxColor.Value,"rbxassetid://"..BoxSt.ThumbnailId.Value)

	end
	return true
end

local function GoldClover(Player, Amount)
	local Clovers = Player:FindFirstChild("GoldClovers")
	if Clovers then
		Clovers.Value = Clovers.Value + Amount
		game.ReplicatedStorage.Hint:FireClient(Player,"Gold Clovers obtained: x"..Amount..".")
		return true
	end
	return false
end

local function Clover(Player, Amount)
	local Clovers = Player:FindFirstChild("Clovers")
	if Clovers then
		Clovers.Value = Clovers.Value + Amount
		game.ReplicatedStorage.Hint:FireClient(Player,"Lucky Clovers obtained: x"..Amount..".")
		return true
	end
	return false
end

local function HundredMil(Player)
	game.ServerStorage.AwardItem:Invoke(Player,529,1)
	 Box(Player, "Magnificent", 1)
	return true
end


local function TwitchCoins(Player, Amount)
	local Clovers = Player:FindFirstChild("TwitchPoints")
	if Clovers then
		Clovers.Value = Clovers.Value + Amount
		game.ReplicatedStorage.Hint:FireClient(Player,"Twitch coins obtained: x"..Amount..".")
		return true
	end
	return false
end

local function CheckAward(Player, CheckTag, ItemId, Amount)
	if Player:FindFirstChild(CheckTag) then
		Award(Player, ItemId, Amount)
		return true
	end
	return false
end

local function Crate(Player, CrateType, Amount)
	Amount = Amount or 1
	local RealCrate = game.ServerStorage:FindFirstChild(CrateType)
	if RealCrate and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
		for i=1,Amount do
			local Crate = RealCrate:Clone()
			Crate.CFrame = Player.Character.HumanoidRootPart.CFrame + Vector3.new(math.random(-5,5), math.random(20,35), math.random(-5,5))
			Crate.Parent = workspace
			game.Debris:AddItem(Crate,60)
		end
		return true
	end
end


local function FreshStart(Player)
	Clover(Player, 1)
	Box(Player, "Inferno", 1)
	Box(Player, "Unreal", 2)
	Crystals(Player, 40)
	pcall(function()
		Instance.new("ForceField",Player.Character)
	end)
	return true
end

local function HeadStart(Player)
	local Money = game.ServerStorage.MoneyStorage:FindFirstChild(Player.Name)
	if Money then
		Money.Value = Money.Value + 100000
		game.ReplicatedStorage.Hint:FireClient(Player,"You got $100,000!",Color3.new(1,1,1),Color3.new(0,1,0),"Purchase",2)
	end
	spawn(function()
		game.PointsService:AwardPoints(Player.userId,5000)
	end)
	return true
end

local Codes = {

--	{"rearti",Artifacts},
--	{"asecretmask",MaskedMan},
--	{"rearti2",Artifacts2},


--	{"BerGamesXmas",CheckAward,"BerezaaGames",247,1},
--	{"h4ppyhunt1ng",Box,"Inferno",1},
--	{"1r1shbl00d",Clover,1},
--	{"AFreshStart",FreshStart},
--    {"Haven4Xbox",CrystalAward, 148, 1, 20},
--[[
    {"buildintogames",Box,"Inferno",1},
    {"WelcomeToHaven",FreshStart},
	{"meitowinlol",Crystals,30},
	{"catchmelift",Crystals,30},
{"imessedup",Crystals,150},
	{"ruffruffruff",Crystals,30},
	{"forum.berezaagames.com",Crystals,30},
    {"gitgudm12",Box,"Inferno",1},
 {"merrystpattys",Box,"Inferno",1},
{"spiceymemememes",Box,"Inferno",1},
{"winteriscomingt",Crystals,35},
	{"CHILLERYWON",Box,"Regular",4},
	{"jebbush",Box,"Regular",3},
	{"aDSKAJDDFD",Box,"Unreal",2},
	{"getbuffed??",Box,"Unreal",2},
	--NEW
	{"unlimitedmemes",TwitchCoins,4},
	{"limitedmemes",TwitchCoins,4},
	{"justdewit",TwitchCoins,4},
	{"heavenlogoffplease",TwitchCoins,4},
	 {"getsp00ked",Box,"Inferno",1},
	 {"spockyscurysk3le",Box,"Inferno",1},
	{"argspacepirates",Box,"Unreal",2},
	{"itsinthefirdge",Crystals,30},
	-- COMMUNITY CODES:
	{"imonaboatlmao",Crystals,20},
	{"thepoweroffriendship",Crystals,20},
	{"youngmacdonald",Crystals,20},
	{"loleris>berezaa",Crystals,20},
	{"maskedwoman",Crystals,20},
	{"trex",Box,"Unreal",1},
	{"musclemilk",Box,"Unreal",1},
	{"eatdairyproducts",Box,"Unreal",1},
	{"filledintogames",Box,"Unreal",1},
	{"chexmix",Clover,1},
	{"micheleobama",Clover,1},
	{"canada",Clover,1},

	{"FREECRYSTALS!!!!",Crystals,30},
	{"w1nteriscoming",Crystals,30},
	{"LOLERISILOVEYOU",Box,"Unreal",2},
	{"jabenyezzaaa",Box,"Unreal",2},
	{"memesrUSA",Box,"Unreal",2},
	{"trumpcare",Box,"Inferno",1},
	{"MEMES4DONALD",TwitchCoins,4},
	{"WEARENUMBER",Award,326,1},
	{"WHAN",Award,327,1},
	{"iliketruckss",TwitchCoins,4},
	{"pokemon",TwitchCoins,4},
	{"roberto5.0",TwitchCoins,4},
	{"OHGEEEEEZ",Box,"Inferno",2},
	{"ZAAAZOOOO",TwitchCoins,8},
	{"ZOMGGG",Crystals,50},
	{"WOOOOO",Crystals,50},
	{"WOOOAAAHH",Box,"Unreal",4},
	{"BLACKFRIDAYY",Box,"Inferno",2},
	{"FRIDAYYBLACK",Award,149,9},
	{"AMerryXmas",Award,338,10},
	{"ohletsgo",Crystals,35},
	{"HOHOHOHOHOHO",Crystals,55},
	{"HolidaySpirit",Box,"Inferno",2},
	{"WINTERISHERE!",Box,"Unreal",3},
	{"amaazingg!",Clover,1},
	{"poodlec0rp",TwitchCoins,4},
	{"freshmeemees",TwitchCoins,4},
]]
	{"KaBOOOOM",GiveTool,"RocketLauncher"},
--	{"AGreat3Years",Box,"Magnificent",1},
	{"hyup",Award,400,1},
	{"communistmanifesobestmanifesto",Box,"Spectral",1},
	{"HeadStart",HeadStart},
	{"Rthro",Award,191,1},

	--{"ferocious",Award,109,1},
}

--function PlayerAdded(Player)
--	local Data
--	Store:UpdateAsync(Player.userId,function(SavedData)
--		Data = SavedData or {}
--		return nil
--	end)
--	_G["Twitter"][Player.Name] = Data
--end

function PlayerAdded(Player)

end

game.ServerStorage.PlayerDataLoaded.Event:Connect(PlayerAdded)

--[[
game.Players.PlayerAdded:connect(PlayerAdded)
for i,v in pairs(game.Players:GetPlayers()) do
	PlayerAdded(v)
end
]]
--local Module = require(script.Parent.Verification)

function game.ReplicatedStorage.TryCode.OnServerInvoke(Player,Code)
	if Code == "restoredata" then
		--743673074
		game:GetService("TeleportService"):Teleport(1778064565,Player)
		return true
	elseif string.sub(Code,1,1) == "$" and string.len(Code) > 6 and string.len(Code) < 10 then
		local success = false
--		local success = Module.Verify(Player, Code)
		if success then

			spawn(function()
				pcall(function()
					game.BadgeService:AwardBadge(Player.userId,685908096)
				end)
			end)

			local Today = math.floor(os.time()/(60*60*24))

			if Player.DiscordAward.Value == 0 then
				game.ReplicatedStorage.Hint:FireClient(Player,"Verified! 60uC Awarded!")
				Player.Crystals.Value = Player.Crystals.Value + 60
				-- Game Analytics Currency Reporting
				local CrystalsGained = 60
				local ProductName = "verification"
				if true then
					ProductName = ProductName or "unknown"
					game.ServerStorage.CurrencyEvent:Fire(Player, "Crystals", CrystalsGained, "granted", ProductName)
				end
				-- Game Analytics Currency Reporting
				local Box = game.ReplicatedStorage.Boxes.Inferno
				game.ReplicatedStorage.CurrencyPopup:FireClient(Player,Box.Name.." Box",Box.BoxColor.Value,"rbxassetid://"..Box.ThumbnailId.Value)

				Player.Crates.Inferno.Value = Player.Crates.Inferno.Value + 1
				game.ServerStorage.AwardItem:Invoke(Player,368,30)
				game.ReplicatedStorage.Hint:FireClient(Player,"Use your code again tomorrow for a random reward!")
				game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." just verified their community account!",Color3.new(90/255, 148/255, 255/255))
				Player.DiscordAward.Value = Today
				game.ServerStorage.ReportEvent:Invoke(Player, "code:discord")
				game.ServerStorage.ReportEvent:Invoke(Player, "verify")
				return true
			elseif Player.DiscordAward.Value < Today then
				local Chance = math.random(1,6)
				local RewardString = ""
				if Chance == 1 then
					RewardString = "15uC"
					Player.Crystals.Value = Player.Crystals.Value + 15
					-- Game Analytics Currency Reporting
					local CrystalsGained = 15
					local ProductName = "reverify"
					if true then
						ProductName = ProductName or "unknown"
						game.ServerStorage.CurrencyEvent:Fire(Player, "Crystals", CrystalsGained, "granted", ProductName)
					end
					-- Game Analytics Currency Reporting
				elseif Chance == 2 then
					RewardString = "1 Regular Box"
					Player.Crates.Regular.Value = Player.Crates.Regular.Value + 1
				elseif Chance == 3 then
					RewardString = "2 Regular Boxes"
					Player.Crates.Regular.Value = Player.Crates.Regular.Value + 2
				elseif Chance == 4 then
					RewardString = "1 Unreal Box"
					Player.Crates.Unreal.Value = Player.Crates.Unreal.Value + 1
				elseif Chance == 5 then
					RewardString = "25uC"
					Player.Crystals.Value = Player.Crystals.Value + 25
					-- Game Analytics Currency Reporting
					local CrystalsGained = 25
					local ProductName = "reverify"
					if true then
						ProductName = ProductName or "unknown"
						game.ServerStorage.CurrencyEvent:Fire(Player, "Crystals", CrystalsGained, "granted", ProductName)
					end
					-- Game Analytics Currency Reporting
				else
					RewardString = "10uC"
					Player.Crystals.Value = Player.Crystals.Value + 10
					-- Game Analytics Currency Reporting
					local CrystalsGained = 10
					local ProductName = "reverify"
					if true then
						ProductName = ProductName or "unknown"
						game.ServerStorage.CurrencyEvent:Fire(Player, "Crystals", CrystalsGained, "granted", ProductName)
					end
					-- Game Analytics Currency Reporting
				end
				game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." claimed their daily community reward!",Color3.new(90/255, 148/255, 255/255))
				game.ReplicatedStorage.Hint:FireClient(Player,"Community Daily reward: "..RewardString.."!")
				Player.DiscordAward.Value = Today
				game.ServerStorage.ReportEvent:Invoke(Player, "code:discord")
				return true
			else
				game.ReplicatedStorage.Hint:FireClient(Player,"You've already used your code today.")
				return nil
			end


		end
		return false
	end
	for i,v in pairs(Codes) do
		if v[1] == Code then
			local Data = _G["Twitter"][Player.Name]
			if Data and Data[Code] then
				return nil
			else
				local args = {v[3],v[4],v[5],v[6],v[7]}
				local arg1,arg2,arg3,arg4,arg5 = args[1],args[2],args[3],args[4],args[5]
				local result = v[2](Player,arg1,arg2,arg3,arg4,arg5)
				if result then
					Data[Code] = true
					--Store:SetAsync(Player.userId,Data)
					game.ServerStorage.ReportEvent:Invoke(Player, "code:twitter")
					return true
				end
				return "NoPermission"
			end
		end
	end
	return false
end