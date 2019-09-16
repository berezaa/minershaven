function Validate(Player)
	if not Player:FindFirstChild("Premium") and game.MarketplaceService:PlayerOwnsAsset(Player,268427885) then
		local tag = Instance.new("BoolValue",Player)
		tag.Name = "Premium"
		tag.Value = true
	end
	if not Player:FindFirstChild("Executive") and game.MarketplaceService:PlayerOwnsAsset(Player,270999180) then
		local tag = Instance.new("BoolValue",Player)
		tag.Name = "Executive"
		tag.Value = true
	end
	if not Player:FindFirstChild("BerToy") and game.MarketplaceService:PlayerOwnsAsset(Player,583030187) then
		local tag = Instance.new("BoolValue",Player)
		tag.Name = "BerToy"
		tag.Value = true
	end
	if not Player:FindFirstChild("Vesterian") and game.BadgeService:UserHasBadgeAsync(Player.userId, 2124445897) then
		local tag = Instance.new("BoolValue",Player)
		tag.Name = "Vesterian"
		tag.Value = true
	end
	if not Player:FindFirstChild("MaskedManMask") and game.MarketplaceService:PlayerOwnsAsset(Player,1198802665) then
		local tag = Instance.new("BoolValue",Player)
		tag.Name = "MaskedManMask"
		tag.Value = true
	end
	if not Player:FindFirstChild("ShoutColor") and game.MarketplaceService:PlayerOwnsAsset(Player,271558969) then
		local tag = Instance.new("BoolValue",Player)
		tag.Name = "ShoutColor"
		tag.Value = true
	end
	if not Player:FindFirstChild("BaseRadio") and game.MarketplaceService:PlayerOwnsAsset(Player,1044027953) then
		local tag = Instance.new("BoolValue",Player)
		tag.Name = "BaseRadio"
		tag.Value = true
	end
	if not Player:FindFirstChild("SwordMaster") and game.MarketplaceService:PlayerOwnsAsset(Player,280971169) then
		local tag = Instance.new("BoolValue",Player)
		tag.Name = "SwordMaster"
		tag.Value = true
	end
	if not Player:FindFirstChild("MultiIsland") and game.MarketplaceService:PlayerOwnsAsset(Player,271363421) then
		local tag = Instance.new("BoolValue",Player)
		tag.Name = "MultiIsland"
		tag.Value = true
	end
	if not Player:FindFirstChild("Admin") and Player:GetRankInGroup(1137635) >= 60 then
		local tag = Instance.new("BoolValue",Player)
		tag.Name = "Admin"
		tag.Value = true
	end


-- HOLIDAY ITEMS

	if not Player:FindFirstChild("CursedPearl") and game.MarketplaceService:PlayerOwnsAsset(Player,1198493255) then
		local tag = Instance.new("BoolValue",Player)
		tag.Name = "CursedPearl"
		tag.Value = true
	end
	if not Player:FindFirstChild("CircusTent") and game.MarketplaceService:PlayerOwnsAsset(Player,1198683768) then
		local tag = Instance.new("BoolValue",Player)
		tag.Name = "CircusTent"
		tag.Value = true
	end
	if not Player:FindFirstChild("LoneFrog") and game.MarketplaceService:PlayerOwnsAsset(Player, 1199092726) then
		local tag = Instance.new("BoolValue",Player)
		tag.Name = "LoneFrog"
		tag.Value = true
	end


	if not Player:FindFirstChild("Gambler") and game.MarketplaceService:PlayerOwnsAsset(Player,324130907) then
		local tag = Instance.new("BoolValue",Player)
		tag.Name = "Gambler"
		tag.Value = true
	end
	if not Player:FindFirstChild("Shoddy") and game.MarketplaceService:PlayerOwnsAsset(Player,324207151) then
		local tag = Instance.new("BoolValue",Player)
		tag.Name = "Shoddy"
		tag.Value = true
	end
	if not Player:FindFirstChild("Snowflake") and game.MarketplaceService:PlayerOwnsAsset(Player,324293291) then
		local tag = Instance.new("BoolValue",Player)
		tag.Name = "Snowflake"
		tag.Value = true
	end

-- 2ND GEN ARTIFACTS

	if not Player:FindFirstChild("Mars") and game.MarketplaceService:PlayerOwnsAsset(Player,556758024) then
		local tag = Instance.new("BoolValue",Player)
		tag.Name = "Mars"
		tag.Value = true
	end
	if not Player:FindFirstChild("Nebula") and game.MarketplaceService:PlayerOwnsAsset(Player,556281687) then
		local tag = Instance.new("BoolValue",Player)
		tag.Name = "Nebula"
		tag.Value = true

	end
	if not Player:FindFirstChild("GiantCrate") and game.MarketplaceService:PlayerOwnsAsset(Player,556452016) then
		local tag = Instance.new("BoolValue",Player)
		tag.Name = "GiantCrate"
		tag.Value = true
	end



	if not Player:FindFirstChild("AddictedMiner") and Player:IsInGroup(2628255) then
		local tag = Instance.new("BoolValue",Player)
		tag.Name = "AddictedMiner"
		tag.Value = true
	end

	if not Player:FindFirstChild("RbxDev") and Player:IsInGroup(979242) then
		local tag = Instance.new("BoolValue",Player)
		tag.Name = "RbxDev"
		tag.Value = true
	end
	if not Player:FindFirstChild("BerezaaGames") and Player:IsInGroup(1137635) then
		local tag = Instance.new("BoolValue",Player)
		tag.Name = "BerezaaGames"
		tag.Value = true
	end
	if not Player:FindFirstChild("Fan") and Player:IsInGroup(2569809) then
		local tag = Instance.new("BoolValue",Player)
		tag.Name = "Fan"
		tag.Value = true
	end

	if not Player:FindFirstChild("Fool") and game.BadgeService:UserHasBadge(Player.userId,719514719) then
		local tag = Instance.new("BoolValue",Player)
		tag.Name = "Fool"
		tag.Value = true
	end

	if not Player:FindFirstChild("RAT") and Player:IsInGroup(7013) then
		local tag = Instance.new("BoolValue",Player)
		tag.Name = "RAT"
		tag.Value = true
	end

	if not Player:FindFirstChild("Submitter") and Player:IsInGroup(3076491) then
		local tag = Instance.new("BoolValue",Player)
		tag.Name = "Submitter"
		tag.Value = true
	end
	if not Player:FindFirstChild("RobloxStaff") and Player:IsInGroup(1200769) then
		local tag = Instance.new("BoolValue",Player)
		tag.Name = "RobloxStaff"
		tag.Value = true
	end
	if not Player:FindFirstChild("VIP") and game.MarketplaceService:PlayerOwnsAsset(Player,304936437) then
		local tag = Instance.new("BoolValue",Player)
		tag.Name = "VIP"
		tag.Value = true
	end
	wait(300)
end
game.Players.PlayerAdded:connect(Validate)
for i,Player in pairs(game.Players:GetPlayers()) do
	Validate(Player)
end