-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Component\\BaseTipComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local BaseTipComponent = Class.LightClass("BaseTipComponent", UIComponent)

function BaseTipComponent:onCtor(info)
	self.priority = info and info.priority and info.priority or 0
end

function BaseTipComponent:preUpdate(param)
	return false
end

function BaseTipComponent:onUpdate()
	return
end

function BaseTipComponent:checkIsRunning()
	return false
end

function BaseTipComponent:clearRunningList(force)
	return
end

function BaseTipComponent:clearQueueList()
	return
end

function BaseTipComponent:hideRunningList(param)
	return
end

function BaseTipComponent:checkMutWithOtherModel(modelPriority)
	return true
end

function BaseTipComponent:openFullScreenPanel()
	return
end

function BaseTipComponent:onDestroy()
	UIComponent.onDestroy(self)
	self:clearQueueList()
	self:clearRunningList(true)
end

function BaseTipComponent:NotifyEdgeTipChanged(isShow, flag)
	self.ctrl:onEdgeTipPriorityChange(self.priority, isShow, flag)
end

return BaseTipComponent
