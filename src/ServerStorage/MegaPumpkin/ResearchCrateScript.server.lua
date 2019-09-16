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
				Player.Pumpkins.Value = Player.Pumpkins.Value + 1
				if Player.Pumpkins.Value < 100 then
					game.ReplicatedStorage.Currency:FireClient(Player,script.Parent,tostring(Player.Pumpkins.Value).."/100",Color3.new(1, 1, 1),2)
				elseif Player.Pumpkins.Value == 100 then
					game.ReplicatedStorage.Currency:FireClient(Player,script.Parent,"Pumpkin Hero obtained!",Color3.new(1, 1, 1),2)
					game.ServerStorage.AwardItem:Invoke(Player,315,1)
					game.BadgeService:AwardBadge(Player.userId,527864873)

					local DataStore = game:GetService("DataStoreService"):GetDataStore("GlobalAnnouncement")
					local Data = {Player.Name.." completed the Pumpkin Quest!",{0.7,0.5,0.3},{0,0,0},{0,0,0}}
					DataStore:SetAsync("Announcement",Data)
				end
				game.ReplicatedStorage.Hint:FireClient(Player,"You found an Unreal box!")
				Player.Crates.Unreal.Value = Player.Crates.Unreal.Value + 1
				spawn(function()
					wait(0.4)
					game.ReplicatedStorage.Currency:FireClient(Player,script.Parent,"+1 Unreal Box",Color3.new(1, 17/25, 8/25),2,131144461)
				end)
				game.ServerStorage.AwardItem:Invoke(Player,321,1)
				game.ReplicatedStorage.Currency:FireClient(Player,script.Parent,"Candy Bag Obtained",Color3.new(1, 17/25, 8/25),2,131144461)
				game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." destroyed the Mega Pumpkin!")
				wait(0.35)
				script.Parent.Anchored = true
				script.Parent.CanCollide = false

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