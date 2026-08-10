# MawyxxHub

Roblox GUI framework: **Tab → Group → Controls**. Equal-width groups, height by content.

## Run demo (GitHub → executor)

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Mawyxx/MawyxxHub/main/examples/FakeDemo.client.lua"))()
```

Loads `dist/MawyxxHub.lua` from this repo. **RightShift** opens/closes the menu (starts hidden).

## Framework-only

```lua
local MawyxxHub = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/Mawyxx/MawyxxHub/main/dist/MawyxxHub.lua"
))()

local hub = MawyxxHub.new()
local tab = hub:addTab("Combat")
local g = hub:addGroup(tab, "Aim")
hub:addToggle(g, "Enabled", "aim_on", false)
-- RightShift opens GUI
```

## Rebuild bundle after source changes

```bash
python scripts/bundle.py
```

## Controls

`addToggle` · `addSlider` · `addDropdown` · `addButton` · `addColorPicker`

Repo: https://github.com/Mawyxx/MawyxxHub
