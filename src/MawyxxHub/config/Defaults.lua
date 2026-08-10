-- QuantHub-like contrast: near-black chrome, lifted panels, bright lavender accent.

local Defaults = {
	window = {
		width = 920,
		height = 600,
		sidebarWidth = 156,
		title = "MawyxxHub",
	},
	colors = {
		bg = Color3.fromRGB(10, 10, 10),
		surface = Color3.fromRGB(18, 18, 18),
		surface2 = Color3.fromRGB(24, 24, 24),
		surfaceHover = Color3.fromRGB(32, 32, 34),
		border = Color3.fromRGB(42, 42, 46),
		borderSoft = Color3.fromRGB(34, 34, 38),
		text = Color3.fromRGB(235, 235, 240),
		textSoft = Color3.fromRGB(175, 175, 182),
		textMuted = Color3.fromRGB(110, 110, 118),
		-- Bright lavender accent (QuantHub-style) — sliders / toggles / brand
		purple = Color3.fromRGB(157, 141, 255),
		purpleHover = Color3.fromRGB(178, 165, 255),
		purpleDark = Color3.fromRGB(115, 98, 210),
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
