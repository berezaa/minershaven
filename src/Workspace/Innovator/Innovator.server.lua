



game.ReplicatedStorage.RequestQuest.OnServerEvent:connect(function(Player)
	if not Player.InnoResearchClaimed.Value then
		Player.InnoResearchClaimed.Value = true
		game.ServerStorage.AwardItem:Invoke(Player, 503)
	end
end)

game.ServerStorage.PlayerDataLoaded.Event:connect(function(Player)
	wait(3)
	game.ReplicatedStorage.Splash:FireClient(Player,"InnoStart")
end)

function game.ReplicatedStorage.ClaimEvent.OnServerInvoke(Player, event)
	if event == 1 then

		if Player.InnoEventProgress.Value >= 1000 and not Player.InnoRocketComplete.Value then
			Player.InnoRocketComplete.Value = true

			game.ReplicatedStorage.Splash:FireClient(Player,"InnoEnd")

			game.ServerStorage.AwardBadge:Invoke(Player, 1334714065)
			return true
		end


	elseif event == 2 then
		if Player.InnoElementPending.Value and not Player.InnoElementComplete.Value then
			Player.InnoElementPending.Value = false
			Player.InnoElementComplete.Value = true
			game.ReplicatedStorage.Splash:FireClient(Player,"InnoEnd")

			game.ServerStorage.AwardBadge:Invoke(Player, 1334713630)
			game.ServerStorage.InnovationRobotDog:Clone().Parent = Player.Backpack
			return true
		end
	end
	return false
end