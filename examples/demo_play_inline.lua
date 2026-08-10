-- Functional demo: ESP / tracers / names / distance + basic player helpers.
-- Bundled into dist/demo_play.lua (appended after framework).

print("[MawyxxHub] play demo loading")

local MawyxxHub = __require("init")
assert(type(MawyxxHub) == "table" and MawyxxHub.new, "[MawyxxHub] init failed")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local hub = MawyxxHub.new({
	window = { title = "MawyxxHub Play", width = 920, height = 600, sidebarWidth = 156 },
	brand = { prefix = "Mawyxx", accent = "Hub", footer = "Play / Demo" },
	startHidden = false,
	toggleKey = Enum.KeyCode.RightControl,
	group = {
		columns = 2,
		gap = 10,
		gutter = 14,
		padding = 14,
		paddingLeft = 14,
		paddingRight = 10,
		innerPadding = 12,
	},
})

------------------------------------------------------------------------
-- Feature runtime
------------------------------------------------------------------------

local folder = Instance.new("Folder")
folder.Name = "MawyxxPlayVisuals"
local okCore = pcall(function()
	folder.Parent = game:GetService("CoreGui")
end)
if not okCore then
	folder.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local overlayGui = Instance.new("ScreenGui")
overlayGui.Name = "MawyxxEspOverlay"
overlayGui.IgnoreGuiInset = true
overlayGui.ResetOnSpawn = false
overlayGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
overlayGui.Parent = folder

local entries = {} -- [Player] = { highlight, billboard, nameLabel, distLabel, tracer }
local savedLighting = {
	Brightness = Lighting.Brightness,
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	FogEnd = Lighting.FogEnd,
	ClockTime = Lighting.ClockTime,
}
local savedCam = {
	FieldOfView = 70,
	FieldOfViewMode = nil,
}
do
	local cam = workspace.CurrentCamera
	if cam then
		savedCam.FieldOfView = cam.FieldOfView
		pcall(function()
			savedCam.FieldOfViewMode = cam.FieldOfViewMode
		end)
	end
end
local letterTop = Instance.new("Frame")
letterTop.Name = "LetterboxTop"
letterTop.BackgroundColor3 = Color3.new(0, 0, 0)
letterTop.BorderSizePixel = 0
letterTop.Visible = false
letterTop.ZIndex = 100
letterTop.Parent = overlayGui
local letterBot = Instance.new("Frame")
letterBot.Name = "LetterboxBot"
letterBot.BackgroundColor3 = Color3.new(0, 0, 0)
letterBot.BorderSizePixel = 0
letterBot.Visible = false
letterBot.ZIndex = 100
letterBot.Parent = overlayGui
local baseWalkSpeed = 16
local flyConn = nil
local flyBV = nil

local function flag(name, fallback)
	local v = hub:get(name)
	if v == nil then
		return fallback
	end
	return v
end

local function clearEntry(plr)
	local e = entries[plr]
	if not e then
		return
	end
	if e.highlight then
		e.highlight:Destroy()
	end
	if e.billboard then
		e.billboard:Destroy()
	end
	if e.tracer then
		e.tracer:Destroy()
	end
	entries[plr] = nil
end

local function ensureEntry(plr)
	local e = entries[plr]
	if e then
		return e
	end
	e = {}

	local highlight = Instance.new("Highlight")
	highlight.Name = "EspHighlight"
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Enabled = false
	highlight.Parent = folder
	e.highlight = highlight

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "EspTag"
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.fromOffset(160, 36)
	billboard.StudsOffset = Vector3.new(0, 2.6, 0)
	billboard.Enabled = false
	billboard.Parent = folder

	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Size = UDim2.new(1, 0, 0, 18)
	nameLabel.Font = Enum.Font.Code
	nameLabel.TextSize = 13
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.TextStrokeTransparency = 0.5
	nameLabel.Text = plr.Name
	nameLabel.Parent = billboard

	local distLabel = Instance.new("TextLabel")
	distLabel.BackgroundTransparency = 1
	distLabel.Position = UDim2.new(0, 0, 0, 16)
	distLabel.Size = UDim2.new(1, 0, 0, 16)
	distLabel.Font = Enum.Font.Code
	distLabel.TextSize = 11
	distLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	distLabel.TextStrokeTransparency = 0.5
	distLabel.Text = ""
	distLabel.Parent = billboard

	e.billboard = billboard
	e.nameLabel = nameLabel
	e.distLabel = distLabel

	local tracer = Instance.new("Frame")
	tracer.Name = "Tracer"
	tracer.AnchorPoint = Vector2.new(0.5, 0.5)
	tracer.BorderSizePixel = 0
	tracer.BackgroundColor3 = Color3.new(1, 1, 1)
	tracer.Visible = false
	tracer.ZIndex = 50
	tracer.Parent = overlayGui
	e.tracer = tracer

	entries[plr] = e
	return e
