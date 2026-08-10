-- Open: thin center strip expands up+down. Close: collapses into center strip. Linear.

local OPEN_INFO = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
local CLOSE_INFO = TweenInfo.new(0.08, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
local OPEN_MS = 0.11
local CLOSE_MS = 0.09

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
	-- Horizontal strip through the menu center (collapse / grow pivot)
	local STRIP = UDim2.fromOffset(w, 2)

	hub.window.AnchorPoint = Vector2.new(0.5, 0.5)
	hub.window.Position = UDim2.fromScale(0.5, 0.5)
	hub.window.ClipsDescendants = true

	-- Remove old scale anim if present
	local oldScale = hub.window:FindFirstChildOfClass("UIScale")
	if oldScale then
		oldScale:Destroy()
	end

	local visible = not startHidden
	hub.window.Visible = visible
	hub.window.Size = visible and FULL or STRIP

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

	local function clearSearch()
		local box = hub.searchBox
		if box then
			if box:IsFocused() then
				box:ReleaseFocus()
			end
			if box.Text ~= "" then
				box.Text = ""
			end
		end
		if hub.searchQuery ~= "" then
			hub.searchQuery = ""
			hub:_refreshPages()
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

		if open then
			hub.window.Visible = true
			hub.window.Size = STRIP
			-- Width already full — layout columns once, height reveal only clips
			runLayouts()
			task.defer(runLayouts)

			if hub.config.animations == false then
				hub.window.Size = FULL
				runLayouts()
				return
			end

			hub:tween(hub.window, { Size = FULL }, OPEN_INFO)
			task.delay(OPEN_MS, function()
				if token == animToken and not hub._destroyed then
					hub.window.Size = FULL
					runLayouts()
				end
			end)
		else
			clearSearch()

			if hub.config.animations == false then
				hub.window.Size = STRIP
				hub.window.Visible = false
				return
			end

			hub:tween(hub.window, { Size = STRIP }, CLOSE_INFO)
			task.delay(CLOSE_MS, function()
				if token ~= animToken or hub._destroyed then
					return
				end
				if not visible then
					hub.window.Size = STRIP
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
