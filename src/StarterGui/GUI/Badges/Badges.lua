-- Badge Tracker

--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]


local module = {}

function module.init(Modules)

	local Player = game.Players.LocalPlayer

	game.StarterGui:SetCore("BadgesNotificationsActive",false)
	game.StarterGui:SetCore("PointsNotificationsActive",false)

	local function scan()
		local Count = 0
		local Badges = #game.ReplicatedStorage.Badges:GetChildren()
		for i,Badge in pairs(script.Parent.Items:GetChildren()) do
			if Badge:IsA("ImageButton") and Badge.Visible then
				if Player:FindFirstChild(Badge.Name) then
					Badge.ImageTransparency = 0
					Count = Count + 1
				else
					Badge.ImageTransparency = 0.8
				end
				Badge.Description.Visible = false
			end
		end
		local completion = math.floor((Count/Badges) * 100)
		script.Parent.Mastery.Text = tostring(completion).."\%".." Miner's Haven Mastery"
		script.Parent.Parent.HUDBottom.Badges.Hover.Title.Text = tostring(completion).."\%"
		script.Parent.Parent.HUDBottom.Badges.Hover.Title.Under.Text = tostring(completion).."\%"
	end
	Player.ChildAdded:connect(scan)

	spawn(function()

		for i,Badge in pairs(game.ReplicatedStorage.Badges:GetChildren()) do
			if Badge:FindFirstChild("LayoutOrder") then
				local Button = script.Parent.Items.SampleBadge:Clone()
				Button.Image = "https://www.roblox.com/Thumbs/Asset.ashx?width=110&height=110&assetId="..Badge.Value
				Button.LayoutOrder = Badge.LayoutOrder.Value
				Button.Parent = script.Parent.Items
				Button.Name = "Badge"..tostring(Badge.Value)
				Button.Visible = true
				local Success, Error = pcall(function()
					local Desc = Badge:FindFirstChild("Description")
					if Desc == nil then
						local Info = game.MarketplaceService:GetProductInfo(Badge.Value)
						if Info and Info.Description then
							Desc = Instance.new("StringValue")
							Desc.Name = "Description"
							Desc.Value = Info.Description
							Desc.Parent = Badge

						end
					end
					Button.Description.Text = Desc.Value
				end)
				if not Success then
					warn("Error finding information for badge "..Badge.Name)
				end

				local function Select()
					scan()
					Button.ImageTransparency = 0.8
					Button.Description.Visible = true
				end
				local function Unselect()
					if Player:FindFirstChild(Button.Name) then
						Button.ImageTransparency = 0
					else
						Button.ImageTransparency = 0.8
					end
					Button.Description.Visible = false
				end

				Button.MouseEnter:connect(Select)
				Button.MouseLeave:connect(Unselect)
				Button.SelectionGained:connect(Select)
				Button.SelectionLost:connect(Unselect)
			end
		end



		scan()
	end)

	script.Parent.Top.Close.MouseButton1Click:connect(function()
		Modules.Menu.sounds.Click:Play()
		Modules.Focus.close()
	end)

end

return module
