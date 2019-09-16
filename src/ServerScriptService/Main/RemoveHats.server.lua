game.Workspace.ChildAdded:connect(function(obj)		-- Track new items added to the workspace
	if (obj:IsA("Hat")) then								-- Check to see if the object is a hat
		wait(4)												-- Give the player a chance to put the hat back on
		if (obj.Parent == game.Workspace) then			-- If hat is still just lying around, remove it
			obj:Destroy()
		end
	end
end)

function scan(obj)
	wait()
	if obj:IsA("BasePart") then
		obj.Locked = true
	elseif obj:IsA("Model") then
		for i,v in pairs(obj:GetChildren()) do
			scan(v)
		end
	end
end

for i,v in pairs(workspace:GetChildren()) do
	scan(v)
end