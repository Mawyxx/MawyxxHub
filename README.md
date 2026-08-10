# MawyxxHub

Roblox Luau GUI framework: **Tab → Group → Controls**.

Equal-width group cards in a 2-column grid, height grows with content. Built for executors (`HttpGet` + `loadstring`) and Studio (Rojo).

Repo: https://github.com/Mawyxx/MawyxxHub

---

## Quick start (executor)

**Full demo** (hub + sample tabs, one file — use this URL to avoid HttpGet cache):

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Mawyxx/MawyxxHub/main/dist/___RUN_UI_V18.lua"))()
```

- Starts **hidden**
- **RightControl** — open / close
- Red **×** — close (same as RightControl)
- Drag window from the top bar
- Search filters controls on the active page

**Framework only** (build your own UI):

```lua
local MawyxxHub = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/Mawyxx/MawyxxHub/main/dist/MawyxxHub.lua"
))()

local hub = MawyxxHub.new({
	window = { width = 920, height = 600, sidebarWidth = 156 },
	brand = { prefix = "Mawyxx", accent = "Hub", footer = "My Script" },
	startHidden = true,
})

local combat = hub:addTab("Combat")
local aim = hub:addGroup(combat, "Aim")

hub:addToggle(aim, "Enabled", "aim_on", false, function(on)
	print("aim", on)
end)

hub:addSlider(aim, "FOV", "aim_fov", 10, 180, 1, 75, function(v)
	print("fov", v)
end)
```

---

## Hierarchy

```
Hub
 └─ Tab          (sidebar, text-only)
     └─ Group    (named card; 2 columns by default)
         └─ Controls  (toggle, slider, dropdown, button, color picker)
```

You only declare structure and flags. Layout, scrolling, search, and open/close animation are handled by the framework.

---

## API

### `MawyxxHub.new(config?, deps?) → hub`

Creates the window and binds a settings table (default `_G.MawyxxHubSettings`).

### Tabs & groups

| Method | Description |
|--------|-------------|
| `hub:addTab(name)` | Sidebar tab. Returns `tab`. |
| `hub:activateTab(tab)` | Switch active tab. |
| `hub:addGroup(tab, name)` | Card under a tab. Returns `group`. |
| `hub:addSection(tab, name)` | Alias of `addGroup`. |

### Controls

All stateful controls take a unique **`flag`** string. Values are stored in the settings table and readable via `hub:get` / `hub:set`.

```lua
hub:addToggle(group, label, flag, default?, callback?)
-- callback(boolean)

hub:addSlider(group, label, flag, min, max, step, default?, callback?)
-- callback(number)

hub:addDropdown(group, label, flag, options, default?, callback?)
-- options = { "A", "B", ... }; callback(string)

hub:addColorPicker(group, label, flag, defaultColor3?, callback?)
-- click swatch → HSV square + hue strip → OK / Cancel; callback(Color3)

hub:addButton(group, label, callback?)
-- no flag; fire-and-forget action
```

### State

```lua
local on = hub:get("aim_on")     -- read
hub:set("aim_on", true)          -- write + update UI
hub:Destroy()                    -- tear down ScreenGui + connections
```

**How controls are identified (important for script authors)**

- **Tab** and **Group** are only layout. You pass them when *creating* UI so the control appears in the right place.
- After that, the program does **not** address controls as `Tab → Group → Label`.
- Stateful controls (`toggle` / `slider` / `dropdown` / `color`) are addressed by a unique **`flag`** string on the whole hub.
- `hub:get("aim_on")` / `hub:set("aim_on", true)` work from anywhere — no tab/group path needed.
- **`flag` must be unique** across the entire hub (two toggles cannot share `"speed"`).
- **Labels may repeat** — e.g. two groups both can show `"Enabled"`. Same text is fine; different flags are required (`"aim_on"` vs `"esp_on"`).
- **Buttons** have no flag: they only run `callback` on click. For on/off state, use a toggle.

```lua
-- Same label, different flags — correct:
local aim = hub:addGroup(combat, "Aim")
local esp = hub:addGroup(visuals, "ESP")
hub:addToggle(aim, "Enabled", "aim_on", false)
hub:addToggle(esp, "Enabled", "esp_on", true)

hub:get("aim_on")  -- Aim toggle
hub:get("esp_on")  -- ESP toggle
```

```lua
-- Build (structure matters here):
local combat = hub:addTab("Combat")
local aim = hub:addGroup(combat, "Aim")
hub:addToggle(aim, "Enabled", "aim_on", false, function(on)
	-- game logic; `on` is already saved under flag "aim_on"
end)

-- Later / elsewhere (structure does NOT matter):
if hub:get("aim_on") then
	-- ...
end
hub:set("aim_fov", 90) -- UI updates if that slider exists
```

**Pattern for your script logic**

```lua
hub:addToggle(g, "Speed", "speed_on", false, function(on)
	-- runs on every click with the new value
end)

-- or poll elsewhere:
if hub:get("speed_on") then
	-- ...
end
```

---

## Config (optional)

Deep-merged over defaults. Useful keys:

```lua
MawyxxHub.new({
	window = {
		width = 920,
		height = 600,
		sidebarWidth = 156,
		title = "MawyxxHub",
	},
	brand = {
		prefix = "Mawyxx",  -- white
		accent = "Hub",     -- purple
		footer = "Mawyxx / Hub",
	},
	search = {
		enabled = true,
		placeholder = "Search",
	},
	startHidden = true,       -- open with RightControl
	animations = true,        -- open/close strip animation
	settingsTable = "MawyxxHubSettings", -- _G key for flags
	group = {
		columns = 2,
		gap = 10,             -- vertical gap between cards
		gutter = 14,          -- horizontal gap between columns
		padding = 14,         -- page padding (right column keeps 10px to edge)
		innerPadding = 12,
	},
	colors = { --[[ theme Color3s ]] },
	font = Enum.Font.Code,
})
```

---

## UX behavior

| Feature | Behavior |
|---------|----------|
| Open / close | Vertical strip from center (linear, fast). RightControl or ×. |
| Search | Live filter by group/control label & flag. Cleared + unfocused on close. |
| Color picker | Overlay HSV picker (square + hue bar), OK / Cancel. |
| Groups | Equal width; height from content; 2 columns. |
| Tabs | Centered labels in sidebar. Brand centered in header. |

---

## Project layout

```
src/MawyxxHub/          source modules
dist/MawyxxHub.lua      bundled framework for HttpGet
dist/___RUN_UI_V18.lua  bundled framework + English demo
examples/               Studio / inline demo sources
scripts/bundle.py       rebuild dist/*
```

### Rebuild after editing `src/`

```bash
python scripts/bundle.py
```

Then commit and push if you publish to GitHub.

### Studio / Rojo

`default.project.json` maps `src/MawyxxHub` into the DataModel. See `examples/basic.client.lua` for a local `require` example.

---

## Notes

- Prefer a **new** `dist/___RUN_UI_V*.lua` URL when testing updates — many executors cache `HttpGet` by path forever.
- `flag` names must be unique across the hub.
- Buttons have no stored state; use toggles for on/off.
- Search TextBox uses Gotham so non-ASCII input works; UI labels use the config font (default Code).
