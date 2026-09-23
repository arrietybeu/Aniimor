-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Nourish\\Component\\CultivateTipsComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local LeylineFlowerUtils = require("Common.Utils.LeylineFlowerUtils")
local LeylineFlowerConst = require("Const.LeylineFlowerConst")
local AreaRainbowPetLevelData = require("Data.area_rainbowPet_level_data")
local SysConfigData = require("Data.sys_config_data")
local PuppetData = require("Data.puppet_data")
local PetData = require("Data.pet_data")
local ClientConst = require("Const.ClientConst")
local CultivateTipsComponent = Class.LightClass("CultivateTipsComponent", UIComponent)
local MAX_RAINBOW_STAGE = #AreaRainbowPetLevelData
local MIN_RAINBOW_STAGE = 1
local DEFAULT_NORMAL_STAGE_DURATION = 0.8
local DEFAULT_RUSH_STAGE_DURATIONS = {
	0.8,
	0.7,
	0.6,
	0.5,
	0.4,
	0.3
}
local DEFAULT_MIN_PROGRESS_DURATION = 0.05
local STAGE_UP_EVENT = CS.XGUI.EInvokeTime.Custom1

function CultivateTipsComponent:getView()
	local transform = self.transform
	local objectReference = transform:GetComponent("ObjectReference")

	return {
		objectReference = objectReference,
		stageUpUComponent = transform.parent and transform.parent:GetComponent("UWidget") or nil,
		rootUComponent = transform:GetComponent("UComponent"),
		txtTipsUSDFText = objectReference:GetRefValue("txtTipsUSDFText"),
		txtQualityUSDFText = objectReference:GetRefValue("txtQualityUSDFText"),
		countDownUCountDown = objectReference:GetRefValue("countDownUCountDown"),
		btnInfo2UButton = objectReference:GetRefValue("btnInfo2UButton"),
		progressProbabilityUComponent = objectReference:GetRefValue("progressProbabilityUComponent"),
		progressGlowUComponent = objectReference:GetRefValue("progressGlowUComponent"),
		txtProbabilityUSDFText = objectReference:GetRefValue("txtProbabilityUSDFText")
	}
end

function CultivateTipsComponent:bindInfoTooltip()
	function self.btnInfo2UButton.luaRenderTooltip(_, tipItem)
		local objectReference = tipItem:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("RAINBOW_ENERGY_STAGE_TIPS"))
	end
end

function CultivateTipsComponent:addToCtrl()
	if self.extInfo and self.extInfo.manualDestroy then
		return
	end

	UIComponent.addToCtrl(self)
end

function CultivateTipsComponent:onDestroy()
	self.destroyed = true
end

function CultivateTipsComponent:findObjects()
	local view = self:getView()

	for name, object in pairs(view) do
		self[name] = object
	end
end

function CultivateTipsComponent:initView()
	self:bindInfoTooltip()
end

function CultivateTipsComponent:normalizeSnapshot(rainbowSnapshot)
	local s = rainbowSnapshot or {}
	local newStage = s.newStage or MIN_RAINBOW_STAGE
	local newEnergy = s.newEnergy or 0
	local grownStage = s.grownStage or newStage
	local grownEnergy = s.grownEnergy

	if grownEnergy == nil then
		grownEnergy = newEnergy
	end

	local oldStage = s.oldStage or grownStage
	local oldEnergy = s.oldEnergy

	if oldEnergy == nil then
		oldEnergy = grownEnergy
	end

	return {
		oldStage = oldStage,
		oldEnergy = oldEnergy,
		grownStage = grownStage,
		grownEnergy = grownEnergy,
		newStage = newStage,
		newEnergy = newEnergy
	}
end

function CultivateTipsComponent:getStageProgress(blockId, stage, totalEnergy)
	stage = math.clamp(stage or 1, 1, MAX_RAINBOW_STAGE)

	if stage >= MAX_RAINBOW_STAGE then
		return 1
	end

	local energy = totalEnergy

	if energy == nil then
		local flowerId = LeylineFlowerUtils.getStaticIdByBlockId(nil, blockId)
		local flowerInfo = pg.me.getCurFlowerInfo and pg.me:getCurFlowerInfo(flowerId) or pg.me.leylineFlowerInfoMap and pg.me.leylineFlowerInfoMap[flowerId]

		energy = LeylineFlowerUtils.getTotalRainbowEnergy(flowerInfo)
	end

	local currentNeed = AreaRainbowPetLevelData[stage].rainbowEnergyNeed
	local nextNeed = AreaRainbowPetLevelData[stage + 1].rainbowEnergyNeed
	local span = nextNeed - currentNeed

	if span <= 0 then
		return 1
	end

	return math.clamp((energy - currentNeed) / span, 0, 1)
