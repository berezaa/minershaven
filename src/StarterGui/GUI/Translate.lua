local module = {}

local function normify(str)
	str = string.lower(string.gsub(string.gsub(str," ","_"),"[^a-zA-Z0-9 - _]",""))
	if #str > 30 then
		str = string.sub(str,1,30)
	end
	return str
end

local Translator = game.LocalizationService:GetTranslatorForPlayer(game.Players.LocalPlayer)

local function Translate(RealItem, Type)
	local Text
	local Prefix = "item_"
	if Type == "Name" then
		Prefix = "itemname_"
	end
	pcall(function()
		local Translation = Translator:FormatByKey(Prefix..normify(RealItem.Name))
		if Translation and #Translation > 0 then
			Text = Translation
		end
	end)
	return Text
end

function module.Item(RealItem)
	return Translate(RealItem,"Description") or RealItem.Description.Value
end

function module.ItemName(RealItem)
	return Translate(RealItem,"Name") or RealItem.Name
end

return module
