--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

local module = {}


local placement

module.placing = false
module.visual = nil

local LastModel

local Player = game.Players.LocalPlayer

--local Platforms = {}

local Debounce = true

local function getItemById(Id)
	for i,Item in pairs(game.ReplicatedStorage.Items:GetChildren()) do
		if Item.ItemId.Value == Id then
			return Item
		end
	end
end

-- ONLY FOR PARTS I GUESS
local function scan(Item, Property, Value)
	if Item:IsA("BasePart") then
		Item[Property] = Value
	end
	for i,Child in pairs(Item:GetChildren()) do
		scan(Child, Property, Value)
	end
end
--[[
local function RoundByThree(Number)
	if math.floor(Number) == Number then
		if Number%3 == 0 then
			return Number
		elseif (Number - 1)%3 == 0 then
			return Number - 1
		elseif (Number + 1)%3 == 0 then
			return Number + 1
		end
	end
	return Number
end
]]

local Selectables = {}

local function RoundByThree(Number)
	local Mod = math.floor(Number / 3)
	local Remain = Number - (Mod * 3)
	if Remain < 1.5 then
		return Mod * 3
	else
		return (Mod * 3) + 3
	end
end

local Rotation = 0
local GoodPlacement = false

local PlaceStartPoint

module.count = script.Parent.Placing.Count

local placement

function module.init(Modules)

	local placementlastpos

	local Preview = Modules["Preview"]
	local Mode = Modules["Input"]["mode"]
	local HUD = Modules["HUD"]
	local Menu = Modules["Menu"]
	local Sounds = Menu["sounds"]
	local TycoonLib = Modules["TycoonLib"]
	local getTycoon = TycoonLib.getTycoon

	local Settings = game.Players.LocalPlayer:FindFirstChild("PlayerSettings")

	local function reini()
		local tycoon = getTycoon(game.Players.LocalPlayer) or game.Players.LocalPlayer.PlayerTycoon.Value
		local plane = tycoon.Base
		local obstacles = tycoon
		local grid = 3
		local smooth = Settings.SmoothPlace.Value
		placement = require(game.ReplicatedStorage.PlacementModule).new(plane, obstacles, grid, Modules, smooth)
	end

	reini()

	Settings.SmoothPlace.Changed:connect(function()
		placement:toggleWobble(Settings.SmoothPlace.Value)
	end)


	game.Players.LocalPlayer.ActiveTycoon.Changed:connect(function()
		if game.Players.LocalPlayer.ActiveTycoon.Value then
			reini()
		end
	end)

	local connection

	local function superscan(Object) -- throwback to when this was a naming conflict and broke everything hahahaha kill me
		for i,Part in pairs(Object:GetDescendants()) do
			if (Part.Name == "Hitbox" or Part:FindFirstChild("ClickDetector") or Part.Name == "Cover") and Part:IsA("BasePart") then
				table.insert(Selectables,Part)
			-- LOCAL CANNON

			end
		end
	end

	local function tycoonSetup()
		if connection then
			connection:disconnect()
		end
		Selectables = {}
		local Tycoon = game.Players.LocalPlayer.ActiveTycoon.Value
		if Tycoon then
			superscan(Tycoon)
			connection = Tycoon.ChildAdded:connect(function(Child)
				wait(0.25)
				if Child:FindFirstChild("LocalItem") == nil and Child:FindFirstChild("Representation") == nil then
					superscan(Child)
				end
			end)
		end
	end

	tycoonSetup()
	game.Players.LocalPlayer.ActiveTycoon.Changed:connect(tycoonSetup)

	local Highlight = Instance.new("Part")
	Highlight.Anchored = true
	Highlight.Material = "SmoothPlastic"
	Highlight.CanCollide = false
	Highlight.Transparency = 0.4

	local Light = Instance.new("PointLight")
	Light.Name = "Light"
	Light.Brightness = 2
	Light.Enabled = true
	Light.Parent = Highlight

	local LastHighlight

	local SelectionHigh = script.Parent.SelectionHigh

	local Mesh = Instance.new("BlockMesh")
	Mesh.Name = "Mesh"
	Mesh.Scale = Vector3.new(1,0.5,1)
	Mesh:Clone().Parent = Highlight

	Mesh.Scale = Vector3.new(1.2,500,1.2)

	local Mouse = Player:GetMouse()

	local MouseDown = false

	local Selected = {}



	local PlacedHistory = {}

	local LastPosition

	local PlaceTag = script.Placing




	local function findButtonById(Buttons,Id)
		for i,Button in pairs(Buttons) do
			if Button:FindFirstChild("ItemId") and Button.ItemId.Value == Id then
				return Button
			end
		end
	end


	local function Shift(Object)
		if Object.Visible then
			local Button = Object.Button.Value
			if Button and Button.Parent then

				if Button.ItemId.Value < 1 or Button.ItemId.Value ~= Object.Id.Value then -- something smells funky here

					local NewButton = findButtonById(Button.Parent:GetChildren(),Object.Id.Value) -- fallback in case buttons are changed.

					if NewButton and NewButton.Parent and NewButton.ItemId.Value > 0 then
						Button = NewButton
					else
						Object.Visible = false
						return false
					end
				end

				spawn(function()
					module.startPlacing(Button.ItemId.Value, Button)
				end)

			else
				Object.Visible = false
			end
		end
	end

	local Objects = {}

	function module.wipePlacing()

		LastPosition = nil
		placementlastpos = nil
		local Tycoon = game.Players.LocalPlayer.ActiveTycoon.Value
		if Tycoon then
			local Repre = Tycoon:FindFirstChild("Representation")
			if Repre then
				Repre:Destroy()
			end
			for i,Item in pairs(Tycoon:GetChildren()) do
				if Item:FindFirstChild("LocalItem") then
					Item:Destroy()
				end
			end
		end
		Objects = {}
		placement:disable()
	end

	function module.stopPlacing()

		module.wipePlacing()


		local Tycoon = game.Players.LocalPlayer.ActiveTycoon.Value

		if Modules.Input.mode.Value == "Mobile" then
			workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		end

		PlaceTag.Visible = false
		PlaceTag.Parent = script
		module.placing = false


		script.Parent.Placing.Visible = false

		for i,Item in pairs(Tycoon:GetChildren()) do
			if Item:FindFirstChild("SelectionBox") then
				Item.SelectionBox.Visible = false
			end
		end

		if Mouse then
			Mouse.TargetFilter = nil
		end

		Modules.HUD.showHUD()

		--Grid display
		for i,v in next,Tycoon:GetChildren() do
			local grid = v.ClassName == "Model" and v:FindFirstChild("Model") and v.Model:FindFirstChild("BasePart")
			grid = grid and grid:FindFirstChild("Grid")
			if grid then
				grid.Transparency = 1
			elseif v == Tycoon.Base then
				Tycoon.Base.Grid.Transparency = 1
			end
		end
	end



