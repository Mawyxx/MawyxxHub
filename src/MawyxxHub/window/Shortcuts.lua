-- RightShift always toggles the hub window (framework-level). Starts hidden — first press opens.

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

	local function setOpen(open)
		visible = open
		if open then
			hub.window.Visible = true
			hub:tween(hub.window, {
				Size = UDim2.new(0, hub.config.window.width, 0, hub.config.window.height),
			})
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

	hub._maid:Connect(input.InputBegan, function(inp, processed)
		if hub._destroyed then
			return
		end
		-- Ignore gameProcessed so RightShift always works in menus / chat focus quirks
		if inp.KeyCode == Enum.KeyCode.RightShift then
			setOpen(not visible)
		end
	end)
end

return Shortcuts
