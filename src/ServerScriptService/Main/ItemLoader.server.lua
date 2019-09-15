local MoneyLib = require(game.ReplicatedStorage.MoneyLib)


for i,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do

	if v:FindFirstChild("Crystals") then
		v.Cost.Value = v.Crystals.Value * 100
	end


	if v.Cost.ClassName == "StringValue" then
		local newValue = MoneyLib.ShortToLong(v.Cost.Value)
		v.Cost.Name = "StringCost"
		local newCost = Instance.new("NumberValue",v)
		newCost.Name = "Cost"
		newCost.Value = newValue
	end

	if v:FindFirstChild("Tier") then

		if v.ItemType.Value == 5 then
			if v.ReqPoints.Value >= 500000 then
				v.Tier.Value = 93
			elseif v.ReqPoints.Value >= 75000 then
				v.Tier.Value = 92
			elseif v.ReqPoints.Value >= 20000 then
				v.Tier.Value = 91
			else
				v.Tier.Value = 90
			end
		end

		-- make crystal items worth it to sell.
		if v.ItemType.Value == 7 and v:FindFirstChild("Crystals") then
			v.Cost.Value = v.Crystals.Value * 100000
		end

		if v.ItemType.Value == 4 or (v.ItemType.Value == 7 and v.Tier.Value == 21) then
			local Tag = Instance.new("BoolValue")
			Tag.Name = "Decoration"
			Tag.Parent = v
		end

		if (v.ItemType.Value < 5 and v.ItemType.Value > 0) or v.ItemType.Value == 11 then
			if v.Cost.Value >= 10^50 then
				v.Tier.Value = 9

			elseif v.Cost.Value >= MoneyLib.ShortToLong("1Ud") then
				v.Tier.Value = 8


			elseif v.Cost.Value >= MoneyLib.ShortToLong("1O") then
				v.Tier.Value = 7

			elseif v.Cost.Value >= MoneyLib.ShortToLong("25Qn") then
				v.Tier.Value = 6

			elseif v.Cost.Value >= MoneyLib.ShortToLong("1qd") then
				v.Tier.Value = 5

			elseif v.Cost.Value >= MoneyLib.ShortToLong("1T") then
				v.Tier.Value = 4

			elseif v.Cost.Value >= MoneyLib.ShortToLong("1B") then
				v.Tier.Value = 3

			elseif v.Cost.Value >= MoneyLib.ShortToLong("1M") then
				v.Tier.Value = 2

			elseif v.Cost.Value >= MoneyLib.ShortToLong("50k") then
				v.Tier.Value = 1

			else
				v.Tier.Value = 0

			end

			local Tier = game.ReplicatedStorage.Tiers:FindFirstChild(tostring(v.Tier.Value))
			if Tier and Tier:FindFirstChild("ReqPoints") then
				v.ReqPoints.Value = Tier.ReqPoints.Value
			end

		end
	end
end

