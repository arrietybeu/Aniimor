-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ListenLevelItemFieldSetNode.lua

local Class = require("Core.Framework.Class")
local ServerEventConst = require("Const.ServerEventConst")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local ListenLevelItemFieldSetNode = Class.LiteClass("ListenLevelItemFieldSetNode", ListenBaseNode)

function ListenLevelItemFieldSetNode:ctor(nodeId, nodeData, graph)
	ListenLevelItemFieldSetNode.super.ctor(self, nodeId, nodeData, graph)
end

function ListenLevelItemFieldSetNode:registerPorts()
	ListenLevelItemFieldSetNode.super.registerPorts(self)

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

function ListenLevelItemFieldSetNode:Get_Field_Value(context, field)
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

function ListenLevelItemFieldSetNode:On_In_PortCalled(context, inputPortName)
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

	local eventName = ServerEventConst.LEVELITEM_STATE_SET .. levelItemId

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

return ListenLevelItemFieldSetNode
