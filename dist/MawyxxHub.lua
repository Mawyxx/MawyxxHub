-- MawyxxHub — main framework bundle. Auto-generated; do not edit.
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
	local RunService = game:GetService("RunService")
	
	local RobloxInput = {}
	
	function RobloxInput.GetMouseLocation()
		return UserInputService:GetMouseLocation()
	end
	
	-- Mouse in GuiObject.AbsolutePosition space (GetMouseLocation is screen; AbsolutePosition is inset-shifted).
	function RobloxInput.GetMouseLocationGui()
		return UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
	end
	
	function RobloxInput.SetMouseIconEnabled(enabled)
		UserInputService.MouseIconEnabled = enabled and true or false
	end
	
	RobloxInput.InputBegan = UserInputService.InputBegan
	RobloxInput.InputChanged = UserInputService.InputChanged
	RobloxInput.InputEnded = UserInputService.InputEnded
	RobloxInput.RenderStepped = RunService.RenderStepped
	
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
	-- QuantHub-inspired palette: layered depth, muted accent, clean sans.
	
	local Defaults = {
		window = {
			width = 920,
			height = 600,
			sidebarWidth = 156,
			title = "MawyxxHub",
		},
		colors = {
			-- Chrome (deepest)
			bg = Color3.fromRGB(17, 17, 17),
			-- Group / panel lift
			surface = Color3.fromRGB(22, 22, 22),
			surface2 = Color3.fromRGB(28, 28, 28),
			surfaceHover = Color3.fromRGB(34, 34, 34),
			-- Controls sit near-black, not pure #000 (less harsh)
			control = Color3.fromRGB(10, 10, 10),
			controlHover = Color3.fromRGB(26, 26, 26),
			border = Color3.fromRGB(36, 36, 36),
			borderSoft = Color3.fromRGB(30, 30, 30),
			text = Color3.fromRGB(255, 255, 255),
			textSoft = Color3.fromRGB(160, 160, 160),
			textMuted = Color3.fromRGB(120, 120, 120),
			-- Muted lavender accent (less neon than raw #7B52FF)
			purple = Color3.fromRGB(118, 100, 200),
			purpleHover = Color3.fromRGB(138, 120, 215),
			purpleDark = Color3.fromRGB(90, 74, 160),
			white = Color3.fromRGB(255, 255, 255),
		},
		font = Enum.Font.Code,
		animations = true,
		settingsTable = "MawyxxHubSettings",
		toggleKey = Enum.KeyCode.RightControl,
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
			paddingLeft = 14,
			paddingRight = 10,
			scrollBarGutter = 6,
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
		  GetMouseLocationGui() -> Vector2  (AbsolutePosition space)
		  SetMouseIconEnabled(boolean)?
		  InputBegan, InputChanged, InputEnded : RBXScriptSignal
		  RenderStepped? : RBXScriptSignal
	
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
		  Session-scoped by default (_G); swap adapter for persistence.
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
		hub._pageMaid:Connect(btn.MouseEnter, function()
			hub:tween(btn, { BackgroundColor3 = controlHover })
		end)
		hub._pageMaid:Connect(btn.MouseLeave, function()
			hub:tween(btn, { BackgroundColor3 = control })
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
	-- mountSwatch() is shared by colorpicker + togglecolor rows.
	
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
	
	--- Wire an existing swatch button to the HSV panel + settings flag.
	-- opts: { flag, default, callback }
	function ColorPicker.mountSwatch(hub, swatch, opts)
		local config = hub.config
		local input = hub.deps.input
		local flag = opts.flag
		local color = hub.settings[flag]
		if typeof(color) ~= "Color3" then
			color = opts.default
		end
		if typeof(color) ~= "Color3" then
			color = Color3.fromRGB(117, 72, 255)
		end
		hub.deps.settings.Set(hub.settings, flag, color)
		swatch.BackgroundColor3 = color
	
		local panelW = PANEL_PAD + SV + GAP + HUE_W + PANEL_PAD
		local panelH = PANEL_PAD + 18 + GAP + SV + GAP + PREVIEW_H + GAP + BTN_H + PANEL_PAD
	
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
			if typeof(newColor) ~= "Color3" then
				return
			end
			color = newColor
			committed = newColor
			hub.deps.settings.Set(hub.settings, flag, newColor)
			swatch.BackgroundColor3 = newColor
			if fireCallback and type(opts.callback) == "function" then
				opts.callback(newColor)
			end
		end
	
		local function closePanel()
			open = false
			draggingSV = false
			draggingHue = false
			panel.Visible = false
		end
	
		local function mouseXY()
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
	end
	
	function ColorPicker.build(hub, element)
		local config = hub.config
	
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
			Size = UDim2.new(0, 16, 0, 16),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 5,
		})
		Stroke(swatch, config.colors.borderSoft, 1, 0.4)
		Corner(swatch, 2)
	
		ColorPicker.mountSwatch(hub, swatch, {
			flag = element.flag,
			default = element.default,
			callback = element.callback,
		})
	
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
		local input = hub.deps.input
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
	
		local control = config.colors.control or config.colors.surface2
		local controlHover = config.colors.controlHover or config.colors.surfaceHover
	
		local btn = Create("TextButton", {
			Parent = row,
			Position = UDim2.new(0, 0, 0, 20),
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundColor3 = control,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 21,
		})
		Stroke(btn, config.colors.borderSoft, 1, 0.45)
	
		local currentText = TextLabel(btn, tostring(selected), 14, config.colors.text, config.font)
		currentText.Position = UDim2.new(0, 9, 0, 0)
		currentText.Size = UDim2.new(1, -35, 1, 0)
	
		local arrow = TextLabel(btn, "v", 14, config.colors.textSoft, config.font)
		arrow.Position = UDim2.new(1, -25, 0, 0)
		arrow.Size = UDim2.new(0, 20, 1, 0)
		arrow.TextXAlignment = Enum.TextXAlignment.Center
	
		local open = false
		local maxVisible = 8
		local rowH = 27
		local listH = math.min(#options, maxVisible) * rowH
		local list = Create("ScrollingFrame", {
			Name = "DropdownList",
			Parent = hub.overlay,
			Size = UDim2.new(0, 100, 0, listH),
			BackgroundColor3 = control,
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = 250,
			ScrollBarThickness = 3,
			CanvasSize = UDim2.new(0, 0, 0, #options * rowH),
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ClipsDescendants = true,
		})
		Stroke(list, config.colors.border, 1)
		hub._pageMaid:Give(list)
	
		Create("UIListLayout", {
			Parent = list,
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
	
		local function closeList()
			open = false
			list.Visible = false
			arrow.Text = "⌄"
		end
	
		local function apply(opt, fireCallback)
			selected = opt
			hub.deps.settings.Set(hub.settings, flag, opt)
			currentText.Text = tostring(opt)
			closeList()
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
				Size = UDim2.new(1, 0, 0, rowH),
				BackgroundColor3 = control,
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
					BackgroundColor3 = controlHover,
					TextColor3 = config.colors.text,
				})
			end)
			hub._pageMaid:Connect(optBtn.MouseLeave, function()
				hub:tween(optBtn, {
					BackgroundColor3 = control,
					TextColor3 = config.colors.textSoft,
				})
			end)
			hub._pageMaid:Connect(optBtn.MouseButton1Click, function()
				apply(opt, true)
			end)
		end
	
		local function reposition()
			if not open then
				return
			end
			local pos = btn.AbsolutePosition
			local size = btn.AbsoluteSize
			local parentPos = hub.overlay.AbsolutePosition
			list.Position = UDim2.fromOffset(pos.X - parentPos.X, pos.Y - parentPos.Y + size.Y + 2)
			list.Size = UDim2.fromOffset(size.X, listH)
		end
	
		hub._pageMaid:Connect(btn:GetPropertyChangedSignal("AbsolutePosition"), reposition)
		hub._pageMaid:Connect(btn:GetPropertyChangedSignal("AbsoluteSize"), reposition)
		if hub.window then
			hub._pageMaid:Connect(hub.window:GetPropertyChangedSignal("AbsoluteSize"), reposition)
		end
	
		hub._pageMaid:Connect(btn.MouseButton1Click, function()
			open = not open
			if open then
				reposition()
				list.Visible = true
				arrow.Text = "⌃"
			else
				closeList()
			end
		end)
	
		-- Click outside closes list
		hub._pageMaid:Connect(input.InputBegan, function(inp)
			if not open then
				return
			end
			if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end
			local getter = input.GetMouseLocationGui or input.GetMouseLocation
			local m = getter()
			local lp = list.AbsolutePosition
			local ls = list.AbsoluteSize
			local bp = btn.AbsolutePosition
			local bs = btn.AbsoluteSize
			local inList = m.X >= lp.X and m.X <= lp.X + ls.X and m.Y >= lp.Y and m.Y <= lp.Y + ls.Y
			local inBtn = m.X >= bp.X and m.X <= bp.X + bs.X and m.Y >= bp.Y and m.Y <= bp.Y + bs.Y
			if not inList and not inBtn then
				closeList()
			end
		end)
	
		return row
	end
	
	return Dropdown
end

__modules["controls/Factory"] = function(__require)
	local Errors = __require("util/Errors")
	local Toggle = __require("controls/Toggle")
	local ToggleColor = __require("controls/ToggleColor")
	local Slider = __require("controls/Slider")
	local Dropdown = __require("controls/Dropdown")
	local Button = __require("controls/Button")
	local ColorPicker = __require("controls/ColorPicker")
	
	local builders = {
		toggle = Toggle.build,
		togglecolor = ToggleColor.build,
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
		local step = element.step
		if type(step) ~= "number" or step <= 0 then
			step = 1
		end
		local val = hub.settings[flag]
		if type(val) ~= "number" then
			val = element.default
		end
		if type(val) ~= "number" then
			val = min
		end
		val = math.clamp(val, min, max)
		-- Snap once to the caller-defined step (default 1)
		val = math.clamp(math.round(val / step) * step, min, max)
		hub.deps.settings.Set(hub.settings, flag, val)
	
		local row = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 48),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		})
	
		local label = TextLabel(row, element.label, 14, config.colors.text, config.font)
		label.Size = UDim2.new(1, 0, 0, 20)
		label.TextXAlignment = Enum.TextXAlignment.Left
	
		local track = Create("TextButton", {
			Parent = row,
			Position = UDim2.new(0, 0, 0, 26),
			Size = UDim2.new(1, 0, 0, 16),
			BackgroundColor3 = config.colors.control or config.colors.surface2,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
		})
		Stroke(track, config.colors.borderSoft, 1, 0.5)
	
		local fill = Create("Frame", {
			Parent = track,
			Size = UDim2.new((val - min) / math.max(max - min, 1e-9), 0, 1, 0),
			BackgroundColor3 = config.colors.purple,
			BorderSizePixel = 0,
			ZIndex = 1,
		})
	
		-- Value centered in track (QuantHub-style)
		local valueLabel = TextLabel(track, tostring(val) .. " / " .. tostring(max), 11, config.colors.textSoft, config.font)
		valueLabel.Size = UDim2.fromScale(1, 1)
		valueLabel.TextXAlignment = Enum.TextXAlignment.Center
		valueLabel.ZIndex = 2
	
		local dragging = false
	
		local function apply(newVal, fireCallback)
			newVal = math.clamp(newVal, min, max)
			newVal = math.round(newVal / step) * step
			newVal = math.clamp(newVal, min, max)
			val = newVal
			hub.deps.settings.Set(hub.settings, flag, val)
			fill.Size = UDim2.new((val - min) / math.max(max - min, 1e-9), 0, 1, 0)
			valueLabel.Text = tostring(val) .. " / " .. tostring(max)
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
			local getter = input.GetMouseLocationGui or input.GetMouseLocation
			local mouseX = inputX
			if mouseX == nil then
				mouseX = getter().X
			end
			local rel = math.clamp((mouseX - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
			apply(min + (max - min) * rel, true)
		end
	
		hub._pageMaid:Connect(track.MouseButton1Down, function()
			dragging = true
			local getter = input.GetMouseLocationGui or input.GetMouseLocation
			updateFromX(getter().X)
		end)
		hub._pageMaid:Connect(input.InputChanged, function(inp)
			if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
				local getter = input.GetMouseLocationGui or input.GetMouseLocation
				updateFromX(getter().X)
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
		if type(state) ~= "boolean" then
			state = element.default
		end
		if type(state) ~= "boolean" then
			state = false
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
	
		local offColor = config.colors.control or config.colors.surface2
		local toggleBtn = Create("TextButton", {
			Parent = row,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.new(0, 50, 0, 22),
			BackgroundColor3 = state and config.colors.purple or offColor,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
		})
		Create("UIPadding", {
			Parent = row,
			PaddingRight = UDim.new(0, 4),
		})
		Corner(toggleBtn, 11)
		-- Soft edge instead of hard stroke
		Stroke(toggleBtn, config.colors.borderSoft, 1, 0.55)
	
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
				BackgroundColor3 = state and config.colors.purple or offColor,
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

__modules["controls/ToggleColor"] = function(__require)
	-- Toggle + color swatch on one row (QuantHub-style: name [■] [toggle]).
	
	local CreateMod = __require("visual/Create")
	local ColorPicker = __require("controls/ColorPicker")
	
	local Create = CreateMod.Create
	local Corner = CreateMod.Corner
	local Stroke = CreateMod.Stroke
	local TextLabel = CreateMod.TextLabel
	
	local ToggleColor = {}
	
	function ToggleColor.build(hub, element)
		local config = hub.config
		local flag = element.flag
		local colorFlag = element.colorFlag
	
		local state = hub.settings[flag]
		if type(state) ~= "boolean" then
			state = element.default
		end
		if type(state) ~= "boolean" then
			state = false
		end
		hub.deps.settings.Set(hub.settings, flag, state)
	
		local row = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		})
		Create("UIPadding", {
			Parent = row,
			PaddingRight = UDim.new(0, 4),
		})
	
		local label = TextLabel(row, element.label, 14, config.colors.text, config.font)
		label.Size = UDim2.new(1, -90, 1, 0)
		label.TextXAlignment = Enum.TextXAlignment.Left
	
		local offColor = config.colors.control or config.colors.surface2
		local toggleBtn = Create("TextButton", {
			Parent = row,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.new(0, 50, 0, 22),
			BackgroundColor3 = state and config.colors.purple or offColor,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 4,
		})
		Corner(toggleBtn, 11)
		Stroke(toggleBtn, config.colors.borderSoft, 1, 0.55)
	
		local knob = Create("Frame", {
			Parent = toggleBtn,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
			Size = UDim2.new(0, 16, 0, 16),
			BackgroundColor3 = config.colors.white,
			BorderSizePixel = 0,
		})
		Corner(knob, 20)
	
		-- Color square just left of the toggle
		local swatch = Create("TextButton", {
			Parent = row,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -58, 0.5, 0),
			Size = UDim2.new(0, 16, 0, 16),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 5,
		})
		Stroke(swatch, config.colors.borderSoft, 1, 0.4)
		Corner(swatch, 2)
	
		ColorPicker.mountSwatch(hub, swatch, {
			flag = colorFlag,
			default = element.colorDefault or Color3.new(1, 1, 1),
			callback = element.colorCallback,
		})
	
		local function apply(newState)
			state = newState and true or false
			hub.deps.settings.Set(hub.settings, flag, state)
			hub:tween(toggleBtn, {
				BackgroundColor3 = state and config.colors.purple or offColor,
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
	
	return ToggleColor
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
		function api.SetMouseIconEnabled(_enabled) end
		api.RenderStepped = makeSignal()
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
	-- Batch updates, unique flags, remove*, applyTheme (PRIME contract surface).
	
	local Defaults = __require("config/Defaults")
	local Merge = __require("config/Merge")
	local Maid = __require("util/Maid")
	local Model = __require("model/Model")
	local Validate = __require("model/Validate")
	local DefaultDeps = __require("adapters/DefaultDeps")
	local WindowBuild = __require("window/Build")
	local Drag = __require("window/Drag")
	local Shortcuts = __require("window/Shortcuts")
	local CustomCursor = __require("window/CustomCursor")
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
	
	local function scheduleRefresh(hub, wantSidebar)
		if (hub._batchDepth or 0) > 0 then
			hub._pendingRefresh = true
			if wantSidebar then
				hub._pendingSidebar = true
			end
			return
		end
		hub:_refreshPages()
		if wantSidebar then
			hub:_renderSidebar()
		end
	end
	
	local function appendControl(hub, group, el)
		Validate.alive(hub)
		Validate.group(group)
		if el.flag then
			Validate.flagUnique(hub, el.flag)
		end
		table.insert(group.elements, el)
		scheduleRefresh(hub, false)
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
		self._batchDepth = 0
		self._pendingRefresh = false
		self._pendingSidebar = false
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
		CustomCursor.setup(self)
		self:_renderSidebar()
		return self
	end
	
	--- Batch structural changes into one refresh (call endUpdate when done).
	function MawyxxHub:beginUpdate()
		Validate.alive(self)
		self._batchDepth += 1
	end
	
	function MawyxxHub:endUpdate()
		Validate.alive(self)
		self._batchDepth = math.max(0, (self._batchDepth or 0) - 1)
		if self._batchDepth > 0 then
			return
		end
		local needPages = self._pendingRefresh
		local needSidebar = self._pendingSidebar
		self._pendingRefresh = false
		self._pendingSidebar = false
		if needPages then
			self:_refreshPages()
		end
		if needSidebar then
			self:_renderSidebar()
		end
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
		if #self.tabs == 1 then
			tab.active = true
			self.activeTab = tab
		end
		scheduleRefresh(self, true)
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
	
		-- Fast path: flip page visibility without full rebuild
		if self.pages and next(self.pages) ~= nil then
			for t, page in pairs(self.pages) do
				page.Visible = t == tab
			end
			Sidebar.updateHighlight(self)
			return
		end
		scheduleRefresh(self, false)
	end
	
	--- Explicit group by text name only (equal width, height from controls).
	function MawyxxHub:addGroup(tab, name)
		Validate.alive(self)
		Validate.tab(tab)
		Validate.label(name)
		local group = Model.newGroup(name)
		table.insert(tab.groups, group)
		scheduleRefresh(self, false)
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
	
	--- Slider. Step is explicit (default 1) — never derived from range.
	-- addSlider(group, label, flag, min, max, default, step?, callback?)
	function MawyxxHub:addSlider(group, label, flag, min, max, default, step, callback)
		Validate.label(label)
		Validate.flag(flag)
		min = min or 0
		max = max or 100
	
		-- Allow omitting step: (..., default, callback)
		if type(step) == "function" then
			callback = step
			step = 1
		end
		if type(default) == "function" then
			callback = default
			default = min
			step = 1
		end
		if type(default) ~= "number" then
			default = min
		end
		-- Step must be a positive number the caller chose; fallback is 1 (smooth)
		if type(step) ~= "number" or step <= 0 then
			step = 1
		end
		if type(callback) ~= "function" then
			callback = nil
		end
	
		Validate.sliderRange(min, max, step)
		default = math.clamp(default, min, max)
	
		return appendControl(self, group, {
			type = "slider",
			label = label,
			flag = flag,
			min = min,
			max = max,
			step = step,
			default = default,
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
	
	--- Toggle + color swatch on one row. Two flags: bool + Color3.
	-- Signature: addToggleColor(group, label, flag, colorFlag, defaultOn?, defaultColor?, callback?, colorCallback?)
	-- Also accepts shuffled args (Color3 / function) so misplaced callbacks don't corrupt settings.
	function MawyxxHub:addToggleColor(group, label, flag, colorFlag, defaultOn, defaultColor, callback, colorCallback)
		Validate.label(label)
		Validate.flagsDistinct(flag, colorFlag)
		Validate.flagUnique(self, colorFlag)
	
		-- Normalize flexible argument order
		if type(defaultOn) == "function" then
			-- (..., colorFlag, callback, colorCallback?)
			colorCallback = defaultColor
			callback = defaultOn
			defaultOn = true
			defaultColor = Color3.new(1, 1, 1)
		elseif typeof(defaultOn) == "Color3" then
			-- (..., colorFlag, defaultColor, callback?, colorCallback?)
			colorCallback = callback
			callback = defaultColor
			defaultColor = defaultOn
			defaultOn = true
		end
		if type(defaultColor) == "function" then
			-- (..., defaultOn, callback, colorCallback?)
			colorCallback = callback
			callback = defaultColor
			defaultColor = Color3.new(1, 1, 1)
		end
		if type(callback) ~= "function" then
			callback = nil
		end
		if type(colorCallback) ~= "function" then
			colorCallback = nil
		end
		if type(defaultOn) ~= "boolean" then
			defaultOn = defaultOn and true or false
		end
		if typeof(defaultColor) ~= "Color3" then
			defaultColor = Color3.new(1, 1, 1)
		end
	
		return appendControl(self, group, {
			type = "togglecolor",
			label = label,
			flag = flag,
			colorFlag = colorFlag,
			default = defaultOn,
			colorDefault = defaultColor,
			callback = callback,
			colorCallback = colorCallback,
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
		scheduleRefresh(self, false)
	end
	
	--- Remove a stateful control by flag (or colorFlag). Returns true if removed.
	function MawyxxHub:removeControl(flag)
		Validate.alive(self)
		Validate.flag(flag)
		for _, tab in ipairs(self.tabs) do
			for _, group in ipairs(tab.groups or {}) do
				for i, el in ipairs(group.elements) do
					if el.flag == flag or el.colorFlag == flag then
						table.remove(group.elements, i)
						if el.flag then
							self._bindings[el.flag] = nil
						end
						if el.colorFlag then
							self._bindings[el.colorFlag] = nil
						end
						scheduleRefresh(self, false)
						return true
					end
				end
			end
		end
		return false
	end
	
	--- Remove a group from its tab.
	function MawyxxHub:removeGroup(tab, group)
		Validate.alive(self)
		Validate.tab(tab)
		Validate.group(group)
		local groups = tab.groups or {}
		for i, g in ipairs(groups) do
			if g == group then
				table.remove(groups, i)
				scheduleRefresh(self, false)
				return true
			end
		end
		return false
	end
	
	--- Remove a tab (and its groups). Activates first remaining tab if needed.
	function MawyxxHub:removeTab(tab)
		Validate.alive(self)
		Validate.tab(tab)
		for i, t in ipairs(self.tabs) do
			if t == tab then
				table.remove(self.tabs, i)
				if self.activeTab == tab then
					self.activeTab = self.tabs[1]
					if self.activeTab then
						self.activeTab.active = true
					end
				end
				scheduleRefresh(self, true)
				return true
			end
		end
		return false
	end
	
	--- Merge color overrides and rebuild visible chrome.
	function MawyxxHub:applyTheme(partialColors)
		Validate.alive(self)
		Validate.expectTable(partialColors, "Theme.Colors", "partialColors must be a table")
		for k, v in pairs(partialColors) do
			self.config.colors[k] = v
		end
		if self.window and partialColors.bg then
			self.window.BackgroundColor3 = partialColors.bg
		end
		if self.sidebar and partialColors.bg then
			self.sidebar.BackgroundColor3 = partialColors.bg
		end
		if self.topbar and partialColors.bg then
			self.topbar.BackgroundColor3 = partialColors.bg
		end
		if self.content and partialColors.bg then
			self.content.BackgroundColor3 = partialColors.bg
		end
		scheduleRefresh(self, true)
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
	-- Search / filter: ASCII + Cyrillic, byte-safe (no string.lower on UTF-8).
	
	local Filter = {}
	
	-- Fold without utf8 lib edge-cases: walk UTF-8 bytes for Cyrillic А-Я / Ё and ASCII A-Z.
	local function norm(s)
		s = tostring(s or "")
		if s == "" then
			return ""
		end
	
		local out = table.create(#s)
		local n = 0
		local i = 1
		local len = #s
	
		while i <= len do
			local b1 = string.byte(s, i)
	
			-- UTF-8 2-byte Cyrillic (D0/D1 …)
			if (b1 == 0xD0 or b1 == 0xD1) and i < len then
				local b2 = string.byte(s, i + 1)
				-- Ё U+0401 = D0 81 → ё U+0451 = D1 91
				if b1 == 0xD0 and b2 == 0x81 then
					n += 1
					out[n] = "\209\145" -- D1 91
					i += 2
				-- А-П U+0410..041F = D0 90..9F → а-п D0 B0..BF
				elseif b1 == 0xD0 and b2 >= 0x90 and b2 <= 0x9F then
					n += 1
					out[n] = string.char(0xD0, b2 + 0x20)
					i += 2
				-- Р-Я U+0420..042F = D0 A0..AF → р-я D1 80..8F
				elseif b1 == 0xD0 and b2 >= 0xA0 and b2 <= 0xAF then
					n += 1
					out[n] = string.char(0xD1, b2 - 0x20)
					i += 2
				else
					-- already lower Cyrillic or other D0/D1 char — keep
					n += 1
					out[n] = string.char(b1, b2)
					i += 2
				end
			elseif b1 >= 0x41 and b1 <= 0x5A then
				n += 1
				out[n] = string.char(b1 + 0x20)
				i += 1
			else
				n += 1
				out[n] = string.sub(s, i, i)
				i += 1
			end
		end
	
		return table.concat(out)
	end
	
	local function contains(haystack, needle)
		if needle == "" then
			return true
		end
		if string.find(haystack, needle, 1, true) then
			return true
		end
		-- raw fallback (in case fold missed something)
		return false
	end
	
	function Filter.matchesQuery(query, ...)
		local qRaw = tostring(query or "")
		if qRaw == "" then
			return true
		end
		local q = norm(qRaw)
		for i = 1, select("#", ...) do
			local text = tostring(select(i, ...) or "")
			if contains(norm(text), q) or contains(text, qRaw) then
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
			if Filter.matchesQuery(query, el.label, el.flag, el.colorFlag, el.type) then
				table.insert(filtered, el)
			end
		end
		return #filtered > 0, filtered
	end
	
	Filter.sectionVisible = Filter.groupVisible
	Filter._norm = norm -- for tests / debug
	
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
	
	function Validate.flagUnique(hub, flag)
		Validate.flag(flag)
		Errors.expect(type(hub) == "table" and type(hub.tabs) == "table", "Validate.FlagUnique", "hub required")
		for _, tab in ipairs(hub.tabs) do
			for _, group in ipairs(tab.groups or tab.sections or {}) do
				for _, el in ipairs(group.elements or {}) do
					Errors.expect(
						el.flag ~= flag and el.colorFlag ~= flag,
						"Validate.FlagUnique",
						("duplicate flag %q — labels may repeat, flags must be unique"):format(flag)
					)
				end
			end
		end
	end
	
	function Validate.flagsDistinct(flag, colorFlag)
		Validate.flag(flag)
		Validate.flag(colorFlag)
		Errors.expect(flag ~= colorFlag, "Validate.Flag", "flag and colorFlag must differ")
	end
	
	function Validate.label(label)
		Errors.expect(type(label) == "string" and label ~= "", "Validate.Label", "label must be a non-empty string")
	end
	
	function Validate.expectTable(value, ruleId, message)
		Errors.expect(type(value) == "table", ruleId, message)
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
			BackgroundColor3 = config.colors.surface,
			BorderSizePixel = 0,
			ClipsDescendants = false, -- never clip toggles/sliders at the card edge
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = layoutOrder or 0,
		})
		Stroke(frame, config.colors.border, 1)
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
		local header = TextLabel(headerRow, group.name, 15, config.colors.textSoft, config.font)
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
	-- Tab page: N-column group layout (horizontal columns, vertical cards per column).
	
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
			FillDirection = Enum.FillDirection.Vertical,
		})
	end
	
	local function layoutPads(gcfg, fallbackPad)
		local padL = gcfg.paddingLeft or fallbackPad or 14
		local padR = gcfg.paddingRight or 10
		local scrollBar = gcfg.scrollBarGutter or 6
		return math.max(padL, 8), math.max(padR, 0), math.max(scrollBar, 0)
	end
	
	local function relayoutRow(scroll, row, cols, columns, gutter, padL, padR, scrollBar)
		local viewW = scroll.AbsoluteSize.X
		if viewW <= 1 then
			return false
		end
		local usable = math.max(viewW - padL - padR - scrollBar, 80)
		local g = math.max(gutter, 8)
		local gaps = g * math.max(columns - 1, 0)
		local colW = math.max(math.floor((usable - gaps) / columns), 40)
	
		row.Size = UDim2.new(0, usable, 0, 0)
		row.Position = UDim2.new(0, padL, 0, padL)
	
		for i, col in ipairs(cols) do
			col.Size = UDim2.new(0, colW, 0, 0)
			col.LayoutOrder = i
		end
		return true
	end
	
	function Pages.render(hub)
		if hub._suspendLayout then
			return
		end
	
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
		local padL, padR, scrollBar = layoutPads(gcfg, pad)
		local columns = math.max(1, math.floor(gcfg.columns or 2))
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
	
			local row = Create("Frame", {
				Name = "Columns",
				Parent = scroll,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				AutomaticSize = Enum.AutomaticSize.Y,
			})
	
			-- Always horizontal strip of columns (fixes cards stacking under each other)
			Create("UIListLayout", {
				Parent = row,
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				Padding = UDim.new(0, gutter),
				SortOrder = Enum.SortOrder.LayoutOrder,
			})
	
			local cols = {}
			for c = 1, columns do
				local col = Create("Frame", {
					Name = "Column" .. c,
					Parent = row,
					Size = UDim2.new(0, 200, 0, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
					LayoutOrder = c,
				})
				addColumnList(col, gap)
				cols[c] = col
			end
	
			local function relayout()
				if hub._suspendLayout then
					return
				end
				relayoutRow(scroll, row, cols, columns, gutter, padL, padR, scrollBar)
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
				BackgroundTransparency = active and 0.88 or 1,
				BackgroundColor3 = active and hub.config.colors.surface2 or hub.config.colors.bg,
			})
			hub:tween(data.label, {
				TextColor3 = active and hub.config.colors.purple or hub.config.colors.textSoft,
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
			BackgroundTransparency = 0.04,
			BorderSizePixel = 0,
			ClipsDescendants = true,
		})
		hub.window = window
		Stroke(window, config.colors.border, 1, 0.35)
	
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
		local accentWidth = textMetrics.Measure(accent, config.font, 20)
	
		local brandHeader = Create("Frame", {
			Name = "BrandHeader",
			Parent = sidebar,
			Size = UDim2.new(1, 0, 0, 62),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		})
	
		local brandRow = Create("Frame", {
			Name = "BrandRow",
			Parent = brandHeader,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(prefixWidth + accentWidth + 2, 32),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		})
	
		local brandLabel = TextLabel(brandRow, prefix, 20, config.colors.text, config.font)
		brandLabel.Position = UDim2.new(0, 0, 0, 0)
		brandLabel.Size = UDim2.new(0, prefixWidth + 1, 1, 0)
		brandLabel.TextXAlignment = Enum.TextXAlignment.Right
		brandLabel.TextYAlignment = Enum.TextYAlignment.Center
	
		local brandPurple = TextLabel(brandRow, accent, 20, config.colors.purple, config.font)
		brandPurple.Position = UDim2.new(0, prefixWidth + 1, 0, 0)
		brandPurple.Size = UDim2.new(0, accentWidth + 1, 1, 0)
		brandPurple.TextXAlignment = Enum.TextXAlignment.Left
		brandPurple.TextYAlignment = Enum.TextYAlignment.Center
	
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
	
		-- Centered search strip (no icon / no box)
		local closeReserve = 40
		local search = Create("TextBox", {
			Parent = topbar,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, -math.floor(closeReserve / 2), 0.5, 0),
			Size = UDim2.new(1, -(closeReserve + 24), 1, 0),
			BackgroundTransparency = 1,
			Text = "",
			PlaceholderText = searchEnabled and placeholder or "Search disabled",
			PlaceholderColor3 = config.colors.textMuted,
			TextColor3 = config.colors.text,
			TextSize = 14,
			Font = config.font,
			ClearTextOnFocus = false,
			BorderSizePixel = 0,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextEditable = searchEnabled,
		})
		hub.searchBox = search
	
		if searchEnabled then
			local function syncSearch()
				hub.searchQuery = search.Text or ""
				hub:_refreshPages()
			end
			hub._maid:Connect(search:GetPropertyChangedSignal("Text"), syncSearch)
			hub._maid:Connect(search.FocusLost, syncSearch)
		end
	
		local closeBtn = Create("TextButton", {
			Name = "Close",
			Parent = topbar,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -8, 0.5, 0),
			Size = UDim2.fromOffset(28, 28),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = "X",
			TextColor3 = config.colors.textMuted,
			TextSize = 14,
			Font = config.font,
			AutoButtonColor = false,
			ZIndex = 5,
		})
		hub.closeButton = closeBtn
	
		hub._maid:Connect(closeBtn.MouseEnter, function()
			hub:tween(closeBtn, { TextColor3 = config.colors.text })
		end)
		hub._maid:Connect(closeBtn.MouseLeave, function()
			hub:tween(closeBtn, { TextColor3 = config.colors.textMuted })
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
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		})
		Create("Frame", {
			Parent = footer,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = config.colors.borderSoft,
			BackgroundTransparency = 0.35,
			BorderSizePixel = 0,
		})
	
		local footerText = TextLabel(footer, brand.footer or "Mawyxx / Hub", 10, config.colors.textMuted, config.font)
		footerText.AnchorPoint = Vector2.new(0.5, 0.5)
		footerText.Position = UDim2.new(0.5, 0, 0.5, 0)
		footerText.Size = UDim2.new(0, 160, 0, 18)
		footerText.TextXAlignment = Enum.TextXAlignment.Center
		footerText.TextTransparency = 0.25
	
		-- Quiet resize hint (wired in Drag.setup) — geometric, no emoji
		local resizeGrip = Create("TextButton", {
			Name = "ResizeGrip",
			Parent = window,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -2, 1, -2),
			Size = UDim2.fromOffset(14, 14),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 20,
		})
		local gripA = Create("Frame", {
			Parent = resizeGrip,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -2, 1, -2),
			Size = UDim2.fromOffset(8, 1),
			BackgroundColor3 = config.colors.textMuted,
			BackgroundTransparency = 0.35,
			BorderSizePixel = 0,
			Rotation = -45,
		})
		local gripB = Create("Frame", {
			Parent = resizeGrip,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -5, 1, -2),
			Size = UDim2.fromOffset(5, 1),
			BackgroundColor3 = config.colors.textMuted,
			BackgroundTransparency = 0.35,
			BorderSizePixel = 0,
			Rotation = -45,
		})
		hub.resizeGrip = resizeGrip
		hub._resizeGripLines = { gripA, gripB }
	
		hub.pages = {}
		hub.searchQuery = ""
	end
	
	return Build
