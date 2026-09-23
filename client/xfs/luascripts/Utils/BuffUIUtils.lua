-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\BuffUIUtils.lua

local LuaUIUtils = require("Utils.LuaUIUtils")
local TimerManager = require("Core.Timer.TimerManager")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientAbilityUtils = require("Utils.ClientAbilityUtils")
local ClientUtils = require("Utils.ClientUtils")
local AbilityConst = require("Common.Const.AbilityConst")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local lume = require("Core.Common.lume")
local BuffConfigData = require("Data.buff_config_data")
local ElementBuffData = require("Data.element_buff_data")
local ElementPropData = require("Data.element_prop_data")
local AbilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local SysConfigData = require("Data.sys_config_data")
local element_buff_rev_data = require("Data.element_buff_rev_data")
local BuffUIUtils = {}

function BuffUIUtils.sortBuff(buffA, buffB)
	if buffA.showOrder == buffB.showOrder then
		if buffA.isAdvanced and not buffB.isAdvanced then
			return true
		end

		if not buffA.isAdvanced and buffB.isAdvanced then
			return false
		end

		return buffA.instanceId > buffB.instanceId
	end

	return buffA.showOrder > buffB.showOrder
end

function BuffUIUtils.findBuffIndex(buffList, instanceId)
	if not buffList or not instanceId then
		return 0
	end

	for i, info in ipairs(buffList) do
		if info.instanceId == instanceId then
			return i
		end
	end

	return 0
end

function BuffUIUtils.computeInsertIndex(buffList, buffInfo, maxCount)
	if not buffList or not buffInfo then
		return 0
	end

	local idx

	for i, info in ipairs(buffList) do
		if BuffUIUtils.sortBuff(buffInfo, info) then
			idx = i

			break
		end
	end

	idx = idx or #buffList + 1

	if maxCount and maxCount < idx then
		return 0
	end

	return idx
end

function BuffUIUtils.tryInsertBuff(uiList, buffList, idx, buffInfo)
	if not buffList or not buffInfo or not idx or idx <= 0 then
		return
	end

	table.insert(buffList, idx, buffInfo)

	if uiList then
		if idx == #buffList then
			uiList:AddElement(buffInfo)
		else
			uiList:InsertElement(idx - 1, buffInfo)
		end
	end
end

function BuffUIUtils.tryRemoveBuff(uiList, buffList, idx)
	if not buffList or not idx or idx <= 0 or idx > #buffList then
		return
	end

	table.remove(buffList, idx)

	if uiList then
		uiList:RemoveElement(idx - 1)
	end
end

function BuffUIUtils.refreshBuffCountDown(btn, buffInfo)
	local objectReference = btn:GetComponent("ObjectReference")
	local countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")

	if not countDownUCountDown then
		return
	end

	if buffInfo.duration > 0 and not buffInfo.hideCountDown then
		LuaUIUtils.setUIViewVisible(countDownUCountDown, true)

		if buffInfo.breakBuffFreezeTime ~= 0 then
			countDownUCountDown:Stop()
		else
			local remain = buffInfo.expiredTime - pg.me:getGameTime()

			if remain > 0 then
				local totalTime = math.max(buffInfo.duration, remain)

				countDownUCountDown:Play(remain, totalTime)
			end
		end
	else
		LuaUIUtils.setUIViewVisible(countDownUCountDown, false)
	end
end

function BuffUIUtils.refreshBuffLayer(btn, buffInfo)
	local objectReference = btn:GetComponent("ObjectReference")
	local numUBaseText = objectReference:GetRefValue("numUBaseText")

	if not numUBaseText then
		return
	end

	local maxLayer = AbilityUtils.getBuffMaxLayer(buffInfo.templateId)

	if maxLayer > 1 then
		ClientTextUtils.setText(numUBaseText, BuffUIUtils.formatBuffLayer(buffInfo.layer or ""))
	else
		ClientTextUtils.setText(numUBaseText, "")
	end
end

function BuffUIUtils.updateBuffExpiredTime(uiList, buffList, info)
	if not info or not buffList then
		return nil
	end

	local idx = BuffUIUtils.findBuffIndex(buffList, info.buffInsId)

	if idx <= 0 then
		return nil
	end

	local buffInfo = buffList[idx]

	if info.newExpireTime then
		buffInfo.expiredTime = info.newExpireTime
	end

	if info.newDuration then
		buffInfo.duration = info.newDuration
	end

	if uiList then
		local flag, btn = uiList:TryGetChildAt(idx - 1)

		if flag then
			BuffUIUtils.refreshBuffCountDown(btn, buffInfo)
		end
	end

	return buffInfo
