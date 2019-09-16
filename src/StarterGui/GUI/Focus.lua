-- Focus Module

--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

local module = {}


function module.close()
	warn("Focus.close not yet ready")
end

module.current = script.Parent.FocusWindow

function module.change()
	warn("Focus.change not yet ready")
end



local function getBestButton(gui)
	local hiv = Vector2.new(999,999)
	local top
	for i, child in pairs (gui:GetDescendants()) do
		if child:IsA("GuiButton") and child.Visible then
			local vec = child.AbsolutePosition - gui.AbsolutePosition
			if vec.magnitude < hiv.magnitude then
				top = child
				hiv = vec
			end
		end
	end
	return top
end

function module.init(Modules)
	script.Parent.FocusWindow.Changed:connect(function()
		local Object = script.Parent.FocusWindow.Value
		if Object and Object:IsA("GuiObject") then
			Object:GetPropertyChangedSignal("Visible"):connect(function()
				if not Object.Visible then
					script.Parent.FocusWindow.Value = nil
				end
			end)
		end
	end)

	local Blur = game.Lighting.Blur

	function module.close()


		if Modules.Input.mode.Value == "Xbox" then
			game:GetService("GuiService").GuiNavigationEnabled = false
			game:GetService("GuiService").SelectedObject = nil
			pcall(function()
				game:GetService("GuiService"):RemoveSelectionGroup("Focus")
				game:GetService("GuiService"):RemoveSelectionGroup("stealFocus")
			end)
		end

		for i,Object in pairs(script.Parent:GetChildren()) do
			if Object:IsA("GuiObject") and Object:FindFirstChild("MenuObject") then
				Object.Visible = false
			end
		end

		local Object = script.Parent.FocusWindow.Value
		if Object and Object:IsA("GuiObject") then




			script.Parent.FocusWindow.Value = nil




			if Object == script.Parent.Menu then
				Modules.HUD.closeMenu()
			elseif Object == script.Parent.HUDRight then
				script.Parent.HUDRight.Visible = true
				script.Parent.HUDRight.XboxKey.Close.Visible = false
				script.Parent.HUDRight.XboxKey.Open.Visible = true
			else
				Object.Visible = false
			end



			if Object == script.Parent.MOTD then
				game.ReplicatedStorage.MOTDRead:InvokeServer()
			end
		end
		Modules.ItemInfo.hide()
		Modules.Preview.collapse()
		game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All,true)

		if Blur.Size > 0 then
			Modules.Menu.tween(Blur,{"Size"},{0},0.5)
		end
		Modules.HUD.showHUD()
	end

	module.close()

	local function fade(new)
		if new:IsA("ImageLabel") then
			local Tag = new:FindFirstChild("OriginalBg")
			if Tag == nil then
				Tag = Instance.new("NumberValue")
				Tag.Name = "OriginalBg"
				Tag.Value = new.ImageTransparency
				Tag.Parent = new
			end

			new.ImageTransparency = 1
			Modules.Menu.tween(new,{"ImageTransparency"},Tag.Value,0.5)
			if new:FindFirstChild("Depth") then
				fade(new.Depth)
			end
		end
	end

	local function focusinfo(new, override)
		override = override or "Focus"
		if Modules.Input.mode.Value == "Xbox" then
			game:GetService("GuiService"):RemoveSelectionGroup("Focus")
			local Button = getBestButton(new)
			local Selection = game.GuiService.SelectedObject

			if Button then
				game:GetService("GuiService").GuiNavigationEnabled = true
				if Selection == nil or not Selection:IsDescendantOf(new) then
					game:GetService("GuiService").SelectedObject = Button
				end
				game:GetService("GuiService"):AddSelectionParent(override,new)
			end
		end

	end

	function module.stealFocus(new)
		if not new:IsA("GuiObject") then
			warn("Tried to focus on something that isn't a gui!")
		end
		focusinfo(new, "stealFocus")
	end

	function module.change(new)

		if not new:IsA("GuiObject") then
			warn("Tried to focus on something that isn't a gui!")
		end

		if new.Name ~= "Shop" and new.Name ~= "Inventory" then
			script.Parent.Shop.Visible = false
			script.Parent.Inventory.Visible = false
		end
		local Object = script.Parent.FocusWindow.Value
		if Object and Object:IsA("GuiObject") then
			Object.Visible = false
		end

		for i,Object in pairs(script.Parent:GetChildren()) do
			if Object:IsA("GuiObject") and Object:FindFirstChild("MenuObject") then
				Object.Visible = false
			end
		end

		if  Object == script.Parent.HUDRight then
			script.Parent.HUDRight.Visible = true
			script.Parent.HUDRight.XboxKey.Close.Visible = false
			script.Parent.HUDRight.XboxKey.Open.Visible = true
		end

		fade(new)


		Modules.Menu.tween(Blur,{"Size"},{9},0.5)

		new.Visible = true

		if new:FindFirstChild("Contents") and new.Contents:IsA("ScrollingFrame") then
			new.Contents.CanvasPosition = Vector2.new(0,0)
		end

		Modules.ItemInfo.hide()
		Modules.Preview.collapse()
		script.Parent.FocusWindow.Value = new
		focusinfo(new)


	end

end



return module
