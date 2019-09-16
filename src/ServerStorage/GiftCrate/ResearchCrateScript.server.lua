local Enabled = true
script.Parent.Touched:connect(function(hit)

	if (hit.Position - script.Parent.Position).Magnitude > 30 then
		return false
	end

	if Enabled then
		local human = hit.Parent:FindFirstChild("Humanoid")
		if human then
			local Player = game.Players:GetPlayerFromCharacter(human.Parent)
			local player = Player
			local Owner = script.Parent.Owner.Value
			if Player and (Owner == nil or player == Owner) then
				Enabled = false
				script.Parent.Open:Play()
				wait(0.3)
				Instance.new("Sparkles",script.Parent)
				local Amount = script.Parent.PointsBase.Value*(math.random(50,150)/100)
				spawn(function()
					game.PointsService:AwardPoints(Player.userId,Amount)
				end)
				game.ReplicatedStorage.Currency:FireClient(Player,script.Parent,"+"..Amount.."RP",Color3.new(0.4,0.5,1),2,245520987)
				local chance = 1

				--[[
				if player:FindFirstChild("GoldClovers") then
					local amount = math.random(0,3)
					if amount > 0 then
						game.ReplicatedStorage.Currency:FireClient(Player,script.Parent,"+"..amount.." Gold Clover",Color3.new(1, 1, 0.4),3,245520987)
						game.ReplicatedStorage.Hint:FireClient(player,"You found "..amount.." Gold Clovers!")
						player.GoldClovers.Value = player.GoldClovers.Value + amount
					end
				end
				]]
				if chance == 1 then -- brilliant coding

					local Box = game.ReplicatedStorage.Boxes.Regular
					game.ReplicatedStorage.CurrencyPopup:FireClient(Player,Box.Name.." Box",Box.BoxColor.Value,"rbxassetid://"..Box.ThumbnailId.Value)

					--game.ReplicatedStorage.Hint:FireClient(Player,"You found a regular box!")
					Player.Crates.Regular.Value = Player.Crates.Regular.Value + 1
					spawn(function()
						wait(0.3)
						game.ReplicatedStorage.Currency:FireClient(Player,script.Parent,"+1 Regular Box",Color3.new(1, 17/25, 8/25),3,131144461)
					end)
				end
				wait(0.35)
				script.Parent.Anchored = true
				script.Parent.CanCollide = false
				for i,v in pairs(script.Parent:GetChildren()) do
					if v:IsA("Decal") then
						v:Destroy()
					end
				end
				for i=1,10 do
					script.Parent.Transparency = script.Parent.Transparency + 0.1
					wait(0.1)
				end
				wait(2.5)
				script.Parent:Destroy()
			end
		end
	end
end)