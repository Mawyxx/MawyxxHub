-- Window drag via topbar + corner resize (uses IInputService port).

local Drag = {}

function Drag.setup(hub)
	local dragging = false
	local resizing = false
	local dragStart, startPos, startSize
	local input = hub.deps.input
	local minW, minH = 640, 420

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

	local grip = hub.resizeGrip
	if grip then
		hub._maid:Connect(grip.MouseButton1Down, function()
			resizing = true
			dragStart = input.GetMouseLocation()
			startSize = hub.window.AbsoluteSize
		end)
		hub._maid:Connect(grip.MouseEnter, function()
			hub:tween(grip, { TextTransparency = 0.05 })
		end)
		hub._maid:Connect(grip.MouseLeave, function()
			if not resizing then
				hub:tween(grip, { TextTransparency = 0.35 })
			end
		end)
	end

	hub._maid:Connect(input.InputChanged, function(inp)
		if inp.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end
		if dragging then
			local delta = inp.Position - dragStart
			hub.window.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		elseif resizing then
			local m = input.GetMouseLocation()
			local dw = m.X - dragStart.X
			local dh = m.Y - dragStart.Y
			local w = math.max(minW, startSize.X + dw)
			local h = math.max(minH, startSize.Y + dh)
			hub.window.Size = UDim2.fromOffset(w, h)
		end
	end)

	hub._maid:Connect(input.InputEnded, function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
			resizing = false
			if grip then
				grip.TextTransparency = 0.35
			end
		end
	end)
end

return Drag
