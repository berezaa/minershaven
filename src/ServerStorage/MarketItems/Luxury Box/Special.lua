-- Award the player a spectral box
return function(Player)
	Player.Crates.Luxury.Value = Player.Crates.Luxury.Value + 1
	local Box = game.ReplicatedStorage.Boxes.Luxury
	game.ReplicatedStorage.CurrencyPopup:FireClient(Player,Box.Name.." Box",Box.BoxColor.Value,"rbxassetid://"..Box.ThumbnailId.Value)
end