end

local function sameTeam(plr)
	if LocalPlayer.Team == nil or plr.Team == nil then
		return false
	end
	return LocalPlayer.Team == plr.Team
end

local function characterRoot(plr)
	local char = plr.Character
	if not char then
		return nil
	end
	return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
end

local function updateTracer(frame, from, to, color)
	local mid = (from + to) / 2
	local delta = to - from
	local length = delta.Magnitude
	if length < 2 then
		frame.Visible = false
		return
	end
	frame.Visible = true
	frame.BackgroundColor3 = color
	frame.Size = UDim2.fromOffset(length, 1)
	frame.Position = UDim2.fromOffset(mid.X, mid.Y)
	frame.Rotation = math.deg(math.atan2(delta.Y, delta.X))
end

-- Clip ray from→dir to the viewport rectangle (first hit on an edge)
local function rayToScreenEdge(from, dir, viewport)
	local mag = dir.Magnitude
	if mag < 1e-6 then
		return from
	end
	dir = dir / mag
	local w, h = viewport.X, viewport.Y
	local bestT = math.huge
	local function hit(t)
		if t > 1e-4 and t < bestT then
			bestT = t
		end
	end
	if math.abs(dir.X) > 1e-8 then
		hit((0 - from.X) / dir.X)
		hit((w - from.X) / dir.X)
	end
	if math.abs(dir.Y) > 1e-8 then
		hit((0 - from.Y) / dir.Y)
		hit((h - from.Y) / dir.Y)
	end
	if bestT == math.huge then
		return from
	end
	local p = from + dir * bestT
	-- Keep endpoint slightly inside so the line stays visible
	return Vector2.new(math.clamp(p.X, 1, w - 1), math.clamp(p.Y, 1, h - 1))
end

-- Endpoint always toward the player — behind cam / off-screen included (no stub near feet)
local function worldToTracerEnd(cam, worldPos, from, viewport)
	local screen = cam:WorldToViewportPoint(worldPos)
	local to = Vector2.new(screen.X, screen.Y)

	if screen.Z >= 0 then
		-- In front: if on-screen use exact point; if off-screen, extend to edge
		local onScreen = to.X >= 0 and to.X <= viewport.X and to.Y >= 0 and to.Y <= viewport.Y
		if onScreen then
			return to
		end
		return rayToScreenEdge(from, to - from, viewport)
	end

	-- Behind camera: aim by camera-local XY (look is -Z)
	local rel = cam.CFrame:PointToObjectSpace(worldPos)
	local dir = Vector2.new(rel.X, -rel.Y)
	if dir.Magnitude < 1e-4 then
		dir = Vector2.new(0, 1)
	end
	return rayToScreenEdge(from, dir, viewport)
end

local function applyWalkSpeed()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then
		return
	end
	if flag("play_speed_on", false) then
		hum.WalkSpeed = flag("play_walkspeed", 16)
	else
		hum.WalkSpeed = baseWalkSpeed
	end
end

local function stopFly()
	if flyConn then
		flyConn:Disconnect()
		flyConn = nil
	end
	if flyBV then
		flyBV:Destroy()
		flyBV = nil
	end
end

local function startFly()
	stopFly()
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	bv.Velocity = Vector3.zero
	bv.Parent = root
	flyBV = bv

	flyConn = RunService.RenderStepped:Connect(function()
		if not flag("play_fly", false) or not flyBV or not flyBV.Parent then
			stopFly()
			return
		end
		local cam = workspace.CurrentCamera
		if not cam then
			return
		end
		local speed = flag("play_flyspeed", 50)
		local dir = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			dir += cam.CFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			dir -= cam.CFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			dir -= cam.CFrame.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			dir += cam.CFrame.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			dir += Vector3.yAxis
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			dir -= Vector3.yAxis
		end
		if dir.Magnitude > 0 then
			dir = dir.Unit * speed
		end
		flyBV.Velocity = dir
	end)
end

local function applyFullbright(on)
	if on then
		Lighting.Brightness = 2
		Lighting.Ambient = Color3.fromRGB(180, 180, 180)
		Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
		Lighting.FogEnd = 1e6
		Lighting.ClockTime = 14
	else
		Lighting.Brightness = savedLighting.Brightness
		Lighting.Ambient = savedLighting.Ambient
		Lighting.OutdoorAmbient = savedLighting.OutdoorAmbient
		Lighting.FogEnd = savedLighting.FogEnd
		Lighting.ClockTime = savedLighting.ClockTime
	end
