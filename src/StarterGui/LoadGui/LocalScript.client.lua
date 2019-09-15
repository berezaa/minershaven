local Player = game.Players.LocalPlayer
if Player:FindFirstChild("BaseDataLoaded") then
	script.Parent:Destroy()
else
	local module = require(script.Parent.LoadGuiScript)
	script.Parent.Contents.Visible = true
	module.init()
end