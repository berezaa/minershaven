function getPlayerFromId(Id)
	for i,v in pairs(game.Players:GetChildren()) do
		if v.userId == Id then
			return v
		end
	end
	return nil
end

function PlayerAdded(Player)
	local OldVal
	if #game.Players:GetChildren() <= 6 then
		local Val = Instance.new("NumberValue",Player)
		Val.Name = "Points"
		if Player.userId > 0 then
			Val.Value = game.PointsService:GetGamePointBalance(Player.userId)
			OldVal = Val.Value
		end

		Player.ChildAdded:connect(function(Child)
			if Player:FindFirstChild("BaseDataLoaded") then
				if Child.Name == "Premium" then
					game.ReplicatedStorage.Hint:FireClient(Player,"All tiers unlocked!",Color3.new(0,0,0),Color3.new(1,1,1),"TierUnlock")
				end
			end
		end)

		Val.Changed:connect(function()
			if Player:FindFirstChild("Premium") == nil then
				for i,Tier in pairs(game.ReplicatedStorage.Tiers:GetChildren()) do
					if Tier:FindFirstChild("ReqPoints") then
						if OldVal < Tier.ReqPoints.Value and Val.Value >= Tier.ReqPoints.Value then
							game.ReplicatedStorage.Hint:FireClient(Player,Tier.TierName.Value.."-tier items unlocked.",nil,Tier.TierColor.Value,"TierUnlock")
							game.ReplicatedStorage.InventoryChanged:FireClient(Player,_G["Inventory"][Player.Name])
						end
					end
				end
			end
			OldVal = Val.Value
		end)
	end
	if game.MarketplaceService:PlayerOwnsAsset(Player,258261279) then
		local Tag = Instance.new("BoolValue")
		Tag.Name = "Million"
		Tag.Parent = Player
	end
end
game.Players.PlayerAdded:connect(PlayerAdded)
for i,v in pairs(game.Players:GetPlayers()) do
	PlayerAdded(v)
end

game.PointsService.PointsAwarded:connect(function(userId, pointsAwarded, userBalanceinUni, userBalance)
	local Player = getPlayerFromId(userId)
	if Player then
		Player.Points.Value = userBalanceinUni
	end
end)