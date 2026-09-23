-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\RiftNode.lua

local Class = require("Core.Framework.Class")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local RiftNode = Class.LiteClass("RiftNode", ListenBaseNode)
local ServerEventConst = require("Const.ServerEventConst")
local Const = require("Common.Const.Const")

function RiftNode:ctor(nodeId, nodeData, graph)
	RiftNode.super.ctor(self, nodeId, nodeData, graph)
end

function RiftNode:registerPorts()
	RiftNode.super.registerPorts(self)
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.valueInput_SpawnerList = self:addValueInput("SpawnerList")
	self.valueInput_TargetStaticId = self:addValueInput("TargetStaticId")
	self.valueInput_FailRadius = self:addValueInput("FailRadius")
	self.valueInput_Center = self:addValueInput("Center")
	self.flowOut_Success = self:addFlowOutput("Success")
	self.flowOut_Fail = self:addFlowOutput("Fail")
end

function RiftNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local sandboxId = context.sandboxId
	local sandbox = space.sandboxes[sandboxId]

	if not sandbox then
		return
	end

	sandbox:createGamePlay(Const.GAME_PLAY_RIFT, {
		spawnerList = self:getContextValue(context, self.valueInput_SpawnerList),
		targetStaticId = self:getContextValue(context, self.valueInput_TargetStaticId),
		failRadius = self:getContextValue(context, self.valueInput_FailRadius),
		center = self:getContextValue(context, self.valueInput_Center)
	})

	local function finishListener(args)
		self:removeTimer(context)
		self:checkDoOnce(context)

		if args and args.success then
			self.flowOut_Success:call(context)
		else
			self.flowOut_Fail:call(context)
		end
	end

	self:addEventListen(context, ServerEventConst.RIFT_FINISH .. sandboxId, finishListener)
end

return RiftNode
