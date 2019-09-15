

game.ReplicatedStorage.Click.OnServerEvent:connect(function(Player,Target)
	if Target:IsDescendantOf(script.Parent) then
		game.ReplicatedStorage.Boom:FireClient(Player,script.Parent)
		game.ServerStorage.AwardItem:Invoke(Player,500,1)
	end
end)