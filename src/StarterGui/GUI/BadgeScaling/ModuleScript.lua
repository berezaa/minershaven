local module = {}


script.Parent.Size = UDim2.new(0,0,0,0)
script.Parent.Visible = false


function module.init(Modules)

	local function displayBadge(badgeId)
		local badgeInfo = game:GetService("BadgeService"):GetBadgeInfoAsync(badgeId)
		local IconImageId = badgeInfo.IconImageId
		script.Parent.Image = "rbxassetid://"..IconImageId
		script.Parent.Size = UDim2.new(0,0,0,0)
		script.Parent.ImageTransparency = 0
		script.Parent.Visible = true
		Modules.Menu.sounds.Badge:Play()
		game.ContentProvider:PreloadAsync({script.Parent})
		Modules.Menu.tween(script.Parent, {"Size", "ImageTransparency"}, {UDim2.new(0,700,0,700), 1}, 1)
	end

	game.ReplicatedStorage.BadgeAwardedNew.OnClientEvent:Connect(displayBadge)

end

return module
