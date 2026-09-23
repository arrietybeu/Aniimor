-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\GroupSingPuzzle.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local VirtualEntitiesContainer = require("GameApp.Sandbox.VirtualEntitiesContainer")
local ClientUtils = require("Utils.ClientUtils")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local EventConst = require("Const.EventConst")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("GroupSingPuzzle", "Sandbox", LoggerConst.ERROR)
local PlayableConst = require("Common.Const.PlayableConst")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local SandboxConst = require("Common.Const.SandboxConst")
local ClientConst = require("Const.ClientConst")
local AudioConst = require("Const.AudioConst")
local Time = require("Core.Common.Time")
local NoticeDef = require("Common.NoticeDef")
local ClientModelUtils = require("Utils.ClientModelUtils")
local GroupSingPuzzle = Class.LightClass("GroupSingPuzzle", VirtualEntitiesContainer)
local BGM_NAME = "BGM_SceneObject_ARK_StreetPerform"
local SWITCH_NAME = "Character%s_Options"
local OPTION_NAME = "Character%s_Options_0%s"
local OPTION_MUTE = "Character%s_Options_Mute"
local TIMELINE_TAG = "GroupSingPuzzle"

function GroupSingPuzzle:ctor(sandBox, spawnInfo, syncInfo)
	GroupSingPuzzle.super.ctor(self, sandBox, spawnInfo, syncInfo)

	self.puzzleEntityInfo = {}
	self.otherEntityInfo = {}
	self.watchEntityInfo = {}
end

function GroupSingPuzzle:destroy()
	pg.global.ui.topLogo:setTopLogoVisible(UIConst.TOPLOGO_VISIBLE_KEY.GROUP_SING, true)

	for singIndex, entityInfo in pairs(self.puzzleEntityInfo) do
		self:entStopSing(entityInfo)
	end

	self:setOtherEntityAudio(false)
	pg.game.audio:stopEvent(BGM_NAME)
	pg.game.audio:trySetState(AudioConst.STATE_GROUP_BGM_VOLUME, AudioConst.ATTENUATION_STATE_ID_NORMAL, self:getClassType())
	GroupSingPuzzle.super.destroy(self)
end

function GroupSingPuzzle:onSandboxReady()
	self.groupSingSB = self.shell.gameObject:GetComponent("GroupSingPuzzleSB")
	self.clientCustomVariableId = self.groupSingSB.clientCustomVariableId or 0

	self:createSubEntities()
	self:checkAndSetClientState()
	self:refreshNpcState()
end

function GroupSingPuzzle:onCreateVirtualEntity(refKey, extraInfo)
	local vEnt = ClientUtils.createClientEntity("ClientVirtualNpc", VirtualEntUtils.getNewVirtualEntityId(), extraInfo)

	if not vEnt then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("GroupSingPuzzle onCreateVirtualEntity failed", refKey, extraInfo.templateId)
		end

		return nil
	end

	vEnt:setPositionRotation(extraInfo.rootTrans.position, extraInfo.rootTrans.rotation)

	vEnt.singNpcIndex = extraInfo.singNpcIndex

	vEnt:enterSpace(pg.me.space)

	local defaultAnim = extraInfo.defaultAnim or PlayableConst.Idle

	vEnt:playAnimation(defaultAnim, nil, TIMELINE_TAG)

	return vEnt
end

function GroupSingPuzzle:checkNpcCanInteract(npcEnt, interactUnity)
	if self.puzzleState == SandboxConst.GroupPuzzleState.Disable or self.puzzleState == SandboxConst.GroupPuzzleState.Finish then
		return false
	end

	local singIndex = npcEnt.singNpcIndex
	local lastInteractTime = self.puzzleEntityInfo[singIndex].lastInteractTime

	if lastInteractTime and lastInteractTime + 2 > Time.realSecondCache then
		return false
	end

	return true
end