--[[
█▀▀█ █░░ █▀▀█ █▀▀ ░▀░ █▀▀▄ █▀▀▀
█░░█ █░░ █▄▄█ █░░ ▀█▀ █░░█ █░▀█
█▀▀▀ ▀▀▀ ▀░░▀ ▀▀▀ ▀▀▀ ▀░░▀ ▀▀▀▀
]]

	local LocalTag = Instance.new("BoolValue")
	LocalTag.Name = "LocalItem"


	function module.place()


		local Tycoon = Player.ActiveTycoon.Value
		if Tycoon == nil then
			return false
		end

		local LastPoz


		if placement:isGood() then
			if #Objects == 1 then
				local Poz = placement:place()
				if Poz == nil then
					return false
				end

				local Position = Poz[1]

				if Position == LastPosition then
					return false
				end
				LastPosition = Position

				local Repre = Objects[1]:Clone()
				Repre.Name = "Representation"
				Repre:SetPrimaryPartCFrame(Position)

				if LastPoz ~= Position then
					local Sound = Sounds.Placement:Clone()
					Sound.Parent = Repre.Hitbox
					Sound:Play()
				end
				LastPoz = Position

				script.Parent.Placing.Count.Value = script.Parent.Placing.Count.Value - 1
				script.Parent.Placing.Amount.Text = script.Parent.Placing.Count.Value.." Left"

				--[[
				if Repre:FindFirstChild("LocalItem") then
					Repre.LocalItem:Destroy()
				end
				]]


				--Sounds.Placement:Play()
				--game.SoundService:PlayLocalSound(Sounds.Placement)

				Repre.Parent = Tycoon

				--print('attempting to place item:',Objects[1].Name)
				local Model = game.ReplicatedStorage.PlaceItem:InvokeServer(Objects[1].Name, Position)
				--print('placed item at:',Position)
				if Model ~= nil then
					if Model:FindFirstChild("SelectionBox") and module.placing then
						Model.SelectionBox.Visible = true
					end

					--[[
					--PLATFORM STUFF
					if Model:FindFirstChild("Platform") then
						local placementModule = require(game.ReplicatedStorage.PlacementModule)
						local tycoon = getTycoon(game.Players.LocalPlayer) or game.Players.LocalPlayer.PlayerTycoon.Value
						local smooth = Settings.SmoothPlace.Value
						Platforms[Model] = placementModule.new(Model.PrimaryPart, tycoon, 3, Modules, smooth)
					end
					]]--

					table.insert(PlacedHistory, Model)
				else
					script.Parent.Placing.Count.Value = script.Parent.Placing.Count.Value + 1
					script.Parent.Placing.Amount.Text = script.Parent.Placing.Count.Value.." Left"
				end

				Repre:Destroy()
			elseif #Objects > 1 then
				local Positions = placement:place()
				if Positions == nil then
					return false
				end
				local ItemData = {}
				for i,Object in pairs(Objects) do
					ItemData[i] = {Object.Name, Positions[i]}
				end
				local Models = game.ReplicatedStorage.PlaceMultiple:InvokeServer(ItemData)
				if Models and #Models > 0 then
					Sounds.Placement:Play()
					module.stopPlacing() -- stop placing with multi-place
					for i,Model in pairs(Models) do
						table.insert(PlacedHistory,Model)
					end
				else
					Sounds.Error:Play()
				end
			end
		end
		return false
	end

	local function findClosest(Buttons, Value)
		local Smaller
		local Greater
		for i,Button in pairs(Buttons) do
			if Button:IsA("GuiButton") and Button.Visible then
				if Button.LayoutOrder > Value then
					if Greater then
						if Button.LayoutOrder < Greater.LayoutOrder then
							Greater = Button
						end
					else
						Greater = Button
					end
				elseif Button.LayoutOrder < Value then
					if Smaller then
						if Button.LayoutOrder > Smaller.LayoutOrder then
							Smaller = Button
						end
					else
						Smaller = Button
					end
				end
			end
		end
		return Smaller,Greater
	end

	function module.shiftleft(_, Type)

		if Type and Type ~= Enum.UserInputState.Begin then
			return false
		end

		Shift(script.Parent.Placing.Left)
	end

	function module.shiftright(_, Type)

		if Type and Type ~= Enum.UserInputState.Begin then
			return false
		end

		Shift(script.Parent.Placing.Right)
	end

	function module.startPlacing(Id, Button)



		--module.stopPlacing()
		Modules.Focus.close()
		game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)
		script.Parent.Inventory.Visible = false
		Modules.ItemInfo.hide()
		module.wipePlacing()
		game.ReplicatedStorage.Blur.Size = 0




		--if Modules.Input.mode.Value ~= "PC" then
			Modules.HUD.hideHUD()
			if Modules.Input.mode.Value == "Xbox" then
				game.GuiService.SelectedObject = nil
				game.GuiService.GuiNavigationEnabled = false

			end
		--end

		local Tycoon = game.Players.LocalPlayer.ActiveTycoon.Value
		if Tycoon == nil then
			return false
		end

		for i,Child in pairs(Tycoon:GetChildren()) do
			if Child:FindFirstChild("SelectionBox") then
				Child.SelectionBox.Visible = true
			end
		end

		Sounds.Move:Play()
		LastPosition = nil

		local Item



		if type(Id) == "userdata" and Id:IsA("Model") then
			Item = Id
			if Item:FindFirstChild("ItemId") then
				LocalTag:Clone().Parent = Item
				Item.Parent = Tycoon
				table.insert(Objects,Item)
				Id = Item.ItemId.Value
			else
				LocalTag:Clone().Parent = Item
				Id = -99 -- Special id for multi-placing
				for i,Object in pairs(Item:GetChildren()) do
					if Object:IsA("Model") and Object:FindFirstChild("Hitbox") then
						table.insert(Objects,Object)
						Object.Parent = Tycoon
					end
				end
				Item:Destroy()
				Item = nil
			end
		else
			Item = getItemById(Id):Clone()
			table.insert(Objects,Item)
		end

		module.placingId = Id

		for i,Object in pairs(Objects) do
			Object.PrimaryPart = Object.Hitbox
			LocalTag:Clone().Parent = Object
			if Object:FindFirstChild("SelectionBox") then
				Object.SelectionBox.Visible = false
			end
		end

		if Id ~= -99 then
			spawn(function()
				local Count = game.ReplicatedStorage.HasItem:InvokeServer(Id)
				script.Parent.Placing.Count.Value = Count

				script.Parent.Placing.Amount.Text = Count.." Left"
				script.Parent.Placing.Amount.Visible = true
			end)
		else
			script.Parent.Placing.Amount.Text = "Placing multiple items"
			script.Parent.Placing.Amount.Visible = true
		end


		if Button then

			PlaceTag.Parent = Button
			PlaceTag.Visible = true

			local Left,Right
			if Id ~= -99 then
				Left,Right = findClosest(Button.Parent:GetChildren(),Button.LayoutOrder)
			end

			if Left and Left:FindFirstChild("ItemId") then
				script.Parent.Placing.Left.Visible = true
				script.Parent.Placing.Left.Item.Favorite.Visible = Left.Favorite.Visible
				script.Parent.Placing.Left.Item.Image = Left.Thumbnail.Image

				script.Parent.Placing.Left.Button.Value = Left
				script.Parent.Placing.Left.Id.Value = Left.ItemId.Value
			else
				script.Parent.Placing.Left.Visible = false
			end

			if Right and Right:FindFirstChild("ItemId") then
				script.Parent.Placing.Right.Visible = true
				script.Parent.Placing.Right.Item.Favorite.Visible = Right.Favorite.Visible
				script.Parent.Placing.Right.Item.Image = Right.Thumbnail.Image

				script.Parent.Placing.Right.Button.Value = Right
				script.Parent.Placing.Right.Id.Value = Right.ItemId.Value
			else
				script.Parent.Placing.Right.Visible = false
			end

		else
			script.Parent.Placing.Right.Visible = false
			script.Parent.Placing.Left.Visible = false
		end

		script.Parent.Placing.Amount.Visible = false

		if true then


			script.Parent.Placing.Visible = true

			-- Show Hitboxes

			--local Arrows = {}

			local Tycoon = getTycoon(game.Players.LocalPlayer)

			if Tycoon then

				Tycoon.Base.Grid.Transparency = 0



				for e,Object in pairs(Objects) do
					scan(Object, "Transparency", 0.5)
					scan(Object, "BrickColor", BrickColor.new("Bright blue"))
					Object.Parent = Tycoon
					if Object:FindFirstChild("Hitbox") and Object:FindFirstChild("Model") then
						Object.Hitbox.Transparency = 1
						Object.PrimaryPart = Object.Hitbox

						--L--
						--Got rid of all conveyor arrow logic in this script
						--New location is GUI.ArrowHandler
						--Will ignore things that aren't a conveyor
						Modules.ArrowHandler.addConveyor(Object)
					end
				end

			end





			local LocalItemTag = Instance.new("BoolValue")
			LocalItemTag.Name = "LocalItem"
			LocalItemTag.Parent = Item





			local Mouse = game.Players.LocalPlayer:GetMouse()
			if Mouse then
				Mouse.TargetFilter = Tycoon
			end




			if Tycoon then



				local Itemboxes = {}




				local TycoonBase = Tycoon.Base
				local TycoonTopLeft = TycoonBase.CFrame * CFrame.new(Vector3.new(TycoonBase.Size.x/2, 0, TycoonBase.Size.z/2))

				script.Parent.Placing.Hydrolics.Visible = false

				for i,Object in pairs(Objects) do
					if Object:FindFirstChild("Hitbox") and Object.Hitbox:FindFirstChild("AdjustableHeight") and Object.Hitbox.AdjustableHeight.Value > 0 then
						script.Parent.Placing.Hydrolics.Visible = true
					end
				end


				placement:enable(Objects)

				--[[
				for model,meta in next,Platforms do
					meta:enable(Objects,true)
				end
				]]--

				module.placing = true

				local lastpos
				--[[
				placedSignal:connect(function(cf, model) -- location represents the CFrame of the model, item is the model you provided earlier

					if module.placing and model:FindFirstChild("SelectionBox") then
						model.SelectionBox.Visible = true
						model.SelectionBox.Transparency = 0
					end

					local Repre = Instance.new("Model")
					Repre.Name = "Representation"
					local ReHit = model:Clone()
					model:SetPrimaryPartCFrame(cf)
					ReHit.Parent = Repre
					Repre.Parent = Tycoon
					scan(Repre, "Transparency", 0.7)

					local real = game.ReplicatedStorage.PlaceItem:InvokeServer(model.Name, Tycoon, cf)
					if real == nil then
						Sounds.Error:Play()
					else
						if PlaceStartPoint == nil then
							PlaceStartPoint = ReHit.PrimaryPart.Position
						end
						GoodPlacement = false
						table.insert(PlacedHistory,real)
						Sounds.Placement.Pitch = 1 + math.random(-100,100)/500
						Sounds.Placement:Play()
						script.Parent.Placing.Count.Value = game.ReplicatedStorage.HasItem:InvokeServer(model.ItemId.Value)
						script.Parent.Placing.Amount.Text = script.Parent.Placing.Count.Value.." Left"

						if script.Parent.Placing.Count.Value <= 0 then --???? how is that nil
							if module.visual == nil or module.visual == model or module.visual.ItemId.Value == model.ItemId.Value then
								module.stopPlacing()
							end
						end
					end

					Repre:Destroy()
				end)
				]]

				local initialDelay = .25
				local startPlace
				local pastInitialPlacement
				while module.placing and Id == module.placingId do
					if MouseDown then
						--print(not pastInitialPlacement,tick() - startPlace > initialDelay)
						startPlace = startPlace or tick()
						if not pastInitialPlacement or tick() - startPlace > initialDelay then
							local placementPos = placement:pos()
							if lastpos ~= placementPos then
								lastpos = placementPos
								if module.count.Value > 0 or module.placingId == -99 then
									module.place()
									pastInitialPlacement = true
								end
							end
						end
					else
						lastpos = nil
						pastInitialPlacement = nil
						startPlace = nil
					end
					game:GetService("RunService").Heartbeat:wait()
				end

				--[[

				Visual:SetPrimaryPartCFrame(TycoonTopLeft * CFrame.new(Vector3.new(-Hitbox.Size.x/2, Hitbox.Size.y/2, -Hitbox.Size.z/2)))


				local TycoonBaseSizeX, TycoonBaseSizeZ
				local HitboxSizeX, HitboxSizeZ
				local Hitboxes
				local NewVector

			--	local LastPosition = CFrame.new()



				-- Important placing functions that god help me I am not redoing.
				-- update: i'm going to have to redo them
				local function VerifyPos()
					local ModelColliding
					local function Argue()
						for i, Hitbox in pairs(Hitboxes) do
							if Hitbox.Name == "Hitbox" and not Hitbox:IsDescendantOf(Visual) then
								return false
							end
						end
						local CheckRay = Ray.new(Visual.Hitbox.Position, Vector3.new(0,-500,0))
						local Hit = workspace:FindPartOnRayWithIgnoreList(CheckRay,{Tycoon,workspace.DroppedParts})
						if Hit and Hit:FindFirstChild("Base") and Hit.Name == Tycoon.Name then
							return true
						end
						return false
					end

					local ModelColliding = not Argue()

					GoodPlacement = not ModelColliding
					Visual:SetPrimaryPartCFrame(NewVector * CFrame.Angles(0, math.rad(Rotation), 0))

					-- new change. Shift if out of items


					if GoodPlacement then
				--		LastPosition = Visual.Hitbox.CFrame --NewVector * CFrame.Angles(0, math.rad(Rotation), 0)
						if Visual.Hitbox.BrickColor ~= BrickColor.new("Bright blue") then
							scan(Visual, "BrickColor", BrickColor.new("Bright blue"))
							for i,Box in pairs(Itemboxes) do
								if Box.Parent:FindFirstChild("SelectionBox") then
									Box.Parent.SelectionBox.Color3 = Color3.new(0.0509804, 0.411765, 0.67451)
								end
							end
						end
					--	Visual.SelectionBox.Color3 = Color3.new(0.0509804, 0.411765, 0.67451)
					else
						if Visual.Hitbox.BrickColor ~= BrickColor.new("Really red") then
							scan(Visual, "BrickColor", BrickColor.new("Really red"))
							for i,Box in pairs(Itemboxes) do
								if Box.Parent:FindFirstChild("SelectionBox") then
									Box.Parent.SelectionBox.Color3 = Color3.new(1,0,0)
								end
							end
						end
					--	Visual.SelectionBox.Color3 = Color3.new(1,0,0)
					end
				end

				local function CheckPos(xdisp,zdisp,placepos) -- placepos is Mouse.Hit.p on pc

					-- straight line placing assist
					if PlaceStartPoint ~= nil then
						local xdiff = math.abs(PlaceStartPoint.x - placepos.x)
						local zdiff = math.abs(PlaceStartPoint.z - placepos.z)

						local dist = (placepos - PlaceStartPoint).magnitude


						if LastHighlight == nil or LastHighlight.Name ~= "Allign" or LastHighlight.Parent == nil then
							if LastHighlight then
								LastHighlight:Destroy()
							end
							LastHighlight = Highlight:Clone()
							LastHighlight.BrickColor = BrickColor.new("Lime green")
							LastHighlight.Size = Vector3.new(1,1,1)
							LastHighlight.Name = "Allign"
							LastHighlight.Parent = Tycoon
						end

						LastHighlight.CFrame = CFrame.new(PlaceStartPoint)

						if (zdiff < 2 and zdiff < xdiff) or (zdiff < 5 and zdiff < xdiff / 2) or (zdiff < 8 and zdiff < xdiff / 4) then
							placepos = placepos + Vector3.new(0,0, PlaceStartPoint.z - placepos.z)
							if dist > 3 then
								LastHighlight.Transparency = 0.3
								LastHighlight.Mesh.Scale = Vector3.new(999,0.2,0.2)
							else
								LastHighlight.Transparency = 1
							end
						elseif (xdiff < 2 and xdiff < zdiff) or (xdiff < 5 and xdiff < zdiff / 2) or (xdiff < 8 and xdiff < zdiff / 4) then
							placepos = placepos + Vector3.new(PlaceStartPoint.x - placepos.x,0,0)
							if dist > 3 then
								LastHighlight.Transparency = 0.3
								LastHighlight.Mesh.Scale = Vector3.new(0.2,0.2,999)
							else
								LastHighlight.Transparency = 1
							end
						else
							LastHighlight.Transparency = 1
						end

					end
					-- end placing assist

					xdisp = xdisp or 0
					zdisp = zdisp or 0

					local xdispco = 0.5
					local zdispco = 0.5

					if Rotation % 180 == 0 then
						TycoonBaseSizeX, TycoonBaseSizeZ = TycoonBase.Size.x, TycoonBase.Size.z
						HitboxSizeX, HitboxSizeZ = Hitbox.Size.x, Hitbox.Size.z
					else
						TycoonBaseSizeX, TycoonBaseSizeZ = TycoonBase.Size.x, TycoonBase.Size.z
						HitboxSizeX, HitboxSizeZ = Hitbox.Size.z, Hitbox.Size.x
					end

					local TycoonTopLeft = TycoonBase.CFrame * CFrame.new(Vector3.new(TycoonBase.Size.x/2, 0, TycoonBase.Size.z/2))

					local BaseAngleX, BaseAngleY, BaseAngleZ = CFrame.new(TycoonBase.Position, (TycoonBase.CFrame*Vector3.new(1, 0, 0))):toEulerAnglesXYZ()
					local VectorRotation = CFrame.Angles(BaseAngleX, BaseAngleY, BaseAngleZ)

					local RoundByThreeX = RoundByThree(math.floor(placepos.x + HitboxSizeX*xdispco) + xdisp - math.ceil(TycoonTopLeft.x))
					local RoundByThreeZ = RoundByThree(math.floor(placepos.z + HitboxSizeZ*zdispco) + zdisp - math.ceil(TycoonTopLeft.z))

				--	RoundByThreeX = RoundByThreeX + RoundByThree(HitboxSizeX/2)
			   	--	RoundByThreeZ = RoundByThreeZ + RoundByThree(HitboxSizeZ/2)


					local VectorComponent1 = CFrame.new(Vector3.new(TycoonTopLeft.x, TycoonBase.Position.y, TycoonTopLeft.z))
					local VectorComponent2 = CFrame.new(Vector3.new(RoundByThreeX, TycoonBase.Size.y/2, RoundByThreeZ)) --*VectorRotation
					local VectorComponent3 = CFrame.new(Vector3.new(-HitboxSizeX/2, Hitbox.Size.y/2, -HitboxSizeZ/2))
		--			local VectorComponent3 = CFrame.new(Vector3.new(-HitboxSizeX/2, Hitbox.Size.y/2, -HitboxSizeZ/2))

					NewVector = VectorComponent1*VectorComponent2*VectorComponent3


					local RegionVectorMin = NewVector * CFrame.new(Vector3.new(HitboxSizeX/2, -Hitbox.Size.y/2, HitboxSizeZ/2))
					local RegionVectorMax = NewVector * CFrame.new(-Vector3.new(HitboxSizeX/2, -Hitbox.Size.y/2, HitboxSizeZ/2))

					Hitboxes = game.Workspace:FindPartsInRegion3(
						Region3.new(
							Vector3.new(
								math.min(RegionVectorMin.x, RegionVectorMax.x),
								math.min(RegionVectorMin.y, RegionVectorMax.y),
								math.min(RegionVectorMin.z, RegionVectorMax.z)
							) + Vector3.new(0.1, 0, 0.1),
							Vector3.new(
								math.max(RegionVectorMin.x, RegionVectorMax.x),
								math.max(RegionVectorMin.y, RegionVectorMax.y),
								math.max(RegionVectorMin.z, RegionVectorMax.z)
							) - Vector3.new(0.1, 0, 0.1)
						), game.Workspace.Map, 100
					)
					return true
				end

				Tycoon.Base.Grid.Transparency = 0.5

				]]

				--[[
				-- BIG DADDY RIGHT HERE
				while module.placing do





					if Visual ~= module.visual then
						break
					end

					if TycoonBase ~= nil then
						local UIS = game:GetService("UserInputService")
						if Modules.Input.mode.Value == "Xbox" or Modules.Input.mode.Value == "Mobile" then
							local LookVector = workspace.CurrentCamera.CoordinateFrame.lookVector
							local xCo = 1
							local zCo = 1
							if LookVector.x > 0 then
								xCo = 2
							end
							if LookVector.z > 0 then
								zCo = 2
							end
							NewVector = Vector3.new(LookVector.x * xCo, LookVector.y, LookVector.z * zCo)
							local Pos = Player.Character.HumanoidRootPart.Position + (NewVector * 20)
							CheckPos(0,0,Pos)
							VerifyPos()
						elseif Mouse ~= nil and Mouse.Target ~= nil and Mouse.Target.Name == Tycoon.Name and Mouse.Target:FindFirstChild("Base") then

							CheckPos(0,0,Mouse.Hit.p)
							VerifyPos()
						end
					else
						break
					end
					game:GetService("RunService").RenderStepped:wait()

				end
				]]
				-- DONE PLACING



			end
		end

		return false

	end





	script.Parent.Placing.Left.Click.MouseButton1Click:connect(function()
		Shift(script.Parent.Placing.Left)
	end)
	script.Parent.Placing.Right.Click.MouseButton1Click:connect(function()
		Shift(script.Parent.Placing.Right)
	end)

