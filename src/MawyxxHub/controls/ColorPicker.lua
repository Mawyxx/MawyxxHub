-- Preset color cycle control (API name addColorPicker kept for compat).

local CreateMod = require(script.Parent.Parent.visual.Create)

local Create = CreateMod.Create
local Stroke = CreateMod.Stroke
local TextLabel = CreateMod.TextLabel

local PRESET_COLORS = {
	Color3.new(1, 1, 1),
	Color3.new(0, 1, 0),
	Color3.new(1, 0, 0),
	Color3.new(0, 0, 1),
	Color3.new(1, 1, 0),
	Color3.new(1, 0, 1),
	Color3.new(0, 1, 1),
	Color3.new(1, 0.5, 0),
}

local function colorNear(a, b)
	return math.abs(a.R - b.R) < 1e-3 and math.abs(a.G - b.G) < 1e-3 and math.abs(a.B - b.B) < 1e-3
end

local ColorPicker = {}

function ColorPicker.build(hub, element)
	local config = hub.config
	local flag = element.flag
	local color = hub.settings[flag]
	if color == nil then
		color = element.default or Color3.new(1, 1, 1)
	end
	hub.deps.settings.Set(hub.settings, flag, color)

	local row = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
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
	})
	Create("UIPadding", {
		Parent = row,
		PaddingRight = UDim.new(0, 2),
	})
	Stroke(swatch, config.colors.border, 1)

	local idx = 1
	for i, c in ipairs(PRESET_COLORS) do
		if colorNear(c, color) then
			idx = i
			break
		end
	end

	local function apply(newColor, fireCallback)
		color = newColor
		hub.deps.settings.Set(hub.settings, flag, newColor)
		swatch.BackgroundColor3 = newColor
		if fireCallback and element.callback then
			element.callback(newColor)
		end
	end

	hub._bindings[flag] = {
		apply = function(v)
			apply(v, false)
		end,
		read = function()
			return color
		end,
	}

	hub._pageMaid:Connect(swatch.MouseButton1Click, function()
		idx = idx % #PRESET_COLORS + 1
		apply(PRESET_COLORS[idx], true)
	end)

	return row
end

return ColorPicker
