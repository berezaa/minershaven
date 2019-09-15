local module = {}

function module.init(Modules)

	local MoneyLib = Modules.MoneyLib

	local Player = game.Players.LocalPlayer
	for i,Currency in pairs(script.Parent:GetChildren()) do
		if Currency:IsA("GuiObject") then

			Currency.Visible = false
			spawn(function()
				local Real = Player:WaitForChild(Currency.Name)
				Real.Changed:connect(function()
					if Real.Value > 0 then
						Currency.Visible = true
						Currency.Value.Text = MoneyLib.DealWithPoints(Real.Value)
					else
						Currency.Visible = false
					end
				end)
				if Real.Value > 0 then
					Currency.Visible = true
					Currency.Value.Text = MoneyLib.DealWithPoints(Real.Value)
				else
					Currency.Visible = false
				end
			end)

		end
	end
end

return module
