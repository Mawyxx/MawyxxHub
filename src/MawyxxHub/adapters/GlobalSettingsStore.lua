-- Adapter: session settings bag in _G[key].

local GlobalSettingsStore = {}

function GlobalSettingsStore.Bind(key)
	local store = rawget(_G, key)
	if type(store) ~= "table" then
		store = {}
		rawset(_G, key, store)
	end
	return store
end

function GlobalSettingsStore.Get(store, flag)
	return store[flag]
end

function GlobalSettingsStore.Set(store, flag, value)
	store[flag] = value
end

return GlobalSettingsStore
