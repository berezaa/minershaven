-- PVP STUFF
function GetTycoon(player)
	for i,v in pairs(workspace.Tycoons:GetChildren()) do
		if game.Players:FindFirstChild(v.Owner.Value) == player then
			return v
		end
	end
	return nil
end

local function CreatePermTag(Permission, Parent)
	local Tag = Instance.new("BoolValue")
	Tag.Name = Permission
	Tag.Parent = Parent
	return Tag
end

function game.ReplicatedStorage.TogglePerm.OnServerInvoke(Player, Permissee, Perm)
	local Permissions = Permissee.Permissions:FindFirstChild(Player.Name)
	print(Permissee.Name)
	print(tostring(Permissions))
	if Permissions then
		local PermTag = Permissions:FindFirstChild(Perm)
		if PermTag then
			PermTag.Value = not PermTag.Value
		else
			PermTag = CreatePermTag(Perm, Permissions)
			PermTag.Value = true
		end
		if Permissee.ActiveTycoon.Value == Player.PlayerTycoon.Value then
			game.ReplicatedStorage.Hint:FireClient(Permissee,string.upper(Perm).." permission set to "..string.upper(tostring(PermTag.Value)),Color3.new(0.5,0.5,1))
		end
		game.ReplicatedStorage.PermissionsChanged:FireClient(Player)
		game.ReplicatedStorage.PermissionsChanged:FireClient(Permissee)
		return true
	else
		print("Could not find permissions")
	end
	return false
end

game.ServerStorage.Currency.Event:connect(function(Owner,Target,String,Color,Time,Sound)
	if Owner then
		local Tycoon = Owner.PlayerTycoon.Value
		if Tycoon then
			for i,Player in pairs(game.Players:GetPlayers()) do
				if Player.ActiveTycoon.Value == Tycoon then

					game.ReplicatedStorage.Currency:FireClient(Player,Target,String,Color,Time,Sound)
				end
			end
		end
	end
end)

function game.ReplicatedStorage.TogglePermissions.OnServerInvoke(Player, Permissee)
	if Permissee.Permissions:FindFirstChild(Player.Name) then

		Permissee.Permissions:FindFirstChild(Player.Name):Destroy()
		if Permissee.ActiveTycoon.Value == Player.PlayerTycoon.Value then
			Permissee.ActiveTycoon.Value = nil
			game.ReplicatedStorage.Hint:FireClient(Permissee,Player.Name.." has revoked your permissions!",Color3.new(1,0.5,0.5))
		end
	else

		local Perms = Instance.new("BoolValue")
		Perms.Name = Player.Name

		CreatePermTag("Build", Perms).Value = true
		CreatePermTag("Buy", Perms).Value = false
		CreatePermTag("Sell", Perms).Value = false

		Perms.Parent = Permissee.Permissions

		local Character = Permissee.Character
		if Character and Character:FindFirstChild("HumanoidRootPart") then
			local Tycoon = Player.PlayerTycoon.Value
			if Tycoon then
				if (Character.HumanoidRootPart.Position - Tycoon.Base.Position).magnitude < Tycoon.Base.Size.X * 1.25 then
					Permissee.ActiveTycoon.Value = Tycoon
					game.ReplicatedStorage.Hint:FireClient(Permissee,Player.Name.." has added you to their base!",Color3.new(0.5,1,0.5))
				end
			end
		end

	end
	game.ReplicatedStorage.PermissionsChanged:FireClient(Permissee)
--	game.ReplicatedStorage.InventoryChanged:FireClient(Permissee)
	game.ReplicatedStorage.PermissionsChanged:FireClient(Player)
	return true
end



local function IsSafe(Player, Hit)
	if Hit then
		if Hit.Name == "Safe" then
			return true
		elseif Player.ActiveTycoon.Value and Hit:IsDescendantOf(Player.ActiveTycoon.Value) then
			return true
		end
	end
	return false
end

game.ServerStorage.PlayerDataLoaded.Event:connect(function(Player)
	local TycoonTag = Player:FindFirstChild("ActiveTycoon")
	if TycoonTag then
		TycoonTag.Value = GetTycoon(Player)
	end
end)

local function FindTycoon(Character)
	if Character and Character:FindFirstChild("HumanoidRootPart") then
		for i,Tycoon in pairs(workspace.Tycoons:GetChildren()) do
			if (Character.HumanoidRootPart.Position - Tycoon.Base.Position).magnitude <= Tycoon.Base.Size.X * 1.25 then
				if (Character.HumanoidRootPart.Position.Y - Tycoon.Base.Position.Y) >= -20 then
					return Tycoon
				end
			end
		end
	end
