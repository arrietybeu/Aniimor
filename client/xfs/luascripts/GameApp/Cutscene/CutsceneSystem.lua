-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Cutscene\\CutsceneSystem.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local MessageName = require("Const.MessageName")
local SystemBase = require("GameApp.Core.SystemBase")
local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local CutsceneCmd = require("GameApp.Cutscene.CutsceneCmd")
local bitset = require("Common.Bitset")
local CameraConst = require("GameApp.Camera.CameraConst")
local UIConst = require("Const.UIConst")
local TimerManager = require("Core.Timer.TimerManager")
local Utils = require("Common.Utils.Utils")
local ClientUtils = require("Utils.ClientUtils")
local TimelineConfigType = ClientConst.TimelineConfigType
local logger = LoggerManager.getLogger("CutsceneSystem")
local AudioConst = require("Const.AudioConst")
local ConflictTypes = require("Common.ConflictTypes")
local Queue = require("Core.Framework.Queue")
local SafeCallback = require("Core.Framework.SafeCallback")
local CutsceneSystem = Class.LightClass("CutsceneSystem", SystemBase)
local Sequence_State = {
	Playing = 2,
	Waiting = 1
}
local entityManager = appFacade.entityManager

function CutsceneSystem:onCtor()
	self.cutscenes = {}
	self.currId = 0
	self.preloadCutSceneMap = {}
	self.cutsceneStateInfo = {}
	self.cutsceneSettingActiveSets = {}
	self.cutsceneSettingFuncs = {}
	self.cutSceneSequence = Queue.new(50)
end

function CutsceneSystem:onInit()
	self:initTimelineConfigs()
end

function CutsceneSystem:initTimelineConfigs()
	for _, key in pairs(TimelineConfigType) do
		self.cutsceneSettingActiveSets[key] = {}
	end

	local function isActive(key)
		local activeSet = self.cutsceneSettingActiveSets[key]

		return activeSet and next(activeSet) ~= nil
	end

	self.cutsceneSettingFuncs[TimelineConfigType.HideUI] = function()
		SafeCallback(self.hideUI, self, isActive(TimelineConfigType.HideUI))
	end
	self.cutsceneSettingFuncs[TimelineConfigType.HideAllPlayer] = function()
		SafeCallback(self.hideAllPlayer, self, isActive(TimelineConfigType.HideAllPlayer), isActive(TimelineConfigType.HideAllPlayer_IncludeMainPlayer))
	end
	self.cutsceneSettingFuncs[TimelineConfigType.HideNPC] = function()
		SafeCallback(self.hideNPC, self, isActive(TimelineConfigType.HideNPC))
	end
	self.cutsceneSettingFuncs[TimelineConfigType.ApplyStateConflict] = function()
		SafeCallback(self.onCutsceneStateConflict, self, isActive(TimelineConfigType.ApplyStateConflict))
	end
	self.cutsceneSettingFuncs[TimelineConfigType.DisableBgm] = function()
		SafeCallback(self.onCutsceneDisableBgm, self, isActive(TimelineConfigType.DisableBgm))
	end
	self.cutsceneSettingFuncs[TimelineConfigType.DisableAmb] = function()
		SafeCallback(self.onCutsceneDisableAmb, self, isActive(TimelineConfigType.DisableAmb))
	end
	self.cutsceneSettingFuncs[TimelineConfigType.DisableAuxEnvBus] = function()
		SafeCallback(self.disableAuxEnvBus, self, isActive(TimelineConfigType.DisableAuxEnvBus))
	end
	self.cutsceneSettingFuncs[TimelineConfigType.DisableWorldAudio] = function()
		SafeCallback(self.setAttenGroupState, self, isActive(TimelineConfigType.DisableWorldAudio))
	end
end

function CutsceneSystem:onClear()
	for _, cutscene in pairs(self.cutscenes) do
		cutscene:destroy()
	end

	self.cutscenes = {}
	self.currId = 0
end

