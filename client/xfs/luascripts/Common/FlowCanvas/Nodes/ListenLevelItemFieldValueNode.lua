-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ListenLevelItemFieldValueNode.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local ServerEventConst = require("Const.ServerEventConst")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local levelItemSubtypeData = require("Data.level_item_subtype_data")
local ListenLevelItemFieldValueNode = Class.LiteClass("ListenLevelItemFieldValueNode", FlowNode)

function ListenLevelItemFieldValueNode:ctor(nodeId, nodeData, graph)
	ListenLevelItemFieldValueNode.super.ctor(self, nodeId, nodeData, graph)
end

function ListenLevelItemFieldValueNode:registerPorts()
	ListenLevelItemFieldValueNode.super.registerPorts(self)

	self.timerKey = self.nodeId .. "timer"
	self.flowOut_Out = self:addFlowOutput("Out")
	self.flowOut_TimeOut = self:addFlowOutput("TimeOut")
	self.valueInput_TimeOutSecond = self:addValueInput("TimeOutSecond")
	self.valueInput_LevelItemId = self:addValueInput("LevelItemId")
	self.valueInput_fieldName = self:addValueInput("fieldName")
	self.valueInput_fieldValue = self:addValueInput("fieldValue")

	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)
end

function ListenLevelItemFieldValueNode:On_In_PortCalled(context, inputPortName)
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

	local className = levelItem.className or "LevelItem"

	if not levelItemSubtypeData[className] then
		return
	end

	local fieldName = self:getContextValue(context, self.valueInput_fieldName)
	local fieldValue = self:fixInputFieldValue(context, className, fieldName)

	if levelItem[fieldName] == fieldValue then
		self.flowOut_Out:call(context)

		return
	end

	self:addTimer(context)

	local function setListener(args)
		if levelItemId ~= args.levelItemId or args.sandboxId ~= context.sandboxId or args[fieldName] == nil or args[fieldName] ~= fieldValue then
			return
		end

		self:_clearup(context)
		self.flowOut_Out:call(context)
	end

	local setEventName = ServerEventConst.LEVELITEM_STATE_SET .. levelItemId

	self:addEventListen(context, setEventName, setListener)

	local changeEventName = ServerEventConst.LEVELITEM_STATE_CHANGE .. levelItemId

	local function changeListener(args)
		if levelItemId ~= args.levelItemId or args.sandboxId ~= context.sandboxId or args[fieldName] == nil or args[fieldName] ~= fieldValue then
			return
		end

		self:_clearup(context)
		self.flowOut_Out:call(context)
	end

	self:addEventListen(context, changeEventName, changeListener)
end

function ListenLevelItemFieldValueNode:fixInputFieldValue(context, className, fieldName)
	local fieldValue = self:getContextValue(context, self.valueInput_fieldValue)
	local found = false

	for index, listenField in pairs(levelItemSubtypeData[className].listenField or EMPTY_TABLE) do
		if listenField == fieldName then
			local expectedType = levelItemSubtypeData[className].listenFieldType and levelItemSubtypeData[className].listenFieldType[index] or "string"
			local parsedValue = self:ParseValueFromString(fieldValue, expectedType)

			fieldValue = parsedValue
			found = true

			break
		end
	end

	if not found then
		self.logger:error("@node ListenLevelItemFieldValueNode fieldName=%s type not found in levelItemSubtypeData[%s]", fieldName, className)
	end

	return fieldValue
end

function ListenLevelItemFieldValueNode:ParseValueFromString(strValue, expectedType)
	if not strValue or strValue == "" then
		return nil
	end

	if expectedType == "int" then
		return tonumber(strValue)
	end

	if expectedType == "bool" or expectedType == "boolean" then
		return strValue == "true" or strValue == "True" or strValue == "1"
	end

	if expectedType == "float" then
		return tonumber(strValue)
	end

	if expectedType == "string" then
		return strValue
	end

	return strValue
end

function ListenLevelItemFieldValueNode:addEventListen(context, eventName, listener)
	local space = context:getSpace()

	if not space then
		return
	end

	context:registerSpaceEventListener(self.nodeId, eventName, listener)
end

function ListenLevelItemFieldValueNode:addTimer(context)
	local timer = context:getTimer(self.timerKey)
	local timeroutSecond = self:getContextValue(context, self.valueInput_TimeOutSecond)

	if timeroutSecond and timeroutSecond ~= 0 and not timer then
		context:addContextTimer(self.timerKey, timeroutSecond, self, "On_Timeout")
	end
end

function ListenLevelItemFieldValueNode:removeTimer(context)
	context:removeContextTimer(self.timerKey, self.nodeId)
end

function ListenLevelItemFieldValueNode:On_Timeout(context)
	local timer = context:getTimer(self.timerKey)

	if not timer then
		return
	end

	self:_clearup(context)
	self.flowOut_TimeOut:call(context)
end

function ListenLevelItemFieldValueNode:_clearup(context)
	context:unregisterSpaceEventListeners(self.nodeId)
	self:removeTimer(context)
end

function ListenLevelItemFieldValueNode:onContextDestroy(context)
	if context then
		self:removeTimer(context)
	end

	ListenLevelItemFieldValueNode.super.onContextDestroy(self, context)
end

return ListenLevelItemFieldValueNode
