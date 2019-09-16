--Placement Module 
--Author: Locard

--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
This script was created under a contract originally for exclusive use for this project and the author, Locard.
Please include this copyright & permission notice in all copies or substantial portions of the Software.
]]

--Services
local runService 			= game:GetService('RunService')
local userInputService 		= game:GetService('UserInputService')

--those dank modifiers 
local DEBUG_MODE			= false
local ROTATION_AMOUNT		= math.pi*.5 -- 90 degreeces
local UNIT_SIZE				= 3
local SELECTED_RAISE_OFFSET = 0
local NO_COLLISION_COLOR 	= Color3.new(0.0509804, 0.411765, 0.67451)
local COLLISION_COLOR		= Color3.new(0.768628, 0.156863, 0.109804)
local AXIS_COLOR			= Color3.new(0.227451, 0.490196, 0.0823529)
local AXIS_LOCK_ANGLE 		= .05235987755983


--those dank vars
local currentRotation 		= 0
local Camera 				= workspace.CurrentCamera
local axisAngCos			= math.cos(AXIS_LOCK_ANGLE)
local axisAngSin			= math.sin(AXIS_LOCK_ANGLE)
local zeroVector 			= Vector3.new(0,0,0)
local zeroAngleCF			= CFrame.Angles(0,0,0)
local frontAngleCF			= CFrame.Angles(math.pi*.5,0,0)
local sideAngleCF			= CFrame.Angles(0,0,math.pi*.5)
local Normals 				= {
								Up = Vector3.new(0,1,0);
								Down = Vector3.new(0,-1,0);
							}

local MODULES


--those dank generic functions

function clamp(x,c0,c1)
	return x < c0 and c0 or x > c1 and c1 or x
end

function round(x)
	return (x+.5) - (x+.5)%1
end

function roundToGrid(x,gridSize,offset)
	return ((((x+(gridSize*.5))/gridSize) - ((x+(gridSize*.5))/gridSize)%1) * gridSize) + (offset or 0)
end				--  ^ MUCH BETTER

function roundToDegreeGrid(x,gridAngle)
	x = x%(math.pi*2)
	return (((x+(gridAngle*.5))/gridAngle) - ((x+(gridAngle*.5))/gridAngle)%1) * gridAngle
end

function getModelOffsets(model)
	local t = {}
	
	local pp = model.PrimaryPart
	local function search(obj)
		if obj ~= pp then
			if obj:IsA'BasePart' then
				t[obj] = pp.CFrame:inverse() * obj.CFrame
			end
		end
		for _,v in pairs(obj:GetChildren()) do
			search(v)
		end
	end	
	search(model)	
	
	return t
end

function setModelCanCollide(model,bool)
	
	local function search(obj)
		for _,v in pairs(obj:GetChildren()) do
			search(v)
		end
		if obj:IsA'BasePart' then
			obj.CanCollide = bool
		end
	end	
	
	search(model)
end

function rotateVector3(vector,a)
	return Vector3.new(
		vector.X*math.cos(a) - vector.Z*math.sin(a),
		0,
		vector.X*math.sin(a) + vector.Z*math.cos(a)
	)
end

function setModelCFrame(model,offsetData,cf)
	local originCF = cf or model.PrimaryPart.CFrame
	for obj,offset in next,offsetData do
		obj.CFrame = originCF * offset
	end
end

function getMaxExtentsWorldSpace(cf,size)
	local lookVector = cf.lookVector
	local theta = -math.atan(lookVector.z/lookVector.x) + .5*math.pi
	local maxVolume
	if theta > math.pi*.5 then
		maxVolume = Vector3.new(
			size.z*math.cos(theta - .5*math.pi) + size.x*math.sin(theta - .5*math.pi),
			0,
			size.z*math.sin(theta - .5*math.pi) + size.x*math.cos(theta - .5*math.pi)
		)
	else
		maxVolume = Vector3.new(
			size.x*math.cos(theta) + size.z*math.sin(theta),
			0,
			size.x*math.sin(theta) + size.z*math.cos(theta)
		)
	end
	return maxVolume
end

function roundVectorToGrid(v,gridSize,offsetV)
	offsetV = offsetV or zeroVector
	return Vector3.new(
		roundToGrid(v.x,gridSize,offsetV.x),
		roundToGrid(v.y,gridSize,offsetV.y),
		roundToGrid(v.z,gridSize,offsetV.z)
	)
end

