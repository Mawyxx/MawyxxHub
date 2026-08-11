-- RMB bind mini-menu: mode (press/hold) + listen for key + OK / Cancel / Clear.

local CreateMod = require(script.Parent.Parent.visual.Create)
local BindStore = require(script.Parent.Parent.util.BindStore)

local Create = CreateMod.Create
local Stroke = CreateMod.Stroke
local Corner = CreateMod.Corner

local PANEL_W = 228
local PANEL_H = 168

local BindMenu = {}

local function bindsEnabled(hub)
	local b = hub.config.binds
	return b == nil or b.enabled ~= false
end

function BindMenu.open(hub, opts)
	if not bindsEnabled(hub) or hub._destroyed then
		return
	end
	if hub._bindMenuClose then
		hub._bindMenuClose()
	end

	local config = hub.config
	local input = hub.deps.input
	local bindId = opts.bindId
	local title = opts.title or "Bind"
	local existing = BindStore.get(hub, bindId)

	local pendingKey = existing and existing.key or nil
	local pendingMode = (existing and existing.mode) or ((config.binds and config.binds.defaultMode) or "press")
	if pendingMode ~= "hold" then
		pendingMode = "press"
	end
	local listening = false
	local listenArmedAt = 0

	local overlayGui = Create("ScreenGui", {
		Name = "MawyxxBindMenu",
		Parent = hub.deps.guiHost.GetPlayerGui(),
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 100002,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})

	local panel = Create("Frame", {
		Parent = overlayGui,
		Size = UDim2.fromOffset(PANEL_W, PANEL_H),
		BackgroundColor3 = config.colors.surface,
		BorderSizePixel = 0,
		Active = true,
		ZIndex = 20,
	})
	Stroke(panel, config.colors.border, 1)
	Corner(panel, 6)

	local function place()
		local anchor = opts.anchor
		local x, y = 40, 40
		if anchor and anchor.AbsolutePosition then
			local pos = anchor.AbsolutePosition
			local size = anchor.AbsoluteSize
			x = pos.X + size.X - PANEL_W
			y = pos.Y + size.Y + 6
		end
		local cam = workspace.CurrentCamera
		local view = cam and cam.ViewportSize or Vector2.new(1920, 1080)
		x = math.clamp(x, 8, math.max(8, view.X - PANEL_W - 8))
		y = math.clamp(y, 8, math.max(8, view.Y - PANEL_H - 8))
		panel.Position = UDim2.fromOffset(math.floor(x), math.floor(y))
	end
	place()

	Create("TextLabel", {
		Parent = panel,
		Position = UDim2.fromOffset(12, 10),
		Size = UDim2.new(1, -24, 0, 16),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = config.colors.text,
		TextSize = 13,
		Font = config.font,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 21,
	})

	local keyBtn = Create("TextButton", {
		Parent = panel,
		Position = UDim2.fromOffset(12, 34),
		Size = UDim2.new(1, -24, 0, 28),
		BackgroundColor3 = config.colors.control,
		BorderSizePixel = 0,
		Text = pendingKey or "Click, then press a key",
		TextColor3 = config.colors.textSoft,
		TextSize = 13,
		Font = config.font,
		AutoButtonColor = false,
		ZIndex = 21,
	})
	Stroke(keyBtn, config.colors.borderSoft, 1, 0.4)
	Corner(keyBtn, 4)

	local function refreshKeyLabel()
		if listening then
			keyBtn.Text = "Listening... (key or mouse)"
			keyBtn.TextColor3 = config.colors.purple
			return
		end
		if pendingKey then
			keyBtn.Text = BindStore.displayLabel(hub, pendingKey)
			keyBtn.TextColor3 = config.colors.text
		else
			keyBtn.Text = "Click, then key or mouse"
			keyBtn.TextColor3 = config.colors.textSoft
		end
	end

	local modePress = Create("TextButton", {
		Parent = panel,
		Position = UDim2.fromOffset(12, 72),
		Size = UDim2.fromOffset(98, 26),
		BackgroundColor3 = config.colors.control,
		BorderSizePixel = 0,
		Text = "Press",
		TextColor3 = config.colors.textSoft,
		TextSize = 12,
		Font = config.font,
		AutoButtonColor = false,
		ZIndex = 21,
	})
	Corner(modePress, 4)
	Stroke(modePress, config.colors.borderSoft, 1, 0.45)

	local modeHold = Create("TextButton", {
		Parent = panel,
		Position = UDim2.fromOffset(118, 72),
		Size = UDim2.fromOffset(98, 26),
		BackgroundColor3 = config.colors.control,
		BorderSizePixel = 0,
		Text = "Hold",
		TextColor3 = config.colors.textSoft,
		TextSize = 12,
		Font = config.font,
		AutoButtonColor = false,
		ZIndex = 21,
	})
	Corner(modeHold, 4)
	Stroke(modeHold, config.colors.borderSoft, 1, 0.45)

	local function refreshModes()
		local on = config.colors.purple
		local off = config.colors.control
		local onT = config.colors.white
		local offT = config.colors.textSoft
		modePress.BackgroundColor3 = pendingMode == "press" and on or off
		modePress.TextColor3 = pendingMode == "press" and onT or offT
		modeHold.BackgroundColor3 = pendingMode == "hold" and on or off
		modeHold.TextColor3 = pendingMode == "hold" and onT or offT
	end
	refreshModes()
	refreshKeyLabel()

	local clearBtn = Create("TextButton", {
		Parent = panel,
		Position = UDim2.fromOffset(12, 108),
		Size = UDim2.fromOffset(60, 26),
		BackgroundColor3 = config.colors.control,
		BorderSizePixel = 0,
		Text = "Clear",
		TextColor3 = config.colors.textSoft,
		TextSize = 12,
		Font = config.font,
		AutoButtonColor = false,
		ZIndex = 21,
	})
	Corner(clearBtn, 4)
	Stroke(clearBtn, config.colors.borderSoft, 1, 0.45)

	local cancelBtn = Create("TextButton", {
		Parent = panel,
		Position = UDim2.fromOffset(80, 108),
		Size = UDim2.fromOffset(64, 26),
		BackgroundColor3 = config.colors.control,
		BorderSizePixel = 0,
		Text = "Cancel",
		TextColor3 = config.colors.textSoft,
		TextSize = 12,
		Font = config.font,
		AutoButtonColor = false,
		ZIndex = 21,
	})
	Corner(cancelBtn, 4)
	Stroke(cancelBtn, config.colors.borderSoft, 1, 0.45)

	local okBtn = Create("TextButton", {
		Parent = panel,
		Position = UDim2.fromOffset(152, 108),
		Size = UDim2.fromOffset(64, 26),
		BackgroundColor3 = config.colors.purpleDark,
		BorderSizePixel = 0,
		Text = "OK",
		TextColor3 = config.colors.white,
		TextSize = 12,
		Font = config.font,
		AutoButtonColor = false,
		ZIndex = 21,
	})
	Corner(okBtn, 4)
	Stroke(okBtn, config.colors.purple, 1)

	Create("TextLabel", {
		Parent = panel,
		Position = UDim2.fromOffset(12, 140),
		Size = UDim2.new(1, -24, 0, 18),
		BackgroundTransparency = 1,
		Text = "Right-click controls to bind",
		TextColor3 = config.colors.textMuted,
		TextSize = 10,
		Font = config.font,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 21,
	})

	local conns = {}
	local function disconnectAll()
		for _, c in ipairs(conns) do
			pcall(function()
				c:Disconnect()
			end)
		end
		conns = {}
	end

	local function close()
		hub._bindMenuOpen = false
		hub._bindMenuClose = nil
		disconnectAll()
		if overlayGui.Parent then
			overlayGui:Destroy()
		end
	end
	hub._bindMenuOpen = true
	hub._bindMenuClose = close
	hub._maid:Give(overlayGui)

	local function isForbidden(keyCode)
		local toggleKey = hub.config.toggleKey or Enum.KeyCode.RightControl
		if keyCode == toggleKey then
			return true
		end
		if keyCode == Enum.KeyCode.Unknown or keyCode == Enum.KeyCode.Escape then
			return true
		end
		return false
	end

	table.insert(conns, keyBtn.MouseButton1Click:Connect(function()
		listening = true
		listenArmedAt = os.clock() + 0.2
		refreshKeyLabel()
	end))

	table.insert(conns, modePress.MouseButton1Click:Connect(function()
		pendingMode = "press"
		refreshModes()
	end))
	table.insert(conns, modeHold.MouseButton1Click:Connect(function()
		pendingMode = "hold"
		refreshModes()
	end))

	table.insert(conns, clearBtn.MouseButton1Click:Connect(function()
		BindStore.clear(hub, bindId)
		if opts.onChanged then
			opts.onChanged()
		end
		close()
	end))
	table.insert(conns, cancelBtn.MouseButton1Click:Connect(function()
		close()
	end))
	table.insert(conns, okBtn.MouseButton1Click:Connect(function()
		if pendingKey then
			local other = BindStore.findByKey(hub, pendingKey, bindId)
			if other then
				BindStore.clear(hub, other)
			end
			BindStore.set(hub, bindId, pendingKey, pendingMode)
		else
			BindStore.clear(hub, bindId)
		end
		if opts.onChanged then
			opts.onChanged()
		end
		close()
	end))

	table.insert(conns, input.InputBegan:Connect(function(inp, _gameProcessed)
		if not listening then
			return
		end
		if inp.UserInputType == Enum.UserInputType.Keyboard then
			local keyCode = inp.KeyCode
			if keyCode == Enum.KeyCode.Escape then
				listening = false
				refreshKeyLabel()
				return
			end
			if isForbidden(keyCode) then
				return
			end
			pendingKey = BindStore.keyName(keyCode)
			listening = false
			refreshKeyLabel()
			return
		end

		local mouseToken = BindStore.mouseName(inp.UserInputType)
		if not mouseToken then
			return
		end
		-- Ignore the click that armed listening (same MouseButton1)
		if os.clock() < listenArmedAt and mouseToken == "MouseButton1" then
			return
		end
		pendingKey = mouseToken
		listening = false
		refreshKeyLabel()
	end))

	return close
end

return BindMenu
