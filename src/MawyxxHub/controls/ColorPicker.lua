-- Color picker: click swatch → mini palette → OK / Cancel.

local CreateMod = require(script.Parent.Parent.visual.Create)

local Create = CreateMod.Create
local Stroke = CreateMod.Stroke
local Corner = CreateMod.Corner

local PALETTE = {
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(200, 200, 205),
	Color3.fromRGB(120, 120, 128),
	Color3.fromRGB(40, 40, 44),
	Color3.fromRGB(0, 0, 0),
	Color3.fromRGB(255, 70, 70),
	Color3.fromRGB(255, 120, 50),
	Color3.fromRGB(255, 210, 60),
	Color3.fromRGB(100, 220, 90),
	Color3.fromRGB(60, 200, 160),
	Color3.fromRGB(70, 170, 255),
	Color3.fromRGB(117, 72, 255),
	Color3.fromRGB(180, 90, 255),
	Color3.fromRGB(255, 90, 180),
	Color3.fromRGB(160, 100, 60),
	Color3.fromRGB(90, 200, 255),
}

local COLS = 4
local CELL = 28
local GAP = 6
local PANEL_PAD = 10
local BTN_H = 28

local function colorNear(a, b)
	return math.abs(a.R - b.R) < 1e-3 and math.abs(a.G - b.G) < 1e-3 and math.abs(a.B - b.B) < 1e-3
end

local ColorPicker = {}

