local module = {}


function module.init(Modules)

	local Sounds = Modules["Menu"]["sounds"]

	for i=1,5 do
		local Tab = script.Parent.Sample:Clone()

		Tab.Name = tostring(i)

		local function CloseTab()
			Sounds.Error:Play()
			Tab.Visible = false
			Tab.PlayerName.Text = ""
		end

		local function Toggle()
			Sounds.Click:Play()
			local Player = game.Players:FindFirstChild(Tab.PlayerName.Text)
			if Player then
				local Success = game.ReplicatedStorage.TogglePermissions:InvokeServer(Player)
				if Success then
				else
					Sounds.Error:Play()
				end
			else
				CloseTab()
			end
		end

		Tab.Parent = script.Parent.Players
		Tab.Add.MouseButton1Click:connect(Toggle)
		Tab.Rem.MouseButton1Click:connect(Toggle)

		for i,Button in pairs(Tab:GetChildren()) do
			if Button:FindFirstChild("Perm") then
				Button.MouseButton1Click:connect(function()
					Sounds.Click:Play()
					local Player = game.Players:FindFirstChild(Tab.PlayerName.Text)
					if Player then
						local Success = game.ReplicatedStorage.TogglePerm:InvokeServer(Player, Button.Name)
						if not Success then
							Sounds.Error:Play()
						end
					end
				end)
			end
		end
	end

	local function HasPermission(Player, Perm)
		local Permissions = Player.Permissions:FindFirstChild(game.Players.LocalPlayer.Name)
		if Permissions then
			local Permission = Permissions:FindFirstChild(Perm)
			if Permission and Permission.Value then
				return true
			end
		end
		return false
	end

	local function UpdatePermissions()
		local Count = 1
		for i,Player in pairs(game.Players:GetPlayers()) do
			local Button = script.Parent.Players:FindFirstChild(tostring(Count))
			if Button and Player:WaitForChild("Permissions") and Player ~= game.Players.LocalPlayer then
				Button.PlayerName.Text = Player.Name
				if Player.Permissions:FindFirstChild(game.Players.LocalPlayer.Name) then
					Button.Add.Visible = false

					for i, Perm in pairs(Button:GetChildren()) do
						if Perm:FindFirstChild("Perm") then
							Perm.Visible = true
							Perm.BackgroundColor3 = HasPermission(Player, Perm.Name) and Color3.new(86/255, 149/255, 85/255) or Color3.new(149/255, 97/255, 98/255)
						end
					end

					Button.Rem.Visible = true
				else
					Button.Add.Visible = true

					for i, Perm in pairs(Button:GetChildren()) do
						if Perm:FindFirstChild("Perm") then
							Perm.Visible = false
						end
					end

					Button.Rem.Visible = false

				end
				Button.Visible = true
				Count = Count + 1
			end
		end

		for i=Count,5 do
			local Button = script.Parent.Players:FindFirstChild(tostring(Count))
			Button.Visible = false
			Button.PlayerName.Text = ""
		end

		if Count <= 1 then
			script.Parent.Parent.Visible = false
		else
			script.Parent.Parent.Visible = true
		end
	end

	local function RefreshMulti()
		UpdatePermissions()
	end

	game.Players.PlayerAdded:connect(RefreshMulti)
	game.Players.PlayerRemoving:connect(RefreshMulti)
	RefreshMulti()

	game.ReplicatedStorage.PermissionsChanged.OnClientEvent:connect(UpdatePermissions)
end

return module
