-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\SpaceComponent\\ClientSpaceGraphComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local SceneData = require("Data.scene_data")
local levelData = require("Data.level_data")
local ResLoader = require("GameApp.ResLoad.ResLoader")
local ClientSpaceGraphComponent = Class.Component("ClientSpaceGraphComponent")

function ClientSpaceGraphComponent:ctor()
	return
end

function ClientSpaceGraphComponent:getDebugger(graphId)
	return appFacade.sandboxManager:GetDebugger(graphId)
end

function ClientSpaceGraphComponent:RPC_SC_DebugCallPort(graphId, nodeId, port, targetNodeId, targetPortName)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_DebugCallPort ", graphId, nodeId, port, targetNodeId, targetPortName)
	end

	local debugger = self:getDebugger(graphId)

	if debugger then
		debugger:DebugCallPort(nodeId, port, false, targetNodeId, targetPortName)
	end
end

function ClientSpaceGraphComponent:RPC_SC_DebugPortIn(graphId, nodeId, port, fromNodeId, fromPortName)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_DebugPortIn ", graphId, nodeId, port, fromNodeId, fromPortName)
	end

	local debugger = self:getDebugger(graphId)

	if debugger then
		debugger:DebugCallPort(nodeId, port, true, fromNodeId, fromPortName)
	end
end

function ClientSpaceGraphComponent:RPC_SC_GraphRunningNode(graphId, nodeId, isRunning)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_GraphRunningNode ", graphId, nodeId, isRunning)
	end

	local debugger = self:getDebugger(graphId)

	if debugger then
		debugger:SetNodeRunningStatus(nodeId, isRunning)
	end
end

function ClientSpaceGraphComponent:RPC_SC_GraphDebugInfo(graphId, runningNodes, callOutputNodesCount, callInputNodesCount, callOutputNodesInfo, callInputNodesInfo)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_GraphDebugInfo ", graphId, inspect(callOutputNodesInfo), inspect(callInputNodesInfo))
	end

	local debugger = self:getDebugger(graphId)

	if debugger then
		for k, v in pairs(callOutputNodesCount) do
			debugger:SetNodeCallTimes(k, v)
		end

		for k, v in pairs(callInputNodesCount) do
			debugger:SetNodeInputCallTimes(k, v)
		end

		for index, value in ipairs(runningNodes) do
			debugger:SetNodeRunningStatus(value, true)
		end

		for sourceNodeId, info in pairs(callOutputNodesInfo) do
			for targetNodeId, portCallInfo in pairs(info) do
				if portCallInfo ~= nil then
					for portName, callTimes in pairs(portCallInfo) do
						print("节点", sourceNodeId, "调出到节点", targetNodeId, "的端口", portName, "调出次数", callTimes)
						debugger:SetNodeOutputCallTimeInfo(sourceNodeId, targetNodeId, portName, callTimes)
					end
				end
			end
		end

		for targetNodeId, info in pairs(callInputNodesInfo) do
			for sourceNodeId, portCallInfo in pairs(info) do
				if portCallInfo ~= nil then
					for portName, callTimes in pairs(portCallInfo) do
						print("节点", targetNodeId, "从节点", sourceNodeId, "的端口", portName, "调入次数", callTimes)
						debugger:SetNodeInputCallTimeInfo(targetNodeId, sourceNodeId, portName, callTimes)
					end
				end
			end
		end
	end
end

return ClientSpaceGraphComponent
