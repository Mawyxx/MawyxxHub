-- Full QuantHub palette (from reference UI).

local Defaults = {
	window = {
		width = 920,
		height = 600,
		sidebarWidth = 156,
		title = "MawyxxHub",
	},
	colors = {
		-- Chrome
		bg = Color3.fromRGB(11, 11, 11), -- #0B0B0B window / sidebar
		surface = Color3.fromRGB(18, 18, 18), -- #121212 group cards
		surface2 = Color3.fromRGB(22, 22, 22),
		surfaceHover = Color3.fromRGB(28, 28, 28),
		-- Interactive fields (slider track, off toggle, dropdown, search, buttons)
		control = Color3.fromRGB(30, 30, 30), -- #1E1E1E
		controlHover = Color3.fromRGB(40, 40, 40),
		border = Color3.fromRGB(32, 32, 32),
		borderSoft = Color3.fromRGB(26, 26, 26),
		-- Text
		text = Color3.fromRGB(230, 230, 230),
		textSoft = Color3.fromRGB(160, 160, 160),
		textMuted = Color3.fromRGB(100, 100, 100),
		-- Accent (slider fill / on-toggle / active tab / brand)
		purple = Color3.fromRGB(138, 126, 253), -- #8A7EFD
		purpleHover = Color3.fromRGB(158, 148, 255),
		purpleDark = Color3.fromRGB(100, 90, 200),
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
