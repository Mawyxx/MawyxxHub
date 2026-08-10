-- MawyxxHub bundled for HttpGet/loadstring. Auto-generated; do not edit.
local __modules = {}
local __loaded = {}
local function __require(id)
	if __loaded[id] then return __loaded[id] end
	local loader = __modules[id]
	if not loader then error("[MawyxxHub] module not found: " .. tostring(id), 2) end
	local export = loader(__require)
	__loaded[id] = export
	return export
end

__modules["adapters/DefaultDeps"] = function(__require)
	-- Wires default Roblox adapters (composition helper for root).
	
	return {
		input = __require("adapters/RobloxInput"),
		guiHost = __require("adapters/RobloxGuiHost"),
		tween = __require("adapters/RobloxTween"),
		textMetrics = __require("adapters/RobloxTextMetrics"),
		settings = __require("adapters/GlobalSettingsStore"),
	}
end

__modules["adapters/GlobalSettingsStore"] = function(__require)
	-- Adapter: session settings bag in _G[key].
	
	local GlobalSettingsStore = {}
	
	function GlobalSettingsStore.Bind(key)
		local store = rawget(_G, key)
		if type(store) ~= "table" then
			store = {}
			rawset(_G, key, store)
		end
		return store
	end
	
	function GlobalSettingsStore.Get(store, flag)
		return store[flag]
	end
	
	function GlobalSettingsStore.Set(store, flag, value)
		store[flag] = value
	end
	
	return GlobalSettingsStore
end

__modules["adapters/RobloxGuiHost"] = function(__require)
	-- Adapter: PlayerGui host.
	
	local Players = game:GetService("Players")
	
	local RobloxGuiHost = {}
	
	function RobloxGuiHost.GetPlayerGui()
		local player = Players.LocalPlayer
		if not player then
			error("[MawyxxHub.GuiHost] LocalPlayer missing — client-only framework", 2)
		end
		return player:WaitForChild("PlayerGui")
	end
	
	function RobloxGuiHost.DestroyNamed(name)
		local gui = RobloxGuiHost.GetPlayerGui()
		local old = gui:FindFirstChild(name)
		if old then
			old:Destroy()
		end
	end
	
	return RobloxGuiHost
end