end

function BuffUIUtils.clearBuffDisappearHintTimer(uiComp, instanceId)
	if uiComp and uiComp.buffDisappearHintTimer and instanceId and uiComp.buffDisappearHintTimer[instanceId] then
		TimerManager.removeTimer(uiComp.buffDisappearHintTimer[instanceId])

		uiComp.buffDisappearHintTimer[instanceId] = nil
	end
end

function BuffUIUtils.applyLayerChange(uiList, buffList, info)
	if not info or not buffList then
		return
	end

	local idx = BuffUIUtils.findBuffIndex(buffList, info.instanceId)

	if idx <= 0 then
		return
	end

	local buffInfo = buffList[idx]

	buffInfo.layer = info.newLayer

	if not uiList then
		return
	end

	local flag, btn = uiList:TryGetChildAt(idx - 1)

	if flag then
		BuffUIUtils.refreshBuffLayer(btn, buffInfo)

		if not BuffUIUtils.checkForbidLayerChangeFx(buffInfo.templateId) then
			btn:InvokeCallback(CS.XGUI.EInvokeTime.Custom6)
		end
	end
end

function BuffUIUtils.invokeDisappearHintFx(uiList, buffList, instanceId)
	if not uiList or not buffList or not instanceId then
		return
	end

	local idx = BuffUIUtils.findBuffIndex(buffList, instanceId)

	if idx <= 0 then
		return
	end

	local flag, btn = uiList:TryGetChildAt(idx - 1)

	if flag then
		btn:InvokeCallback(CS.XGUI.EInvokeTime.Custom5)
	end
end

function BuffUIUtils.scheduleDisappearHint(uiComp, buffInfo)
	return BuffUIUtils.checkBuffDisappearHint(uiComp, buffInfo)
end

function BuffUIUtils.rescheduleDisappearHint(uiComp, buffInfo)
	if not buffInfo then
		return false
	end

	BuffUIUtils.clearBuffDisappearHintTimer(uiComp, buffInfo.instanceId)

	return BuffUIUtils.scheduleDisappearHint(uiComp, buffInfo)
end

function BuffUIUtils.computeSpecialStateBuff(buffList)
	if not buffList then
		return nil
	end

	local maxOrder = -1
	local maxInsId = 0
	local result, resultCfg

	for _, buffInfo in ipairs(buffList) do
		local cfg = BuffConfigData[buffInfo.templateId]

		if cfg and cfg.stateEffectIcon and cfg.stateEffectOrder then
			local order = cfg.stateEffectOrder

			if maxOrder < order or order == maxOrder and maxInsId < buffInfo.instanceId then
				maxOrder = order
				maxInsId = buffInfo.instanceId
				result = buffInfo
				resultCfg = cfg
			end
		end
	end

	if result then
		result.stateEffectIcon = resultCfg.stateEffectIcon
		result.name = resultCfg.buffName
	end

	return result
end

