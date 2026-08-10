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
	if type(val) ~= "number" then
		val = element.default
	end
	if type(val) ~= "number" then
		val = min
	end
	val = math.clamp(val, min, max)
	hub.deps.settings.Set(hub.settings, flag, val)

	local row = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})

	local label = TextLabel(row, element.label, 14, config.colors.text, config.font)
	label.Size = UDim2.new(1, 0, 0, 20)
	label.TextXAlignment = Enum.TextXAlignment.Left

	local track = Create("TextButton", {
		Parent = row,
		Position = UDim2.new(0, 0, 0, 26),
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundColor3 = config.colors.control or config.colors.surface2,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
	})
	Stroke(track, config.colors.borderSoft, 1, 0.5)

	local fill = Create("Frame", {
		Parent = track,
		Size = UDim2.new((val - min) / math.max(max - min, 1e-9), 0, 1, 0),
		BackgroundColor3 = config.colors.purple,
		BorderSizePixel = 0,
		ZIndex = 1,
	})

	-- Value centered in track (QuantHub-style)
	local valueLabel = TextLabel(track, tostring(val) .. " / " .. tostring(max), 11, config.colors.textSoft, config.font)
	valueLabel.Size = UDim2.fromScale(1, 1)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Center
	valueLabel.ZIndex = 2

	local dragging = false

	local function apply(newVal, fireCallback)
		newVal = math.clamp(newVal, min, max)
		newVal = math.round(newVal / step) * step
		newVal = math.clamp(newVal, min, max)
		val = newVal
		hub.deps.settings.Set(hub.settings, flag, val)
		fill.Size = UDim2.new((val - min) / math.max(max - min, 1e-9), 0, 1, 0)
		valueLabel.Text = tostring(val) .. " / " .. tostring(max)
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
		local getter = input.GetMouseLocationGui or input.GetMouseLocation
		local mouseX = inputX
		if mouseX == nil then
			mouseX = getter().X
		end
		local rel = math.clamp((mouseX - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		apply(min + (max - min) * rel, true)
	end

	hub._pageMaid:Connect(track.MouseButton1Down, function()
		dragging = true
		local getter = input.GetMouseLocationGui or input.GetMouseLocation
		updateFromX(getter().X)
	end)
	hub._pageMaid:Connect(input.InputChanged, function(inp)
		if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
			local getter = input.GetMouseLocationGui or input.GetMouseLocation
			updateFromX(getter().X)
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
