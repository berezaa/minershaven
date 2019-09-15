local human = script.Parent:WaitForChild("Humanoid")
workspace.CurrentCamera.FieldOfView = 70
workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
workspace.CurrentCamera.CameraSubject = human
if game.Lighting:FindFirstChild("Blur") then
	game.Lighting.Blur.Size = 0
end

local p = human.Parent.HumanoidRootPart

workspace.CurrentCamera.CFrame = CFrame.new(p.Position, p.Position + Vector3.new(15,0,15))