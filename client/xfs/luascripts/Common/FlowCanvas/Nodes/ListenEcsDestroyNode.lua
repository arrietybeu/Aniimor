-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ListenEcsDestroyNode.lua

local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local ListenEcsDestroyNode = Class.LiteClass("ListenEcsDestroyNode", ListenBaseNode)
local SceneUtils = require("Common.Utils.SceneUtils")
local ServerEventConst = require("Const.ServerEventConst")

function ListenEcsDestroyNode:ctor(nodeId, nodeData, graph)
	ListenEcsDestroyNode.super.ctor(self, nodeId, nodeData, graph)
end

function ListenEcsDestroyNode:registerPorts()
	ListenEcsDestroyNode.super.registerPorts(self)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_Reason = self:addValueInput("Reason")
	self.valueInput_StaticId = self:addValueInput("StaticId")
	self.valueOutput_Position = self:addValueOutput("Position", function(context)
		return self:getContextValue(context, self.valueOutput_Position)
	end)
end

function ListenEcsDestroyNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local staticId = self:getContextValue(context, self.valueInput_StaticId)
	local reason = self:getContextValue(context, self.valueInput_Reason)
	local globalId = SceneUtils.getEnvIdByStaticId(staticId)

	if globalId then
		local eventName = ServerEventConst.ECS_DESTROY_ENV_ENTITY .. "#" .. globalId .. "#" .. reason

		local function listener(position)
			if not position then
				local ent = space:getEntityByStaticId(staticId)

				position = ent and ent.getPosition and ent:getPosition() or nil
			end

			self:setContextValue(context, self.valueOutput_Position, position)
			self:removeTimer(context)
			self:checkDoOnce(context)
			self.flowOut_Out:call(context)
		end

		self:addEventListen(context, eventName, listener)
	elseif LoggerManager.checkLogger(LoggerConst.WARN) then
		self.logger:warn("ListenEcsDestroyNode find globalId fail. staticId:%s", staticId)
	end
end

return ListenEcsDestroyNode
