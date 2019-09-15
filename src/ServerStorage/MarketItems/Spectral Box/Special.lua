-- Award the player a spectral box
return function(Player)
	Player.Crates.Spectral.Value = Player.Crates.Spectral.Value + 1
	local Box = game.ReplicatedStorage.Boxes.Spectral
	game.ReplicatedStorage.CurrencyPopup:FireClient(Player,Box.Name.." Box",Box.BoxColor.Value,"rbxassetid://"..Box.ThumbnailId.Value)
end