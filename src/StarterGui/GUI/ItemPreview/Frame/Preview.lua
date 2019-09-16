local module = {}

local MoneyLib

script.Parent.Expanded.Value = false

local LastTable

local Goal

local Sounds

function module.pos(Item)
	if type(Item) == "table" then
		local Sum = Vector3.new(0,0,0)
		local Count = 0
		for i,It in pairs(Item) do
			Sum = Sum + It.Hitbox.Position
		end

		local EndPos = Sum/#Item
		if Goal ~= EndPos then
			EndPos = Goal
			local PropertyGoals = {Value = Sum/#Item}
			local TweenProps = TweenInfo.new(0.2,Enum.EasingStyle.Linear,Enum.EasingDirection.In)
			game.TweenService:Create(script.Parent.PhysicalPos,TweenProps,PropertyGoals):Play()
		end
	else
		script.Parent.PhysicalPos.Value = Item.Hitbox.Position
	end

end

function module.info(Item)
	local ItemName = Item.Name
	if Item:FindFirstChild("ItemName") then
		ItemName = Item.ItemName.Value
	end
	script.Parent.ItemName.Text = ItemName
	local Tier = game.ReplicatedStorage.Tiers:FindFirstChild(tostring(Item.Tier.Value))
	if Tier then
		script.Parent.Tier.Text = Tier.TierName.Value
		script.Parent.Tier.BackgroundColor3 = Tier.TierColor.Value
		local col = Tier.TierBackground.Value
		script.Parent.BackgroundColor3 = Color3.new((col.r / 2) + 0.3, (col.g / 2) + 0.3, (col.b / 2) + 0.3)

		if Item.Tier.Value == 40 or Item.Tier.Value == 41 then
			script.Parent.Tier.TextColor3 = Tier.TierBackground.Value
			script.Parent.Tier.TextStrokeColor3 = Tier.TierBackground.Value
			script.Parent.Tier.Special.ImageColor3 = Tier.TierBackground.Value
			script.Parent.Tier.Special.Visible = true
			script.Parent.Tier.TextStrokeTransparency = 0.5
		else
			script.Parent.Tier.TextStrokeTransparency = 1
			script.Parent.Tier.TextColor3 = Color3.new(0,0,0)
			script.Parent.Tier.Special.Visible = false
		end
	end
end




function module.show(Item)

	if Item and not script.Parent.Expanded.Value then
		module.pos(Item)
		if type(Item) == "table" then
			script.Parent.LockedToMouse.Value = false
			script.Parent.ItemName.Text = "Multiple items selected"
			script.Parent.Tier.BackgroundColor3 = Color3.new(0.9,0.9,0.9)
			script.Parent.Tier.Text = #Item.." items"
			script.Parent.Tier.TextStrokeTransparency = 1
			script.Parent.Tier.TextColor3 = Color3.new(0,0,0)
			script.Parent.Tier.Special.Visible = false
			script.Parent.Parent.Expand.Object.Value = nil
		else
			script.Parent.LockedToMouse.Value = true
			script.Parent.Parent.Expand.Object.Value = Item
			module.info(Item)
		end
		script.Parent.Parent.Visible = true
		script.Parent.Size = UDim2.new(1,0,0,script.Parent.ItemName.TextBounds.Y + 18)
		--script.Parent:TweenSize(UDim2.new(1,0,0,script.Parent.ItemName.TextBounds.Y + 18),nil,nil,0)

	end
end


function module.expand(Item)

	if Item then
		script.Parent.LockedToMouse.Value = false
		local PreExistingConditions = script.Parent.Expanded.Value
		script.Parent.Expanded.Value = true

		local EndSize
		module.pos(Item)

		script.Parent.Parent.Expand.Object.Value = nil

		Sounds.Slide:Play()

		if type(Item) == "table" then
			script.Parent.Multi.Value = true
			script.Parent.Object.Value = nil
			script.Parent.Tier.BackgroundColor3 = Color3.new(0.9,0.9,0.9)
			EndSize = UDim2.new(1,0,0,116)
			script.Parent.ItemName.Text = "Multiple items selected"
			script.Parent.Move.Label.Text = "Move Items"
			script.Parent.Tier.Text = #Item.." items"
			script.Parent.Tier.TextStrokeTransparency = 1
			script.Parent.Tier.TextColor3 = Color3.new(0,0,0)
			script.Parent.Tier.Special.Visible = false
		else
			EndSize = UDim2.new(1,0,0,178)
			script.Parent.Move.Label.Text = "Move Item"
			script.Parent.Object.Value = Item
			script.Parent.Multi.Value = false

			module.info(Item)

			local Tier = game.ReplicatedStorage.Tiers:FindFirstChild(tostring(Item.Tier.Value))


			if Item.ItemType.Value ~= 99 and Item.ItemType.Value ~= 6 and Item.ItemType.Value ~= 10 then
				if Item.ItemType.Value == 7 and Item:FindFirstChild("Crystals") then
					script.Parent.Buy.BackgroundColor3 = Color3.fromRGB(255, 85, 201)
					script.Parent.Buy.Label.Text = "Buy - "..MoneyLib.DealWithPoints(Item.Crystals.Value).."uC"
				else
					script.Parent.Buy.BackgroundColor3 = Color3.new(149/255, 1, 188/255)
					script.Parent.Buy.Label.Text = "Buy - "..MoneyLib.HandleMoney(Item.Cost.Value)
				end

				if Item.ItemType.Value == 4 or Item.ItemType.Value == 11 then
					script.Parent.Sell.Label.Text = "Destroy"
				else
					script.Parent.Sell.Label.Text = "Sell - "..MoneyLib.HandleMoney(Item.Cost.Value*0.35)
				end
				script.Parent.Sell.BackgroundColor3 = Color3.new(1, 164/255, 166/255)


				--	math.floor(Object.Cost.Value * 0.3)
			else
				script.Parent.Buy.Label.Text = "Can't Buy"
				script.Parent.Sell.Label.Text = "Can't Sell"
				script.Parent.Sell.BackgroundColor3 = Color3.new(0.5,0.5,0.5)
				script.Parent.Buy.BackgroundColor3 = Color3.new(0.6,0.6,0.6)
			end

		end



		if PreExistingConditions then
			script.Parent.Size = EndSize
		else
			script.Parent:TweenSize(EndSize,nil,nil,0.5,true)
		end
		script.Parent.Parent.Visible = true


	end
end

script.Parent.Parent.Expand.Object.Changed:connect(function()
	if script.Parent.Parent.Expand.Object.Value then
		script.Parent.Parent.Expand.Button.Visible = true
	else
		script.Parent.Parent.Expand.Button.Visible = false
	end
end)

script.Parent.Parent.Expand.Button.MouseButton1Click:connect(function()
	local Obj = script.Parent.Parent.Expand.Object.Value
	if Obj and Obj.Parent == game.Players.LocalPlayer.ActiveTycoon.Value then
		module.expand(Obj)
	end
end)


function module.hide()
	if not script.Parent.Expanded.Value then
		--script.Parent:TweenSize(UDim2.new(1,0,0,0),nil,nil,0.15,true)
		spawn(function()
			--wait(0.18)
			if not script.Parent.Expanded.Value then
				script.Parent.Parent.Expand.Object.Value = nil
				script.Parent.Parent.Visible = false
				script.Parent.Object.Value = nil
			end
		end)
	end
end

function module.collapse()
	if script.Parent.Expanded.Value then
		script.Parent.Expanded.Value = false
		script.Parent.Object.Value = nil
	end
end

function module.init(Modules)
	MoneyLib = Modules["MoneyLib"]
	Sounds = Modules["Menu"]["sounds"]
	local Placement = Modules["Placement"]
	local Debounce = true


	local Mode = Modules["Input"]["mode"]

	local function resize()
		if Mode.Value == "Mobile" then
			script.Parent.Parent.Size = UDim2.new(0,130,0,200)
		else
			script.Parent.Parent.Size = UDim2.new(0,160,0,200)
		end
	end


	script.Parent.Expanded.Changed:connect(function()
		module.Expanded = script.Parent.Expanded.Value
		module.expanded = script.Parent.Expanded.Value
	end)

	Mode.Changed:connect(resize)
	resize()

	script.Parent.Withdraw.MouseButton1Click:connect(function()
		if Debounce then
			Debounce = false
			Sounds.Click:Play()
			Placement["withdraw"]()
			wait()
			Debounce = true
		end
	end)

	script.Parent.Move.MouseButton1Click:connect(function()
		if Debounce then
			Debounce = false
			Sounds.Click:Play()
			Placement["quickplace"]()
			wait()
			Debounce = true
		end
	end)

	script.Parent.Sell.MouseButton1Click:connect(function()
		if Debounce then
			Debounce = false
			Sounds.Click:Play()
			Placement["quicksell"]()
			wait()
			Debounce = true
		end
	end)

	script.Parent.Buy.MouseButton1Click:connect(function()
		if Debounce then
			Debounce = false
			Sounds.Click:Play()
			Placement["quickbuy"]()
			wait()
			Debounce = true
		end
	end)


end



return module
