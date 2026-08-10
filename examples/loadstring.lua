-- Cache-bust so executors don't keep an old HttpGet copy
(loadstring or load)(game:HttpGet("https://raw.githubusercontent.com/Mawyxx/MawyxxHub/main/dist/demo.lua?v=" .. tostring(tick())))()
