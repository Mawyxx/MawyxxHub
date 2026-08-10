-- Optional demo with cache-bust (executors often pin HttpGet by URL forever).
(loadstring or load)(game:HttpGet("https://raw.githubusercontent.com/Mawyxx/MawyxxHub/main/dist/demo.lua?t=" .. tostring(tick())))()
