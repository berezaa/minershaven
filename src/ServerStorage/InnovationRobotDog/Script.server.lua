-- // Created by StarWars
local InsertService = game:GetService("InsertService")

local Tool = script.Parent
Tool.RequiresHandle = false

if Tool:FindFirstChild("Handle") then
	Tool.Handle:Destroy()
end

if Tool:FindFirstChild("Display") then
	Tool.Display:Destroy()
end

local RobotDog = InsertService:LoadAsset(1374012792)
RobotDog = RobotDog:GetChildren()[1]:Clone()

local CurrentRobotDog = nil
local Character = nil

function OnEquipped()
	Character = Tool.Parent
	CurrentRobotDog = RobotDog:Clone()
	local Owner = Instance.new("ObjectValue")
	Owner.Name = "Owner"
	Owner.Value = Character
	Owner.Parent = CurrentRobotDog

	CurrentRobotDog.Name = Character.Name .. "'s_RobotDog"
	CurrentRobotDog.Parent = workspace
	CurrentRobotDog:MakeJoints()
	CurrentRobotDog:MoveTo((Owner.Value.PrimaryPart.CFrame * CFrame.new(4, 0, 3)).p)
end

function OnUnequip()
	if CurrentRobotDog then
		CurrentRobotDog:Destroy()
	end

	CurrentRobotDog = nil
	Character = nil
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequip)