local module = {}

function module.init(Modules)


	local function color()
		local cr = tonumber(script.Parent.Color.r.Text) or script.Parent.Color.BackgroundColor3.r * 255
		local cg = tonumber(script.Parent.Color.g.Text) or script.Parent.Color.BackgroundColor3.g * 255
		local cb = tonumber(script.Parent.Color.b.Text) or script.Parent.Color.BackgroundColor3.b * 255
		script.Parent.Color.BackgroundColor3 = Color3.fromRGB(cr,cg,cb)
		script.Parent.Sample.TextColor3 = Color3.fromRGB(cr,cg,cb)
		local sr = tonumber(script.Parent.StrokeColor.r.Text) or script.Parent.StrokeColor.BackgroundColor3.r * 255
		local sg = tonumber(script.Parent.StrokeColor.g.Text) or script.Parent.StrokeColor.BackgroundColor3.g * 255
		local sb = tonumber(script.Parent.StrokeColor.b.Text) or script.Parent.StrokeColor.BackgroundColor3.b * 255
		script.Parent.StrokeColor.BackgroundColor3 = Color3.fromRGB(sr,sg,sb)
		script.Parent.Sample.TextStrokeColor3 = Color3.fromRGB(sr,sg,sb)
	end

	color()
	script.Parent.Color.r.Changed:connect(color)
	script.Parent.Color.g.Changed:connect(color)
	script.Parent.Color.b.Changed:connect(color)
	script.Parent.StrokeColor.r.Changed:connect(color)
	script.Parent.StrokeColor.g.Changed:connect(color)
	script.Parent.StrokeColor.b.Changed:connect(color)

end

return module
