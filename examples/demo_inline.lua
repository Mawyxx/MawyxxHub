-- Inline demo body (appended by bundle into dist/___RUN_HSV.lua). No HttpGet.

print("[MawyxxHub] BUILD=UI_V12_SINGLEFILE")

local MawyxxHub = __require("init")
assert(type(MawyxxHub) == "table" and MawyxxHub.new, "[MawyxxHub] init failed")

local hub = MawyxxHub.new({
	window = { title = "MawyxxHub Demo", width = 920, height = 600, sidebarWidth = 156 },
	brand = { prefix = "Mawyxx", accent = "Hub", footer = "Demo / HSV V4" },
	startHidden = true,
	group = {
		columns = 2,
		gap = 10,
		gutter = 14,
		padding = 14,
		innerPadding = 12,
	},
})

local combat = hub:addTab("Combat")
local visuals = hub:addTab("Visuals")
local player = hub:addTab("Player")
local misc = hub:addTab("Misc")

local aim = hub:addGroup(combat, "Aim")
local guns = hub:addGroup(combat, "Weapons")
local rage = hub:addGroup(combat, "Rage")

hub:addToggle(aim, "Enabled", "demo_aim_on", false)
hub:addSlider(aim, "FOV", "demo_aim_fov", 10, 180, 1, 75)
hub:addDropdown(aim, "Target", "demo_aim_target", { "Closest", "Lowest HP", "Crosshair" }, "Closest")
hub:addColorPicker(aim, "FOV color", "demo_aim_color", Color3.fromRGB(117, 72, 255))

hub:addToggle(guns, "No recoil", "demo_norecoil", true)
hub:addSlider(guns, "Spread", "demo_spread", 0, 100, 1, 20)
hub:addButton(guns, "Reload config", function() end)

hub:addToggle(rage, "Auto fire", "demo_autofire", false)
hub:addToggle(rage, "Silent", "demo_silent", false)
hub:addSlider(rage, "Hit chance", "demo_hitchance", 0, 100, 5, 80)

local esp = hub:addGroup(visuals, "ESP")
local world = hub:addGroup(visuals, "World")

hub:addToggle(esp, "Boxes", "demo_esp_box", true)
hub:addToggle(esp, "Names", "demo_esp_names", true)
hub:addToggle(esp, "Tracers", "demo_esp_tracers", false)
hub:addColorPicker(esp, "Box color", "demo_esp_color", Color3.fromRGB(80, 200, 120))
hub:addDropdown(esp, "Box style", "demo_esp_style", { "Full", "Corner", "3D" }, "Corner")

hub:addToggle(world, "Fullbright", "demo_fullbright", false)
hub:addSlider(world, "Fog", "demo_fog", 0, 100, 1, 40)
hub:addButton(world, "Reset lighting", function()
	hub:set("demo_fog", 40)
	hub:set("demo_fullbright", false)
end)

local move = hub:addGroup(player, "Movement")
local cam = hub:addGroup(player, "Camera")

hub:addToggle(move, "Speed", "demo_speed_on", false)
hub:addSlider(move, "WalkSpeed", "demo_walkspeed", 16, 120, 1, 16)
hub:addToggle(move, "Fly", "demo_fly", false)
hub:addSlider(move, "Fly speed", "demo_flyspeed", 10, 200, 5, 50)

hub:addSlider(cam, "FOV", "demo_cam_fov", 50, 120, 1, 70)
hub:addToggle(cam, "Third person", "demo_thirdperson", false)

local ui = hub:addGroup(misc, "UI")
local danger = hub:addGroup(misc, "Session")

hub:addToggle(ui, "Animations", "demo_ui_anim", true)
hub:addDropdown(ui, "Accent", "demo_accent", { "Purple", "Blue", "Red" }, "Purple")
hub:addButton(ui, "Print flags", function()
	print("aim", hub:get("demo_aim_on"), "fov", hub:get("demo_aim_fov"))
end)

hub:addButton(danger, "Destroy hub", function()
	hub:Destroy()
end)

print("[MawyxxHub] Demo ready — RightShift — click color square for HSV picker")
