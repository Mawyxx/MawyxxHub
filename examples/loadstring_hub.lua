-- Framework load with HttpGet cache-bust (ALWAYS use ?v=... or a commit SHA)
local ls = loadstring or load
local MawyxxHub = ls(game:HttpGet(
	"https://raw.githubusercontent.com/Mawyxx/MawyxxHub/main/dist/MawyxxHub.lua?v=" .. tostring(tick())
))()
print("[load] MawyxxHub", MawyxxHub.VERSION)
return MawyxxHub
