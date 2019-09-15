script.Parent.Fixer.Touched:connect(function(Hit)
	if Hit.Parent:FindFirstChild("Humanoid") then
		local Player = game.Players:GetPlayerFromCharacter(Hit.Parent)
		Hit.Parent.Humanoid:UnequipTools()
		if Player then
			Player.Backpack:ClearAllChildren()
		end
		Hit.Parent.Humanoid.WalkSpeed = 16
		Hit.Parent.Humanoid.JumpPower = 50
	end
end)

local DeeBee = true
script.Parent.Prize.Reward.Touched:connect(function(Hit)
	if DeeBee then
		DeeBee = false
		local Player = game.Players:GetPlayerFromCharacter(Hit.Parent)
		if Player and Player:FindFirstChild("GoldClovers") and Player:FindFirstChild("TrialMode") then
			if Player.TrialMode.Value ~= "John" then
				Player.TrialMode.Value = "John"
				script.Parent.Prize:Destroy()
				game.ReplicatedStorage.Hint:FireClient(Player,"You got 30 Gold Clovers for beating John Doe's trial!")
				Player.GoldClovers.Value = Player.GoldClovers.Value + 30
				game.BadgeService:AwardBadge(Player.userId,700526907)
			else
				script.Parent.Prize:Destroy()
			end
		end
		wait(0.1)
		DeeBee = true
	end
end)