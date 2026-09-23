-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\SetCache.lua

local TablePool = require("Common.Container.TablePool")
local DoAction = require("Common.AICt.Nodes.DoAction")
local Class = require("Core.Framework.Class")
local SetCache = Class.LightClass("SetCache", DoAction)

function SetCache:onCallFlowInternal(flow)
	local cd = self:getInputValue(self.condition, flow)

	self:checkCondition(cd, flow)

	if not cd then
		return false
	end

	local context = TablePool.getTable(3)

	self:getContext(context, flow)
	flow:setCacheValue(self.nodeData.cacheNodeId, context.key, context.value)
	TablePool.returnTable(context, 3)
end

return SetCache
