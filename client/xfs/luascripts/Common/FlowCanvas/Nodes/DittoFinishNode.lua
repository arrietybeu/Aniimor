-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\DittoFinishNode.lua

local Class = require("Core.Framework.Class")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local DittoFinishNode = Class.LiteClass("DittoFinishNode", ListenBaseNode)

function DittoFinishNode:ctor(nodeId, nodeData, graph)
	DittoFinishNode.super.ctor(self, nodeId, nodeData, graph)
end

function DittoFinishNode:registerPorts()
	DittoFinishNode.super.registerPorts(self)
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.valueInput_Success = self:addValueInput("Success")
end

function DittoFinishNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local sandboxId = context.sandboxId
	local sandbox = space.sandboxes[sandboxId]

	if not sandbox then
		return
	end

	local dittoDungeonGamePlay = sandbox:getGameplay()

	if not dittoDungeonGamePlay then
		return
	end

	local success = self:getContextValue(context, self.valueInput_Success)

	if success then
		dittoDungeonGamePlay:onStatusSuccess()
	else
		dittoDungeonGamePlay:onStatusFail()
	end
end

return DittoFinishNode
