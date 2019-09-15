-- Input Module

--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

local module = {}

module.mode = script.Mode


local USI = game:GetService("UserInputService")

if USI.GamepadEnabled then
	module.mode.Value = "Xbox"
elseif USI.KeyboardEnabled then
	module.mode.Value = "PC"
elseif USI.TouchEnabled then
	module.mode.Value = "Mobile"
end

game.GuiService.AutoSelectGuiEnabled = false

function module.findFirstButton(Object)
	local Closest
	local Dist = 999
	for i,Button in pairs(Object:GetDescendants()) do
		if Button:IsA("GuiButton") and Button.Selectable then
			local D = (Object.AbsolutePosition - Button.AbsolutePosition).magnitude
			if D < Dist then
				Dist = D
				Closest = Button
			end
		end
	end
	return Closest
end

local function findFirstButton(Object)
	local Min = 9999
	local Ret = nil
	for i,Child in pairs(Object:GetChildren()) do
		if Child:IsA("GuiButton") and Child.Visible then
			if Child.LayoutOrder < Min then
				Min = Child.LayoutOrder
				Ret = Child
			end
		end
	end
	return Ret
end

function module.init(Modules)
	local Menu = Modules["Menu"]
	local HUD = Modules["HUD"]
	local Placement = Modules["Placement"]

	local Busy = false


	-- open up xbox chat
	local function OpenXboxChat()
		local Visible = not script.Parent.XboxMessage.Visible
		if Visible then
			Modules.Focus.change(script.Parent.XboxMessage)
			script.Parent.XboxMessage.Visible = true
			game:GetService("GuiService"):AddSelectionParent("XboxChat",script.Parent.XboxMessage)
			game:GetService("GuiService").SelectedObject = script.Parent.XboxMessage.TextBox
			game:GetService("GuiService").GuiNavigationEnabled = true
		end
	end



