-- Window drag via topbar (uses IInputService port).

local Drag = {}

function Drag.setup(hub)
	local dragging = false
	local dragStart, startPos
	local input = hub.deps.input

	hub._maid:Connect(hub.topbar.InputBegan, function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = inp.Position
			startPos = hub.window.Position
		end
	end)

	hub._maid:Connect(hub.topbar.InputEnded, function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	hub._maid:Connect(input.InputChanged, function(inp)
		if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = inp.Position - dragStart
			hub.window.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

return Drag
