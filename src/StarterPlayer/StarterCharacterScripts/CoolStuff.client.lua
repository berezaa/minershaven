local Boom = game.ReplicatedStorage:WaitForChild("Boom")

function tween(Object, Properties, Value, Time, Style)
	Style = Style or Enum.EasingStyle.Quad

	Time = Time or 0.5

	local propertyGoals = {}

	local Table = (type(Value) == "table" and true) or false

	for i,Property in pairs(Properties) do
		propertyGoals[Property] = Table and Value[i] or Value
	end
	local tweenInfo = TweenInfo.new(
		Time,
		Style,
		Enum.EasingDirection.Out
	)
	local tween = game:GetService("TweenService"):Create(Object,tweenInfo,propertyGoals)
	tween:Play()
end


Boom.OnClientEvent:connect(function(Model,Exp)
	if Model.Parent and Model.Parent.Name == "EventClovers" then
		Model.Transparency = 0
		tween(Model,{"Transparency"},{1},2)
	else
		Exp = Exp or 1
		local Temp = Model:Clone()
		Model:Destroy()
		Model = Temp
		Model.Parent = workspace
		local Pos = Vector3.new(0,0,0)
		local Count = 0
		for i,Part in pairs(Model:GetDescendants()) do
			if Part:IsA("BasePart") then
				Pos = Pos + Part.Position
				Count = Count + 1
				Part.Anchored = false
			end
		end
		Model:BreakJoints()
		local Avg = Pos / Count
		local ExpPart = Instance.new("Part",Model)
		ExpPart.Anchored = true
		ExpPart.Transparency = 1
		ExpPart.CFrame = CFrame.new(Avg)
		local Sound = script.Explode:Clone()
		Sound.Parent = ExpPart
		Sound:Play()
		local Explode = Instance.new("Explosion")
		Explode.DestroyJointRadiusPercent = 0
		Explode.BlastPressure = Explode.BlastPressure * Exp
		Explode.Parent = workspace
		Explode.Position = Avg
		wait(3)
		Model:Destroy()
	end

end)

local Character = game.Players.LocalPlayer.Character
Character.Humanoid.Died:connect(function()
	script.Sound:Play()
end)