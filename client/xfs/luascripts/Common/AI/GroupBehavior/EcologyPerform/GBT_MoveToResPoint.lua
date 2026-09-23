-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\GroupBehavior\\EcologyPerform\\GBT_MoveToResPoint.lua

local Class = require("Core.Framework.Class")
local GroupBehaviourTacheBase = require("Common.AI.GroupBehavior.GroupBehaviourTacheBase")
local GBT_MoveToResPoint = Class.LiteClass("GBT_MoveToResPoint", GroupBehaviourTacheBase)

function GBT_MoveToResPoint:_getTriggerEventName(member)
	return "GBTrigger_Test_MoveToResPoint"
end

function GBT_MoveToResPoint:_getTriggerContext(member, context)
	context.tPointId = self:getBindResPoint():getFixPointId()
	context.tPortId = self:getMemberIndex(member)
end

function GBT_MoveToResPoint:_getFinishBehavId(member)
	return "BP_Wild_Com_Test_GroupBehav_MoveToResPoint"
end

return GBT_MoveToResPoint
