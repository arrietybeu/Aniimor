-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\SetMultiLevelItemFieldNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local SandboxConst = require("Common.Const.SandboxConst")
local SetMultiLevelItemFieldNode = Class.LiteClass("SetMultiLevelItemFieldNode", FlowNode)

function SetMultiLevelItemFieldNode:ctor(nodeId, nodeData, graph)
	SetMultiLevelItemFieldNode.super.ctor(self, nodeId, nodeData, graph)

	self.fieldSettings = nodeData.FieldSettings or {}
end

function SetMultiLevelItemFieldNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
end

function SetMultiLevelItemFieldNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local successCount = 0
	local totalCount = 0

	if self.fieldSettings then
		for i = 1, #self.fieldSettings do
			totalCount = totalCount + 1

			local setting = self.fieldSettings[i]

			if setting then
				local levelItemId = setting.LevelItemId
				local fieldName = setting.FieldName
				local fieldValue = setting.FieldValue

				if levelItemId and levelItemId ~= 0 and fieldName and fieldName ~= "" then
					local levelItem = space:getLevelItem(context.sandboxId, levelItemId)

					if levelItem then
						levelItem:setField(fieldName, fieldValue)

						successCount = successCount + 1
					end
				end
			end
		end
	end

	self.flowOut_Out:call(context)
end

return SetMultiLevelItemFieldNode
