-- Open/close: collapse ↔ expand from the exact center of the menu.

local OPEN_INFO = TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local CLOSE_INFO = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local OPEN_MS = 0.26
local CLOSE_MS = 0.2
-- Near-zero size = one point at AnchorPoint (menu center)
local POINT = UDim2.fromOffset(2, 2)

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

	-- Pivot = center of the GUI (collapse point)
	hub.window.AnchorPoint = Vector2.new(0.5, 0.5)
	hub.window.Position = UDim2.fromScale(0.5, 0.5)

	-- Drop leftover UIScale from older builds so Size pivot is clean
	local oldScale = hub.window:FindFirstChildOfClass("UIScale")
	if oldScale then
		oldScale:Destroy()
	end

	local visible = not startHidden
	hub.window.Visible = visible
	hub.window.Size = visible and FULL or POINT

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

		-- Keep pivot locked on menu center while animating
		hub.window.AnchorPoint = Vector2.new(0.5, 0.5)
		hub.window.Position = UDim2.fromScale(0.5, 0.5)

		if open then
			hub.window.Visible = true
			hub.window.Size = POINT

			if hub.config.animations == false then
				hub.window.Size = FULL
				runLayouts()
				task.defer(runLayouts)
				return
			end

			hub:tween(hub.window, { Size = FULL }, OPEN_INFO)
			task.delay(OPEN_MS * 0.45, function()
				if token == animToken and not hub._destroyed then
					runLayouts()
				end
			end)
			task.delay(OPEN_MS, function()
				if token == animToken and not hub._destroyed then
					hub.window.Size = FULL
					runLayouts()
				end
			end)
		else
			if hub.config.animations == false then
				hub.window.Size = POINT
				hub.window.Visible = false
				return
			end

			hub:tween(hub.window, { Size = POINT }, CLOSE_INFO)
			task.delay(CLOSE_MS, function()
				if token ~= animToken or hub._destroyed then
					return
				end
				if not visible then
					hub.window.Size = POINT
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
