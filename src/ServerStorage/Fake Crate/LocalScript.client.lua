local db = true
script.Parent.Activated:connect(function()
	local Player = game.Players.LocalPlayer
	if Player.Character and Player.Character:FindFirstChild("Head") and db then
		db = false
		local Pos = Player.Character.Head.CFrame + workspace.CurrentCamera.CFrame.lookVector * 35 + Vector3.new(0,40,0) -- Spawn in front of char
		-- because im too lazy to use cursor pos
		game.ReplicatedStorage.FakeCrate:InvokeServer(Pos)
		wait(15)
		db = true
	end
end)