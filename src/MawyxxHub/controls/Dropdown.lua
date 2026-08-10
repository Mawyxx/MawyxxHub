local CreateMod = require(script.Parent.Parent.visual.Create)

local Create = CreateMod.Create
local Stroke = CreateMod.Stroke
local Padding = CreateMod.Padding
local TextLabel = CreateMod.TextLabel

local Dropdown = {}

function Dropdown.build(hub, element)
	local config = hub.config
	local input = hub.deps.input
	local flag = element.flag
	local options = element.options or {}
	local selected = hub.settings[flag]
	if selected == nil then
		selected = element.default or options[1] or ""
	end
	hub.deps.settings.Set(hub.settings, flag, selected)

	local row = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 20,
	})

	local label = TextLabel(row, element.label, 13, config.colors.textSoft, config.font)
	label.Size = UDim2.new(1, 0, 0, 18)
	label.TextXAlignment = Enum.TextXAlignment.Left

	local control = config.colors.control or config.colors.surface2
	local controlHover = config.colors.controlHover or config.colors.surfaceHover

	local btn = Create("TextButton", {
		Parent = row,
		Position = UDim2.new(0, 0, 0, 20),
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = control,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 21,
	})
	Stroke(btn, config.colors.borderSoft, 1, 0.45)

	local currentText = TextLabel(btn, tostring(selected), 14, config.colors.text, config.font)
	currentText.Position = UDim2.new(0, 9, 0, 0)
	currentText.Size = UDim2.new(1, -35, 1, 0)

	local arrow = TextLabel(btn, "v", 14, config.colors.textSoft, config.font)
	arrow.Position = UDim2.new(1, -25, 0, 0)
	arrow.Size = UDim2.new(0, 20, 1, 0)
	arrow.TextXAlignment = Enum.TextXAlignment.Center

	local open = false
	local maxVisible = 8
	local rowH = 27
	local listH = math.min(#options, maxVisible) * rowH
	local list = Create("ScrollingFrame", {
		Name = "DropdownList",
		Parent = hub.overlay,
		Size = UDim2.new(0, 100, 0, listH),
		BackgroundColor3 = control,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 250,
		ScrollBarThickness = 3,
		CanvasSize = UDim2.new(0, 0, 0, #options * rowH),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ClipsDescendants = true,
	})
	Stroke(list, config.colors.border, 1)
	hub._pageMaid:Give(list)

	Create("UIListLayout", {
		Parent = list,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local function closeList()
		open = false
		list.Visible = false
		arrow.Text = "⌄"
	end

	local function apply(opt, fireCallback)
		selected = opt
		hub.deps.settings.Set(hub.settings, flag, opt)
		currentText.Text = tostring(opt)
		closeList()
		if fireCallback and element.callback then
			element.callback(opt)
		end
	end

	hub._bindings[flag] = {
		apply = function(v)
			apply(v, false)
		end,
		read = function()
			return selected
		end,
	}

	for _, opt in ipairs(options) do
		local optBtn = Create("TextButton", {
			Parent = list,
			Size = UDim2.new(1, 0, 0, rowH),
			BackgroundColor3 = control,
			BorderSizePixel = 0,
			Text = tostring(opt),
			TextColor3 = config.colors.textSoft,
			TextSize = 13,
			Font = config.font,
			AutoButtonColor = false,
			ZIndex = 251,
		})
		optBtn.TextXAlignment = Enum.TextXAlignment.Left
		Padding(optBtn, 9, 5, 0, 0)
		hub._pageMaid:Connect(optBtn.MouseEnter, function()
			hub:tween(optBtn, {
				BackgroundColor3 = controlHover,
				TextColor3 = config.colors.text,
			})
		end)
		hub._pageMaid:Connect(optBtn.MouseLeave, function()
			hub:tween(optBtn, {
				BackgroundColor3 = control,
				TextColor3 = config.colors.textSoft,
			})
		end)
		hub._pageMaid:Connect(optBtn.MouseButton1Click, function()
			apply(opt, true)
		end)
	end

	local function reposition()
		if not open then
			return
		end
		local pos = btn.AbsolutePosition
		local size = btn.AbsoluteSize
		local parentPos = hub.overlay.AbsolutePosition
		list.Position = UDim2.fromOffset(pos.X - parentPos.X, pos.Y - parentPos.Y + size.Y + 2)
		list.Size = UDim2.fromOffset(size.X, listH)
	end

	hub._pageMaid:Connect(btn:GetPropertyChangedSignal("AbsolutePosition"), reposition)
	hub._pageMaid:Connect(btn:GetPropertyChangedSignal("AbsoluteSize"), reposition)
	if hub.window then
		hub._pageMaid:Connect(hub.window:GetPropertyChangedSignal("AbsoluteSize"), reposition)
	end

	hub._pageMaid:Connect(btn.MouseButton1Click, function()
		open = not open
		if open then
			reposition()
			list.Visible = true
			arrow.Text = "⌃"
		else
			closeList()
		end
	end)

	-- Click outside closes list
	hub._pageMaid:Connect(input.InputBegan, function(inp)
		if not open then
			return
		end
		if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end
		local getter = input.GetMouseLocationGui or input.GetMouseLocation
		local m = getter()
		local lp = list.AbsolutePosition
		local ls = list.AbsoluteSize
		local bp = btn.AbsolutePosition
		local bs = btn.AbsoluteSize
		local inList = m.X >= lp.X and m.X <= lp.X + ls.X and m.Y >= lp.Y and m.Y <= lp.Y + ls.Y
		local inBtn = m.X >= bp.X and m.X <= bp.X + bs.X and m.Y >= bp.Y and m.Y <= bp.Y + bs.Y
		if not inList and not inBtn then
			closeList()
		end
	end)

	return row
end

return Dropdown
