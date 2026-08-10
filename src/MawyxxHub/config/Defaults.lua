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
