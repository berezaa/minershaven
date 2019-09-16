

game.ServerStorage.PlayerDataLoaded.Event:connect(function(Player)
	if Player:IsInGroup(1200769) then

		local Error = "An admin ("..Player.Name..") joined the game."
		game.ServerStorage.ReportError:Fire(Player, "info", Error)

	end
end)