-- Wires default Roblox adapters (composition helper for root).

return {
	input = require(script.Parent.RobloxInput),
	guiHost = require(script.Parent.RobloxGuiHost),
	tween = require(script.Parent.RobloxTween),
	textMetrics = require(script.Parent.RobloxTextMetrics),
	settings = require(script.Parent.GlobalSettingsStore),
}
