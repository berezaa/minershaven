local module = {}

local Rand = Random.new()

function module.getItem(Player)

	local Money = game.ServerStorage.MoneyStorage:FindFirstChild(Player.Name)
	if Money == nil then
		return false
	end

	local Items = {}
	for i,Item in pairs(game.ReplicatedStorage.Items:GetChildren()) do
		if Item.ItemType.Value == 11 then
			local Min = 0
			local t = Item.Tier.Value
			if t == 1 then
				Min = 50000
			elseif t == 2 then
				Min = (1 * 10^6)
			elseif t == 3 then
				Min = (1 * 10^9)
			elseif t == 4 then
				Min = (1 * 10^12)
			elseif t == 5 then
				Min = (1 * 10^15)
			elseif t >= 6 then
				Min = (25 * 10^18)
			end
			if Money.Value > Min then
				table.insert(Items,Item)
			end
		end
	end

	local Item = Items[Rand:NextInteger(1,#Items)]
	return Item
end


return module
