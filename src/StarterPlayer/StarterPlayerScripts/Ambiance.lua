local module = {}

function module.init(Modules)

	local Day = script:WaitForChild("Day")
	local Night = script:WaitForChild("Night")

	game.ContentProvider:PreloadAsync(script:GetChildren())

	local function Tween(Object, Properties, Value, Time, Style)
		Style = Style or Enum.EasingStyle.Quad

		Time = Time or 0.5

		local propertyGoals = {}

		local Table = (type(Value) == "table" and true) or false

		for i,Property in pairs(Properties) do
			propertyGoals[Property] = Table and Value[i] or Value
		end
		local tweenInfo = TweenInfo.new(
			Time,
			Style,
			Enum.EasingDirection.Out
		)
		local tween = game:GetService("TweenService"):Create(Object,tweenInfo,propertyGoals)
		tween:Play()
	end


	local Music = workspace.CurrentCamera:FindFirstChild("Music")

	if game.Lighting:FindFirstChild("Blur") then
		game.Lighting.Blur.Size = 0
	end


	if Music == nil then
		Music = Instance.new("Sound")
		Music.Name = "Music"
		Music.Parent = workspace.CurrentCamera
		Music.Looped = true
		local Tag = Instance.new("NumberValue")
		Tag.Name = "PlayerVolume"
		Tag.Value = 0.07 -- todo: change
		Tag.Parent = Music
	end

	local autochange = true

	local function setTrack(song, override)
		if Music.SoundId ~= song and (autochange or override) then
			if override then
				autochange = false
			end
			spawn(function()
				if Music.IsPlaying then
					Tween(Music,{"Volume","PlaybackSpeed"},{0,0.7},1.2)
					wait(1)
					Music:Stop()
				end
				wait()
				Music.SoundId = song
				Music.Volume = 0
				Music.PlaybackSpeed = 0.7
				wait()
				Music:Play()
				Tween(Music,{"Volume","PlaybackSpeed"},{Music.PlayerVolume.Value,1},1)
			end)
		end
	end


	local function Apply()

		if game.ReplicatedStorage.NightTime.Value then
			--setTrack("rbxassetid://1032898519")
			setTrack(Night.SoundId)
			Tween(game.Lighting,{
				"FogColor",
				"FogEnd",
				"Ambient",
				"Brightness",
				"OutdoorAmbient"
			},
			{
				Color3.new(0.0,0,0.07),
				600,
				Color3.new(0.09,0.09,0.11),
				0.3,
				Color3.new(0.25,0.25,0.3)
			},4)
		else
			--setTrack("rbxassetid://1150924713")
		    --setTrack("rbxassetid://1032898031")
			setTrack(Day.SoundId)
			Tween(game.Lighting,{
				"FogColor",
				"FogEnd",
				"Ambient",
				"Brightness",
				"OutdoorAmbient"
			},
			{
				Color3.fromRGB(174, 240, 235),
				1000,
				Color3.fromRGB(67,67,67),
				1,
				Color3.fromRGB(140,140,140)
			},4)
		end
	end

	local function reset()
		autochange = true
		Apply()
	end

	local connection


	local function arguecustom()
		if connection then
			connection:disconnect()
		end
		local Tycoon = game.Players.LocalPlayer.NearTycoon.Value
		if Tycoon and Tycoon:FindFirstChild("SpecialMusic") then

			local function set()
				setTrack("rbxassetid://"..Tycoon.SpecialMusic.Value,true)
			end
			if Tycoon.SpecialMusic.Value == 0 then
				reset()
			else
				set()
			end
			connection = Tycoon.SpecialMusic.Changed:connect(set)


		else
			reset()
		end
	end
	spawn(function()
		game.Players.LocalPlayer:WaitForChild("NearTycoon")
		game.Players.LocalPlayer.NearTycoon.Changed:connect(arguecustom)
		arguecustom()
	end)


	game.ReplicatedStorage.NightTime.Changed:connect(function()
		if game.ReplicatedStorage.NightTime.Value then
			if Music.PlayerVolume.Value > 0 then
				script.WolfHowl:Play()
			end
		else
			if Music.PlayerVolume.Value > 0 then
				script.Rooster:Play()
			end
		end
		Apply()
	end)

	Apply()

	local function Adjust()
		if Music.PlayerVolume.Value ~= Music.Volume then
			local PitchGoal = 0.7
			if Music.PlayerVolume.Value > 0 then
				PitchGoal = 1
			end
			if Music.Volume == 0 then
				Music.PlaybackSpeed = 0.7
			end
			Tween(Music,{"Volume","PlaybackSpeed"},{Music.PlayerVolume.Value,PitchGoal},1.2)
		end
	end

	Adjust()
	Music.PlayerVolume.Changed:connect(Adjust)


	--print("HI")

	workspace.CurrentCamera.FieldOfView = 70


end

return module

