--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
This script was created under a contract originally for exclusive use for this project and the author, Locard.
Please include this copyright & permission notice in all copies or substantial portions of the Software.
]]

local module = {}

local MODULES

local isDisplaying
local masterFrame

local Positions

local nextColors = {
	Green = Color3.fromRGB(119,189,65);
	Blue = Color3.fromRGB(150,235,81);
}
local white = Color3.new(1,1,1)
local oppositeBlue = Color3.fromRGB(84,131,45)

function module.isDisplaying()
	return isDisplaying
end

function module.forceStop()
	if not isDisplaying then
		return
	end


end

--This function yields the thread!
--Returns true if done with displaying
function module.Display(displayType,...)

	if displayType == "Step" then

		--Kind of like a page book

		local messages,Override = ...

		if not Override and isDisplaying then
			return
		end

		if not messages or #messages == 0 then
			return
		end

		isDisplaying = true

		--Set up
		masterFrame.StepFrame.Visible = true
		masterFrame.ListFrame.Visible = false
		masterFrame.TipFrame.Visible = false

		masterFrame.Size = UDim2.new(.3,0,.2,0)
		masterFrame.Position = Positions.OutScreen()



		local stepFrame = masterFrame.StepFrame
		local currentMessage = 1
		local Pass

		local function selfIsSelected()
			local obj = game:GetService("GuiService").SelectedObject

			if obj then
				return obj:IsDescendantOf(masterFrame)
			else
				return false
			end
		end

		local Xbox = MODULES.Input.mode.Value == "Xbox"
		if Xbox and not selfIsSelected() then
			MODULES.Focus.stealFocus(stepFrame)
			--[[
			game.GuiService:AddSelectionParent("TutorialFrame",masterFrame.StepFrame)
			game.GuiService.GuiNavigationEnabled = true
			game.GuiService.SelectedObject = masterFrame.StepFrame.Right
			]]--
		end

		--local functions
		local function updateText()
			stepFrame.TextBody.Text = messages[currentMessage]

			local showNext = currentMessage == #messages
			stepFrame.Right.Text = showNext and "Next" or ">"
			stepFrame.Right.Image.ImageColor3 = showNext and nextColors.Blue or nextColors.Green
			stepFrame.Right.TextColor3 = showNext and oppositeBlue or white

			local propT = {"ImageTransparency"}
			MODULES.Menu.tween(stepFrame.Left.Image, propT, currentMessage == 1 and .7 or 0, .35, Enum.EasingStyle.Quint)
			MODULES.Menu.tween(stepFrame.Left.Depth, propT, currentMessage == 1 and .7 or 0, .35, Enum.EasingStyle.Quint)
			MODULES.Menu.tween(stepFrame.Left,{"TextTransparency"}, currentMessage == 1 and .7 or 0, .35,Enum.EasingStyle.Quint)
		end

		--Create connections
		local Cons = {}

		--left/right connections

		Cons[#Cons+1] = stepFrame.Left.MouseButton1Click:Connect(function()
			local newNum = currentMessage - 1
			if newNum < 1 then
				MODULES.Menu.sounds.Error:Play()
			else
				currentMessage = newNum
				MODULES.Menu.sounds.Click:Play()
			end
			updateText()
		end)
		Cons[#Cons+1] = stepFrame.Right.MouseButton1Click:Connect(function()
			local newNum = currentMessage + 1
			MODULES.Menu.sounds.Click:Play()
			if newNum > #messages then
				Pass = true
			else
				currentMessage = newNum
				updateText()
			end
		end)
		updateText()

		masterFrame.Position = Positions.OutScreen()
		masterFrame.Visible = true
		MODULES.Menu.tween(masterFrame,{"Position"},Positions.InScreen(), .4, Enum.EasingStyle.Quint)

		repeat
			local Xbox = MODULES.Input.mode.Value == "Xbox"
			if Xbox and not selfIsSelected() then
				MODULES.Focus.stealFocus(stepFrame)
			end
			wait()
		until Pass ~= nil

		MODULES.Menu.tween(masterFrame,{"Position"},Positions.OutScreen(), .4, Enum.EasingStyle.Quint)

		for _,con in next,Cons do
			con:Disconnect()
		end

		if Xbox then
			game.GuiService:RemoveSelectionGroup("TutorialFrame")
			if MODULES.Focus.current.Value then
				MODULES.Focus.change(MODULES.Focus.current.Value)
			end
		end

		if Pass then
			--Next step
			isDisplaying = false
			return true
		else
			--Force broke
		end

	elseif displayType == "List" then

		--Displays a list of items

		local updateTable,Override = ...

		if not Override and isDisplaying then
			return
		end

		isDisplaying = true

		--Set up
		masterFrame.StepFrame.Visible = false
		masterFrame.ListFrame.Visible = true
		masterFrame.TipFrame.Visible = false

		masterFrame.Size = UDim2.new(.3,0,.2,0)

	elseif displayType == "Tipbox" then

		--Gives a little tip, needs to be positioned though

		local side,message,Override = ...

		if not Override and isDisplaying then
			return
		end
		isDisplaying = true

		local Pos = Positions[side or 'InScreen']()

		masterFrame.StepFrame.Visible = false
		masterFrame.ListFrame.Visible = false
		masterFrame.TipFrame.Visible = true

		masterFrame.Size = UDim2.new(.2,0,.15,0)

		if message then
			masterFrame.TipFrame.TextBody.Text = message
		end

		masterFrame.Position = Pos

	else
		return
	end
end

function module.init(Modules)
	MODULES = Modules
	local Sounds = Modules.Menu.sounds

	masterFrame = script.Parent
	masterFrame.Position = UDim2.new(.5,0,1,272)

	Positions = {
		InScreen = function()
			return UDim2.new(.5,-masterFrame.AbsoluteSize.x*.5,1,-masterFrame.AbsoluteSize.y + -85)
		end;
		OutScreen = function()
			return UDim2.new(.5,-masterFrame.AbsoluteSize.x*.5,1,272)
		end;
		NextToShop = function()
			return UDim2.new(0,10,1,-masterFrame.AbsoluteSize.y + -10)
		end;
		NextToInventory = function()
			return UDim2.new(1,-masterFrame.AbsoluteSize.x + -10,1,-masterFrame.AbsoluteSize.y + -10)
		end;
	}

	script.Parent.Top.Close.MouseButton1Click:Connect(function()
		Sounds.Click:Play()

		--This'll close out of the tutorial.

		local success = MODULES.InputPrompt.prompt("Do you really want to exit the tutorial?")

		if success then
			MODULES.Tutorial.stopTutorial()
		end
	end)
end


return module