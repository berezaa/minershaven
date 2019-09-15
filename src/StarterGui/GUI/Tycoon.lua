-- Tycoon Module

--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

local module = {}


function module.getTycoon(Player)
	Player = Player or game.Players.LocalPlayer
	return Player.ActiveTycoon.Value
end



module.money = script.Parent.Money
module.points = script.Parent.Points
module.crystals = script.Parent.Crystals

function module.init(Modules)

	local Sounds = Modules["Menu"]["sounds"]

	local connections = {}

	script.Parent.Radio.Visible = false
	local PulseDown = false

	local function scan(Tycoon)
		for i,Child in pairs(Tycoon:GetChildren()) do
			if Child:FindFirstChild("RemoteDrop") then
				return true
			end
		end
		return false
	end

	local function unhook()
		for i,connection in pairs(connections) do
			if connection.Connected then
				connection:Disconnect()
			end
			table.remove(connections,i)
		end
		script.Parent.Radio.Visible = false
		PulseDown = false

	end

	local function hook()
		unhook()
		local Tycoon = game.Players.LocalPlayer.ActiveTycoon.Value
		if Tycoon then

			if Tycoon:FindFirstChild("Ore Pulsar") or Tycoon:FindFirstChild("Ore Quasar") or Tycoon:FindFirstChild("Ore Nebula") or Tycoon:FindFirstChild("Ore Supernova") then
				PulseDown = true
				script.Parent.HUDLeft.Buttons.Pulse.Visible = true

			else
				PulseDown = false
				script.Parent.HUDLeft.Buttons.Pulse.Visible = false
			end
			if scan(Tycoon) then
				script.Parent.Radio.Visible = true

				script.Parent.Radio.Button.Hover.BackgroundTransparency = 1

			else
				script.Parent.Radio.Visible = false
			end

			local Owner = game.Players:FindFirstChild(Tycoon.Owner.Value)
			if Owner then
				local Money = game.ReplicatedStorage.MoneyMirror:FindFirstChild(Owner.Name)

				local Points = Owner.Points

				if Owner == game.Players.LocalPlayer then
					local Shards = Owner.Shards
					table.insert(connections,Shards.Changed:connect(function()
						script.Parent.Shards.Value = Shards.Value
					end))
					script.Parent.Shards.Value = Shards.Value
				else
					script.Parent.Shards.Value = 0
				end

				if Points then
					table.insert(connections,Points.Changed:connect(function()
						script.Parent.Points.Value = Points.Value
					end))
					script.Parent.Points.Value = Points.Value
				else
					script.Parent.Points.Value = 0
				end

				local Crystals = Owner.Crystals

				if Crystals then
					table.insert(connections,Crystals.Changed:connect(function()
						script.Parent.Crystals.Value = Crystals.Value
					end))
					script.Parent.Crystals.Value = Crystals.Value
				else
					script.Parent.Crystals.Value = 0
				end

				table.insert(connections,Money.Changed:connect(function()
					script.Parent.Money.Value = Money.Value
				end))
				script.Parent.Money.Value = Money.Value

				table.insert(connections,Owner.AverageIncome.Changed:connect(function()
					script.Parent.Change.Value = Owner.AverageIncome.Value
				end))
			end

			table.insert(connections,Tycoon.DescendantAdded:connect(function(Child)
				if Child.Name == "RemoteDrop" and Child.Parent:FindFirstChild("LocalItem") == nil and Child.Parent:FindFirstChild("Representation") == nil then
					if not script.Parent.Radio.Visible then
						script.Parent.Radio.Visible = true
						script.Parent.Radio.Button.Hover.Visible = true
						script.Parent.Radio.Button.Hover.BackgroundTransparency = 0
						script.Parent.Radio.Button.Hover.Size = UDim2.new(1,1,1)
						Modules.Menu.tween(script.Parent.Radio.Button.Hover,{"Size","BackgroundTransparency"},{UDim2.new(9,9,9),1},0.2)
						Sounds.TurnOn:Play()
					end
				elseif not PulseDown and Child.Name == "Ore Pulsar" or Child.Name == "Ore Quasar" or Child.Name == "Ore Nebula" or Child.Name == "Ore Supernova" then
					PulseDown = true
					script.Parent.HUDLeft.Buttons.Pulse.Visible = true
					Sounds.PulseOn:Play()
				end
			end))

			table.insert(connections,Tycoon.ChildRemoved:connect(function(Child)
				if not Child:FindFirstChild("LocalItem") and not Child:FindFirstChild("Representation") then

					if Child:FindFirstChild("RemoteDrop") and not scan(Tycoon) then
						script.Parent.Radio.Visible = false
						Sounds.TurnOff:Play()
					elseif PulseDown and not (Tycoon:FindFirstChild("Ore Pulsar") or Tycoon:FindFirstChild("Ore Quasar") or Tycoon:FindFirstChild("Ore Nebula") or Tycoon:FindFirstChild("Ore Supernova")) then
						PulseDown = false
						script.Parent.HUDLeft.Buttons.Pulse.Visible = false
						Sounds.PulseOff:Play()
					end
				end
			end))
		end
	end

	game.Players.LocalPlayer.ActiveTycoon.Changed:connect(hook)
	hook()

	local DB = true
	function module.remotedrop(String, Type)

		if Type == Enum.UserInputState.Cancel then
			return false
		end

		if DB and script.Parent.Radio.Visible then
			DB = false
			script.Parent.Radio.Button.BackgroundColor3 = Color3.new(1,0.3,0.30)
			Sounds.Tick:Play()
			game.ReplicatedStorage.RemoteDrop:FireServer()

			wait(0.15)
			script.Parent.Radio.Button.BackgroundColor3 = Color3.new(105/255, 1, 82/255)
			DB = true
		end
	end
	script.Parent.Radio.Button.MouseButton1Click:connect(module.remotedrop)

	function module.pulse(String, Type)

		if Type == Enum.UserInputState.Cancel then
			return false
		end

		if DB and script.Parent.HUDLeft.Buttons.Pulse.Visible then
			Sounds.Click:Play()
			game.ReplicatedStorage.Pulse:FireServer()
		end
	end

	script.Parent.HUDLeft.Buttons.Pulse.MouseButton1Click:connect(module.pulse)
end



return module
