local CreateMod = require(script.Parent.Parent.visual.Create)

local Create = CreateMod.Create
local Stroke = CreateMod.Stroke
local Padding = CreateMod.Padding
local TextLabel = CreateMod.TextLabel

local Dropdown = {}

function Dropdown.build(hub, element)
	local config = hub.config
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

	local btn = Create("TextButton", {
		Parent = row,
		Position = UDim2.new(0, 0, 0, 20),
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = config.colors.surface,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 21,
	})
	Stroke(btn, config.colors.borderSoft, 1)

	local currentText = TextLabel(btn, tostring(selected), 14, config.colors.text, config.font)
	currentText.Position = UDim2.new(0, 9, 0, 0)
	currentText.Size = UDim2.new(1, -35, 1, 0)

	local arrow = TextLabel(btn, "⌄", 15, config.colors.textSoft, config.font)
	arrow.Position = UDim2.new(1, -25, 0, 0)
	arrow.Size = UDim2.new(0, 20, 1, 0)
	arrow.TextXAlignment = Enum.TextXAlignment.Center

	local open = false
	local list = Create("Frame", {
		Name = "DropdownList",
		Parent = hub.overlay,
		Size = UDim2.new(0, 100, 0, #options * 27),
		BackgroundColor3 = config.colors.surface,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 250,
	})
	Stroke(list, config.colors.border, 1)
	hub._pageMaid:Give(list)

	Create("UIListLayout", {
		Parent = list,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local function apply(opt, fireCallback)
		selected = opt
		hub.deps.settings.Set(hub.settings, flag, opt)
		currentText.Text = tostring(opt)
		open = false
		list.Visible = false
		arrow.Text = "⌄"
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
			Size = UDim2.new(1, 0, 0, 27),
			BackgroundColor3 = config.colors.surface,
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
				BackgroundColor3 = config.colors.surfaceHover,
				TextColor3 = config.colors.text,
			})
		end)
		hub._pageMaid:Connect(optBtn.MouseLeave, function()
			hub:tween(optBtn, {
				BackgroundColor3 = config.colors.surface,
				TextColor3 = config.colors.textSoft,
			})
		end)
		hub._pageMaid:Connect(optBtn.MouseButton1Click, function()
			apply(opt, true)
		end)
	end

	local function reposition()
		local pos = btn.AbsolutePosition
		local size = btn.AbsoluteSize
		local parentPos = hub.overlay.AbsolutePosition
		list.Position = UDim2.fromOffset(pos.X - parentPos.X, pos.Y - parentPos.Y + size.Y + 2)
		list.Size = UDim2.fromOffset(size.X, #options * 27)
	end

	hub._pageMaid:Connect(btn.MouseButton1Click, function()
		open = not open
		if open then
			reposition()
		end
		list.Visible = open
		arrow.Text = open and "⌃" or "⌄"
	end)

	return row
end

return Dropdown