--	USI.TouchTapInWorld:connect(function(Position, Processed)
	USI.TouchTap:connect(function(Positions,Processed)
		if not Processed then
			if #Positions == 1 and not Placement.placing then
				Placement.selectFromPoint(Positions[1])
			end
		end
	end)

	local Debounce = true
	--[[
	function module.toggleInventory(String, Type)

		if Type == Enum.UserInputState.Cancel then
			return false
		end

		if Debounce then
			Debounce = false
			if not HUD.MenuOpen then
				Menu.openMenu("Inventory",true)
				HUD.openMenu()
			else
				if Menu.current.Value == "Inventory" then
					if Modules.Input.mode.Value == "Xbox" and script.Parent.Menu.Contents.Inventory.Frame.Items.CanvasPosition.Y > 30 then
						Modules.Menu.tween(script.Parent.Menu.Contents.Inventory.Frame.Items,{"CanvasPosition"},Vector2.new(0,0),0.2)
						Modules.Menu.sounds.SwooshFast:Play()
						wait(0.195)
						local FirstButton = findFirstButton(script.Parent.Menu.Contents.Inventory.Frame.Items)
						if FirstButton then
							game.GuiService.SelectedObject = FirstButton
						end

					else
						HUD.closeMenu()
					end

				else
					Menu.openMenu("Inventory")
				end
			end
			wait(0.15)
			Debounce = true
		end
	end
	]]

	function module.toggleShop(String, Type)

		Modules.ItemInfo.hide()


		-- todo: animate this ish

		if Type == Enum.UserInputState.Cancel then
			return false
		end

		if game.Players.LocalPlayer.ActiveTycoon.Value == nil then
			return false
		end

		if Modules.Focus.current.Value == script.Parent.Shop then
			if not script.Parent.Inventory.Visible then
				Modules.Focus.close()
				game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,true)
			else
				script.Parent.Shop.Visible = false
				Modules.Focus.current.Value = script.Parent.Inventory
			end
		elseif script.Parent.Shop.Visible then
			script.Parent.Shop.Visible = false
			if not script.Parent.Inventory.Visible then
				Modules.Focus.close()
			end
		else
			if Modules.Focus.current.Value then
				if not (Modules.Focus.current.Value.Name == "Inventory" and module.mode.Value == "PC") then
					Modules.Focus.change(script.Parent.Shop)
				end

			else
				Modules.Focus.change(script.Parent.Shop)
			end
			Modules.Shop.onOpen()
			script.Parent.Shop.Visible = true
			game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)
		end
	end

	function module.toggleInventory(String, Type)

		script.Parent.Inventory.Cover.BackgroundTransparency = 1

		script.Parent.MenuOpened.Value = true

		 Modules.ItemInfo.hide()

		-- todo: animate this ish

		if Type == Enum.UserInputState.Cancel then
			return false
		end

		if game.Players.LocalPlayer.ActiveTycoon.Value == nil then
			return false
		end

		if Modules.Focus.current.Value == script.Parent.Inventory then
			if not script.Parent.Shop.Visible then
				Modules.Focus.close()
				game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,true)
			else
				script.Parent.Inventory.Visible = false
				Modules.Focus.current.Value = script.Parent.Shop
			end
		elseif script.Parent.Inventory.Visible then
			script.Parent.Inventory.Visible = false
			if not script.Parent.Shop.Visible then
				Modules.Focus.close()
			end
		else
			if Modules.Focus.current.Value then
				if not (Modules.Focus.current.Value.Name == "Shop" and module.mode.Value == "PC") then
					Modules.Focus.change(script.Parent.Inventory)
				end

			else
				Modules.Focus.change(script.Parent.Inventory)
			end
			script.Parent.Inventory.Visible = true
			game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)
		end
	end

	function module.togglePremium(String, Type)
		if Type == Enum.UserInputState.Cancel then
			return false
		end

		if game.Players.LocalPlayer.ActiveTycoon.Value == nil then
			return false
		end

		if Modules.Focus.current.Value == script.Parent.Premium then
			Modules.Focus.close()
		else
			script.Parent.Premium.Visible = true
			Modules.Focus.change(script.Parent.Premium)
		end
	end

	function module.toggleSettings(String, Type)

		if Type == Enum.UserInputState.Cancel then
			return false
		end

		if game.Players.LocalPlayer.ActiveTycoon.Value == nil then
			return false
		end

		if Modules.Focus.current.Value == script.Parent.Settings then
			Modules.Focus.close()
		else
			script.Parent.Settings.Visible = true
			Modules.Focus.change(script.Parent.Settings)
		end
		--[[
		if not HUD.MenuOpen then
			Menu.openMenu("Settings",true)
			HUD.openMenu()
		else
			if Menu.current.Value == "Settings" then
				HUD.closeMenu()
			else
				Menu.openMenu("Settings")
			end
		end
		]]
	end


	-- Placing

	--game.ContextActionService:BindActionAtPriority("XboxChat",OpenXboxChat,false,Enum.ContextActionPriority.High,Enum.KeyCode.ButtonSelect)


	USI.InputEnded:connect(function(Input,Processed)

		if Input.KeyCode == Enum.KeyCode.ButtonSelect then
			OpenXboxChat()
		end

		if Processed then
			return false
		end

		if not Processed and not Busy then
			local InputVal = Input.UserInputType.Value

			if (InputVal == 8) or (InputVal >= 0 and InputVal <= 4) then
				module.mode.Value = "PC"
			elseif InputVal == 7 then
				module.mode.Value = "Mobile"
			elseif InputVal >= 12 and InputVal <= 19 then
				module.mode.Value = "Xbox"
			end

			local Focused = (script.Parent.FocusWindow.Value and script.Parent.FocusWindow.Value.Visible)
			local Tycoon = game.Players.LocalPlayer.ActiveTycoon.Value

			-- XBOX CONTROLS

			if Input.KeyCode == Enum.KeyCode.ButtonA then
				if script.Parent.ItemPreview.Frame.Expanded.Value then
					Modules.Placement.quickplace()
				end

			elseif Modules.Placement.placing and Input.KeyCode == Enum.KeyCode.DPadUp then
				Modules.Placement.raise()
			elseif Modules.Placement.placing and Input.KeyCode == Enum.KeyCode.DPadDown then
				Modules.Placement.lower()
			elseif Input.KeyCode == Enum.KeyCode.ButtonB then
				if script.Parent.Shop.Visible then
					if script.Parent.Shop.Confirm.Visible then
						for i,Button in pairs(script.Parent.Shop.Frame.Items:GetChildren()) do
							if Button:FindFirstChild("ItemId") and Button.ItemId.Value == script.Parent.Shop.SelectedItem.Value then
								game.GuiService.SelectedObject = Button
							end
						end
						script.Parent.Shop.SelectedItem.Value = 0
					elseif script.Parent.Shop.Mode.Value ~= "New" then
						local OldMode = script.Parent.Shop.Mode.Value
						local Button = script.Parent.Shop.Frame.Top:FindFirstChild(OldMode)
						script.Parent.Shop.Mode.Value = "New"

						if Button then
							script.Parent.Shop.Frame.Top.Visible = true
							game.GuiService.SelectedObject = Button
						end

					else
						Modules.Focus.close()
					end
				elseif Modules.Placement.placing then
					Modules.Placement.stopPlacing()
				elseif Focused then
					Modules.Focus.close()
				elseif script.Parent.ItemPreview.Frame.Expanded.Value then
					Modules.Preview.collapse()
				end



			elseif Input.KeyCode == Enum.KeyCode.DPadUp then
				if Modules.Preview.expanded ~= nil and script.Parent.ItemPreview.Visible and script.Parent.ItemPreview.Frame.Expanded.Value then
					Modules.Placement.quickplace()
				elseif not Focused then
					Modules.Tycoon.remotedrop()
				end

			elseif Input.KeyCode == Enum.KeyCode.DPadLeft then
				if not Focused then
					Modules.Tycoon.pulse()
				end

			elseif Input.KeyCode == Enum.KeyCode.DPadRight then
				if not Focused then
					Modules.Focus.change(script.Parent.HUDRight)
					script.Parent.HUDRight.Visible = true
					script.Parent.HUDRight.XboxKey.Close.Visible = true
					script.Parent.HUDRight.XboxKey.Open.Visible = false
					--Modules.HUD.opengift()
				end

			elseif Input.KeyCode == Enum.KeyCode.DPadDown then
				if not Focused then
					Modules.HUD.openboxes()
				end

			elseif Input.KeyCode == Enum.KeyCode.ButtonX then
				if Tycoon then
					if script.Parent.ItemPreview.Frame.Expanded.Value then
						Modules.Placement.withdraw()
					else
						module.toggleInventory()
					end
				end

			elseif Input.KeyCode == Enum.KeyCode.ButtonY then
				if Tycoon then
					if script.Parent.ItemPreview.Frame.Expanded.Value then
						Modules.Placement.quicksell()
					elseif Modules.Placement.placing then
						Modules.Placement.undo()
					else
						module.toggleShop()
					end
				end

			elseif Input.KeyCode == Enum.KeyCode.ButtonL2 then
				if Modules.Placement.placing then
					Modules.Placement.rotate()
				end

			elseif Input.KeyCode == Enum.KeyCode.ButtonL1 then
				if script.Parent.Inventory.Visible then
					module.toggleSettings()
				elseif Modules.Placement.placing then
					Modules.Placement.shiftleft()
				end

			elseif Input.KeyCode == Enum.KeyCode.ButtonR1 then
				if script.Parent.Shop.Visible then
					script.Parent.Premium.Visible = true
					Modules.Focus.change(script.Parent.Premium)
				elseif Modules.Placement.placing then
					Modules.Placement.shiftright()
				elseif script.Parent.ItemInfo.Item.FavPrompt.Contents.Visible then
					local Button = script.Parent.ItemInfo.RealButton.Value
					if Button then
						local Success = game.ReplicatedStorage.ToggleFavorite:InvokeServer(Button.ItemId.Value)
						if not Success then
							Modules.Menu.sounds.Error:Play()
						else
							Modules.ItemInfo.hide(Button)
							Modules.Inventory.favorite(Button)
						end
					end
				end

			-- PC CONTROLS

			elseif Input.KeyCode == Enum.KeyCode.E then
				module.toggleInventory()
			end

			if Modules.Placement.placing then
				if Input.KeyCode == Enum.KeyCode.R then
					Modules.Placement.rotate()
				elseif Input.KeyCode == Enum.KeyCode.Q then
					Modules.Placement.stopPlacing()
				elseif Input.KeyCode == Enum.KeyCode.F then
					Modules.Placement.undo()
				elseif Input.KeyCode == Enum.KeyCode.Z then
					Modules.Placement.shiftleft()
				elseif Input.KeyCode == Enum.KeyCode.C then
					Modules.Placement.shiftright()
				elseif Input.KeyCode == Enum.KeyCode.One or Input.KeyCode == Enum.KeyCode.KeypadOne then
					Modules.Placement.lower()
				elseif Input.KeyCode == Enum.KeyCode.Two or Input.KeyCode == Enum.KeyCode.KeypadTwo	then
					Modules.Placement.raise()
				end

			elseif script.Parent.ItemPreview.Frame.Expanded.Value then
				if Input.KeyCode == Enum.KeyCode.Z then
					Modules.Placement.withdraw()
				elseif Input.KeyCode == Enum.KeyCode.R then
					Modules.Placement.quickplace()
				elseif Input.KeyCode == Enum.KeyCode.X then
					Modules.Placement.quicksell()
				elseif Input.KeyCode == Enum.KeyCode.C then
					Modules.Placement.quickbuy()
				end

			else
				if Input.KeyCode == Enum.KeyCode.F then
					module.toggleShop()
				elseif Input.KeyCode == Enum.KeyCode.C then
					module.toggleSettings()
				elseif Input.KeyCode == Enum.KeyCode.P then
					module.togglePremium()
				elseif Input.KeyCode == Enum.KeyCode.L then
					Modules.Focus.change(script.Parent.Layouts)
				end

			end
		end
	end)


	local function Scan()
		for i,Object in pairs(script.Parent:GetDescendants()) do
			if Object:IsA("GuiObject") then

				if Object:FindFirstChild("PC") or Object:FindFirstChild("Xbox") or Object:FindFirstChild("Mobile") then
					Object.Visible = Object:FindFirstChild(module.mode.Value)
				end

			end
		end
	end
	Scan()


	module.mode.Changed:connect(Scan)

	--print(module.mode.Value)

end


return module
