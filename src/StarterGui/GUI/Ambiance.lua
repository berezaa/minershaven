local module = {}

function module.init(Modules)

	local Tween = Modules.Menu.tween

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





	local function Adjust()

		if Music.PlayerVolume.Value == 0 then
			script.Parent.Mute.Image = "rbxassetid://287301561"
		else
			script.Parent.Mute.Image = "rbxassetid://287301550"
		end
	end

	Adjust()
	Music.PlayerVolume.Changed:connect(Adjust)

	script.Parent.Mute.MouseButton1Click:connect(function()
		if Music.PlayerVolume.Value == 0 then
			Music.PlayerVolume.Value = 0.1
		else
			Music.PlayerVolume.Value = 0
		end
	end)

	--print("HI")

	workspace.CurrentCamera.FieldOfView = 70


end

return module
