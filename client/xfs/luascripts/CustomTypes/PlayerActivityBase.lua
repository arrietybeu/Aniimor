-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PlayerActivityBase.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local PlayerActivityBase = class.LiteClass("PlayerActivityBase", CustomDict)

function PlayerActivityBase:isGoing()
	return self.activityId > 0
end

function PlayerActivityBase:getTaskInfoById(taskId)
	return self.activityTasks[taskId]
end

function PlayerActivityBase:foreachTask(cb)
	if not cb then
		return
	end

	for taskId, task in pairs(self.activityTasks) do
		cb(task)
	end
end

return PlayerActivityBase
