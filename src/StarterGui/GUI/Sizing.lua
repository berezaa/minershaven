local module = {}

local function iDiv(a,b)
	return math.floor(a/b)
end

function module.resize()
	warn("Sizing.resize() not ready yet.")
end

local Size = 100



function module.init(Modules)


	local function modechange()
		if Modules.Input.mode.Value == "Mobile" then
			Size = 70
			script.Parent.Inventory.Size = UDim2.new(0.6,0,0.7,0)
			script.Parent.Shop.Size = UDim2.new(0.6,0,0.7,0)
		else
			Size = 100
			script.Parent.Inventory.Size = UDim2.new(0.4,0,0.7,0)
			script.Parent.Shop.Size = UDim2.new(0.4,0,0.7,0)
		end
	end
	modechange()
	Modules.Input.mode.Changed:connect(modechange)


	function module.resize()



		local Length = script.Parent.Inventory.Frame.Items.AbsoluteSize.X - 22
		local Collums = iDiv(Length,Size + 10)
		local Extra = Length - (Collums * (Size + 10))
		local Cell = Size + iDiv(Extra,Collums)
		script.Parent.Inventory.Frame.Items.UIGridLayout.CellSize = UDim2.new(0, Cell, 0, Cell)
		script.Parent.Shop.Frame.Items.UIGridLayout.CellSize = UDim2.new(0, Cell, 0, Cell)
		--script.Parent.Boxes.Items.UIGridLayout.CellSize = UDim2.new(0, Cell, 0, Cell)

		local Buttons = script.Parent.Inventory.Frame.Items.Count.Value
		script.Parent.Inventory.Frame.Items.CanvasSize = UDim2.new(0,0,0,10 + (Cell + 10) * math.ceil(Buttons / Collums))
		local xtra = 0
		if script.Parent.Shop.Mode.Value == "New" then
			xtra = 100
		end
		local ShopButtons = script.Parent.Shop.Frame.Items.Count.Value
		script.Parent.Shop.Frame.CanvasSize = UDim2.new(0,0,0,xtra + Size + 20 + (Cell + 10) * math.ceil(ShopButtons/Collums))

		--local BoxButtons = script.Parent.Boxes.Items.Count.Value
		--script.Parent.Boxes.Items.CanvasSize = UDim2.new(0,0,0,130 + (Cell + 10) * math.ceil(BoxButtons/Collums))
	end

	module.resize()
	script.Parent.ScreenSize:GetPropertyChangedSignal("AbsoluteSize"):connect(module.resize)
	Modules.Focus.current.Changed:connect(module.resize)
	script.Parent.Inventory.Frame.Items.Count.Changed:connect(module.resize)
	script.Parent.Shop.Frame.Items.Count.Changed:connect(module.resize)

end

return module