function CutsceneSystem:onPlayerLeaveScene()
	local toDestroy = {}

	for key, cutscene in pairs(self.cutscenes) do
		if cutscene and cutscene:canBeInterrupted() then
			table.insert(toDestroy, key)
		end
	end

	for _, key in ipairs(toDestroy) do
		local cutscene = self.cutscenes[key]

		if cutscene then
			cutscene:destroy()

			self.cutscenes[key] = nil
		end
	end
end

function CutsceneSystem:onDestroy()
	for _, cutscene in pairs(self.cutscenes) do
		cutscene:destroy()
	end

	self.cutscenes = {}
end

function CutsceneSystem:createCutscene(name, resId, position, rotation, extraData)
	if string.isNilOrEmpty(name) then
		return
	end

	self.currId = self.currId + 1

	local cutscene = CutsceneCmd(self.currId, name, resId, position, rotation, extraData)

	self.cutscenes[self.currId] = cutscene

	return cutscene
end

function CutsceneSystem:getCurCutScene()
	return self.cutscenes[self.currId]
end

function CutsceneSystem:sequenceCutScenePlaying()
	for _, cutscene in pairs(self.cutscenes) do
		if cutscene and cutscene.sequenceState == Sequence_State.Playing then
			return true
		end
	end

	return false
end

function CutsceneSystem:destroyCutscene(cutscene)
	local id = cutscene.id

	if self.cutscenes[id] == cutscene then
		self.cutscenes[id] = nil
	end

	self.preloadCutSceneMap[cutscene.name] = nil

	if not self.cutSceneSequence:isEmpty() and not self:sequenceCutScenePlaying() then
		local cs = self.cutSceneSequence:deQueue()

		self:innerPlayCutscene(cs)
	end

	self:updateCutsceneSetting(cutscene, false)
end

function CutsceneSystem:preloadCutscene(name, resId, position, rotation, extraData)
	if self.preloadCutSceneMap[name] then
		return self.preloadCutSceneMap[name]
	end

	extraData = extraData or {}

	local keepPrefabTrans = extraData.keepPrefabTrans or false
	local cutscene = self:createCutscene(name, resId, position, rotation, extraData)

	if cutscene ~= nil then
		function extraData.endCallback()
			if not extraData.dontDestroy then
				cutscene:destroy()
			end
		end

		cutscene.isPreloading = true

		cutscene:preloadAsync(function()
			cutscene.isPreloading = false

			if cutscene.preloadFinishCb then
				cutscene.preloadFinishCb()
			end
		end)
	end

	self.preloadCutSceneMap[name] = cutscene

	return cutscene
end

function CutsceneSystem:getPreloadCutscene(name)
	if string.isNilOrEmpty(name) then
		return
	end

	return self.preloadCutSceneMap[name]
end

function CutsceneSystem:unPreloadCutScene(name)
	local cutScene = self.preloadCutSceneMap[name]

	if cutScene then
		cutScene:destroy()

		self.preloadCutSceneMap[name] = nil
	end
end

function CutsceneSystem:playPreloadCutscene(name, duration, stopCallback, playCallback)
	local cutscene = self.preloadCutSceneMap[name]

	if not cutscene then
		return false, -1
	end

	if cutscene:isPlaying() then
		return true, cutscene.id
	end

	if duration and duration > 0 then
		cutscene:setStopTime(duration, function()
			cutscene:stop()

			if stopCallback then
				stopCallback(cutscene)
			end
		end)
	end

	if cutscene.isPreloading then
		function cutscene.preloadFinishCb()
			self:onAfterPreloadUpdateCutsceneSetting(cutscene)
			cutscene:play()

			if playCallback then
				playCallback(cutscene)
			end

			if duration and duration > 0 then
				cutscene:setStopTime(duration, function()
					cutscene:stop()

					if stopCallback then
						stopCallback(cutscene)
					end
				end)
			end
		end
	else
		self:onAfterPreloadUpdateCutsceneSetting(cutscene)
		cutscene:play()

		if playCallback then
			playCallback(cutscene)
		end

		if duration and duration > 0 then
			cutscene:setStopTime(duration, function()
				cutscene:stop()

				if stopCallback then
					stopCallback(cutscene)
				end
			end)
		end
	end

	return true, cutscene.id