end

__modules["window/CustomCursor"] = function(__require)
	-- Custom crosshair cursor (replaces system mouse while hub lives).
	
	local CreateMod = __require("visual/Create")
	
	local Create = CreateMod.Create
	
	local CROSS = 12
	local BAR = 2
	local GLOW = 4
	
	local CustomCursor = {}
	
	local function makeBar(parent, size, z, color, transparency)
		return Create("Frame", {
			Parent = parent,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = size,
			BackgroundColor3 = color,
			BackgroundTransparency = transparency or 0,
			BorderSizePixel = 0,
			ZIndex = z,
		})
	end
	
	function CustomCursor.setup(hub)
		local input = hub.deps.input
		local guiHost = hub.deps.guiHost
		local white = (hub.config.colors and hub.config.colors.white) or Color3.new(1, 1, 1)
	
		if input.SetMouseIconEnabled then
			input.SetMouseIconEnabled(false)
		end
	
		local gui = Create("ScreenGui", {
			Name = "MawyxxCursor",
			Parent = guiHost.GetPlayerGui(),
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			DisplayOrder = 100001,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		})
		hub._maid:Give(gui)
		hub._maid:Give(function()
			if input.SetMouseIconEnabled then
				input.SetMouseIconEnabled(true)
			end
		end)
	
		local root = Create("Frame", {
			Name = "Cross",
			Parent = gui,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(CROSS, CROSS),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 10,
		})
	
		-- Soft glow (slightly thicker, translucent)
		makeBar(root, UDim2.fromOffset(CROSS + 2, GLOW), 10, white, 0.65)
		makeBar(root, UDim2.fromOffset(GLOW, CROSS + 2), 10, white, 0.65)
		-- Sharp cross
		makeBar(root, UDim2.fromOffset(CROSS, BAR), 11, white, 0)
		makeBar(root, UDim2.fromOffset(BAR, CROSS), 11, white, 0)
	
		local function follow()
			if hub._destroyed then
				return
			end
			-- Cursor ScreenGui uses IgnoreGuiInset=true → raw screen coords (not Gui-inset space)
			local m = input.GetMouseLocation()
			root.Position = UDim2.fromOffset(m.X, m.Y)
		end
	
		follow()
		if input.RenderStepped then
			hub._maid:Connect(input.RenderStepped, follow)
		end
		hub._maid:Connect(input.InputChanged, function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseMovement then
				follow()
			end
		end)
	
		hub._customCursor = root
	end
	
	return CustomCursor
