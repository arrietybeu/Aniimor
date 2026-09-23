-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\RescueNode.lua

local Class = require("Core.Framework.Class")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local RescueNode = Class.LiteClass("RescueNode", ListenBaseNode)
local ServerEventConst = require("Const.ServerEventConst")

function RescueNode:ctor(nodeId, nodeData, graph)
	RescueNode.super.ctor(self, nodeId, nodeData, graph)
end

function RescueNode:registerPorts()
	RescueNode.super.registerPorts(self)
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.valueInput_TrappedStaticId = self:addValueInput("TrappedStaticId")
	self.flowOut_Init = self:addFlowOutput("Init")
	self.flowOut_SuccessCondition = self:addFlowOutput("SuccessCondition")
	self.flowOut_EnterBattle = self:addFlowOutput("EnterBattle")
	self.flowOut_ExitBattle = self:addFlowOutput("ExitBattle")
	self.flowOut_EnterRescueGame = self:addFlowOutput("EnterRescueGame")
	self.flowOut_ExitRescueGame = self:addFlowOutput("ExitRescueGame")
	self.firstIn = "firstIn" .. self.nodeId
end

function RescueNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local firstIn = context:getContextValue(self.firstIn)

	if firstIn == nil then
		self:removeTimer(context)
		self:checkDoOnce(context)
		context:setContextValue(self.firstIn, true)
		self.flowOut_Init:call(context)
		self.flowOut_SuccessCondition:call(context)
	end

	local eventName = ServerEventConst.PLAYER_ENTER_COMBAT

	local function enterCombatListener(args)
		self:removeTimer(context)
		self:checkDoOnce(context)
		self.flowOut_EnterBattle:call(context)
	end

	self:addEventListen(context, eventName, enterCombatListener)

	local eventName = ServerEventConst.PLAYER_LEAVE_COMBAT

	local function leaveCombatListener(args)
		self:removeTimer(context)
		self:checkDoOnce(context)
		self.flowOut_ExitBattle:call(context)
	end

	self:addEventListen(context, eventName, leaveCombatListener)

	local staticId = self:getContextValue(context, self.valueInput_TrappedStaticId)
	local eventName = ServerEventConst.ENTER_CALL_FRIENDS

	local function callFriendsListener(args)
		if args.staticId == staticId then
			self:removeTimer(context)
			self:checkDoOnce(context)
			self.flowOut_EnterRescueGame:call(context)
		end
	end

	self:addEventListen(context, eventName, callFriendsListener)

	local eventName = ServerEventConst.LEAVE_CALL_FRIENDS

	local function leaveFriendsListener(args)
		if args.staticId == staticId then
			self:removeTimer(context)
			self:checkDoOnce(context)
			self.flowOut_ExitRescueGame:call(context)
		end
	end

	self:addEventListen(context, eventName, leaveFriendsListener)
end

return RescueNode
