-- In-memory settings store (ISettingsStore Fake).

local FakeSettingsStore = {}

function FakeSettingsStore.Bind(_key)
	return {}
end

function FakeSettingsStore.Get(store, flag)
	return store[flag]
end

function FakeSettingsStore.Set(store, flag, value)
	store[flag] = value
end

return FakeSettingsStore