end

game.Players.PlayerAdded:connect(function(Player)
	local TycoonTag = Instance.new("ObjectValue")
	TycoonTag.Name = "ActiveTycoon"
	TycoonTag.Parent = Player

	local NearTag = Instance.new("ObjectValue")
	NearTag.Name = "NearTycoon"
	NearTag.Parent = Player


	local Permissions = Instance.new("Folder")
	Permissions.Name = "Permissions"
	Permissions.Parent = Player

	Player.CharacterAdded:connect(function(Character)
		local Alive = true

		local Human = Character:WaitForChild("Humanoid")
		Human.Died:connect(function()
			Alive = false
		end)

		while Alive do

			local NearestTycoon = FindTycoon(Character)
			if NearestTycoon then
				if Player.Permissions:FindFirstChild(NearestTycoon.Owner.Value) or Player.PlayerTycoon.Value == NearestTycoon then
					if Player.ActiveTycoon.Value == nil then
						if NearestTycoon == Player.PlayerTycoon.Value then
							game.ReplicatedStorage.Hint:FireClient(Player,"Welcome back to your base.")
						else
							game.ReplicatedStorage.Hint:FireClient(Player,"Now entering "..NearestTycoon.Owner.Value.."'s base.")
						end
						Player.ActiveTycoon.Value = NearestTycoon
						game.ReplicatedStorage.PermissionsChanged:FireClient(Player)
					end
				elseif Player.NearTycoon.Value ~= NearestTycoon and NearestTycoon:FindFirstChild("SpecialMusic") and NearestTycoon.SpecialMusic.Value ~= 0 then
					game.ReplicatedStorage.Hint:FireClient(Player,"Now playing "..NearestTycoon.Owner.Value.."'s music.",nil,nil,"Swoosh")
				elseif NearestTycoon.Owner.Value == "" and Player.ActiveTycoon.Value == NearestTycoon then
					Player.ActiveTycoon.Value = nil
					game.ReplicatedStorage.Hint:FireClient(Player,"The base owner has left the game.",nil,nil,"Swoosh")
				end
				Player.NearTycoon.Value = NearestTycoon
			else
				Player.NearTycoon.Value = nil
				if Player.ActiveTycoon.Value then
					game.ReplicatedStorage.Hint:FireClient(Player,"You've left the base.",nil,nil,"Swoosh")
					Player.ActiveTycoon.Value = nil
				end
			end

			local Rey = Ray.new(Character.HumanoidRootPart.Position,Vector3.new(0,-100,0))
			local Whitelist = {workspace.Tycoons,workspace.Map:FindFirstChild("Safe")}
			local Hit = workspace:FindPartOnRayWithWhitelist(Rey,Whitelist,true)
			if IsSafe(Player, Hit) then
				if Character.Humanoid:FindFirstChild("Safe") == nil then
					local Tag = Instance.new("BoolValue")
					Tag.Name = "Safe"
					Tag.Parent = Character.Humanoid
					local Shine = script.Protected:Clone()
					Shine.Parent = Character.HumanoidRootPart
					Shine.Enabled = true
					spawn(function()
						wait(1)
						Shine.Enabled = false
						wait(2)
						Shine:Destroy()
					end)

				end
			else
				if Character.Humanoid:FindFirstChild("Safe") then
					Character.Humanoid.Safe:Destroy()
					local Shine = script.NotProtected:Clone()
					Shine.Parent = Character.HumanoidRootPart
					Shine.Enabled = true
					spawn(function()
						wait(1)
						Shine.Enabled = false
						wait(2)
						Shine:Destroy()
					end)
				end
			end
			wait(1)
		end
	end)
end)
-- NO MORE PVP

game.Players.PlayerAdded:connect(function(Player)
	local Tag = Instance.new("BoolValue")
	Tag.Name = "Editing"
	Tag.Value = true
	Tag.Parent = Player
end)

-- Money Mirror


game.ServerStorage.MoneyStorage.ChildAdded:connect(function(Child)
	local newTag = Instance.new("NumberValue")
	newTag.Name = Child.Name
	newTag.Value = Child.Value
	newTag.Parent = game.ReplicatedStorage.MoneyMirror
	Child.Changed:connect(function()
		newTag.Value = Child.Value
	end)
end)

game.ServerStorage.MoneyStorage.ChildRemoved:connect(function(Child)
	local newTag = game.ReplicatedStorage.MoneyMirror:FindFirstChild(Child.Name)
	if newTag then
		newTag:Destroy()
	end
end)

