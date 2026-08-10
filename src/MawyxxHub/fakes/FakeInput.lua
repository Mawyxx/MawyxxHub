-- Fake IInputService for tests (same duck shape as RobloxInput).

local function makeSignal()
	local handlers = {}
	return {
		Connect = function(_, handler)
			table.insert(handlers, handler)
			return {
				Disconnect = function()
					for i, h in ipairs(handlers) do
						if h == handler then
							table.remove(handlers, i)
							break
						end
					end
				end,
			}
		end,
		Fire = function(_, ...)
			for _, h in ipairs(handlers) do
				h(...)
			end
		end,
	}
end

local FakeInput = {}

function FakeInput.new()
	local mouse = Vector2.new(0, 0)
	local api = {
		InputBegan = makeSignal(),
		InputChanged = makeSignal(),
		InputEnded = makeSignal(),
	}
	function api.GetMouseLocation()
		return mouse
	end
	function api.SetMouse(x, y)
		mouse = Vector2.new(x, y)
	end
	return api
end

return FakeInput
