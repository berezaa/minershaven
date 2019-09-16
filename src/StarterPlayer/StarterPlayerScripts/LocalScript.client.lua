game.StarterGui:SetCore("ChatMakeSystemMessage", {
	Text = "Welcome to Miner's Haven!"; -- Required. Has to be a string!
	Color = Color3.new(0.1, 1, 0.2); -- Cyan is (0, 255 / 255, 255 / 255). Optional, defaults to white: Color3.new(255 / 255, 255 / 255, 243 / 255)
})

game.ReplicatedStorage.SystemAlert.OnClientEvent:connect(function(String,Col,idk,BGCol,Font)
	game.StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = String;
		Color = Col;
		Font = Font;
	})
end)

local Player = game.Players.LocalPlayer


local function getTycoon()
	for i,Tycoon in pairs(workspace.Tycoons:GetChildren()) do
		if Player.PlayerTycoon.Value == Tycoon then
			return Tycoon
		end
	end
end



wait()

--game.CollectionService:GetInstanceAddedSignal("DroppedOre"):Connect(function(Ore)

--[[
local Resolution = workspace.CurrentCamera.ViewportSize.X * workspace.CurrentCamera.ViewportSize.Y
local Details = game.ReplicatedStorage:WaitForChild("Complex")

if Resolution >= 1500000 or not game:GetService("UserInputService").TouchEnabled then
	Details.Parent = workspace.Map
else
	Details:Destroy()
end
]]
Player:WaitForChild("ActiveTycoon")

workspace.DroppedParts.DescendantAdded:Connect(function(Ore)
	wait()
	if Ore and Ore:IsA("BasePart") then

		if Player.ActiveTycoon.Value == Player.PlayerTycoon.Value then

			local Tycoon = Player.ActiveTycoon.Value
			local Parent = workspace.DroppedParts:FindFirstChild(Tycoon.Name)
			if Parent == nil then
				error("DroppedParts not found")
			end


			if Ore.Parent ~= Parent then
				Ore:Destroy()
			end
		end
	end
end)


Player.ActiveTycoon.Changed:connect(function()
	local Tycoon = Player.ActiveTycoon.Value
	if Player.ActiveTycoon.Value == Player.PlayerTycoon.Value then

		local Parent = workspace.DroppedParts:FindFirstChild(Tycoon.Name)
		if Parent == nil then
			error("DroppedParts not found")
		end

		for i,Part in pairs(workspace.DroppedParts:GetDescendants()) do
			if Part and Part:IsA("BasePart") then
				if Part.Parent ~= Parent then
					Part:Destroy()
				end
			end
		end
	end
end)

require(script.Parent.Ambiance).init()



--[[
local run = game:GetService("RunService")
local Player = game.Players.LocalPlayer

while run.Heartbeat:wait() do
	if workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Water") and workspace.CurrentCamera.CFrame.Y <= workspace.Map.Water.CFrame.Y then
		Player.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Zoom
	else
		Player.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
	end
end

]]
--[[
local Snow = script.SnowFloor
Snow.Parent = workspace

local Player = game.Players.LocalPlayer

while game:GetService("RunService").RenderStepped:wait() do
	if Player.Character and Player.Character.PrimaryPart then
		Snow.CFrame = CFrame.new(Player.Character.PrimaryPart.CFrame.p + Vector3.new(0,30,0))
	else
		Snow.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.p + Vector3.new(0,30,0))
	end
end]]