-- Uber realistic timeofday script by berezaa
-- "Super simple, just brilliant" ~Builderman


DAY_TIME_IN_MIN = 20

if game.VIPServerId ~= "" and game.VIPServerOwnerId == 0 then
	game.ReplicatedStorage.NightTime.Value = false
	game.ServerStorage.NightTime.Value = false
	game.Lighting.TimeOfDay = 14
else
	game.ReplicatedStorage.NightTime.Value = true
	game.ServerStorage.NightTime.Value = true
end

local dhour = 10
local dmin = 0

math.randomseed(os.time())
for i=1,math.random(7,10) do
	math.random()
	math.random(1,10)
end


local Range
if workspace:FindFirstChild("Private") then
	if game.ReplicatedStorage:FindFirstChild("Mars") then
		Range = 17500
	else
		Range = 25000
	end
else
	Range = 6000
end


workspace:WaitForChild("Tycoons")

local Tycoons = {}
for i,Tycoon in pairs(workspace.Tycoons:GetChildren()) do
	if Tycoon:FindFirstChild("Base") then
		table.insert(Tycoons,Tycoon)
	end
end

-- support new players with extra crates

spawn(function()
	while wait(180) do
		for i,Player in pairs(game.Players:GetPlayers()) do
			if Player.Points.Value < 100000 then
				local Tycoon = Player.PlayerTycoon.Value
				if Tycoon and Tycoon.Base then
					local Crate = game.ServerStorage.ResearchCrate:Clone()
					Crate.CFrame = Tycoon.Base.CFrame + Vector3.new(math.random(-50,50),100,math.random(-50,50))
					Crate.Parent = workspace
					game.Debris:AddItem(Crate,600)
				end
			end
		end
	end
end)


while true do
	wait(DAY_TIME_IN_MIN/48)
	-- FRIDAY NIGHT CHANGE
	-- ENTER AROUND A RANDOM TYCOON

	local PCFrame = Tycoons[math.random(1,#Tycoons)].Base.CFrame + Vector3.new(0,100,0)
	local FinFrame = PCFrame + Vector3.new(math.random(-200,200),5,math.random(-200,200))

	local Chance = math.random(1,Range)
	if (game.ReplicatedStorage.NightTime.Value and (Chance == 3400 or Chance == 3700)) or Chance == 2183 then
		local Crate = game.ServerStorage.DiamondCrate:Clone()
		Crate.CFrame = FinFrame
		Crate.Parent = workspace
		game.Debris:AddItem(Crate,600)
		game.ReplicatedStorage.SystemAlert:FireAllClients("A Diamond Crate has appeared!",Color3.new(39/255, 200/255, 255/255))
	elseif (game.ReplicatedStorage.NightTime.Value and Chance == 4777) or Chance == 777 then
		local Crate = game.ServerStorage.LuckyCrate:Clone()
		Crate.CFrame = FinFrame
		Crate.Parent = workspace
		game.Debris:AddItem(Crate,300)
		game.ReplicatedStorage.SystemAlert:FireAllClients("A Lucky Crate has appeared!",Color3.new(33/255, 255/255, 114/255))
	elseif Chance == 4000 or Chance == 1000 or Chance == 5800 or Chance == 2000 or Chance == 2005 or Chance == 2008 then
		local Crate = game.ServerStorage.CrystalCrate:Clone()
		Crate.CFrame = FinFrame
		Crate.Parent = workspace
		game.Debris:AddItem(Crate,500)
	end
	if game.ReplicatedStorage.NightTime.Value then
		dmin = dmin + 2
		local Chance = math.random(1,(workspace:FindFirstChild("Private") and 1300) or 300)
		if Chance <= 7 then
			local Crate = game.ServerStorage.ResearchCrate:Clone()
			Crate.CFrame = FinFrame
			Crate.Parent = workspace
			game.Debris:AddItem(Crate,300)
		elseif Chance == 8 or Chance == 9 then
			local Crate = game.ServerStorage.GoldenCrate:Clone()
			Crate.CFrame = FinFrame
			Crate.Parent = workspace
			game.Debris:AddItem(Crate,300)
			--[[
		elseif Chance == 12 or Chance == 15 then
			local Crate = game.ServerStorage.Gift:Clone()
			Crate.CFrame = workspace.Location.Value + Vector3.new(math.random(-450,450),0,math.random(-450,450))
			Crate.Parent = workspace
			game.Debris:AddItem(Crate,300)
			]]
		elseif Chance == 10 or Chance == 11 or Chance == 15 or Chance == 17 then
			local Crate = game.ServerStorage.ShadowCrate:Clone()
			Crate.CFrame = FinFrame
			Crate.Parent = workspace.Shadows -- Deleted when day comes
			game.Debris:AddItem(Crate,60)
		end
	else
		if #workspace.Shadows:GetChildren() > 0 then
			workspace.Shadows:ClearAllChildren()
		end
		local Chance = math.random(1,600)
		if Chance == 5 or Chance == 6 or Chance == 7 or Chance == 14 or Chance == 18 or Chance == 22 then
			local Crate = game.ServerStorage.ResearchCrate:Clone()
			Crate.CFrame = FinFrame
			Crate.Parent = workspace
			game.Debris:AddItem(Crate,300)
			--[[
		elseif Chance == 9 then
			local Crate = game.ServerStorage.Gift:Clone()
			Crate.CFrame = workspace.Location.Value + Vector3.new(math.random(-450,450),0,math.random(-450,450))
			Crate.Parent = workspace
			game.Debris:AddItem(Crate,300)
			]]
		end
		dmin = dmin + 1
	end

	if dmin >= 120 then
		dmin = 0
		dhour = dhour + 1
		if dhour >= 24 then
			dhour = 0
		end
	end

	game.ServerStorage.NightTime.Value = ((dhour > 17 and dmin > 20) or dhour > 18 or (dhour < 6 and dmin < 15) or dhour < 7)
	game.ReplicatedStorage.NightTime.Value = game.ServerStorage.NightTime.Value

	game.Lighting.TimeOfDay = dhour..":"..dmin/2

end

