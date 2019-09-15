while true do
	for i=1,50 do
		wait()
		script.Parent.Frame.BackgroundColor3 = Color3.new(i/50,0,0)
	end
	for i=50,0,-1 do
		wait()
		script.Parent.Frame.BackgroundColor3 = Color3.new(i/50,0,0)
	end
end