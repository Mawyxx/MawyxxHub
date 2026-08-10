local CreateMod = require(script.Parent.Parent.visual.Create)

local Create = CreateMod.Create
local Stroke = CreateMod.Stroke
local TextLabel = CreateMod.TextLabel

local Slider = {}

function Slider.build(hub, element)
	local config = hub.config
	local input = hub.deps.input
	local flag = element.flag
	local min = element.min or 0
	local max = element.max or 100
	local step = element.step or 1
	local val = hub.settings[flag]
	if val == nil then
		val = element.default or min
	end
	hub.deps.settings.Set(hub.settings, flag, val)

	local row = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})

	local label = TextLabel(row, element.label, 14, config.colors.text, config.font)
	label.Size = UDim2.new(0.5, 0, 0, 22)
	label.TextXAlignment = Enum.TextXAlignment.Left

	local valueLabel = TextLabel(row, tostring(val) .. "/" .. tostring(max), 13, config.colors.textSoft, config.font)
	valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
	valueLabel.Size = UDim2.new(0.5, -2, 0, 22)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.TextTruncate = Enum.TextTruncate.AtEnd

	local track = Create("TextButton", {
		Parent = row,
		Position = UDim2.new(0, 0, 0, 28),
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundColor3 = config.colors.surface2,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
	})
	Stroke(track, config.colors.borderSoft, 1)

	local fill = Create("Frame", {
		Parent = track,
		Size = UDim2.new((val - min) / math.max(max - min, 1e-9), 0, 1, 0),
		BackgroundColor3 = config.colors.purple,
		BorderSizePixel = 0,
	})

	local dragging = false

	local function apply(newVal, fireCallback)
		newVal = math.clamp(newVal, min, max)
		newVal = math.round(newVal / step) * step
		newVal = math.clamp(newVal, min, max)
		val = newVal
		hub.deps.settings.Set(hub.settings, flag, val)
		fill.Size = UDim2.new((val - min) / math.max(max - min, 1e-9), 0, 1, 0)
		valueLabel.Text = tostring(val) .. "/" .. tostring(max)
		if fireCallback and element.callback then
			element.callback(val)
		end
	end

	hub._bindings[flag] = {
		apply = function(v)
			apply(v, false)
		end,
		read = function()
			return val
		end,
	}

	local function updateFromX(inputX)
		local rel = math.clamp((inputX - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		apply(min + (max - min) * rel, true)
	end

	hub._pageMaid:Connect(track.MouseButton1Down, function()
		dragging = true
		updateFromX(input.GetMouseLocation().X)
	end)
	hub._pageMaid:Connect(input.InputChanged, function(inp)
		if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
			updateFromX(inp.Position.X)
		end
	end)
	hub._pageMaid:Connect(input.InputEnded, function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	return row
end

return Slider
