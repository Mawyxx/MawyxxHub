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