end

function CutsceneSystem:playCutscene(name, resId, position, rotation, fixDuration, isAsync, extraData, stopCallback, playCallback)
	extraData = extraData or {}

	local cutscene = self:createCutscene(name, resId, position, rotation, extraData)

	if cutscene == nil then
		return
	end

	local keepPrefabTrans = extraData.keepPrefabTrans or false
	local endCallback = extraData.endCallback
	local createCallback = extraData.createCallback

	function extraData.endCallback()
		if endCallback then
			endCallback()
		end

		if not extraData.dontDestroy then
			cutscene:destroy()
		end
	end

	cutscene:setKeepTrans(keepPrefabTrans)

	cutscene.isAsync = isAsync
	cutscene.createCallback = createCallback
	cutscene.stopCallback = stopCallback
	cutscene.fixDuration = fixDuration

	if extraData.playSequence then
		cutscene.sequenceState = Sequence_State.Waiting

		if self:sequenceCutScenePlaying() then
			self.cutSceneSequence:enQueue(cutscene)
		else
			self:innerPlayCutscene(cutscene, playCallback)
		end
	else
		self:innerPlayCutscene(cutscene, playCallback)
	end

	return cutscene
end

function CutsceneSystem:innerPlayCutscene(cutscene, playCallback)
	if cutscene.sequenceState == Sequence_State.Waiting then
		cutscene.sequenceState = Sequence_State.Playing
	end

	if cutscene.isAsync then
		cutscene:preloadAsync(function()
			self:onAfterPreloadUpdateCutsceneSetting(cutscene)

			if cutscene.createCallback then
				cutscene.createCallback(cutscene)
			end

			cutscene:play()

			if playCallback then
				playCallback(cutscene)
			end
		end)
	else
		cutscene:preload()
		self:onAfterPreloadUpdateCutsceneSetting(cutscene)

		if cutscene.createCallback then
			cutscene.createCallback(cutscene)
		end

		cutscene:play()

		if playCallback then
			playCallback(cutscene)
		end

		local fixDuration = cutscene.fixDuration

		if fixDuration and fixDuration > 0 then
			cutscene:setStopTime(fixDuration, function()
				cutscene:destroy()

				if cutscene.stopCallback then
					cutscene.stopCallback(cutscene)
				end
			end)
		end
	end
end

function CutsceneSystem:stopCutscene(currId)
	local cutscene = self.cutscenes[currId]

	if cutscene == nil then
		return
	end

	if cutscene.isPreloading then
		function cutscene.preloadFinishCb()
			cutscene:onInvalid()
			self:destroyCutscene(cutscene)
		end
	else
		cutscene:stop()
	end
end

function CutsceneSystem:onTimelinePlay(cutscene)
	self:onTimelinePlayUpdateCutsceneSetting(cutscene)
end

function CutsceneSystem:onTimelineEnd(cutscene)
	self:onTimelineEndUpdateCutsceneSetting(cutscene)
end

function CutsceneSystem:refreshVisibleInfo()
	local hideAllUI = false

	if hideAllUI then
		pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.CUTSCENE, {})
	else
		pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.CUTSCENE)
	end
end

function CutsceneSystem:playSkillTimelineAnim(cutsceneId, targetEnt)
	if targetEnt == nil or not targetEnt.eModel then
		return
	end

	local _tpx, _tpy, _tpz = targetEnt.eModel:GetPositionAgentPosEx()
	local cutsceneItem = self:createCutscene("superSkill", cutsceneId, Vector3.New(_tpx, _tpy, _tpz), nil)

	cutsceneItem:setBindSlot("target", targetEnt)
	cutsceneItem:preload()
	cutsceneItem:play(function()
		cutsceneItem:destroy()
	end)
