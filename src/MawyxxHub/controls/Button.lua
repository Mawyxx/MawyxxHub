local CreateMod = require(script.Parent.Parent.visual.Create)

local Create = CreateMod.Create
local Stroke = CreateMod.Stroke

local Button = {}

function Button.build(hub, element)
	local config = hub.config
	local row = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})

	local btn = Create("TextButton", {
		Parent = row,
		Position = UDim2.new(0.2, 0, 0, 0),
		Size = UDim2.new(0.6, 0, 1, 0),
		BackgroundColor3 = config.colors.surface,
		Text = element.label,
		TextColor3 = config.colors.text,
		TextSize = 14,
		Font = config.font,
		BorderSizePixel = 0,
		AutoButtonColor = false,
	})
	Stroke(btn, config.colors.borderSoft, 1)
	hub._pageMaid:Connect(btn.MouseEnter, function()
		hub:tween(btn, { BackgroundColor3 = config.colors.surfaceHover })
	end)
	hub._pageMaid:Connect(btn.MouseLeave, function()
		hub:tween(btn, { BackgroundColor3 = config.colors.surface })
	end)
	hub._pageMaid:Connect(btn.MouseButton1Click, function()
		if element.callback then
			element.callback()
		end
	end)

	return row
end

return Button