function BuffUIUtils.renderBuffIcon(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local numUBaseText = objectReference:GetRefValue("numUBaseText")
	local maxLayer = AbilityUtils.getBuffMaxLayer(data.templateId)

	if maxLayer > 1 then
		ClientTextUtils.setText(numUBaseText, BuffUIUtils.formatBuffLayer(data.layer or ""))
	else
		ClientTextUtils.setText(numUBaseText, "")
	end

	if data.ecsElementType then
		button:TryChangePage("ECSType", data.ecsElementType or 0)

		return
	end

	local iconUImage = objectReference:GetRefValue("iconUImage")

	iconUImage.url = nil
	iconUImage.url = data.icon

	if data.tag == AbilityConst.BUFF_TAG_POSITIVE then
		button:TryChangePage("Buff_Type", data.isAdvanced and "Up2" or "Up")
	elseif data.tag == AbilityConst.BUFF_TAG_NEGATIVE then
		button:TryChangePage("Buff_Type", data.isAdvanced and "Down2" or "Down")
	else
		button:TryChangePage("Buff_Type", data.isAdvanced and "Normal2" or "Normal")
	end

	local countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")

	if countDownUCountDown then
		LuaUIUtils.setUIViewVisible(countDownUCountDown, false)
	end
end

function BuffUIUtils.setBuffInfo(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local numUBaseText = objectReference:GetRefValue("numUBaseText")
	local maxLayer = AbilityUtils.getBuffMaxLayer(data.templateId)

	if maxLayer > 1 then
		ClientTextUtils.setText(numUBaseText, BuffUIUtils.formatBuffLayer(data.layer or ""))
	else
		ClientTextUtils.setText(numUBaseText, "")
	end

	if data.ecsElementType and button:HasController("ECSType") then
		button:TryChangePage("ECSType", data.ecsElementType or 0)

		return
	end

	local iconUImage = objectReference:GetRefValue("iconUImage")
	local countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")

	if iconUImage then
		iconUImage.url = data.icon
	end

	if data.tag == AbilityConst.BUFF_TAG_POSITIVE then
		button:TryChangePage("Buff_Type", data.isAdvanced and "Up2" or "Up")
	elseif data.tag == AbilityConst.BUFF_TAG_NEGATIVE then
		button:TryChangePage("Buff_Type", data.isAdvanced and "Down2" or "Down")
	else
		button:TryChangePage("Buff_Type", data.isAdvanced and "Normal2" or "Normal")
	end

	if countDownUCountDown then
		countDownUCountDown.useGameTime = true

		if data.duration > 0 and not data.hideCountDown then
			LuaUIUtils.setUIViewVisible(countDownUCountDown, true)

			if data.breakBuffFreezeTime ~= 0 then
				countDownUCountDown:Stop()
			else
				local duration = data.expiredTime - pg.me:getGameTime()

				if duration > 0 then
					local totalTime = math.max(data.duration, duration)

					countDownUCountDown:Play(duration, totalTime)
				end
			end
		else
			LuaUIUtils.setUIViewVisible(countDownUCountDown, false)
		end
	end

	if not data.isDisplayed then
		button:InvokeCallback(CS.XGUI.EInvokeTime.Custom3)

		data.isDisplayed = true
	end
end

function BuffUIUtils.setStateEffectBuff(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")
	local textName = objectReference:GetRefValue("textName")

	iconUImage.url = data.stateEffectIcon

	if countDownUCountDown then
		countDownUCountDown.useGameTime = true

		if data.duration > 0 and not data.hideCountDown then
			LuaUIUtils.setUIViewVisible(countDownUCountDown, true)

			if data.breakBuffFreezeTime ~= 0 then
				countDownUCountDown:Stop()
			else
				local duration = data.expiredTime - pg.me:getGameTime()

				if duration > 0 then
					local totalTime = math.max(data.duration, duration)

					countDownUCountDown:Play(duration, totalTime)
				end
			end
		else
			LuaUIUtils.setUIViewVisible(countDownUCountDown, false)
		end
	end

	ClientTextUtils.setText(textName, ClientTextUtils.getLocalizationText(data.name))
end

function BuffUIUtils.checkIsElementBuff(buffTempId)
	return element_buff_rev_data[buffTempId] ~= nil
end

function BuffUIUtils.tryDestroyEleBuffsTimer(uiComp)
	if not uiComp then
		return
	end

	uiComp.preEleBuffButton = nil
	uiComp.preEleBuffStage = nil
	uiComp.preEleBuffType = nil
	uiComp.preEleBuffLayer = nil
	uiComp.preEleBuffSliderActive = nil
	uiComp.preEleBuffSliderValue = nil

	if uiComp.delayHideEleBuffTimer then
		TimerManager.removeTimer(uiComp.delayHideEleBuffTimer)
	end

	uiComp.delayHideEleBuffTimer = nil
end

function BuffUIUtils.setElementBuff(button, ent, uiComp)
	if uiComp and uiComp.preEleBuffButton ~= button then
		BuffUIUtils.tryDestroyEleBuffsTimer(uiComp)

		uiComp.preEleBuffButton = button
	end

	local refs = uiComp and uiComp.elementToplogoRefs

	if refs and refs.button ~= button then
		refs = nil
	end

	local objectReference = refs and refs.objectReference or button:GetComponent("ObjectReference")
	local elementType = ent.ecsAmountCache.maxElementType
	local elementAmount = ent.ecsAmountCache.maxValue
	local ebd = ElementBuffData[elementType]
	local buffId = ebd and ebd.buffId
	local buff = ent.actorBuff:findOneBuffByTemplateId(buffId)
	local outAniName = "VX_Node_ElementToplogo_State_Out"
	local animationRefVal = refs and refs.animation or objectReference:GetRefValue("uINodeElementToplogoAnimation")
	local isDelayHide = false
	local stageAniName, stageAniLoopName

	if not buff then
		if uiComp then
			BuffUIUtils.tryDestroyEleBuffsTimer(uiComp)
		end

		if animationRefVal and outAniName and uiComp then
			isDelayHide = true

			animationRefVal:Play(outAniName)

			uiComp.delayHideEleBuffTimer = TimerManager.addTimer(0.5, function()
				if button then
					button:SetActiveFastest(false)
				end
			end)
		else
			button:SetActiveFastest(false)
		end

		return false, isDelayHide
	end

	if button.bActive == false then
		button:SetActive(true)
	end

	button:SetActiveFastest(true)

	local buffConfigData = BuffConfigData[buffId]
	local stage = 0

	if buffConfigData.stage3Layer and buff.buffData.layer > buffConfigData.stage3Layer then
		stage = 2
		stageAniName = "VX_Node_ElementToplogo_State3_In"
		stageAniLoopName = "VX_Node_ElementToplogo_State3_Loop"
	elseif buffConfigData.stage2Layer and buff.buffData.layer > buffConfigData.stage2Layer then
		stage = 1
		stageAniName = "VX_Node_ElementToplogo_State2_In"
	else
		stage = 0
		stageAniName = "VX_Node_ElementToplogo_State1_In"
	end

	if not uiComp.preEleBuffStage or uiComp.preEleBuffStage ~= stage then
		button:TryChangePage("State", stage, false, true, false)

		if animationRefVal and stageAniName then
			animationRefVal:Play(stageAniName)

			if stageAniLoopName then
				animationRefVal:PlayQueued(stageAniLoopName)
			end
		end
	end

	uiComp.preEleBuffStage = stage

	if not uiComp or uiComp.preEleBuffType ~= elementType then
		local abilityElementType = AbilityConst.ECS_ELEMENT_2_ABILITY[elementType]

		button:TryChangePage("type", ElementPropData[abilityElementType].name)

		if uiComp then
			uiComp.preEleBuffType = elementType
		end
	end

	local sliderUSlider = refs and refs.slider or objectReference:GetRefValue("sliderUSlider")

	if not uiComp or not uiComp.preEleBuffSliderActive then
		sliderUSlider:SetActive(true)

		if uiComp then
			uiComp.preEleBuffSliderActive = true
		end
	end

	local layer = buff.buffData.layer

	if not uiComp or uiComp.preEleBuffLayer ~= layer then
		local numUBaseText = refs and refs.numText or objectReference:GetRefValue("numUBaseText")

		ClientTextUtils.setText(numUBaseText, BuffUIUtils.formatBuffLayer(layer))

		if uiComp then
			uiComp.preEleBuffLayer = layer
		end
	end

	local value = 0
	local valueLayer = AbilitySettingGlobalConstData.elementValuePerLayer

	if stage == 0 then
		value = elementAmount / (valueLayer * (buffConfigData.stage2Layer or buffConfigData.maxLayer))
	elseif stage == 1 then
		local startAmount = valueLayer * buffConfigData.stage2Layer
		local endAmount = valueLayer * buffConfigData.stage3Layer

		value = (elementAmount - startAmount) / (endAmount - startAmount)
	else
		local startAmount = valueLayer * buffConfigData.stage3Layer
		local endAmount = valueLayer * buffConfigData.maxLayer

		value = (elementAmount - startAmount) / (endAmount - startAmount)
	end

	value = math.clamp(value, 0, 1)

	if not uiComp or uiComp.preEleBuffSliderValue ~= value then
		sliderUSlider.value = value

		if uiComp then
			uiComp.preEleBuffSliderValue = value
		end
	end

	return true
end

function BuffUIUtils._addBuffInfo(buff, ent, ret)
	local icon = ClientAbilityUtils.getBuffIcon(buff.templateId)
	local buffConfigData = BuffConfigData[buff.templateId]
	local buffTemplate = pg.global.abilityMgr:getBuffTemplate(buff.templateId, buff.level)
	local overrideTags = buffConfigData and buffConfigData.buffTag
	local tags = buffTemplate and buffTemplate.tags
	local tag

	if overrideTags then
		if lume.find(overrideTags, "Positive") then
			tag = AbilityConst.BUFF_TAG_POSITIVE
		elseif lume.find(overrideTags, "Negative") then
			tag = AbilityConst.BUFF_TAG_NEGATIVE
		end
	elseif tags then
		if lume.find(tags, AbilityConst.BUFF_TAG_POSITIVE) then
			tag = AbilityConst.BUFF_TAG_POSITIVE
		elseif lume.find(tags, AbilityConst.BUFF_TAG_NEGATIVE) then
			tag = AbilityConst.BUFF_TAG_NEGATIVE
		end
	end

	local buffInfo

	if icon ~= nil then
		local stage

		if buffConfigData.stageElement then
			stage = buff.layer > (buffConfigData.stage3Layer or 10) and 3 or buff.layer > (buffConfigData.stage2Layer or 5) and 2 or 1
		end

		local srcEntity = pg.getEntity(buff.srcEntityId)
		local buffOwner = buff:getRootOwner()
		local buffInstance = buffOwner and buffOwner.actorBuff and buffOwner.actorBuff:findBuff(buff.instanceId)

		buffInfo = {
			templateId = buff.templateId,
			level = buff.level,
			icon = icon,
			tag = tag,
			layer = buff.layer,
			expiredTime = buff.expiredTime,
			duration = buff.duration,
			breakBuffFreezeTime = ent.breakBuffFreezeTime,
			hideCountDown = buffConfigData and buffConfigData.hideCountDown,
			isAdvanced = ToBool(buffConfigData.isAdvanced),
			instanceId = buff.instanceId,
			stageElement = buffConfigData.stageElement,
			stage = stage,
			isDisplayed = ent.displayedBuffs and ent.displayedBuffs[buff.templateId],
			ownerActorId = buffInstance and buffInstance.owner and buffInstance.owner.actorId or ent and ent.actorId,
			buffInstance = buffInstance,
			showOrder = buffConfigData.showOrder or 0,
			petInfo = srcEntity and srcEntity.petInfo or ent and ent.petInfo
		}

		if not buffInfo.isDisplayed and buff.isTeamBuff then
			local masterEntity = ent.getMasterEntity and ent:getMasterEntity()

			if masterEntity then
				buffInfo.isDisplayed = masterEntity.displayedBuffs and masterEntity.displayedBuffs[buff.templateId]
			end
		end

		ret[#ret + 1] = buffInfo
	end

	local ecsElementType = element_buff_rev_data[buff.templateId]

	if ecsElementType and buffInfo then
		buffInfo.tIndex = 1
		buffInfo.ecsElementType = ecsElementType
	end

	return buffInfo
end

function BuffUIUtils.getEcsBuffList(ent, maxCount)
	if not ent then
		return {}, nil
	end

	local buffs = ent.buffDataList or {}
	local ret = {}

	for _, buff in ipairs(buffs) do
		local ecsElementType = element_buff_rev_data[buff.templateId]

		if ecsElementType then
			BuffUIUtils._addBuffInfo(buff, ent, ret)
		end
	end

	table.sort(ret, BuffUIUtils.sortBuff)

	if maxCount and maxCount < #ret then
		for i = #ret, maxCount + 1, -1 do
			ret[i] = nil
		end
	end

	return ret
end

function BuffUIUtils.filterEcsBuff(buffList)
	RemoveTableByFunc(buffList, function(buffInfo)
		return BuffUIUtils.checkIsElementBuff(buffInfo.templateId)
	end)
end

function BuffUIUtils.updateSpecialStateBuff(specialStateBuff, newBuffData, ent)
	if not newBuffData then
		return specialStateBuff
	end

	local buffCfgData = BuffConfigData[newBuffData.templateId]

	if buffCfgData.stateEffectIcon and buffCfgData.stateEffectOrder then
		if specialStateBuff == nil then
			specialStateBuff = BuffUIUtils._addBuffInfo(newBuffData, ent, {})
			specialStateBuff.stateEffectIcon = buffCfgData.stateEffectIcon
			specialStateBuff.name = buffCfgData.buffName
		else
			local curSpecialStateBuffCfgData = BuffConfigData[specialStateBuff.templateId]
			local curStateEffectOrder = curSpecialStateBuffCfgData.stateEffectOrder

			if curStateEffectOrder < buffCfgData.stateEffectOrder or buffCfgData.stateEffectOrder == curStateEffectOrder and newBuffData.instanceId > specialStateBuff.instanceId then
				specialStateBuff = BuffUIUtils._addBuffInfo(newBuffData, ent, {})
				specialStateBuff.stateEffectIcon = buffCfgData.stateEffectIcon
				specialStateBuff.name = buffCfgData.buffName
			end
		end
	end

	return specialStateBuff
end

function BuffUIUtils.getUIBuffList(ent, maxCount)
	if not ent then
		return {}, nil
	end

	local buffs = ent.buffDataList or {}
	local ret = {}
	local maxStateEffectOrder = -1
	local maxStateEffectInsId = 0
	local stateEffectBuffInfo

	for _, buff in ipairs(buffs) do
		local buffInfo = BuffUIUtils._addBuffInfo(buff, ent, ret)

		if buffInfo then
			local configData = BuffConfigData[buff.templateId]

			if configData.stateEffectIcon and configData.stateEffectOrder and (maxStateEffectOrder < configData.stateEffectOrder or configData.stateEffectOrder == maxStateEffectOrder and maxStateEffectInsId < buff.instanceId) then
				maxStateEffectOrder = configData.stateEffectOrder
				maxStateEffectInsId = buff.instanceId
				stateEffectBuffInfo = ret[#ret]
				stateEffectBuffInfo.stateEffectIcon = configData.stateEffectIcon
				stateEffectBuffInfo.name = configData.buffName
			end
		end
	end

	local masterEntity = ent.getMasterEntity and ent:getMasterEntity()

	if masterEntity then
		for _, buff in ipairs(masterEntity.buffDataList) do
			if buff.isTeamBuff then
				BuffUIUtils._addBuffInfo(buff, ent, ret)
			end
		end
	end

	table.sort(ret, BuffUIUtils.sortBuff)

	if maxCount and maxCount < #ret then
		for i = #ret, maxCount + 1, -1 do
			ret[i] = nil
		end
	end

	return ret, stateEffectBuffInfo
end

function BuffUIUtils.tryfilterOutElementBuff(ret)
	local filteredRet = {}

	for i = 1, #ret do
		local elem = ret[i]

		if elem and elem.templateId ~= nil and not BuffUIUtils.checkIsElementBuff(elem.templateId) then
			table.insert(filteredRet, elem)
		end
	end

	return filteredRet
end

function BuffUIUtils.checkForbidLayerChangeFx(buffId)
	return BuffConfigData[buffId] and BuffConfigData[buffId].forbidLayerChangeFx
end

function BuffUIUtils.checkBuffDisappearHint(uiComp, buffData)
	if not uiComp or not uiComp.buffDisappearHintTimer then
		return false
	end

	if not buffData then
		return false
	end

	local hintDuration = AbilitySettingGlobalConstData.buffDisappearHintDuration

	if not hintDuration then
		return false
	end

	local durationLimit = AbilitySettingGlobalConstData.buffDisappearHintDurationLimit
	local buffDuration = buffData.duration

	if buffDuration == -1 then
		return false
	end

	if durationLimit and buffDuration < durationLimit then
		return false
	end

	local buffRemainDuration = buffData.expiredTime - pg.me:getGameTime()
	local delayTime = math.max(buffRemainDuration - hintDuration, 0)

	return true, delayTime, buffData.instanceId
end

function BuffUIUtils.checkCanDoAppearBuff(ent, buffData)
	local isMultiPlayerEnv = pg.me.space and pg.me.space:isMultiPlayerEnv()

	if isMultiPlayerEnv then
		local casterEnt = pg.getEntity(buffData.srcEntityId)
		local casterPlayerEnt = Utils.getMasterPlayer(casterEnt)

		if casterPlayerEnt ~= pg.me then
			return false
		end
	elseif Utils.isPuppet(ent) then
		local labelCheck = AbilitySettingGlobalConstData.appearBuffPuppetLabelLimit

		if labelCheck then
			local labelValid = false
			local label = ent.label or Const.PET_LABEL_MASK.NORMAL

			for _, checkLabel in ipairs(labelCheck) do
				if ToBool(bit.band(label, checkLabel)) then
					labelValid = true

					break
				end
			end

			if not labelValid then
				return false
			end
		end

		if not AbilityUtils.checkBuffHasTag(buffData.templateId, AbilityConst.BUFF_TAG_NEGATIVE) then
			return false
		end
	elseif Utils.isPlayer(ent) or Utils.isPet(ent) then
		if not AbilityUtils.checkBuffHasTag(buffData.templateId, AbilityConst.BUFF_TAG_POSITIVE) then
			return false
		end
	else
		return false
	end

	return true
end

function BuffUIUtils.doAppearFromTopLogoBuff(info, uiComp, targetKey)
	local doEntActorId = info and info.ent and info.ent.actorId
	local curTarget = uiComp[targetKey]

	if not curTarget or curTarget.actorId ~= doEntActorId then
		return
	end

	uiComp.appearFromTopLogoBuffInfo = info

	if NotNil(uiComp.topLogoBuffUButton) then
		uiComp.topLogoBuffUButton:SetActive(false)

		local ret = {}

		BuffUIUtils._addBuffInfo(uiComp.appearFromTopLogoBuffInfo.buffData, uiComp.appearFromTopLogoBuffInfo.ent, ret)

		if ret[1] then
			uiComp.topLogoBuffUButton:SetActive(true)

			uiComp.isBuffAppearing = true

			local curTargetLockPos = curTarget:getLockPosition()
			local worldOffsetX = 0
			local worldOffsetH = curTargetLockPos and curTargetLockPos.y - curTarget:getPosition().y or 0
			local uiOffsetX, uiOffsetY = ClientUtils.getPetEntryBuffUIoffset(curTarget)

			uiComp.topLogoBuffUButton.ignoreLayout = true

			CS.FunPlus.WorldX.GUIS.Panels.UFollowEnt.CreateByActorId(uiComp.topLogoBuffUButton.gameObject, curTarget.actorId, worldOffsetX, worldOffsetH, uiOffsetX, uiOffsetY)
			uiComp.topLogoBuffUButton:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)

			local rawDataHideCd = ret[1].hideCountDown

			ret[1].hideCountDown = true

			BuffUIUtils.setBuffInfo(uiComp.topLogoBuffUButton, ret[1])

			ret[1].hideCountDown = rawDataHideCd

			if uiComp.topLogoBuffTimer then
				uiComp:killTimer(uiComp.topLogoBuffTimer)

				uiComp.topLogoBuffTimer = nil
			end

			if uiComp.delayHideBuffTimer then
				uiComp:killTimer(uiComp.delayHideBuffTimer)

				uiComp.delayHideBuffTimer = nil
			end

			uiComp.topLogoBuffTimer = uiComp:startTimer(function()
				uiComp.topLogoBuffTimer = nil

				if NotNil(uiComp.topLogoBuffUButton) then
					uiComp.topLogoBuffUButton:InvokeCallback(CS.XGUI.EInvokeTime.Custom4)

					uiComp.delayHideBuffTimer = uiComp:startTimer(function()
						if uiComp then
							uiComp.delayHideBuffTimer = nil

							if NotNil(uiComp.topLogoBuffUButton) then
								uiComp.topLogoBuffUButton:SetActive(false)
							end

							uiComp.isBuffAppearing = false
						end
					end, 1)
				end
			end, BuffUIUtils.getAppearFromTopLogoBuffTime())
		end
	end
end

function BuffUIUtils.getAppearFromTopLogoBuffTime()
	return SysConfigData.appearFromTopLogoBuffTime or 2.5
end

function BuffUIUtils.getBuffConfigData(strArray)
	local buffId = tonumber(strArray[1])
	local keyName = strArray[2]

	return BuffConfigData[buffId] and BuffConfigData[buffId][keyName]
end

function BuffUIUtils.isAppearFromTopLogoBuff(ent, buffData)
	local templateId = buffData.templateId

	if BuffConfigData[templateId].isAppearFromTopLogo then
		return BuffUIUtils.checkCanDoAppearBuff(ent, buffData)
	end

	return false
end

function BuffUIUtils.formatBuffLayer(layer)
	if not layer then
		return ""
	end

	if type(layer) ~= "number" then
		layer = tonumber(layer) or 0
	end

	if layer >= 1000000 then
		return "999k"
	end

	if layer >= 10000 then
		return math.floor(layer / 1000) .. "k"
	end

	if layer >= 1000 then
		local val = layer / 1000

		if val % 1 == 0 then
			return string.format("%dk", val)
		else
			return string.format("%.1fk", val)
		end
	end

	return tostring(math.floor(layer))
end

return BuffUIUtils
