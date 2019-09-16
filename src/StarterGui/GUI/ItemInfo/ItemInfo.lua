-- ItemInfo Module
--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

local module = {}


function module.show(Button)
	local LastButton = script.Parent.RealButton.Value
	if LastButton and LastButton:FindFirstChild("Amount") then
		LastButton.Amount.Visible = false
	end
	script.Parent.RealButton.Value = Button
	if Button and Button:FindFirstChild("Amount") then
		Button.Amount.Visible = true
	end
end

local function Tween()
	print("Tween not ready yet")
end

local LastButton

function module.hide(Button)

	if script.Parent.RealButton.Value == Button or Button == nil then -- conditional close, prevent override with .show
		script.Parent.RealButton.Value = nil
		if Button and Button:FindFirstChild("Amount") then
			Button.Amount.Visible = false
		end
		spawn(function()
			wait(0.1)
			if Button == LastButton then
				--Tween(script.Parent.Parent.Inventory.Cover,{"BackgroundTransparency"},1,0.2)
			end
		end)
	end
end



function module.init(Modules)

	Tween = Modules.Menu.tween

	script.Parent.RealButton.Changed:connect(function()



		local Button = script.Parent.RealButton.Value
		if Button then

			LastButton = Button

			--Tween(script.Parent.Parent.Inventory.Cover,{"BackgroundTransparency"},0.6,0.2)

			script.Parent.Item.Subtext.Visible = true
			if Button:IsDescendantOf(script.Parent.Parent.Inventory) and Button:FindFirstChild("Favorite") then
				script.Parent.Item.FavPrompt.Contents.Visible = true
				if Button.Favorite.Visible then
					script.Parent.Item.FavPrompt.Contents.TextLabel.Text = "Unfavorite Item"
				else
					script.Parent.Item.FavPrompt.Contents.TextLabel.Text = "Favorite Item"
				end
			else
				script.Parent.Item.FavPrompt.Contents.Visible = false
				script.Parent.Item.Subtext.Visible = false
				script.Parent.Item.CrateIcon.Visible = false
			end

			script.Parent.ExtraChildren:ClearAllChildren()

			local BGCol = Color3.fromRGB(132, 132, 132)

			if Button:FindFirstChild("Thumbnail") then
				script.Parent.Image = Button.Thumbnail.Image
				if Button:IsA("ImageButton") then
					BGCol = Button.ImageColor3
				end
			elseif Button:IsA("ImageButton") or Button:IsA("ImageLabel") then
				script.Parent.Image = Button.Image
			end
			script.Parent.BackgroundColor3 = Button.BackgroundColor3

			script.Parent.Inner.ImageColor3 = BGCol
			script.Parent.Frame.ImageColor3 = BGCol

			local Color = Color3.new(1,1,1)
			local BGColor = Color3.new(0,0,0)

			for i,Child in pairs(script.Parent.Item.BG:GetChildren()) do
				if Child:IsA("GuiObject") then
					Child.Visible = false
				end
			end


			script.Parent.Item.ImageColor3 = Color3.fromRGB(66, 66, 66)
			script.Parent.Item.Description.TextColor3 = Color3.fromRGB(197, 197, 197)
			script.Parent.Item.Description.TextStrokeColor3 = Color3.fromRGB(42, 42, 42)
			script.Parent.Item.Tier.TextStrokeColor3 = Color3.new(0,0,0)

			local Translator = game.LocalizationService:GetTranslatorForPlayer(game.Players.LocalPlayer)


			if Button:FindFirstChild("Box") then

				local RealItem = game.ReplicatedStorage.Boxes:FindFirstChild(Button.Name)
				if RealItem then

					script.Parent.Item.Tier.Visible = true
					local Count = 0
					if game.Players.LocalPlayer.Crates:FindFirstChild(Button.Name) then
						Count = game.Players.LocalPlayer.Crates[Button.Name].Value
					else
						script.Parent.Item.Tier.Visible = false
					end
					script.Parent.Item.Tier.Text = "You own "..Count.."."
					Color = RealItem.BoxColor.Value
					script.Parent.Item.Title.Text = Button.Name .. " Box"


					script.Parent.Item.Description.Text = Modules.Translate.Item(RealItem)

					script.Parent.Visible = true
				else
					module.hide()
				end

			elseif Button:FindFirstChild("ItemId") then

				local RealItem = Modules.Inventory.sortedItems[Button.ItemId.Value]
				if RealItem then


					script.Parent.Item.Description.Text = Modules.Translate.Item(RealItem)



					script.Parent.Item.Title.Text = Modules.Translate.ItemName(RealItem)

					script.Parent.BackgroundColor3 = Button.BackgroundColor3
					local t = RealItem.Tier.Value
					local Tier = game.ReplicatedStorage.Tiers:FindFirstChild(tostring(t))

					script.Parent.Item.CrateIcon.Visible = (RealItem.ItemType.Value == 11)



					-- todo decorations for enchanted items

					if Tier then
						script.Parent.Item.Tier.Visible = true
						script.Parent.Item.Tier.Text = Tier.TierName.Value
						Color = Tier.TierColor.Value
						local TBG = Tier.TierBackground.Value
						BGColor = Color3.new(TBG.r/2,TBG.g/2,TBG.b/2)

						script.Parent.Item.ImageColor3 = Color3.fromRGB(44 + Color.r * 18, 44 + Color.g * 18, 44 + Color.b * 18)

						if t == 40 or t == 41 then
							script.Parent.Item.BG.Vintage.Visible = true
							script.Parent.Item.BG.Vintage.ImageColor3 = Tier.TierBackground.Value
							script.Parent.Item.ImageColor3 = Tier.TierBackground.Value
							script.Parent.Item.Description.TextColor3 = Color3.fromRGB(56,56,56)
							script.Parent.Item.Description.TextStrokeColor3 = Tier.TierBackground.Value
							script.Parent.Item.Tier.TextStrokeColor3 = Tier.TierBackground.Value
						elseif t == 30 or t == 31 or t == 32 or t == 33 or t == 78 then
							script.Parent.Item.BG.Reborn.Visible = true
							script.Parent.Item.BG.Reborn.ImageColor3 = Tier.TierColor.Value
							script.Parent.Item.ImageColor3 = Tier.TierColor.Value
							script.Parent.Item.Description.TextColor3 = Color3.fromRGB(56,56,56)
							script.Parent.Item.Description.TextStrokeColor3 = Tier.TierColor.Value
						elseif t == 99 then
							script.Parent.Item.BG.Ultimate.Visible = true
							script.Parent.Item.ImageColor3 = Color3.fromRGB(138, 0, 2)
						elseif t == 66 then
							script.Parent.Item.BG.Luxury.Visible = true
							script.Parent.Item.ImageColor3 = Color3.fromRGB(203, 203, 203)
						elseif t == 100 then
							script.Parent.Item.BG.Enchanted.Visible = true
						elseif t == 77 then
							script.Parent.Item.BG.Contraband.Visible = true
							script.Parent.Item.ImageColor3 = Color3.fromRGB(0, 0, 0)
						end

					else
						script.Parent.Item.Tier.Visible = false
					end

					local SubText = ""
					local SubColor = Color3.fromRGB(255,255,255)
					if RealItem.Tier.Value == 32 and RealItem:FindFirstChild("RebornCount") then
						SubText = SubText .. "<Evo Index "..RealItem.RebornCount.Value.."> "
					elseif RealItem.Tier.Value == 30 or RealItem.Tier.Value == 33 then
						if RealItem:FindFirstChild("ReqLife") then
							SubText = SubText .. "<Life "..RealItem.ReqLife.Value.."> "
						end
						if RealItem:FindFirstChild("RebornChance") then
							SubText = SubText .. "<Rarity "..RealItem.RebornChance.Value.."> "
							if RealItem.RebornChance.Value == 1 then
								SubColor = Color3.fromRGB(170,70,255)
							elseif RealItem.RebornChance.Value <= 3 then
								SubColor = Color3.fromRGB(255,155,155)
							elseif RealItem.RebornChance.Value <= 6 then
								SubColor = Color3.fromRGB(175,175,255)
							elseif RealItem.RebornChance.Value <= 10 then
								SubColor = Color3.fromRGB(200,255,200)
							end
						end
					end
					if RealItem:FindFirstChild("Soulbound") then
						SubText = SubText .. "<Soulbound> "
					end
					if RealItem.Tier.Value ~= 30 and RealItem.Tier.Value ~= 31 and RealItem.Tier.Value ~= 32 and RealItem.Tier.Value ~= 33 and RealItem.Tier.Value ~= 100 and RealItem.ItemType.Value == 6 then
						SubText = SubText .. "<Special>"
					end
					if RealItem.Tier.Value == 78 then
						SubText = SubText .. "<Highly Unstable>"
						SubColor = Color3.fromRGB(255,100,100)
					end

					script.Parent.Item.Subtext.Text = SubText
					script.Parent.Item.Subtext.TextColor3 = SubColor

				--	script.Parent.BorderColor3 = Color


					script.Parent.Visible = true
				else
					module.hide()
				end

			end

			if script.Parent.Visible then
				--script.Parent.Item.BorderColor3 = Color
				--script.Parent.Item.ImageColor3 = Color
				script.Parent.Item.Tier.TextColor3 = Color
				if not script.Parent.Item.BG.Vintage.Visible then
					script.Parent.Item.Tier.TextStrokeColor3 = Color3.new(BGColor.r/2,BGColor.g/2,BGColor.b/2)
				end
				script.Parent.Item.Tier.BackgroundColor3 = BGColor
				--[[
				for i,Child in pairs(Button:GetChildren()) do
					if Child:IsA("GuiObject") and Child.Visible and Child.Name ~= "Thumbnail" then
						local New = Child:Clone()
						New.Parent = script.Parent.ExtraChildren
						New.ZIndex = Child.ZIndex + 7
						New.BorderSizePixel = 0
					end
				end
				]]
			end

		else
			script.Parent.Visible = false
		end
	end)
end


return module