function ScreenToWorld(screenPoint, depth)
	local resolution = Camera.ViewportSize
	local x,y = screenPoint.x,screenPoint.y
	local aspectRatio = resolution.X / resolution.Y
	local hfactor = math.tan(math.rad(Camera.FieldOfView)*.5)
	local wfactor = aspectRatio*hfactor
	local xf, yf = x/resolution.X*2 - 1, y/resolution.Y*2 - 1
	local xpos = xf * -wfactor * depth
	local ypos = yf *  hfactor * depth
	return (Camera.CFrame * CFrame.new(xpos, ypos, depth):inverse()).p
end

function getMass(t)
	local totalMass = 0
	for _,obj in pairs(t) do
		local c = obj:GetChildren()
		if #c > 0 then
			totalMass = getMass(c)
		end
		if obj:IsA'BasePart' then
			totalMass = obj:GetMass()
		end				
	end
	return totalMass
end

function setAllPartProperties(model,prop,val,exclusiveT)
	if type(exclusiveT) ~= 'table' then
		exclusiveT = {exclusiveT}
	end
	
	local function isExcluded(obj)
		for i = 1,#exclusiveT do
			if obj == exclusiveT[i] then
				return true
			end
		end
		return false
	end
	
	local function recursive(obj)
		for _,v in next,obj:GetChildren() do
			recursive(v)
		end
		if obj:IsA'BasePart' and not isExcluded(obj) then
			obj[prop] = val
		end
	end
	
	recursive(model)
end

--why are springs so easy again?
function solveSpring(now,springData,target,noUpdate)
	local Position 			= springData.Position
	local startTime 		= springData.startTime
	local Velocity 			= springData.Velocity
	local Damper 			= springData.Damper
	local Step 				= springData.Step
	
	local deltaT 			= now - startTime
	
	local newPos,newVel,newAccel
	if Damper == 1 then
		local posDiffInverse	= Position - target
		local cMod				= Velocity/Step + posDiffInverse
		local eMod				= 2.718281828^(Step*deltaT)
		newPos 					= target + (posDiffInverse + cMod*Step*deltaT)/eMod
		newVel 					= Step*(cMod - posDiffInverse - cMod*Step*deltaT)/eMod
		newAccel				= Step*Step*(posDiffInverse-2*cMod+cMod*Step*deltaT)/eMod
	elseif Damper < 1 then
		local cirCurve			= (1 - Damper*Damper)^.5
		local posDiffInverse	= Position - target
		local cMod				= (Velocity/Step + Damper*posDiffInverse)/cirCurve
		local cosCurve			= math.cos(cirCurve*Step*deltaT)
		local sinCurve			= math.sin(cirCurve*Step*deltaT)
		local eMod				= 2.718281828^(Damper*Step*deltaT)												
		newPos 					= target + (posDiffInverse*cosCurve + cMod*sinCurve)/eMod
		newVel 			 		= Step * ((cirCurve*cMod - Damper*posDiffInverse)
									* cosCurve-(cirCurve*posDiffInverse+Damper*cMod)*sinCurve)/eMod
		newAccel				= Step*Step*((Damper*Damper*posDiffInverse-2*cirCurve*Damper*cMod-cirCurve*cirCurve*posDiffInverse)*cirCurve
									+(Damper*Damper*cMod+2*cirCurve*Damper*posDiffInverse-cirCurve*cirCurve*cMod)*sinCurve)/eMod
		
	else
		Damper = 1
	end
	
	if not noUpdate then 
		springData.Position 	= newPos
		springData.Velocity		= newVel
		springData.Acceleration	= newAccel
		springData.startTime 	= now
	end
end

--those dank api functions

local Plane = {}

