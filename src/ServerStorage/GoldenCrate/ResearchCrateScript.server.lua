local Enabled = true
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
				local Amount = script.Parent.PointsBase.Value*(math.random(50,150)/100)
				spawn(function()
					game.PointsService:AwardPoints(Player.userId,Amount)
				end)
				game.ReplicatedStorage.Currency:FireClient(Player,script.Parent,"+"..Amount.."RP",Color3.new(0.4,0.5,1),2,245520987)

				if Player:FindFirstChild("Premium") then
					Player.Clovers.Value = Player.Clovers.Value + 1
					game.ReplicatedStorage.Currency:FireClient(Player,script.Parent,"+1 Lucky Clover",Color3.new(0.3, 1, 0.4),3,245520987)
				end


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
					local chance = math.random(1,25)
					if chance == 17 then

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
				-- ARTIFACT EVENT
				pcall(function()
					if Player:FindFirstChild("Snowflake") then
						Player.Character.Humanoid.WalkSpeed = Player.Character.Humanoid.WalkSpeed + 2
						game.ReplicatedStorage.Hint:FireClient(Player,"WalkSpeed increased by 2.")
					end
				end)

				local Item = require(game.ServerStorage.CrateItems).getItem(Player)
				if Item then
					game.ServerStorage.AwardItem:Invoke(Player,Item.ItemId.Value)
					local Tier = game.ReplicatedStorage.Tiers:FindFirstChild(tostring(Item.Tier.Value))
					local col = Color3.new(0.8,0.8,0.8)
					local suf = ""
					if Tier then
						col = Tier.TierColor.Value
						suf = " ("..Tier.TierName.Value..")"
					end
					game.ReplicatedStorage.CurrencyItem:FireClient(Player,script.Parent,Item,3)
		--			game.ReplicatedStorage.Currency:FireClient(Player,script.Parent,Item.Name..suf,col,3,nil,("rbxassetid://"..Item.ThumbnailId.Value))
					--Target,String,Color,Time,Audio,Texture
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