function GroupSingPuzzle:npcInteractFunc(npcEnt, funcMenuId, index)
	local singIndex = npcEnt.singNpcIndex

	self.puzzleEntityInfo[singIndex].choice = index
	self.puzzleEntityInfo[singIndex].lastInteractTime = Time.realSecondCache

	if index ~= 3 then
		self:entDoSing(self.puzzleEntityInfo[singIndex], funcMenuId, index)
	else
		self:entStopSing(self.puzzleEntityInfo[singIndex])
	end

	self:refreshPuzzleState()
end

function GroupSingPuzzle:entDoSing(entityInfo, funcMenuId, index)
	local npcEnt = entityInfo.ent

	npcEnt:stopAllAnimation()
	npcEnt:playAnimation(entityInfo.choicePlayableName, true, TIMELINE_TAG, true)

	if entityInfo.switchIndex and entityInfo.correctIndex and entityInfo.wrongIndex then
		local switchStr = string.format(SWITCH_NAME, entityInfo.switchIndex)
		local optionStr = string.format(OPTION_NAME, entityInfo.switchIndex, index == entityInfo.rightChoiceId and entityInfo.correctIndex or entityInfo.wrongIndex)

		pg.game.audio:setSwitch(switchStr, optionStr)

		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("jsx - pg.game.audio:setSwitch", switchStr, optionStr)
		end
	end

	if index == entityInfo.rightChoiceId then
		if entityInfo.subItem then
			entityInfo.subItem:SetPlaying(true, 0, true)
		end
	else
		entityInfo.subItem:SetPlaying(false)
	end
end

function GroupSingPuzzle:entStopSing(entityInfo, fromCutScene)
	local npcEnt = entityInfo.ent

	if not fromCutScene then
		npcEnt.eventEmitter:emit(EventConst.TOPLOGO_DIALOGUE, false, nil)
	end

	npcEnt:stopAllAnimation()

	local defaultAnim = PlayableConst.Idle

	npcEnt:playAnimation(defaultAnim, nil, TIMELINE_TAG)

	if entityInfo.subItem then
		entityInfo.subItem:SetPlaying(false)
	end

	if entityInfo.switchIndex and entityInfo.correctIndex and entityInfo.wrongIndex then
		local switchStr = string.format(SWITCH_NAME, entityInfo.switchIndex)
		local optionStr = string.format(OPTION_MUTE, entityInfo.switchIndex)

		pg.game.audio:setSwitch(switchStr, optionStr)
	end
end

