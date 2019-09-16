

local function SpawnEgg()
	local Egg = script.Egg:Clone()
	Egg.BrickColor = BrickColor.Random()
	Egg.Parent = workspace.Eggs
	return Egg
end

local function RespawnEggs()
	workspace.Eggs:ClearAllChildren()
	local NumPlayers = #game.Players:GetPlayers()

	if workspace.Map:FindFirstChild("EggSpawns") then
		print("Map Spawns")
		for i,Spawn in pairs(workspace.Map.EggSpawns:GetChildren()) do
			local Chance = math.random(1,3)
			if Chance == 1 or (NumPlayers >= 4 and Chance == 2) then
				local Egg = SpawnEgg()
				Egg.Anchored = true
				Egg.CFrame = Spawn.CFrame
			end

		end
	end

	for i=1,NumPlayers * 3 do
		local Egg = SpawnEgg()
		Egg.CFrame = workspace.Location.Value + Vector3.new(math.random(-350,350),0,math.random(-350,350))
		Egg.Anchored = false
	end

	game.ReplicatedStorage.SystemAlert:FireAllClients("New Easter Eggs have appeared on the map!",Color3.new(240/255, 73/255, 1))

end

game.ReplicatedStorage.Click.OnServerEvent:connect(function(Player,Target)
	if Target.Parent == workspace.Eggs and Target.Transparency == 0 then
		if Player:DistanceFromCharacter(Target.Position) <= 12 then

			Target.Transparency = 0.5
			Instance.new("Sparkles",Target)

			Player.EasterEggs.Value = Player.EasterEggs.Value + 1


			if Player.EasterEggs.Value == 5 then
				game.ServerStorage.AwardItem:Invoke(Player,391)
				game.ReplicatedStorage.Hint:FireClient(Player,"Congrats on finding 5 hidden Easter Eggs!")
				pcall(function()
					game.BadgeService:AwardBadge(Player.userId,739626765)
				end)
			end

			local Reward = math.random(1,30)

			if Reward < 5 then
				local Amount = math.random(3,10)
				Player.Crystals.Value = Player.Crystals.Value + Amount
				game.ReplicatedStorage.Currency:FireClient(Player,Target,"+"..Amount.."uC",Color3.new(1,0,0.7),2,373341604)
			elseif Reward == 5 or Reward == 6 then
				game.ReplicatedStorage.Hint:FireClient(Player,"Woah! You found an unreal box!")
				Player.Crates.Unreal.Value = Player.Crates.Unreal.Value + 1
				game.ReplicatedStorage.Currency:FireClient(Player,Target,"+1 Unreal Box",Color3.new(17/25, 4/25, 1),3,131144461)
			elseif Reward == 7 then
				game.ReplicatedStorage.Hint:FireClient(Player,"Woah! You found two unreal boxes!")
				Player.Crates.Unreal.Value = Player.Crates.Unreal.Value + 2
				game.ReplicatedStorage.Currency:FireClient(Player,Target,"+2 Unreal Box",Color3.new(17/25, 4/25, 1),3,131144461)
			elseif Reward > 7 and Reward < 11 then
				game.ReplicatedStorage.SystemAlert:FireAllClients(Player.Name.." found a lucky clover!")
				Player.Clovers.Value = Player.Clovers.Value + 1
				game.ReplicatedStorage.Currency:FireClient(Player,Target,"+1 Lucky Clover",Color3.new(0.3, 1, 0.4),3,245520987)
			elseif Reward >= 11 and Reward < 18 then
				game.ReplicatedStorage.Hint:FireClient(Player,"You found a regular box!")
				Player.Crates.Regular.Value = Player.Crates.Regular.Value + 1
				game.ReplicatedStorage.Currency:FireClient(Player,Target,"+1 Regular Box",Color3.new(1, 17/25, 8/25),3,131144461)
			elseif Reward >= 18 and Reward < 25 then
				game.ServerStorage.AwardItem:Invoke(Player,395)
				game.ReplicatedStorage.Currency:FireClient(Player,Target,"+1 Easter Conveyor",Color3.new(1, 17/25, 8/25),3,131144461)
			elseif Reward >= 25 and Reward < 27 then
				game.ServerStorage.AwardItem:Invoke(Player,393)
				game.ReplicatedStorage.Currency:FireClient(Player,Target,"+1 Easter Wall",Color3.new(1, 17/25, 8/25),3,131144461)
			elseif Reward == 27 then
				game.ServerStorage.AwardItem:Invoke(Player,386)
				game.ReplicatedStorage.Currency:FireClient(Player,Target,"+1 Easter Security Wall",Color3.new(1, 17/25, 8/25),3,131144461)
			elseif Reward == 28 then
				game.ServerStorage.AwardItem:Invoke(Player,395,2)
				game.ReplicatedStorage.Currency:FireClient(Player,Target,"+2 Easter Conveyor",Color3.new(1, 17/25, 8/25),3,131144461)
			else
				game.ReplicatedStorage.Hint:FireClient(Player,"You found two regular boxes!")
				Player.Crates.Regular.Value = Player.Crates.Regular.Value + 2
				game.ReplicatedStorage.Currency:FireClient(Player,Target,"+2 Regular Box",Color3.new(1, 17/25, 8/25),3,131144461)
			end

			wait(1.5)
			Target:Destroy()

		end
	end
end)


if game.VIPServerId == "" or game.VIPServerOwnerId > 0 then

	while wait(1800) do
		RespawnEggs()
		wait(1800)
	end

end
