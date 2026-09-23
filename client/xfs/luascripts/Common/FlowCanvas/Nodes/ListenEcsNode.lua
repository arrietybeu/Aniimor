-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ListenEcsNode.lua

local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local ListenEcsNode = Class.LiteClass("ListenEcsNode", ListenBaseNode)
local SceneUtils = require("Common.Utils.SceneUtils")
local ServerEventConst = require("Const.ServerEventConst")

function ListenEcsNode:ctor(nodeId, nodeData, graph)
	ListenEcsNode.super.ctor(self, nodeId, nodeData, graph)
end

function ListenEcsNode:registerPorts()
	ListenEcsNode.super.registerPorts(self)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_State = self:addValueInput("State")
	self.valueInput_IsEnter = self:addValueInput("IsEnter")
	self.valueInput_StaticId = self:addValueInput("StaticId")
end

local bit = bit

function ListenEcsNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local state = self:getContextValue(context, self.valueInput_State)
	local isEnter = self:getContextValue(context, self.valueInput_IsEnter)
	local staticId = self:getContextValue(context, self.valueInput_StaticId)
	local selfGlobalId = SceneUtils.getEnvIdByStaticId(staticId)

	if selfGlobalId then
		local function listener(globalId, oldState, newState)
			if globalId ~= selfGlobalId then
				return
			end

			local stateDiff = bit.bxor(oldState, newState)

			if bit.band(state, stateDiff) == 0 then
				return
			end

			if isEnter then
				if bit.band(newState, state) == 0 then
					return
				end
			elseif bit.band(newState, state) ~= 0 then
				return
			end

			self:removeTimer(context)
			self:checkDoOnce(context)
			self.flowOut_Out:call(context)
		end

		self:addEventListen(context, ServerEventConst.ECS_STATE_ENV_ENTITY, listener)
	elseif LoggerManager.checkLogger(LoggerConst.WARN) then
		self.logger:warn("ListenEcsNode find selfGlobalId fail. staticId:%s", staticId)
	end
end

return ListenEcsNode
