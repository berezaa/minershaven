--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

local module = {}

function module.init(Modules)

	local Tween = Modules.Menu.tween

	local CurrentId

	local function getBadgeById(BadgeId)
		for i,Badge in pairs(game.ReplicatedStorage.Badges:GetChildren()) do
			if Badge.Value == BadgeId then
				return Badge
			end
		end
	end

	game.ReplicatedStorage.BadgeEarned.OnClientEvent:connect(function(BadgeId)

		if BadgeId ~= 697770868 then

			CurrentId = BadgeId
			script.Parent.Position = UDim2.new(1,360,1,-200)
			script.Parent.Visible = true
			script.Parent.Icon.Image = "https://www.roblox.com/Thumbs/Asset.ashx?width=110&height=110&assetId="..BadgeId
			script.Parent.Description.Text = ""
			local Real = getBadgeById(BadgeId)
			if Real and Real:FindFirstChild("Description") then
				script.Parent.Description.Text = Modules.Translate.Item(Real)
			end
			Tween(script.Parent,{"Position"},UDim2.new(1,10,1,-200),0.5)
			Modules.Menu.sounds.Badge:Play()
			wait(7)
			if CurrentId == BadgeId then
				Tween(script.Parent,{"Position"},UDim2.new(1,360,1,-200),0.5)
				wait(0.5)
				if CurrentId == BadgeId then
					script.Parent.Visible = false
				end
			end

		end
	end)
end

return module
