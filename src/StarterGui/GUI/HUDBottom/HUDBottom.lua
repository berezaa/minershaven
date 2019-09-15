local module = {}

	function module.init(Modules)
		script.Parent.Badges.MouseButton1Click:connect(function()
			Modules.Menu.sounds.Click:Play()
			Modules.Focus.change(script.Parent.Parent.Badges)
		end)
	end

return module
