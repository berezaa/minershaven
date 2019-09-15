game.ReplicatedStorage:WaitForChild("Items")
for i,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
	local SelBox = Instance.new("SelectionBox",v)
	SelBox.Name = "SelectionBox"
	SelBox.Adornee = v.Hitbox
	SelBox.Visible = false
	--[[
	if v.Tier.Value == 20 then
		SelBox.Color3 = Color3.new(172/255, 167/255, 15/255)
	elseif v.Tier.Value == 30 then
		SelBox.Color3 = Color3.new(172/255, 29/255, 153/255)
	elseif v.Tier.Value == 40 then
		SelBox.Color3 = Color3.new(0/255, 161/255, 34/255)
	end
	]]
end