local Enabled = true
script.Parent.Touched:connect(function(hit)
	if Enabled then
		local human = hit.Parent:FindFirstChild("Humanoid")
		if human then
			local Player = game.Players:GetPlayerFromCharacter(human.Parent)
			if Player ~= nil then
				Enabled = false
				local Sparkels = Instance.new("Sparkles",script.Parent)
				script.Parent.Fart:Play()
				wait(0.7)
				local Explode = Instance.new("Explosion",workspace)
				Explode.BlastPressure = 1000000
				Explode.BlastRadius = 45
				Explode.DestroyJointRadiusPercent = 0
				Explode.Position = script.Parent.Position
				script.Parent.Velocity = Vector3.new(math.random(-100,100),math.random(30,100),math.random(-100,100))
				wait(1)
				script.Parent:Destroy()
			end
		end
	end
end)