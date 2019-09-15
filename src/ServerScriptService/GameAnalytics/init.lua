--Variables
local baseURL = "http://api.gameanalytics.com/v2/"

--Services
local HTTP = game:GetService("HttpService")

GA = {
	PostFrequency = 20,

	GameKey = nil,
	SecretKey = nil,
	SessionID = nil,
	Queue = {},

	EncodingModules = {},
	Ready = false,
}

function GA:Init(GameKey, SecretKey)
	baseURL = baseURL..GameKey.."/"

	GA.GameKey = GameKey
	GA.SecretKey = SecretKey
	GA.SessionID = HTTP:GenerateGUID(false):lower()

	--Encoding Modules
	GA.EncodingModules.lockbox = require(script.lockbox)
	GA.EncodingModules.lockbox.bit = require(script.bit).bit
	GA.EncodingModules.array = require(GA.EncodingModules.lockbox.util.array)
	GA.EncodingModules.stream = require(GA.EncodingModules.lockbox.util.stream)
	GA.EncodingModules.base64 = require(GA.EncodingModules.lockbox.util.base64)
	GA.EncodingModules.hmac = require(GA.EncodingModules.lockbox.mac.hmac)
	GA.EncodingModules.sha256 = require(GA.EncodingModules.lockbox.digest.sha2_256)

	GA.Base = {
		["device"] = "unknown",
		["v"] = 2,
		["user_id"] = "unknown",
		["client_ts"] = os.time(),
		["sdk_version"] = "rest api v2",
		["os_version"] = "windows 10",
		["manufacturer"] = "unknown",
		["platform"] = "windows",
		["session_id"] = GA.SessionID,
		["session_num"] = 1,
	}

	local Data = HTTP:JSONEncode({
		["platform"] = "unknown",
		["os_version"] = "unknown",
		["sdk_version"] = "rest api v2",
	})

	local Headers = {
		Authorization = GA:Encode(Data)
	}

	local Response = HTTP:PostAsync(baseURL.."init", Data, Enum.HttpContentType.ApplicationJson, false, Headers)
	Response = HTTP:JSONDecode(Response)

	if not Response.enabled then
		warn("GameAnalytics did not initialize properly!")
		return
	end

	GA.Ready = true

	spawn(function()
		while true do
			wait(GA.PostFrequency)
			GA:Post()
		end
	end)
end

function GA:SendEvent(Data, Player)
	if not GA.Ready then
		warn("GameAnalytics has not been initialized! Call :Init(GameKey, SecretKey) on the module before sending events!")
	end

	for i,v in pairs(GA.Base) do
		Data[i] = Data[i] or v
	end

	if Player ~= nil and Player.Parent == game.Players then -- Allow game to specify a player (mod by berezaa)
		Data["user_id"] = tostring(Player.userId)
		if Player:FindFirstChild("AnalyticsSessionId") then
			Data["session_id"] = Player.AnalyticsSessionId.Value
		end
	end

	Data["client_ts"] = os.time()

	table.insert(GA.Queue, Data)
	return true
end

function GA:Post()
	if not GA.Ready then
		warn("GameAnalytics has not been initialized! Call :Init(GameKey, SecretKey) on the module before sending events!")
		return
	end

	if #GA.Queue > 0 then
		local Data = HTTP:JSONEncode(GA.Queue)
		GA.Queue = {}

		local Headers = {
			["Authorization"] = GA:Encode(Data)
		}

		print("GA data length: "..Data:len().." chars.")
		local s,ret = pcall(function() return HTTP:PostAsync(baseURL.."events", Data, Enum.HttpContentType.ApplicationJson, false, Headers) end)

		if s then
			print("GameAnalytics: Posted!")
		else
			warn("GameAnalytics: Posting error.")
			warn(ret)
		end
	end
end

function GA:Encode(body)
	local secretKey = GA.SecretKey

	local hmacBuilder = GA.EncodingModules.hmac()
		.setBlockSize(64)
		.setDigest(GA.EncodingModules.sha256)
		.setKey(GA.EncodingModules.array.fromString(secretKey))
		.init()
		.update(GA.EncodingModules.stream.fromString(body))
		.finish()
	return GA.EncodingModules.base64.fromArray(hmacBuilder.asBytes())
end

return GA