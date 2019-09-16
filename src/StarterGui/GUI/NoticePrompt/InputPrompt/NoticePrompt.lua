
local module = {}

local runService = game:GetService("RunService")

local promptFrame = script.Parent.Parent
local buttonCons = {}
local Queue = {}
local doBreak

function quint(a,b,c)
	local lerp = a + (b - a)*c
	return lerp*lerp*lerp*lerp
end

function module.forceClose()
	doBreak = true
end

function module.isPrompting()
	return #Queue > 0
end

-- moved under module.init
function module.giveNotice(headerText)
	warn("InputPrompt.giveNotice not ready yet.")
end

function module.init(Modules)



	-- This function is called after all modules have been required
	-- Modules is a table of all of the modules, indexed by name only
	-- ex. module at GUI.ItemPreview.Frame.Preview is Modules.Preview
	-- TWO MODULES CANNOT HAVE THE SAME NAME!

	promptFrame.Absorb.Visible = false

	promptFrame.BackgroundTransparency = 1
	promptFrame.InputPrompt.Position = UDim2.new(0.5,0,0,-400)
	promptFrame.Visible = true
	--[[
	Modules.Focus.current.Changed:Connect(function(Object)
		doBreak = true
	end)
	]]


	local function doTheNotice()
		if not Queue[1] then
			return
		end

		local text,buttonText = unpack(Queue[1])

		local function selfIsSelected()
			local obj = game:GetService("GuiService").SelectedObject

			if obj then
				return obj:IsDescendantOf(promptFrame)
			else
				return false
			end
		end

		--First we initiate the prompt
		promptFrame.InputPrompt.Position = UDim2.new(0.5,0,0,-400)
		promptFrame.InputPrompt.Title.Text = text
		promptFrame.InputPrompt.Ok.Text = buttonText
		promptFrame.Transparency = 1

		local con1 = promptFrame.InputPrompt.Ok.MouseButton1Click:Connect(function()
			Modules.Menu.sounds.Click:Play()
			doBreak = true
		end)

		promptFrame.Absorb.Visible = true
		Modules.Menu.tween(promptFrame,{"BackgroundTransparency"}, .5, 0.7, Enum.EasingStyle.Quint)
		Modules.Menu.tween(promptFrame.InputPrompt, {"Position"}, UDim2.new(0.5,0,0.5,0), 0.7, Enum.EasingStyle.Quint)

		repeat
			local Xbox = Modules.Input.mode.Value == "Xbox"
			if Xbox and not selfIsSelected() then
				Modules.Focus.stealFocus(promptFrame.InputPrompt)
			end
			runService.Heartbeat:Wait()
		until doBreak

		doBreak = nil

		--Disconnect the buttons
		con1:Disconnect()

		promptFrame.Absorb.Visible = false
		Modules.Menu.tween(promptFrame,{"BackgroundTransparency"}, 1, 0.7, Enum.EasingStyle.Quint)
		Modules.Menu.tween(promptFrame.InputPrompt, {"Position"}, UDim2.new(0.5,0,0,-400), 0.7, Enum.EasingStyle.Quint)

		--Wait for the transition to finish
		wait(.7)

		--remove the first index
		table.remove(Queue,1)

		--Condition for continuous text
		if Queue[1] then
			doTheNotice()
		end

	end

	function module.giveNotice(headerText,optionalButtonText)
		optionalButtonText = optionalButtonText or "Ok"
		Queue[#Queue+1] = {headerText,optionalButtonText}
		if #Queue > 1 then
			return
		end
		doTheNotice()
	end

	game.ReplicatedStorage.Prompt.OnClientEvent:Connect(module.giveNotice)
end


return module