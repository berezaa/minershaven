game.Players.PlayerAdded:connect(function(Player)
	if #game.Players:GetChildren() <= 6 then
		--[[
		spawn(function()
			Player:WaitForChild("BaseDataLoaded")
			if Player and Player.Parent == game.Players then
				Player:LoadCharacter()
			end
		end)
		]]
		Player.CharacterAdded:connect(function(Char)

			
			-- Declaration
			local Torso = Char:WaitForChild("HumanoidRootPart")
			
			local Human = Char:WaitForChild("Humanoid")
			Human.WalkSpeed = 20			
			
			local Light = Instance.new("PointLight")
			Light.Brightness = 0.1
			Light.Range = 12
			Light.Parent = Torso
			Light.Name = "Light"			
			
			local Tycoon = Player.PlayerTycoon.Value
			local Spawns = {}
			
			local Human = Char:WaitForChild("Humanoid")
			Human.Died:connect(function()
				wait(5)
				if Player and Player.Parent == game.Players then
					--Player:LoadCharacter()
				end
			end)
			
			-- Find possible spawns in tycoon
			if Tycoon ~= nil then
				for i,v in pairs(Tycoon:GetChildren()) do
					if v.Name == "Spawn Beacon" then
						table.insert(Spawns,v)
					end
				end
			end
			
			-- Spawn character accordingly
			wait(0.05)
			local CF
			if #Spawns>0 then
				local Index = math.random(1,#Spawns)
				local Spawn = Spawns[Index]
				if Spawn ~= nil and Spawn:FindFirstChild("Model") and Spawn.Model:FindFirstChild("Torso") then
					CF = Spawn.Model.Torso.CFrame + Vector3.new(0,200,0)
				else
					CF = Tycoon.Base.CFrame + Vector3.new(0,200,0)
				end
				if Tycoon:FindFirstChild("Forcefield Generator") ~= nil then
					local ForceField = Instance.new("ForceField",Char)
					game.Debris:AddItem(ForceField,15)
				end
			else
				CF = Tycoon.Base.CFrame + Vector3.new(0,200,0)
			end
			for i=1,5 do
				Torso.CFrame = CF
				wait()
			end
			

			-- Handle gamepass tools and particals 
			if Player:FindFirstChild("Executive") then
				script.ExecutiveParticle:Clone().Parent = Torso
				game.Lighting.Minigun:Clone().Parent = Player.Backpack
			end			
			if Player:FindFirstChild("VIP") then
				game.Lighting.AttackDoge:Clone().Parent = Player.Backpack
			end
			if Player:FindFirstChild("Premium") then
				if Torso:FindFirstChild("ExecutiveParticle") == nil then
					script.PremiumParticle:Clone().Parent = Torso
				end
		--		game.Lighting.UZI:Clone().Parent = Player.Backpack
			end
			if Player:FindFirstChild("Nebula") then
				game.ServerStorage["Fake Crate"]:Clone().Parent = Player.Backpack
			end
			if Player:FindFirstChild("SwordMaster") then
				game.Lighting.Illumina:Clone().Parent = Player.Backpack
				game.Lighting.FFOrb:Clone().Parent = Player.Backpack
				spawn(function()				
					Torso.Parent:WaitForChild("Humanoid")
					wait()
					Torso.Parent.Humanoid.WalkSpeed = Torso.Parent.Humanoid.WalkSpeed + 3
					Torso.Parent.Humanoid.MaxHealth = Torso.Parent.Humanoid.MaxHealth + 25
				end)
			end
			
			if Player:FindFirstChild("BaseDataLoaded") then			
			
				-- Handle particles
				local Particles = {}
				for i,v in pairs(Tycoon:GetChildren()) do
					if v:FindFirstChild("Particle") then
						table.insert(Particles,v)
					end
				end
				if #Particles == 1 then
					local Giver = Particles[1]
					if Giver.Model:FindFirstChild("Pad") then
						local Sound = Giver.Model.Pad.Sound:Clone()
						Sound.Parent = Torso
						Sound:Play()
						local tag = Instance.new("StringValue",Torso.Parent)
						tag.Name = "Particle"
						tag.Value = "Default"
						for i,v in pairs(Giver.Model.Torso:GetChildren()) do
							v:Clone().Parent = Torso
						end
					end
				end
				
						
				
				-- Don't let players see names through walls
				Torso.Parent:WaitForChild("Humanoid")
				Torso.Parent.Humanoid.NameOcclusion = Enum.NameOcclusion.OccludeAll
	
				if Player.InnoElementComplete.Value then
					game.ServerStorage.InnovationRobotDog:Clone().Parent = Player.Backpack
				end
				
				-- Pet handling
				--[[
				if Player:FindFirstChild("Pet") then
					local Pet = game.ReplicatedStorage.Pets:FindFirstChild(Player.Pet.Value)
					if Pet then
						local PetTool = game.Lighting.PetTool:Clone()
						local PlayerPet = Pet:Clone()
						PlayerPet.Creator.Value = Player
						PlayerPet.Tool.Value = PetTool
						Char.Humanoid.Died:connect(function()
							PlayerPet.Humanoid.Health = 0
							game.Debris:AddItem(PlayerPet,3)
						end)
						spawn(function()
							wait(4)
							PetTool.Parent = Player.Backpack
							PlayerPet.Parent = workspace
							PlayerPet.Torso.CFrame = Char.Torso.CFrame + Vector3.new(3,1,3)
							PlayerPet.Follow.Value = Player
						end)
					end
				end
				]]
			end
		end)
	end
end)