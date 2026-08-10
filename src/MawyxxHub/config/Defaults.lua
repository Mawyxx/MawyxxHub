-- Exact QuantHub palette (user-specified hex).

local Defaults = {
	window = {
		width = 920,
		height = 600,
		sidebarWidth = 156,
		title = "MawyxxHub",
	},
	colors = {
		-- #111111 — window / sidebar / page chrome
		bg = Color3.fromRGB(17, 17, 17),
		-- Group cards sit slightly above chrome (same family as #111)
		surface = Color3.fromRGB(17, 17, 17),
		surface2 = Color3.fromRGB(17, 17, 17),
		surfaceHover = Color3.fromRGB(28, 28, 28),
		-- #000000 — search, dropdown, buttons, slider tracks, off toggles
		control = Color3.fromRGB(0, 0, 0),
		controlHover = Color3.fromRGB(22, 22, 22),
		border = Color3.fromRGB(40, 40, 40),
		borderSoft = Color3.fromRGB(28, 28, 28),
		-- #FFFFFF — primary labels
		text = Color3.fromRGB(255, 255, 255),
		-- #A0A0A0 — inactive tabs, slider values, secondary labels
		textSoft = Color3.fromRGB(160, 160, 160),
		textMuted = Color3.fromRGB(160, 160, 160),
		-- #7B52FF — accent (fills, on-toggles, brand, active tab)
		purple = Color3.fromRGB(123, 82, 255),
		purpleHover = Color3.fromRGB(143, 110, 255),
		purpleDark = Color3.fromRGB(95, 60, 210),
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
