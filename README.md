# MawyxxHub

Roblox Luau GUI framework: **Tab → Group → Controls**.

Equal-width group cards in a 2-column grid, height grows with content. Built for executors (`HttpGet` + `loadstring`) and Studio (Rojo).

Repo: https://github.com/Mawyxx/MawyxxHub

---

## Quick start (executor)

**Full demo** (one HttpGet — use this URL):

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Mawyxx/MawyxxHub/main/dist/___RUN_UI_V19.lua"))()
```

- Starts **hidden**
- **RightControl** (configurable via `toggleKey`) — open / close
- Red **×** — close
- Drag from the top bar
- Search filters controls; cleared on close

**Framework only:**

```lua
local MawyxxHub = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/Mawyxx/MawyxxHub/main/dist/MawyxxHub.lua"
))()

local hub = MawyxxHub.new({
	window = { width = 920, height = 600, sidebarWidth = 156 },
	toggleKey = Enum.KeyCode.RightControl,
	startHidden = true,
})

hub:beginUpdate()
local combat = hub:addTab("Combat")
local aim = hub:addGroup(combat, "Aim")
hub:addToggle(aim, "Enabled", "aim_on", false, function(on)
	print("aim", on)
end)
hub:endUpdate()
```

---

## Hierarchy

```
Hub
 └─ Tab          (sidebar, text-only)
     └─ Group    (named card; 2 columns by default)
         └─ Controls  (toggle, slider, dropdown, button, color picker)
```

---

## API

### Construction

`MawyxxHub.new(config?, deps?) → hub`

### Batch updates (important)

```lua
hub:beginUpdate()
-- many addTab / addGroup / addToggle …
hub:endUpdate() -- one refresh
```

Without batching, each `add*` refreshes the UI (still correct, just slower for large trees).

### Structure

| Method | Description |
|--------|-------------|
| `addTab(name)` | Sidebar tab |
| `activateTab(tab)` | Switch tab (fast path: visibility only) |
| `addGroup(tab, name)` / `addSection` | Card under tab |
| `removeTab(tab)` | Remove tab |
| `removeGroup(tab, group)` | Remove group |
| `removeControl(flag)` | Remove control by flag |

### Controls

Stateful controls need a unique **`flag`**. Duplicate flags **error**.

```lua
hub:addToggle(group, label, flag, default?, callback?)
hub:addSlider(group, label, flag, min, max, step, default?, callback?)
hub:addDropdown(group, label, flag, options, default?, callback?)
hub:addColorPicker(group, label, flag, defaultColor3?, callback?)
hub:addButton(group, label, callback?) -- no flag
```

### State & theme

```lua
hub:get("aim_on")
hub:set("aim_on", true)          -- updates UI; does not fire callback
hub:applyTheme({ purple = Color3.fromRGB(70, 140, 255) })
hub:Destroy()
```

**Identity:** Tab/Group are layout only. Runtime identity is **`flag`**. Labels may repeat; flags must not.

```lua
hub:addToggle(aim, "Enabled", "aim_on", false)
hub:addToggle(esp, "Enabled", "esp_on", true) -- OK — same label, different flags
```

---

## Config highlights

```lua
MawyxxHub.new({
	toggleKey = Enum.KeyCode.RightControl,
	startHidden = true,
	animations = true,
	settingsTable = "MawyxxHubSettings", -- _G key (session)
	group = {
		columns = 2,
		gap = 10,
		gutter = 14,
		paddingLeft = 14,
		paddingRight = 10,
		scrollBarGutter = 6,
		innerPadding = 12,
	},
	brand = { prefix = "Mawyxx", accent = "Hub", footer = "…" },
	colors = { --[[ theme ]] },
})
```

---

## UX

| Feature | Behavior |
|---------|----------|
| Open / close | Vertical strip from center; `toggleKey` or × |
| Search | Live filter; Cyrillic-aware; clear + unfocus on close |
| Color | HSV square + hue strip; OK / Cancel |
| Dropdown | Outside-click closes; follows button on resize |
| Slider | Gui-inset-correct mouse sampling |

---

## Rebuild

```bash
python scripts/bundle.py
```

Writes `dist/MawyxxHub.lua`, `dist/MawyxxHub.bundle.lua`, `dist/___RUN_UI_V19.lua`.

---

## Tests (Studio / TestEZ)

Under `tests/studio/`: Merge, Filter (+ Cyrillic), Validate.flagUnique, Maid.

---

## Project layout

```
src/MawyxxHub/     source
dist/              HttpGet bundles
examples/          demo_inline, basic.client, loadstring
scripts/bundle.py  bundler
tests/studio/      TestEZ specs
```
