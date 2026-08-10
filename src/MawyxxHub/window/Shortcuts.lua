-- Open/close: full-size layout stays stable; UIScale grows/shrinks linearly from menu center.

local OPEN_INFO = TweenInfo.new(0.22, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
local CLOSE_INFO = TweenInfo.new(0.18, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
local CLOSE_MS = 0.2
local MIN_SCALE = 0.02

local CreateMod = require(script.Parent.Parent.visual.Create)
local Create = CreateMod.Create

local Shortcuts = {}

function Shortcuts.setup(hub)
	local input = hub.deps.input
	local startHidden = hub.config.startHidden
	if startHidden == nil then
		startHidden = true
	end

	local w = hub.config.window.width
	local h = hub.config.window.height
	local FULL = UDim2.fromOffset(w, h)

	-- Stable full size (no layout jump). Pivot = menu center.
	hub.window.AnchorPoint = Vector2.new(0.5, 0.5)
	hub.window.Position = UDim2.fromScale(0.5, 0.5)
	hub.window.Size = FULL

	local scale = hub.window:FindFirstChildOfClass("UIScale")
	if not scale then
		scale = Create("UIScale", {
			Parent = hub.window,
			Scale = 1,
		})
	end
	hub._windowScale = scale

	local visible = not startHidden
	hub.window.Visible = visible
	scale.Scale = visible and 1 or MIN_SCALE

	local animToken = 0

	local function runLayouts()
		local hooks = hub._layoutHooks
		if not hooks then
			return
		end
		for _, fn in ipairs(hooks) do
			pcall(fn)
		end
	end

	local function setOpen(open)
		if hub._destroyed then
			return
		end
		if open == visible and hub.window.Visible == open then
			return
		end

		animToken += 1
		local token = animToken
		visible = open

		hub.window.AnchorPoint = Vector2.new(0.5, 0.5)
		hub.window.Position = UDim2.fromScale(0.5, 0.5)
		hub.window.Size = FULL

		if open then
			hub.window.Visible = true
			scale.Scale = MIN_SCALE
			-- Layout once at full size so content doesn't jump while scaling
			runLayouts()
			task.defer(runLayouts)

			if hub.config.animations == false then
				scale.Scale = 1
				return
			end

			hub:tween(scale, { Scale = 1 }, OPEN_INFO)
		else
			if hub.config.animations == false then
				scale.Scale = MIN_SCALE
				hub.window.Visible = false
				return
			end

			hub:tween(scale, { Scale = MIN_SCALE }, CLOSE_INFO)
			task.delay(CLOSE_MS, function()
				if token ~= animToken or hub._destroyed then
					return
				end
				if not visible then
					scale.Scale = MIN_SCALE
					hub.window.Visible = false
				end
			end)
		end
	end

	hub._setOpen = setOpen
	hub._isOpen = function()
		return visible
	end
	hub._runLayouts = runLayouts

	hub._maid:Connect(input.InputBegan, function(inp)
		if hub._destroyed then
			return
		end
		if inp.KeyCode == Enum.KeyCode.RightShift then
			setOpen(not visible)
		end
	end)
end

return Shortcuts
