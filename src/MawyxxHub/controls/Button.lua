local CreateMod = require(script.Parent.Parent.visual.Create)
local Binds = require(script.Parent.Parent.window.Binds)

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

	local control = config.colors.control or config.colors.surface
	local controlHover = config.colors.controlHover or config.colors.surfaceHover

	local btn = Create("TextButton", {
		Parent = row,
		Position = UDim2.new(0.2, 0, 0, 0),
		Size = UDim2.new(0.6, 0, 1, 0),
		BackgroundColor3 = control,
		Text = element.label,
		TextColor3 = config.colors.text,
		TextSize = 14,
		Font = config.font,
		BorderSizePixel = 0,
		AutoButtonColor = false,
	})
	Stroke(btn, config.colors.borderSoft, 1, 0.45)

	local function fire()
		if element.callback then
			element.callback()
		end
	end

	hub._pageMaid:Connect(btn.MouseEnter, function()
		hub:tween(btn, { BackgroundColor3 = controlHover })
	end)
	hub._pageMaid:Connect(btn.MouseLeave, function()
		hub:tween(btn, { BackgroundColor3 = control })
	end)
	hub._pageMaid:Connect(btn.MouseButton1Click, fire)

	local bindId = element.bindId
	if type(bindId) ~= "string" or bindId == "" then
		hub._bindSeq = (hub._bindSeq or 0) + 1
		bindId = "__btn_" .. tostring(hub._bindSeq)
		element.bindId = bindId
	end

	Binds.attach(hub, {
		bindId = bindId,
		kind = "button",
		title = element.label,
		row = row,
		badgeParent = btn,
		badgeRightOffset = -6,
		clickTargets = { row, btn },
		firePress = fire,
		fireHoldStart = fire,
		fireHoldEnd = function() end,
	})

	return row
end

return Button
