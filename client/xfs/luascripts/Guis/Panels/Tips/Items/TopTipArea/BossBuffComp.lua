-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\TopTipArea\\BossBuffComp.lua

local Class = require("Core.Framework.Class")
local BuffUIUtils = require("Utils.BuffUIUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local SysConfigData = require("Data.sys_config_data")
local TimerManager = require("Core.Timer.TimerManager")
local Prof = require("Guis.Panels.Tips.Items.TopTipArea.BossTitleProfiler")
local ToBool = ToBool
local BossBuffComp = Class.LightClass("BossBuffComp")

function BossBuffComp:ctor(owner)
	self.owner = owner
	self.curBuffList = nil
	self.delayHideStateFxTimer = nil
	self.statusEffectLoadReqId = 0
	self.buffDisappearHintTimer = {}
end

function BossBuffComp:onBind(objectReference)
	self.listBuff = objectReference:GetRefValue("listBuff")
	self.elementToplogoUContainer = objectReference:GetRefValue("elementToplogoUContainer")
	self.statusEffectUContainer = objectReference:GetRefValue("statusEffectUContainer")
	self.elementToplogoRefs = nil

	function self.listBuff.luaRenderItem(button, index, data)
		BuffUIUtils.setBuffInfo(button, data)
	end

	function self.listBuff.luaClick(button, data)
		local info = data

		info.targetRect = button
		info.autoVer = true

		pg.global.ui:open(UIConst.UI_ID_COMMON_BUFF_INFO_TIP, info)
	end
end

function BossBuffComp:getElementToplogoRefs()
	if not self.elementToplogoRefs then
		local button = self.elementToplogoUContainer.content:GetComponent("UButton")
		local objectReference = button:GetComponent("ObjectReference")

		self.elementToplogoRefs = {
			button = button,
			objectReference = objectReference,
			animation = objectReference:GetRefValue("uINodeElementToplogoAnimation"),
			slider = objectReference:GetRefValue("sliderUSlider"),
			numText = objectReference:GetRefValue("numUBaseText")
		}
	end

	return self.elementToplogoRefs
end

function BossBuffComp:clearDisappearHintTimers()
	for _, timerId in pairs(self.buffDisappearHintTimer) do
		TimerManager.removeTimer(timerId)
	end

	self.buffDisappearHintTimer = {}
end

function BossBuffComp:addDisappearHintTimer(delayTime, instanceId)
	BuffUIUtils.clearBuffDisappearHintTimer(self, instanceId)

	self.buffDisappearHintTimer[instanceId] = TimerManager.addTimer(delayTime, function()
		self.buffDisappearHintTimer[instanceId] = nil

		BuffUIUtils.invokeDisappearHintFx(self.listBuff, self.curBuffList, instanceId)
	end)
end

function BossBuffComp:refreshBuffs(info)
	Prof.count("buffRefresh")

	if not self.owner.m_isCreated then
		return
	end

	Prof.beginSample("BossTitle.refreshBuffs")

	local entId = info.entId

	if self.owner.curTarget and self.owner.curTarget.id == entId then
		local buffData, specialStateBuff = BuffUIUtils.getUIBuffList(self.owner.curTarget, SysConfigData.bossTitleBuffCount or 6)

		BuffUIUtils.filterEcsBuff(buffData)
		self.listBuff:SetList(buffData)

		self.curBuffList = buffData

		if specialStateBuff then
			self:showSpecialStateBuffWrap(specialStateBuff)
		else
			self:hideSpecialStateBuffWithDelay()
		end

		local should, delayTime, instanceId = BuffUIUtils.checkBuffDisappearHint(self, info and info.newBuffData)

		if should then
			self:addDisappearHintTimer(delayTime, instanceId)
		end

		self:refreshEcsAmount(self.owner.curTarget)
	end

	Prof.endSample()
end

function BossBuffComp:showSpecialStateBuffWrap(specialStateBuff)
	if IsNil(self.statusEffectUContainer) or not specialStateBuff then
		return
	end

	self:clearHideStateFxTimer()

	self.statusEffectLoadReqId = (self.statusEffectLoadReqId or 0) + 1

	local reqId = self.statusEffectLoadReqId
	local target = self.owner.curTarget
	local container = self.statusEffectUContainer

	local function applyStateEffect()
		if self.statusEffectLoadReqId ~= reqId then
			return
		end

		if not self.owner.m_isCreated or self.owner.curTarget ~= target or IsNil(container) then
			return
		end

		self:showSpecialStateBuff(specialStateBuff, container)
	end

	if container:CheckURLLoaded() then
		applyStateEffect()
	else
		container:LoadDefaultUrlManually(function()
			applyStateEffect()
		end)
	end
end

function BossBuffComp:showSpecialStateBuff(specialStateBuff, container)
	container = container or self.statusEffectUContainer

	if IsNil(container) or not container.content then
		return
	end

	self.curSpecialStateBuff = specialStateBuff

	self.owner.baseInfo:setVisible(false)
	BuffUIUtils.setStateEffectBuff(container.content, specialStateBuff)
	container:SetActive(true)
	LuaUIUtils.setUIVisible(container, true)
end

function BossBuffComp:hideSpecialStateBuffWithDelay()
	self.statusEffectLoadReqId = (self.statusEffectLoadReqId or 0) + 1

	if not self.curSpecialStateBuff then
		return
	end

	self.curSpecialStateBuff = nil

	if IsNil(self.statusEffectUContainer) or not self.statusEffectUContainer.content then
		return
	end

	self.statusEffectUContainer.content:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	self:clearHideStateFxTimer()

	self.delayHideStateFxTimer = TimerManager.addTimer(0.6, function()
		self.owner.baseInfo:setVisible(true)
		LuaUIUtils.setUIVisible(self.statusEffectUContainer, false)

		self.delayHideStateFxTimer = nil
	end)
end

function BossBuffComp:clearHideStateFxTimer()
	if self.delayHideStateFxTimer then
		TimerManager.removeTimer(self.delayHideStateFxTimer)

		self.delayHideStateFxTimer = nil
	end
end

function BossBuffComp:onBuffAdd(info)
	if not self.owner.m_isCreated or not self.owner.curTarget or not info or self.owner.curTarget.id ~= info.entId then
		return
	end

	local buffData = info.newBuffData

	if not buffData then
		return
	end

	if BuffUIUtils.checkIsElementBuff(buffData.templateId) then
		self:refreshEcsAmount(self.owner.curTarget)

		return
	end

	if not self.curBuffList then
		return
	end

	local buffInfo = BuffUIUtils._addBuffInfo(buffData, self.owner.curTarget, {})

	if buffInfo then
		local maxCount = SysConfigData.bossTitleBuffCount or 6
		local idx = BuffUIUtils.computeInsertIndex(self.curBuffList, buffInfo, maxCount)

		if idx > 0 then
			if maxCount <= #self.curBuffList then
				BuffUIUtils.tryRemoveBuff(self.listBuff, self.curBuffList, #self.curBuffList)
			end

			BuffUIUtils.tryInsertBuff(self.listBuff, self.curBuffList, idx, buffInfo)

			local newSpecial = BuffUIUtils.updateSpecialStateBuff(self.curSpecialStateBuff, buffData, self.owner.curTarget)

			if newSpecial and newSpecial ~= self.curSpecialStateBuff then
				self:showSpecialStateBuffWrap(newSpecial)
			end

			local should, delayTime, instanceId = BuffUIUtils.scheduleDisappearHint(self, buffInfo)

			if should then
				self:addDisappearHintTimer(delayTime, instanceId)
			end
		end
	end
end

function BossBuffComp:onBuffRemove(info)
	if not self.owner.m_isCreated or not self.owner.curTarget or not info or self.owner.curTarget.id ~= info.entId then
		return
	end

	local instanceId = info.buffInsId

	BuffUIUtils.clearBuffDisappearHintTimer(self, instanceId)

	if self.curBuffList then
		local idx = BuffUIUtils.findBuffIndex(self.curBuffList, instanceId)

		if idx > 0 then
			BuffUIUtils.tryRemoveBuff(self.listBuff, self.curBuffList, idx)
		end
	end

	if self.curSpecialStateBuff and self.curSpecialStateBuff.instanceId == instanceId then
		local newSpecial = BuffUIUtils.computeSpecialStateBuff(self.curBuffList)

		if newSpecial then
			self:showSpecialStateBuffWrap(newSpecial)
		else
			self:hideSpecialStateBuffWithDelay()
		end
	end

	self:refreshEcsAmount(self.owner.curTarget)
end

function BossBuffComp:refreshSpecialStateBuffExpiredTime(info)
	local specialStateBuff = self.curSpecialStateBuff

	if not specialStateBuff or specialStateBuff.instanceId ~= info.buffInsId then
		return
	end

	if info.newExpireTime ~= nil then
		specialStateBuff.expiredTime = info.newExpireTime
	end

	if info.newDuration ~= nil then
		specialStateBuff.duration = info.newDuration
	end

	if IsNil(self.statusEffectUContainer) or IsNil(self.statusEffectUContainer.content) then
		return
	end

	BuffUIUtils.refreshBuffCountDown(self.statusEffectUContainer.content, specialStateBuff)
end

function BossBuffComp:onBuffExpiredTimeChange(info)
	if not self.owner.m_isCreated or not self.owner.curTarget or not info or self.owner.curTarget.id ~= info.entId then
		return
	end

	self:refreshSpecialStateBuffExpiredTime(info)

	if self.curBuffList then
		local buffInfo = BuffUIUtils.updateBuffExpiredTime(self.listBuff, self.curBuffList, info)

		if buffInfo then
			local should, delayTime, instanceId = BuffUIUtils.rescheduleDisappearHint(self, buffInfo)

			if should then
				self:addDisappearHintTimer(delayTime, instanceId)
			end
		end
	end
end

function BossBuffComp:onBuffLayerChange(info)
	local entId = info.entId

	if self.owner.curTarget and self.owner.curTarget.id == entId then
		self:refreshEcsAmount(self.owner.curTarget)
		BuffUIUtils.applyLayerChange(self.listBuff, self.curBuffList, info)
	end
end

function BossBuffComp:refreshEcsAmount(ent)
	Prof.count("ecsMsg")

	if not ent or not self.owner.curTarget or self.owner.curTarget.id ~= ent.id then
		BuffUIUtils.tryDestroyEleBuffsTimer(self)

		return
	end

	Prof.beginSample("BossTitle.refreshEcs")

	if not self.elementToplogoUContainer then
		BuffUIUtils.tryDestroyEleBuffsTimer(self)
		Prof.endSample()

		return
	end

	local target = self.owner.curTarget
	local needShow = target.ecsAmountCache and target.ecsAmountCache.maxElementType and target.ecsAmountCache.maxValue > 0

	if not needShow then
		self.elementToplogoUContainer:SetActiveFastest(false)
		BuffUIUtils.tryDestroyEleBuffsTimer(self)
		Prof.endSample()

		return
	end

	if not self.elementToplogoUContainer:CheckURLLoaded() then
		if self.isLoading then
			return
		end

		self.isLoading = true

		BuffUIUtils.tryDestroyEleBuffsTimer(self)
		self.elementToplogoUContainer:LoadDefaultUrlManually(function(content)
			if content then
				self:refreshEcsAmount(ent)
			end
		end)
		Prof.endSample()

		return
	end

	local refs = self:getElementToplogoRefs()

	self.elementToplogoUContainer:SetActiveFastest(true)
	BuffUIUtils.setElementBuff(refs.button, target, self)
	Prof.endSample()
end

function BossBuffComp:reset()
	self.statusEffectLoadReqId = (self.statusEffectLoadReqId or 0) + 1

	self:clearDisappearHintTimers()
	self:clearHideStateFxTimer()

	self.curBuffList = nil

	BuffUIUtils.tryDestroyEleBuffsTimer(self)

	if self.elementToplogoUContainer then
		self.elementToplogoUContainer:SetActiveFastest(false)

		self.isLoading = false
	end

	if self.statusEffectUContainer then
		LuaUIUtils.setUIVisible(self.statusEffectUContainer, false)
	end
end

function BossBuffComp:destroy()
	self:reset()

	self.elementToplogoRefs = nil
end

return BossBuffComp
