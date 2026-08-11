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
