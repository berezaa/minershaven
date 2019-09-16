local module = {}

function module.init(Modules)
	local Sounds = Modules.Menu.sounds
	local Player = game.Players.LocalPlayer

	for i,Button in pairs(script.Parent:GetChildren()) do
		if Button:FindFirstChild("PassId") then
			if Player:FindFirstChild(Button.Name) then
				Button.Buy.Text = "Owned"
				Button.Buy.BackgroundColor3 = Color3.fromRGB(190,190,190)
			end
			Button.Buy.MouseButton1Click:connect(function()
				Sounds.Click:Play()
				game.MarketplaceService:PromptPurchase(Player, Button.PassId.Value)
			end)
		end
	end
end


return module