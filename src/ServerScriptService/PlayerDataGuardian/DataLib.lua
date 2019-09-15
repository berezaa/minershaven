local DataLib = {}

--[[
DataLib.TycoonToTable(Tycoon)
DataLib.TableToTycoon(Table, Target, Player)
DataLib.LifeSuffix(Life)
DataLib.GetTycoon(Player)
--]]

function DataLib.Shrink(Input)
	if math.abs(0 - Input) < 0.2 then
		return 0
	elseif math.abs(1 - Input) < 0.2 then
		return 1
	elseif math.abs(-1 - Input) < 0.2 then
		return -1
	end
end

DataLib.DefaultBase = {
	{
	    ["ItemId"] = 73,
	    ["Position"] = {-88.5, 1.5, -88.5, 0, 0, -1}
	},
	{
	    ["ItemId"] = 73,
	    ["Position"] = {-79.5, 1.5, -88.5, 0, 0, -1}
	},
	{
	    ["ItemId"] = 73,
	    ["Position"] = {-79.5, 1.5, -79.5, 0, 0, -1}
	},
	{
	    ["ItemId"] = 73,
	    ["Position"] = {-88.5, 1.5, -79.5, 0, 0, -1}
	},
	{
	    ["ItemId"] = 87,
	    ["Position"] = {-114, 5, -39, 0, 0, -1}
	},
	{
	    ["ItemId"] = 105,
	    ["Position"] = {-84, 2, -84, 0, 0, -1}
	},
	{
	    ["ItemId"] = 21,
	    ["Position"] = {-30, 3.5, -78, 0, 0, 1}
	},

	{
	    ["ItemId"] = 36,
	    ["Position"] = {-94.5, 2, -115.5, 0, 0, 1}
	},
	{
	    ["ItemId"] = 36,
	    ["Position"] = {-67.5, 2, -70.5, 0, 0, 1}
	},

}

-- converts a long and messy float into a neat and short STRING
-- there's probably a better way to do this though

local function formatfloat(float)
	local str = tostring(float)
	local pos = str:find("%.")
	if pos then
		local pre = str:sub(1,pos-1)
		local suf = str:sub(pos+1, pos+2)
		if pre:len() > 0 and suf:len() > 0 then
			local sufval = tonumber(suf)
			local preval = tonumber(pre)
			if sufval and preval then
				local inc = 1
				if str:sub(1,1) == "-" then
					inc = -1
				end
				suf = "0"
				if (sufval >= 40 and sufval <= 60) or (sufval >= 4 and sufval <= 6) then
					suf = "5"
				elseif sufval >= 9 or sufval >= 90 then
					preval = preval + inc
				end
				return (tostring(preval) .. "." .. suf)
			end
		end
	end
	return float
end