__modules["adapters/RobloxInput"] = function(__require)
	-- Adapter: UserInputService (ONLY place that GetService's UIS for input).
	
	local UserInputService = game:GetService("UserInputService")
	local GuiService = game:GetService("GuiService")
	
	local RobloxInput = {}
	
	function RobloxInput.GetMouseLocation()
		return UserInputService:GetMouseLocation()
	end
	
	-- Mouse in GuiObject.AbsolutePosition space (GetMouseLocation is screen; AbsolutePosition is inset-shifted).
	function RobloxInput.GetMouseLocationGui()
		return UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
	end
	
	RobloxInput.InputBegan = UserInputService.InputBegan
	RobloxInput.InputChanged = UserInputService.InputChanged
	RobloxInput.InputEnded = UserInputService.InputEnded
	
	return RobloxInput
end

__modules["adapters/RobloxTextMetrics"] = function(__require)
	-- Adapter: text width measurement for brand layout.
	
	local TextService = game:GetService("TextService")
	
	local RobloxTextMetrics = {}
	
	function RobloxTextMetrics.Measure(text, font, textSize)
		local bounds = TextService:GetTextSize(text, textSize, font, Vector2.new(10000, textSize + 8))
		return bounds.X
	end
	
	return RobloxTextMetrics
end

__modules["adapters/RobloxTween"] = function(__require)
	-- Adapter: TweenService.
	
	local TweenService = game:GetService("TweenService")
	
	local DEFAULT_INFO = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	
	local function RobloxTween(object, properties, info)
		local tween = TweenService:Create(object, info or DEFAULT_INFO, properties)
		tween:Play()
		return tween
	end
	
	return RobloxTween
end

__modules["config/Defaults"] = function(__require)
	-- Sweet-spot defaults: compact but no clipping.
	
	local Defaults = {
		window = {
			width = 920,
			height = 600,
			sidebarWidth = 156,
			title = "MawyxxHub",
		},
		colors = {
			bg = Color3.fromRGB(8, 8, 9),
			surface = Color3.fromRGB(10, 10, 11),
			surface2 = Color3.fromRGB(13, 13, 14),
			surfaceHover = Color3.fromRGB(17, 17, 18),
			border = Color3.fromRGB(31, 31, 33),
			borderSoft = Color3.fromRGB(23, 23, 25),
			text = Color3.fromRGB(224, 224, 226),
			textSoft = Color3.fromRGB(156, 156, 160),
			textMuted = Color3.fromRGB(91, 91, 95),
			purple = Color3.fromRGB(117, 72, 255),
			purpleHover = Color3.fromRGB(132, 91, 255),
			purpleDark = Color3.fromRGB(87, 49, 190),
			white = Color3.fromRGB(245, 245, 247),
		},
		font = Enum.Font.Code,
		animations = true,
		settingsTable = "MawyxxHubSettings",
		brand = {
			prefix = "Mawyxx",
			accent = "Hub",
			footer = "Mawyxx / Hub",
		},
		search = {
			enabled = true,
			placeholder = "Search",
		},
		startHidden = true,
		group = {
			columns = 2,
			gap = 10,
			gutter = 14,
			padding = 14,
			innerPadding = 12,
			headerHeight = 36,
			corner = 4,
		},
	}
	
	return Defaults
end

__modules["config/Merge"] = function(__require)
	-- Deep-clone then overlay-merge so Defaults is never shared/mutated (PRIME config hygiene).
	
	local function deepClone(value)
		if type(value) ~= "table" then
			return value
		end
		local copy = {}
		for k, v in pairs(value) do
			copy[k] = deepClone(v)
		end
		return copy
	end
	
	local function merge(base, overlay)
		local result = deepClone(base)
		if overlay == nil then
			return result
		end
		for k, v in pairs(overlay) do
			if type(v) == "table" and type(result[k]) == "table" then
				result[k] = merge(result[k], v)
			else
				result[k] = deepClone(v)
			end
		end
		return result
	end
	
	return {
		deepClone = deepClone,
		merge = merge,
	}
end

__modules["contracts/Ports"] = function(__require)
	--[[
		Outbound ports (duck-typed contracts) — PRIME-A35.
	
		IInputService:
		  GetMouseLocation() -> Vector2
		  InputBegan, InputChanged, InputEnded : RBXScriptSignal
	
		IGuiHost:
		  GetPlayerGui() -> PlayerGui
		  DestroyNamed(name)
	
		ITween:
		  (object, properties, info?) -> tween-like
	
		ITextMetrics:
		  Measure(text, font, textSize) -> number (width px)
	
		ISettingsStore:
		  Bind(key) -> table
		  Get(store, flag) / Set(store, flag, value)
	]]
	
	return {
		-- Documentation module only; adapters implement the surface.
	}
end

__modules["controls/Button"] = function(__require)
	local CreateMod = __require("visual/Create")
	
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
end

__modules["controls/ColorPicker"] = function(__require)
	-- Color picker: click swatch → HSV square + hue strip → OK / Cancel.
	-- MAWYXX_COLOR_HSV_V5
	
	local CreateMod = __require("visual/Create")
	
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
			BackgroundColor3 = config.colors.surface2,
			BorderSizePixel = 0,
			Text = "Cancel",
			TextColor3 = config.colors.textSoft,
			TextSize = 13,
			Font = config.font,
			AutoButtonColor = false,
			ZIndex = 12,
		})
		Stroke(cancelBtn, config.colors.borderSoft, 1)
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
			hub:tween(cancelBtn, { BackgroundColor3 = config.colors.surfaceHover })
		end)
		hub._pageMaid:Connect(cancelBtn.MouseLeave, function()
			hub:tween(cancelBtn, { BackgroundColor3 = config.colors.surface2 })
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
end

__modules["controls/Dropdown"] = function(__require)
	local CreateMod = __require("visual/Create")
	
	local Create = CreateMod.Create
	local Stroke = CreateMod.Stroke
	local Padding = CreateMod.Padding
	local TextLabel = CreateMod.TextLabel
	
	local Dropdown = {}
	
	function Dropdown.build(hub, element)
		local config = hub.config
		local flag = element.flag
		local options = element.options or {}
		local selected = hub.settings[flag]
		if selected == nil then
			selected = element.default or options[1] or ""
		end
		hub.deps.settings.Set(hub.settings, flag, selected)
	
		local row = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 56),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 20,
		})
	
		local label = TextLabel(row, element.label, 13, config.colors.textSoft, config.font)
		label.Size = UDim2.new(1, 0, 0, 18)
		label.TextXAlignment = Enum.TextXAlignment.Left
	
		local btn = Create("TextButton", {
			Parent = row,
			Position = UDim2.new(0, 0, 0, 20),
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundColor3 = config.colors.surface,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 21,
		})
		Stroke(btn, config.colors.borderSoft, 1)
	
		local currentText = TextLabel(btn, tostring(selected), 14, config.colors.text, config.font)
		currentText.Position = UDim2.new(0, 9, 0, 0)
		currentText.Size = UDim2.new(1, -35, 1, 0)
	
		local arrow = TextLabel(btn, "⌄", 15, config.colors.textSoft, config.font)
		arrow.Position = UDim2.new(1, -25, 0, 0)
		arrow.Size = UDim2.new(0, 20, 1, 0)
		arrow.TextXAlignment = Enum.TextXAlignment.Center
	
		local open = false
		local list = Create("Frame", {
			Name = "DropdownList",
			Parent = hub.overlay,
			Size = UDim2.new(0, 100, 0, #options * 27),
			BackgroundColor3 = config.colors.surface,
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = 250,
		})
		Stroke(list, config.colors.border, 1)
		hub._pageMaid:Give(list)
	
		Create("UIListLayout", {
			Parent = list,
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
	
		local function apply(opt, fireCallback)
			selected = opt
			hub.deps.settings.Set(hub.settings, flag, opt)
			currentText.Text = tostring(opt)
			open = false
			list.Visible = false
			arrow.Text = "⌄"
			if fireCallback and element.callback then
				element.callback(opt)
			end
		end
	
		hub._bindings[flag] = {
			apply = function(v)
				apply(v, false)
			end,
			read = function()
				return selected
			end,
		}
	
		for _, opt in ipairs(options) do
			local optBtn = Create("TextButton", {
				Parent = list,
				Size = UDim2.new(1, 0, 0, 27),
				BackgroundColor3 = config.colors.surface,
				BorderSizePixel = 0,
				Text = tostring(opt),
				TextColor3 = config.colors.textSoft,
				TextSize = 13,
				Font = config.font,
				AutoButtonColor = false,
				ZIndex = 251,
			})
			optBtn.TextXAlignment = Enum.TextXAlignment.Left
			Padding(optBtn, 9, 5, 0, 0)
			hub._pageMaid:Connect(optBtn.MouseEnter, function()
				hub:tween(optBtn, {
					BackgroundColor3 = config.colors.surfaceHover,
					TextColor3 = config.colors.text,
				})
			end)
			hub._pageMaid:Connect(optBtn.MouseLeave, function()
				hub:tween(optBtn, {
					BackgroundColor3 = config.colors.surface,
					TextColor3 = config.colors.textSoft,
				})
			end)
			hub._pageMaid:Connect(optBtn.MouseButton1Click, function()
				apply(opt, true)
			end)
		end
	
		local function reposition()
			local pos = btn.AbsolutePosition
			local size = btn.AbsoluteSize
			local parentPos = hub.overlay.AbsolutePosition
			list.Position = UDim2.fromOffset(pos.X - parentPos.X, pos.Y - parentPos.Y + size.Y + 2)
			list.Size = UDim2.fromOffset(size.X, #options * 27)
		end
	
		hub._pageMaid:Connect(btn.MouseButton1Click, function()
			open = not open
			if open then
				reposition()
			end
			list.Visible = open
			arrow.Text = open and "⌃" or "⌄"
		end)
	
		return row
	end
	
	return Dropdown
end

__modules["controls/Factory"] = function(__require)
	local Errors = __require("util/Errors")
	local Toggle = __require("controls/Toggle")
	local Slider = __require("controls/Slider")
	local Dropdown = __require("controls/Dropdown")
	local Button = __require("controls/Button")
	local ColorPicker = __require("controls/ColorPicker")
	
	local builders = {
		toggle = Toggle.build,
		slider = Slider.build,
		dropdown = Dropdown.build,
		button = Button.build,
		colorpicker = ColorPicker.build,
	}
	
	local Factory = {}
	
	function Factory.build(hub, element)
		local builder = builders[element.type]
		if not builder then
			Errors.fail("Factory.UnknownType", "unknown control type: " .. tostring(element.type))
		end
		return builder(hub, element)
	end
	
	return Factory
end

__modules["controls/Slider"] = function(__require)
	local CreateMod = __require("visual/Create")
	
	local Create = CreateMod.Create
	local Stroke = CreateMod.Stroke
	local TextLabel = CreateMod.TextLabel
	
	local Slider = {}
	
	function Slider.build(hub, element)
		local config = hub.config
		local input = hub.deps.input
		local flag = element.flag
		local min = element.min or 0
		local max = element.max or 100
		local step = element.step or 1
		local val = hub.settings[flag]
		if val == nil then
			val = element.default or min
		end
		hub.deps.settings.Set(hub.settings, flag, val)
	
		local row = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 50),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		})
	
		local label = TextLabel(row, element.label, 14, config.colors.text, config.font)
		label.Size = UDim2.new(0.5, 0, 0, 22)
		label.TextXAlignment = Enum.TextXAlignment.Left
	
		local valueLabel = TextLabel(row, tostring(val) .. "/" .. tostring(max), 13, config.colors.textSoft, config.font)
		valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
		valueLabel.Size = UDim2.new(0.5, -2, 0, 22)
		valueLabel.TextXAlignment = Enum.TextXAlignment.Right
		valueLabel.TextTruncate = Enum.TextTruncate.AtEnd
	
		local track = Create("TextButton", {
			Parent = row,
			Position = UDim2.new(0, 0, 0, 28),
			Size = UDim2.new(1, 0, 0, 16),
			BackgroundColor3 = config.colors.surface2,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
		})
		Stroke(track, config.colors.borderSoft, 1)
	
		local fill = Create("Frame", {
			Parent = track,
			Size = UDim2.new((val - min) / math.max(max - min, 1e-9), 0, 1, 0),
			BackgroundColor3 = config.colors.purple,
			BorderSizePixel = 0,
		})
	
		local dragging = false
	
		local function apply(newVal, fireCallback)
			newVal = math.clamp(newVal, min, max)
			newVal = math.round(newVal / step) * step
			newVal = math.clamp(newVal, min, max)
			val = newVal
			hub.deps.settings.Set(hub.settings, flag, val)
			fill.Size = UDim2.new((val - min) / math.max(max - min, 1e-9), 0, 1, 0)
			valueLabel.Text = tostring(val) .. "/" .. tostring(max)
			if fireCallback and element.callback then
				element.callback(val)
			end
		end
	
		hub._bindings[flag] = {
			apply = function(v)
				apply(v, false)
			end,
			read = function()
				return val
			end,
		}
	
		local function updateFromX(inputX)
			local rel = math.clamp((inputX - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
			apply(min + (max - min) * rel, true)
		end
	
		hub._pageMaid:Connect(track.MouseButton1Down, function()
			dragging = true
			updateFromX(input.GetMouseLocation().X)
		end)
		hub._pageMaid:Connect(input.InputChanged, function(inp)
			if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
				updateFromX(inp.Position.X)
			end
		end)
		hub._pageMaid:Connect(input.InputEnded, function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
	
		return row
	end
	
	return Slider
end

__modules["controls/Toggle"] = function(__require)
	local CreateMod = __require("visual/Create")
	
	local Create = CreateMod.Create
	local Corner = CreateMod.Corner
	local Stroke = CreateMod.Stroke
	local TextLabel = CreateMod.TextLabel
	
	local Toggle = {}
	
	function Toggle.build(hub, element)
		local config = hub.config
		local flag = element.flag
		local state = hub.settings[flag]
		if state == nil then
			state = element.default
			if state == nil then
				state = false
			end
		end
		hub.deps.settings.Set(hub.settings, flag, state)
	
		local row = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		})
	
		local label = TextLabel(row, element.label, 14, config.colors.text, config.font)
		label.Size = UDim2.new(0.65, 0, 1, 0)
		label.TextXAlignment = Enum.TextXAlignment.Left
	
		local toggleBtn = Create("TextButton", {
			Parent = row,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.new(0, 50, 0, 22),
			BackgroundColor3 = state and config.colors.purple or config.colors.surfaceHover,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
		})
		-- Room for UIStroke so the pill is not clipped by the card edge
		Create("UIPadding", {
			Parent = row,
			PaddingRight = UDim.new(0, 4),
		})
		Corner(toggleBtn, 11)
		Stroke(toggleBtn, config.colors.borderSoft, 1)
	
		local knob = Create("Frame", {
			Parent = toggleBtn,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
			Size = UDim2.new(0, 16, 0, 16),
			BackgroundColor3 = config.colors.white,
			BorderSizePixel = 0,
		})
		Corner(knob, 20)
	
		local function apply(newState)
			state = newState and true or false
			hub.deps.settings.Set(hub.settings, flag, state)
			hub:tween(toggleBtn, {
				BackgroundColor3 = state and config.colors.purple or config.colors.surfaceHover,
			})
			hub:tween(knob, {
				Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
			})
		end
	
		hub._bindings[flag] = {
			apply = apply,
			read = function()
				return state
			end,
		}
	
		hub._pageMaid:Connect(toggleBtn.MouseButton1Click, function()
			apply(not state)
			if element.callback then
				element.callback(state)
			end
		end)
	
		return row
	end
	
	return Toggle
end

__modules["fakes/FakeInput"] = function(__require)
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
		function api.GetMouseLocationGui()
			return mouse
		end
		function api.SetMouse(x, y)
			mouse = Vector2.new(x, y)
		end
		return api
	end
	
	return FakeInput
end

__modules["fakes/FakeSettingsStore"] = function(__require)
	-- In-memory settings store (ISettingsStore Fake).
	
	local FakeSettingsStore = {}
	
	function FakeSettingsStore.Bind(_key)
		return {}
	end
	
	function FakeSettingsStore.Get(store, flag)
		return store[flag]
	end
	
	function FakeSettingsStore.Set(store, flag, value)
		store[flag] = value
	end
	
	return FakeSettingsStore
end

__modules["fakes/FakeTween"] = function(__require)
	-- Instant property apply (ITween Fake / animations=false path helper).
	
	local function FakeTween(object, properties, _info)
		for k, v in pairs(properties) do
			object[k] = v
		end
		return { Play = function() end, Cancel = function() end }
	end
	
	return FakeTween
end

__modules["hub/MawyxxHub"] = function(__require)
	-- Hub class: Tab → Group → Controls. Public API + lifecycle.
	
	local Defaults = __require("config/Defaults")
	local Merge = __require("config/Merge")
	local Maid = __require("util/Maid")
	local Model = __require("model/Model")
	local Validate = __require("model/Validate")
	local DefaultDeps = __require("adapters/DefaultDeps")
	local WindowBuild = __require("window/Build")
	local Drag = __require("window/Drag")
	local Shortcuts = __require("window/Shortcuts")
	local Sidebar = __require("navigation/Sidebar")
	local Pages = __require("navigation/Pages")
	
	local MawyxxHub = {}
	MawyxxHub.__index = MawyxxHub
	
	local function mergeDeps(overrides)
		local base = {
			input = DefaultDeps.input,
			guiHost = DefaultDeps.guiHost,
			tween = DefaultDeps.tween,
			textMetrics = DefaultDeps.textMetrics,
			settings = DefaultDeps.settings,
		}
		if overrides then
			for k, v in pairs(overrides) do
				base[k] = v
			end
		end
		return base
	end
	
	local function appendControl(hub, group, el)
		Validate.alive(hub)
		Validate.group(group)
		table.insert(group.elements, el)
		hub:_refreshPages()
		return el
	end
	
	function MawyxxHub.new(userConfig, deps)
		local self = setmetatable({}, MawyxxHub)
		self.config = Merge.merge(Defaults, userConfig or {})
		self.deps = mergeDeps(deps)
		self.tabs = {}
		self.activeTab = nil
		self._destroyed = false
		self._bindings = {}
		self.searchQuery = ""
		self._maid = Maid.new()
		self._pageMaid = Maid.new()
		self._navMaid = Maid.new()
		self._maid:Give(self._pageMaid)
		self._maid:Give(self._navMaid)
	
		self.settings = self.deps.settings.Bind(self.config.settingsTable)
	
		WindowBuild.window(self)
		Drag.setup(self)
		Shortcuts.setup(self)
		self:_renderSidebar()
		return self
	end
	
	function MawyxxHub:tween(object, properties, info)
		if not self.config.animations then
			for k, v in pairs(properties) do
				object[k] = v
			end
			return nil
		end
		return self.deps.tween(object, properties, info)
	end
	
	function MawyxxHub:_renderSidebar()
		self._navMaid:DoCleaning()
		Sidebar.render(self)
	end
	
	function MawyxxHub:_refreshPages()
		Validate.alive(self)
		Pages.render(self)
		Sidebar.updateHighlight(self)
	end
	
	--- Sidebar entry. Text label only (no icons/emoji).
	function MawyxxHub:addTab(name)
		Validate.alive(self)
		Validate.label(name)
		local tab = Model.attachGroupsAlias(Model.newTab(name))
		table.insert(self.tabs, tab)
		self:_renderSidebar()
		if #self.tabs == 1 then
			self:activateTab(tab)
		end
		return tab
	end
	
	function MawyxxHub:activateTab(tab)
		Validate.alive(self)
		Validate.tab(tab)
		for _, t in ipairs(self.tabs) do
			t.active = false
		end
		tab.active = true
		self.activeTab = tab
		self:_refreshPages()
	end
	
	--- Explicit group by text name only (equal width, height from controls).
	function MawyxxHub:addGroup(tab, name)
		Validate.alive(self)
		Validate.tab(tab)
		Validate.label(name)
		local group = Model.newGroup(name)
		table.insert(tab.groups, group)
		self:_refreshPages()
		return group
	end
	
	-- Compat: old name
	function MawyxxHub:addSection(tab, name)
		return self:addGroup(tab, name)
	end
	
	function MawyxxHub:addToggle(group, label, flag, default, callback)
		Validate.label(label)
		Validate.flag(flag)
		local el = {
			type = "toggle",
			label = label,
			flag = flag,
			default = default,
			callback = callback,
		}
		if el.default == nil then
			el.default = false
		end
		return appendControl(self, group, el)
	end
	
	function MawyxxHub:addSlider(group, label, flag, min, max, step, default, callback)
		Validate.label(label)
		Validate.flag(flag)
		min = min or 0
		max = max or 100
		step = step or 1
		Validate.sliderRange(min, max, step)
		return appendControl(self, group, {
			type = "slider",
			label = label,
			flag = flag,
			min = min,
			max = max,
			step = step,
			default = default or min,
			callback = callback,
		})
	end
	
	function MawyxxHub:addDropdown(group, label, flag, options, default, callback)
		Validate.label(label)
		Validate.flag(flag)
		Validate.dropdownOptions(options)
		return appendControl(self, group, {
			type = "dropdown",
			label = label,
			flag = flag,
			options = options,
			default = default or options[1],
			callback = callback,
		})
	end
	
	function MawyxxHub:addButton(group, label, callback)
		Validate.label(label)
		return appendControl(self, group, {
			type = "button",
			label = label,
			callback = callback,
		})
	end
	
	function MawyxxHub:addColorPicker(group, label, flag, default, callback)
		Validate.label(label)
		Validate.flag(flag)
		return appendControl(self, group, {
			type = "colorpicker",
			label = label,
			flag = flag,
			default = default or Color3.new(1, 1, 1),
			callback = callback,
		})
	end
	
	function MawyxxHub:get(flag)
		Validate.alive(self)
		Validate.flag(flag)
		return self.deps.settings.Get(self.settings, flag)
	end
	
	function MawyxxHub:set(flag, value)
		Validate.alive(self)
		Validate.flag(flag)
		self.deps.settings.Set(self.settings, flag, value)
		local binding = self._bindings[flag]
		if binding and binding.apply then
			binding.apply(value)
			return
		end
		self:_refreshPages()
	end
	
	function MawyxxHub:Destroy()
		if self._destroyed then
			return
		end
		self._destroyed = true
		self._bindings = {}
		self._maid:Destroy()
		self.screenGui = nil
		self.window = nil
	end
	
	MawyxxHub.destroy = MawyxxHub.Destroy
	
	return MawyxxHub
end

__modules["init"] = function(__require)
	--[[
		MawyxxHub — Roblox GUI framework (composition root).
	
			local MawyxxHub = require(ReplicatedStorage.MawyxxHub)
			local hub = MawyxxHub.new(config?, deps?)
	]]
	
	return __require("hub/MawyxxHub")
end

__modules["model/Filter"] = function(__require)
	-- Search / filter helpers: Tab → Group → Control.
	-- ASCII + Cyrillic case-fold (string.lower is ASCII-only).
	
	local Filter = {}
	
	local function foldChar(code)
		-- A-Z
		if code >= 0x41 and code <= 0x5A then
			return code + 0x20
		end
		-- А-Я (Cyrillic)
		if code >= 0x410 and code <= 0x42F then
			return code + 0x20
		end
		-- Ё
		if code == 0x401 then
			return 0x451
		end
		return code
	end
	
	local function norm(s)
		s = tostring(s or "")
		if s == "" then
			return ""
		end
		local parts = table.create(#s)
		local n = 0
		for _, code in utf8.codes(s) do
			n += 1
			parts[n] = utf8.char(foldChar(code))
		end
		return table.concat(parts)
	end
	
	function Filter.matchesQuery(query, ...)
		local q = norm(query)
		if q == "" then
			return true
		end
		for i = 1, select("#", ...) do
			if string.find(norm(select(i, ...)), q, 1, true) then
				return true
			end
		end
		return false
	end
	
	function Filter.groupVisible(group, query)
		if Filter.matchesQuery(query, group.name) then
			return true, group.elements
		end
		local filtered = {}
		for _, el in ipairs(group.elements) do
			if Filter.matchesQuery(query, el.label, el.flag, el.type) then
				table.insert(filtered, el)
			end
		end
		return #filtered > 0, filtered
	end
	
	-- Compat
	Filter.sectionVisible = Filter.groupVisible
	
	return Filter
end

__modules["model/Model"] = function(__require)
	-- Document model helpers: Tab → Group → Control.
	
	local Model = {}
	
	function Model.newTab(name)
		return {
			name = name,
			groups = {},
			-- compat alias used by older call sites / filters
			sections = nil, -- set to same table below
			active = false,
		}
	end
	
	function Model.attachGroupsAlias(tab)
		-- sections == groups (same list) for backward-compatible validation paths
		tab.sections = tab.groups
		return tab
	end
	
	function Model.newGroup(name)
		return {
			name = name,
			elements = {},
		}
	end
	
	return Model
end

__modules["model/Validate"] = function(__require)
	-- Element / API validation (explicit errors).
	
	local Errors = __require("util/Errors")
	
	local Validate = {}
	
	function Validate.tab(tab)
		Errors.expect(type(tab) == "table", "Validate.Tab", "tab is required")
		local groups = tab.groups or tab.sections
		Errors.expect(type(groups) == "table", "Validate.Tab", "tab.groups missing — pass hub:addTab result")
	end
	
	function Validate.group(group)
		Errors.expect(type(group) == "table", "Validate.Group", "group is required")
		Errors.expect(type(group.elements) == "table", "Validate.Group", "group.elements missing — pass hub:addGroup result")
	end
	
	-- Compat alias
	Validate.section = Validate.group
	
	function Validate.flag(flag)
		Errors.expect(type(flag) == "string" and flag ~= "", "Validate.Flag", "flag must be a non-empty string")
	end
	
	function Validate.label(label)
		Errors.expect(type(label) == "string" and label ~= "", "Validate.Label", "label must be a non-empty string")
	end
	
	function Validate.sliderRange(min, max, step)
		Errors.expect(type(min) == "number" and type(max) == "number", "Validate.Slider", "min/max must be numbers")
		Errors.expect(min <= max, "Validate.Slider", ("min (%s) > max (%s)"):format(tostring(min), tostring(max)))
		Errors.expect(type(step) == "number" and step > 0, "Validate.Slider", "step must be > 0")
	end
	
	function Validate.dropdownOptions(options)
		Errors.expect(type(options) == "table", "Validate.Dropdown", "options must be a table")
		Errors.expect(#options > 0, "Validate.Dropdown", "options must be non-empty")
	end
	
	function Validate.alive(hub)
		Errors.expect(hub._destroyed ~= true, "Lifecycle.Destroyed", "hub already destroyed")
	end
	
	return Validate
end

__modules["navigation/Groups"] = function(__require)
	-- Named group card: equal WIDTH (from column), HEIGHT follows controls.
	
	local CreateMod = __require("visual/Create")
	local Factory = __require("controls/Factory")
	
	local Create = CreateMod.Create
	local Stroke = CreateMod.Stroke
	local Corner = CreateMod.Corner
	local TextLabel = CreateMod.TextLabel
	
	local Groups = {}
	
	function Groups.render(hub, group, parent, layoutOrder, elements)
		elements = elements or group.elements
		local config = hub.config
		local g = config.group or {}
		local headerH = g.headerHeight or 36
		local inset = g.innerPadding or 12
	
		local frame = Create("Frame", {
			Name = "Group_" .. group.name,
			Parent = parent,
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundColor3 = config.colors.bg,
			BorderSizePixel = 0,
			ClipsDescendants = false, -- never clip toggles/sliders at the card edge
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = layoutOrder or 0,
		})
		Stroke(frame, config.colors.borderSoft, 1)
		Corner(frame, g.corner or 4)
	
		Create("UIListLayout", {
			Parent = frame,
			Padding = UDim.new(0, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
	
		local headerRow = Create("Frame", {
			Parent = frame,
			Size = UDim2.new(1, 0, 0, headerH),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 1,
		})
		local header = TextLabel(headerRow, group.name, 15, config.colors.text, config.font)
		header.Position = UDim2.new(0, inset, 0, 0)
		header.Size = UDim2.new(1, -inset * 2, 1, 0)
	
		Create("Frame", {
			Parent = frame,
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = config.colors.borderSoft,
			BorderSizePixel = 0,
			LayoutOrder = 2,
		})
	
		local list = Create("Frame", {
			Name = "Body",
			Parent = frame,
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 3,
		})
		Create("UIListLayout", {
			Parent = list,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
		Create("UIPadding", {
			Parent = list,
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 12),
			PaddingLeft = UDim.new(0, inset),
			PaddingRight = UDim.new(0, inset),
		})
	
		for _, element in ipairs(elements) do
			local row = Factory.build(hub, element)
			if row then
				row.Parent = list
			end
		end
	
		return frame
	end
	
	return Groups
end

__modules["navigation/Pages"] = function(__require)
	-- Tab page: column widths from scroll viewport (UIPadding does not shrink AbsoluteSize).
	
	local CreateMod = __require("visual/Create")
	local Groups = __require("navigation/Groups")
	local Filter = __require("model/Filter")
	
	local Create = CreateMod.Create
	
	local Pages = {}
	
	local function addColumnList(col, gap)
		Create("UIListLayout", {
			Parent = col,
			Padding = UDim.new(0, gap),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
	end
	
	--- Layout against the visible scroll width, not row.AbsoluteSize (padding-safe).
	local function layoutTwoColumns(scroll, row, left, right, gutter, pad)
		local viewW = scroll.AbsoluteSize.X
		if viewW <= 1 then
			return false
		end
		local g = math.max(gutter, 8)
		local p = math.max(pad, 8)
		local scrollBar = 6
		local usable = math.max(viewW - p * 2 - scrollBar, 80)
		local colW = math.max(math.floor((usable - g) / 2), 40)
	
		row.Size = UDim2.new(0, usable, 0, 0)
		row.Position = UDim2.new(0, p, 0, p)
	
		left.Size = UDim2.new(0, colW, 0, 0)
		left.Position = UDim2.new(0, 0, 0, 0)
		right.Size = UDim2.new(0, colW, 0, 0)
		right.Position = UDim2.new(0, colW + g, 0, 0)
		return true
	end
	
	function Pages.render(hub)
		hub._pageMaid:DoCleaning()
		hub._bindings = {}
	
		for _, child in ipairs(hub.pageContainer:GetChildren()) do
			child:Destroy()
		end
		if hub.overlay then
			for _, child in ipairs(hub.overlay:GetChildren()) do
				child:Destroy()
			end
		end
		hub.pages = {}
		hub._layoutHooks = {}
	
		local query = hub.searchQuery or ""
		local gcfg = hub.config.group or {}
		local gap = gcfg.gap or 7
		local pad = gcfg.padding or 14
		local columns = math.max(1, gcfg.columns or 2)
		local gutter = gcfg.gutter or 12
	
		for _, tab in ipairs(hub.tabs) do
			local page = Create("Frame", {
				Name = tab.name,
				Parent = hub.pageContainer,
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Visible = tab == hub.activeTab,
			})
			hub.pages[tab] = page
	
			local scroll = Create("ScrollingFrame", {
				Name = "PageScroll",
				Parent = page,
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ScrollBarThickness = 4,
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				ClipsDescendants = true,
			})
			-- Vertical pad only via top offset on row; horizontal pad baked into layoutTwoColumns.
			-- (UIPadding on ScrollingFrame does not reliably shrink child AbsoluteSize.)
	
			local row = Create("Frame", {
				Name = "Columns",
				Parent = scroll,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				AutomaticSize = Enum.AutomaticSize.Y,
			})
	
			local cols = {}
	
			if columns == 1 then
				local col = Create("Frame", {
					Name = "Column1",
					Parent = row,
					Size = UDim2.new(1, 0, 0, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
				})
				addColumnList(col, gap)
				cols[1] = col
	
				local function relayout1()
					local viewW = scroll.AbsoluteSize.X
					if viewW <= 0 then
						return
					end
					local usable = math.max(viewW - pad * 2 - 6, 80)
					row.Size = UDim2.new(0, usable, 0, 0)
					row.Position = UDim2.new(0, pad, 0, pad)
					col.Size = UDim2.new(1, 0, 0, 0)
				end
				hub._pageMaid:Connect(scroll:GetPropertyChangedSignal("AbsoluteSize"), relayout1)
				task.defer(relayout1)
			elseif columns == 2 then
				local left = Create("Frame", {
					Name = "Column1",
					Parent = row,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
				})
				addColumnList(left, gap)
				cols[1] = left
	
				local right = Create("Frame", {
					Name = "Column2",
					Parent = row,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
				})
				addColumnList(right, gap)
				cols[2] = right
	
				local function relayout()
					layoutTwoColumns(scroll, row, left, right, gutter, pad)
				end
				hub._pageMaid:Connect(scroll:GetPropertyChangedSignal("AbsoluteSize"), relayout)
				hub._pageMaid:Connect(page:GetPropertyChangedSignal("AbsoluteSize"), relayout)
				if hub.window then
					hub._pageMaid:Connect(hub.window:GetPropertyChangedSignal("AbsoluteSize"), relayout)
				end
				table.insert(hub._layoutHooks, relayout)
				task.defer(relayout)
				task.delay(0.05, relayout)
				task.delay(0.2, relayout)
			else
				Create("UIPadding", {
					Parent = scroll,
					PaddingLeft = UDim.new(0, pad),
					PaddingRight = UDim.new(0, pad),
					PaddingTop = UDim.new(0, pad),
					PaddingBottom = UDim.new(0, pad),
				})
				local shrink = math.ceil(gutter * (columns - 1) / columns)
				row.Size = UDim2.new(1, 0, 0, 0)
				Create("UIListLayout", {
					Parent = row,
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, gutter),
					SortOrder = Enum.SortOrder.LayoutOrder,
				})
				for c = 1, columns do
					local col = Create("Frame", {
						Name = "Column" .. c,
						Parent = row,
						Size = UDim2.new(1 / columns, -shrink, 0, 0),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						AutomaticSize = Enum.AutomaticSize.Y,
						LayoutOrder = c,
					})
					addColumnList(col, gap)
					cols[c] = col
				end
			end
	
			local groups = tab.groups or tab.sections or {}
			local visibleIndex = 0
			for _, group in ipairs(groups) do
				local visible, elements = Filter.groupVisible(group, query)
				if visible then
					visibleIndex = visibleIndex + 1
					local colIndex = ((visibleIndex - 1) % columns) + 1
					Groups.render(hub, group, cols[colIndex], visibleIndex, elements)
				end
			end
		end
	end
	
	return Pages
end

__modules["navigation/Sections"] = function(__require)
	-- Compat shim: use navigation.Groups (square group cards).
	return __require("navigation/Groups")
end

__modules["navigation/Sidebar"] = function(__require)
	-- Sidebar: text-only tabs (no icons / emoji), names always centered.
	
	local CreateMod = __require("visual/Create")
	
	local Create = CreateMod.Create
	local TextLabel = CreateMod.TextLabel
	
	local Sidebar = {}
	
	function Sidebar.render(hub)
		local maid = hub._navMaid
		for _, child in ipairs(hub.navContainer:GetChildren()) do
			child:Destroy()
		end
		hub.navButtons = {}
	
		Create("UIListLayout", {
			Parent = hub.navContainer,
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
		Create("UIPadding", {
			Parent = hub.navContainer,
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 8),
		})
	
		for _, tab in ipairs(hub.tabs) do
			local btn = Create("TextButton", {
				Parent = hub.navContainer,
				Size = UDim2.new(1, 0, 0, 38),
				BackgroundColor3 = hub.config.colors.bg,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Text = "",
			})
	
			local label = TextLabel(btn, tab.name, 16, hub.config.colors.textSoft, hub.config.font)
			label.Position = UDim2.new(0, 0, 0, 0)
			label.Size = UDim2.new(1, 0, 1, 0)
			label.TextXAlignment = Enum.TextXAlignment.Center
			label.TextYAlignment = Enum.TextYAlignment.Center
	
			maid:Connect(btn.MouseEnter, function()
				if tab ~= hub.activeTab then
					hub:tween(btn, {
						BackgroundTransparency = 0.85,
						BackgroundColor3 = hub.config.colors.surfaceHover,
					})
				end
			end)
			maid:Connect(btn.MouseLeave, function()
				if tab ~= hub.activeTab then
					hub:tween(btn, { BackgroundTransparency = 1 })
				end
			end)
			maid:Connect(btn.MouseButton1Click, function()
				hub:activateTab(tab)
			end)
	
			hub.navButtons[tab] = { btn = btn, label = label }
		end
	
		Sidebar.updateHighlight(hub)
	end
	
	function Sidebar.updateHighlight(hub)
		for tab, data in pairs(hub.navButtons) do
			local active = tab == hub.activeTab
			hub:tween(data.btn, {
				BackgroundTransparency = active and 0.92 or 1,
				BackgroundColor3 = active and hub.config.colors.purple or hub.config.colors.bg,
			})
			hub:tween(data.label, {
				TextColor3 = active and hub.config.colors.text or hub.config.colors.textSoft,
			})
		end
	end
	
	return Sidebar
end

__modules["util/Errors"] = function(__require)
	-- Explicit framework errors (PRIME-A10). rule_id in message for observability.
	
	local Errors = {}
	
	function Errors.fail(ruleId, message)
		error(("[MawyxxHub.%s] %s"):format(ruleId, message), 2)
	end
	
	function Errors.expect(condition, ruleId, message)
		if not condition then
			Errors.fail(ruleId, message)
		end
	end
	
	return Errors
end

__modules["util/Maid"] = function(__require)
	-- Connection / cleanup bag. Disconnects RBX connections, runs functions, destroys Instances/Maids.
	
	local Maid = {}
	Maid.__index = Maid
	
	function Maid.new()
		return setmetatable({ _tasks = {} }, Maid)
	end
	
	function Maid:Give(task)
		if task ~= nil then
			table.insert(self._tasks, task)
		end
		return task
	end
	
	function Maid:Connect(signal, handler)
		local connection = signal:Connect(handler)
		self:Give(connection)
		return connection
	end
	
	local function cleanupOne(task)
		local ty = typeof(task)
		if ty == "RBXScriptConnection" then
			task:Disconnect()
		elseif ty == "Instance" then
			task:Destroy()
		elseif type(task) == "function" then
			task()
		elseif type(task) == "table" then
			if type(task.DoCleaning) == "function" then
				task:DoCleaning()
			elseif type(task.Destroy) == "function" then
				task:Destroy()
			elseif type(task.Disconnect) == "function" then
				task:Disconnect()
			end
		end
	end
	
	function Maid:DoCleaning()
		for i = #self._tasks, 1, -1 do
			local task = self._tasks[i]
			self._tasks[i] = nil
			cleanupOne(task)
		end
	end
	
	function Maid:Destroy()
		self:DoCleaning()
		setmetatable(self, nil)
	end
	
	return Maid
end

__modules["visual/Create"] = function(__require)
	-- Instance construction helpers (no GetService).
	
	local function Create(className, properties)
		local obj = Instance.new(className)
		for prop, val in pairs(properties or {}) do
			obj[prop] = val
		end
		return obj
	end
	
	local function Corner(parent, radius)
		return Create("UICorner", {
			Parent = parent,
			CornerRadius = UDim.new(0, radius or 0),
		})
	end
	
	local function Stroke(parent, color, thickness, transparency)
		return Create("UIStroke", {
			Parent = parent,
			Color = color or Color3.fromRGB(31, 31, 33),
			Thickness = thickness or 1,
			Transparency = transparency or 0,
		})
	end
	
	local function Padding(parent, left, right, top, bottom)
		return Create("UIPadding", {
			Parent = parent,
			PaddingLeft = UDim.new(0, left or 0),
			PaddingRight = UDim.new(0, right or 0),
			PaddingTop = UDim.new(0, top or 0),
			PaddingBottom = UDim.new(0, bottom or 0),
		})
	end
	
	local function TextLabel(parent, text, size, color, font)
		return Create("TextLabel", {
			Parent = parent,
			BackgroundTransparency = 1,
			Text = text,
			TextColor3 = color or Color3.fromRGB(224, 224, 226),
			TextSize = size or 14,
			Font = font or Enum.Font.Code,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			BorderSizePixel = 0,
		})
	end
	
	return {
		Create = Create,
		Corner = Corner,
		Stroke = Stroke,
		Padding = Padding,
		TextLabel = TextLabel,
	}
end

__modules["window/Build"] = function(__require)
	-- Builds ScreenGui shell: sidebar (scroll), topbar + live search, content, footer, overlay.
	
	local CreateMod = __require("visual/Create")
	
	local Create = CreateMod.Create
	local Stroke = CreateMod.Stroke
	local Corner = CreateMod.Corner
	local TextLabel = CreateMod.TextLabel
	
	local Build = {}
	
	function Build.window(hub)
		local config = hub.config
		local guiHost = hub.deps.guiHost
		local textMetrics = hub.deps.textMetrics
	
		guiHost.DestroyNamed("MawyxxHub")
	
		local screenGui = Create("ScreenGui", {
			Name = "MawyxxHub",
			Parent = guiHost.GetPlayerGui(),
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		})
		hub.screenGui = screenGui
		hub._maid:Give(screenGui)
	
		local sideW = (config.window and config.window.sidebarWidth) or 168
	
		local window = Create("Frame", {
			Name = "Window",
			Parent = screenGui,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(0, config.window.width, 0, config.window.height),
			BackgroundColor3 = config.colors.bg,
			BorderSizePixel = 0,
			ClipsDescendants = true,
		})
		hub.window = window
		Stroke(window, config.colors.border, 1)
	
		local sidebar = Create("Frame", {
			Name = "Sidebar",
			Parent = window,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(0, sideW, 1, 0),
			BackgroundColor3 = config.colors.bg,
			BorderSizePixel = 0,
		})
		hub.sidebar = sidebar
		Create("Frame", {
			Parent = sidebar,
			Position = UDim2.new(1, -1, 0, 0),
			Size = UDim2.new(0, 1, 1, 0),
			BackgroundColor3 = config.colors.border,
			BorderSizePixel = 0,
		})
	
		local brand = config.brand or {}
		local prefix = brand.prefix or "Mawyxx"
		local accent = brand.accent or "Hub"
		local prefixWidth = textMetrics.Measure(prefix, config.font, 20)
	
		local brandLabel = TextLabel(sidebar, prefix, 20, config.colors.text, config.font)
		brandLabel.Position = UDim2.new(0, 20, 0, 17)
		brandLabel.Size = UDim2.new(0, prefixWidth + 4, 0, 32)
	
		local brandPurple = TextLabel(sidebar, accent, 20, config.colors.purple, config.font)
		brandPurple.Position = UDim2.new(0, 20 + prefixWidth, 0, 17)
		brandPurple.Size = UDim2.new(0, 60, 0, 32)
	
		local navContainer = Create("ScrollingFrame", {
			Name = "Navigation",
			Parent = sidebar,
			Position = UDim2.new(0, 0, 0, 62),
			Size = UDim2.new(1, 0, 1, -70),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 3,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
		})
		hub.navContainer = navContainer
		hub.navButtons = {}
	
		local topbar = Create("Frame", {
			Name = "Topbar",
			Parent = window,
			Position = UDim2.new(0, sideW, 0, 0),
			Size = UDim2.new(1, -sideW, 0, 51),
			BackgroundColor3 = config.colors.bg,
			BorderSizePixel = 0,
		})
		hub.topbar = topbar
		Create("Frame", {
			Parent = topbar,
			Position = UDim2.new(0, 0, 1, -1),
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = config.colors.border,
			BorderSizePixel = 0,
		})
	
		local searchEnabled = config.search == nil or config.search.enabled ~= false
		local placeholder = (config.search and config.search.placeholder) or "Search"
	
		local search = Create("TextBox", {
			Parent = topbar,
			Position = UDim2.new(0, 10, 0, 8),
			Size = UDim2.new(1, -56, 0, 34),
			BackgroundColor3 = config.colors.surface,
			Text = "",
			PlaceholderText = searchEnabled and placeholder or "Search disabled",
			PlaceholderColor3 = config.colors.textMuted,
			TextColor3 = config.colors.text,
			TextSize = 14,
			Font = config.font,
			ClearTextOnFocus = false,
			BorderSizePixel = 0,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextEditable = searchEnabled,
		})
		Stroke(search, config.colors.borderSoft, 1)
		hub.searchBox = search
	
		local searchIcon = TextLabel(topbar, "⌕", 23, config.colors.textSoft, config.font)
		searchIcon.Position = UDim2.new(0, 18, 0, 7)
		searchIcon.Size = UDim2.new(0, 25, 0, 35)
	
		if searchEnabled then
			hub._maid:Connect(search:GetPropertyChangedSignal("Text"), function()
				hub.searchQuery = search.Text
				hub:_refreshPages()
			end)
		end
	
		local closeRed = Color3.fromRGB(220, 55, 60)
		local closeRedSoft = Color3.fromRGB(48, 14, 16)
		local closeRedHover = Color3.fromRGB(255, 72, 78)
		local closeBtn = Create("TextButton", {
			Name = "Close",
			Parent = topbar,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(30, 30),
			BackgroundColor3 = closeRedSoft,
			BorderSizePixel = 0,
			Text = "×",
			TextColor3 = closeRed,
			TextSize = 22,
			Font = config.font,
			AutoButtonColor = false,
			ZIndex = 5,
		})
		Corner(closeBtn, 6)
		Stroke(closeBtn, Color3.fromRGB(160, 40, 48), 1)
		hub.closeButton = closeBtn
	
		hub._maid:Connect(closeBtn.MouseEnter, function()
			hub:tween(closeBtn, {
				BackgroundColor3 = Color3.fromRGB(70, 18, 22),
				TextColor3 = closeRedHover,
			})
		end)
		hub._maid:Connect(closeBtn.MouseLeave, function()
			hub:tween(closeBtn, {
				BackgroundColor3 = closeRedSoft,
				TextColor3 = closeRed,
			})
		end)
		hub._maid:Connect(closeBtn.MouseButton1Click, function()
			if hub._setOpen then
				hub._setOpen(false)
			end
		end)
	
		local content = Create("Frame", {
			Name = "Content",
			Parent = window,
			Position = UDim2.new(0, sideW, 0, 51),
			Size = UDim2.new(1, -sideW, 1, -77),
			BackgroundColor3 = config.colors.bg,
			BorderSizePixel = 0,
			ClipsDescendants = true,
		})
		hub.content = content
		hub.pageContainer = content
	
		local overlay = Create("Frame", {
			Name = "Overlay",
			Parent = window,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 200,
			Visible = true,
		})
		hub.overlay = overlay
	
		local footer = Create("Frame", {
			Parent = window,
			Position = UDim2.new(0, sideW, 1, -26),
			Size = UDim2.new(1, -sideW, 0, 26),
			BackgroundColor3 = config.colors.bg,
			BorderSizePixel = 0,
		})
		Create("Frame", {
			Parent = footer,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = config.colors.border,
			BorderSizePixel = 0,
		})
	
		local footerText = TextLabel(footer, brand.footer or "Mawyxx / Hub", 11, config.colors.textMuted, config.font)
		footerText.AnchorPoint = Vector2.new(0.5, 0)
		footerText.Position = UDim2.new(0.5, 0, 0, 2)
		footerText.Size = UDim2.new(0, 140, 0, 22)
		footerText.TextXAlignment = Enum.TextXAlignment.Center
	
		hub.pages = {}
		hub.searchQuery = ""
	end
	
	return Build
end

__modules["window/Drag"] = function(__require)
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
end

__modules["window/Shortcuts"] = function(__require)
	-- Open: thin center strip expands up+down. Close: collapses into center strip. Linear.
	
	local OPEN_INFO = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local CLOSE_INFO = TweenInfo.new(0.08, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
	local OPEN_MS = 0.11
	local CLOSE_MS = 0.09
	
	local Shortcuts = {}
	
	function Shortcuts.setup(hub)
		local input = hub.deps.input
		local startHidden = hub.config.startHidden
		if startHidden == nil then
			startHidden = true
		end
	
		local w = hub.config.window.width
		local h = hub.config.window.height
		local FULL = UDim2.fromOffset(w, h)
		-- Horizontal strip through the menu center (collapse / grow pivot)
		local STRIP = UDim2.fromOffset(w, 2)
	
		hub.window.AnchorPoint = Vector2.new(0.5, 0.5)
		hub.window.Position = UDim2.fromScale(0.5, 0.5)
		hub.window.ClipsDescendants = true
	
		-- Remove old scale anim if present
		local oldScale = hub.window:FindFirstChildOfClass("UIScale")
		if oldScale then
			oldScale:Destroy()
		end
	
		local visible = not startHidden
		hub.window.Visible = visible
		hub.window.Size = visible and FULL or STRIP
	
		local animToken = 0
	
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
			if hub._destroyed then
				return
			end
			if open == visible and hub.window.Visible == open then
				return
			end
	
			animToken += 1
			local token = animToken
			visible = open
	
			hub.window.AnchorPoint = Vector2.new(0.5, 0.5)
			hub.window.Position = UDim2.fromScale(0.5, 0.5)
	
			if open then
				hub.window.Visible = true
				hub.window.Size = STRIP
				-- Width already full — layout columns once, height reveal only clips
				runLayouts()
				task.defer(runLayouts)
	
				if hub.config.animations == false then
					hub.window.Size = FULL
					runLayouts()
					return
				end
	
				hub:tween(hub.window, { Size = FULL }, OPEN_INFO)
				task.delay(OPEN_MS, function()
					if token == animToken and not hub._destroyed then
						hub.window.Size = FULL
						runLayouts()
					end
				end)
			else
				if hub.config.animations == false then
					hub.window.Size = STRIP
					hub.window.Visible = false
					return
				end
	
				hub:tween(hub.window, { Size = STRIP }, CLOSE_INFO)
				task.delay(CLOSE_MS, function()
					if token ~= animToken or hub._destroyed then
						return
					end
					if not visible then
						hub.window.Size = STRIP
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
end


-- ===== INLINE DEMO =====
-- Inline demo body (appended by bundle into dist/___RUN_HSV.lua). No HttpGet.

print("[MawyxxHub] BUILD=UI_V12_SINGLEFILE")

local MawyxxHub = __require("init")
assert(type(MawyxxHub) == "table" and MawyxxHub.new, "[MawyxxHub] init failed")

local hub = MawyxxHub.new({
	window = { title = "MawyxxHub Demo", width = 920, height = 600, sidebarWidth = 156 },
	brand = { prefix = "Mawyxx", accent = "Hub", footer = "Demo / HSV V4" },
	startHidden = true,
	group = {
		columns = 2,
		gap = 10,
		gutter = 14,
		padding = 14,
		innerPadding = 12,
	},
})

local combat = hub:addTab("Combat")
local visuals = hub:addTab("Visuals")
local player = hub:addTab("Player")
local misc = hub:addTab("Misc")

local aim = hub:addGroup(combat, "Aim")
local guns = hub:addGroup(combat, "Weapons")
local rage = hub:addGroup(combat, "Rage")

hub:addToggle(aim, "Enabled", "demo_aim_on", false)
hub:addSlider(aim, "FOV", "demo_aim_fov", 10, 180, 1, 75)
hub:addDropdown(aim, "Target", "demo_aim_target", { "Closest", "Lowest HP", "Crosshair" }, "Closest")
hub:addColorPicker(aim, "FOV color", "demo_aim_color", Color3.fromRGB(117, 72, 255))

hub:addToggle(guns, "No recoil", "demo_norecoil", true)
hub:addSlider(guns, "Spread", "demo_spread", 0, 100, 1, 20)
hub:addButton(guns, "Reload config", function() end)

hub:addToggle(rage, "Auto fire", "demo_autofire", false)
hub:addToggle(rage, "Silent", "demo_silent", false)
hub:addSlider(rage, "Hit chance", "demo_hitchance", 0, 100, 5, 80)

local esp = hub:addGroup(visuals, "ESP")
local world = hub:addGroup(visuals, "World")

hub:addToggle(esp, "Boxes", "demo_esp_box", true)
hub:addToggle(esp, "Names", "demo_esp_names", true)
hub:addToggle(esp, "Tracers", "demo_esp_tracers", false)
hub:addColorPicker(esp, "Box color", "demo_esp_color", Color3.fromRGB(80, 200, 120))
hub:addDropdown(esp, "Box style", "demo_esp_style", { "Full", "Corner", "3D" }, "Corner")

hub:addToggle(world, "Fullbright", "demo_fullbright", false)
hub:addSlider(world, "Fog", "demo_fog", 0, 100, 1, 40)
hub:addButton(world, "Reset lighting", function()
	hub:set("demo_fog", 40)
	hub:set("demo_fullbright", false)
end)

local move = hub:addGroup(player, "Movement")
local cam = hub:addGroup(player, "Camera")

hub:addToggle(move, "Speed", "demo_speed_on", false)
hub:addSlider(move, "WalkSpeed", "demo_walkspeed", 16, 120, 1, 16)
hub:addToggle(move, "Fly", "demo_fly", false)
hub:addSlider(move, "Fly speed", "demo_flyspeed", 10, 200, 5, 50)

hub:addSlider(cam, "FOV", "demo_cam_fov", 50, 120, 1, 70)
hub:addToggle(cam, "Third person", "demo_thirdperson", false)

local ui = hub:addGroup(misc, "UI")
local danger = hub:addGroup(misc, "Session")

hub:addToggle(ui, "Animations", "demo_ui_anim", true)
hub:addDropdown(ui, "Accent", "demo_accent", { "Purple", "Blue", "Red" }, "Purple")
hub:addButton(ui, "Print flags", function()
	print("aim", hub:get("demo_aim_on"), "fov", hub:get("demo_aim_fov"))
end)

hub:addButton(danger, "Destroy hub", function()
	hub:Destroy()
end)

print("[MawyxxHub] Demo ready — RightShift — click color square for HSV picker")
