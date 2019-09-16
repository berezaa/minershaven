local Enabled = true
script.Parent.Touched:connect(function(hit)
	if Enabled then
		local human = hit.Parent:FindFirstChild("Humanoid")
		if human then
			local Player = game.Players:GetPlayerFromCharacter(human.Parent)
			if Player ~= nil then
				Enabled = false
				script.Parent.Open:Play()
				wait(0.3)
				Instance.new("Sparkles",script.Parent)
				local Amount = script.Parent.PointsBase.Value*(math.random(50,150)/100)
				spawn(function()
					game.PointsService:AwardPoints(Player.userId,Amount)
				end)
				game.ReplicatedStorage.Currency:FireClient(Player,script.Parent,"+"..Amount.."RP",Color3.new(0.4,0.5,1),2,245520987)
				local chance = math.random(1,30)





				local Infusion = human.Parent:FindFirstChild("Infusion")

				if chance == 13 or (Player:FindFirstChild("Gambler") and chance == 14) then
					--game.ReplicatedStorage.Hint:FireClient(Player,"OMGGG! You found an inferno box!")

					local Box = game.ReplicatedStorage.Boxes.Inferno
					game.ReplicatedStorage.CurrencyPopup:FireClient(Player,Box.Name.." Box",Box.BoxColor.Value,"rbxassetid://"..Box.ThumbnailId.Value)


					game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." found an Inferno Box!")
					Player.Crates.Inferno.Value = Player.Crates.Inferno.Value + 1
					spawn(function()
						wait(0.3)
						game.ReplicatedStorage.Currency:FireClient(Player,script.Parent,"+1 Inferno Box",Color3.new(1, 6/25, 0),4,131144461)
					end)
				elseif chance < 10 then

					local Box = game.ReplicatedStorage.Boxes.Unreal
					game.ReplicatedStorage.CurrencyPopup:FireClient(Player,Box.Name.." Box",Box.BoxColor.Value,"rbxassetid://"..Box.ThumbnailId.Value)

					--game.ReplicatedStorage.Hint:FireClient(Player,"Woah! You found an unreal box!")
					Player.Crates.Unreal.Value = Player.Crates.Unreal.Value + 1
					spawn(function()
						wait(0.3)
						game.ReplicatedStorage.Currency:FireClient(Player,script.Parent,"+1 Unreal Box",Color3.new(17/25, 4/25, 1),3,131144461)
					end)
				elseif ((Infusion ~= nil and Infusion.Value == "Luck") and chance == 12) or chance == 11 then
					game.ReplicatedStorage.Hint:FireClient(Player,"OMGGG! You found a lucky clover!")
					game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." found a lucky clover!")
					Player.Clovers.Value = Player.Clovers.Value + 1
					game.ReplicatedStorage.Currency:FireClient(Player,script.Parent,"+1 Lucky Clover",Color3.new(0.3, 1, 0.4),3,245520987)
				else

					local Box = game.ReplicatedStorage.Boxes.Regular
					game.ReplicatedStorage.CurrencyPopup:FireClient(Player,Box.Name.." Box",Box.BoxColor.Value,"rbxassetid://"..Box.ThumbnailId.Value)

					--game.ReplicatedStorage.Hint:FireClient(Player,"You found a regular box!")
					Player.Crates.Regular.Value = Player.Crates.Regular.Value + 1
					spawn(function()
						wait(0.3)
						game.ReplicatedStorage.Currency:FireClient(Player,script.Parent,"+1 Regular Box",Color3.new(1, 17/25, 8/25),3,131144461)
					end)
				end
				-- ARTIFACT EVENT

				local gears = {}
				for i,v in pairs(game.Lighting:GetChildren()) do
					if v:IsA("Tool") then
						table.insert(gears,v)
					end
				end
				local rando = math.random(1,#gears)
				local gear = gears[rando]
				gear:Clone().Parent = Player.Backpack
				game.ReplicatedStorage.Hint:FireClient(Player,"You've been armed with a "..gear.Name.."!")
				game.ReplicatedStorage.Hint:FireClient(Player,"You feel a strange force, filling you with power.")
				pcall(function()
					Player.Character.Humanoid.MaxHealth = Player.Character.Humanoid.MaxHealth + 15
					Player.Character.Humanoid.WalkSpeed = Player.Character.Humanoid.WalkSpeed + 3
					Player.Character.Humanoid.JumpPower = Player.Character.Humanoid.JumpPower + 5
					Player.Character.Humanoid.MaxSlopeAngle = Player.Character.Humanoid.MaxSlopeAngle + 10
				end)
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