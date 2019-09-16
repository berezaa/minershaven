--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
This script was created under a contract originally for exclusive use for this project and the author, Locard.
Please include this copyright & permission notice in all copies or substantial portions of the Software.
]]


--[[

	Tutorial Module written by Locard

	PROCESS

	The tutorial is prompted under these circumstances:
		The player must be brand new
			a. Must be 1st life and no sacrifice
			b. Their total base value (Asset value of inventory and base + current cash) must be less than 1,000,000
		The PlayerTutorialStep value must be at or between 0 and the final step

	If the player is not brand new, then they will not be prompted to do the tutorial

	We then prompt the user if they want to start the tutorial, or if they want to continue the play-session without it
		If the user has done some of the tutorial already, the prompt will ask if they want to continue where they left off

	---------Tutorial Steps---------

	0 - Start of the tutorial, prompt the user to start the tutorial

	1 - Tells the user to work on a CELL FURNACE SETUP 					($10/s)
		A. Supposed to teach the following:
			- Opening and using the inventory
			- Familiarity with the placement system
			- Dropper
			- Cell furnaces
			- How to immediately earn money from using a cell furnace
		B. Requires the following items:
			- 1x Cell Furnace (included)
			- 1x Basic Iron Mine (included)
		C. User will be prompted to place the items in the correct spot
			1. A blue ghost highlight will appear in the spot that the corresponding item needs to go to
			2. When the player approaches it, a sign will appear in front of it with the ghost item's description
				1.Item Name
				2.Item Price
				3.Hint Value
					-Value: 0; Hint: "InStep"; Status: Player must place items in steps.
					-Value: 1; Hint: "Placement"; Status: Player owns the item and has enough to use this item specifically
					-Value: 2; Hint: "Purchase"; Status: Player does not have enough of this item to get this one specifically
					-Value: 3; Hint: "Ready"; Status: Item is in place
			3. It will go away (Value 3) once the real item is placed there
			4. This step will be completed only when all of the tutorial ghost models are ready

	2 - Tells the user to work on a BASIC MINE SYSTEM 					($35/s)
		A. Supposed to teach the following:
			- Constructing a system to earn money
			- How to earn loads of money over time (through a conveyor system)
		B. Requires the following items:
			- 4x Basic Iron Mine (included)
			- 2x Basic Conveyor (included)
			- 1x Basic Furnace (included)
		C. same as 1.C

	3 - Tells the user to work on an ADVANCED MINE SYSTEM  				($314.2/s)
		A. Supposed to teach the following:
			- Constructing a system with upgraders and multiple conveyors
		B. Requires the following items:
			- 8x Silver Mine (Needs purchasing)
			- 6x Basic Conveyor (included)
			- 4x Ore purifier (included)
			- 1x Basic Furnace (included)
		C. Same as 1.C

	4 - Tell the user to work on a $100k setup							(800/s
		A. Supposed to teach the following:
			- Upgrading droppers
		B. Requires the following items:
			- 8x Copper Mine
			- 4x Basic Conveyor (included)
			- 4x Large Ore Upgrader
			- 1x Ore Incinerator (included)
		C. Same as 1.C

	6 - Tell the user to create the MILLION DOLLAR SETUP				($4.61k/s)
		A. Supposed get the user to finally understand the process of creating systems
		B. Requires the following items:
			- 8x Gold Mine (Needs purchasing) $13,500
			- 5x Large Ore Upgrader (Needs purchasing) $2,500
			- 4x Basic Conveyor (included)
			- 1x Quantum Processor
		C. Same as 1.C

	7 - Wait until million dollars

	8 - Finalize the tutorial
		A. Summarize, that's kinda it tbh

	9 - If anyone is at this step, the tutorial is over

--]]



--MODIFIERS------------------------

local DEBUG = false

local modelColors = {
	PlacementReady = Color3.new(0.0509804, 0.411765, 0.67451);
	WhenReadyAndPlacing = Color3.new(1,1,1);
	correctPlacingItem = Color3.fromRGB(39, 235, 160);
	incorrectPlacingItem = Color3.new(1,.6,.6);
}

-----------------------------------

local Players = game:GetService("Players")
local runService = game:GetService("RunService")
local repStorage = game:GetService("ReplicatedStorage")

local tutorialModule = {}
local localPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local MODULES
local EVENT
local STEPVALUE
local PLACEMENT

local itemDescriptions = {
	["Basic Iron Mine"] = {
		"Behold, the Basic Iron Mine! Mines like this drop precious ore which can be burned for money.";
		"This item drops Iron Ore, which is worth $2 a pop. Some mines drop ore worth billions!";
		"There are over eighty different mines in the game, and some of them are quite interesting.";
	};
	["Cell Furnace"] = {
		"Aha, A Cell Furnace! This is a special item that burns ore for ten times their value! ";
		"That boost comes at a cost... Cell Furnaces must have ore dropped directly into them by a mine.";
		"There are various conveyors, upgraders and other machines in the game that can't be used with a Cell Furnace.";
		"This makes them useful for getting quick cash, but pretty useless for making larger setups.";
	};
	["Basic Conveyor"] = {
		"This is a conveyor. These pick up dropped ore and move them towards upgraders or furnaces.";
		"You can connect many kinds of conveyors together. There are some thare are super fast!";
	};
	["Silver Mine"] = {
		"Nice, you got a Silver Mine! These mines drop ore faster, and Silver is worth $5 instead of $2!";
		"You may have noticed that this mine takes up more space than the Iron Mine. Some mines are much bigger!";
	};
	["Ore Purifier Machine"] = {
		"This item is one of many different machines you can use to upgrade the value of your ore.";
		"Some machines can upgrade ore more than once. Other machines can upgrade your ore in special ways!";
		"This one specifically upgrades your ore a little bit. Ore can be upgraded by this more than once.";
	};
	["Basic Furnace"] = {
		"This is a Basic Furnace. It doesn't offer any bonuses like the Cell Furnace does.";
		"However you can connect conveyors and upgraders to this furnace, potentially making way more money.";
	};
	["Crystal Mine"] = {
		"Precious crystals! This powerful mine is slower than the Silver Mine but the ore is worth $35 instead of $5!";
	};
	["Military-Grade Conveyor"] = {
		"This is a Military-Grade Conveyor. It is much faster than the Basic Conveyor, which should get your ores to the furnace quicker!";
		"This conveyor also has walls, which protects your ore from falling off and being destroyed.";
	};
	["Large Ore Upgrader"] = {
		"This is another ore upgrader. It offers a 35 percent upgrade, which doesn't sound like much...";
		"However, this upgrader can be used multiple items! Use five of them to more than quadruple your ore value.";
		"The Large Ore Upgrader and many other similar multi-use upgraders become less effective the more an ore is worth.";
	};
	["Ore Scanner"] = {
		"This advanced upgrader has a tiny moving beam that must touch an ore to upgrade it.";
		"If the beam hits an ore, it will double the value of the ore, no matter what that ore was worth before!";
		"Upgraders that unconditionally multiply the value of an ore like this should be placed near the end of your setup.";
	};
	["Ore Incinerator"] = {
		"This advanced furnace triples your income, all while still accepting conveyors and upgraders.";
		"As you advance in Miner's Haven you will unlock some very large and powerful furnaces.";
	};
	["Gold Mine"] = {
		"You've struck gold! Now you'll be making real money. The Gold Mine drops ore worth $75 a piece!";
	};
	["Remote Diamond Mine"] = {
		"Did you see that radio appear on your screen? It says \"DROP\" on it.";
		"This is a very special mine. It only drops ore when you activate the radio on your screen.";
		"Activating the radio will make all Remote Mines on your base drop their ore at once!";
		"With this powerful Remote Mine... you should be able to reach $1M in no time!";
	};
}

local tutorialSteps = {

	--STEP 1
	{
		initialCleanup = true;
		microSteps = {
			--Intro
			{
				microStepType = "Frame";
				frameType = "Step";
				Messages = {
					"Hello, welcome to Miner's Haven! Let me help get you your first $1 Million!";
					"We'll start with a simple setup to make quick cash. Let me show you where to go.";
				};
			};
			--Listener
			{
				microStepType = "Listen";
				itemList = {
					{
						Name = "Basic Iron Mine";
						Rotation = 3;
						Placement = Vector3.new(63,0,-64.5);
					};
					{
						Name = "Cell Furnace";
						Rotation = 0;
						Placement = Vector3.new(63,0,-57);
					}
				};
			};
			{
				microStepType = "Frame";
				frameType = "Step";
				Messages = {
					"This will get you money really fast, but did you know you can place multiple mines onto this one Cell Furnace?";
					"Go ahead and place some extra mines on the Cell Furnace!";
				};
			};
			{
				microStepType = "Listen";
				itemList = {
					{
						Name = "Basic Iron Mine";
						Rotation = 1;
						Placement = Vector3.new(63,0,-49.5)
					};
					{
						Name = "Basic Iron Mine";
						Rotation = 2;
						Placement = Vector3.new(70.5,0,-57);
					};
					{
						Name = "Basic Iron Mine";
						Rotation = 0;
						Placement = Vector3.new(55.5,0,-57);
					};
				};
			};

		};
	};


	--STEP 2
	{
		initialCleanup = true;
		microSteps = {
			{
				microStepType = "Frame";
				frameType = "Step";
				Messages = {
					"Nice! This simple setup will get you fast money to start building your larger setups with.";
					"However, that's not all there is to Miner's Haven. There are machines that can make you even more money.";
					"Now that you have some cash, let's start building a basic conveyor system.";
				};
			};
			{
				microStepType = "Listen";
				itemList = {
					--Conveyors
					{
						Name = "Basic Conveyor";
						Rotation = 0;
						Placement = Vector3.new(30,0,-66);
					};
					{
						Name = "Basic Conveyor";
						Rotation = 0;
						Placement = Vector3.new(30,0,-60);
					};
					{
						Name = "Basic Conveyor";
						Rotation = 0;
						Placement = Vector3.new(30,0,-54);
					};
					{
						Name = "Basic Conveyor";
						Rotation = 0;
						Placement = Vector3.new(30,0,-48);
					};
					{
						Name = "Basic Conveyor";
						Rotation = 0;
						Placement = Vector3.new(30,0,-42);
					};
					{
						Name = "Basic Conveyor";
						Rotation = 0;
						Placement = Vector3.new(30,0,-36);
					};
					--Mines
					{
						Name = "Silver Mine";
						Rotation = 0;
						Placement = Vector3.new(22.5,0,-64.5);
					};
					{
						Name = "Silver Mine";
						Rotation = 0;
						Placement = Vector3.new(22.5,0,-55.5);
					};
					{
						Name = "Silver Mine";
						Rotation = 0;
						Placement = Vector3.new(22.5,0,-46.5);
					};
					{
						Name = "Silver Mine";
						Rotation = 2;
						Placement = Vector3.new(37.5,0,-64.5);
					};
					{
						Name = "Silver Mine";
						Rotation = 2;
						Placement = Vector3.new(37.5,0,-55.5);
					};
					{
						Name = "Silver Mine";
						Rotation = 2;
						Placement = Vector3.new(37.5,0,-46.5);
					};
					--Machines
					{
						Name = "Ore Purifier Machine";
						Rotation = 0;
						Placement = Vector3.new(30,0,-27);
					};
					{
						Name = "Ore Purifier Machine";
						Rotation = 0;
						Placement = Vector3.new(30,0,-15);
					};
					--Furnace
					{
						Name = "Basic Furnace";
						Rotation = 0;
						Placement = Vector3.new(30,0,-6);
					};
				};
			};
			{
				microStepType = "Frame";
				frameType = "Step";
				Messages = {
					"Systems like this help generate higher rates of cash over time.";
					"These kinds of systems can be upgraded and modified however you like!";
					"Next we'll be working on an \"Advanced Mine System\"";
				};
			};
		};
	};


	--STEP 3
	{
		initialCleanup = true;
		microSteps = {
			{
				microStepType = "Frame";
				frameType = "Step";
				Messages = {
					"The advanced system will require major upgrading. We will be changing all of our components in our system.";
					"We're going to need a lot of money now! Lets make one more Cell Furnace with better mines to help us out!";
				};
			};
			{
				microStepType = "Listen";
				itemList = {
					{
						Name = "Cell Furnace";
						Rotation = 0;
						Placement = Vector3.new(63,0,-21);
					};
					{
						Name = "Crystal Mine";
						Rotation = 3;
						Placement = Vector3.new(63,0,-28.5);
					};
					{
						Name = "Crystal Mine";
						Rotation = 1;
						Placement = Vector3.new(63,0,-13.5);
					};
					{
						Name = "Crystal Mine";
						Rotation = 2;
						Placement = Vector3.new(70.5,0,-21);
					};
					{
						Name = "Crystal Mine";
						Rotation = 0;
						Placement = Vector3.new(55.5,0,-21);
					};
				};
			};
			{
				microStepType = "Listen";
				itemList = {
					--Conveyors
					{
						Name = "Military-Grade Conveyor";
						Rotation = 0;
						Placement = Vector3.new(-66,0,-66);
					};
					{
						Name = "Military-Grade Conveyor";
						Rotation = 0;
						Placement = Vector3.new(-66,0,-60);
					};
					{
						Name = "Military-Grade Conveyor";
						Rotation = 0;
						Placement = Vector3.new(-66,0,-54);
					};
					{
						Name = "Military-Grade Conveyor";
						Rotation = 0;
						Placement = Vector3.new(-66,0,-48);
					};
					{
						Name = "Military-Grade Conveyor";
						Rotation = 0;
						Placement = Vector3.new(-66,0,-42);
					};
					--Mines
					{
						Name = "Gold Mine";
						Rotation = 0;
						Placement = Vector3.new(-73.5,0,-66);
					};
					{
						Name = "Gold Mine";
						Rotation = 0;
						Placement = Vector3.new(-73.5,0,-60);
					};
					{
						Name = "Gold Mine";
						Rotation = 0;
						Placement = Vector3.new(-73.5,0,-54);
					};
					{
						Name = "Gold Mine";
						Rotation = 2;
						Placement = Vector3.new(-58.5,0,-66);
					};
					{
						Name = "Gold Mine";
						Rotation = 2;
						Placement = Vector3.new(-58.5,0,-60);
					};
					{
						Name = "Gold Mine";
						Rotation = 2;
						Placement = Vector3.new(-58.5,0,-54);
					};
					--Machines
					{
						Name = "Large Ore Upgrader";
						Rotation = 0;
						Placement = Vector3.new(-66,0,-30);
					};
					{
						Name = "Large Ore Upgrader";
						Rotation = 0;
						Placement = Vector3.new(-66,0,-12);
					};
					{
						Name = "Large Ore Upgrader";
						Rotation = 0;
						Placement = Vector3.new(-66,0,6);
					};
					{
						Name = "Ore Scanner";
						Rotation = 0;
						Placement = Vector3.new(-66,0,21);
					};
					--Furnace
					{
						Name = "Ore Incinerator";
						Rotation = 3;
						Placement = Vector3.new(-66,0,34.5);
					};
				};
			};
			{
				microStepType = "Frame";
				frameType = "Step";
				Messages = {
					"Congrats! You have completed the advanced mine system! Look at all the money you're making!";
					"There's one more thing you can add to this setup to make it even better...";
					"We can't get it yet because you don't have enough Research Points!";
					"You can see how many you have at the top of your screen, below your cash.";
					"When you get more Research Points, you unlock bigger, better, and way more powerful items!";
					"You can collect these points from special furnaces, boxes that fall from the sky, daily rewards, and more!";
				};
			};
			{
				microStepType = "ListenForRP";
				Message = "Here is your daily gift, go ahead and open it!";
				noGiftMessage = "Go ahead and collect your boxes! They should be somewhere near you.";
			};
			{
				microStepType = "Frame";
				frameType = "Step";
				Messages = {
					"Nice! You got your first daily reward! Make sure to come back tomorrow to get your next one!";
					"Lets finish this setup with placing our last item, the Remote Diamond Mine.";
				};
			};
			{
				microStepType = "Listen";
				itemList = {
					{
						Name = "Remote Diamond Mine";
						Rotation = 0;
						Placement = Vector3.new(-75,0,-43.5);
					}
				}
			};
			{
				microStepType = "Frame";
				frameType = "Step";
				Messages = {
					"With that last item, you should be getting $1M any minute now!";
					"That's the tutorial! With a little problem-solving, you should be able to reach trillions in no time.";
					"Good luck! Who knows, maybe one day you'll be at the top of the Miner's Haven global leaderboards!";
				};
			};
		};
	};
}


--These are properties that are valuable to the tutorial sequence
local currentStepData
local currentMicroStep
local currentModelListenStep
local initialStepCompleted
local beamStepCompleted
local isDoingStep
local isListening
local millionSkip
local allGhostItems
local tutorialActive
local weTalkedAboutThisJanice = {}
local orderedModels = {}
local modelStepData = {}
local Beams = {}
local currentlyTalkingAboutThisWithJanice
local beamOrigin = script.BeamPart:Clone()
beamOrigin.Name = "beamOrigin"
beamOrigin.Parent = workspace
beamOrigin:ClearAllChildren()
beamOrigin.CFrame = CFrame.new(0,0,0)


local stepActive
local stepHault
local doCleanup
function changeStepState(bool)
	--if true
		--start the run step if it's currently not running
		--continues the run step if it's currently haulted
	--if false
		--pause the run step
	--if nil
		--Completely destroy the run step

	if bool then
		if not stepActive then
			local serial = tick()
			stepActive = serial

			local stopping
			repeat
				tutorialRunStep()
				if doCleanup then
					--print('cleaning up')
					doCleanup = false
					Cleanup()
				end
				if stepActive == serial then
					if stepHault then
						repeat wait() until not stepHault
					end
					runService.Heartbeat:Wait()
				else
					stopping = true
				end
			until stepActive ~= serial and stopping
		else
			stepHault = false
		end
	elseif bool == false then
		stepHault = true
	elseif bool == nil then
		if stepActive then
			stepActive = false
		end
	end
end

--Needs to clean up all of the items created with this module
function cleanupGhosts()
	if orderedModels then
		for i,v in next,orderedModels do
			if v and v.ClassName == "Model" then
				MODULES.ArrowHandler.removeConveyor(v)
			end
		end
	end
	orderedModels = {}
	isListening = nil
end

function finalizeTutorial()
	local Tycoon
	repeat
		Tycoon = MODULES.Tycoon.getTycoon(localPlayer)
	until Tycoon and Tycoon.Owner.Value == localPlayer.Name

	for i,v in next,Tycoon:GetChildren() do
		if v.ClassName == "Model" and v:FindFirstChild("Ignore") then
			v.Ignore:Destroy()
		end
	end

	changeStepState()
	MODULES.Inventory.highlightTutorialItem()
	MODULES.Shop.highlightTutorialItem()
	Cleanup()
	Camera.CameraType = Enum.CameraType.Custom
	Camera.CameraSubject = (localPlayer.Character or localPlayer.CharacterAdded:wait()):WaitForChild("Humanoid")
end

function Cleanup()
	initialStepCompleted = nil
	beamStepCompleted = nil
	isListening = nil
	modelStepData = {}

	for i,v in next,orderedModels do
		if v and v.ClassName == "Model" then
			MODULES.ArrowHandler.removeConveyor(v)
		end
	end

	orderedModels = {}

	if allGhostItems then
		local old = allGhostItems
		allGhostItems = nil
		old:Destroy()
	end

	for i,v in next,Beams do
		v:Destroy()
	end

	MODULES.HUDRight.addArrow()
	MODULES.Buttons.addArrow()
	MODULES.Placement.stopPlacing()
end

local allModelParts = {}
function transformModel(model,transparency,color)
	transparency = transparency or 0
	color = color or modelColors.PlacementReady

	local modelParts = allModelParts[model]
	local function search(c)
		if c:IsA"BasePart" and c.Name ~= "ghostData" then
			c.CanCollide = false
			modelParts[#modelParts+1] = c
		end
		for i,v in next,c:GetChildren() do
			search(v)
		end
	end

	if not modelParts then
		modelParts = {}
		search(model)
		allModelParts[model] = modelParts
	end

	for i = 1,#modelParts do
		local part = modelParts[i]
		if part then
			part.Transparency = part == model.PrimaryPart and 1 or transparency
			part.Color = color
		end
	end
end

function hasModelCorrectlyAligned(model,ghostModel,modelIsAPlacementModel)
	local isCF = typeof(ghostModel) == "CFrame"
	local s = not isCF and ghostModel.PrimaryPart.Size or model.PrimaryPart.Size
	local cf0
	if not modelIsAPlacementModel then
		cf0 = model.PrimaryPart.CFrame
	else
		local clone = model:FindFirstChild("HitboxClone")
		if clone then
			cf0 = clone.CFrame
		else
			return false
		end
	end
	local cf1 = isCF and ghostModel or ghostModel.PrimaryPart.CFrame
	local mag = (cf0.p - cf1.p).Magnitude
	if mag < .2 then
		--If it's a furnace then we don't have to check direction unless its x and z sizes are different
		if s.x == s.z and model.ItemType.Value == 2 then
			return true
		else
			local dot = cf0.lookVector:Dot(cf1.lookVector)
			if dot == 1 then
				return true
			else
				return false
			end
		end
	else
		return false
	end
end

function modelAlignedWithAGhost(model,isPlacementModel)

	local Tycoon = MODULES.Tycoon.getTycoon(localPlayer)
	if not Tycoon or Tycoon.Owner.Value ~= localPlayer.Name then
		return
	end

	if not isPlacementModel then
		for mainStep,stepData in next,tutorialSteps do
			for microStep,microStepData in next,stepData.microSteps do
				if microStepData.itemList then
					for pos,itemData in next,microStepData.itemList do
						if model.Name == itemData.Name then
							local cf = CFrame.new(Tycoon.Base.CFrame * itemData.Placement)
								* CFrame.Angles(0,itemData.Rotation*(math.pi*.5),0)
								* CFrame.new(0,model.PrimaryPart.Size.y*.5 + Tycoon.Base.Size.y*.5,0)
							local d = hasModelCorrectlyAligned(model,cf)
							if d then
								return true
							end
						end
					end
				end
			end
		end
	else
		for step = STEPVALUE.Value,1,-1 do
			local stepData = tutorialSteps[step]
			if stepData then
				for microStep = currentMicroStep,1,-1 do
					local msData = stepData.microSteps[microStep]
					if msData and msData.itemList then
						for pos,itemData in next,msData.itemList do
							if model.Name == itemData.Name then
								local cf = CFrame.new(Tycoon.Base.CFrame * itemData.Placement)
									* CFrame.Angles(0,itemData.Rotation*(math.pi*.5),0)
									* CFrame.new(0,model.PrimaryPart.Size.y*.5 + Tycoon.Base.Size.y*.5,0)
								local d = hasModelCorrectlyAligned(model,cf,isPlacementModel)
								if d then
									return true
								end
							end
						end
					end
				end
			end
		end
	end
	return false
end

function ghostHasModelAligned(ghostModel)

	local Tycoon = MODULES.Tycoon.getTycoon(localPlayer)
	if not Tycoon or Tycoon.Owner.Value ~= localPlayer.Name then
		return
	end

	local modelNeedsToBeAt = ghostModel.PrimaryPart.CFrame
	local closestModel
	local smallestMag = math.huge
	for _,c in next,Tycoon:GetChildren() do
		local id = ghostModel:FindFirstChild("ItemId")
		if c.ClassName == "Model" and id and id.Value == ghostModel.ItemId.Value and c.PrimaryPart then
			if c:FindFirstChild("LocalItem") == nil then
				local p0,p1 = modelNeedsToBeAt.p,c.PrimaryPart.Position
				local mag = (p1-p0).Magnitude
				if smallestMag > mag then
					smallestMag = mag
					closestModel = c
				end
			end
		end
	end

	--Verify the closest model
	if closestModel then
		if hasModelCorrectlyAligned(closestModel,ghostModel) then

			--add the bool
			if not closestModel:FindFirstChild('Ignore') then
				local b = Instance.new("BoolValue")
				b.Name = "Ignore"
				b.Value = true
				b.Parent = closestModel
			end

			return true
		else
			return false
		end
	else
		return false
	end
end


function getBeam(referenceName)

	--reasonToLive needs to be a function that can return a few things:
		--false 		- Turns off the beam and stops updating it
		--0-1 			- Turns on the beam and sets transparency to the number returned
	--It can also have one argument, which is the table below 't'


	if Beams[referenceName] then
		return Beams[referenceName]
	end


	local beam = script.BeamPart.Beam:Clone()
	local a0,a1 = Instance.new("Attachment"),Instance.new("Attachment")

	a0.Parent = beamOrigin
	a1.Parent = beamOrigin
	beam.Parent = beamOrigin

	beam.Attachment0 = a0
	beam.Attachment1 = a1

	local t = {
		Name = referenceName;
		a0 = a0;
		a1 = a1;
		Beam = beam;
	}

	function t.Step(self,func)
		local choice = func(self)
		if not choice then
			beam.Enabled = false
		else
			local t = type(choice)
			if t == 'number' then
				beam.Enabled = true
				beam.Transparency = NumberSequence.new(choice)
			else
				beam.Enabled = false
			end
		end
	end

	function t.setColor(self,color)
		if color ~= beam.Color.Keypoints[1].Value then
			beam.Color = ColorSequence.new(color)
		end
	end

	function t.Destroy(self)
		table.remove(Beams,self.Index)
		self.a0:Destroy()
		self.a1:Destroy()
		self.Beam:Destroy()
		Beams[referenceName] = nil
		self = nil
	end

	Beams[referenceName] = t
	return t
end


function onTutorialStepChanged(newVal)
	changeStepState()
	local newData = tutorialSteps[newVal]
	if newData then
		if newData.initialCleanup then
			Cleanup()
		end
		spawn(function()
			changeStepState(true)
		end)
	else
		if newVal > #tutorialSteps and newVal < 9 then
			--print('FINALIZING TUTORIAL')
			EVENT:FireServer(9)
			finalizeTutorial()
		end
	end
end

function makeGhostItem(itemData)

	local tycoonModel = MODULES.Tycoon.getTycoon(localPlayer)
	assert(tycoonModel ~= nil,"Tycoon model is nil for player ".. tostring(localPlayer))

	--Grab the base item
	local baseItem
	local Items = repStorage.Items:GetChildren()
	for _,model in next,Items do
		if model.Name == itemData.Name then
			baseItem = model
			break
		end
	end

	assert(baseItem ~= nil,"Could not find item with name \"".. tostring(itemData.Name) .."\" to make a ghost item.")

	local ghostModel = baseItem:Clone()
	ghostModel.PrimaryPart = ghostModel.Hitbox

	if not ghostModel.PrimaryPart then
		ghostModel:Destroy()
		return
	end

	--Create the prompt part
	local promptPart = script.ghostData:Clone()
	promptPart.Parent = ghostModel

	--Place the model
	local cf = CFrame.new(tycoonModel.Base.CFrame * itemData.Placement) * CFrame.Angles(0,itemData.Rotation*(math.pi*.5),0)
	ghostModel:SetPrimaryPartCFrame(cf * CFrame.new(0,ghostModel.PrimaryPart.Size.y*.5 + tycoonModel.Base.Size.y*.5,0))

	--Add to ghost model table
	if not allGhostItems then
		allGhostItems = Instance.new("Folder")
		allGhostItems.Name = "GhostItems"
		allGhostItems.Parent = workspace
	end

	orderedModels[#orderedModels+1] = ghostModel

	for i,v in next,orderedModels do
		if not v.PrimaryPart then
			table.remove(orderedModels,i)
		end
	end

	table.sort(orderedModels,function(m0,m1)
		local p0,p1 = m0.PrimaryPart.Position,m1.PrimaryPart.Position
		local sameX = p0.x == p1.x
		local sameSize0 = m0.PrimaryPart.Size.x == m0.PrimaryPart.Size.z
		local isConveyor0 = sameSize0 and m0:FindFirstChild("ConveyorSpeed",true)
		local sameSize1 = m1.PrimaryPart.Size.x == m1.PrimaryPart.Size.z
		local isConveyor1 = sameSize1 and m1:FindFirstChild("ConveyorSpeed",true)

		if isConveyor0 and isConveyor1 then
			return sameX and p0.z < p1.z or p0.x > p1.x
		elseif isConveyor0 and not isConveyor1 then
			return true
		elseif not isConveyor0 and isConveyor1 then
			return false
		end

		if m0.ItemType.Value == m1.ItemType.Value then
			if sameX then
				--We may have a possible conveyor
				return p0.z < p1.z
			else
				--return size0.x > size1.x
				return p0.x > p1.x
			end
		else
			return m0.ItemType.Value > m1.ItemType.Value
		end
	end)

	ghostModel.Parent = allGhostItems

	--Only add arrow handler
	if ghostModel.PrimaryPart.Size.x == ghostModel.PrimaryPart.Size.z and ghostModel.PrimaryPart.Size.x == 6 then
		MODULES.ArrowHandler.addConveyor(ghostModel)
	end
end

function startExplainingJanice(model)

	local Tycoon = MODULES.Tycoon.getTycoon(localPlayer)
	if not Tycoon or Tycoon.Owner.Value ~= localPlayer.Name then
		return
	end

	--Have we talked about our past before, Janice?
	if model and not weTalkedAboutThisJanice[model.ItemId.Value] then
		--Maybe we should talk about this...
		if not currentlyTalkingAboutThisWithJanice then
			--Lets talk about the past, Janice
			currentlyTalkingAboutThisWithJanice = model
			--Specifically the parts that mean the most to us
			weTalkedAboutThisJanice[model.ItemId.Value] = true
			MODULES.Placement.stopPlacing()
			MODULES.HUDRight.addArrow()
			MODULES.Buttons.addArrow()
			repeat
				wait()
			until not PLACEMENT.isPlacing()
			Camera.CameraType = Enum.CameraType.Scriptable
			MODULES.Menu.sounds.Shimmer:Play()
			MODULES.tutorialFrame.Display("Step",itemDescriptions[model.Name],true)
			Camera.CameraType = Enum.CameraType.Custom
			Camera.CameraSubject = (localPlayer.Character or localPlayer.CharacterAdded:wait()):WaitForChild("Humanoid")

			--Now we gotta determine if we re-place the model
				--Loop through microstep's item list
					--Check if the name is the same as the model's name
					--If it's the same, check if it's position has a model there
					--If it doesn't have a model then we re-place with the model

			local microStepData = currentStepData and currentStepData.microSteps[currentMicroStep]

			--print("Step:",STEPVALUE.Value,"Microstep:",currentMicroStep)
			if microStepData and microStepData.itemList then

				local emptySpotRemaining

				--We can't replace if we don't have any more!
				local itemId = model.ItemId.Value
				local inventoryTable = MODULES.Inventory.localInventory[itemId]
				local hasItem = inventoryTable.Quantity and inventoryTable.Quantity > 0
				local numInInventory = hasItem and inventoryTable.Quantity or 0

				local sameModels = {}
				for i,v in next,Tycoon:GetChildren() do
					if v.Name == model.Name and v.ClassName == "Model" and not v:FindFirstChild("LocalItem") and v.PrimaryPart then
						sameModels[#sameModels+1] = v
					end
				end

				if numInInventory > 0 then
					for i = 1,#microStepData.itemList do
						local itemData = microStepData.itemList[i]

						if itemData.Name == model.Name then
							local cf = CFrame.new(Tycoon.Base.CFrame * itemData.Placement)
								* CFrame.Angles(0,itemData.Rotation*(math.pi*.5),0)
								* CFrame.new(0,model.PrimaryPart.Size.y*.5 + Tycoon.Base.Size.y*.5,0)

							local modelIsAligned
							for _,v in next,sameModels do
								if hasModelCorrectlyAligned(v,cf) then
									modelIsAligned = true
								end
							end

							if not modelIsAligned then
								emptySpotRemaining = true
								break
							end
						end
					end
				end

				if emptySpotRemaining then
					spawn(function()
						MODULES.Placement.startPlacing(model.ItemId.Value)
					end)
				end
			end
			currentlyTalkingAboutThisWithJanice = nil
		end
	end
end

function tutorialRunStep()

	if not tutorialActive then
		return
	end

	if not initialStepCompleted then
		local thisStep = STEPVALUE.Value
		currentStepData = tutorialSteps[thisStep]
		if currentStepData then
			currentMicroStep = 1
			initialStepCompleted = true
		else
			--should they be over with the tutorial?
			if thisStep == #tutorialSteps + 1 then
				EVENT:FireServer(9)
			end
			doCleanup = true
			return
		end
	end

	if currentlyTalkingAboutThisWithJanice then
		--Update the camera
		if Camera.CameraType == Enum.CameraType.Scriptable then
			local model = currentlyTalkingAboutThisWithJanice
			local angle = ((tick()*.035)%1)*(math.pi*2)

			if model.PrimaryPart then
				local lookAt = model.PrimaryPart.Position
				local dist = model.PrimaryPart.Size.Magnitude + 2
				local tilt = math.pi/6
				local x,y = dist*math.cos(tilt),dist*math.sin(tilt)
				local cross = lookAt + Vector3.new(math.cos(angle),0,math.sin(angle))*x
				cross = cross + Vector3.new(0,y,0)
				Camera.CFrame = CFrame.new(cross,lookAt)
			end
		end
		return
	end

	local Tycoon = MODULES.Tycoon.getTycoon(localPlayer)
	if not Tycoon or Tycoon.Owner.Value ~= localPlayer.Name then
		return
	end

	--Check money
	local playerMoney = script.Parent.Money.Value
	if playerMoney >= 1000000 then
		--Oh great we gotta end early!
		if not millionSkip then
			millionSkip = true
			MODULES.tutorialFrame.Display('Step',{
				"Wow, you exceeded our expectation! You earned $1,000,000 before the tutorial ended!";
				"Good job on beating the tutorial! Welcome to Miners Haven!";
			},true)
			finalizeTutorial()
		end
		return
	end

	local currentMicroStepData = currentStepData.microSteps[currentMicroStep]

	if currentMicroStepData then
		--Do stuff about the current micro step
		if currentMicroStepData.microStepType == "Frame" then
			if not isDoingStep then
				isDoingStep = true
				MODULES.Buttons.addArrow()
				local success = MODULES.tutorialFrame.Display("Step",currentMicroStepData.Messages,true)
				if success then
					currentMicroStep = currentMicroStep + 1
				else
					--forcefully quit for some reason
					doCleanup = true
				end
				isDoingStep = false
				return
			end
		elseif currentMicroStepData.microStepType == "ListenForRP" then
			local currentPoints = script.Parent.Points.Value

			--They should initially have a daily gift
			--If their gift status is true, prompt them to open
				--Otherwise tell them to collect their boxes

			local GStat = localPlayer:WaitForChild("GiftStatus")
			if GStat.Value then
				MODULES.HUDRight.addArrow(true)
				MODULES.tutorialFrame.Display("Tipbox","InScreen",currentMicroStepData.Message)
			else
				if script.Parent.Points.Value < 1000 then
					MODULES.HUDRight.addArrow(false)
					MODULES.tutorialFrame.Display("Tipbox","InScreen",currentMicroStepData.noGiftMessage)
				else
					MODULES.HUDRight.addArrow(false)
					currentMicroStep = currentMicroStep + 1
				end
			end

		elseif currentMicroStepData.microStepType == "Listen" then

			local currentFrame = MODULES.Focus.current.Value

			local inventoryOpen = currentFrame == script.Parent.Inventory
			local shopOpen = currentFrame == script.Parent.Shop
			if not Tycoon or Tycoon.Owner.Value ~= localPlayer.Name then return end


			if not isListening then
				isListening = true
				for _,itemData in next,currentMicroStepData.itemList do
					makeGhostItem(itemData)
				end
			end

			--This is our run step
			local currentA = -math.huge
			local currentClosest
			local pastIsTransparent
			for pos,ghostModel in next,orderedModels do
				if not pastIsTransparent then
					if not ghostHasModelAligned(ghostModel) then
						--This is our primary focus target

						local pastModel = orderedModels[pos-1]
						spawn(function()
							startExplainingJanice(pastModel)
						end)

						--prompt part
						local primaryPart = ghostModel.PrimaryPart
						local part = ghostModel:FindFirstChild("ghostData")
						if primaryPart and part and localPlayer.Character and localPlayer.Character.PrimaryPart then
							currentModelListenStep = ghostModel
							local diff = primaryPart.Position - localPlayer.Character.PrimaryPart.Position
							local mag = diff.Magnitude
							local unit = diff.Unit
							local x,z = primaryPart.Size.x,primaryPart.Size.z
							local maxPartSize = (x*x + z*z)^.5
							local maxDist = maxPartSize + 20
							local minDist = maxPartSize + 10
							if mag < maxDist then
								local a = (maxDist-mag)/(maxDist-minDist)
								if a > currentA then
									currentA = a
									currentClosest = part
								else
									part.Transparency = 1
									part.SurfaceGui.Title.TextTransparency = 1
								end
							else
								part.Transparency = 1
								part.SurfaceGui.Title.TextTransparency = 1
							end
						end

						local tutorialText
						--ghost model color
						if PLACEMENT.isPlacing() then

							--Gotta find out if it's the same model as ours
							local models = PLACEMENT.getCurrentPlacingItems()
							if #models == 1 and models[1]:FindFirstChild("ItemId") and models[1].ItemId.Value == ghostModel.ItemId.Value then
								transformModel(ghostModel,.7,modelColors.correctPlacingItem)
							else
								--Placing something else ugh
								transformModel(ghostModel,.8,modelColors.incorrectPlacingItem)
								--update the tutorial text
								MODULES.Placement.stopPlacing()
							end

							--placement overriding
							if script.Parent.Placing.Count.Value > 0 then
								--Find our model
								local isAligned
								for i,v in next,Tycoon:GetChildren() do
									if v.ClassName == "Model" and v:FindFirstChild("HitboxClone") then
										if modelAlignedWithAGhost(v,true) then
											isAligned = true
										end
									end
								end

								MODULES.Placement.override(not isAligned)
							end
						else
							--Blue
							transformModel(ghostModel,.85,modelColors.PlacementReady)
						end

						--print('locking at pos:',pos)
						pastIsTransparent = true
					else
						--This model must be invisible because we already verified an item in its place
						transformModel(ghostModel,1,modelColors.WhenReadyAndPlacing)
						ghostModel.ghostData.Transparency = 1
						ghostModel.ghostData.SurfaceGui.Title.TextTransparency = 1
					end
				else
					--Anything after the primary focus target is transparent unless certain cases
					if not weTalkedAboutThisJanice[ghostModel.ItemId.Value] then
						transformModel(ghostModel,.8,modelColors.WhenReadyAndPlacing)
					else
						if PLACEMENT.isPlacing() then
							local models = PLACEMENT.getCurrentPlacingItems()
							if #models == 1 and models[1].ItemId.Value == ghostModel.ItemId.Value then
								--is there something already in place
								if ghostHasModelAligned(ghostModel) then
									transformModel(ghostModel,1,modelColors.WhenReadyAndPlacing)
								else
									transformModel(ghostModel,.7,modelColors.correctPlacingItem)
								end
							else
								transformModel(ghostModel,.9,modelColors.WhenReadyAndPlacing)
							end
						else
							transformModel(ghostModel,.9,modelColors.WhenReadyAndPlacing)
						end
					end
					ghostModel.ghostData.Transparency = 1
					ghostModel.ghostData.SurfaceGui.Title.TextTransparency = 1
				end
			end

			--Tween the prompt part
			if localPlayer.Character and localPlayer.Character.PrimaryPart then
				if currentClosest and currentClosest.Parent and currentClosest.Parent.Parent and currentClosest.Parent.PrimaryPart then
					local primaryPart = currentClosest.Parent.PrimaryPart
					local diff = primaryPart.Position - localPlayer.Character.PrimaryPart.Position
					local unit = diff.Unit
					local x,z = primaryPart.Size.x,primaryPart.Size.z
					local maxPartSize = (x*x + z*z)^.5
					currentA = currentA > 1 and 1 or currentA < 0 and 0 or currentA
					currentClosest.Transparency = .7 + .3*(1 - currentA)
					currentClosest.SurfaceGui.Title.TextTransparency = 1 - currentA
					currentClosest.SurfaceGui.Title.Text = currentClosest.Parent.Name
					currentClosest.CFrame = CFrame.new(primaryPart.Position.x,Tycoon.Base.Position.y + 3,primaryPart.Position.z)
						* CFrame.Angles(0,math.atan2(unit.x,unit.z),0)
						* CFrame.new(0,0,-maxPartSize)
						* CFrame.fromEulerAnglesYXZ(-math.pi*.1,math.pi,0)
				end
			end

			local toTargetBeam = getBeam("pointToTarget")
			if not toTargetBeam.startTick then
				toTargetBeam:setColor(Color3.new(0,1,.2))
				toTargetBeam.startTick = tick()
			end

			--We're listening, we need to direct the player to here
			local char = localPlayer.Character
			if currentModelListenStep and currentModelListenStep.PrimaryPart and char and char.PrimaryPart then
				local primaryPart = char.PrimaryPart

				--Check if we have an item in our inventory
				local itemId = currentModelListenStep.ItemId.Value
				local inventoryTable = MODULES.Inventory.localInventory[itemId]
				local hasItem = inventoryTable.Quantity and inventoryTable.Quantity > 0
				local numInInventory = hasItem and inventoryTable.Quantity or 0

				local currentPos = primaryPart.Position
				local targetPos = currentModelListenStep.PrimaryPart.Position

				local diff = targetPos - currentPos
				local mag = diff.Magnitude

				local oneIsOnBase do

					if not hasItem then
						--Find all items of same kind
						local items = {}
						local currentPos = currentModelListenStep.PrimaryPart.Position

						for _,c in next,Tycoon:GetChildren() do
							if c.ClassName == "Model" and c.PrimaryPart and not c:FindFirstChild("LocalItem") then
								if c:FindFirstChild("ItemId") and c.ItemId.Value == currentModelListenStep.ItemId.Value then
									items[#items+1] = c
								end
							end
						end

						--Next we sort based on proximity
						table.sort(items,function(m0,m1)
							local diff0 = currentPos - m0.PrimaryPart.Position
							local diff1 = currentPos - m1.PrimaryPart.Position

							return diff0.Magnitude < diff1.Magnitude
						end)

						--Finally, loop through and find the shortest non "model aligned" model

						for i = 1,#items do
							local item = items[i]
							if not modelAlignedWithAGhost(item) then
								oneIsOnBase = item
								break
							end
						end
					end

				end

				if PLACEMENT.isPlacing() then
					local models = PLACEMENT.getCurrentPlacingItems()
					local message
					local isCorrect
					if #models == 1 and models[1]:FindFirstChild("ItemId") and models[1].ItemId.Value == currentModelListenStep.ItemId.Value then
						isCorrect = true
						message = "Place the %q in the correct spot"
					else
						message = "That's not the correct item to place!"
					end
					message = message:format(currentModelListenStep.Name)
					local currentPos = models[1].PrimaryPart and models[1].PrimaryPart.Position
					if isCorrect and currentPos then
						MODULES.tutorialFrame.Display("Tipbox","NextToShop",message,true)
						toTargetBeam:Step(function(self)
							local targetPos = currentModelListenStep.PrimaryPart.Position
							local diff = targetPos - currentPos
							local mag = diff.Magnitude
							local Unit = diff.Unit
							self.a0.Position = currentPos + Unit*3
							self.a1.Position = targetPos + -Unit*3
							local timeDiff = (tick() - toTargetBeam.startTick)*.5
							local x = .5 - .5 * math.cos(math.pi*timeDiff + math.pi)
							return mag > 6 and x or false
						end)
					else
						toTargetBeam:Step(function(self)
							return false
						end)
					end
				else
					if oneIsOnBase and oneIsOnBase.PrimaryPart then

						--OI OI OI WAIT
						--PRIORITIZE THE INVENTORY ITEM FIRST YOU DINGUS
						local message = "You currently have a %q on your base. Lets move that!"

						local pos
						if not inventoryOpen and not shopOpen then
							pos = "InScreen"
						elseif shopOpen and not inventoryOpen then
							pos = "NextToShop"
						elseif inventoryOpen and not shopOpen then
							pos = "NextToInventory"
						else
							pos = "OutScreen"
						end

						MODULES.Buttons.addArrow()

						MODULES.tutorialFrame.Display("Tipbox",pos,message:format(currentModelListenStep.Name),true)
						toTargetBeam:Step(function(self)
							local targetPos = oneIsOnBase.PrimaryPart.Position
							local diff = targetPos - currentPos
							local mag = diff.Magnitude
							local Unit = diff.Unit
							self.a0.Position = currentPos + Unit*3
							self.a1.Position = targetPos + -Unit*3

							local timeDiff = (tick() - toTargetBeam.startTick)*.5
							local x = .5 - .5 * math.cos(math.pi*timeDiff + math.pi)
							return mag > 6 and x or false
						end)
					else
						if mag < 30 then
							toTargetBeam:Step(function(self)
								return false
							end)

							if not inventoryOpen and not shopOpen then
								local message
								if hasItem then
									message = "You have a %q in your inventory. Open it up!"
									MODULES.Buttons.addArrow("Inventory")
								else
									message = "Looks like you don't have a %q. Open up the shop!"
									MODULES.Buttons.addArrow("Shop")
								end

								MODULES.Shop.highlightTutorialItem()
								MODULES.Inventory.highlightTutorialItem()
								message = message:format(currentModelListenStep.Name)
								MODULES.tutorialFrame.Display('Tipbox',"InScreen",message,true)
							elseif inventoryOpen and not shopOpen then
								local message

								--Find out how many more you need to buy
									-- equation: numToBuy = numInMultiStepItemList - numOnBase - inventoryTable.Quantity

								local amountToBuy = 0
								local amountNeeded = 0
								for i,v in next,currentMicroStepData.itemList do
									if v.Name == currentModelListenStep.Name then
										amountToBuy = amountToBuy + 1
									end
								end
								amountNeeded = amountToBuy
								for i,v in next,Tycoon:GetChildren() do
									if v:FindFirstChild("ItemId") and not v:FindFirstChild("LocalItem") and v.ItemId.Value == itemId then
										if modelAlignedWithAGhost(v) then
											amountToBuy = amountToBuy - 1
										end
									end
								end
								amountToBuy = amountToBuy - numInInventory

								if hasItem then

									if amountToBuy > 0 then
										message = "You have the %q! Go ahead and find it in your inventory, but you will still need more later!"
									else
										message = "Find the %q in your inventory!"
									end

									--message = "Look for a %q in your inventory"
									--RIGHT HERE DO IT FOR INVENTORY
									MODULES.Inventory.highlightTutorialItem(itemId)
								else
									message = "You do not have the %q in your inventory. Close this and go to the shop."
									MODULES.Inventory.highlightTutorialItem()
								end
								MODULES.Buttons.addArrow()
								MODULES.Shop.highlightTutorialItem()
								message = message:format(currentModelListenStep.Name)
								MODULES.tutorialFrame.Display("Tipbox","NextToInventory",message,true)
							elseif shopOpen and not inventoryOpen then
								local message

								local amountToBuy = 0
								local amountNeeded = 0
								for i,v in next,currentMicroStepData.itemList do
									if v.Name == currentModelListenStep.Name then
										amountToBuy = amountToBuy + 1
									end
								end
								amountNeeded = amountToBuy
								for i,v in next,Tycoon:GetChildren() do
									if v:FindFirstChild("ItemId") and not v:FindFirstChild("LocalItem") and v.ItemId.Value == itemId then
										if modelAlignedWithAGhost(v) then
											amountToBuy = amountToBuy - 1
										end
									end
								end
								amountToBuy = amountToBuy - numInInventory

								if amountToBuy > 0 then
									message = "Look in the shop for a %q. You need "..amountToBuy.." more!"
								else
									message = "You don't need any more! Go back to your inventory."
								end

								MODULES.Shop.highlightTutorialItem(not hasItem and itemId or nil)
								MODULES.Buttons.addArrow()
								MODULES.Inventory.highlightTutorialItem()
								message = message:format(currentModelListenStep.Name)
								MODULES.tutorialFrame.Display("Tipbox","NextToShop",message,true)
							elseif shopOpen and inventoryOpen then
								MODULES.tutorialFrame.Display("Tipbox","OutScreen",nil,true)
								MODULES.Inventory.highlightTutorialItem(itemId)
								MODULES.Shop.highlightTutorialItem(itemId)
								MODULES.Buttons.addArrow()
							end
						else
							--Create the beam and stretch it towards primary part
							MODULES.Inventory.highlightTutorialItem()
							MODULES.Shop.highlightTutorialItem()
							MODULES.Buttons.addArrow()
							MODULES.HUDRight.addArrow()
							MODULES.tutorialFrame.Display("Tipbox","OutScreen",nil,true)
							toTargetBeam:Step(function(self)
								local Unit = diff.Unit
								self.a0.Position = currentPos + Unit*3
								self.a1.Position = targetPos + -Unit*24

								local timeDiff = (tick() - toTargetBeam.startTick)*.5
								local x = .5 - .5 * math.cos(math.pi*timeDiff + math.pi)
								return x
							end)
						end
					end
				end
			end

			if not pastIsTransparent and not currentlyTalkingAboutThisWithJanice then

				--Janice check
					--Gotta get that last item
				local model = orderedModels[#orderedModels]

				if PLACEMENT.isPlacing() then
					MODULES.Placement.stopPlacing()
				end

				if model and not weTalkedAboutThisJanice[model.ItemId.Value] then
					spawn(function() startExplainingJanice(model) end)
					return
				end

				toTargetBeam:Step(function()
					return false
				end)
				cleanupGhosts()
				currentMicroStep = currentMicroStep + 1
			end
		end
	else
		--Finished all microsteps, proceed the step
		EVENT:FireServer(STEPVALUE.Value + 1)
		return
	end
end

function tutorialModule.stopTutorial()
	EVENT:FireServer(10)
	tutorialActive = false

	local Tycoon
	repeat
		Tycoon = MODULES.Tycoon.getTycoon(localPlayer)
	until Tycoon and Tycoon.Owner.Value == localPlayer.Name

	for i,v in next,Tycoon:GetChildren() do
		if v.ClassName == "Model" then
			if v:FindFirstChild("Ignore") and v.Ignore.Value then
				v.Ignore:Destroy()
			end
		end
	end

	MODULES.tutorialFrame.Display("Tipbox","OutScreen","",true)

end

function tutorialModule.startTutorial()
	--Cleanup first
	Cleanup()

	--Prompt user if they want to start the tutorial
	local text
	if STEPVALUE.Value == 0 --[[or STEPVALUE.Value == 9]] then
		text = "Would you like to start the tutorial?"
	elseif STEPVALUE.Value < 9 then
		text = "Welcome back! Would you like to continue the tutorial?"
	end
	if text and localPlayer.Rebirths.Value == 0 then
		local decision = MODULES.InputPrompt.prompt(text)
		if decision and not tutorialActive then
			--Reset our value
			tutorialActive = true

			if STEPVALUE.Value == 0 then
				EVENT:FireServer(1)
				local startT = tick()
				repeat wait() until STEPVALUE.Value == 1 or tick() - startT > 10
			end

			changeStepState(true)
		else
			EVENT:FireServer(10)
		end
	end
end

function tutorialModule.isRunning()
	return tutorialActive
end

function tutorialModule.init(Modules)

	MODULES = Modules
	EVENT = repStorage:WaitForChild("SetTutorialStep")
	PLACEMENT = require(repStorage.PlacementModule)

	local stepValue = localPlayer:WaitForChild("PlayerTutorialStep")

	STEPVALUE = stepValue
	STEPVALUE.Changed:Connect(onTutorialStepChanged)

	spawn(function()
		repeat wait() until Modules.HasFinished and Modules.NewPlayer.Complete

		if DEBUG then
			--Always start the tutorial!
			EVENT:FireServer(0)
			repeat wait() until STEPVALUE.Value == 0
		end

		if stepValue.Value < 9 then
			tutorialModule.startTutorial()
		end
	end)
end




return tutorialModule