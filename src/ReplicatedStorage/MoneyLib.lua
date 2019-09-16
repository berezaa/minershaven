-- Money Functions Library

--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

local MoneyLib = {}


MoneyLib.Suffixes = {"k","M","B","T","qd","Qn","sx","Sp","O","N","de","Ud","DD","tdD","qdD","QnD","sxD","SpD","OcD","NvD","Vgn","UVg","DVg","TVg","qtV","QnV","SeV","SPG","OVG","NVG","TGN","UTG","DTG","tsTG","qtTG","QnTG","ssTG","SpTG","OcTG","NoTG","QdDR","uQDR","dQDR","tQDR","qdQDR","QnQDR","sxQDR","SpQDR","OQDDr","NQDDr","qQGNT","uQGNT","dQGNT","tQGNT","qdQGNT","QnQGNT","sxQGNT","SpQGNT", "OQQGNT","NQQGNT","SXGNTL"}                                              
--                                                  																																															^NEW     ^ 10e123
MoneyLib.CachedShorts = {}

-- 2/3 was TOO HIGH

-- 2/3.5
-- 4/7

-- 2/4 TOO LOW
-- 2/5 is TOO LOW

local function sqrtfac(RB)
	local n = 1000
 	return (math.floor((RB^(4/7) * 5000^(3/7)) / (1000/n) ) * (0.24/n))	
end

MoneyLib.RebornPrice = function(RB)
	local n = 1000
	
	local limRB = RB
	if limRB > 5000 then
		limRB = 5000
	end
	
	local overRB = RB - limRB	
	
	-- 0.23 per 1000 lives
	local low = (math.floor(limRB / (1000/n)) * (0.24/n))
	local high = 0
	
	if RB > 5000 then
		high = sqrtfac(RB) - sqrtfac(5000)
	end
	
	local Expo = 1 + low + high
	local Multi = ((math.floor(RB/5) * 2) + 1) * (1+(math.floor(RB/25)*100)) * (1 + math.floor(RB/500)*1000)
	local Price = (25000000000000000000 * Multi) ^ Expo
	if Price > 2.5 * 10^181 then
		Price = 2.5 * 10^181
	end
	return Price
end

MoneyLib.LifeSkips = function(RB, Money)
	local Cost = MoneyLib.RebornPrice(RB)
	local n = 3
	for i=20,1,-1 do
		local Price = Cost * (10^(n*i))
		if Money > Price then
			return i
		end
	end
	return 0
end


function MoneyLib.HandleLife(Life)
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
	return tostring(Life)..Suffix
end

MoneyLib.ShortToLong = function(MoneyShort)
	if MoneyLib.CachedShorts[MoneyShort] ~= nil then
		return MoneyLib.CachedShorts[MoneyShort]
	end
	local result
	local eCutoff = string.find(MoneyShort,"e%+")
	if eCutoff ~= nil then
		local Coeff = tonumber(string.sub(tostring(MoneyShort),1,1))
		local Zeros = tonumber(string.sub(tostring(MoneyShort),eCutoff+2))
		result = Coeff * 10^Zeros
	else	
		for i,v in pairs(MoneyLib.Suffixes) do
			local Cutoff = string.find(MoneyShort,v)
		--	print(string.sub(MoneyShort,string.len(MoneyShort)-string.len(v)+1),v)
			if Cutoff ~= nil and string.sub(MoneyShort,string.len(MoneyShort)-string.len(v)+1) == v then
				local Moneh = string.sub(MoneyShort,1,string.len(MoneyShort)-string.len(v))
				local Answer = tonumber(Moneh) * 10^(3*i)
				result = Answer
			end
		end
	end
	MoneyLib.CachedShorts[MoneyShort] = result
	return result
end


local function shorten(Input)
	local Negative = Input < 0
	Input = math.abs(Input)

	local Paired = false
	for i,v in pairs(MoneyLib.Suffixes) do
		if not (Input >= 10^(3*i)) then
			Input = Input / 10^(3*(i-1))
			local isComplex = (string.find(tostring(Input),".") and string.sub(tostring(Input),4,4) ~= ".")
			Input = string.sub(tostring(Input),1,(isComplex and 4) or 3) .. (MoneyLib.Suffixes[i-1] or "")
			Paired = true
			break;
		end
	end
	if not Paired then
		local Rounded = math.floor(Input)
		Input = tostring(Rounded)
	end

	if Negative then
		return "-"..Input
	end
	return Input
end

MoneyLib.HandleMoney = function(Input)
	local Negative = Input < 0
	if Negative then
		return "(-$"..shorten(math.abs(Input))..")"
	end
	return "$"..shorten(Input)	
end



function MoneyLib.DealWithPoints(Input)
	return shorten(Input)
end

return MoneyLib
