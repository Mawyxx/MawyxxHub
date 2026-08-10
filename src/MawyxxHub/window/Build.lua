-- Builds ScreenGui shell: sidebar (scroll), topbar + live search, content, footer, overlay.

local CreateMod = require(script.Parent.Parent.visual.Create)

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
