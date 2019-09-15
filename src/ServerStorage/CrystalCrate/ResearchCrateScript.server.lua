local Enabled = true
local bigchance = math.random(1,4)
if bigchance == 3 then
	script.Parent.Size = Vector3.new(8,8,8)
	script.Parent.Material = Enum.Material.Foil
	script.Parent.PointLight.Range = 14
end
script.Parent.Touched:connect(function(hit)

	if (hit.Position - script.Parent.Position).Magnitude > 30 then
		return false
	end

	if Enabled then
		local human = hit.Parent:FindFirstChild("Humanoid")
		if human then
			local Player = game.Players:GetPlayerFromCharacter(human.Parent)
			if Player ~= nil then
				Enabled = false
				script.Parent.Open:Play()
				wait(0.3)
				Instance.new("Sparkles",script.Parent)
				local thing = math.random(1,20)
				local Amount = 1

				if thing < 10 then
					Amount = 1
					if bigchance == 3 then
						Amount = 7
					end
				elseif thing < 16 then
					Amount = 2
					if bigchance == 3 then
						Amount = 8
					end
				elseif thing <= 19 then
					Amount = 3
					if bigchance == 3 then
						Amount = 9
					end
				elseif thing == 20 then
					Amount = 4
					if bigchance == 3 then
						Amount = 10
					end
				end

				Player.Crystals.Value = Player.Crystals.Value + Amount

				-- Game Analytics Currency Reporting
				local CrystalsGained = Amount
				local ProductName = "crystalcrate"
				if true then
					ProductName = ProductName or "unknown"
					game.ServerStorage.CurrencyEvent:Fire(Player, "Crystals", CrystalsGained, "granted", ProductName)
				end
				-- Game Analytics Currency Reporting

				game.ReplicatedStorage.Currency:FireClient(Player,script.Parent,"+"..Amount.."uC",Color3.new(1,0,0.7),2,373341604)
				local chance = math.random(1,3)
				if chance == 2 or bigchance == 3 then
					game.ReplicatedStorage.Hint:FireClient(Player,"You found a regular box!")
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