function GroupSingPuzzle:createSubEntities()
	if IsNil(self.groupSingSB) then
		return
	end

	local virtualEntsConfig = self.groupSingSB.virtualEntsConfig
	local cutsceneRoot = self.groupSingSB.cutsceneRoot

	if virtualEntsConfig then
		for i = 0, virtualEntsConfig.Length - 1 do
			local virtualNpcInfo = virtualEntsConfig[i]
			local extraInfo = {}

			extraInfo.templateId = virtualNpcInfo.templateId

			if extraInfo.templateId ~= 0 then
				local rootTrans = virtualNpcInfo.rootTrans

				if rootTrans then
					extraInfo.rootTrans = rootTrans
					extraInfo.singNpcIndex = i

					local ent = self:createVirtualEntity("SingNpc" .. i, extraInfo)

					cutsceneRoot:SetExternalRefEntity("npc" .. i, ent.eModel)

					function ent.checkCanInteractFunc(npcEnt, interactUnit)
						return self:checkNpcCanInteract(npcEnt, interactUnit)
					end

					function ent.npcInteractFunc(interactEnt, funcMenuId, index)
						return self:npcInteractFunc(interactEnt, funcMenuId, index)
					end

					self.puzzleEntityInfo[i] = {
						ent = ent,
						subItem = virtualNpcInfo.subItem,
						animLen = virtualNpcInfo.animLen or 2,
						rightChoiceId = virtualNpcInfo.rightChoiceId,
						choicePlayableName = virtualNpcInfo.choicePlayableName,
						switchIndex = virtualNpcInfo.switchIndex,
						wrongIndex = virtualNpcInfo.wrongIndex,
						correctIndex = virtualNpcInfo.correctIndex
					}
				end
			end
		end
	end

	local otherEntsConfig = self.groupSingSB.otherEntsConfig

	if otherEntsConfig then
		for i = 0, otherEntsConfig.Length - 1 do
			local virtualNpcInfo = otherEntsConfig[i]
			local extraInfo = {}

			extraInfo.templateId = virtualNpcInfo.templateId

			local rootTrans = virtualNpcInfo.rootTrans

			if rootTrans then
				extraInfo.rootTrans = rootTrans
				extraInfo.defaultAnim = PlayableConst.Behav_HappyLoop

				local ent = self:createVirtualEntity("OtherNpc" .. i, extraInfo)

				cutsceneRoot:SetExternalRefEntity("other" .. i, ent.eModel)

				self.otherEntityInfo[i] = {
					ent = ent,
					subItem = virtualNpcInfo.subItem
				}

				virtualNpcInfo.subItem:SetPlaying(true)
			end
		end
	end

	local baseNpcConfig = self.groupSingSB.baseNpcConfig

	if baseNpcConfig then
		local extraInfo = {}

		extraInfo.templateId = baseNpcConfig.templateId

		local rootTrans = baseNpcConfig.rootTrans

		if rootTrans then
			extraInfo.rootTrans = rootTrans
			self.baseEntity = self:createVirtualEntity("BaseNpc", extraInfo)

			cutsceneRoot:SetExternalRefEntity("baseNpc", self.baseEntity.eModel)

			self.baseEntity.relatedGroupSingLevelItem = self

			function self.baseEntity.onStartDialogue(ent)
				self.baseEntity:stopAnimation(PlayableConst.Emotion_Applaud_Loop)
			end

			function self.baseEntity.onFinishDialogue(ent)
				if self.puzzleState == SandboxConst.GroupPuzzleState.Finish then
					self.baseEntity:playAnimation(PlayableConst.Emotion_Applaud_Loop)
				end

				pg.global.ui.dialogue.forbidRecoverAudioState = true
			end
		end
	end

	local watchNpcConfig = self.groupSingSB.watchEntsConfig

	if watchNpcConfig then
		for i = 0, watchNpcConfig.Length - 1 do
			local extraInfo = {}
			local config = watchNpcConfig[i]

			extraInfo.templateId = config.templateId

			local rootTrans = config.rootTrans

			if rootTrans then
				extraInfo.rootTrans = rootTrans

				local watchEntity = self:createVirtualEntity("WatchNpc" .. i, extraInfo)

				cutsceneRoot:SetExternalRefEntity("watchNpc" .. i, watchEntity.eModel)

				self.watchEntityInfo[i] = {
					ent = watchEntity
				}
			end
		end
	end
end

function GroupSingPuzzle:resetPuzzle()
	for singIndex, entityInfo in pairs(self.puzzleEntityInfo) do
		entityInfo.choice = nil

		self:entStopSing(entityInfo)
	end

	self:setOtherEntityAudio(false)

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("jsx - pg.game.audio:stopEvent(BGM_NAME)", BGM_NAME, debug.traceback())
	end

	pg.game.audio:trySetState(AudioConst.STATE_GROUP_BGM_VOLUME, AudioConst.ATTENUATION_STATE_ID_NORMAL, self:getClassType())
	pg.game.audio:stopEvent(BGM_NAME)
	self:setPuzzleState(SandboxConst.GroupPuzzleState.Disable)
end

