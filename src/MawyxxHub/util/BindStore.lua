-- Persistent keybind map inside hub.settings (no script API required).

local STORE = "_mawyxx_binds"

local BindStore = {}

function BindStore.all(hub)
	local t = hub.settings[STORE]
	if type(t) ~= "table" then
		t = {}
		hub.deps.settings.Set(hub.settings, STORE, t)
	end
	return t
end

function BindStore.get(hub, bindId)
	local e = BindStore.all(hub)[bindId]
	if type(e) ~= "table" or type(e.key) ~= "string" then
		return nil
	end
	local mode = e.mode
	if mode ~= "hold" then
		mode = "press"
	end
	return { key = e.key, mode = mode }
end

function BindStore.set(hub, bindId, keyName, mode)
	if type(bindId) ~= "string" or bindId == "" then
		return
	end
	if type(keyName) ~= "string" or keyName == "" then
		return
	end
	if mode ~= "hold" then
		mode = "press"
	end
	local all = BindStore.all(hub)
	all[bindId] = { key = keyName, mode = mode }
	hub.deps.settings.Set(hub.settings, STORE, all)
end

function BindStore.clear(hub, bindId)
	local all = BindStore.all(hub)
	all[bindId] = nil
	hub.deps.settings.Set(hub.settings, STORE, all)
end

function BindStore.keyCode(keyName)
	if type(keyName) ~= "string" then
		return nil
	end
	local ok, code = pcall(function()
		return Enum.KeyCode[keyName]
	end)
	if ok and typeof(code) == "EnumItem" then
		return code
	end
	return nil
end

function BindStore.keyName(keyCode)
	if keyCode == nil then
		return nil
	end
	return tostring(keyCode):gsub("Enum.KeyCode.", "")
end

local MOUSE_TYPES = {
	[Enum.UserInputType.MouseButton1] = "MouseButton1",
	[Enum.UserInputType.MouseButton2] = "MouseButton2",
	[Enum.UserInputType.MouseButton3] = "MouseButton3",
}

-- MouseButton4/5 exist on some clients
pcall(function()
	MOUSE_TYPES[Enum.UserInputType.MouseButton4] = "MouseButton4"
	MOUSE_TYPES[Enum.UserInputType.MouseButton5] = "MouseButton5"
end)

function BindStore.mouseName(userInputType)
	return MOUSE_TYPES[userInputType]
end

function BindStore.isMouseToken(token)
	return type(token) == "string" and string.sub(token, 1, 11) == "MouseButton"
end

--- Token from an InputObject: KeyCode name or MouseButtonN
function BindStore.tokenFromInput(inp)
	if not inp then
		return nil
	end
	if inp.UserInputType == Enum.UserInputType.Keyboard then
		if inp.KeyCode == Enum.KeyCode.Unknown then
			return nil
		end
		return BindStore.keyName(inp.KeyCode)
	end
	return BindStore.mouseName(inp.UserInputType)
end

function BindStore.displayLabel(hub, token)
	if type(token) ~= "string" then
		return ""
	end
	if BindStore.isMouseToken(token) then
		local n = string.match(token, "MouseButton(%d+)")
		return n and ("M" .. n) or "M?"
	end
	local input = hub and hub.deps and hub.deps.input
	local code = BindStore.keyCode(token)
	if code and input and input.GetStringForKeyCode then
		local s = input.GetStringForKeyCode(code)
		if type(s) == "string" and s ~= "" then
			if s:match("^[%w%p%s]+$") then
				return string.upper(s)
			end
			return s
		end
	end
	return token
end

--- Find bindId that already uses this key (excluding exceptId).
function BindStore.findByKey(hub, keyName, exceptId)
	if type(keyName) ~= "string" then
		return nil
	end
	for id, e in pairs(BindStore.all(hub)) do
		if id ~= exceptId and type(e) == "table" and e.key == keyName then
			return id
		end
	end
	return nil
end

return BindStore
