local OrderedDataStore = game:GetService("DataStoreService"):GetOrderedDataStore("highestLife")

game.Players.PlayerRemoving:connect(function(Player)
	if Player:FindFirstChild("SecondSacrifice") and Player:FindFirstChild("Rebirths") then
		OrderedDataStore:SetAsync(Player.userId, Player.Rebirths.Value + 1)
	end
end)