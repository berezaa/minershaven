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

				local Amount = script.Parent.PointsBase.Value*(math.random(50,150)/100)
				spawn(function()
					game.PointsService:AwardPoints(Player.userId,Amount)
				end)
				game.ReplicatedStorage.Currency:FireClient(Player,script.Parent,"+"..Amount.."RP",Color3.new(0.4,0.5,1),2,245520987)

				local chance = math.random(1,20)

				local Infusion = human.Parent:FindFirstChild("Infusion")
				--[[
				if player:FindFirstChild("GoldClovers") then
					local amount = math.random(0,2)
					if amount > 0 then
						game.ReplicatedStorage.Currency:FireClient(Player,script.Parent,"+"..amount.." Gold Clover",Color3.new(1, 1, 0.4),3,245520987)
						game.ReplicatedStorage.Hint:FireClient(player,"You found "..amount.." Gold Clovers!")
						player.GoldClovers.Value = player.GoldClovers.Value + amount
					end
				end
				]]
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

				for i=1,2 do
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
	--					game.ReplicatedStorage.Currency:FireClient(Player,script.Parent,Item.Name..suf,col,3,nil,("rbxassetid://"..Item.ThumbnailId.Value))
						--Target,String,Color,Time,Audio,Texture
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