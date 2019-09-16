--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]




local key
if game.PlaceId == 258258996 then
	key = require(script.key)
else
	key = require(script.testing)
end





local Analytics = require(game.ServerScriptService.GameAnalytics)


local DEBUG = false

local errorchache = 3

if key.GameKey == "" then
	warn("No GameAnalytics GameKey provided. See", script:GetFullName(), "to add a GA key.")
else
	Analytics:Init(key.GameKey, key.SecretKey)
end



game.Players.PlayerRemoving:connect(function(Player)
	if Player:FindFirstChild("AnalyticsSessionId") or Player:FindFirstChild("BaseDataLoaded") then
		local Length = 0
		if Player:FindFirstChild("JoinTime") then
			Length = os.time() - Player.JoinTime.Value
		end
		Analytics:SendEvent({
			["category"] = "session_end",
			["length"] = math.floor(Length),
		}, Player)
	end
end)

game.Players.PlayerAdded:connect(function(Player)
	local SessionId = game:GetService("HttpService"):GenerateGUID(false):lower()
	local Tag = Instance.new("StringValue")
	Tag.Name = "AnalyticsSessionId"
	Tag.Value = SessionId
	Tag.Parent = Player
end)

game.ServerStorage.PlayerDataLoaded.Event:connect(function(Player)
	if key.GameKey == "" then
		return false
	end
	local SessionId
	if Player:FindFirstChild("AnalyticsSessionId") == nil then
		SessionId = game:GetService("HttpService"):GenerateGUID(false):lower()
		local Tag = Instance.new("StringValue")
		Tag.Name = "AnalyticsSessionId"
		Tag.Value = SessionId
		Tag.Parent = Player
	else
		SessionId = Player.AnalyticsSessionId.Value
	end

	Analytics:SendEvent({
		["category"] = "user",
		["session_id"] = SessionId,
		["user_id"] = tostring(Player.userId),
	}, Player)
	local TimeStamp = Instance.new("NumberValue")
	TimeStamp.Value = os.time()
	TimeStamp.Name = "JoinTime"
	TimeStamp.Parent = Player
	if errorchache < 5 then
		errorchache = errorchache + 1
	end
end)

game.ServerStorage.PurchaseMade.Event:connect(function(Player, Category, Product, Amount)
	if key.GameKey == "" then
		return false
	end
	local Cents = math.floor(Amount * 0.7) * 0.35
	Product = Product or "unspecified"
	Product = tostring(Product):gsub('%W','')
	Analytics:SendEvent({


		["category"] = "business",
		["event_id"] = tostring(Category)..":"..Product,
		["amount"] = math.floor(Cents),
		["currency"] = "USD",
		["transaction_num"] = 1,

	}, Player)

	if DEBUG then
		print(tostring(Category)..":"..Product)
	end
end)

game.ServerStorage.CurrencyEvent.Event:connect(function(Player, Currency, Amount, Category, EventId)
	if key.GameKey == "" then
		return false
	end
	local flowType = "Source"

	if Amount < 0 then
		flowType = "Sink"
		Amount = math.abs(Amount)
	end

	Category = Category or "unspecified"
	EventId = EventId or "unspecified"

	Analytics:SendEvent({
		["category"] = "resource",
		["event_id"] = flowType..":"..Currency..":"..Category..":"..EventId,
		["amount"] = Amount,

	}, Player)
	if DEBUG then
		print(flowType..":"..Currency..":"..Category..":"..EventId)
	end
end)

function game.ServerStorage.ReportProgression.OnInvoke(Player, Status, EventId, Attempt, Score)
	if key.GameKey == "" then
		return false
	end
	local EventId = Status..":"..EventId
	if Status == "Start" then
		Analytics:SendEvent({
			["category"] = "progression",
			["event_id"] = EventId,
		}, Player)
	elseif Status == "Fail" or Status == "Complete" then
		Analytics:SendEvent({
			["category"] = "progression",
			["event_id"] = EventId,
			["attempt_num"] = Attempt,
			["score"] = Score
		}, Player)
	end
end

function game.ServerStorage.ReportEvent.OnInvoke(Player, EventId, Value)
	if key.GameKey == "" then
		return false
	end
	Analytics:SendEvent({
		["category"] = "design",
		["event_id"] = EventId,
		["value"] = Value,
	}, Player)
end

game.ServerStorage.ReportError.Event:connect(function(Player, Severity, Message)
	if key.GameKey == "" then
		return false
	end
	if errorchache > 0 then
		errorchache = errorchache - 1
		Analytics:SendEvent({
			["category"] = "error",
			["severity"] = Severity,
			["message"] = Message,
		}, Player)
	end
end)

game.ServerStorage.PlayerOpenBox.Event:connect(function(Player, Box, VintageWin)
	if key.GameKey == "" then
		return false
	end
	if VintageWin then
		Analytics:SendEvent({
			["category"] = "design",
			["event_id"] = "vintagewin:"..string.lower(Box),
			["value"] = 1
		}, Player)
	end
	Analytics:SendEvent({
		["category"] = "design",
		["event_id"] = "box:"..string.lower(Box),
		["value"] = 1
	}, Player)
	if DEBUG then
		print("box:"..string.lower(Box))
	end
end)
--[[
local ErrorCache = {}

function ErrorExists(Error)
	for i,Err in pairs(ErrorCache) do
		if Err == Error then
			return true
		end
	end
	return false
end

game:GetService("ScriptContext").Error:connect(function (message, stack)
	local Error = tostring(message).." : "..tostring(stack)
	if not ErrorExists(Error) then
		Analytics:SendEvent({
			["category"] = "error",
			["severity"] = "error",
			["message"] = "Server: "..Error
		})
	end
end)
]]
--[[
game.ReplicatedStorage.ClientError.OnServerEvent:connect(function(Player, message, stack)
	Analytics:SendEvent({
		["category"] = "error",
		["severity"] = "error",
		["message"] = tostring(Player.userId)..": "..tostring(message).." : "..tostring(stack)
	})
end)
]]