end

__modules["window/Drag"] = function(__require)
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
				for _, line in ipairs(hub._resizeGripLines or {}) do
					hub:tween(line, { BackgroundTransparency = 0.05 })
				end
			end)
			hub._maid:Connect(grip.MouseLeave, function()
				if not resizing then
					for _, line in ipairs(hub._resizeGripLines or {}) do
						hub:tween(line, { BackgroundTransparency = 0.35 })
					end
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
				for _, line in ipairs(hub._resizeGripLines or {}) do
					line.BackgroundTransparency = 0.35
				end
			end
		end)
	end
	
	return Drag
end

__modules["window/Shortcuts"] = function(__require)
	-- RightControl toggles hub. Vertical strip open/close from center.
	
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
	
		local function clearSearch()
			local box = hub.searchBox
			if box then
				if box:IsFocused() then
					box:ReleaseFocus()
				end
				if box.Text ~= "" then
					box.Text = ""
				end
			end
			if hub.searchQuery ~= "" then
				hub.searchQuery = ""
				hub:_refreshPages()
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
				hub._suspendLayout = true
				hub.window.Visible = true
				hub.window.Size = STRIP
				-- Width already full — layout columns once, height reveal only clips
				hub._suspendLayout = false
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
						hub._suspendLayout = false
						runLayouts()
					end
				end)
			else
				clearSearch()
				hub._suspendLayout = true
	
				if hub.config.animations == false then
					hub.window.Size = STRIP
					hub.window.Visible = false
					hub._suspendLayout = false
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
					hub._suspendLayout = false
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
			local key = hub.config.toggleKey or Enum.KeyCode.RightControl
			if inp.KeyCode == key then
				setOpen(not visible)
			end
		end)
	end
	
	return Shortcuts
end

return __require("init")
