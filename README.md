# MawyxxHub

Roblox GUI framework: **Tab → Group (text) → Controls**.

Equal-width groups, height follows content. Public repo + Rojo demo.

## Quick start (Rojo)

```bash
git clone https://github.com/Mawyxx/MawyxxHub.git
cd MawyxxHub
rojo serve
```

Connect Rojo to Studio → Play. Fake demo menu opens automatically.

## Demo script

`examples/FakeDemo.client.lua` — fake tabs **Combat / Visuals / Player / Misc**, groups, toggles, sliders, dropdowns, buttons, color pickers.

Manual require (if you only sync the module):

```lua
local MawyxxHub = require(game.ReplicatedStorage.MawyxxHub)
local hub = MawyxxHub.new()
local tab = hub:addTab("Combat")
local g = hub:addGroup(tab, "Aim")
hub:addToggle(g, "Enabled", "aim_on", false)
```

## Controls in a group

`addToggle` · `addSlider` · `addDropdown` · `addButton` · `addColorPicker`

## Layout

```lua
hub:addTab("Combat")           -- sidebar text
hub:addGroup(tab, "Aim")       -- named card, equal width
-- controls go into the group
```

`RightShift` — hide/show. `hub:Destroy()` — cleanup.

## Structure

`src/MawyxxHub` — framework · `examples/` — demos · `scripts/assert_adapters.ps1` — adapter boundary check
