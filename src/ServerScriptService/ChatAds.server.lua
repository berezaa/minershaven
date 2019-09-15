while wait(120) do
	game.ReplicatedStorage.SystemAlert:FireAllClients("Stay informed: follow twitter.com/berezaagames for news and codes.",
		Color3.new(0,1,1),Color3.new(0,0,0),Color3.new(0,0,0.3))
	wait(120)
	game.ReplicatedStorage.SystemAlert:FireAllClients("Want to see how this game is made? Follow twitch.tv/bereza for dev streams!",
		Color3.new(1,0.5,0),Color3.new(0,0,0),Color3.new(0.3,0.2,0))
	wait(120)
	game.ReplicatedStorage.SystemAlert:FireAllClients("Get free crystals and boxes in your daily gifts when you join Berezaa Games.",
		Color3.new(1,0.5,0.9),Color3.new(0,0,0),Color3.new(0.25,0,0.2))
	wait(120)
	game.ReplicatedStorage.SystemAlert:FireAllClients("Follow the dev on twitch.tv/bereza to see how the game is made!",
		Color3.new(0,1,0.8),Color3.new(0,0,0),Color3.new(0.2,0,0))

end