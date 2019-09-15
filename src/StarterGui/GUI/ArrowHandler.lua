local runService = game:GetService("RunService")


local module = {}

local Arrows = {}


function module.addConveyor(Object)
	if Object:FindFirstChild("Hitbox") and Object:FindFirstChild("Model") then
		-- Conveyor arrows
		local Multi = 100
		for _,Part in pairs(Object.Model:GetChildren()) do
			if Part.Name == "Conv" or Part.Name == "Conveyor" then
				local Decal = Part:FindFirstChild("ConveyorArrow")
				if not Decal then
					Decal = script.ConveyorArrow:Clone()
					Decal.Parent = Part
				else
					for i = 1,#Arrows do
						if Arrows[i] == Decal.Frame.Icon then
							return
						end
					end
				end

				if Part.Size.Z < 4.5 or Part.Size.X < 4.5 then
					Multi = 200
				end
				Decal.CanvasSize = Vector2.new(Part.Size.Z * Multi, Part.Size.X * Multi)
				Decal.Frame.Icon.Size = UDim2.new(1,600,1,0)
				Decal.Frame.Icon.Position = UDim2.new(0,-600,0,0)
				Decal.Frame.Icon.ImageTransparency = 0
				Decal.Adornee = Part
				table.insert(Arrows,Decal.Frame.Icon)
			end
		end
	end
end

function module.removeConveyor(Object)
	if Object:FindFirstChild("Hitbox") and Object:FindFirstChild("Model") then
		for _,Part in pairs(Object.Model:GetChildren()) do
			if Part.Name == "Conv" or Part.Name == "Conveyor" then
				local Decal = Part:FindFirstChild("ConveyorArrow")
				if Decal then
					for i = 1,#Arrows do
						if Arrows[i] == Decal then
							table.remove(Arrows,i)
						end
					end
					Decal:Destroy()
				end
			end
		end
	end
end

function module.init(Modules)

	local ac = 0
	runService.Heartbeat:Connect(function()
		if #Arrows > 0 then

			ac = ac + 1
			if ac > 120 then
				ac = 0
			end

			for i = 1,#Arrows do
				local Decal = Arrows[i]
				if Decal and Decal:IsDescendantOf(workspace) then
					Decal.Position = UDim2.new(0,(ac*5)-600,0,0)
				else
					if Decal and Decal.Parent then
						Decal:Destroy()
					end
					table.remove(Arrows,i)
				end
			end
		end
	end)
end

return module