end

function CultivateTipsComponent:playStageUpFeedback(widget, duration)
	pg.game.audio:playEvent(LeylineFlowerConst.FLOWER_AUDIO_EVENT.RainbowEnergyLevelUp)

	if IsNil(widget) or not widget:CheckHasEvent(STAGE_UP_EVENT) then
		return
	end

	widget:InvokeCallback(STAGE_UP_EVENT)

	local animation = widget.transform:GetComponent("Animation")

	if IsNil(animation) then
		return
	end

	local state = animation[LeylineFlowerConst.RAINBOW_HUD_VX_CLIP.StageUpFeedback]

	if IsNil(state) then
		return
	end

	if not self.stageUpClipDuration or self.stageUpClipDuration <= 0 then
		self.stageUpClipDuration = state.length
	end

	duration = math.max(DEFAULT_MIN_PROGRESS_DURATION, tonumber(duration) or 0)

	if self.stageUpClipDuration > 0 then
		state.speed = self.stageUpClipDuration / duration
	end
end

function CultivateTipsComponent:getNormalStageDuration()
	return math.max(0, tonumber(SysConfigData.LEYLINE_FLOWER_RAINBOW_HUD_NORMAL_STAGE_DURATION) or DEFAULT_NORMAL_STAGE_DURATION)
end

