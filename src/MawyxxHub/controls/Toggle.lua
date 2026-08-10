local CreateMod = require(script.Parent.Parent.visual.Create)

local Create = CreateMod.Create
local Corner = CreateMod.Corner
local Stroke = CreateMod.Stroke
local TextLabel = CreateMod.TextLabel

local Toggle = {}

function Toggle.build(hub, element)
	local config = hub.config
	local flag = element.flag
	local state = hub.settings[flag]
	if state == nil then
		state = element.default
		if state == nil then
			state = false
		end
	end
	hub.deps.settings.Set(hub.settings, flag, state)

	local row = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})

	local label = TextLabel(row, element.label, 14, config.colors.text, config.font)
	label.Size = UDim2.new(0.65, 0, 1, 0)
	label.TextXAlignment = Enum.TextXAlignment.Left

	local toggleBtn = Create("TextButton", {
		Parent = row,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 50, 0, 22),
		BackgroundColor3 = state and config.colors.purple or config.colors.surfaceHover,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
	})
	-- Room for UIStroke so the pill is not clipped by the card edge
	Create("UIPadding", {
		Parent = row,
		PaddingRight = UDim.new(0, 2),
	})
	Corner(toggleBtn, 11)
	Stroke(toggleBtn, config.colors.borderSoft, 1)

	local knob = Create("Frame", {
		Parent = toggleBtn,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.new(0, 16, 0, 16),
		BackgroundColor3 = config.colors.white,
		BorderSizePixel = 0,
	})
	Corner(knob, 20)

	local function apply(newState)
		state = newState and true or false
		hub.deps.settings.Set(hub.settings, flag, state)
		hub:tween(toggleBtn, {
			BackgroundColor3 = state and config.colors.purple or config.colors.surfaceHover,
		})
		hub:tween(knob, {
			Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
		})
	end

	hub._bindings[flag] = {
		apply = apply,
		read = function()
			return state
		end,
	}

	hub._pageMaid:Connect(toggleBtn.MouseButton1Click, function()
		apply(not state)
		if element.callback then
			element.callback(state)
		end
	end)

	return row
end

return Toggle