end

local function applyFog()
	if flag("play_fullbright", false) then
		return
	end
	local fog = flag("play_fog", 40)
	Lighting.FogEnd = math.max(50, fog * 25)
end

local function applyCameraFov()
	local cam = workspace.CurrentCamera
	if not cam then
		return
	end

	local stretch = flag("play_stretch", false)
	local cinematic = flag("play_cinematic", false)
	local fov = flag("play_cam_fov", 70)

	-- Stretch = wide FOV via MaxAxis (no downscale / no blur — same render res)
	if stretch then
		cam.FieldOfView = math.clamp(fov, 70, 120)
		pcall(function()
			cam.FieldOfViewMode = Enum.FieldOfViewMode.MaxAxis
		end)
	else
		cam.FieldOfView = fov
		pcall(function()
			if savedCam.FieldOfViewMode ~= nil then
				cam.FieldOfViewMode = savedCam.FieldOfViewMode
			else
				cam.FieldOfViewMode = Enum.FieldOfViewMode.Vertical
			end
		end)
	end

	-- Movie letterbox (2.39:1 crop bars) — optional look, keeps sharpness
	local size = cam.ViewportSize
	if cinematic and size.Y > 0 then
		local targetRatio = 2.39
		local viewRatio = size.X / size.Y
		local barH = 0
		if viewRatio < targetRatio then
			-- taller than ultrawide → bars top/bottom
			local targetH = size.X / targetRatio
			barH = math.max(0, (size.Y - targetH) / 2)
		else
			barH = math.max(24, size.Y * 0.08)
		end
		letterTop.Visible = true
		letterBot.Visible = true
		letterTop.Size = UDim2.fromOffset(size.X, barH)
		letterTop.Position = UDim2.fromOffset(0, 0)
		letterBot.Size = UDim2.fromOffset(size.X, barH)
		letterBot.Position = UDim2.fromOffset(0, size.Y - barH)
	else
		letterTop.Visible = false
		letterBot.Visible = false
	end
end

local function restoreCamera()
	local cam = workspace.CurrentCamera
	if not cam then
		return
	end
	cam.FieldOfView = savedCam.FieldOfView
	pcall(function()
		if savedCam.FieldOfViewMode ~= nil then
			cam.FieldOfViewMode = savedCam.FieldOfViewMode
		end
	end)
	letterTop.Visible = false
	letterBot.Visible = false
end

local renderConn = RunService.RenderStepped:Connect(function()
	Camera = workspace.CurrentCamera
	if not Camera then
		return
	end

	-- Keep FOV/stretch sticky (games often reset camera each frame)
	if flag("play_stretch", false) or flag("play_cinematic", false) or flag("play_cam_fov", 70) ~= savedCam.FieldOfView then
		applyCameraFov()
	end

	local espOn = flag("play_esp_on", false)
	local boxes = flag("play_esp_box", true)
	local names = flag("play_esp_names", true)
	local dists = flag("play_esp_dist", true)
	local tracers = flag("play_esp_tracers", false)
	local teamCheck = flag("play_team_check", true)
	local maxDist = flag("play_maxdistance", 2500)
	local chamsColor = flag("play_esp_chams_color", Color3.fromRGB(80, 200, 120))
	local nameColor = flag("play_esp_names_color", Color3.new(1, 1, 1))
	local distColor = flag("play_esp_dist_color", Color3.fromRGB(200, 200, 200))
	local tracerColor = flag("play_esp_tracers_color", Color3.fromRGB(118, 100, 200))
	local origin = Camera.ViewportSize
	local myRoot = characterRoot(LocalPlayer)
	local myPos = myRoot and myRoot.Position

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local root = characterRoot(plr)
			local skip = (not espOn)
				or (not root)
				or (teamCheck and sameTeam(plr))
				or (myPos and (root.Position - myPos).Magnitude > maxDist)

			if skip then
				clearEntry(plr)
			else
				local e = ensureEntry(plr)
				e.highlight.Adornee = plr.Character
				e.highlight.OutlineColor = chamsColor
				e.highlight.FillColor = chamsColor
				e.highlight.FillTransparency = boxes and 0.85 or 1
				e.highlight.Enabled = boxes

				e.billboard.Adornee = root
				e.billboard.Enabled = names or dists
				e.nameLabel.Visible = names
				e.nameLabel.Text = plr.DisplayName ~= "" and plr.DisplayName or plr.Name
				e.nameLabel.TextColor3 = nameColor
				e.distLabel.Visible = dists
				e.distLabel.TextColor3 = distColor
				if dists and myPos then
					e.distLabel.Text = string.format("%d studs", math.floor((root.Position - myPos).Magnitude + 0.5))
				else
					e.distLabel.Text = ""
				end

				if tracers then
					local from = flag("play_tracer_bottom", false)
							and Vector2.new(origin.X / 2, origin.Y - 2)
						or Vector2.new(origin.X / 2, origin.Y / 2)
					local to = worldToTracerEnd(Camera, root.Position, from, origin)
					updateTracer(e.tracer, from, to, tracerColor)
				else
					e.tracer.Visible = false
				end
			end
		else
			clearEntry(plr)
		end
	end
end)

