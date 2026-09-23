-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\RacingTempleNode.lua

local Class = require("Core.Framework.Class")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local RacingTempleNode = Class.LiteClass("RacingTempleNode", ListenBaseNode)
local ServerEventConst = require("Const.ServerEventConst")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")

function RacingTempleNode:ctor(nodeId, nodeData, graph)
	RacingTempleNode.super.ctor(self, nodeId, nodeData, graph)
end

function RacingTempleNode:getGameplay(context)
	local space = context:getSpace()

	if not space then
		return
	end

	local sandbox = space.sandboxes[context.sandboxId]

	if not sandbox then
		return
	end

	local gameplay = sandbox:getGameplay()

	if gameplay and gameplay.type == Const.GAME_PLAY_RACING_TEMPLE then
		return gameplay
	end
end

function RacingTempleNode:registerPorts()
	RacingTempleNode.super.registerPorts(self)
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.valueInput_WaterDurationList = self:addValueInput("WaterDurationList")
	self.valueInput_Countdown = self:addValueInput("Countdown")
	self.valueInput_CountdownShowTime = self:addValueInput("CountdownShowTime")
	self.valueInput_StageList = self:addValueInput("StageList")
	self.valueInput_TargetList = self:addValueInput("TargetList")
	self.valueInput_SwitchId = self:addValueInput("SwitchId")
	self.valueInput_RacingId = self:addValueInput("RacingId")
	self.valueInput_WaterHeightList = self:addValueInput("WaterHeightList")
	self.flowOut_Trigger = self:addFlowOutput("Trigger")
	self.flowOut_Finish = self:addFlowOutput("Finish")
	self.flowOut_OnStageChange = self:addFlowOutput("OnStageChange")
	self.flowOut_OnRestart = self:addFlowOutput("OnRestart")
	self.valueInput_RestartDelayTime = self:addValueInput("RestartDelayTime")
	self.valueInput_PortalSceneId = self:addValueInput("PortalSceneId")
	self.valueInput_PortalId = self:addValueInput("PortalId")

	self:addValueOutput("Status", function(context)
		local gameplay = self:getGameplay(context)

		if gameplay then
			return gameplay.status
		end

		return 0
	end)
	self:addValueOutput("Stage", function(context)
		local gameplay = self:getGameplay(context)

		if gameplay then
			return gameplay.curStage
		end

		return 0
	end)
end

function RacingTempleNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local sandboxId = context.sandboxId
	local sandbox = space.sandboxes[sandboxId]

	if not sandbox then
		return
	end

	local function triggerListener()
		self.flowOut_Trigger:call(context)
	end

	local function finishListener()
		self.flowOut_Finish:call(context)
	end

	local function onStageChangeListener()
		self.flowOut_OnStageChange:call(context)
	end

	local function onRestartListener()
		local portalSceneId = self:getContextValue(context, self.valueInput_PortalSceneId) or 0
		local portalId = self:getContextValue(context, self.valueInput_PortalId) or 0

		if portalId ~= 0 then
			if portalSceneId == 0 then
				portalSceneId = space.sceneId
			end

			for _, player in pairs(sandbox:getActivePlayers()) do
				player:portal(portalSceneId, portalId)
			end
		end

		self.flowOut_OnRestart:call(context)
	end

	local targetList = self:getContextValue(context, self.valueInput_TargetList)

	targetList = Utils.deepCopyTable(targetList)

	sandbox:createGamePlay(Const.GAME_PLAY_RACING_TEMPLE, {
		countdown = self:getContextValue(context, self.valueInput_Countdown),
		countdownShowTime = self:getContextValue(context, self.valueInput_CountdownShowTime),
		targetList = targetList,
		switchId = self:getContextValue(context, self.valueInput_SwitchId),
		racingId = self:getContextValue(context, self.valueInput_RacingId),
		finishCallback = finishListener,
		triggerCallback = triggerListener,
		onStageChangeCallback = onStageChangeListener,
		onRestartCallback = onRestartListener,
		restartDelayTime = self:getContextValue(context, self.valueInput_RestartDelayTime)
	})
end

return RacingTempleNode
