-- Color picker: click swatch → HSV square + hue strip → OK / Cancel.
-- MAWYXX_COLOR_HSV_V5

local CreateMod = require(script.Parent.Parent.visual.Create)

local Create = CreateMod.Create
local Stroke = CreateMod.Stroke
local Corner = CreateMod.Corner

local PANEL_PAD = 12
local SV = 160
local HUE_W = 20
local GAP = 10
local PREVIEW_H = 24
local BTN_H = 28
local MARKER = 12

local function clamp01(n)
	return math.clamp(n, 0, 1)
end

local ColorPicker = {}

function ColorPicker.build(hub, element)
	local config = hub.config
	local input = hub.deps.input
	local flag = element.flag
	local color = hub.settings[flag]
	if color == nil then
		color = element.default or Color3.fromRGB(117, 72, 255)
	end
	hub.deps.settings.Set(hub.settings, flag, color)

	local row = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})
	Create("UIPadding", {
		Parent = row,
		PaddingRight = UDim.new(0, 4),
	})

	local label = CreateMod.TextLabel(row, element.label, 14, config.colors.text, config.font)
	label.Size = UDim2.new(0.65, 0, 1, 0)
	label.TextXAlignment = Enum.TextXAlignment.Left

	local swatch = Create("TextButton", {
		Parent = row,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 26, 0, 22),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 5,
	})
	Stroke(swatch, config.colors.border, 1)
	Corner(swatch, 3)

	local panelW = PANEL_PAD + SV + GAP + HUE_W + PANEL_PAD
	local panelH = PANEL_PAD + 18 + GAP + SV + GAP + PREVIEW_H + GAP + BTN_H + PANEL_PAD

	-- Own ScreenGui so nothing can clip/hide the picker (executor-proof)
	local overlayGui = Create("ScreenGui", {
		Name = "MawyxxColorOverlay",
		Parent = hub.deps.guiHost.GetPlayerGui(),
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 100000,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	hub._pageMaid:Give(overlayGui)

	local panel = Create("Frame", {
		Name = "MawyxxColorPalette",
		Parent = overlayGui,
		Size = UDim2.fromOffset(panelW, panelH),
		BackgroundColor3 = config.colors.surface,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 10,
		Active = true,
	})
	Stroke(panel, config.colors.border, 1)
	Corner(panel, 6)

	Create("TextLabel", {
		Parent = panel,
		Position = UDim2.fromOffset(PANEL_PAD, PANEL_PAD - 2),
		Size = UDim2.new(1, -PANEL_PAD * 2, 0, 16),
		BackgroundTransparency = 1,
		Text = "Color",
		TextColor3 = config.colors.textSoft,
		TextSize = 12,
		Font = config.font,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 11,
	})

	local h, s, v = color:ToHSV()
	local pending = color
	local committed = color
	local open = false
	local draggingSV = false
	local draggingHue = false
	local pickerTop = PANEL_PAD + 18

	local svFrame = Create("TextButton", {
		Parent = panel,
		Position = UDim2.fromOffset(PANEL_PAD, pickerTop),
		Size = UDim2.fromOffset(SV, SV),
		BackgroundColor3 = Color3.fromHSV(h, 1, 1),
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		ClipsDescendants = true,
		ZIndex = 11,
	})
	Corner(svFrame, 4)
	Stroke(svFrame, config.colors.borderSoft, 1)

	local whiteWash = Create("Frame", {
		Parent = svFrame,
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Active = false,
		ZIndex = 12,
	})
	Create("UIGradient", {
		Parent = whiteWash,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1),
		}),
	})

	local blackWash = Create("Frame", {
		Parent = svFrame,
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		Active = false,
		ZIndex = 13,
	})
	Create("UIGradient", {
		Parent = blackWash,
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0),
		}),
	})

	local svHit = Create("TextButton", {
		Parent = svFrame,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 15,
	})

	local svMarker = Create("Frame", {
		Parent = svFrame,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(MARKER, MARKER),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		ZIndex = 16,
	})
	Stroke(svMarker, Color3.new(1, 1, 1), 2)
	Corner(svMarker, MARKER / 2)

	local hueFrame = Create("TextButton", {
		Parent = panel,
		Position = UDim2.fromOffset(PANEL_PAD + SV + GAP, pickerTop),
		Size = UDim2.fromOffset(HUE_W, SV),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		ClipsDescendants = true,
		ZIndex = 11,
	})
	Corner(hueFrame, 4)
	Stroke(hueFrame, config.colors.borderSoft, 1)
	Create("UIGradient", {
		Parent = hueFrame,
		Rotation = 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
			ColorSequenceKeypoint.new(0.16, Color3.fromHSV(0.16, 1, 1)),
			ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
			ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
			ColorSequenceKeypoint.new(0.66, Color3.fromHSV(0.66, 1, 1)),
			ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
		}),
	})

	local hueMarker = Create("Frame", {
		Parent = hueFrame,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, h, 0),
		Size = UDim2.new(1, 4, 0, 4),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Active = false,
		ZIndex = 16,
	})
	Stroke(hueMarker, Color3.new(0, 0, 0), 1)
	Corner(hueMarker, 2)

	local preview = Create("Frame", {
		Parent = panel,
		Position = UDim2.fromOffset(PANEL_PAD, pickerTop + SV + GAP),
		Size = UDim2.fromOffset(SV + GAP + HUE_W, PREVIEW_H),
		BackgroundColor3 = pending,
		BorderSizePixel = 0,
		ZIndex = 11,
	})
	Stroke(preview, config.colors.borderSoft, 1)
	Corner(preview, 3)

	local btnY = pickerTop + SV + GAP + PREVIEW_H + GAP
	local btnW = math.floor((SV + GAP + HUE_W - GAP) / 2)

	local cancelBtn = Create("TextButton", {
		Parent = panel,
		Position = UDim2.fromOffset(PANEL_PAD, btnY),
		Size = UDim2.fromOffset(btnW, BTN_H),
		BackgroundColor3 = config.colors.control or config.colors.surface2,
		BorderSizePixel = 0,
		Text = "Cancel",
		TextColor3 = config.colors.textSoft,
		TextSize = 13,
		Font = config.font,
		AutoButtonColor = false,
		ZIndex = 12,
	})
	Stroke(cancelBtn, config.colors.border, 1)
	Corner(cancelBtn, 4)

	local okBtn = Create("TextButton", {
		Parent = panel,
		Position = UDim2.fromOffset(PANEL_PAD + btnW + GAP, btnY),
		Size = UDim2.fromOffset(btnW, BTN_H),
		BackgroundColor3 = config.colors.purpleDark,
		BorderSizePixel = 0,
		Text = "OK",
		TextColor3 = config.colors.white,
		TextSize = 13,
		Font = config.font,
		AutoButtonColor = false,
		ZIndex = 12,
	})
	Stroke(okBtn, config.colors.purple, 1)
	Corner(okBtn, 4)

	local function syncFromHSV()
		pending = Color3.fromHSV(h, s, v)
		svFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		svMarker.Position = UDim2.fromScale(s, 1 - v)
		hueMarker.Position = UDim2.new(0.5, 0, h, 0)
		preview.BackgroundColor3 = pending
	end

	local function apply(newColor, fireCallback)
		color = newColor
		committed = newColor
		hub.deps.settings.Set(hub.settings, flag, newColor)
		swatch.BackgroundColor3 = newColor
		if fireCallback and element.callback then
			element.callback(newColor)
		end
	end

	local function closePanel()
		open = false
		draggingSV = false
		draggingHue = false
		panel.Visible = false
	end

	local function mouseXY()
		-- AbsolutePosition is Gui-inset space; raw GetMouseLocation is not
		local getter = input.GetMouseLocationGui or input.GetMouseLocation
		local m = getter()
		return m.X, m.Y
	end

	local function sampleSV(screenX, screenY)
		local pos = svFrame.AbsolutePosition
		local size = svFrame.AbsoluteSize
		s = clamp01((screenX - pos.X) / math.max(size.X, 1))
		v = clamp01(1 - (screenY - pos.Y) / math.max(size.Y, 1))
		syncFromHSV()
	end

	local function sampleHue(screenY)
		local pos = hueFrame.AbsolutePosition
		local size = hueFrame.AbsoluteSize
		h = clamp01((screenY - pos.Y) / math.max(size.Y, 1))
		syncFromHSV()
	end

	local function openPanel()
		h, s, v = committed:ToHSV()
		syncFromHSV()

		local pos = swatch.AbsolutePosition
		local size = swatch.AbsoluteSize
		local x = pos.X + size.X - panelW
		local y = pos.Y + size.Y + 8
		local cam = workspace.CurrentCamera
		local view = cam and cam.ViewportSize or Vector2.new(1920, 1080)

		if x < 8 then
			x = 8
		end
		if x + panelW > view.X - 8 then
			x = math.max(8, view.X - panelW - 8)
		end
		if y + panelH > view.Y - 8 then
			y = pos.Y - panelH - 8
		end
		if y < 8 then
			y = 8
		end

		panel.Position = UDim2.fromOffset(math.floor(x), math.floor(y))
		panel.Visible = true
		open = true
	end

	hub._bindings[flag] = {
		apply = function(val)
			apply(val, false)
			h, s, v = val:ToHSV()
			pending = val
			committed = val
			syncFromHSV()
		end,
		read = function()
			return color
		end,
	}

	hub._pageMaid:Connect(swatch.MouseButton1Click, function()
		if open then
			h, s, v = committed:ToHSV()
			syncFromHSV()
			closePanel()
			return
		end
		openPanel()
	end)

	hub._pageMaid:Connect(svHit.MouseButton1Down, function()
		draggingSV = true
		draggingHue = false
		local x, y = mouseXY()
		sampleSV(x, y)
	end)

	hub._pageMaid:Connect(hueFrame.MouseButton1Down, function()
		draggingHue = true
		draggingSV = false
		local _, y = mouseXY()
		sampleHue(y)
	end)

	hub._pageMaid:Connect(input.InputChanged, function(inp)
		if not open then
			return
		end
		if inp.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end
		local x, y = mouseXY()
		if draggingSV then
			sampleSV(x, y)
		elseif draggingHue then
			sampleHue(y)
		end
	end)

	hub._pageMaid:Connect(input.InputEnded, function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSV = false
			draggingHue = false
		end
	end)

	hub._pageMaid:Connect(cancelBtn.MouseButton1Click, function()
		h, s, v = committed:ToHSV()
		syncFromHSV()
		closePanel()
	end)

	hub._pageMaid:Connect(okBtn.MouseButton1Click, function()
		apply(pending, true)
		closePanel()
	end)

	hub._pageMaid:Connect(cancelBtn.MouseEnter, function()
		hub:tween(cancelBtn, { BackgroundColor3 = config.colors.controlHover or config.colors.surfaceHover })
	end)
	hub._pageMaid:Connect(cancelBtn.MouseLeave, function()
		hub:tween(cancelBtn, { BackgroundColor3 = config.colors.control or config.colors.surface2 })
	end)
	hub._pageMaid:Connect(okBtn.MouseEnter, function()
		hub:tween(okBtn, { BackgroundColor3 = config.colors.purple })
	end)
	hub._pageMaid:Connect(okBtn.MouseLeave, function()
		hub:tween(okBtn, { BackgroundColor3 = config.colors.purpleDark })
	end)

	syncFromHSV()
	return row
end

return ColorPicker
