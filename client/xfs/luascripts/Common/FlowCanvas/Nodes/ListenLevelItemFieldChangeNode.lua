-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ListenLevelItemFieldChangeNode.lua

local Class = require("Core.Framework.Class")
local ServerEventConst = require("Const.ServerEventConst")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local ListenLevelItemFieldChangeNode = Class.LiteClass("ListenLevelItemFieldChangeNode", ListenBaseNode)

function ListenLevelItemFieldChangeNode:ctor(nodeId, nodeData, graph)
	ListenLevelItemFieldChangeNode.super.ctor(self, nodeId, nodeData, graph)
end

function ListenLevelItemFieldChangeNode:registerPorts()
	ListenLevelItemFieldChangeNode.super.registerPorts(self)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.flowOut_Init = self:addFlowOutput("Init")
	self.valueInput_LevelItemId = self:addValueInput("LevelItemId")
	self.valueInput_fieldName = self:addValueInput("fieldName")
	self.firstIn = "firstIn" .. self.nodeId

	for _, field in pairs(self._outputPortValues) do
		self:addValueOutput(field, function(context)
			return self:Get_Field_Value(context, field)
		end)
	end
end

function ListenLevelItemFieldChangeNode:Get_Field_Value(context, field)
	local space = context:getSpace()

	if not space then
		return
	end

	local levelItemId = self:getContextValue(context, self.valueInput_LevelItemId)
	local sandboxId = context.sandboxId
	local levelItem = space:getLevelItem(sandboxId, levelItemId)

	if not levelItem then
		return
	end

	if not field or field == "" then
		field = "state"
	end

	return levelItem[field]
end

function ListenLevelItemFieldChangeNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local levelItemId = self:getContextValue(context, self.valueInput_LevelItemId)
	local sandboxId = context.sandboxId
	local levelItem = space:getLevelItem(sandboxId, levelItemId)

	if not levelItem then
		return
	end

	local fieldName = self:getContextValue(context, self.valueInput_fieldName)
	local firstIn = context:getContextValue(self.firstIn)

	if levelItem[fieldName] and not firstIn then
		context:setContextValue(self.firstIn, true)
		self.flowOut_Init:call(context)
	end

	local eventName = ServerEventConst.LEVELITEM_STATE_CHANGE .. levelItemId

	local function listener(args)
		if levelItemId ~= args.levelItemId or args.sandboxId ~= context.sandboxId or args[fieldName] == nil then
			return
		end

		self:removeTimer(context)
		self:checkDoOnce(context)
		self.flowOut_Out:call(context)
	end

	self:addEventListen(context, eventName, listener)
end

return ListenLevelItemFieldChangeNode
