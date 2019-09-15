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
			if Player ~= nil then
				Enabled = false
				script.Parent.Open:Play()
				wait(0.3)
				Instance.new("Sparkles",script.Parent)


				local Amount = math.random(1,3)
				Player.Clovers.Value = Player.Clovers.Value + Amount
				game.ReplicatedStorage.Currency:FireClient(Player,script.Parent,"+"..Amount.." Lucky Clover",Color3.new(0.3, 1, 0.4),3,245520987)
					--[[
				if player:FindFirstChild("GoldClovers") then
					local amount = math.random(0,4)
					if amount > 0 then
						game.ReplicatedStorage.Currency:FireClient(Player,script.Parent,"+"..amount.." Gold Clover",Color3.new(1, 1, 0.4),3,245520987)
						game.ReplicatedStorage.Hint:FireClient(player,"You found "..amount.." Gold Clovers!")
						player.GoldClovers.Value = player.GoldClovers.Value + amount
					end
				end
					]]
				local chance = math.random(1,3)
				if chance == 2 then

					local Box = game.ReplicatedStorage.Boxes.Regular
					game.ReplicatedStorage.CurrencyPopup:FireClient(Player,Box.Name.." Box",Box.BoxColor.Value,"rbxassetid://"..Box.ThumbnailId.Value)

					--game.ReplicatedStorage.Hint:FireClient(Player,"You found a regular box!")
					Player.Crates.Regular.Value = Player.Crates.Regular.Value + 1
					spawn(function()
						wait(0.3)
						game.ReplicatedStorage.Currency:FireClient(Player,script.Parent,"+1 Regular Box",Color3.new(1, 17/25, 8/25),3,131144461)
					end)
				else -- If you don't get a crate
					local chance = math.random(1,10)
					if chance == 3 then


					local Box = game.ReplicatedStorage.Boxes.Unreal
					game.ReplicatedStorage.CurrencyPopup:FireClient(Player,Box.Name.." Box",Box.BoxColor.Value,"rbxassetid://"..Box.ThumbnailId.Value)

						--game.ReplicatedStorage.Hint:FireClient(Player,"Woah! You found an unreal box!")
						Player.Crates.Unreal.Value = Player.Crates.Unreal.Value + 1
						spawn(function()
							wait(0.3)
							game.ReplicatedStorage.Currency:FireClient(Player,script.Parent,"+1 Unreal Box",Color3.new(17/25, 4/25, 1),3,131144461)
						end)
					end
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