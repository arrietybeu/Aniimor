-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\MoveLevelItemNode.lua

local Class = require("Core.Framework.Class")
local ServerEventConst = require("Const.ServerEventConst")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local MoveLevelItemNode = Class.LiteClass("MoveLevelItemNode", ListenBaseNode)

function MoveLevelItemNode:ctor(nodeId, nodeData, graph)
	MoveLevelItemNode.super.ctor(self, nodeId, nodeData, graph)
end

function MoveLevelItemNode:registerPorts()
	MoveLevelItemNode.super.registerPorts(self)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_LevelItemId = self:addValueInput("LevelItemId")
	self.valueInput_Index = self:addValueInput("Index")
end

function MoveLevelItemNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local levelItemId = self:getContextValue(context, self.valueInput_LevelItemId)
	local index = self:getContextValue(context, self.valueInput_Index)
	local sandboxId = context.sandboxId
	local levelItem = space:getLevelItem(sandboxId, levelItemId)

	if not levelItem or not levelItem.startMove then
		return
	end

	levelItem:startMove(index)

	local eventName = ServerEventConst.LEVELITEM_ARRIVE .. sandboxId .. levelItemId .. "index" .. index

	local function listener()
		self:removeTimer(context)
		self:checkDoOnce(context)
		self.flowOut_Out:call(context)
	end

	self:addEventListen(context, eventName, listener)
end

return MoveLevelItemNode
