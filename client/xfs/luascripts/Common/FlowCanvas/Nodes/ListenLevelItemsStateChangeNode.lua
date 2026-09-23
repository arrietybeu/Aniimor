-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ListenLevelItemsStateChangeNode.lua

local Class = require("Core.Framework.Class")
local ServerEventConst = require("Const.ServerEventConst")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local ListenLevelItemsStateChangeNode = Class.LiteClass("ListenLevelItemsStateChangeNode", ListenBaseNode)

function ListenLevelItemsStateChangeNode:ctor(nodeId, nodeData, graph)
	ListenLevelItemsStateChangeNode.super.ctor(self, nodeId, nodeData, graph)
end

function ListenLevelItemsStateChangeNode:registerPorts()
	ListenLevelItemsStateChangeNode.super.registerPorts(self)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.levelItemIds = self.nodeData.LevelItemIds
	self.valueOutput_State = self:addValueOutput("State", function(context)
		return self:Get_State_Value(context)
	end)
	self.valueOutput_LevelItemId = self:addValueOutput("LevelItemId", function(context)
		return self:Get_LevelItemId_Value(context)
	end)
end

function ListenLevelItemsStateChangeNode:Get_State_Value(context)
	return self:getContextValue(context, self.valueOutput_State)
end

function ListenLevelItemsStateChangeNode:Get_LevelItemId_Value(context)
	return self:getContextValue(context, self.valueOutput_LevelItemId)
end

function ListenLevelItemsStateChangeNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local sandboxId = context.sandboxId

	for _, levelItemId in pairs(self.levelItemIds) do
		local levelItem = space:getLevelItem(sandboxId, levelItemId)

		if levelItem then
			local eventName = ServerEventConst.LEVELITEM_STATE_CHANGE .. levelItemId

			local function listener(args)
				if levelItemId ~= args.levelItemId or args.sandboxId ~= context.sandboxId or args.state == nil then
					return
				end

				self:removeTimer(context)
				self:checkDoOnce(context)
				self:setContextValue(context, self.valueOutput_State, args.state)
				self:setContextValue(context, self.valueOutput_LevelItemId, args.levelItemId)
				self.flowOut_Out:call(context)
			end

			self:addEventListen(context, eventName, listener)
		end
	end
end

return ListenLevelItemsStateChangeNode
