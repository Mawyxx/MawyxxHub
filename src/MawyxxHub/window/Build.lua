-- Builds ScreenGui shell: sidebar (scroll), topbar + live search, content, footer, overlay.

local CreateMod = require(script.Parent.Parent.visual.Create)

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

	-- Quiet search strip (no box) — icon + left-aligned field
	local closeReserve = 40
	local searchIcon = TextLabel(topbar, "⌕", 14, config.colors.textMuted, config.font)
	searchIcon.Position = UDim2.new(0, 14, 0, 0)
	searchIcon.Size = UDim2.new(0, 18, 1, 0)
	searchIcon.TextXAlignment = Enum.TextXAlignment.Left

	local search = Create("TextBox", {
		Parent = topbar,
		Position = UDim2.new(0, 34, 0, 0),
		Size = UDim2.new(1, -(closeReserve + 40), 1, 0),
		BackgroundTransparency = 1,
		Text = "",
		PlaceholderText = searchEnabled and placeholder or "Search disabled",
		PlaceholderColor3 = config.colors.textMuted,
		TextColor3 = config.colors.text,
		TextSize = 14,
		Font = config.font,
		ClearTextOnFocus = false,
		BorderSizePixel = 0,
		TextXAlignment = Enum.TextXAlignment.Left,
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
		Text = "×",
		TextColor3 = config.colors.textMuted,
		TextSize = 20,
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

	-- Quiet resize hint (wired in Drag.setup)
	local resizeGrip = Create("TextButton", {
		Name = "ResizeGrip",
		Parent = window,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -4, 1, -2),
		Size = UDim2.fromOffset(16, 16),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "⌟",
		TextColor3 = config.colors.textMuted,
		TextTransparency = 0.35,
		TextSize = 14,
		Font = config.font,
		AutoButtonColor = false,
		ZIndex = 20,
	})
	hub.resizeGrip = resizeGrip

	hub.pages = {}
	hub.searchQuery = ""
end

return Build
