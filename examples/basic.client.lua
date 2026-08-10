-- Example: declare tabs/groups by text only; width equal, height = content.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MawyxxHub = require(ReplicatedStorage:WaitForChild("MawyxxHub"))

local hub = MawyxxHub.new()

hub:beginUpdate()

local combat = hub:addTab("Combat")
local visuals = hub:addTab("Visuals")

local aim = hub:addGroup(combat, "Aim")
local rage = hub:addGroup(combat, "Rage")
local esp = hub:addGroup(visuals, "ESP")

hub:addToggle(aim, "Enabled", "aim_enabled", false)
hub:addSlider(aim, "FOV", "aim_fov", 10, 120, 60)
hub:addDropdown(aim, "Mode", "aim_mode", { "Closest", "Lowest HP", "FOV" }, "Closest")

hub:addToggle(rage, "Auto fire", "rage_autofire", false)
hub:addButton(rage, "Reset", function()
	hub:set("aim_enabled", false)
end)

hub:addToggle(esp, "Boxes", "esp_boxes", true)
hub:addColorPicker(esp, "Box color", "esp_color", Color3.fromRGB(117, 72, 255))

hub:endUpdate()
