-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\TriggerGuideNode.lua

local Class = require("Core.Framework.Class")
local SandboxListenBaseNode = require("Common.FlowCanvas.Nodes.SandboxListenBaseNode")
local GuideData = require("Data.guide_data")
local TriggerGuideNode = Class.LiteClass("TriggerGuideNode", SandboxListenBaseNode)

function TriggerGuideNode:ctor(nodeId, nodeData, graph)
	TriggerGuideNode.super.ctor(self, nodeId, nodeData, graph)

	self._playerTriggerCount = {}
end

function TriggerGuideNode:registerPorts()
	TriggerGuideNode.super.registerPorts(self)

	self.valueInput_LevelItemId = self:addValueInput("levelItemId")
	self.valueInput_GuidanceGroupId = self:addValueInput("guidanceGroupId")
	self.valueInput_MaxPlayCount = self:addValueInput("maxPlayCount")
	self.flowOut_Enter = self:addFlowOutput("OnEnter")
	self.flowOut_Exit = self:addFlowOutput("OnExit")
end

function TriggerGuideNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local sandboxId = context.sandboxId
	local sandbox = space.sandboxes[sandboxId]

	if not sandbox then
		return
	end

	local levelItemId = self:getContextValue(context, self.valueInput_LevelItemId)
	local guidanceGroupId = self:getContextValue(context, self.valueInput_GuidanceGroupId)
	local maxPlayCount = self:getContextValue(context, self.valueInput_MaxPlayCount) or 1

	if not guidanceGroupId or guidanceGroupId == 0 or not GuideData[guidanceGroupId] then
		return
	end

	local function listener(lid, isEnter, actorId)
		if lid ~= levelItemId then
			return
		end

		if not isEnter then
			self.flowOut_Exit:call(context)

			return
		end

		local ent = pg.getEntityByActorId(actorId)

		if not ent then
			return
		end

		local player

		if ent.startGuidanceRecord then
			player = ent
		elseif ent.master and ent.master.startGuidanceRecord then
			player = ent.master
		end

		if not player then
			return
		end

		self.flowOut_Enter:call(context)

		local count = self._playerTriggerCount[actorId] or 0

		if maxPlayCount ~= -1 and count >= maxPlayCount then
			return
		end

		self._playerTriggerCount[actorId] = count + 1

		player:startGuidanceRecord(guidanceGroupId)
	end

	self:addSbEventListen(context, "TRIGGER_ENTER", listener)
end

return TriggerGuideNode
