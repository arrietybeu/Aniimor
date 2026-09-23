-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CaptureBall\\Component\\AimUIComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local bit = bit
local lshift = bit.lshift
local bor = bit.bor
local bnot = bit.bnot
local SysConfigData = require("Data.sys_config_data")
local Time = require("Core.Common.Time")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local AimUIComponent = Class.LightClass("AimUIComponent", UIComponent)
local EventConst = require("Const.EventConst")
local ClientConst = require("Const.ClientConst")
local PuppetData = require("Data.puppet_data")
local CatchDisplayData = require("Data.catch_display_data")
local CatchProbContext = require("Common.Utils.CatchProbContext")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local Utils = require("Common.Utils.Utils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local AIUtils = require("Common.Utils.AIUtils")
local catch_config_data = require("Data.catch_config_data")
local CastItemData = require("Data.cast_item_data")
local ItemEffectData = require("Data.item_effect_data")
local ItemData = require("Data.item_data")
local logger = LoggerManager.getLogger("AimUIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TimerManager = require("Core.Timer.TimerManager")
local CatchState = {
	Lock = 2,
	Select = 1,
	None = 0
}
local SuccessRate = {
	Success = 5,
	None = 0,
	Zero = 4,
	Low = 3,
	Mid = 2,
	High = 1
}
local BuffType = {
	Midbuff = 0,
	LowestBuff = 4,
	Mustbuff = 3,
	Highbuff = 2,
	Debuff = 1
}
local CatchBuffState = {
	ShinyChampion = 2,
	Champion = 1,
	Normal = 0
}
local LONG_PRESS_DELAY = 0.55

function AimUIComponent:onCtor()
	self.catchLocked = false
	self.lastState = {}
	self.currentState = {}
	self.lastProb = {}
	self.effectiveProb = {}
	self.lastBallItemId = nil
	self.aimedActorIds = {}
	self.curAimedActorId = nil
	self.curAimedTs = 0
end

function AimUIComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.catchBuffList = self.objectReference:GetRefValue("catchBuffList")
	self.rateNum = self.objectReference:GetRefValue("rateNum")
	self.rate = self.objectReference:GetRefValue("rate")
	self.catchAimSightUComponent = self.objectReference:GetRefValue("catchAimSightUComponent")
	self.rateNumAdd = self.objectReference:GetRefValue("rateNumAdd")
	self.panelRate = self.objectReference:GetRefValue("panelRate")

	self:addUListItemListener()
end

function AimUIComponent:_setPanelRateActive(active)
	if self.panelRateActive == active then
		return
	end

	self.panelRateActive = active

	if self.panelRate then
		self.panelRate:SetActive(active)
	end
end

function AimUIComponent:addUListItemListener()
	function self.catchBuffList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local buffText = objectReference:GetRefValue("buffText")
		local buffRateText = objectReference:GetRefValue("buffRateText")

		button:TryChangePage("State", data.state or CatchBuffState.Normal)
		button:TryChangePage("BuffType", data.buffType)
		ClientTextUtils.setText(buffText, data.buffText)
		ClientTextUtils.setText(buffRateText, data.buffRateText)
	end
end

function AimUIComponent:initView()
	self:initAimTimer()
end

function AimUIComponent:initAimTimer()
	pg.me.catchAimActorId = 0

	if not self.timer then
		self.timer = self.ctrl:startTimer(function()
			self:startCatchTick()
		end, 0.1, true)
	end

	self:resetAnimState(0, true)
end

function AimUIComponent:startCatchTick()
	self:clearLockEntity()

	local catchCamMode = pg.game.camera.playerCameraMode.catchCamera.cameraMode
	local curEntActorId = catchCamMode:GetFirstAimPuppet()
	local ent = pg.getEntityByActorId(curEntActorId)

	pg.me.catchAimActorId = curEntActorId
	self.isInScreen = ToBool(ent)

	if self.catchLocked and ent and Utils.isPlayerPet(ent) then
		return
	end

	if not ent or Utils.isNpc(ent) and not Utils.npcShowForbidCatchReason(ent) or not Utils.isPuppet(ent) and not Utils.isPet(ent) then
		if self.outAimOnce then
			self:resetAnimState(2, false)
			pg.game.input:stopRumble(ClientConst.RumbleLayer.CATCH_AIM)
		end

		self.catchAimSightUComponent:TryChangePage("CatchState", CatchState.None)
		self.catchAimSightUComponent:TryChangePage("SuccessRate", SuccessRate.None)

		return
	end

	local isFishingCaptureBoss = false

	if pg.me and pg.me.isInFishingCapture and pg.me:isInFishingCapture() then
		isFishingCaptureBoss = ent.isFishingCaptureBoss and ent:isFishingCaptureBoss() or false

		if not isFishingCaptureBoss then
			self.catchAimSightUComponent:TryChangePage("CatchState", CatchState.None)
			self.catchAimSightUComponent:TryChangePage("SuccessRate", SuccessRate.None)
			self:_setPanelRateActive(true)

			return
		end
	end

	self:_setPanelRateActive(not isFishingCaptureBoss)

	if ent.isTrapped then
		self.catchAimSightUComponent:TryChangePage("CatchState", CatchState.None)
		self.catchAimSightUComponent:TryChangePage("SuccessRate", SuccessRate.None)

		return
	end

	local successState, context = self:getCatchRate(ent)

	self:tryTriggerCatchPetLevelGap(ent)
	table.clearArray(self.effectiveProb)
	table.clearArray(self.currentState)

	local curProb = self:getDisplayConfigName(ent, context, self.effectiveProb, self.currentState)
	local needTriggerSfx = false

	if self.finalProb ~= curProb then
		needTriggerSfx = true
	end

	self.finalProb = curProb

	if self.isInScreen then
		self:setLockTargetInCatch(ent.id)
		self:switchCatchTopLogo(true, ent)
		LuaUIUtils.setUIViewVisible(self.rate, false)

		local pData = PuppetData[ent.templateId]

		if pData and pData.successRateText then
			ClientTextUtils.setText(self.rateNum, pData.successRateText)
			ClientTextUtils.setText(self.rateNumAdd, pData.successRateText)
			LuaUIUtils.setUIViewVisible(self.rate, false)
			self.catchAimSightUComponent:TryChangePage("SuccessRate", SuccessRate.Mid)
		else
			ClientTextUtils.setText(self.rateNum, self.finalProb)
			ClientTextUtils.setText(self.rateNumAdd, self.finalProb)
			LuaUIUtils.setUIViewVisible(self.rate, true)
			self.catchAimSightUComponent:TryChangePage("SuccessRate", successState)
		end

		if self.inAimOnce == true then
			if self.catchLocked then
				self.catchAimSightUComponent:TryChangePage("CatchState", CatchState.Lock)
			else
				self.catchAimSightUComponent:TryChangePage("CatchState", CatchState.Select)
			end

			self.inAimOnce = false
			self.outAimOnce = true

			pg.game.input:playRumbleByName(ClientConst.RumbleLayer.CATCH_AIM, "CommonTapLight", true)

			if not self._fromLock then
				needTriggerSfx = true
			end

			self._fromLock = false
		end

		if needTriggerSfx then
			local sfx = ClientCaptureUtils.getSfxByRate(tonumber(context.finalProb))

			pg.game.audio:playEvent(sfx)
		end

		local ballItemId = self.ctrl:getCurSelectPropId()

		if self.lastBallItemId ~= ballItemId or not table.equal(self.currentState, self.lastState) or not table.equal(self.effectiveProb, self.lastProb) then
			self:removeElementInUList()

			if self.addElementTimerId then
				self.ctrl:killTimer(self.addElementTimerId)

				self.addElementTimerId = nil
			end

			local startIdx = 1
			local totalCnt = #self.currentState

			if totalCnt > 0 then
				self.addElementTimerId = self.ctrl:startTimer(function()
					if startIdx > totalCnt then
						self.ctrl:killTimer(self.addElementTimerId)

						return
					end

					self:addSingleElementToUList(self.currentState[startIdx], self.effectiveProb[startIdx])

					startIdx = startIdx + 1
				end, 0.07, true)
			end

			table.clearArray(self.lastState)
			table.mergeList(self.lastState, self.currentState)
			table.clearArray(self.lastProb)
			table.mergeList(self.lastProb, self.effectiveProb)

			self.lastBallItemId = ballItemId
		end
	else
		if self.outAimOnce == true then
			self:resetAnimState(2, false)
			pg.game.input:stopRumble(ClientConst.RumbleLayer.CATCH_AIM)
		end

		self.catchAimSightUComponent:TryChangePage("CatchState", CatchState.None)
	end
end

function AimUIComponent:resetAnimState(animParameter, isEnterCatchMode)
	self:removeElementInUList()

	local catchState = CatchState.None

	if self.catchLocked then
		catchState = CatchState.Lock
	elseif animParameter == 2 then
		catchState = CatchState.Select
	end

	self.catchAimSightUComponent:TryChangePage("CatchState", catchState)
	self.catchAimSightUComponent:TryChangePage("SuccessRate", SuccessRate.None)
	table.clearArray(self.lastState)
	table.clearArray(self.currentState)
	table.clearArray(self.lastProb)
	table.clearArray(self.effectiveProb)

	self.lastBallItemId = nil
	self.outAimOnce = false
	self.inAimOnce = true
end

function AimUIComponent:catchLockPuppetMsg(isLock, isInField)
	if not pg.me or not pg.me:isInCatchMode() then
		return
	end

	self.catchLocked = isLock
	self.inAimOnce = true
	self._fromLock = true
end

function AimUIComponent:_syncLockStateFromCamera()
	if self.catchLocked then
		return
	end

	local playerCameraMode = pg.game.camera and pg.game.camera.playerCameraMode
	local catchCamera = playerCameraMode and playerCameraMode.catchCamera

	if not catchCamera then
		return
	end

	if catchCamera.target ~= nil then
		self:catchLockPuppetMsg(true, catchCamera.isInField)
	end
end

function AimUIComponent._getCatchBuffState(catchDisplayConfigKey, effectiveProb, itemId)
	if catchDisplayConfigKey ~= "ballProb" or effectiveProb <= 998 then
		return CatchBuffState.Normal
	end

	local castItemId = Utils.itemId2CastItemId(itemId)
	local castItemConfig = castItemId and CastItemData[castItemId]

	if not castItemConfig or castItemConfig.isSpecialSlot ~= 1 then
		return CatchBuffState.Normal
	end

	return castItemConfig.forceShiny == 1 and CatchBuffState.ShinyChampion or CatchBuffState.Champion
end

function AimUIComponent:addSingleElementToUList(catchDisplayConfigKey, effectiveProb)
	effectiveProb = tonumber(effectiveProb)

	if effectiveProb == 1 then
		return
	end

	local buffText, buffType
	local catchBuffState = CatchBuffState.Normal

	if catchDisplayConfigKey == "ballProb" then
		local itemId = self.ctrl:getCurSelectPropId()
		local itemData = ItemData[itemId]

		buffText = pg.getLocalizationText(itemData and itemData.itemName)
		catchBuffState = AimUIComponent._getCatchBuffState(catchDisplayConfigKey, effectiveProb, itemId)

		if effectiveProb > 998 or effectiveProb <= 0 then
			buffType = BuffType.Mustbuff
		else
			buffType = effectiveProb < 1 and BuffType.Debuff or BuffType.Midbuff
		end
	else
		local catchDisplayConfig = CatchDisplayData[catchDisplayConfigKey]

		if catchDisplayConfig then
			buffText = pg.getLocalizationText(catchDisplayConfig.catchDisplayText)

			if effectiveProb > 998 or effectiveProb <= 0 then
				buffType = BuffType.Mustbuff
			elseif catchDisplayConfig.MaxBuffTypeThreshold and effectiveProb >= catchDisplayConfig.MaxBuffTypeThreshold then
				buffType = BuffType.Highbuff
			elseif catchDisplayConfig.MinBuffTypeThreshold and effectiveProb <= catchDisplayConfig.MinBuffTypeThreshold then
				buffType = BuffType.LowestBuff
			else
				buffType = effectiveProb < 1 and BuffType.Debuff or BuffType.Midbuff
			end
		elseif LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug("jsx-AimUIComponent-addSingleElementToUList can not find CatchDisplayData!", catchDisplayConfigKey)
		end
	end

	if buffText and buffType then
		self.catchBuffList:AddElement({
			buffText = buffText,
			buffRateText = effectiveProb,
			buffType = buffType,
			state = catchBuffState
		})
	elseif LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("jsx-AimUIComponent-addSingleElementToUList can not find CatchDisplayData!", catchDisplayConfigKey)
	end
end

function AimUIComponent:removeElementInUList()
	local count = self.catchBuffList.itemCount

	if not count or count <= 0 then
		return
	end

	for i = 0, count - 1 do
		local isExist, button = self.catchBuffList:TryGetChildAt(i)

		if button then
			-- block empty
		end
	end

	self.catchBuffList:SetList(nil)
end

function AimUIComponent:getDisplayConfigName(ent, context, propTab, textTab)
	local finalProb

	if context and context.canCatch then
		local isMust = context.probGroup.isMust

		if isMust then
			table.insert(propTab, string.format("%.1f", 999))
			table.insert(textTab, context.probGroup.reason)
		else
			if not ent:isDead() and context.levelStateProb ~= 1 then
				table.insert(propTab, string.format("%.1f", context.levelStateProb))

				local levelRatioKey = context.levelStateProb <= catch_config_data.CATCH_LEVEL_TOO_HIGH_THRESHOLD and "levelRatioFuncDebuffMax" or "levelRatioFuncDebuff"

				table.insert(textTab, levelRatioKey)
			end

			if context.ballProb ~= 1 then
				table.insert(propTab, string.format("%.1f", context.ballProb))
				table.insert(textTab, "ballProb")
			end

			if ent:isInCombat() then
				if context.hpStateProb ~= 1 then
					table.insert(propTab, string.format("%.1f", context.hpStateProb))

					local hpRatioKey = context.hpStateProb > 1 and "hpRatioFuncBuff" or "hpRatioFuncDebuff"

					table.insert(textTab, hpRatioKey)
				end

				if context.probGroup.minMaxProb ~= 1 then
					table.insert(propTab, string.format("%.1f", context.probGroup.minMaxProb))
					table.insert(textTab, context.probGroup.reason)
				end
			elseif ent:isDead() then
				if context.entTagProb ~= 1 then
					table.insert(propTab, string.format("%.1f", context.entTagProb))

					local entityTagName = context.entTagKey

					table.insert(textTab, entityTagName)
				end
			else
				if context.fromBehindProb ~= 1 then
					table.insert(propTab, string.format("%.1f", context.fromBehindProb))
					table.insert(textTab, "fromBehindRadio")
				end

				if context.probGroup.minMaxProb ~= 1 then
					table.insert(propTab, string.format("%.1f", context.probGroup.minMaxProb))
					table.insert(textTab, context.probGroup.reason)
				end
			end
		end

		finalProb = LuaUIUtils.formatCatchRate(context.finalProb)
	else
		table.insert(propTab, 0)
		table.insert(textTab, context.cantCatchReason)

		finalProb = 0
	end

	return finalProb
end

function AimUIComponent:switchCatchTopLogo(active, ent)
	if ent then
		ent.eventEmitter:emit(EventConst.TOPLOGO_CATCH_LOCK, active)
	end
end

function AimUIComponent:clearLockEntity(isExit)
	if self.catchLockTargetId then
		local ent = pg.getEntity(self.catchLockTargetId)

		if not ent then
			self:setLockTargetInCatch()
		else
			self:switchCatchTopLogo(false, ent)
		end
	end

	if not isExit then
		self:setLockTargetInCatch()
	end
end

function AimUIComponent:setLockTargetInCatch(entId)
	self.catchLockTargetId = entId
end

function AimUIComponent:clearAim()
	self:clearCatchPetLevelGapCache()
end

function AimUIComponent:onCatchModeChange(enable)
	if enable then
		self:initAimTimer()
		self:_syncLockStateFromCamera()
	else
		if self.timer then
			self.ctrl:killTimer(self.timer)

			self.timer = nil
		end

		self:removeElementInUList()

		self.catchLocked = false

		self:clearLockEntity(true)
		self:clearAim()
		self:resetAnimState(0, false)
		pg.game.input:stopRumble(ClientConst.RumbleLayer.CATCH_AIM)
	end

	self:clearCatchPetLevelGapCache()
end

function AimUIComponent:clearCatchPetLevelGapCache()
	self.aimedActorIds = {}
	self.curAimedActorId = nil
	self.curAimedTs = 0
end

function AimUIComponent:tryTriggerCatchPetLevelGap(ent)
	local actorId = ent.actorId

	if self.curAimedActorId ~= actorId then
		if self.curAimedActorId then
			self.aimedActorIds[self.curAimedActorId] = nil
		end

		self.curAimedActorId = actorId
		self.curAimedTs = Time.realSecondCache * 1000

		return
	end

	if self.aimedActorIds[actorId] then
		return
	end

	if Time.realSecondCache * 1000 - self.curAimedTs <= catch_config_data.CATCH_LEVEL_TOO_HIGH_TIP_DWELL_TIME then
		return
	end

	self.aimedActorIds[actorId] = true

	pg.me:checkTriggerCatchPetLevelGap(ent.level or 0, Utils.getPuppetPetPrototypeId(ent.templateId))
end

function AimUIComponent:switchAimVisible(visible)
	LuaUIUtils.setUIViewVisible(self.catchAimSightUComponent, visible)
end

function AimUIComponent:getCatchRate(ent)
	local entity = ent

	if entity == nil then
		return 0
	end

	local propId = self.ctrl:getCurSelectPropId()
	local rate, context = ClientCaptureUtils.catchUIColorRate(pg.me, entity, propId)

	return rate, context
end

return AimUIComponent
