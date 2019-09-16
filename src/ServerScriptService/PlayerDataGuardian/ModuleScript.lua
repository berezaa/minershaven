local module = {}

local DataLib = {}
function DataLib.GetTycoon(Player)
	for i,v in pairs(workspace.Tycoons:GetChildren()) do
		if Player.Name == v.Owner.Value then
			return v
		end
	end
	return nil
end

function DataLib.Shrink(Input)
	if math.abs(0 - Input) < 0.2 then
		return 0
	elseif math.abs(1 - Input) < 0.2 then
		return 1
	elseif math.abs(-1 - Input) < 0.2 then
		return -1
	end
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

			local xrot,yrot,zrot = DataLib.Shrink(HitboxDirection.x),DataLib.Shrink(HitboxDirection.y),DataLib.Shrink(HitboxDirection.z)
			DataTbl.Position = {PosVector.x, PosVector.y, PosVector.z, xrot, yrot, zrot}

			Return[#Return + 1] = DataTbl
		end
	end
	return Return
end

print(game:GetService("HttpService"):JSONEncode(DataLib.TycoonToTable(DataLib.GetTycoon(game.Players.berezaa))))

return module
