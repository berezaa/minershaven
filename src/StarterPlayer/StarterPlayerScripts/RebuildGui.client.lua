local Player = game.Players.LocalPlayer
repeat wait() until Player.PlayerGui:FindFirstChild("GUI")
Player.CharacterAdded:Connect(function(player)
	local GUI = game.ReplicatedStorage:WaitForChild("GUI")
	GUI:Clone().Parent = Player.PlayerGui
end)