function CultivateTipsComponent:getRushStageDuration(stage)
	local durations = SysConfigData.LEYLINE_FLOWER_RAINBOW_HUD_RUSH_STAGE_DURATIONS

	if durations == nil then
		durations = DEFAULT_RUSH_STAGE_DURATIONS
	end

	return math.max(0, tonumber(durations[stage]) or tonumber(durations[#durations]) or DEFAULT_RUSH_STAGE_DURATIONS[#DEFAULT_RUSH_STAGE_DURATIONS])
end

function CultivateTipsComponent:getStageDuration(stage, isRush)
	if isRush then
		return self:getRushStageDuration(stage)
	end

	return self:getNormalStageDuration()
end

function CultivateTipsComponent:getMinProgressDuration()
	return math.max(0, tonumber(SysConfigData.LEYLINE_FLOWER_RAINBOW_HUD_MIN_PROGRESS_DURATION) or DEFAULT_MIN_PROGRESS_DURATION)
end

function CultivateTipsComponent:getRushStartStage(snapshot)
	return math.clamp(snapshot.grownStage or MIN_RAINBOW_STAGE, MIN_RAINBOW_STAGE, MAX_RAINBOW_STAGE)
end

function CultivateTipsComponent:shouldPlayRush(snapshot)
	return (snapshot.oldStage or MIN_RAINBOW_STAGE) < LeylineFlowerConst.FLOWER_RAINBOW_LEVEL.LEVEL5
end

function CultivateTipsComponent:setProgressValue(targetValue)
	targetValue = math.clamp(targetValue or 0, 0, 1)
	self.progressProbabilityUComponent.value = targetValue

	if NotNil(self.progressGlowUComponent) then
		self.progressGlowUComponent.value = targetValue
	end
end

function CultivateTipsComponent:animateProgress(targetValue, fullStageDuration, onFinished, onIncreaseStarted)
	targetValue = math.clamp(targetValue or 0, 0, 1)

	local progress = self.progressProbabilityUComponent
	local currentValue = progress.value or 0
	local distance = math.abs(targetValue - currentValue)

	if distance <= 0.0001 or fullStageDuration <= 0 or not progress.gameObject.activeInHierarchy then
		self:setProgressValue(targetValue)

		if onFinished then
			onFinished()
		end

		return
	end

	if currentValue < targetValue and onIncreaseStarted then
		onIncreaseStarted()
	end

	local duration = math.max(self:getMinProgressDuration(), fullStageDuration)
	local glowProgress = self.progressGlowUComponent

	if NotNil(glowProgress) and glowProgress.gameObject.activeInHierarchy then
		glowProgress:ProgressToValue(targetValue, nil, duration, 0, CS.DG.Tweening.Ease.Linear)
	elseif NotNil(glowProgress) then
		glowProgress.value = targetValue
	end

	progress:ProgressToValue(targetValue, onFinished, duration, 0, CS.DG.Tweening.Ease.Linear)
end

function CultivateTipsComponent:getRainbowPetName(blockId)
	local staticId = LeylineFlowerUtils.getStaticIdByBlockId(nil, blockId)

	if not staticId then
		return ""
	end

	if not pg.space or not pg.space.getRainbowPetTemplateId then
		return ""
	end

	local templateId = pg.space:getRainbowPetTemplateId(staticId, nil)

	if not templateId then
		return ""
	end

	local puppetData = PuppetData[templateId]
	local petData = PetData[templateId] or puppetData and PetData[puppetData.petPrototypeId]

	return pg.getLocalizationText(puppetData and puppetData.name or petData and petData.name or "") or ""
end

function CultivateTipsComponent:refreshStaticText(blockId)
	ClientTextUtils.setText(self.txtTipsUSDFText, pg.getGameString("NOURISH_RAINBOW_ENERGY_STAGE"))
	ClientTextUtils.setText(self.txtProbabilityUSDFText, string.format(pg.getGameString("NOURISH_RAINBOW_PROBABILITY"), self:getRainbowPetName(blockId or 0)))
end

function CultivateTipsComponent:refreshStageView(blockId, stage, energy)
	local rainbowStage = stage or LeylineFlowerUtils.getRainbowStageBySmallAreaId(blockId or 0)
	local stageData = AreaRainbowPetLevelData[rainbowStage] or {}

	ClientTextUtils.setText(self.txtQualityUSDFText, pg.getLocalizationText(stageData.stageDesc or ""))
	self.rootUComponent:TryChangePage("Quality", rainbowStage)
	self.progressProbabilityUComponent:TryChangePage("Quality", rainbowStage)

	if NotNil(self.progressGlowUComponent) then
		self.progressGlowUComponent:TryChangePage("Quality", rainbowStage)
	end

	self:setProgressValue(self:getStageProgress(blockId, rainbowStage, energy))
end

function CultivateTipsComponent:prepareRainbowEnergyView(blockId, rainbowSnapshot)
	self.blockId = blockId

	self:refreshStaticText(blockId)

	local snapshot = self:normalizeSnapshot(rainbowSnapshot)

	self:refreshStageView(blockId, snapshot.oldStage, snapshot.oldEnergy)
end

function CultivateTipsComponent:startIncreaseSound(progressContext)
	if progressContext.increaseSoundPlaying then
		return
	end

	progressContext.increaseSoundPlaying = true

	pg.game.audio:playEvent(LeylineFlowerConst.FLOWER_AUDIO_EVENT.RainbowEnergyIncrease)
end

function CultivateTipsComponent:finishProgress(progressContext)
	if self.destroyed then
		return
	end

	if progressContext.increaseSoundPlaying then
		progressContext.increaseSoundPlaying = false

		self:stopRainbowEnergyIncreaseSound()
	end

	if progressContext.onFinished then
		progressContext.onFinished()
	end
end

function CultivateTipsComponent:playCurrentStage(progressContext, stage)
	if self.destroyed then
		return
	end

	local blockId = progressContext.blockId

	if stage >= progressContext.toStage then
		self:animateProgress(self:getStageProgress(blockId, progressContext.toStage, progressContext.toEnergy), self:getStageDuration(stage, progressContext.fillMaxStage), progressContext.onProgressFinished, progressContext.onIncreaseStarted)

		return
	end

	self:animateProgress(1, self:getStageDuration(stage, progressContext.fillMaxStage), function()
		if self.destroyed then
			return
		end

		local nextStage = stage + 1

		self:refreshStageView(blockId, nextStage, AreaRainbowPetLevelData[nextStage].rainbowEnergyNeed)

		if progressContext.fillMaxStage and nextStage == MAX_RAINBOW_STAGE then
			self:setProgressValue(0)
		end

		local nextDuration = self:getStageDuration(nextStage, progressContext.fillMaxStage)

		self:playStageUpFeedback(self.stageUpUComponent or self.rootUComponent, nextDuration)

		if progressContext.fillMaxStage then
			local rumbleName = LeylineFlowerConst.RAINBOW_RUSH_RUMBLE_BY_STAGE[nextStage]

			if rumbleName then
				pg.game.input:playRumbleByName(ClientConst.RumbleLayer.DEFAULT, rumbleName)
			end
		end

		self:playCurrentStage(progressContext, nextStage)
	end, progressContext.onIncreaseStarted)
end

function CultivateTipsComponent:playStageProgress(blockId, fromStage, fromEnergy, toStage, toEnergy, onFinished, fillMaxStage)
	fromStage = math.clamp(fromStage or 1, 1, MAX_RAINBOW_STAGE)
	toStage = math.clamp(toStage or fromStage, 1, MAX_RAINBOW_STAGE)

	self:refreshStageView(blockId, fromStage, fromEnergy)

	if fillMaxStage and fromStage == MAX_RAINBOW_STAGE then
		self:setProgressValue(0)
	end

	local progressContext = {
		increaseSoundPlaying = false,
		blockId = blockId,
		toStage = toStage,
		toEnergy = toEnergy,
		onFinished = onFinished,
		fillMaxStage = fillMaxStage
	}

	function progressContext.onProgressFinished()
		self:finishProgress(progressContext)
	end

	function progressContext.onIncreaseStarted()
		self:startIncreaseSound(progressContext)
	end

	if toStage < fromStage then
		self:refreshStageView(blockId, toStage, toEnergy)
		self:finishProgress(progressContext)

		return
	end

	self:playCurrentStage(progressContext, fromStage)
end

function CultivateTipsComponent:stopRainbowEnergyIncreaseSound()
	pg.game.audio:stopEvent(LeylineFlowerConst.FLOWER_AUDIO_EVENT.RainbowEnergyIncrease)
end

function CultivateTipsComponent:refresh(blockId, rainbowSnapshot)
	self.blockId = blockId

	self:refreshStaticText(blockId)
	self:refreshStageView(blockId, rainbowSnapshot and rainbowSnapshot.newStage, rainbowSnapshot and rainbowSnapshot.newEnergy)
end

function CultivateTipsComponent:prepareRainbowEnergyFlow(blockId, rainbowSnapshot)
	self:prepareRainbowEnergyView(blockId, rainbowSnapshot)
end

function CultivateTipsComponent:refreshcountDown(time, type)
	LuaUIUtils.setCountDownTime(self.countDownUCountDown, time, type)
end

function CultivateTipsComponent:playRainbowEnergyFlow(blockId, rainbowSnapshot, isRainbowSpawn, onBeforeRush, onFinished)
	self:prepareRainbowEnergyView(blockId, rainbowSnapshot)

	local snapshot = self:normalizeSnapshot(rainbowSnapshot)
	local flowContext = {
		blockId = blockId,
		snapshot = snapshot,
		isRainbowSpawn = isRainbowSpawn,
		onBeforeRush = onBeforeRush,
		onFinished = onFinished
	}

	if snapshot.oldStage == snapshot.grownStage and snapshot.oldEnergy == snapshot.grownEnergy then
		self:playConsume(flowContext)

		return
	end

	self:playStageProgress(blockId, snapshot.oldStage, snapshot.oldEnergy, snapshot.grownStage, snapshot.grownEnergy, function()
		self:playConsume(flowContext)
	end)
end

function CultivateTipsComponent:finishRainbowEnergyFlow(flowContext)
	if flowContext.onFinished then
		flowContext.onFinished()
	end
end

function CultivateTipsComponent:playRush(flowContext)
	if self.destroyed then
		return
	end

	local snapshot = flowContext.snapshot
	local rushStartStage = self:getRushStartStage(snapshot)

	self:playStageProgress(flowContext.blockId, rushStartStage, snapshot.grownEnergy, MAX_RAINBOW_STAGE, AreaRainbowPetLevelData[MAX_RAINBOW_STAGE].rainbowEnergyNeed, function()
		self:finishRainbowEnergyFlow(flowContext)
	end, true)
end

function CultivateTipsComponent:afterEnergyChange(flowContext)
	if not flowContext.isRainbowSpawn then
		self:finishRainbowEnergyFlow(flowContext)

		return
	end

	local rush

	if self:shouldPlayRush(flowContext.snapshot) then
		function rush()
			self:playRush(flowContext)
		end
	end

	if flowContext.onBeforeRush then
		flowContext.onBeforeRush(rush, rush and self:getRainbowRushDuration(flowContext.snapshot) or 0)
	elseif rush then
		rush()
	else
		self:finishRainbowEnergyFlow(flowContext)
	end
end

function CultivateTipsComponent:playConsume(flowContext)
	local snapshot = flowContext.snapshot

	if flowContext.isRainbowSpawn or snapshot.grownStage == snapshot.newStage and snapshot.grownEnergy == snapshot.newEnergy then
		self:afterEnergyChange(flowContext)

		return
	end

	self:playStageProgress(flowContext.blockId, snapshot.grownStage, snapshot.grownEnergy, snapshot.newStage, snapshot.newEnergy, function()
		self:afterEnergyChange(flowContext)
	end)
end

function CultivateTipsComponent:getRainbowRushDuration(rainbowSnapshot)
	local snapshot = self:normalizeSnapshot(rainbowSnapshot)

	if not self:shouldPlayRush(snapshot) then
		return 0
	end

	local minDuration = self:getMinProgressDuration()
	local totalDuration = 0

	for stage = self:getRushStartStage(snapshot), MAX_RAINBOW_STAGE do
		totalDuration = totalDuration + math.max(minDuration, self:getRushStageDuration(stage))
	end

	return totalDuration
end

function CultivateTipsComponent:shouldPlayRainbowRush(rainbowSnapshot)
	return self:shouldPlayRush(self:normalizeSnapshot(rainbowSnapshot))
end

return CultivateTipsComponent