end

function CutsceneSystem:isInCutsceneState()
	if not Utils.tableIsEmptyOrNil(self.cutsceneStateInfo) then
		return true
	end

	if next(self.cutsceneSettingActiveSets[TimelineConfigType.ApplyStateConflict]) ~= nil then
		return true
	end

	return false
end

function CutsceneSystem:setInCutsceneState(reasonKey, inState)
	reasonKey = reasonKey or "Default"

	if inState then
		local isOk, result = xpcall(function()
			if pg.pawn then
				pg.pawn:checkStatus(ConflictTypes.CT_ENTER_CUTSCENE, false)
			end
		end, debug.traceback)

		if not isOk and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("setInCutsceneState checkStatus failed ", result)
		end

		self.cutsceneStateInfo[reasonKey] = inState
	else
		self.cutsceneStateInfo[reasonKey] = nil
	end
end

function CutsceneSystem:onTimelinePlayUpdateCutsceneSetting(cutscene)
	self:updateCutsceneSetting(cutscene, true)
end

function CutsceneSystem:onTimelineEndUpdateCutsceneSetting(cutscene)
	self:updateCutsceneSetting(cutscene, false)
end

function CutsceneSystem:onAfterPreloadUpdateCutsceneSetting(cutscene)
	local config = cutscene:getConfig()

	if config == nil then
		return
	end

	if config.checkGroupTrackCondition then
		cutscene:checkGroupTrackCondition()
	end
end

function CutsceneSystem:updateCutsceneSetting(cutscene, isAdd)
	local config = cutscene:getConfig()

	if config == nil then
		return
	end

	local refreshSet = {}

	local function markRefresh(key)
		if key ~= nil then
			refreshSet[key] = true
		end
	end

	if config.hideAllUI then
		markRefresh(self:cutsceneSettingSetChange(TimelineConfigType.HideUI, cutscene.id, isAdd))
	end

	if config.hideAllPlayer then
		local changed = self:cutsceneSettingSetChange(TimelineConfigType.HideAllPlayer, cutscene.id, isAdd)

		if config.includeMainPlayer then
			local changed2 = self:cutsceneSettingSetChange(TimelineConfigType.HideAllPlayer_IncludeMainPlayer, cutscene.id, isAdd)

			if changed2 ~= nil then
				changed = TimelineConfigType.HideAllPlayer
			end
		end

		markRefresh(changed)
	end

	if config.hideNPC then
		markRefresh(self:cutsceneSettingSetChange(TimelineConfigType.HideNPC, cutscene.id, isAdd))
	end

	if config.applyStateConflict then
		markRefresh(self:cutsceneSettingSetChange(TimelineConfigType.ApplyStateConflict, cutscene.id, isAdd))
	end

	if config.disableBgm then
		markRefresh(self:cutsceneSettingSetChange(TimelineConfigType.DisableBgm, cutscene.id, isAdd))
	end

	if config.disableAmb then
		markRefresh(self:cutsceneSettingSetChange(TimelineConfigType.DisableAmb, cutscene.id, isAdd))
	end

	if config.disableAuxEnvBus then
		markRefresh(self:cutsceneSettingSetChange(TimelineConfigType.DisableAuxEnvBus, cutscene.id, isAdd))
	end

	if config.disableWorldAudio then
		markRefresh(self:cutsceneSettingSetChange(TimelineConfigType.DisableWorldAudio, cutscene.id, isAdd))
	end

	self:applyCutsceneSetting(refreshSet)
end

function CutsceneSystem:cutsceneSettingSetChange(key, cutsceneId, isAdd)
	local set = self.cutsceneSettingActiveSets[key]

	if set == nil then
		return nil
	end

	local wasActive = next(set) ~= nil

	if isAdd then
		set[cutsceneId] = true
	else
		set[cutsceneId] = nil
	end

	local isActive = next(set) ~= nil

	if wasActive ~= isActive then
		return key
	end

	return nil
