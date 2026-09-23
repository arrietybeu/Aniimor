-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\CreateEntityGroupBehaviour.lua

local DoAction = require("Common.AICt.Nodes.DoAction")
local Class = require("Core.Framework.Class")
local CreateEntityGroupBehaviour = Class.LightClass("CreateEntityGroupBehaviour", DoAction)

function CreateEntityGroupBehaviour:getEventName()
	return "CreateEntityGroupBehaviour"
end

function CreateEntityGroupBehaviour:getContext(context, flow)
	DoAction.getContext(self, context, flow)

	context.behavName = self.nodeData.behavName
end

return CreateEntityGroupBehaviour