function DataLib.TycoonToTable(Tycoon)
	local Return
	local TycoonBase = Tycoon.Base
	local TycoonTopLeft = TycoonBase.CFrame * CFrame.new(Vector3.new(TycoonBase.Size.x/2, 0, TycoonBase.Size.z/2))

	Return = {}
	for i, Object in pairs(Tycoon:GetChildren()) do
		if Object:IsA("Model") and Object:FindFirstChild("Hitbox") then
			local PosVector = Object.Hitbox.Position - TycoonTopLeft.p

			local HitboxDirection = Object.Hitbox.CFrame.lookVector

			local DataTbl = {}
			DataTbl.ItemId = Object.ItemId.Value

			if Object:FindFirstChild("Special") then
				DataTbl.Special = Object.Special.Value
			end

			local xrot,yrot,zrot = DataLib.Shrink(HitboxDirection.x),DataLib.Shrink(HitboxDirection.y),DataLib.Shrink(HitboxDirection.z)
			local vx = formatfloat(PosVector.x)
			local vy = formatfloat(PosVector.y,true)
			local vz = formatfloat(PosVector.z)

			DataTbl.Position = {vx, vy, vz, xrot, yrot, zrot}

			Return[#Return + 1] = DataTbl
		end
	end
	return Return
end

function DataLib.TableToTycoon(Table, Target, Player)

	local Models = {}

	local TycoonBase = Target.Base
	local TycoonTopLeft = TycoonBase.CFrame * CFrame.new(Vector3.new(TycoonBase.Size.x/2, 0, TycoonBase.Size.z/2))

	-- wipe the base before loading
	for i,Object in pairs(Target:GetChildren()) do
		if Object and Object:FindFirstChild("Hitbox") then
			Object:Destroy()
		end
	end

	for i, Object in pairs(Table) do
		local Item
		for i, Thing in pairs(game.ReplicatedStorage.Items:GetChildren()) do
			if Object.ItemId == Thing.ItemId.Value then
				Item = Thing
			end
		end

		Object.Position[1] = tonumber(Object.Position[1])
		Object.Position[2] = tonumber(Object.Position[2])
		Object.Position[3] = tonumber(Object.Position[3])

		local HitboxDirection = Vector3.new()
		local DirectionValue = Object.Position[4]

		if game.Players:FindFirstChild(Target.Owner.Value) == nil or game.Players:FindFirstChild(Target.Owner.Value) ~= Player then
			print("Player missing, stopping base saving")
			for i,Item in pairs(Models) do
				if Item then
					Item:Destroy()
				end
			end
			return false
		end

		if Player ~= nil or Player.Parent ~= game.Players then
			if Item then
				Item = Item:clone()
				Item.Parent = Target
				Item.PrimaryPart = Item.Hitbox
				if Object.Position[5] == nil then -- Legacy for old saving system
					DirectionValue = DirectionValue * 90
					Item:SetPrimaryPartCFrame(CFrame.new(TycoonTopLeft * Vector3.new(Object.Position[1], Object.Position[2], Object.Position[3]))*CFrame.Angles(0, (math.pi * (DirectionValue/180)), 0))
				else -- New advanced saving system
					local Position = TycoonTopLeft * Vector3.new(Object.Position[1], Object.Position[2], Object.Position[3])
					local lookVector = Vector3.new(Object.Position[4],Object.Position[5],Object.Position[6])
					local CoordinateFrame = CFrame.new(Position, Position + (lookVector * 5))
					Item:SetPrimaryPartCFrame(CoordinateFrame)
				end


				--local CheckRay = Ray.new(Item.Hitbox.Position, Vector3.new(0,-25,0))
				--local Hit = workspace:FindPartOnRayWithIgnoreList(CheckRay,{Target})
				--if Hit and Hit:FindFirstChild("Base") and Hit.Name == Target.Name then
					-- na dis good
				--else
				--	local Tag = Instance.new("BoolValue",Item)
				--	Tag.Name = "Withdraw" -- Order the client to withdraw it
					-- TODO: comply.
				--end

				if Item:FindFirstChild("Special") and Object["Special"] then
					Item.Special.Value = Object["Special"]
				end


				for i,v in pairs(Item.Model:GetChildren()) do
					if v.Name == "Colored" then
						v.BrickColor = Player.TeamColor
					end
					if v:IsA("Script") then
						v.Disabled = false
					end
				end

				Item.Hitbox.Transparency = 1
				Item.Hitbox.CanCollide = false

				table.insert(Models,Item)

				wait()
			end
		else
			print("Player missing, stopping base saving")
			return false
		end
	end
	return true
end

function DataLib.LifeSuffix(Life)
	local Suffix
	local LastDigit = tonumber(string.sub(tostring(Life),string.len(tostring(Life))))
	if Life <= 20 and Life >= 10 then
		Suffix = "th"
	elseif LastDigit == 1 then
		Suffix = "st"
	elseif LastDigit == 2 then
		Suffix = "nd"
	elseif LastDigit == 3 then
		Suffix = "rd"
	else
		Suffix = "th"
	end
	return Suffix
end

function DataLib.GetTycoon(Player)
	for i,v in pairs(workspace.Tycoons:GetChildren()) do
		if Player.Name == v.Owner.Value then
			return v
		end
	end
	return nil
end

return DataLib
