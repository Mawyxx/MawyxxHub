-- RightShift toggles hub. Relayout after open (AbsoluteSize was 0 while hidden).

local Shortcuts = {}

function Shortcuts.setup(hub)
	local input = hub.deps.input
	local startHidden = hub.config.startHidden
	if startHidden == nil then
		startHidden = true
	end

	local visible = not startHidden
	hub.window.Visible = visible
	if not visible then
		hub.window.Size = UDim2.new(0, hub.config.window.width, 0, 0)
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
			hub:tween(hub.window, {
				Size = UDim2.new(0, hub.config.window.width, 0, hub.config.window.height),
			})
			task.defer(runLayouts)
			task.delay(0.05, runLayouts)
			task.delay(0.15, runLayouts)
		else
			hub:tween(hub.window, {
				Size = UDim2.new(0, hub.config.window.width, 0, 0),
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
