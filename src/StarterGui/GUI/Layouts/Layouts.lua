-- Layouts
--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

local module = {}

function getItemFromId(Id)
	for i,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
		if v.ItemId.Value == Id then
			return v
		end
	end
	return nil
end

function module.init(Modules)
	local ItemsToBuy = {}

	module.missing = {}

	module.changed = script.Event.Event

	script.Parent.Top.Close.MouseButton1Click:connect(function()
		Modules.Menu.sounds.Click:Play()
		Modules.Focus.close()
	end)

	local Busy = false

	local function isTycoonEmpty(Tycoon)
		for i,Child in pairs(Tycoon:GetChildren()) do
			if Child:FindFirstChild("Hitbox") then
				return false
			end
		end
		return true
	end

	local function check()

		module.missing = {}

		local results = game.ReplicatedStorage.Layouts:InvokeServer("Check")

		if type(results) ~= "table" then
			return false
		end

		for layoutname,result in pairs(results) do
			local layout = script.Parent.Contents:FindFirstChild(layoutname)
			if layout then
				local empty = true
				--print(layoutname)
				if result == false then
					layout.Save.BackgroundColor3 = Color3.fromRGB(115, 255, 255)
					layout.Save.Text = "[SAVE]"
					layout.Status.Text = "This slot is empty."
					layout.Status.TextColor3 = Color3.new(0,0,0)
					layout.Load.BackgroundColor3 = Color3.fromRGB(147, 147, 147)
					layout.Load.Active = false
				elseif result == true then
					layout.Save.BackgroundColor3 = Color3.fromRGB(255, 125, 127)
					layout.Save.Text = "[CLEAR]"
					ItemsToBuy[layoutname] = nil
					empty = false
					layout.Status.Text = "Ready to go!"
					layout.Status.TextColor3 = Color3.new(0,1,0)
					layout.Load.BackgroundColor3 = Color3.fromRGB(114, 255, 112)
					layout.Load.Active = true
				elseif type(result) == "table" then
					layout.Save.BackgroundColor3 = Color3.fromRGB(255, 125, 127)
					layout.Save.Text = "[CLEAR]"

					empty = false
					local missingstring = ""
					--print(game.HttpService:JSONEncode(result))


					--L--
					local missingItems = {}
					-----

					local missingCostSum = 0

					for e,Item in pairs(result) do
						if missingstring ~= "" then
							missingstring = missingstring .. ", "
						end

						--L--
						--Check if purchasable
						local itemData = game.ReplicatedStorage.Items:FindFirstChild(Item.ItemName)
						if itemData and (itemData.ItemType.Value == 11 or (itemData.ItemType.Value >= 1 and itemData.ItemType.Value <= 4)) then
							missingItems[#missingItems+1] = {
								Name = Item.ItemName;
								Amount = Item.Amount;
								CostPerUnit = itemData.Cost.Value;
							}
							missingCostSum = missingCostSum + itemData.Cost.Value * Item.Amount
						end

						-----

						missingstring = missingstring .. Item.ItemName .. " (x "..Item.Amount..")"
						module.missing[Item.ItemName] = true
					end

					if #missingItems > 0 then
						ItemsToBuy[layoutname] = missingItems
					else
						ItemsToBuy[layoutname] = nil
					end

					if #result > 3 then
						missingstring = tostring(#result .. " items missing")
					end

					if missingItems and #missingItems > 0 then
						missingstring = missingstring .. " ("..Modules.MoneyLib.HandleMoney(missingCostSum).." to buy shop items)"
					end

					layout.Status.Text = "Missing: " .. missingstring .. " (Load Anyway?)"
					layout.Status.TextColor3 = Color3.fromRGB(255, 161, 106)
					layout.Load.BackgroundColor3 = Color3.fromRGB(255, 186, 46)
					layout.Load.Active = true
				else
					layout.Status.Text = "An error occured"
					layout.Status.TextColor3 = Color3.new(1,0,0)
					layout.Load.BackgroundColor3 = Color3.fromRGB(147, 147, 147)
					layout.Load.Active = false
				end
				if not empty then
					for i,Child in pairs(layout.BG:GetChildren()) do
						if Child:IsA("GuiObject") and Child.Name ~= "Sample" then
							Child:Destroy()
						end
					end
					local RawLayout = game.Players.LocalPlayer.Layouts:FindFirstChild(layoutname)
					if RawLayout then
						local Raw = game.HttpService:JSONDecode(RawLayout.Value)
						if Raw then
							for i,Item in pairs(Raw) do
								local Real = getItemFromId(Item.ItemId)
								if Real and layout.BG:FindFirstChild(Real.Name) == nil then
									local Template = layout.BG.Sample:Clone()
									Template.Name = Real.Name
									Template.Image = "rbxassetid://"..Real.ThumbnailId.Value
									Template.Visible = true
									Template.Parent = layout.BG
								end
							end
						end
					end
				end
			else
				print("404 not found: " .. layoutname)
			end
		end

		script.Event:Fire()
	end

	for i,layout in pairs(script.Parent.Contents:GetChildren()) do
		if layout:IsA("GuiObject") and layout:FindFirstChild("Save") then


			layout.Save.MouseButton1Click:connect(function()
				if Busy then
					return false
				end
				local rawLayout = game.Players.LocalPlayer.Layouts:FindFirstChild(layout.Name)
				if rawLayout == nil then
					return false
				end
				local Tycoon = game.Players.LocalPlayer.ActiveTycoon.Value
				if Tycoon == nil or Tycoon ~= game.Players.LocalPlayer.PlayerTycoon.Value then
					Modules.Menu.sounds.Error:Play()
					return false
				end

				Busy = true

				if (rawLayout.Value == "[]" or rawLayout.Value == "") or Modules.InputPrompt.prompt("Are you sure you want to delete this layout?") then

					for e,olayout in pairs(script.Parent.Contents:GetChildren()) do
						if olayout:FindFirstChild("Save") then
							olayout.Save.BackgroundColor3 = Color3.fromRGB(147, 147, 147)
							olayout.Save.Active = false
							olayout.Load.BackgroundColor3 = Color3.fromRGB(147, 147, 147)
							olayout.Load.Active = false
						end
					end



					if isTycoonEmpty(game.Players.LocalPlayer.ActiveTycoon.Value) and (rawLayout.Value == "[]" or rawLayout.Value == "") then
						layout.Status.Text = "Base is empty!"
						layout.Status.TextColor3 = Color3.new(1,0,0)
						wait(0.5)
					else
						layout.Save.BackgroundColor3 = Color3.fromRGB(147, 147, 147)
						layout.Save.Active = false




						local Success = game.ReplicatedStorage.Layouts:InvokeServer("Save",layout.Name)
						if Success then
							if rawLayout.Value == "[]" or rawLayout.Value == "" then

								Modules.Menu.sounds.Withdraw:Play()
								layout.Status.Text = "Setup cleared!"
								layout.Status.TextColor3 = Color3.new(1,1,1)
								for i,Child in pairs(layout.BG:GetChildren()) do
									if Child:IsA("GuiObject") and Child.Name ~= "Sample" then
										Child:Destroy()
									end
								end
							else
								Modules.Menu.sounds.Favorite:Play()
								layout.Status.Text = "Woah... your layout has been saved!"
								layout.Status.TextColor3 = Color3.new(0.1,0.7,1)
							end

							wait(0.7)
						elseif #Tycoon:GetChildren() > 201 then
							layout.Status.Text = "Too many items!"
							layout.Status.TextColor3 = Color3.new(1,0,0)
							wait(0.5)
						end

						layout.Save.BackgroundColor3 = Color3.fromRGB(115, 255, 255)
						layout.Save.Active = true
					end
				end

				check()
				Busy = false
			end)

			layout.Load.MouseButton1Click:connect(function()

				if Busy then
					return false
				end

				Busy = true

				local Tycoon = game.Players.LocalPlayer.ActiveTycoon.Value
				if Tycoon == nil or Tycoon ~= game.Players.LocalPlayer.PlayerTycoon.Value then
					Modules.Menu.sounds.Error:Play()
					return false
				end

				if layout.Load.Active then

					layout.Status.Text = "Loading..."
					layout.Status.TextColor3 = Color3.new(1,1,1)

					--L--
					--Attempt to prompt to buy all remaining items
					if ItemsToBuy[layout.Name] then
						local playerMoney = Modules.Tycoon.money.Value
						local totalAmount = 0
						for _,item in next,ItemsToBuy[layout.Name] do
							totalAmount = totalAmount + item.CostPerUnit*item.Amount
						end

						local beautifyNumber = Modules.MoneyLib.HandleMoney(totalAmount)
						local a = Modules.InputPrompt.prompt("Would you like to buy missing shop items for "..beautifyNumber.."?")

						if not a then
							ItemsToBuy[layout.Name] = nil
						end
					end
					-----

					for e,olayout in pairs(script.Parent.Contents:GetChildren()) do
						if olayout:FindFirstChild("Save") then
							olayout.Save.BackgroundColor3 = Color3.fromRGB(147, 147, 147)
							olayout.Save.Active = false
							olayout.Load.BackgroundColor3 = Color3.fromRGB(147, 147, 147)
							olayout.Load.Active = false
						end
					end



					layout.Load.BackgroundColor3 = Color3.fromRGB(147, 147, 147)
					layout.Load.Active = false

					if true --[[isTycoonEmpty(Tycoon)]] then
						local Success, collisons = game.ReplicatedStorage.Layouts:InvokeServer("Load",layout.Name,ItemsToBuy[layout.Name])
						ItemsToBuy[layout.Name] = nil
						if Success then
							Modules.Menu.sounds.Placement:Play()
							layout.Status.TextColor3 = Color3.new(0,1,0)
							if #collisons > 0 then
								layout.Status.Text = "Setup loaded! ("..tostring(#collisons).." items failed)"

								-- show collision parts
								for i,collision in pairs(collisons) do
									local Size = collision[1]
									local CoordinateFrame = collision[2]
									local Repre = Instance.new("Part")
									Repre.Material = Enum.Material.Neon
									Repre.Size = Size
									Repre.Color = Color3.new(1,0.2,0.23)
									Repre.Anchored = true
									Repre.CanCollide = false
									Repre.Transparency = 0.5
									Repre.CFrame = CoordinateFrame
									Repre.Parent = workspace
									game.Debris:AddItem(Repre,math.random(25,35)/10)
								end

								wait(1)
							else
								layout.Status.Text = "Setup loaded!"
								wait(0.5)
							end
						else
							layout.Status.Text = "Failed to load!"
							layout.Status.TextColor3 = Color3.new(1,0,0)
							Modules.Menu.sounds.Error:Play()
							wait(0.5)
						end
					else
						Modules.Menu.sounds.Error:Play()
						layout.Status.Text = "Withdraw all before loading!"
						layout.Status.TextColor3 = Color3.new(1,0,0)
						wait(0.5)
					end
					check()
				end
				Busy = false
			end)
		end
	end

	check()

	Modules.Focus.current.Changed:connect(function()
		if Modules.Focus.current.Value == script.Parent then
			check()
		end
	end)

	game.ReplicatedStorage.InventoryChanged.OnClientEvent:connect(function()
		if Modules.Focus.current.Value == script.Parent or script.Parent.Parent.Shop.Visible then
			check()
		end
	end)


end

return module
