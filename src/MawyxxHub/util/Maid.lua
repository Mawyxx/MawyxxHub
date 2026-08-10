-- Connection / cleanup bag. Disconnects RBX connections, runs functions, destroys Instances/Maids.

local Maid = {}
Maid.__index = Maid

function Maid.new()
	return setmetatable({ _tasks = {} }, Maid)
end

function Maid:Give(task)
	if task ~= nil then
		table.insert(self._tasks, task)
	end
	return task
end

function Maid:Connect(signal, handler)
	local connection = signal:Connect(handler)
	self:Give(connection)
	return connection
end

local function cleanupOne(task)
	local ty = typeof(task)
	if ty == "RBXScriptConnection" then
		task:Disconnect()
	elseif ty == "Instance" then
		task:Destroy()
	elseif type(task) == "function" then
		task()
	elseif type(task) == "table" then
		if type(task.DoCleaning) == "function" then
			task:DoCleaning()
		elseif type(task.Destroy) == "function" then
			task:Destroy()
		elseif type(task.Disconnect) == "function" then
			task:Disconnect()
		end
	end
end

function Maid:DoCleaning()
	for i = #self._tasks, 1, -1 do
		local task = self._tasks[i]
		self._tasks[i] = nil
		cleanupOne(task)
	end
end

function Maid:Destroy()
	self:DoCleaning()
	setmetatable(self, nil)
end

return Maid
