# MawyxxHub

Roblox Luau GUI: **Tab → Group → Controls**.

Repo: https://github.com/Mawyxx/MawyxxHub

---

## Use the framework (this is all you need)

One file — no versions, no prefixes:

```lua
local ls = loadstring or load
local MawyxxHub = ls(game:HttpGet(
	"https://raw.githubusercontent.com/Mawyxx/MawyxxHub/main/dist/MawyxxHub.lua"
))()

local hub = MawyxxHub.new({ startHidden = true })

hub:beginUpdate()
local tab = hub:addTab("Combat")
local g = hub:addGroup(tab, "Aim")
hub:addToggle(g, "Enabled", "aim_on", false, function(on)
	-- your logic
end)
hub:endUpdate()
```

**RightControl** opens/closes the menu (change with `toggleKey` in config).

> If you see `attempt to call a nil value` on line 1, your executor has no `loadstring` — use `local ls = loadstring or load` as above.

---

## Optional demo

```lua
local ls = loadstring or load
ls(game:HttpGet(
	"https://raw.githubusercontent.com/Mawyxx/MawyxxHub/main/dist/demo.lua?v=" .. tostring(tick())
))()
```

`?v=...` bypasses executor HttpGet cache (raw.githubusercontent also caches ~5 min).

---

## Hierarchy

```
Hub → Tab → Group → Controls
```

Controls with state use a unique **`flag`** (`hub:get` / `hub:set` / callback).  
Labels may repeat; flags must not. Buttons have no flag.

---

## API (short)

```lua
hub:beginUpdate() / hub:endUpdate()   -- batch UI builds
hub:addTab / addGroup / addToggle / addSlider / addDropdown / addButton / addColorPicker
hub:get(flag) / hub:set(flag, value)
hub:removeControl(flag) / removeGroup / removeTab
hub:applyTheme({ purple = Color3.new(...) })
hub:Destroy()
```

---

## Config (optional)

```lua
MawyxxHub.new({
	toggleKey = Enum.KeyCode.RightControl,
	startHidden = true,
	window = { width = 920, height = 600, sidebarWidth = 156 },
	brand = { prefix = "Mawyxx", accent = "Hub", footer = "…" },
	group = { columns = 2, paddingLeft = 14, paddingRight = 10 },
})
```

---

## Rebuild after editing `src/`

```bash
python scripts/bundle.py
```

Writes only:

- `dist/MawyxxHub.lua` — **main framework**
- `dist/demo.lua` — optional demo

---

## Studio

Rojo + `examples/basic.client.lua` (`require` the package).
