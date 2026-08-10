-- RightShift toggles hub. Always relayout after open so columns fit.

local Shortcuts = {}

function Shortcuts.setup(hub)
	local input = hub.deps.input
	local startHidden = hub.config.startHidden
	if startHidden == nil then
		startHidden = true
	end

	local w = hub.config.window.width
	local h = hub.config.window.height

	local visible = not startHidden
	hub.window.Visible = visible
	if visible then
		hub.window.Size = UDim2.new(0, w, 0, h)
	else
		hub.window.Size = UDim2.new(0, w, 0, 0)
	end

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
		visible = open
		if open then
			hub.window.Visible = true
			-- Set final size immediately so AbsoluteSize is correct for layout
			hub.window.Size = UDim2.new(0, w, 0, h)
			runLayouts()
			task.defer(runLayouts)
			task.delay(0.05, runLayouts)
		else
			hub:tween(hub.window, {
				Size = UDim2.new(0, w, 0, 0),
			})
			task.delay(0.2, function()
				if not visible and not hub._destroyed then
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