function Plane.new(base, obstacles, grid, modules, wobbleBaby)
	
	if not MODULES then
		MODULES = modules
	end
	
	local absoluteOrigin = Vector3.new(
		base.Position.X,
		base.Position.Y + base.Size.Y*.5,
		base.Position.Z
	)
	
	local setData
	local enableArray
	local Update
	local movedFromOrigin
	local initialPlacement
	local gridLockInitialPlacement
	local lockAxis = false
	local collisionOverride = false
	local isColliding = false
	local lastCollisionValue = false
	local currentRotation = 0
	local enableReady = false
	local lastTargetPoint = Vector3.new()
	local averagePosition = Vector3.new()
	local appliedModels = {}
	local debugParts = {}
	local obj = {}
	
	--Create the axis parts
	local axisPartX = Instance.new('Part')
	axisPartX.Size = Vector3.new(1,base.Size.x,1)
	axisPartX.Color = AXIS_COLOR
	axisPartX.Anchored = true
	axisPartX.CanCollide = false
	axisPartX.Material = Enum.Material.Neon
	local m = Instance.new('CylinderMesh')
	m.Parent = axisPartX
	
	local axisPartZ = axisPartX:Clone()
	axisPartZ.Size = Vector3.new(1,base.Size.z,1)
	
	--local functions
	
	local function finalize()
		if obj.Heartbeat then
			obj.Heartbeat:Disconnect()
			obj.Heartbeat = nil
		end
		
		for i,modelData in next,appliedModels do
			modelData.hitboxClone:Destroy()
			modelData.hitboxClone = nil
		end
		
		if DEBUG_MODE then
			for i,v in next,debugParts do
				v.Parent = nil
			end
		end
		
		isColliding = false
		collisionOverride = false
		currentRotation = 0
		appliedModels = {}
		setData = false
	end
	
	
	--Object functions
	
	function obj.enable(self,modelArray)
		--verify integrity of array
		self:disable()
		if type(modelArray) == "table" then
			for _,v in next,modelArray do
				if v.ClassName ~= "Model" then
					error("Attempt to enable placement with a non-model value inside of the array")
				end
			end
		else
			error("Attempt to enable placement with a non-table value")
		end
		
		while not enableReady do
			runService.Heartbeat:Wait()
		end
		
		enableArray = modelArray
		self.Heartbeat = runService.Heartbeat:Connect(Update)
	end
	
	function obj.rotate(self)
		currentRotation = currentRotation + 1
	end
	
	function obj.pos(self)
		return averagePosition
	end
	
	function obj.place(self)
		local t = {}
		for i,v in next,appliedModels do
			t[i] = v.realCFrame
		end
		return t
	end
	
	function obj.disable(self)
		--Let the placement finish its last step as enabled
		runService.Heartbeat:Wait()		
		
		--Reset vars
		finalize()
		lockAxis = false
		enableReady = true
	end	
	
	function obj.anchor(self)
		lockAxis = true
	end
	
	function obj.release(self)
		lockAxis = false
		movedFromOrigin = nil
	end
	
	function obj.override(self,bool)
		collisionOverride = bool == nil and not collisionOverride or bool
	end
	
	function obj.isGood(self)
		return not isColliding
	end
	
	function obj.toggleWobble(self,bool)
		wobbleBaby = bool == nil and not wobbleBaby or bool
	end
	
	--Create the boundary
	local Boundary = {
		Min = base.Position - base.Size*.5;
		Max = base.Position + base.Size*.5;
	}
	Boundary.Min = Vector3.new(Boundary.Min.X,base.Position.Y + base.Size.Y*.5,Boundary.Min.Z)
	Boundary.Max = Vector3.new(Boundary.Max.X,base.Position.Y + base.Size.Y*.5,Boundary.Max.Z)
	
	local debugFolder
	
	--Create the Debug Parts
	if DEBUG_MODE then
		
		--Folder to hold all of them
		debugFolder = Instance.new("Folder")
		debugFolder.Name = "placementDebugParts"
		debugFolder.Parent = workspace
		
		--Mouse position
		local mousePart = Instance.new("Part")
		mousePart.Name = "Mouse"
		mousePart.Size = Vector3.new(.5,.5,.5)
		mousePart.Color = Color3.fromRGB(203,255,144)
		mousePart.Anchored = true
		mousePart.CanCollide = false
		mousePart.Parent = debugFolder
		debugParts.Mouse = mousePart
		
		--Mouse grid-locked position
		local mouseGridPart = Instance.new("Part")
		mouseGridPart.Name = "MouseGrid"
		mouseGridPart.Size = Vector3.new(UNIT_SIZE*.5,UNIT_SIZE*.5,UNIT_SIZE*.5)
		mouseGridPart.Color = Color3.fromRGB(203,255,144)
		mouseGridPart.Anchored = true
		mouseGridPart.CanCollide = false
		mouseGridPart.Parent = debugFolder
		debugParts.MouseGrid = mouseGridPart
		
		--Center of transitioning parts
		local centerPart = Instance.new("Part")
		centerPart.Name = "Center"
		centerPart.Size = Vector3.new(UNIT_SIZE,UNIT_SIZE,UNIT_SIZE)
		centerPart.Color = Color3.fromRGB(255,197,155)
		centerPart.Anchored = true
		centerPart.CanCollide = false	
		centerPart.Parent = debugFolder
		debugParts.Center = centerPart	
		
		--min region corner
		local minPart = Instance.new("Part")
		minPart.Name = "minCorner"
		minPart.Size = Vector3.new(.5,10,.5)
		minPart.Color = Color3.new(1,0,0)
		minPart.Anchored = true
		minPart.CanCollide = false
		minPart.Parent = debugFolder
		debugParts.minCorner = minPart
		
		--max region corner
		local maxPart = minPart:Clone()
		maxPart.Name = "maxCorner"
		maxPart.Color = Color3.new(0,1,0)
		maxPart.Parent = debugFolder
		debugParts.maxCorner = maxPart
		
		--Center part for when multi-placing
		local multiCenter = Instance.new("Part")
		multiCenter.Name = "multiCenter"
		multiCenter.Size = Vector3.new(UNIT_SIZE*.5,UNIT_SIZE,UNIT_SIZE*.5)
		multiCenter.Anchored = true
		multiCenter.CanCollide = false
		multiCenter.Parent = debugFolder
		debugParts.multiCenter = multiCenter
		
	end
	
	local function clampWalls(pos,rotOffset,size)
		--Adjust the boundary for the size of the box		
		--First get the rotation, then yeah		
		local realSize = getMaxExtentsWorldSpace(rotOffset,size)
		local offset = pos - absoluteOrigin
		--First do the x side
		local maxX = base.Size.x*.5 - realSize.x*.5
		local minX = -maxX
		
		--Then the y side
		local maxZ = base.Size.z*.5 - realSize.z*.5
		local minZ = -maxZ
		
		--Finally clamp
		local xPos = clamp(offset.x,minX,maxX)
		local zPos = clamp(offset.z,minZ,maxZ)
		
		return xPos,zPos
	end
	
	local function isGridBoxColliding(corners0,corners1,wallOffset)
		wallOffset = wallOffset or 0
		return (corners0[1].x  < corners1[2].x - wallOffset and corners0[2].x - wallOffset > corners1[1].x)
			and (corners0[1].y < corners1[2].y - wallOffset and corners0[2].y - wallOffset > corners1[1].y)
	end
	
	local function isInAppliedModels(model)
		for i = 1,#appliedModels do
			if appliedModels[i] and appliedModels[i].Model == model then
				return true
			end
		end
	end		
	
	local function checkCollision(modelDatas)
		local hasCollided do
			for _,modelData in next,modelDatas do
				local hitbox = modelData.hitboxClone
				if not collisionOverride then
					local useSize = getMaxExtentsWorldSpace(hitbox.CFrame,hitbox.Size)
					local minCorner0 = Vector2.new(hitbox.Position.x - useSize.x*.5,hitbox.Position.z - useSize.z*.5)
					local maxCorner0 = Vector2.new(hitbox.Position.x + useSize.x*.5,hitbox.Position.z + useSize.z*.5)
					
					for _,obstacle in next,obstacles:GetChildren() do
						if obstacle.ClassName == "Model" and not isInAppliedModels(obstacle) then
							local part = obstacle.PrimaryPart or obstacle:FindFirstChild("Hitbox")
							if part then
								local pos = part.Position
								local size = getMaxExtentsWorldSpace(part.CFrame,part.Size)
								local minCorner1 = Vector2.new(pos.x - size.x*.5,pos.z - size.z*.5)
								local maxCorner1 = Vector2.new(pos.x + size.x*.5,pos.z + size.z*.5)
								
								hasCollided = isGridBoxColliding(
									{minCorner0,maxCorner0},
									{minCorner1,maxCorner1},
									.75									
								)
								if hasCollided then break end
							end	
						end					
					end						
					
				else
					hasCollided = true
				end
			end
		end
		
		for _,modelData in next,modelDatas do
			local hitbox = modelData.hitboxClone
			if hasCollided then
				if lastCollisionValue ~= true then
					lastCollisionValue = true
					--paint it red
					setAllPartProperties(modelData.Model,'Color',COLLISION_COLOR,{hitbox})
					modelData.hitboxClone.Color = COLLISION_COLOR
					modelData.hitboxClone.SelectionBox.Color3 = COLLISION_COLOR
				end
			else
				if lastCollisionValue ~= false then
					lastCollisionValue = false
					--paint it blue
					setAllPartProperties(modelData.Model,'Color',NO_COLLISION_COLOR,{hitbox})
					modelData.hitboxClone.Color = NO_COLLISION_COLOR
					modelData.hitboxClone.SelectionBox.Color3 = NO_COLLISION_COLOR					
				end
			end
		end	
		
		isColliding = hasCollided
	end
	
	function Update(step)
		local now = tick()
		
		
		--Before anything, we must make sure all the models have a primary part
		for i,model in next,enableArray do
			if not model.PrimaryPart then
				local hitBox = model:FindFirstChild('Hitbox')
				if hitBox then
					model.PrimaryPart = hitBox
				end
			end
		end
		
		
		--find the target position on the plane
		local targetPoint do
			--determine if using camera or mouse
			local rayPos
			if modules.Input.mode.Value ~= 'Xbox' and modules.Input.mode.Value ~= 'Mobile' then
				local mousePos = userInputService:GetMouseLocation()
				rayPos = ScreenToWorld(mousePos, 1)
			else
				rayPos = ScreenToWorld(Camera.ViewportSize*Vector2.new(.5,.4),1)
			end
			
			--solve for line-plane intersection
			local rayDir = (rayPos - Camera.CFrame.p).Unit
			local xAxisRot = math.asin(rayDir.y)
			if xAxisRot == xAxisRot and xAxisRot < 0 then
			
				local dot = Normals.Up:Dot(rayDir)
				
				local intersect
				if math.abs(dot) > 1e-6 then
					local diffPos = rayPos - absoluteOrigin
					local si = Normals.Down:Dot(diffPos) / dot
					intersect = diffPos + si*rayDir + absoluteOrigin
				else
					intersect = lastTargetPoint
				end
				
				targetPoint = Vector3.new(
					intersect.X < Boundary.Min.X and Boundary.Min.X or intersect.X > Boundary.Max.X and Boundary.Max.X or intersect.X,
					absoluteOrigin.Y,
					intersect.Z < Boundary.Min.Z and Boundary.Min.Z or intersect.Z > Boundary.Max.Z and Boundary.Max.Z or intersect.Z
				)
			else
				targetPoint = lastTargetPoint
			end
		end
		
		
		--Get our gridlocked target point
		local gridlockTargetPoint do
			local offset = targetPoint - absoluteOrigin
			local lockOffset = roundVectorToGrid(offset, UNIT_SIZE)
			gridlockTargetPoint = absoluteOrigin + lockOffset
		end
		
		
		--Do data ready stuff
		if not setData then
			for _,model in next,enableArray do
				setModelCanCollide(model,false)
				
				local hitboxClone = model.PrimaryPart:Clone()
				hitboxClone.Parent = workspace
				hitboxClone.Transparency = .85
				local selectBox = Instance.new('SelectionBox')
				selectBox.Parent = hitboxClone
				selectBox.Adornee = hitboxClone
				
				local lv = model.PrimaryPart.CFrame.lookVector
				local originalAngle = roundToDegreeGrid(math.atan2(-lv.x,-lv.z),math.pi*.5)
				
				
				appliedModels[#appliedModels+1] = {
					Model = model;
					hitboxClone = hitboxClone;
					partOffsets = {};
					originalAngle = originalAngle;	
					realCFrame = model.PrimaryPart.CFrame;					
				}
				
				--get our model doing the A E S T H E T I C 
				setAllPartProperties(model,'Transparency',.5,{model.PrimaryPart})
				setAllPartProperties(model,'Color',NO_COLLISION_COLOR,{model.PrimaryPart})
				setAllPartProperties(model,'CanCollide',false)						
				
			end
			
			--Debug parts
			for i,v in next,debugParts do
				v.Parent = debugFolder
			end
			
			setData = true
		end
		
		local currentRotation = currentRotation*(math.pi*.5)
		
		local finalizedStepData = {}
		if #appliedModels > 1 then
			
			--THIS IS CODE FOR MULTIPLE PARTS
		
			
			--Determine the position of the min and max corners
			local minCorner,maxCorner		
			for _,modelData in next,appliedModels do
				local hitbox = modelData.hitboxClone
				local currentRotOffset = CFrame.Angles(0,modelData.originalAngle + currentRotation,0)	
				local Size = getMaxExtentsWorldSpace(currentRotOffset,hitbox.Size)
				local Pos = hitbox.Position				
				
				local modelMinCorner = Pos - (Size*.5)
				local modelMaxCorner = Pos + (Size*.5)
				
				minCorner = Vector2.new(
					not minCorner and modelMinCorner.x or (modelMinCorner.x < minCorner.x and modelMinCorner.x or minCorner.x),
					not minCorner and modelMinCorner.z or (modelMinCorner.z < minCorner.y and modelMinCorner.z or minCorner.y)
				)
				maxCorner = Vector2.new(
					not maxCorner and modelMaxCorner.x or (modelMaxCorner.x > maxCorner.x and modelMaxCorner.x or maxCorner.x),
					not maxCorner and modelMaxCorner.z or (modelMaxCorner.z > maxCorner.y and modelMaxCorner.z or maxCorner.y)
				)
			end
			
			--Get our center and size where we do the offsets
			local Center = (minCorner + (maxCorner - minCorner)*.5)
			local totalSize = getMaxExtentsWorldSpace(
				CFrame.new(0,0,0),
				Vector3.new(maxCorner.x - minCorner.x,0,maxCorner.y - minCorner.y)
			)
			
			--Next we create offsets from the center if they don't exist yet
			for _,modelData in next,appliedModels do
				if not modelData.multiOffset then
					modelData.multiOffset = modelData.Model.PrimaryPart.Position - Vector3.new(Center.x,absoluteOrigin.y,Center.y)
				end
				if not modelData.Offsets then
					modelData.Offsets = getModelOffsets(modelData.Model)
				end
			end
			
			--Modify our real position
			local modX,modZ = 0,0
			if round(totalSize.x%(UNIT_SIZE*2)) == UNIT_SIZE then
				modX = UNIT_SIZE*.5
			end
			if round(totalSize.z%(UNIT_SIZE*2)) == UNIT_SIZE then
				modZ = UNIT_SIZE*.5
			end
			
			gridlockTargetPoint = Vector3.new(gridlockTargetPoint.x+modX,absoluteOrigin.y,gridlockTargetPoint.z+modZ)
			
			--Adjust the boundary for the size of the box		
			--First get the rotation, then yeah	
			local xPos,zPos = clampWalls(gridlockTargetPoint,CFrame.Angles(0,currentRotation,0),totalSize)

			--Get the real CFrame!
			local realCFrame = CFrame.new(absoluteOrigin + Vector3.new(xPos,0,zPos)) 
			averagePosition = realCFrame.p
			
			--Place down the models relative to the realCFrame and multiOffset
			for _,modelData in next,appliedModels do
				local hitboxClone = modelData.hitboxClone
				local hardCFrame = realCFrame
				* CFrame.Angles(0,currentRotation,0)
				* CFrame.new(modelData.multiOffset)
				* CFrame.Angles(0,modelData.originalAngle,0)
				
				modelData.realCFrame = hardCFrame
				hitboxClone.CFrame = hardCFrame
				
				local hitbox = modelData.Model.PrimaryPart
				local realY = absoluteOrigin.y + hitbox.Size.y*.5
				
				if wobbleBaby then
					--Setup the springs
					if not modelData.Springs then
						modelData.Springs = {
							posSpring = {
								Position = Vector2.new(hardCFrame.x,hardCFrame.z); --no touchy
								startTime = tick(); --touchy but wouldn't recommend
								Velocity = Vector2.new(0,0); --touchy
								Acceleration = Vector2.new(0,0); --touchy
								Damper = .74; --touchy
								Step = 20; --touchy
							};
							xRot = {
								Position = 0;
								startTime = tick();
								Velocity = 0;
								Acceleration = 0;
								Damper = .74;
								Step = 20;
							};
							--Actual rotation
							yRot = {
								Position = currentRotation + modelData.originalAngle;
								startTime = tick();
								Velocity = 0;
								Acceleration = 0;
								Damper = .67;
								Step = 20;
							};
							zRot = {
								Position = 0;
								startTime = tick();
								Velocity = 0;
								Acceleration = 0;
								Damper = .74;
								Step = 20;
							};
						}
					end	
					
					--Solve the springs
					solveSpring(now,modelData.Springs.posSpring,Vector2.new(hardCFrame.x,hardCFrame.z))
					solveSpring(now,modelData.Springs.yRot,modelData.originalAngle + currentRotation)
					
					--Solve rot
					local realYRot = modelData.Springs.yRot.Position
					local rotCF = CFrame.Angles(0,realYRot,0)
					local pos = modelData.Springs.posSpring.Position
					
					local wobbleTorque
					local vel = modelData.Springs.posSpring.Velocity
					if wobbleBaby then
						solveSpring(now,modelData.Springs.xRot,(vel.y/300) * (math.pi/8))
						solveSpring(now,modelData.Springs.zRot,(-vel.x/300) * (math.pi/8))
						wobbleTorque = CFrame.Angles(
							modelData.Springs.xRot.Position,
							0,
							modelData.Springs.zRot.Position
						)
					else
						wobbleTorque = zeroAngleCF
					end
					
					hitbox.CFrame = CFrame.new(pos.x,realY,pos.y) * wobbleTorque * rotCF
					averagePosition = Vector3.new(pos.x,absoluteOrigin.y,pos.y)
					
				else
					hitbox.CFrame = hardCFrame
				end

				--Do the offset placement
				for part,offset in next,modelData.Offsets do
					part.CFrame = hitbox.CFrame * offset
				end
				
			end
			
			checkCollision(appliedModels)
			
			if DEBUG_MODE then
				debugParts.minCorner.CFrame = realCFrame * CFrame.new(minCorner.x - Center.x,5,minCorner.y - Center.y)
				debugParts.maxCorner.CFrame = realCFrame * CFrame.new(maxCorner.x - Center.x,5,maxCorner.y - Center.y)
				debugParts.multiCenter.CFrame = realCFrame * CFrame.new(Center.x,absoluteOrigin.y + UNIT_SIZE*.5, Center.y)
			end
		
		else
			
			
			
			--THIS IS CODE FOR SINGLE PLACEMENT PARTS
			local modelData = appliedModels[1]	
			local modX,modZ = 0,0
			local hitbox = modelData.Model.PrimaryPart
			local realSize = getMaxExtentsWorldSpace(CFrame.Angles(0,currentRotation + modelData.originalAngle,0),hitbox.Size)
			if round(realSize.x%(UNIT_SIZE*2)) == UNIT_SIZE then
				modX = UNIT_SIZE*.5
			end
			if round(realSize.z%(UNIT_SIZE*2)) == UNIT_SIZE then
				modZ = UNIT_SIZE*.5
			end
			
			gridlockTargetPoint = Vector3.new(gridlockTargetPoint.x+modX,absoluteOrigin.y,gridlockTargetPoint.z+modZ)
			
			--Prepare to offset gridlock target point if lock axis is enabled
			if lockAxis then
				if not initialPlacement then
					initialPlacement = gridlockTargetPoint
				end
				
				--do the alignment calc
				local diff = targetPoint - initialPlacement
				
				--solve for x cone alignment
				local dirX = diff.x
				local dirZ = diff.z
				
				--x and z are the depths of the cones
				
				--x cone
				local yFactorMin = (-dirX/axisAngCos)*axisAngSin
				if yFactorMin > 0 then yFactorMin = -yFactorMin end
				local yFactorMax = 3 + -yFactorMin
				
				if dirZ < 0 then dirZ = -dirZ end
				if dirZ >= yFactorMin and dirZ <= yFactorMax then
					gridlockTargetPoint = Vector3.new(gridlockTargetPoint.x,gridlockTargetPoint.y,initialPlacement.z)
					if movedFromOrigin then
						axisPartX.Color = AXIS_COLOR
						axisPartX.Parent = workspace
					end
				else
					axisPartX.Parent = nil
				end
				
				
				--z cone
				local yFactorMin = (-dirZ/axisAngCos)*axisAngSin
				if yFactorMin > 0 then yFactorMin = -yFactorMin end
				local yFactorMax = 3 + -yFactorMin
				--print(yFactorMin,dirZ,'\n')
				if dirX < 0 then dirX = -dirX end
				if dirX >= yFactorMin and dirX <= yFactorMax then
					--print('z aligned')
					targetPoint = Vector3.new(initialPlacement.x,gridlockTargetPoint.y,gridlockTargetPoint.z)
					if movedFromOrigin then
						axisPartZ.Parent = workspace
					end
				else
					axisPartZ.Parent = nil
				end				
			else
				initialPlacement = nil
				gridLockInitialPlacement = nil
				axisPartX.Parent = nil
				axisPartZ.Parent = nil
			end
			
			local currentRotOffset = CFrame.Angles(0,modelData.originalAngle + currentRotation,0)				
			
			--Adjust the boundary for the size of the box		
			--First get the rotation, then yeah		
			local xPos,zPos = clampWalls(gridlockTargetPoint,currentRotOffset,hitbox.Size)

			--Get the real CFrame!
			local realCFrame = CFrame.new(absoluteOrigin + Vector3.new(xPos,hitbox.Size.y*.5,zPos)) 
			
			checkCollision({modelData})
			
			--Now we have to tween the model!
			if not modelData.Offsets then
				modelData.Offsets = getModelOffsets(modelData.Model)
			end
			
			--Place down the fake hitbox
			local hardCFrame = realCFrame * currentRotOffset
			modelData.realCFrame = hardCFrame
			modelData.hitboxClone.CFrame = hardCFrame
			
			local realY = absoluteOrigin.y + hitbox.Size.y*.5
			
			--grid line placement
			if not gridLockInitialPlacement then
				gridLockInitialPlacement = Vector3.new(targetPoint.x,0,targetPoint.z)
			else
				if targetPoint.x ~= gridLockInitialPlacement.x 
					or targetPoint.z ~= gridLockInitialPlacement.z then
					movedFromOrigin = true
				end
			end
			if axisPartZ.Parent == workspace then
				axisPartZ.Size = Vector3.new(1,base.Size.z,1)
				axisPartZ.CFrame = CFrame.new(
					gridlockTargetPoint.x,
					base.Position.y+.5,
					base.Position.z
				) * frontAngleCF
				
			end
			if axisPartX.Parent == workspace then
				axisPartX.Size = Vector3.new(1,base.Size.x,1)
				axisPartX.CFrame = CFrame.new(
					base.Position.x,
					base.Position.y+.5,
					gridlockTargetPoint.z
				) * sideAngleCF
			end	
			
			if wobbleBaby then
				--Update the springs
				if not modelData.Springs then
					modelData.Springs = {
						posSpring = {
							Position = Vector2.new(realCFrame.x,realCFrame.z); --no touchy
							startTime = tick(); --touchy but wouldn't recommend
							Velocity = Vector2.new(0,0); --touchy
							Acceleration = Vector2.new(0,0); --touchy
							Damper = .74; --touchy
							Step = 20; --touchy
						};
						xRot = {
							Position = 0;
							startTime = tick();
							Velocity = 0;
							Acceleration = 0;
							Damper = .74;
							Step = 20;
						};
						--Actual rotation
						yRot = {
							Position = currentRotation + modelData.originalAngle;
							startTime = tick();
							Velocity = 0;
							Acceleration = 0;
							Damper = .67;
							Step = 20;
						};
						zRot = {
							Position = 0;
							startTime = tick();
							Velocity = 0;
							Acceleration = 0;
							Damper = .74;
							Step = 20;
						};
					}
				end	
				
				solveSpring(now,modelData.Springs.posSpring,Vector2.new(realCFrame.x,realCFrame.z))
				solveSpring(now,modelData.Springs.yRot,modelData.originalAngle + currentRotation)
				
				--Handle the wobbliness
				local wobbleTorque
				local vel = modelData.Springs.posSpring.Velocity
				if wobbleBaby then
					solveSpring(now,modelData.Springs.xRot,(vel.y/300) * (math.pi/8))
					solveSpring(now,modelData.Springs.zRot,(-vel.x/300) * (math.pi/8))
					wobbleTorque = CFrame.Angles(
						modelData.Springs.xRot.Position,
						0,
						modelData.Springs.zRot.Position
					)
				else
					wobbleTorque = zeroAngleCF
				end
				
				--Solve rot
				local realYRot = modelData.Springs.yRot.Position
				local rotCF = CFrame.Angles(0,realYRot,0)
				
				--Place the primary part
				local pos = modelData.Springs.posSpring.Position
				hitbox.CFrame = CFrame.new(pos.x,realY,pos.y) * wobbleTorque * rotCF
				averagePosition = Vector3.new(pos.x,absoluteOrigin.y,pos.y)
			else
				hitbox.CFrame = hardCFrame
			end
			
			--Do the offset placement
			for part,offset in next,modelData.Offsets do
				part.CFrame = hitbox.CFrame * offset
			end
		end
		
		--Debug parts for mouse
		if DEBUG_MODE then
			debugParts.Mouse.CFrame = CFrame.new(targetPoint) * CFrame.new(0,debugParts.Mouse.Size.Y*.5,0)		
			debugParts.MouseGrid.CFrame = CFrame.new(gridlockTargetPoint) * CFrame.new(0,debugParts.MouseGrid.Size.Y*.5,0)
		end
		
		--Finalize step
		lastTargetPoint = targetPoint	
		
		if DEBUG_MODE then
			print('End of placement step.\n')
		end
	end
	
	
	
	enableReady = true
	return obj
end



local planeMeta = {}
planeMeta.__index = function(self,i)
	if i == 'new' then
		return Plane.new
	end
end


return setmetatable({},planeMeta)
