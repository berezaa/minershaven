--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

local module = {}

local Done = false

local BaseSize = UDim2.new(0,300,0,100)

local function resize()

end

function Tween(Object, Properties, Value, Time)
	Time = Time or 0.5

	local propertyGoals = {}

	local Table = (type(Value) == "table" and true) or false

	for i,Property in pairs(Properties) do
		propertyGoals[Property] = Table and Value[i] or Value
	end
	local tweenInfo = TweenInfo.new(
		Time,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out
	)
	local tween = game:GetService("TweenService"):Create(Object,tweenInfo,propertyGoals)
	tween:Play()
end


function module.init()
	math.randomseed(os.time())
	game.StarterGui:SetCoreGuiEnabled("Backpack",false)


	wait()


	script.Parent.Contents.Bottom.Position = UDim2.new(0,0,1,0)
	script.Parent.Contents.Top.Position = UDim2.new(0,0,-0.6,0)

	script.Parent.Contents.Bottom.Leaderboards.Position = UDim2.new(0.5,0,1.5,0)
	script.Parent.Contents.Bottom.Leaderboards.Visible = false

	if workspace:FindFirstChild("Private") then
		script.Parent.Contents.Top.TextLabel.Text = game.Players.LocalPlayer.Name.."'s Private Island"
		script.Parent.Contents.Bottom.Solo.Visible = false
		script.Parent.Contents.Bottom.Enter.Visible = true
		script.Parent.Contents.Bottom.Enter.Position = UDim2.new(0.5,-50,0.22,0)
	end

	game.ReplicatedStorage:WaitForChild("IsWhitelisted")
	local Allowed = game.ReplicatedStorage.IsWhitelisted:InvokeServer()
	if not Allowed then
		script.Parent.Contents.NotAllowed.Visible = true
		return false
	end

	local YaDoneNow = false


	wait(1)

	if script.Parent.Contents:FindFirstChild("Ambiance") then
		require(script.Parent.Contents.Ambiance).init()
	end

	local Tips = {
		"A mysterious merchant appears on the weekend to sell secret items. You just have to find them.",
		"When you reach $25Qn, you can advance to the next life with a powerful new Reborn item.",
		"Cell Furnaces don't take upgraded ore. Some mines are so powerful that their ore starts out upgraded.",
		"Research Points are shared across save files and are not lost when rebirthing.",
		"Coal is used to power special industrial mines and upgraders that won't work without it.",
		"Many upgraders have limits to how they can be used. They will flash if not used correctly.",
		"Having trouble with other players? Try Play Solo, where you can play on your own private island.",
		"You can sync your Miner's Haven account with our community server to unlock special ranks and chatrooms.",
		"Decorative items don't give any money when sold. However, they stay in your inventory when you Rebirth.",
		"Play together with your friends! Add people to your base & edit permissions under the Settings tab.",
		"The best way to rebirth quickly is to have a layout or two and constantly improve them as you gain new items.",
		"Having trouble rebirthing? Try searching for Research Crates on the map and use the items you find in them!"
	}
	local USI = game:GetService("UserInputService")

	if USI.MouseEnabled and USI.KeyboardEnabled then
		table.insert(Tips,"Right-click items in your inventory to favorite them. Favorite items always appear on top.")
		table.insert(Tips,"Quickly toggle various parts of the menu with hotkeys. [E] opens inventory and [F] opens the shop.")
		table.insert(Tips,"Click and hold to quickly select multiple items on your base at once.")
		table.insert(Tips,"You can drag-click your mouse to quickly place an item multiple times.")
	end

	local Tip = Tips[math.random(1,#Tips)]
	script.Parent.Contents.Bottom.Tip.Text = "Tip: "..Tip
	script.Parent.Contents.Tip.Content.Text = Tip


	local DoneLoading = true


	--script.Parent.Contents.Music:Play()


--[[
	Tween(game.Lighting,{
		"FogColor",
		"FogEnd",
		"Ambient",
		"Brightness",
		"OutdoorAmbient"
	},
	{
		Color3.new(0.0,0,0.05),
		500,
		Color3.new(0.0,0,0.03),
		0.1,
		Color3.new(0.03,0.07,0.09)
	},4)
	wait(1)
]]
	local h = 0
	local progress = 0




	--[[
	-- LOAD ASSETS
	local Ids = {}




	local Loading

	local function scan(Object)
		for i,Ins in pairs(Object:GetDescendants()) do
			if Ins:IsA("ImageLabel") or Ins:IsA("ImageButton") or Ins:IsA("Decal") then
				table.insert(Ids,Ins)
			end
		end
	end


	scan(game.StarterGui)


	game.ReplicatedStorage:WaitForChild("Items")
	for i,Item in pairs(game.ReplicatedStorage.Items:GetChildren()) do
		if Item.ItemType.Value == 11 then
			table.insert(Ids,"http://www.roblox.com/asset/?id="..Item.ThumbnailId.Value)
		end
	end






	table.insert(Ids,script.Parent.Contents.Music)
	scan(script.Parent.Contents)

	local Queue = #Ids

	spawn(function()
		game:GetService("ContentProvider"):PreloadAsync(Ids)
		DoneLoading = true
	end)

	local Time = os.time()

	wait(0.1)
	local Queue = game.ContentProvider.RequestQueueSize

	while not DoneLoading do

		game:GetService("RunService").Heartbeat:wait()

		local Cur = game.ContentProvider.RequestQueueSize
		if Cur > Queue then
			Queue = Cur
		end

		progress = (Queue - Cur) / Queue

		script.Parent.Contents.Bar.Progress.Size = UDim2.new(progress/1,0,1,0)

		if (os.time() - Time) >= 30 then
			DoneLoading = true
		end
	end

	script.Parent.Contents.Bar.Progress.Size = UDim2.new(1,0,1,0)


--	Tween(script.Parent.Contents.Bar.Progress, {"BackgroundColor3"}, Color3.fromRGB(255, 214, 90) )
--	Tween(script.Parent.Contents.Background, {"ImageColor3"}, Color3.fromRGB(255, 214, 90) )
]]


	--Tween(script.Parent.Contents.Bar.Progress, {"BackgroundColor3"}, Color3.fromRGB(216, 186, 36) )
	--Tween(script.Parent.Contents.Background, {"ImageColor3","BackgroundTransparency"}, {Color3.fromRGB(0, 0, 255),0.5}, 2)
	--Tween(script.Parent.Contents.Loading, {"TextTransparency"}, 1, 2)

	wait(1)
	resize()



	script.Parent.Contents.Top.Visible = true
	--[[
	if game.Players.LocalPlayer:FindFirstChild("Executive") then
		script.Parent.Contents.Top.Logo.Executive.Visible = true
	elseif game.Players.LocalPlayer:FindFirstChild("Premium") then
		script.Parent.Contents.Top.Logo.Premium.Visible = true
	elseif game.Players.LocalPlayer:FindFirstChild("VIP") then
		script.Parent.Contents.Top.Logo.VIP.Visible = true
	end
	]]


	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):connect(resize)
	script.Parent.Contents.Top:TweenPosition(UDim2.new(0,0,-0.1,0),Enum.EasingDirection.Out,Enum.EasingStyle.Bounce,2)
	script.Parent.Contents.Bottom:TweenPosition(UDim2.new(0,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Bounce,2)

	spawn(function()
		wait(2)
		Tween(script.Parent.Contents.Bottom.Tip,{"TextTransparency"},0.3,1)
	end)

	-- leaderboard stuff
	spawn(function()

		for i,Leaderboard in pairs(script.Parent.Contents.Bottom.Leaderboards:GetChildren()) do
			if Leaderboard:IsA("GuiObject") then
				local Real = workspace:WaitForChild("Map"):WaitForChild(Leaderboard.Name)
				if Real then
					local ui = Real:WaitForChild("Board").Leaderboard.Frame
					Leaderboard.Visible = true
					Leaderboard.Winner.BackgroundColor3 = ui.Winner.BackgroundColor3
					Leaderboard.Winner.Thumbnail.Image = ui.Winner.Thumbnail.Image
					Leaderboard.Winner.Thumbnail.ImageColor3 = ui.Winner.Thumbnail.ImageColor3
					Leaderboard.Winner.Amount.Text = ui.Winner.Amount.Text
					Leaderboard.Winner.Amount.TextColor3 = ui.Winner.Amount.TextColor3
					Leaderboard.Winner.Pos.TextColor3 = ui.Winner.Title.TextColor3
					Leaderboard.Winner.WinnerName.Text = ui.Winner.WinnerName.Text
					Leaderboard.Winner.WinnerName.TextColor3 = ui.Winner.WinnerName.TextColor3
					Leaderboard.Title.Text = ui.Title.Text
				else
					Leaderboard.Visible = false
				end
			end
		end
		wait(1.5)
		script.Parent.Contents.Bottom.Leaderboards.Visible = true
		Tween(script.Parent.Contents.Bottom.Leaderboards,{"Position"},UDim2.new(0.5,0,1,0),1)

	end)

	if game.Lighting:FindFirstChild("Blur") then
		Tween(game.Lighting:WaitForChild("Blur"),{"Size"},10,0.4)
	end


	Tween(script.Parent.Contents.Tip,{"Position"},UDim2.new(0.5,0,1.5,0),1)
	wait(2)
	script.Parent.Contents.Tip.Visible = false




	local Allowed = game.ReplicatedStorage.IsWhitelisted:InvokeServer()
	if Allowed then


		--Code for checking friends' private islands
		--[[
		local Players = game:GetService("Players")
		local friends = Players.LocalPlayer:GetFriendsOnline()

		for i,friendData in next,friends do
			if friendData.LocationType == 4 then
				if PlaceId == game.PlaceId and
			end
		end
		]]--

		script.Parent.Contents.Bottom.Enter.Visible = true
		script.Parent.Contents.Bottom.Solo.Visible = true
		script.Parent.Contents.Bottom.Saves.Visible = false

		if workspace:FindFirstChild("Private") then
			script.Parent.Contents.Bottom.Solo.Visible = false
			script.Parent.Contents.Bottom.Enter.Visible = true
			script.Parent.Contents.Bottom.Enter.Position = UDim2.new(0.5,-50,0.22,0)
		end


		if USI.GamepadEnabled then
			script.Parent.Contents.XboxControls.Visible = true
			game.GuiService.GuiNavigationEnabled = true
			game.GuiService.SelectedObject = script.Parent.Contents.Bottom.Enter
		end

		spawn(function()
			wait()
			if USI.GamepadEnabled then
				script.Parent.Contents.XboxControls.Visible = true
				game.GuiService.GuiNavigationEnabled = true
				game.GuiService.SelectedObject = script.Parent.Contents.Bottom.Enter
			end
		end)

		local Requested = false
		game.ReplicatedStorage:WaitForChild("MoneyLib")
		local MoneyLib = require(game.ReplicatedStorage.MoneyLib)
		--[[
		local function RequestLoad()
			if not Requested then
				Requested = true

				if game.ReplicatedStorage.Waitlist:FindFirstChild(game.Players.LocalPlayer.Name) then
					script.Parent.Contents.Bottom.Status.TextColor3 = Color3.new(1,0.5,0.5)
					script.Parent.Contents.Bottom.Status.Text = "You're attempting to rejoin this server too quickly!"
					script.Parent.Contents.Bottom.Status.Visible = true
					wait(1)
					script.Parent.Contents.Bottom.Status.Visible = false
					Requested = false
					return false
				end

				script.Parent.Contents.Bottom.Status.Text = "Loading data..."
				script.Parent.Contents.Bottom.Status.TextColor3 = Color3.new(1,1,1)
				script.Parent.Contents.Bottom.Status.Visible = true

				local Result, Success, Errormsg, DataCount = game.ReplicatedStorage.LoadPlayerData:InvokeServer()

				if DataCount then
					print("Your data is "..DataCount.." characters long.")
				end

				if not Result then -- Ruh-oh, something went wrong!
					if Success then
						script.Parent.Contents.Bottom.Status.TextColor3 = Color3.new(1,0.75,0.5)
						for i=1,60 do
							script.Parent.Contents.Bottom.Status.Text = "Failed to connect to ROBLOX! Retrying in: ("..(61-i)..")"
							wait(1)
						end
						Requested = false
						RequestLoad()
					else
						script.Parent.Contents.Bottom.Status.TextColor3 = Color3.new(1,0.5,0.5)
						script.Parent.Contents.Bottom.Status.Text = "Something went wrong! Check error log."
						warn("ERROR LOADING PLAYER DATA")
						warn(Errormsg)
						print("Please send a screenshot of this to berezaa")
					end
				else
					script.Parent.Contents.Bottom.Status.TextColor3 = Color3.new(0.5,1,0.6)
					script.Parent.Contents.Bottom.Status.Text = "Success! Welcome to Miner's Haven!"
				end

			end
		end
		]]
	--	script.Parent.Contents.Bottom.Enter.MouseButton1Click:connect(RequestLoad)

		local function LoadSlotButton(Button)
			local Slot = tonumber(Button.Name)
			if Slot and not Requested then
				Requested = true
				script.Parent.Contents.Click:Play()
				if not Button.Loaded.Value then

					Button.Load.Visible = false
					Button.Status.Visible = true
					Button.Status.Text = "Loading..."
					Button.Status.TextColor3 = Color3.new(1,1,1)
					local Success, Data = game.ReplicatedStorage.QuickLoad:InvokeServer(Slot)
					if Success then
						Button.Status.Visible = false
						Button.Load.Text = "[PLAY]"
						Button.Load.BackgroundColor3 = Color3.new(0.5,1,0.5)
						Button.Load.Visible = true
						if USI.GamepadEnabled and game.GuiService.SelectedObject == nil then
							game.GuiService.SelectedObject = Button.Load
						end
						Button.Cash.Visible = true
						Button.Loaded.Value = true
						if Data and Data["Money"] then
							Button.Cash.Text = MoneyLib.HandleMoney(tonumber(Data.Money))
							if Data["Rebirths"] then
								Button.Life.Visible = true
								local Prefix = ""
								if Data["SecondSacrifice"] then
									Prefix = "S+"
								elseif Data["Sacrifice"] then
									Prefix = "s-"
								end
								Button.Life.Text = Prefix..MoneyLib.HandleLife(Data["Rebirths"] + 1).." Life"
							else
								Button.Life.Visible = false
							end
						else
							Button.Cash.Text = "New Game"
						end
					else
						Button.Status.Text = "Error Loading!"
						Button.Status.TextColor3 = Color3.new(1,0.5,0.5)
						wait(3)
						Button.Status.Visible = false
						Button.Load.Visible = true
					end
					Requested = false
				else
					--Tween(workspace.CurrentCamera,{"FieldOfView"},20,0.3)
					Button.Load.Visible = false
					Button.Status.TextColor3 = Color3.new(0.5,1,0.5)
					Button.Status.Text = "Loading..."
					Button.Status.Visible = true
					local Success = game.ReplicatedStorage.LoadPlayerData:InvokeServer(Slot)
					if not Success then
						Button.Status.Text = "Error Occurred!"
						wait(1)
						Button.Load.Visible = true
						Button.Status.Visible = false
						Requested = false
					end
					Button.Status.Text = "Success!"
				end
			end
		end

		local DB = true

		script.Parent.Contents.Bottom.Solo.MouseButton1Click:connect(function()
			if DB then
				DB = false
				script.Parent.Contents.Click:Play()
				local Success = game.ReplicatedStorage.PlaySolo:InvokeServer()
				if Success then
					script.Parent.Contents.Bottom.Status.TextColor3 = Color3.new(0.3,0.6,1)
					script.Parent.Contents.Bottom.Status.Text = "Teleporting to your private island..."
					script.Parent.Contents.Bottom.Status.Visible = true
				else
					script.Parent.Contents.Bottom.Status.TextColor3 = Color3.new(1,0.5,0.5)
					script.Parent.Contents.Bottom.Status.Text = "Something went wrong on the server."
					script.Parent.Contents.Bottom.Status.Visible = true
					wait(1)
					script.Parent.Contents.Bottom.Status.Visible = false
				end
				DB = true
			end
		end)



		script.Parent.Contents.Bottom.Enter.MouseButton1Click:connect(function()
			if DB then
				DB = false
				script.Parent.Contents.Click:Play()
				if game.ReplicatedStorage.Waitlist:FindFirstChild(game.Players.LocalPlayer.Name) then
					script.Parent.Contents.Bottom.Status.TextColor3 = Color3.new(1,0.5,0.5)
					script.Parent.Contents.Bottom.Status.Text = "You're attempting to rejoin this server too quickly!"
					script.Parent.Contents.Bottom.Status.Visible = true
					wait(1)
					script.Parent.Contents.Bottom.Status.Visible = false
					DB = true
					return false
				else
					spawn(function()
						Tween(game.Lighting:WaitForChild("Blur"),{"Size"},30,0.4)
						Tween(game.Lighting:WaitForChild("Bloom"),{"Intensity","Threshold"},{1,0.5},0.4)
						Tween(game.Lighting:WaitForChild("ColorCorrection"),{"Brightness"},0.2,0.4)
						game.Lighting.Blur.Enabled = true
						game.Lighting.ColorCorrection.Enabled = true
						wait(0.3)

						local Tycoon = game.Players.LocalPlayer.PlayerTycoon.Value
						if not Tycoon then
							--workspace.CurrentCamera.CFrame = script.Parent.Contents.CamPos.Value
							YaDoneNow = true
						end


						Tween(game.Lighting:WaitForChild("ColorCorrection"),{"Brightness"},-0.04,0.4)
						Tween(game.Lighting.Blur,{"Size"},5,0.4)
						Tween(game.Lighting.Bloom,{"Intensity","Threshold"},{0.15,0.95},0.4)


						local camera = workspace.CurrentCamera
						local angle = math.rad(70)
						local velo = 0.05

						workspace.CurrentCamera.FieldOfView = 40

						while not YaDoneNow do
						    local cf = CFrame.new(Tycoon.Base.Position)  --Start at the position of the part
						                           * CFrame.Angles(0, angle, 0) --Rotate by the angle
						                           * CFrame.new(0, 0, 230)       --Move the camera backwards 5 units
						    angle = angle + math.rad(velo)
							workspace.CurrentCamera.CFrame = CFrame.new(cf.p + Vector3.new(0,35,0),Tycoon.Base.Position+ Vector3.new(0,10,0))
							game:GetService("RunService").RenderStepped:wait()

						end

						wait(0.3)
					end)
					script.Parent.Contents.Bottom.Enter.Visible = false
					script.Parent.Contents.Bottom.Solo.Visible = false
					Tween(script.Parent.Contents.Bottom.Leaderboards,{"Position"},UDim2.new(0.5,0,1.5,0))
					Tween(script.Parent.Contents.Bottom.Tip,{"TextTransparency"},1,1)
					local Abs = script.Parent.Contents.Bottom.Saves.AbsoluteSize
					script.Parent.Contents.Bottom.Saves.Position = UDim2.new(0.5,0,1,10)
					script.Parent.Contents.Bottom.Saves:TweenPosition(UDim2.new(0.5,0,0.03,35),nil,nil,0.5)
					script.Parent.Contents.Bottom.Saves.Visible = true
					--LoadSlotButton(script.Parent.Contents.Bottom.Saves.Slots["1"])
					if USI.GamepadEnabled then
						game.GuiService.GuiNavigationEnabled = true
						game.GuiService.SelectedObject = script.Parent.Contents.Bottom.Saves.Slots["1"].Load
					end
				end
				DB = true
			end
		end)



		for i,Button in pairs(script.Parent.Contents.Bottom.Saves.Slots:GetChildren()) do
			if Button:FindFirstChild("Loaded") then
				Button.Load.MouseButton1Click:connect(function()

					LoadSlotButton(Button)
				end)
			end
		end

	else
		script.Parent.Contents.Bottom.Status.TextColor3 = Color3.new(1,0.5,0.5)
		script.Parent.Contents.Bottom.Status.Visible = true
		script.Parent.Contents.Bottom.Enter.Visible = false
		script.Parent.Contents.Bottom.Solo.Visible = false

		if game.ReplicatedStorage:FindFirstChild("BerOnly") then
			script.Parent.Contents.Bottom.Status.Text = "You can only test with berezaa in your server."
		else
			script.Parent.Contents.Bottom.Status.Text = "You do not have permission to enter."
		end
	end

	local function CloseGui()
		--Tween(script.Parent.Contents.Background,{"ImageTransparency","BackgroundTransparency"},1)


		script.Parent.Contents.Cover.BackgroundTransparency = 1
		script.Parent.Contents.Cover.Visible = true
		Tween(script.Parent.Contents.Cover,{"BackgroundTransparency"},0,0.2)

		local GUI = game.ReplicatedStorage:WaitForChild("GUI")
		--GUI.Parent = game.StarterGui
		GUI:Clone().Parent = game.Players.LocalPlayer.PlayerGui
		local Cover = GUI:WaitForChild("Cover")
		if Cover then
			Cover.Visible = true
		end
		wait()
		script.Parent:Destroy()
	end

	game.ReplicatedStorage.DataLoadedIn.OnClientEvent:connect(CloseGui)
end

return module
