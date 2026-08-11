--[[
	Outbound ports (duck-typed contracts) — PRIME-A35.

	IInputService:
	  GetMouseLocation() -> Vector2
	  GetMouseLocationGui() -> Vector2  (AbsolutePosition space)
	  SetMouseIconEnabled(boolean)?
	  GetStringForKeyCode(keyCode)? -> string  (layout-aware key glyph)
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
