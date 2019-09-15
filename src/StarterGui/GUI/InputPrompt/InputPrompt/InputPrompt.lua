
local module = {}

local runService = game:GetService("RunService")

local promptOut
local promptFrame = script.Parent.Parent
local buttonCons = {}
local currentDecision

function quint(a,b,c)
	local lerp = a + (b - a)*c
	return lerp*lerp*lerp*lerp
end

function module.forceClose()
	if promptOut then
		currentDecision = false
	end
end

function module.isPrompting()
	return promptOut
end

-- moved under module.init
function module.prompt(headerText)
	warn("InputPrompt.prompt not ready yet.")
end

function module.init(Modules)
	-- This function is called after all modules have been required
	-- Modules is a table of all of the modules, indexed by name only
	-- ex. module at GUI.ItemPreview.Frame.Preview is Modules.Preview
	-- TWO MODULES CANNOT HAVE THE SAME NAME!

	promptFrame.Absorb.Visible = false

	promptFrame.BackgroundTransparency = 1
	promptFrame.InputPrompt.Position = UDim2.new(0.5,0,0,-250)
	promptFrame.Visible = true

	Modules.Focus.current.Changed:Connect(function(Object)
		if promptOut then
			currentDecision = false
		end
	end)

	function module.prompt(headerText)
		if promptOut then
			return false
		end

		-- temp measure

		local function selfIsSelected()
			local obj = game:GetService("GuiService").SelectedObject

			if obj then
				return obj:IsDescendantOf(promptFrame)
			else
				return false
			end
		end

		promptOut = true

		local transitionOut

		--First we initiate the prompt
		promptFrame.InputPrompt.Position = UDim2.new(0.5,0,0,-250)
		promptFrame.InputPrompt.Title.Text = headerText
		promptFrame.Transparency = 1

		local con0 = promptFrame.InputPrompt.No.MouseButton1Click:Connect(function()
			Modules.Menu.sounds.Click:Play()
			currentDecision = false
		end)
		local con1 = promptFrame.InputPrompt.Yes.MouseButton1Click:Connect(function()
			Modules.Menu.sounds.Click:Play()
			currentDecision = true
		end)

		--Transition the stuff into the screen
		--spawn(function()
			-- use my tween function nerd



		promptFrame.Absorb.Visible = true
		Modules.Menu.tween(promptFrame,{"BackgroundTransparency"}, .5, 0.7, Enum.EasingStyle.Quint)
		Modules.Menu.tween(promptFrame.InputPrompt, {"Position"}, UDim2.new(0.5,0,0.5,0), 0.7, Enum.EasingStyle.Quint)

			--[[

			local startT = tick()
			for i = 1,60*deltaT do
				if transitionOut then
					break
				end
				local now = tick() - startT
				local a = now/deltaT
				local inputFrameY = quint(-.5,.5,a)
				local bgTransparency = quint(1,.6,a)
				promptFrame.BackgroundTransparency = bgTransparency
				promptFrame.InputPrompt.Position = UDim2.new(0,0,inputFrameY,0)
				runService.Heartbeat:Wait()
			end
			]]

		--end)


		--Yield the thread until an answer pops up
		repeat
			local Xbox = Modules.Input.mode.Value == "Xbox"
			if Xbox and not selfIsSelected() then
				Modules.Focus.stealFocus(promptFrame.InputPrompt)
			end
			runService.Heartbeat:Wait()
		until currentDecision ~= nil

		local thisDecision = currentDecision
		currentDecision = nil

		--Disconnect the buttons
		con0:Disconnect()
		con1:Disconnect()

		--make prompt ready
		promptOut = false


	--	spawn(function()

		promptFrame.Absorb.Visible = false
		Modules.Menu.tween(promptFrame,{"BackgroundTransparency"}, 1, 0.7, Enum.EasingStyle.Quint)
		Modules.Menu.tween(promptFrame.InputPrompt, {"Position"}, UDim2.new(0.5,0,0,-250), 0.7, Enum.EasingStyle.Quint)
		--[[
		local startT = tick()
		for i = 1,60*deltaT do
			if promptOut then
				break
			end
			local now = tick() - startT
			local a = now/deltaT
			local inputFrameY = quint(.5,-.5,a)
			local bgTransparency = quint(.6,1,a)
			promptFrame.BackgroundTransparency = bgTransparency
			promptFrame.InputPrompt.Position = UDim2.new(0,0,inputFrameY,0)
			runService.Heartbeat:Wait()
		end
		]]
	--	end)

		return thisDecision
	end

end


return module