function GroupSingPuzzle:resetAndStartPuzzle()
	for singIndex, entityInfo in pairs(self.puzzleEntityInfo) do
		entityInfo.choice = nil

		self:entStopSing(entityInfo)
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("jsx - pg.game.audio:stopEvent(BGM_NAME)", BGM_NAME, debug.traceback())
	end

	pg.game.audio:stopEvent(BGM_NAME)
	self:setPuzzleState(SandboxConst.GroupPuzzleState.Playing)

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("jsx - pg.game.audio:playEvent(BGM_NAME)", BGM_NAME, debug.traceback())
	end

	pg.game.audio:trySetState(AudioConst.STATE_GROUP_BGM_VOLUME, AudioConst.ATTENUATION_STATE_ID_ATTENUATION_ARK, self:getClassType())
	pg.game.audio:playEvent(BGM_NAME)
	self:setOtherEntityAudio(true)
end

function GroupSingPuzzle:playSuccessCutscene()
	for singIndex, entityInfo in pairs(self.puzzleEntityInfo) do
		self:entStopSing(entityInfo, true)
	end

	self:setOtherEntityAudio(false)
	pg.game.audio:stopEvent(BGM_NAME)

	if self.groupSingSB then
		self.groupSingSB:PlaySuccessCutscene()
	end

	if self.baseEntity then
		self.baseEntity:setPositionAgentLocalRotation(0, 0, 0, 1)
	end

	pg.global.ui.topLogo:setTopLogoVisible(UIConst.TOPLOGO_VISIBLE_KEY.GROUP_SING, false)
	self:setPuzzleState(SandboxConst.GroupPuzzleState.PlayingCutscene)
	pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.GROUP_SING, {}, 10)
	pg.game.input:setBlockNoneUIEvent(ClientConst.BlockNoneUIEventKey.GroupSingPuzzle, true)
end

function GroupSingPuzzle:triggerFinishEvent()
	pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.GROUP_SING)
	pg.game.input:setBlockNoneUIEvent(ClientConst.BlockNoneUIEventKey.GroupSingPuzzle, false)
	pg.global.ui.topLogo:setTopLogoVisible(UIConst.TOPLOGO_VISIBLE_KEY.GROUP_SING, true)

	local finishEventId = self.groupSingSB.finishEventId
	local finishEventInfo = {}

	finishEventInfo.globalId = self.baseEntity:getGlobalId()
	finishEventInfo.isClient = true

	self:setPuzzleState(SandboxConst.GroupPuzzleState.Finish)
	self:onPuzzleFinish()

	if finishEventId ~= 0 then
		pg.me:doEvent(finishEventId, finishEventInfo)
	end

	for _, info in pairs(self.watchEntityInfo) do
		local entity = info.ent
		local defaultAnim = PlayableConst.Emotion_Applaud_Loop

		entity:playAnimation(defaultAnim, nil, TIMELINE_TAG)
	end

	pg.game.audio:playEvent(BGM_NAME)
	self:setOtherEntityAudio(true)

	for singIndex, entityInfo in pairs(self.puzzleEntityInfo) do
		self:entDoSing(entityInfo, nil, entityInfo.rightChoiceId)
	end
end

function GroupSingPuzzle:refreshPuzzleState()
	if self:checkPuzzleSuccess() then
		self:onPuzzleSuccess()

		return
	end

	if self:checkPuzzleFailed() then
		self:onPuzzleFailed()

		return
	end
end

function GroupSingPuzzle:checkPuzzleSuccess()
	for singIndex, entityInfo in pairs(self.puzzleEntityInfo) do
		if entityInfo.choice ~= entityInfo.rightChoiceId then
			return false
		end
	end

	pg.global.showBubbleMessage(NoticeDef.ARK_GROUP_SING_SUCCESS)

	return true
end

function GroupSingPuzzle:checkPuzzleFailed()
	local isFailed = false

	for singIndex, entityInfo in pairs(self.puzzleEntityInfo) do
		if entityInfo.choice == nil then
			return false
		end

		if entityInfo.choice ~= entityInfo.rightChoiceId then
			isFailed = true
		end
	end

	if isFailed then
		pg.global.showBubbleMessage(NoticeDef.ARK_GROUP_SING_FAILED)
	end

	return isFailed
end

function GroupSingPuzzle:onPuzzleSuccess()
	self:setPuzzleState(SandboxConst.GroupPuzzleState.Success)
