local light

local function checklight()
	if light then
		if script.Parent.Handle.SpotLight.Brightness > 0 then
			light.Brightness = 0.5
		else
			light.Brightness = 0.1
		end
	end
end

script.Parent.Equipped:connect(function()
	local Torso = script.Parent.Parent:FindFirstChild("HumanoidRootPart")
	if Torso then
		light = Torso:FindFirstChild("Light")
		checklight()
	end
end)


function click()
	if script.Parent.Handle.SpotLight.Brightness > 0 then

		script.Parent.Handle.SpotLight.Brightness = 0
		script.Parent.Click:play()


	elseif script.Parent.Handle.SpotLight.Brightness == 0 then

		script.Parent.Handle.SpotLight.Brightness = 10
		script.Parent.Click:play()

	end

	checklight()
end

script.Parent.Activated:connect(click)

script.Parent.Unequipped:connect(function()
	if light then
		light.Brightness = 0.1
	end
end)