function ColorPicker.build(hub, element)
	local config = hub.config
	local flag = element.flag
	local color = hub.settings[flag]
	if color == nil then
		color = element.default or Color3.fromRGB(117, 72, 255)
	end
	hub.deps.settings.Set(hub.settings, flag, color)

	local row = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})
	Create("UIPadding", {
		Parent = row,
		PaddingRight = UDim.new(0, 4),
	})

	local label = TextLabel(row, element.label, 14, config.colors.text, config.font)
	label.Size = UDim2.new(0.65, 0, 1, 0)
	label.TextXAlignment = Enum.TextXAlignment.Left

	local swatch = Create("TextButton", {
		Parent = row,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 26, 0, 22),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 22,
	})
	Stroke(swatch, config.colors.border, 1)
	Corner(swatch, 3)

	local gridRows = math.ceil(#PALETTE / COLS)
	local gridW = COLS * CELL + (COLS - 1) * GAP
	local gridH = gridRows * CELL + (gridRows - 1) * GAP
	local panelW = gridW + PANEL_PAD * 2
	local panelH = PANEL_PAD + gridH + 8 + 22 + 8 + BTN_H + PANEL_PAD

	local panel = Create("Frame", {
		Name = "ColorPalette",
		Parent = hub.overlay,
		Size = UDim2.fromOffset(panelW, panelH),
		BackgroundColor3 = config.colors.surface,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 260,
	})
	Stroke(panel, config.colors.border, 1)
	Corner(panel, 6)
	hub._pageMaid:Give(panel)

	local grid = Create("Frame", {
		Parent = panel,
		Position = UDim2.fromOffset(PANEL_PAD, PANEL_PAD),
		Size = UDim2.fromOffset(gridW, gridH),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 261,
	})

	local pending = color
	local open = false
	local committed = color
	local cellButtons = {}

	local preview = Create("Frame", {
		Parent = panel,
		Position = UDim2.fromOffset(PANEL_PAD, PANEL_PAD + gridH + 8),
		Size = UDim2.fromOffset(gridW, 22),
		BackgroundColor3 = pending,
		BorderSizePixel = 0,
		ZIndex = 261,
	})
	Stroke(preview, config.colors.borderSoft, 1)
	Corner(preview, 3)

	local function refreshSelection()
		preview.BackgroundColor3 = pending
		for _, data in ipairs(cellButtons) do
			local selected = colorNear(data.color, pending)
			data.stroke.Color = selected and config.colors.purple or config.colors.borderSoft
			data.stroke.Thickness = selected and 2 or 1
		end
	end

	for i, c in ipairs(PALETTE) do
		local col = ((i - 1) % COLS)
		local r = math.floor((i - 1) / COLS)
		local cell = Create("TextButton", {
			Parent = grid,
			Position = UDim2.fromOffset(col * (CELL + GAP), r * (CELL + GAP)),
			Size = UDim2.fromOffset(CELL, CELL),
			BackgroundColor3 = c,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 262,
		})
		Corner(cell, 4)
		local cellStroke = Stroke(cell, config.colors.borderSoft, 1)
		table.insert(cellButtons, { color = c, stroke = cellStroke, btn = cell })
		hub._pageMaid:Connect(cell.MouseButton1Click, function()
			pending = c
			refreshSelection()
		end)
	end

	local btnY = PANEL_PAD + gridH + 8 + 22 + 8
	local btnW = math.floor((gridW - GAP) / 2)

	local cancelBtn = Create("TextButton", {
		Parent = panel,
		Position = UDim2.fromOffset(PANEL_PAD, btnY),
		Size = UDim2.fromOffset(btnW, BTN_H),
		BackgroundColor3 = config.colors.surface2,
		BorderSizePixel = 0,
		Text = "Cancel",
		TextColor3 = config.colors.textSoft,
		TextSize = 13,
		Font = config.font,
		AutoButtonColor = false,
		ZIndex = 262,
	})
	Stroke(cancelBtn, config.colors.borderSoft, 1)
	Corner(cancelBtn, 4)

	local okBtn = Create("TextButton", {
		Parent = panel,
		Position = UDim2.fromOffset(PANEL_PAD + btnW + GAP, btnY),
		Size = UDim2.fromOffset(btnW, BTN_H),
		BackgroundColor3 = config.colors.purpleDark,
		BorderSizePixel = 0,
		Text = "OK",
		TextColor3 = config.colors.white,
		TextSize = 13,
		Font = config.font,
		AutoButtonColor = false,
		ZIndex = 262,
	})
	Stroke(okBtn, config.colors.purple, 1)
	Corner(okBtn, 4)

	local function apply(newColor, fireCallback)
		color = newColor
		committed = newColor
		hub.deps.settings.Set(hub.settings, flag, newColor)
		swatch.BackgroundColor3 = newColor
		if fireCallback and element.callback then
			element.callback(newColor)
		end
	end

	local function closePanel()
		open = false
		panel.Visible = false
	end

	local function openPanel()
		pending = committed
		refreshSelection()
		local pos = swatch.AbsolutePosition
		local size = swatch.AbsoluteSize
		local parentPos = hub.overlay.AbsolutePosition
		local parentSize = hub.overlay.AbsoluteSize

		local x = pos.X - parentPos.X + size.X - panelW
		local y = pos.Y - parentPos.Y + size.Y + 6
		if x < 8 then
			x = 8
		end
		if x + panelW > parentSize.X - 8 then
			x = math.max(8, parentSize.X - panelW - 8)
		end
		if y + panelH > parentSize.Y - 8 then
			y = pos.Y - parentPos.Y - panelH - 6
		end

		panel.Position = UDim2.fromOffset(x, y)
		panel.Visible = true
		open = true
	end

	hub._bindings[flag] = {
		apply = function(v)
			apply(v, false)
			pending = v
			committed = v
			refreshSelection()
		end,
		read = function()
			return color
		end,
	}

	hub._pageMaid:Connect(swatch.MouseButton1Click, function()
		if open then
			pending = committed
			closePanel()
		else
			openPanel()
		end
	end)

	hub._pageMaid:Connect(cancelBtn.MouseButton1Click, function()
		pending = committed
		refreshSelection()
		closePanel()
	end)

	hub._pageMaid:Connect(okBtn.MouseButton1Click, function()
		apply(pending, true)
		closePanel()
	end)

	hub._pageMaid:Connect(cancelBtn.MouseEnter, function()
		hub:tween(cancelBtn, { BackgroundColor3 = config.colors.surfaceHover })
	end)
	hub._pageMaid:Connect(cancelBtn.MouseLeave, function()
		hub:tween(cancelBtn, { BackgroundColor3 = config.colors.surface2 })
	end)
	hub._pageMaid:Connect(okBtn.MouseEnter, function()
		hub:tween(okBtn, { BackgroundColor3 = config.colors.purple })
	end)
	hub._pageMaid:Connect(okBtn.MouseLeave, function()
		hub:tween(okBtn, { BackgroundColor3 = config.colors.purpleDark })
	end)

	refreshSelection()
	return row
end

return ColorPicker
