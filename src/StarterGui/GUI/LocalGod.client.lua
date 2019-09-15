--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]

script.Parent:WaitForChild("Cover")
script.Parent.Cover.Visible = true

local Modules = {}

wait(0.1)


--print("Hi there!")

script.Parent.Menu.Visible = false

local Libs = {
	game.ReplicatedStorage.MoneyLib,
	game.ReplicatedStorage.LotteryLib,
	game.ReplicatedStorage.TycoonLib,
	game.ReplicatedStorage.HydraulicLib,
	game.ReplicatedStorage.PlacementModule
}


local function AddModule(Ins)
	local Success, Error = pcall(function()
		Modules[Ins.Name] = require(Ins)
	end)
	if not Success then
		warn("Error requiring module "..Ins.Name.."! Module failed to load")
		warn(Error)
	end
end

local function scan(Ins)
	if Ins:IsA("ModuleScript") then
		AddModule(Ins)
	end
	for i,Child in pairs(Ins:GetChildren()) do
		scan(Child)
	end
end

local function Init()
	print("Begin requiring modules")
	local StartTime = tick()
	Modules.HasFinished = false
	scan(script.Parent)
	print("Finished requiring modules ("..tick()-StartTime.."s)")


	--print("Begin requiring libraries")
	for i,Lib in pairs(Libs) do
		local StartTime = tick()
		AddModule(Lib)
		--print("Library "..Lib.Name.." loaded! ("..tick()-StartTime.."s)")
	end

	print("Begin initializing modules")
	StartTime = tick()
	for Name,Module in pairs(Modules) do
		if Module and Module["init"] then
			local strt = tick()
			local Success, Error = pcall(Module.init,Modules) -- Pass a table of all modules to each module
			if Success then
				local del = tick() - strt
				if del > 0.1 then
					print("Module "..Name.." took " .. del .. " sec to init")
				end
				--print("Module "..Name.." initialized successfully.")
			else
				warn("Error initializing "..Name.."!")
				warn(Error)
			end
		end
	end
	Modules.HasFinished = true

	print("Done! ("..tick()-StartTime.."s)")

	print("------------------------------------------------------------")
	print([[NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]])
	print("If you see any errors BELOW THIS POINT, please report them to the dev.")

	print("-----------------------------------------------------------")




	--This is honestly the safest spot for debug code imo. Feel free to suggest otherwise.


	--Notice prompt
	--[[
	spawn(function()
		wait(3)
		print('Prompting the notice')
		Modules.NoticePrompt.giveNotice("Hello! Welcome to Miner's Haven REZ! This is a temporary notice to see if they work yet. Press ok to start!")
		Modules.NoticePrompt.giveNotice("HAH you thought I was going to leave you alone after all? >:)")
	end)
	]]--
end

Init()

local Tween = Modules.Menu.tween
Tween(script.Parent.Cover,{"BackgroundTransparency"},1)
wait(1)
script.Parent.Cover.Visible = false