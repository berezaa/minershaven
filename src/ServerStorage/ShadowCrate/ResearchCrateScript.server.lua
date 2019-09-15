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
				local chance = math.random(3,6)
				if chance == 5 then

					local Box = game.ReplicatedStorage.Boxes.Unreal
					game.ReplicatedStorage.CurrencyPopup:FireClient(Player,Box.Name.." Box",Box.BoxColor.Value,"rbxassetid://"..Box.ThumbnailId.Value)

					--game.ReplicatedStorage.Hint:FireClient(Player,"Woah! You found an unreal box!")
					Player.Crates.Unreal.Value = Player.Crates.Unreal.Value + 1
					spawn(function()
						wait(0.3)
						game.ReplicatedStorage.Currency:FireClient(Player,script.Parent,"+1 Unreal Box",Color3.new(17/25, 4/25, 1),3,131144461)
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