end

function CutsceneSystem:applyCutsceneSetting(refreshSet)
	self:cleanupStaleSettingEntries()

	for key, _ in pairs(refreshSet) do
		if self.cutsceneSettingFuncs[key] then
			self.cutsceneSettingFuncs[key]()
		end
	end
end

function CutsceneSystem:cleanupStaleSettingEntries()
	for key, set in pairs(self.cutsceneSettingActiveSets) do
		for cutsceneId, _ in pairs(set) do
			local cutscene = self.cutscenes[cutsceneId]

			if cutscene == nil or not cutscene:isPlaying() then
				if LoggerManager.checkLogger(LoggerConst.WARN) then
					logger:error("cleanupStaleSettingEntries: remove stale cutscene id=", cutsceneId, " key=", key)
				end

				set[cutsceneId] = nil
			end
		end
	end
end

function CutsceneSystem:hideUI(hideFlag)
	if hideFlag then
		pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.CUTSCENE, {
			[UIConst.UI_ID_SKIP_PANEL] = true,
			[UIConst.UI_ID_NET_LOADING] = true,
			[UIConst.UI_ID_LIVE_STREAMING] = true,
			[UIConst.UI_ID_SUBTITLES_PANEL] = true,
			[UIConst.UI_ID_COMMON_CONFIRM] = true,
			[UIConst.UI_ID_DIALOGUE_SKIP] = true,
			[UIConst.UI_ID_GAMEPLAY_PROGRESS] = true,
			[UIConst.UI_ID_NET_LOADING] = true,
			[UIConst.UI_ID_DIALOGUE_ID] = true,
			[UIConst.UI_ID_CONFIG_TOPPING] = true
		})
	else
		pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.CUTSCENE)
	end
end

function CutsceneSystem:hideAllPlayer(hideFlag, includeMainPlayerFlag)
	local visible = not hideFlag
	local includeMainPlayer = visible or includeMainPlayerFlag

	ClientUtils.SetAllPlayerVisible(ClientConst.MODEL_VISIBLE_KEY.CUTSCENE, visible, includeMainPlayer)
end

function CutsceneSystem:hideNPC(hideFlag)
	local visible = not hideFlag

	ClientUtils.SetAllPuppetVisible(ClientConst.MODEL_VISIBLE_KEY.CUTSCENE, visible)
end

function CutsceneSystem:onCutsceneStateConflict(enterConflict)
	if self.isEnterCutsceneStateConflict ~= enterConflict then
		self.isEnterCutsceneStateConflict = enterConflict

		if enterConflict then
			pg.pawn:checkStatus(ConflictTypes.CT_ENTER_CUTSCENE, false)
		end
	end
end

function CutsceneSystem:onCutsceneDisableBgm(isDisable)
	if isDisable then
		pg.game.audio:playBgm("", AudioConst.BgmPriority.Cutscene)
	else
		pg.game.audio:playBgm(nil, AudioConst.BgmPriority.Cutscene)
	end
end

function CutsceneSystem:onCutsceneDisableAmb(isDisable)
	if isDisable then
		pg.game.audio:playAmb("", AudioConst.BgmPriority.Cutscene)
	else
		pg.game.audio:playAmb(nil, AudioConst.BgmPriority.Cutscene)
	end
end

function CutsceneSystem:disableAuxEnvBus(isDisable)
	pg.game.audio:disableAuxEnvBus(AudioConst.DisableAuxEnvReason.Default, isDisable)
end

function CutsceneSystem:setAttenGroupState(isDisable)
	pg.game.audio:setAttenGroupState(AudioConst.AttenGroupStateReason.Cutscene, isDisable)
end

function CutsceneSystem:setOtherPlayer(key, id)
	if id then
		entityManager:RegisterOtherPlayerKey(key, id)
	else
		entityManager:UnregisterOtherPlayerKey(key)
	end
end

return CutsceneSystem