--[[

	local function ShiftLeft()
		if script.Parent.Placing.Left.Visible then
			local Button = script.Parent.Placing.Left.Button.Value
			if Button then

				spawn(function()
					module.startPlacing(Button.ItemId.Value, Button)
				end)
			else
				script.Parent.Placing.Left.Visible = false
			end
		end
	end

	script.Parent.Placing.Left.Click.MouseButton1Click:connect(ShiftLeft)

	local function ShiftRight()
		if script.Parent.Placing.Right.Visible then
			local Button = script.Parent.Placing.Right.Button.Value
			if Button and Button.ItemId.Value > 0 then
				spawn(function()
					module.startPlacing(Button.ItemId.Value, Button)
				end)
			else
				script.Parent.Placing.Right.Visible = false
			end
		end
	end

	script.Parent.Placing.Right.Click.MouseButton1Click:connect(ShiftRight)
]]
	local Selection = script.SelectionBox
	Selection.Parent = script.Parent

	local Editing = Player:FindFirstChild("Editing")

	local function ClearFocus()

		local LastItem = LastModel
		if LastItem and LastItem:FindFirstChild("Hitbox") then
			LastItem.Hitbox.Transparency = 1
			if LastItem:FindFirstChild("Mesh") then
				LastItem.Mesh.Scale = Vector3.new(1,1,1)
			end
		end
		if LastHighlight then
			LastHighlight:Destroy()
		end

		Highlight.Parent = game.ReplicatedStorage
		SelectionHigh.Adornee = nil
		SelectionHigh.Visible = false


		if not MouseDown then
			Preview.hide()
		end
		if not module.placing then
			if Mouse and Mouse.TargetFilter then
				Mouse.TargetFilter = nil
			end
		end

		local LastItem = LastModel
		if LastItem then
			Modules.ArrowHandler.removeConveyor(LastItem)
			--[[
			if LastItem:FindFirstChild("Model") then
				for i,Part in pairs(LastItem.Model:GetChildren()) do
					if Part:FindFirstChild("ConveyorArrow") then
						Part.ConveyorArrow:Destroy()
					end
				end
			end
			]]--
		end
		LastModel = nil

	end

	function module.raise()
		placement:raise()
	end

	function module.lower()
		placement:lower()
	end

	script.Parent.Placing.Hydrolics.MobileControl.Raise.MouseButton1Click:Connect(module.raise)
	script.Parent.Placing.Hydrolics.MobileControl.Lower.MouseButton1Click:Connect(module.lower)

	function module.rotate(String, Type)

		if Type and Type ~= Enum.UserInputState.Begin then
			return false
		end

		placement:rotate()
		--[[
		if Debounce then
			Debounce = false
			if Rotation >= 360 then
				Rotation = 0
			end
			Rotation = Rotation + 90
			wait(0.2)
			Debounce = true
		end
		]]
	end


	-- manual placement override
	function module.override(bool)
		placement:override(bool)
	end

	-- Pick up selected item(s)
	function module.withdraw(skipsound)

		local Tycoon = game.Players.LocalPlayer.ActiveTycoon.Value
		if Tycoon == nil then
			return false
		end


		local Model
		if #Selected == 1 then
			Model = Selected[1]
			-- Instantly hide the item away and await results
			Model.Parent = game.Lighting
		end

		spawn(function()
			skipsound = skipsound or false
			local Success = false
			if #Selected == 1 then
				Success = game.ReplicatedStorage.DestroyItem:InvokeServer(Selected[1])
			elseif #Selected > 1 then
				Success = game.ReplicatedStorage.DestroySelected:InvokeServer(Selected)
			end
			if Success then
				if Model and Model.Parent then
					Model:Destroy()
				end
				Preview.collapse()
				ClearFocus()


				if not skipsound then
					Sounds.Withdraw:Play()
				end
				Selected = {}
				Preview.collapse()
			else
				if Model and Model.Parent == game.Lighting then
					Model.Parent = Tycoon
				end
				if not skipsound then
					Sounds.Error:Play()
				end
			end
		end)

		return true

	end

	-- Move selected item(s)
	function module.quickplace()
		if #Selected == 1 then -- move one
			local Item = Selected[1]
			if Item and Item:FindFirstChild("ItemId") then
				local Id = Item.ItemId.Value
				if module.withdraw(true) then
					Preview.collapse()
					ClearFocus()

					spawn(function()
						module.startPlacing(Item:Clone())
					end)
				end
			end

		elseif #Selected > 1 then -- move multiple
			local Model = Instance.new("Model")
			Model.Name = "GroupedItems"
			for i,Item in pairs(Selected) do
				Item:Clone().Parent = Model
			end
			if module.withdraw(true) then
				Preview.collapse()
				ClearFocus()

				spawn(function()
					module.startPlacing(Model)
				end)
			end
		end
	end

	function module.quicksell()
		if Debounce then
			Debounce = false

			local Success = false
			if #Selected == 1 then
				local Item = Selected[1]
				if Item:FindFirstChild("Crystals") and Item.ItemType.Value == 7 then
					local Prompt = "Are you sure you want to sell this crystal item for " .. Modules.MoneyLib.HandleMoney(Item.Cost.Value*0.35) .. "?"
					if not Modules.InputPrompt.prompt(Prompt) then
						Debounce = true
						return false
					end
				end
				Success = game.ReplicatedStorage.SellItem:InvokeServer(Selected[1])
				if Success then
					Sounds.Money:Play()
					Preview.collapse()
					ClearFocus()
				else
					Sounds.Error:Play()
				end
			end
			Debounce = true
			return Success
		end

	end

	function module.quickbuy()
		local Success = false
		if #Selected == 1 and Selected[1] then
			Success = game.ReplicatedStorage.BuyItem:InvokeServer(Selected[1].Name)
			if Success then
				Sounds.Purchase:Play()
			else
				Sounds.Error:Play()
			end
		end
		return Success
	end

	function module.undo()
		if Debounce then
			Debounce = false
			LastPosition = nil
			local LastItem
			local Index = #PlacedHistory
			local Id = 0
			repeat
				LastItem = PlacedHistory[Index]
				Index = Index - 1
			until (LastItem ~= nil or Index <= 0)
			local Success = false
			if LastItem then
				Id = LastItem.ItemId.Value
				if LastItem:FindFirstChild("SelectionBox") then
					LastItem.SelectionBox.Visible = true
					LastItem.SelectionBox.Color3 = Color3.fromRGB(255,100,0)
					LastItem.SelectionBox.Transparency = 0
				end
				Success = game.ReplicatedStorage.DestroyItem:InvokeServer(LastItem)
			end
			if Success then
				Sounds.Withdraw:Play()
				if #Objects == 1 and Objects[1]:FindFirstChild("ItemId") and Objects[1].ItemId.Value == Id then
					script.Parent.Placing.Count.Value = script.Parent.Placing.Count.Value + 1
				end
				table.remove(PlacedHistory,Index+1)
			else
				Sounds.Error:Play()
			end
			wait(0.1)
			Debounce = true
		end
	end

	local gear = false
	function gearscan()
		local Char = game.Players.LocalPlayer.Character
		if Char then
			for i,Child in pairs(Char:GetChildren()) do
				if Child:IsA("Tool") then
					return true
				end
			end
		end
		return false
	end

	local function gearcheck()
		gear = gearscan()
	end

	local Char = game.Players.LocalPlayer.Character
	if Char then
		Char.ChildAdded:connect(gearcheck)
		Char.ChildRemoved:connect(gearcheck)
	end

	local function countCheck()
		if script.Parent.Placing.Count.Value > 0 then
			if not Modules.Tutorial.isRunning() then
				placement:override(false)
			end
			if placement:isGood() then
				for i,Object in pairs(Objects) do
					if Object:FindFirstChild("SelectionBox") then
						Object.SelectionBox.Color3 = BrickColor.new("Bright blue").Color
					end
					scan(Object, "BrickColor", BrickColor.new("Bright blue"))
				end
			end
		else
			placement:override(true)
			for i,Object in pairs(Objects) do
				if Object:FindFirstChild("SelectionBox") then
					Object.SelectionBox.Color3 = BrickColor.Red().Color
				end
				scan(Object, "BrickColor", BrickColor.Red())
			end
		end
	end

	script.Parent.Placing.Count.Changed:connect(countCheck)


