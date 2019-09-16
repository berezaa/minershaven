--[[
local Parts = {}

workspace:WaitForChild("Map")

for i,Part in pairs(workspace.Map.Parts:GetChildren()) do
	local Col = Part.Color
	if Part.Name ~= "Excempt" and Col.g > Col.r + 0.2 and Col.g > Col.b + 0.1 then
		table.insert(Parts, Part)
	end
end


local CloverParent = workspace:FindFirstChild("EventClovers")
if CloverParent == nil then
	CloverParent = Instance.new("Folder")
	CloverParent.Name = "EventClovers"
	CloverParent.Parent = workspace
end
]]
game.ReplicatedStorage.BuyEventItem.OnServerInvoke = function(Player, ItemName)
	if ItemName == "LuckyCrate" then
		local Amount = 20
		if Player.MagicClovers.Value >= Amount then
			Player.MagicClovers.Value = Player.MagicClovers.Value - Amount
			local Crate = game.ServerStorage.LuckyCrate:Clone()
			Crate.Parent = workspace
			Crate.CFrame = Player.Character.PrimaryPart.CFrame + Vector3.new(0,10,0)
			return true
		end
	end
	local RealItem = game.ReplicatedStorage.Items:FindFirstChild(ItemName)
	if RealItem and RealItem:FindFirstChild("MagicClover") then
		local Amount = RealItem.MagicClover.Value
		if Amount > 0 and Player.MagicClovers.Value >= Amount then
			Player.MagicClovers.Value = Player.MagicClovers.Value - Amount
			game.ServerStorage.AwardItem:Invoke(Player, RealItem.ItemId.Value)
			return true
		end
	end
	return false
end
--[[
local Rand = Random.new(os.time())

function place(Clover)


	local Part = Parts[Rand:NextInteger(1,#Parts)]
	local s = Part.Size

	local Repre = Clover:Clone()

	local Scale = 2
	--local Scale = Rand:NextInteger(10,35)/10
	Repre.Size = Repre.Size * Scale
	Repre.Mesh.Scale = Repre.Mesh.Scale * Scale
	--Repre.Color = Part.Color

	--Repre.Size = Vector3.new(1,1,1)
	local v = Vector3.new( Rand:NextInteger(-s.x/2.3,s.x/2.3), s.y/2 + Repre.Size.Y/2, Rand:NextInteger(-s.z/2.3, s.z/2.3) )
	local Offset = Part.CFrame:vectorToWorldSpace(v)
	local Top = Part.CFrame:vectorToWorldSpace(v - Vector3.new(0, s.y/2 + Repre.Size.Y/2, 0))
	local Rey = Ray.new(Top, (Offset - Top)*10)

	local Block = workspace:FindPartOnRay(Rey, Part)
	if Block and Block.Parent == Part.Parent then
		Repre:Destroy()
	else
		local Rotation = CFrame.Angles(0,math.rad(Rand:NextInteger(-180,180)),0)
		--Rotation = Rotation:toObjectSpace(Part.CFrame)

		--Repre.Name = "Clover"
		Repre.Parent = CloverParent
		Repre.Anchored = true
		Repre.CFrame = (Part.CFrame * Rotation) + Offset
		local Tag = Instance.new("BoolValue")
		Tag.Name = "Clover"
		Tag.Parent = Repre
	end

	return Repre
end

local function HandleClover(Player, Target)
	if Target:FindFirstChild("Claimed") == nil then
		if Target:FindFirstChild("Clover") then

			if Player and Player.Character and Player.Character.HumanoidRootPart then
				if (Player.Character.HumanoidRootPart.Position - Target.Position).magnitude > (Target.ClickDetector.MaxActivationDistance * 1.3) then
					return false
				end
			else
				return false
			end

			local Claimed = Instance.new("BoolValue")
			Claimed.Name = "Claimed"
			Claimed.Parent = Target

			Target.Transparency = 1
			game.ReplicatedStorage.Boom:FireClient(Player, Target)
			--Target.Transparency = 0.5
			local Amount = 1
			if Target.Name == "DiamondClover" then
				Amount = 10
			elseif Target.Name == "GoldenClover" then
				Amount = 3
			end

			local Prefix = (Amount == 1 and "") or Amount.." "

			Player.MagicClovers.Value = Player.MagicClovers.Value + Amount
			game.ReplicatedStorage.Currency:FireClient(Player,Target,"+"..Amount.." Magic Clover",Color3.new(0.3, 1, 0.4),3,245520987)
			game.ReplicatedStorage.CurrencyPopup:FireClient(Player,Prefix.."Magic Clover",Color3.fromRGB(68, 193, 60),"http://www.roblox.com/asset/?id=1488547146")
			wait(3)
			if Target then
				Target:Destroy()
			end
		end
	end
end

game.ReplicatedStorage.Click.OnServerEvent:connect(HandleClover)

while wait(0.1) do
	if #CloverParent:GetChildren() < 250 then
		local Multi = #game.Players:GetPlayers()
		if game.VIPServerId ~= "" then
			Multi = Multi * 0.5
		end
		local Clover
		local Lifetime = 180
		local Chance = Rand:NextInteger(1,10000)
		-- Diamond Clovers
		if Chance >= 77 and Chance <= (77 + Multi) then
			Clover = place(game.ServerStorage.DiamondClover)
			Lifetime = 600
		elseif Chance >= 7777 and Chance <= (7777 + 4 * Multi) then
			Clover = place(game.ServerStorage.GoldenClover)
			Lifetime = 300
		elseif Chance >= 777 and Chance <= (777 + 65 * Multi) then
			Clover = place(game.ServerStorage.MagicClover)
		end
		if Clover then
			Clover.Touched:connect(function(Hit)
				if Hit.Parent:FindFirstChild("Humanoid") then
					local Player = game.Players:GetPlayerFromCharacter(Hit.Parent)
					if Player then
						HandleClover(Player, Clover)
					end
				end
			end)
			game.Debris:AddItem(Clover, Lifetime)
		end
	end
end



]]