end

function GroupSingPuzzle:onPuzzleFailed()
	self:setPuzzleState(SandboxConst.GroupPuzzleState.Failed)
end

function GroupSingPuzzle:setPuzzleState(state)
	if self.puzzleState ~= state then
		self.puzzleState = state

		if self.puzzleState == SandboxConst.GroupPuzzleState.Playing then
			self._hasShowBubbleTips = false
		end

		if self.clientCustomVariableId ~= 0 then
			pg.me:setClientCustomVariable(self.clientCustomVariableId, state)
			facade:sendMsgToUI(MessageName.UPDATE_INTERACT_VIEW, {})
		end
	end
end

function GroupSingPuzzle:checkAndSetClientState()
	if self.clientCustomVariableId ~= 0 then
		local varData = ClientUtils.getCustomVariableValue(self.clientCustomVariableId)

		if varData == SandboxConst.GroupPuzzleState.Finish then
			self:setPuzzleState(SandboxConst.GroupPuzzleState.Finish)

			return
		end
	end

	self:setPuzzleState(SandboxConst.GroupPuzzleState.Disable)
end

function GroupSingPuzzle:refreshNpcState()
	if self.puzzleState == SandboxConst.GroupPuzzleState.Finish then
		if self.baseEntity then
			self.baseEntity:playAnimation(PlayableConst.Emotion_Applaud_Loop)
		end

		for singIndex, entityInfo in pairs(self.puzzleEntityInfo) do
			local npcEnt = entityInfo.ent

			npcEnt:playAnimation(entityInfo.choicePlayableName, nil, TIMELINE_TAG, true)

			if entityInfo.subItem then
				entityInfo.subItem:SetPlaying(true, 0, true)
			end
		end

		for _, entityInfo in pairs(self.otherEntityInfo) do
			if entityInfo.subItem then
				entityInfo.subItem:SetPlaying(true, 0, true)
			end
		end
	else
		if self.baseEntity then
			self.baseEntity:stopAnimation(PlayableConst.Emotion_Applaud_Loop)
			self.baseEntity:playAnimation(PlayableConst.Idle)
		end

		for singIndex, entityInfo in pairs(self.puzzleEntityInfo) do
			local npcEnt = entityInfo.ent

			npcEnt:stopAnimation(entityInfo.choicePlayableName)
		end
	end
end

function GroupSingPuzzle:onPuzzleFinish()
	self:refreshNpcState()
	self:serverMsg("RPC_CS_PuzzleFinish")
end

function GroupSingPuzzle:callServerResetPuzzle()
	self:resetPuzzle()
	self:refreshNpcState()
	self:serverMsg("RPC_CS_ResetFinishState")
end

function GroupSingPuzzle:onPuzzleAreaTrigger(isEnter)
	self:setOtherEntityAudio(isEnter)

	if self.puzzleState == SandboxConst.GroupPuzzleState.Playing then
		if isEnter then
			pg.game.audio:trySetState(AudioConst.STATE_GROUP_BGM_VOLUME, AudioConst.ATTENUATION_STATE_ID_ATTENUATION_ARK, self:getClassType())
		else
			pg.game.audio:trySetState(AudioConst.STATE_GROUP_BGM_VOLUME, AudioConst.ATTENUATION_STATE_ID_NORMAL, self:getClassType())
		end
	elseif self.puzzleState == SandboxConst.GroupPuzzleState.Finish and not isEnter then
		pg.game.audio:stopEvent(BGM_NAME)
		pg.game.audio:trySetState(AudioConst.STATE_GROUP_BGM_VOLUME, AudioConst.ATTENUATION_STATE_ID_NORMAL, self:getClassType())
	end
end

function GroupSingPuzzle:setOtherEntityAudio(active)
	local groupName = "Character4_Options"
	local switchName = active and "Character4_Options_01" or "Character4_Options_Mute"

	pg.game.audio:setSwitch(groupName, switchName)
end

return GroupSingPuzzle
