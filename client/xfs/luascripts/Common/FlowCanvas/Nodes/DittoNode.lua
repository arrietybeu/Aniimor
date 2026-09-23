-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\DittoNode.lua

local Class = require("Core.Framework.Class")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local DittoNode = Class.LiteClass("DittoNode", ListenBaseNode)
local ServerEventConst = require("Const.ServerEventConst")
local Const = require("Common.Const.Const")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")

function DittoNode:ctor(nodeId, nodeData, graph)
	DittoNode.super.ctor(self, nodeId, nodeData, graph)
end

function DittoNode:registerPorts()
	DittoNode.super.registerPorts(self)
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.failRadius = self.nodeData.FailRadius
	self.entryPoiId = self.nodeData.EntryPoiId
	self.entrySceneId = self.nodeData.EntrySceneId
	self.valueInput_Center = self:addValueInput("Center")
	self.flowOut_Success = self:addFlowOutput("Success")
end

function DittoNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local sandboxId = context.sandboxId
	local sandbox = space.sandboxes[sandboxId]

	if not sandbox then
		return
	end

	sandbox:createGamePlay(Const.GAME_PLAY_DITTO, {
		failRadius = self.failRadius,
		entryPoiId = self.entryPoiId,
		entrySceneId = self.entrySceneId,
		center = self:getContextValue(context, self.valueInput_Center)
	})

	local eventName = ServerEventConst.DITTO_SUCCESS .. space.sceneId

	local function listener()
		self:removeTimer(context)
		self:checkDoOnce(context)
		self.flowOut_Success:call(context)
	end

	self:addEventListen(context, eventName, listener)
end

return DittoNode