Players.PlayerRemoving:Connect(clearEntry)
LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait(0.2)
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		baseWalkSpeed = hum.WalkSpeed
	end
	applyWalkSpeed()
	if flag("play_fly", false) then
		startFly()
	end
end)

------------------------------------------------------------------------
-- UI
------------------------------------------------------------------------

hub:beginUpdate()

local visuals = hub:addTab("Visuals")
local playerTab = hub:addTab("Player")
local world = hub:addTab("World")
local misc = hub:addTab("Misc")

local esp = hub:addGroup(visuals, "ESP")
local tracersG = hub:addGroup(visuals, "Tracers")

hub:addToggle(esp, "enabled", "play_esp_on", true)
hub:addToggle(esp, "team check", "play_team_check", true)
hub:addToggleColor(esp, "name", "play_esp_names", "play_esp_names_color", true, Color3.new(1, 1, 1))
hub:addToggleColor(esp, "distance", "play_esp_dist", "play_esp_dist_color", true, Color3.fromRGB(200, 200, 200))
hub:addToggleColor(esp, "chams", "play_esp_box", "play_esp_chams_color", true, Color3.fromRGB(80, 200, 120))
hub:addSlider(esp, "maxdistance", "play_maxdistance", 100, 5000, 50, 2500)

hub:addToggleColor(tracersG, "tracers", "play_esp_tracers", "play_esp_tracers_color", true, Color3.fromRGB(118, 100, 200))
hub:addToggle(tracersG, "from bottom", "play_tracer_bottom", false)

local move = hub:addGroup(playerTab, "Movement")
local cam = hub:addGroup(playerTab, "Camera")

hub:addToggle(move, "speed", "play_speed_on", false, function()
	applyWalkSpeed()
end)
hub:addSlider(move, "walkspeed", "play_walkspeed", 16, 120, 1, 28, function()
	applyWalkSpeed()
end)
hub:addToggle(move, "fly", "play_fly", false, function(on)
	if on then
		startFly()
	else
		stopFly()
	end
end)
hub:addSlider(move, "fly speed", "play_flyspeed", 10, 200, 5, 50)

hub:addSlider(cam, "fov", "play_cam_fov", 50, 120, 1, 70, function()
	applyCameraFov()
end)
hub:addToggle(cam, "stretch fov", "play_stretch", false, function()
	applyCameraFov()
end)
hub:addToggle(cam, "cinematic bars", "play_cinematic", false, function()
	applyCameraFov()
end)
hub:addButton(cam, "reset camera", function()
	hub:set("play_cam_fov", savedCam.FieldOfView)
	hub:set("play_stretch", false)
	hub:set("play_cinematic", false)
	restoreCamera()
end)

local lightingG = hub:addGroup(world, "Lighting")
hub:addToggle(lightingG, "fullbright", "play_fullbright", false, function(on)
	applyFullbright(on)
	if not on then
		applyFog()
	end
end)
hub:addSlider(lightingG, "fog", "play_fog", 0, 100, 1, 40, function()
	applyFog()
end)
hub:addButton(lightingG, "reset lighting", function()
	hub:set("play_fullbright", false)
	hub:set("play_fog", 40)
	applyFullbright(false)
	applyFog()
end)

local session = hub:addGroup(misc, "Session")
hub:addButton(session, "destroy", function()
	hub:Destroy()
end)

hub:endUpdate()

-- sync once
applyWalkSpeed()
applyCameraFov()
applyFog()

local oldDestroy = hub.Destroy
function hub:Destroy()
	renderConn:Disconnect()
	stopFly()
	applyFullbright(false)
	restoreCamera()
	for plr in pairs(entries) do
		clearEntry(plr)
	end
	folder:Destroy()
	oldDestroy(self)
end

print("[MawyxxHub] Play demo ready — RightControl | ESP/tracers/stretch FOV/speed/fly")
