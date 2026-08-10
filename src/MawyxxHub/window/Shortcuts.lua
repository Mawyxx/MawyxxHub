-- RightShift toggles window visibility.

local Shortcuts = {}

function Shortcuts.setup(hub)
	local visible = true
	local input = hub.deps.input

	hub._maid:Connect(input.InputBegan, function(inp, processed)
		if processed or hub._destroyed then
			return
		end
		if inp.KeyCode == Enum.KeyCode.RightShift then
			visible = not visible
			if visible then
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
	end)
end

return Shortcuts
