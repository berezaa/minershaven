
--SERVER SCRIPT BY LOCARD
--MADE ONLY TO CHANGE THE VALUE OF Player.PlayerTutorialStep

local repStorage = game:GetService("ReplicatedStorage")

local event = repStorage:WaitForChild("SetTutorialStep")

local function startMission(Player, v)
	if v then
		local Mission
		if v == 1 then
			Mission = "Tutorial:CellFurnace"
		elseif v == 2 then
			Mission = "Tutorial:BaseMine"
		elseif v == 3 then
			Mission = "Tutorial:AdvancedMine"
		end
		if Mission then
			local Status = "Start"
			game.ServerStorage.ReportProgression:Invoke(Player, Status, Mission)
			local Attempts = Player:FindFirstChild("PlayerTutorialAttempts")
			Attempts.Value = Attempts.Value + 1
			local StartTime = Player:FindFirstChild("TutorialStepStartTime")
			if StartTime == nil then
				StartTime = Instance.new("IntValue")
				StartTime.Name = "TutorialStepStartTime"
				StartTime.Value = os.time()
				StartTime.Parent = Player
			end
		end
	end
end

local function endMisison(Player, v, Status)
	if v then
		local Mission
		if v == 1 then
			Mission = "Tutorial:CellFurnace"
		elseif v == 2 then
			Mission = "Tutorial:BaseMine"
		elseif v == 3 then
			Mission = "Tutorial:AdvancedMine"
		end
		if Mission then
			local EventId = Mission
			local Attempt = Player.PlayerTutorialAttempts.Value + 1
			local Score = os.time() - Player.TutorialStepStartTime.Value
			game.ServerStorage.ReportProgression:Invoke(Player, Status, EventId, Attempt, Score)
		end
	end
end

event.OnServerEvent:Connect(function(Player,val)
	local valType = type(val)
	if not (valType == 'number' and val > -1 and val <= 10) then
		return
	end

	local v = Player:FindFirstChild("PlayerTutorialStep")

	local oldval = v.Value

	--[[
	if val < oldval then -- no backsies for now!
		return false
	end	]]--

	if oldval == 0 and val == 10 then -- Skipped tutorial
		game.ServerStorage.ReportEvent:Invoke(Player, "tutorial:reject")
	elseif oldval == 0 and val == 1 then -- Accepted tutorial
		game.ServerStorage.ReportEvent:Invoke(Player, "tutorial:accept")
	end

	if val == oldval + 1 or val == 9 then

		if (oldval == 1 or oldval == 2 or oldval == 3) then
			endMisison(Player, oldval, "Complete")
		end
		if (val == 1 or val == 2 or val == 3) then
			local Attempts = Player:FindFirstChild("PlayerTutorialAttempts")
			Attempts.Value = 0
			startMission(Player, val)
		end

	end

	v.Value = val
end)

game.ServerStorage.PlayerDataLoaded.Event:Connect(function(Player)
	local v = Player:FindFirstChild("PlayerTutorialStep")
	if v then
		startMission(Player, v.Value)
	end
end)

game.Players.PlayerRemoving:Connect(function(Player)
	local v = Player:FindFirstChild("PlayerTutorialStep")
	if v then
		endMisison(Player, v.Value, "Fail")
	end
end)