--[[
░▀░ █▀▀▄ █▀▀█ █░��█ ▀▀█▀▀
▀█▀ █░░█ █░░█ █░░█ ░░█░░
▀▀▀ ▀░░▀ █▀▀▀ ░▀▀▀ ░░▀░░
--]]



	-- Mobile Buttons

	local Btns = script.Parent.Placing.MobileControls

	Btns.Cancel.MouseButton1Click:connect(function()
		module.stopPlacing()
	end)
	Btns.Rotate.MouseButton1Click:connect(function()
		module.rotate()
	end)

	Btns.Place.MouseButton1Down:connect(function()
		if script.Parent.Placing.Count.Value <= 0 and module.placing then
			module.stopPlacing()
		end
		MouseDown = true
		placement:anchor()
		if module.placing and not placement:isGood() then
			Sounds.Error:Play()
		end
		--workspace.CurrentCamera.CameraType = Enum.CameraType.Track
	end)
	Btns.Place.MouseButton1Up:connect(function()
		MouseDown = false
		placement:release()
		--workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	end)
	--Btns.Place.MouseButton1Click:connect(function()
	--	module.place()
	--end)
	Btns.Undo.MouseButton1Click:connect(function()
		module.undo()
	end)

	script.Parent.FocusWindow.Changed:connect(function()
		if script.Parent.FocusWindow.Value ~= nil then
			MouseDown = false
			placement:release()
		end
	end)

	-- Else

	local ButtonMouseover

	Mouse.Button1Down:connect(function()
		PlaceStartPoint = nil
		if Mode.Value ~= "Mobile" then
			MouseDown = true
			placement:anchor()
			if module.placing and not placement:isGood() then
				Sounds.Error:Play()
			end

			if script.Parent.Placing.Count.Value <= 0 and (#Objects == 1 and Objects[1]:FindFirstChild("ItemId")) and module.placing then
				module.stopPlacing()
			end
			Preview.collapse()
			for i,Item in pairs(Selected) do
				if Item:FindFirstChild("SelectionBox") then
					Item.SelectionBox.Visible = false
				end
			end
			Selected = {}
			ButtonMouseover = nil
			if Selection and Selection.Adornee and Selection.Adornee:FindFirstChild("ClickDetector") then
				ButtonMouseover = Selection.Adornee
			end
		end
	end)

	Mouse.Button1Up:connect(function()
		PlaceStartPoint = nil
		if MouseDown then
			MouseDown = false -- if something broke this is it
			placement:release()
			if Mode.Value ~= "Mobile" then
				local Count = #Selected

				if ButtonMouseover and Selection and Selection.Adornee and Selection.Adornee:FindFirstChild("ClickDetector") then
					if Count > 0 then
						for i,Item in pairs(Selected) do
							if Item:FindFirstChild("SelectionBox") then
								Item.SelectionBox.Visible = false
							end
						end
					end
					Sounds.Tick:Play()
					Preview.collapse()
					local Part = ButtonMouseover
					if Part:IsDescendantOf(workspace.Market) and workspace.Market.Active.Value then
						script.Parent.EventShop.Visible = true
						Modules.Focus.change(script.Parent.EventShop)
					elseif Part.Parent.Name == "WizardDude" then
						Modules.Focus.change(script.Parent.Craftsman)
					elseif workspace:FindFirstChild("Innovator") and Part:IsDescendantOf(workspace.Innovator) then
						--script.Parent.EventMenu.Visible = true
						--Modules.Focus.change(script.Parent.EventMenu)
					elseif Part.Name:lower() == "adprem" and Player:FindFirstChild("Premium") == nil then
						Modules.Menu.sounds.SwooshFast:Play()
						Modules.Focus.change(script.Parent.PremiumAd)
					--	game.MarketplaceService:PromptPurchase(Player,268427885)
					end
					game.ReplicatedStorage.Click:FireServer(Part)
				elseif Count == 1 then
					if script.Parent.ItemPreview.Frame.Object.Value == Selected[1] then
						Preview.collapse()
					else
						Preview.expand(Selected[1])
					end

				elseif Count > 0 then
					Preview.expand(Selected)
				end
			end
		end
	end)







	local function repos()
		if Modules.Input.mode.Value == "PC" and script.Parent.ItemPreview.Frame.LockedToMouse.Value then
			script.Parent.ItemPreview.AnchorPoint = Vector2.new(0,0.5)
			local EndPos = UDim2.new(0, Mouse.X + 20, 0, Mouse.Y + 5)
			script.Parent.ItemPreview.Position = EndPos
		else
			local Pos, Visible = workspace.CurrentCamera:WorldToScreenPoint(script.Parent.ItemPreview.Frame.PhysicalPos.Value)
			local x, y = Pos.X, Pos.Y

			if HUD.MenuOpen then
				if x - (script.Parent.ItemPreview.AbsoluteSize.X / 2) < script.Parent.Menu.AbsoluteSize.X + 7 then
					x = (script.Parent.ItemPreview.AbsoluteSize.X / 2) + script.Parent.Menu.AbsoluteSize.X + 7
				end
			end

			script.Parent.ItemPreview.AnchorPoint = Vector2.new(0.5,0.5)
			local EndPos = UDim2.new(0,x,0,y)
			script.Parent.ItemPreview.Position = EndPos


		end
	end


	local function FocusItem(Model)

		if gear then
			return false
		end

		if script.Parent.FocusWindow.Value and script.Parent.FocusWindow.Value.Visible and script.Parent.FocusWindow.Value ~= script.Parent.Menu then
			return false
		end

		if Model:FindFirstChild("Ignore") and Model.Ignore.Value then
			return false
		end

		if MouseDown and Model:FindFirstChild("SelectionBox") and not Model.SelectionBox.Visible then
			Model.SelectionBox.Visible = true
			table.insert(Selected, Model)
			if #Selected>1 then
				Sounds.TickSoft:Play()
				Preview.show(Selected)
			end
		end

		if LastModel ~= Model then

			repos()

			local LastItem = LastModel
			if LastItem and LastItem:FindFirstChild("Hitbox") then
				LastItem.Hitbox.Transparency = 1
				--if LastItem:FindFirstChild("SelectionBox") then
				--	LastItem.SelectionBox.Visible = false
				--end

				Modules.ArrowHandler.removeConveyor(LastItem)
				--[[
				if LastItem:FindFirstChild("Model") then
					for i,Part in pairs(LastItem.Model:GetChildren()) do
						if Part:FindFirstChild("ConveyorArrow") then
							Part.ConveyorArrow:Destroy()
						end
					end
				end
				]]--
			end

			--if Model:FindFirstChild("SelectionBox") then
			--	Model.SelectionBox.Visible = true
			--	Model.SelectionBox.Transparency = 0.7
			--end

			Modules.ArrowHandler.addConveyor(Model)
			--[[
			if Model:FindFirstChild("Model") then
				for i,Part in pairs(Model.Model:GetChildren()) do
					local Multi = 100
					if Part.Name == "Conv" or Part.Name == "Conveyor" then
						local Decal = script.ConveyorArrow:Clone()
						Decal.Parent = Part
						Decal.Frame.Icon.ImageTransparency = 0.5
						if Part.Size.Z < 4.5 or Part.Size.X < 4.5 then
							Multi = 200
						end
						Decal.CanvasSize = Vector2.new(Part.Size.Z * Multi, Part.Size.X * Multi)
						Decal.Adornee = Part
					end
				end
			end
			]]--

			local Hitbox = Model:FindFirstChild("Hitbox")
			if Hitbox then
				if LastHighlight then
					LastHighlight:Destroy()
				end
				LastHighlight = Highlight:Clone()
				LastHighlight.Size = Vector3.new(Hitbox.Size.X,1,Hitbox.Size.Z)

				local Mush = Hitbox:FindFirstChild("Mesh")
				if Mush == nil then
					Mush = Mesh:Clone()
					Mush.Parent = Hitbox
				end
				Mush.Scale = Vector3.new(1,100,1)

				LastHighlight.Light.Enabled = false
				--LastHighlight.Light.Range = (Hitbox.Size.X + Hitbox.Size.Z) * 0.6

				LastHighlight.Parent = workspace.CurrentCamera

				SelectionHigh.Adornee = Model.Hitbox
				SelectionHigh.Visible = true

				if Model:FindFirstChild("Tier") then
					local Tier = game.ReplicatedStorage.Tiers:FindFirstChild(tostring(Model.Tier.Value))
					if Tier then
						LastHighlight.Color = Tier.TierColor.Value
						LastHighlight.Light.Color = Tier.TierColor.Value
						Hitbox.Color = Tier.TierColor.Value
						SelectionHigh.Color3 = Tier.TierColor.Value

					end
				end
				Hitbox.Transparency = 0.9
				LastHighlight.Transparency = 0.5

				LastHighlight.CFrame = Hitbox.CFrame - Vector3.new(0,Hitbox.Size.Y/2,0)


			end
			LastModel = Model

		end
		if not MouseDown then
			Preview.show(Model)
		end
	end




	script.Parent.ItemPreview.Frame.PhysicalPos.Changed:connect(repos)


	local processed = false
	game:GetService("UserInputService").InputChanged:connect(function(Input, Processed)
		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			processed = Processed
		end
	end)

	local function updateItemInfo()
		if script.Parent.ItemInfo.RealButton.Value then
			local Button = script.Parent.ItemInfo.RealButton.Value
			local NPos = UDim2.new(0,Button.AbsolutePosition.X + Button.AbsoluteSize.X/2,0,Button.AbsolutePosition.Y + Button.AbsoluteSize.Y/2)
			script.Parent.ItemInfo.Position = NPos
			local prevsize = Button.AbsoluteSize.X * 1 - 10
			if Button.AbsoluteSize.Y > Button.AbsoluteSize.X then
				prevsize = Button.AbsoluteSize.Y * 1 - 10
			end

			script.Parent.ItemInfo.Size = UDim2.new(0,prevsize,0,prevsize)

			local x = 1
			local y = 0
			local yd = -15
			if script.Parent.ItemInfo.AbsolutePosition.Y + script.Parent.ItemInfo.Item.AbsoluteSize.Y >= (workspace.CurrentCamera.ViewportSize.Y - 36) then
				y = -1.5
				yd = 10
			end
			if script.Parent.ItemInfo.AbsolutePosition.X + script.Parent.ItemInfo.AbsoluteSize.X + script.Parent.ItemInfo.Item.AbsoluteSize.X >= workspace.CurrentCamera.ViewportSize.X then
				x = -2.2
			end
			script.Parent.ItemInfo.Item.Position = UDim2.new(x,0,y,yd)
			--script.Parent.ItemInfo.Shadow.Position = UDim2.new(x,0,y,yd+6)
		end
	end
	script.Parent.ItemInfo.RealButton.Changed:Connect(updateItemInfo)


	local function frame()

		-- bind pretty much everything here lmao


		if script.Parent.NewPlayer.Visible then
			return false
		end

		updateItemInfo()

		-- maybe move this to the item info script in the future


		--[[
		if module.placing then
			if MouseDown then
				module.place()
			elseif LastHighlight then
				LastHighlight:Destroy()
			end
		end
		]]


		if script.Parent.ItemPreview.Visible then
			repos()
		end

		if HUD.MenuOpen and Selection then
			ClearFocus()
		end
		if (Mode.Value == "PC" or not HUD.MenuOpen) and not module.placing then -- if anything broke its this
			local ScreenPos



			if Mode.Value == "PC" and Mouse then
				ScreenPos = Vector2.new(Mouse.X, Mouse.Y + 36)
				if HUD.MenuOpen then
					if Mouse.X < script.Parent.Menu.AbsolutePosition.X + script.Parent.Menu.AbsoluteSize.X then
						return false
					end
				end

			else
				local CamView = workspace.CurrentCamera.ViewportSize
				ScreenPos = Vector2.new(math.floor(CamView.X/2),math.floor(CamView.Y/3))
			end

			if Mode.Value ~= "Mobile" then

				local lrey = workspace.CurrentCamera:ViewportPointToRay(ScreenPos.X,ScreenPos.Y)
				local rey = Ray.new(lrey.Origin, lrey.Direction * 1000)
				local Part
				if Player.ActiveTycoon.Value then
					Part = workspace:FindPartOnRayWithWhitelist(rey,Selectables)
					if Part == nil or (Part.Name ~= "Hitbox" and Part:FindFirstChild("ClickDetector") == nil and Part.Name ~= "Cover") then
						-- second opinion
						Part = workspace:FindPartOnRayWithIgnoreList(rey,{workspace.DroppedParts,game.Players.LocalPlayer.Character})
					end
				else
					Part = workspace:FindPartOnRay(rey,Player.Character)
				end

				--local Part = workspace:FindPartOnRay(rey,Player.Character)
				if Part and not processed then
					if Part:FindFirstChild("ClickDetector") then
						local p = Player.Character.HumanoidRootPart.Position
						local dif = Part.Position - p
						if dif.magnitude <= Part.ClickDetector.MaxActivationDistance then
							local newR = Ray.new(p, dif)
							local col = workspace:FindPartOnRay(newR, Player.Character)
							if col == nil or col == Part then
								Selection.Adornee = Part
							else
								ClearFocus()
							end
						else
							ClearFocus()
						end
						ClearFocus()
					elseif Part.Name == "Cover" then
						ClearFocus()
					elseif Player.ActiveTycoon.Value and TycoonLib.hasPermission(Player, "Build") then
						Selection.Adornee = nil
						if Part then
							if (Part.Name == "Hitbox") then
								local Model = (Part.Name == "Hitbox" and Part.Parent)
								local Tycoon = getTycoon(game.Players.LocalPlayer)
								if Model and Model:IsDescendantOf(Tycoon) and Model ~= Objects[1] then
									if Model.Name == "Representation" then
										Model:Destroy()
										return false
									end
									FocusItem(Model)
								else
									ClearFocus()
								end
					--		elseif LastModel and not Part:IsDescendantOf(LastModel) then
							else
								ClearFocus()
							end
						else
							ClearFocus()
						end
					else
						Selection.Adornee = nil
						ClearFocus()
					end
				else
					Selection.Adornee = nil
					ClearFocus()
				end
			end
		end

	end
	--name, priority function

	game:GetService("RunService"):BindToRenderStep("LocalFrame",Enum.RenderPriority.Camera.Value - 1,frame)
	--game:GetService("RunService").RenderStepped:connect(frame)

	-- Mobile stuffs

	function module.selectFromPoint(Point)

		if gear then
			return false
		end

		if script.Parent.FocusWindow.Value ~= nil then
			return false
		end

		if module.placing then
			return false
		end

		local Tycoon = game.Players.LocalPlayer.ActiveTycoon.Value

		local Rey = workspace.CurrentCamera:ScreenPointToRay(Point.X,Point.Y)
		local RealRey = Ray.new(Rey.Origin, Rey.Direction * 1000)

		local Part

		if Tycoon then
			Part = workspace:FindPartOnRayWithWhitelist(RealRey,{Tycoon})
			if Part == nil or (Part.Name ~= "Hitbox" and Part:FindFirstChild("ClickDetector") == nil) then
				-- Second opinion
				Part = workspace:FindPartOnRayWithIgnoreList(RealRey,{workspace.DroppedParts,game.Players.LocalPlayer.Character})
			end
			if Part and Part:IsDescendantOf(Tycoon) and Part:FindFirstChild("ClickDetector") == nil then
				local Object = nil

				for i,Item in pairs(Tycoon:GetChildren()) do
					if Item:FindFirstChild("SelectionBox") then
						Item.SelectionBox.Visible = false
					end
				end

				if Part.Name == "Base" then
					Object = nil
				elseif Part.Name == "Hitbox" then
					Object = Part.Parent
				elseif Part.Parent.Parent:FindFirstChild("Hitbox") then
					Object = Part.Parent.Parent
				elseif Part.Parent.Parent.Parent:FindFirstChild("Hitbox") then
					Object = Part.Parent.Parent.Parent
				end

				if Object then
					if Object == script.Parent.ItemPreview.Expand.Object.Value then
						Selected = {Object}
						Object.SelectionBox.Visible = true
						Preview.expand(Object)
					else
						Preview.collapse()
						Selected = {Object}
						FocusItem(Object)
					end

			--		Selected = {Object}
			--		Preview.show(Object)
			--		Preview.expand(Object)
				else
					Preview.collapse()
					Preview.hide()
					Selected = {}
					ClearFocus()
				end
			elseif Part and Part:FindFirstChild("ClickDetector") then
				Preview.collapse()
				Preview.hide()
				Selected = {}
				ClearFocus()
				Selection.Adornee = Part
				Selection.Color3 = Color3.new(0,1,0.1)
				Sounds.Tick:Play()
				if Part:IsDescendantOf(workspace.Market) and workspace.Market.Active.Value then
					script.Parent.EventShop.Visible = true
					Modules.Focus.change(script.Parent.EventShop)
				elseif workspace:FindFirstChild("Innovator") and Part:IsDescendantOf(workspace.Innovator) then
					--script.Parent.EventMenu.Visible = true
					--Modules.Focus.change(script.Parent.EventMenu)
				elseif Part.Parent.Name == "WizardDude" then
					Modules.Focus.change(script.Parent.Craftsman)
				elseif Part.Name:lower() == "adprem" and Player:FindFirstChild("Premium") == nil then
					Modules.Menu.sounds.SwooshFast:Play()
					Modules.Focus.change(script.Parent.PremiumAd)
					--game.MarketplaceService:PromptPurchase(Player,268427885)
				end
				game.ReplicatedStorage.Click:FireServer(Part)
				spawn(function()
					wait(0.4)
					if Part and Selection.Adornee == Part then
						Selection.Adornee = nil
					end
				end)
			else
				Preview.collapse()
				Preview.hide()
				Selected = {}
			end
		else
			Preview.collapse()
			Preview.hide()
			Selected = {}
			ClearFocus()
			Part = workspace:FindPartOnRayWithIgnoreList(RealRey,{workspace.DroppedParts,game.Players.LocalPlayer.Character})
			if Part and Part:FindFirstChild("ClickDetector") then
				Sounds.Tick:Play()
				if Part:IsDescendantOf(workspace.Market) and workspace.Market.Active.Value then
					script.Parent.EventShop.Visible = true
					Modules.Focus.change(script.Parent.EventShop)
				elseif Part.Parent.Name == "WizardDude" then
					Modules.Focus.change(script.Parent.Craftsman)
				elseif workspace:FindFirstChild("Innovator") and Part:IsDescendantOf(workspace.Innovator) then
					--script.Parent.EventMenu.Visible = true
					--Modules.Focus.change(script.Parent.EventMenu)
				elseif Part.Name:lower() == "adprem" and Player:FindFirstChild("Premium") == nil then
					Modules.Menu.sounds.SwooshFast:Play()
					Modules.Focus.change(script.Parent.PremiumAd)
					--game.MarketplaceService:PromptPurchase(Player,268427885)
				end
				game.ReplicatedStorage.Click:FireServer(Part)
			end
		end


	end

end

print("finished")

return module