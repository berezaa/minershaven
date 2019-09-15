local Player = game.Players.LocalPlayer

local PlayerTycoon = Player:WaitForChild("PlayerTycoon")

local TeleportPads = {}

local Tycoon = Player.PlayerTycoon.Value

local Rand = Random.new(tick())

function tween(Object, Properties, Value, Time, Style, Direction)
	Style = Style or Enum.EasingStyle.Quad
	Direction = Direction or Enum.EasingDirection.Out

	Time = Time or 0.5

	local propertyGoals = {}

	local Table = (type(Value) == "table" and true) or false

	for i,Property in pairs(Properties) do
		propertyGoals[Property] = Table and Value[i] or Value
	end
	local tweenInfo = TweenInfo.new(
		Time,
		Style,
		Direction
	)
	local tween = game:GetService("TweenService"):Create(Object,tweenInfo,propertyGoals)
	tween:Play()
end

local function teleport(Ore, Code, Override)
	Override = Override or false
	local Tag
	if not Override then
		Tag = Instance.new("BoolValue")
		Tag.Name = "Teleporting"
		Tag.Parent = Ore
	end
	local oreColor = Ore.Color
	local oreTransparency = Ore.Transparency
	local pads = TeleportPads[Code]
	if pads then
		local n = #pads
		if n > 0 then
			local index = Rand:NextInteger(1,n)
			local telepad = pads[index]
			if telepad == nil or (not telepad:IsDescendantOf(Player.PlayerTycoon.Value)) then
				table.remove(pads,index)
				teleport(Ore, Code)
			else
				spawn(function()
					if not Override then
						tween(Ore,{"Transparency"},1,0.2)
						tween(Ore,{"Color"},telepad.Color,0.5)
						wait(0.5)
					end
					if Ore and telepad then
						-- where the actual teleporting happens!
						Ore.Position = telepad.Position + Vector3.new(math.random(-100,100)/60,0,math.random(-100,100)/60) -- Position over CFrame, clipping is auctually something I want to avoid rn
					else
						teleport(Ore, Code, true)
					end
					if not Override then
						if Tag then
							Tag:Destroy()
						end
						tween(Ore,{"Color"},oreColor,0.5)
						tween(Ore,{"Transparency"},oreTransparency,0.2)
					end
				end)
			end
		end
	end
end


local function Check(Object)

	if Object.Name == "ConveyorSpeed" then
		local Speed = Object.Value
		local Conveyor = Object.Parent
		Conveyor.Velocity = Conveyor.CFrame.lookVector * Speed


	elseif Object.Name == "Error" and Object.Parent.Name == "Upgrade" then
		if Object.Parent.Parent.Parent:FindFirstChild("LocalItem") == nil then
			Object.Parent:GetPropertyChangedSignal("CFrame"):Connect(function()
				if Object.Parent then
					Object.Parent:Destroy()
				end
			end)
		end

	elseif Object.Name == "OreTeleTag" then

		Object.Parent.Touched:connect(function(Hit)
			if Hit:FindFirstChild("Cash") and Hit:FindFirstChild("Tele") == nil then
				local Tag = Instance.new("BoolValue")
				Tag.Name = "Tele"
				Tag.Parent = Hit
				local Color = Hit.Color
				local Transp = Hit.Transparency
				local Parent = Hit.Parent

				tween(Hit,{"Color","Transparency"},{Object.Parent.Color, 1},0.4)
				Hit.Velocity = Vector3.new(0,0,0)

				wait(0.4)

				Hit.CFrame = CFrame.new(Object.Parent.Parent.Pad.Position + Vector3.new(math.random(-5,5)/3,math.random(3,6)/3,math.random(-5,5)/3))
				Hit.Velocity = Vector3.new(0,0,0)

				tween(Hit,{"Color","Transparency"},{Color,Transp},0.4)




				if Hit and Tag then
					Tag:Destroy()
				end
			end
		end)

	elseif Object:IsA("StringValue") then

		if Object.Parent.Parent.Parent:FindFirstChild("LocalItem") then
			return false
		end

		local Code = Object.Value

		if Object.Name == "TeleportSend" then


			local Teleporter = Object.Parent

			Teleporter.Touched:Connect(function(Ore)
				if Ore:FindFirstChild("Cash") and Ore:FindFirstChild("Teleporting") == nil then

					if TeleportPads[Code] and #TeleportPads[Code] > 0 then

						teleport(Ore, Code)

					end
				end
			end)


		elseif Object.Name == "TeleportPad" then



			TeleportPads[Code] = TeleportPads[Code] or {}
			table.insert(TeleportPads[Code],Object.Parent)
		end

	elseif Object:IsA("BasePart") and Object.Name == "Boost" and Object.Parent.Parent.Name == "Ore Hoister" then

		Object.Touched:Connect(function(hit)
			if hit:FindFirstChild("Cash") then
				if Object.Parent:FindFirstChild("Ref") then
					local Velo = Instance.new("BodyVelocity")
					Velo.Velocity = Object.CFrame.lookVector * 40
					Velo.Parent = hit
					wait(0.2)
					if hit and Velo then
						Velo.Velocity = Object.Parent.Ref.CFrame.lookVector * 20
					end
					wait(0.2)
					if Velo then
						Velo:Destroy()
					end
				end
			end
		end)


	elseif Object:IsA("IntValue") and Object.Name == "Speed" and Object.Parent.Name == "Cannon" then

		if Object.Parent.Parent.Parent:FindFirstChild("LocalItem") then
			return false
		end

		Object.Parent.Touched:Connect(function(hit)

			if hit:FindFirstChild("Cash") then
				if hit:FindFirstChild("RealBodyVelocity") == nil then

					local Velo = Instance.new("BodyVelocity")
					Velo.Velocity = Object.Parent.CFrame.lookVector*Object.Value
					Velo.Name = "RealBodyVeocity"
					Velo.Parent = hit

					game.Debris:AddItem(Velo,0.1)
				end
			end
		end)

	end

end

local function Scan(Model)
	for i,Object in pairs(Model:GetDescendants()) do
		Check(Object)
	end
	Model.DescendantAdded:Connect(Check)
end

repeat wait() until PlayerTycoon.Value

print("Found tycoon!!")

local Tycoon = PlayerTycoon.Value
Scan(Tycoon)
