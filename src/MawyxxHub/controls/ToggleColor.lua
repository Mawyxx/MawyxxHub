-- Toggle + color swatch on one row (QuantHub-style: name [■] [toggle]).

local CreateMod = require(script.Parent.Parent.visual.Create)
local ColorPicker = require(script.Parent.ColorPicker)
local Binds = require(script.Parent.Parent.window.Binds)

local Create = CreateMod.Create
local Corner = CreateMod.Corner
local Stroke = CreateMod.Stroke
local TextLabel = CreateMod.TextLabel

local ToggleColor = {}

function ToggleColor.build(hub, element)
	local config = hub.config
	local flag = element.flag
	local colorFlag = element.colorFlag

	local state = hub.settings[flag]
	if type(state) ~= "boolean" then
		state = element.default
	end
	if type(state) ~= "boolean" then
		state = false
	end
	hub.deps.settings.Set(hub.settings, flag, state)

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
	label.Size = UDim2.new(1, -118, 1, 0)
	label.TextXAlignment = Enum.TextXAlignment.Left

	local offColor = config.colors.control or config.colors.surface2
	local toggleBtn = Create("TextButton", {
		Parent = row,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 50, 0, 22),
		BackgroundColor3 = state and config.colors.purple or offColor,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 4,
	})
	Corner(toggleBtn, 11)
	Stroke(toggleBtn, config.colors.borderSoft, 1, 0.55)

	local knob = Create("Frame", {
		Parent = toggleBtn,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.new(0, 16, 0, 16),
		BackgroundColor3 = config.colors.white,
		BorderSizePixel = 0,
	})
	Corner(knob, 20)

	-- Color square just left of the toggle
	local swatch = Create("TextButton", {
		Parent = row,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -58, 0.5, 0),
		Size = UDim2.new(0, 16, 0, 16),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 5,
	})
	Stroke(swatch, config.colors.borderSoft, 1, 0.4)
	Corner(swatch, 2)

	ColorPicker.mountSwatch(hub, swatch, {
		flag = colorFlag,
		default = element.colorDefault or Color3.new(1, 1, 1),
		callback = element.colorCallback,
	})

	local function apply(newState, fireCallback)
		state = newState and true or false
		hub.deps.settings.Set(hub.settings, flag, state)
		hub:tween(toggleBtn, {
			BackgroundColor3 = state and config.colors.purple or offColor,
		})
		hub:tween(knob, {
			Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
		})
		if fireCallback and element.callback then
			element.callback(state)
		end
	end

	hub._bindings[flag] = {
		apply = function(v)
			apply(v, false)
		end,
		read = function()
			return state
		end,
	}

	local function clickToggle()
		apply(not state, true)
	end

	hub._pageMaid:Connect(toggleBtn.MouseButton1Click, clickToggle)

	-- Badge left of swatch+toggle: toggle(50)+gap+swatch(16)+gap+badge
	Binds.attach(hub, {
		bindId = flag,
		kind = "toggle",
		title = element.label,
		row = row,
		badgeParent = row,
		badgeRightOffset = -86,
		clickTargets = { row, toggleBtn, label },
		firePress = clickToggle,
		fireHoldStart = function()
			if not state then
				apply(true, true)
			end
		end,
		fireHoldEnd = function()
			if state then
				apply(false, true)
			end
		end,
	})

	return row
end

return ToggleColor
