-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ServerMultiListenerEventNode.lua

local Class = require("Core.Framework.Class")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local AccessControl = require("Core.Framework.AccessControl")
local EventStateCheck = require("Common.FlowCanvas.EventStateCheck")
local ServerMultiListenerEventNode = Class.LiteClass("ServerMultiListenerEventNode", ListenBaseNode)

function ServerMultiListenerEventNode:ctor(nodeId, nodeData, graph)
	ServerMultiListenerEventNode.super.ctor(self, nodeId, nodeData, graph)
end

function ServerMultiListenerEventNode:registerPorts()
	ServerMultiListenerEventNode.super.registerPorts(self)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_EventName = self:addValueInput("EventName")
	self.groupOutputs = {}

	local eventParams = self.nodeData.eventParams or {}

	self.everyDoOnce = self.nodeData.everyDoOnce

	if self.everyDoOnce == true then
		self.finishedEvents = {}
	end

	if eventParams and #eventParams > 0 then
		for i, paramGroup in ipairs(eventParams) do
			local outputPortName = "Group" .. i
			local flowOutput = self:addFlowOutput(outputPortName)

			self.groupOutputs[i] = flowOutput
			self["flowOut_" .. outputPortName] = flowOutput
		end
	end
end

function ServerMultiListenerEventNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local eventName = self:getContextValue(context, self.valueInput_EventName) or self.nodeData.EventName

	if not eventName or eventName == "" then
		return
	end

	local player = space.ownerPlayer

	if player then
		local func = EventStateCheck[eventName]

		if func then
			local eventParams = self.nodeData.eventParams or {}

			if eventParams and #eventParams > 0 then
				for i, data in ipairs(eventParams) do
					if data and func(player, data) then
						local firstOutput = self["flowOut_Group" .. i]

						if firstOutput then
							firstOutput:call(context)
						end
					end
				end
			end
		end
	end

	local function listener(args)
		args = args or {}

		local eventParams = self.nodeData.eventParams or {}

		if not eventParams or #eventParams == 0 then
			return
		end

		for groupIndex, paramGroup in ipairs(eventParams) do
			if not paramGroup then
				-- block empty
			else
				local isGroupMatched = true

				for paramName, configValue in pairs(paramGroup) do
					local eventValue = args[paramName]
					local normalizedEventValue = eventValue
					local normalizedConfigValue = configValue

					if type(eventValue) == "number" and type(configValue) == "string" then
						normalizedConfigValue = tonumber(configValue)
					elseif type(eventValue) == "string" and type(configValue) == "number" then
						normalizedEventValue = tonumber(eventValue)
					elseif type(eventValue) == "string" and type(configValue) == "string" then
						local eventNum = tonumber(eventValue)
						local configNum = tonumber(configValue)

						if eventNum and configNum then
							normalizedEventValue = eventNum
							normalizedConfigValue = configNum
						end
					end

					if normalizedEventValue ~= normalizedConfigValue then
						isGroupMatched = false

						break
					end
				end

				if not isGroupMatched or self.everyDoOnce == true and self.finishedEvents[groupIndex] == true then
					goto label_4_0
				elseif self.everyDoOnce == true then
					self.finishedEvents[groupIndex] = true
				end

				for k, v in pairs(args) do
					if self["valueOutput_" .. k] then
						self:setContextValue(context, self["valueOutput_" .. k], v)
					end
				end

				self:removeTimer(context)
				self:checkDoOnce(context)

				local outputPortName = "Group" .. groupIndex
				local flowOutput = self["flowOut_" .. outputPortName]

				if flowOutput then
					flowOutput:call(context)
				end

				self.flowOut_Out:call(context)
			end

			::label_4_0::
		end
	end

	self:addEventListen(context, eventName, listener)
end

return ServerMultiListenerEventNode
