local module = {}


function module.init(Modules)

	script.Parent.Top.Close.MouseButton1Click:connect(function()
		Modules.Menu.sounds.Click:Play()
		Modules.Focus.close()
	end)

	script.Parent.Contents.Bottom.Close.MouseButton1Click:connect(function()
		Modules.Menu.sounds.Click:Play()
		Modules.Focus.close()
	end)

	script.Parent.Contents.Bottom.Buy.MouseButton1Click:connect(function()
		Modules.Menu.sounds.OpenedGift:Play()
		game.MarketplaceService:PromptPurchase(game.Players.LocalPlayer,268427885)
	end)
end

return module
