-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\TopTipArea\\BossHpComp.lua

local Class = require("Core.Framework.Class")
local ClientTextUtils = require("Utils.ClientTextUtils")
local BossRushUtils = require("Utils.BossRushUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Prof = require("Guis.Panels.Tips.Items.TopTipArea.BossTitleProfiler")
local BossHpComp = Class.LightClass("BossHpComp")

function BossHpComp:ctor(owner)
	self.owner = owner
	self.lastBossStage = nil
	self.lastBossRushStage = nil
	self.m_lastSyncedCurHp = nil
end

function BossHpComp:onBind(objectReference)
	self.barHp = objectReference:GetRefValue("barHp")
	self.addonBloodUContainer = objectReference:GetRefValue("addonBloodUContainer")
	self.hpNumUWidget = objectReference:GetRefValue("hpNumUWidget")
	self.hpNumUBaseText = objectReference:GetRefValue("hpNumUBaseText")

	self.barHp:TryChangePage("NameChar", 2)
end

function BossHpComp:initTargetInfo()
	local multiHpBar = self.owner.curTarget:getConfigData().mutiHpBar or 1
	local showMultiHpBar = multiHpBar > 1 or pg.me.space:isBossRushEnv()

	LuaUIUtils.setUIVisible(self.addonBloodUContainer, showMultiHpBar)
	self.hpNumUWidget:SetActiveFastestAndMarkIgnoreLayout(showMultiHpBar)

	if showMultiHpBar and not self.addonBloodUContainer:CheckURLLoaded() then
		self.addonBloodUContainer:LoadDefaultUrlManually(function()
			return
		end)
	end

	if pg.me.space:isBossRushEnv() then
		self:refreshBossStage(true)
	elseif multiHpBar > 1 then
		ClientTextUtils.setText(self.hpNumUBaseText, "x", multiHpBar)
	end
end

function BossHpComp:getStagePos()
	if self.hpNumUBaseText then
		return self.hpNumUBaseText.transform.position
	end
end

function BossHpComp:isBound()
	return self.barHp ~= nil and NotNil(self.barHp)
end

function BossHpComp:newHpState()
	return {
		displayMaxHp = 1,
		displayCurHp = 0,
		rawMaxHp = 1,
		rawCurHp = 0,
		barSize = 1,
		curRatio = 0
	}
end

function BossHpComp:getHpDisplayRatio(curHp, maxHp)
	return math.clamp(curHp / (maxHp - 0.01), 0, 1)
end

function BossHpComp:refreshHpDisplay(entity)
	local owner = self.owner
	local state = owner.hpState
	local rawCurHp = entity.curHp or 0
	local rawMaxHp = entity.maxHp or 1
	local displayCurHp, displayMaxHp = rawCurHp, rawMaxHp
	local barSize = rawMaxHp
	local configData = entity:getConfigData()
	local multiHpBar = configData.mutiHpBar or 1

	if pg.space:isBossRushEnv() then
		local grade, curValue, maxValue = BossRushUtils.getBossCurHpState(rawCurHp, rawMaxHp)

		state.hideAddonBlood = BossRushUtils.checkIsBossLastHp(rawCurHp, rawMaxHp)
		state.curStage = BossRushUtils.getBossTotalHpCount() - grade + 1
		displayCurHp = curValue
		displayMaxHp = maxValue
		barSize = maxValue
	elseif multiHpBar > 1 then
		local oneHpBar = rawMaxHp / multiHpBar
		local curStage = math.min(math.floor(rawCurHp / oneHpBar) + 1, multiHpBar)

		displayCurHp = rawCurHp % oneHpBar
		displayMaxHp = oneHpBar
		barSize = oneHpBar
		state.curStage = curStage
		state.hideAddonBlood = curStage <= 1
	else
		state.curStage = nil
		state.hideAddonBlood = nil
	end

	state.rawCurHp = rawCurHp
	state.rawMaxHp = rawMaxHp
	state.displayCurHp = displayCurHp
	state.displayMaxHp = displayMaxHp
	state.barSize = barSize > 0 and barSize or 1
	state.curRatio = self:getHpDisplayRatio(displayCurHp, displayMaxHp)
end

function BossHpComp:applyHpToBar(isFirstSet)
	local owner = self.owner
	local state = owner.hpState

	if state.hideAddonBlood then
		LuaUIUtils.setUIVisible(self.addonBloodUContainer, false)
	end

	if state.curStage and self.lastBossStage ~= state.curStage then
		self.lastBossStage = state.curStage

		if not isFirstSet and state.curStage ~= 0 then
			owner.rootComponent:InvokeCallback(CS.XGUI.EInvokeTime.User2)
		end

		ClientTextUtils.setText(self.hpNumUBaseText, "x", state.curStage)
	end

	self.barHp.maxHp = state.displayMaxHp

	if isFirstSet and pg.space:isNpcDuel() then
		self.barHp.hp = state.displayCurHp
	end

	self.barHp.hp = state.displayCurHp
end

function BossHpComp:refreshHealthPoint(entity)
	local owner = self.owner

	Prof.markHpFrame()

	if not owner.m_isCreated then
		return
	end

	if not owner.curTarget or owner.curTarget.id ~= entity.id then
		return
	end

	local newCurHp = entity and entity.curHp

	if newCurHp ~= nil and self.m_lastSyncedCurHp ~= nil and math.abs(self.m_lastSyncedCurHp - newCurHp) < 0.01 then
		return
	end

	local isFirstSet = self.m_lastSyncedCurHp == nil
	local preRawHp = self.m_lastSyncedCurHp or newCurHp or 0

	self.m_lastSyncedCurHp = newCurHp

	if owner.m_isSwitchTargetFadingOut then
		return
	end

	if entity and self.barHp then
		Prof.count("hpApplied")
		Prof.beginSample("BossTitle.refreshHp")

		local preStage = owner.hpState.curStage

		self:refreshHpDisplay(entity)
		self:applyHpToBar(isFirstSet)
		owner.bloodFx:onHpDisplayChanged(preRawHp, preStage)
		Prof.endSample()
	else
		owner.hpState.curRatio = 0
	end
end

function BossHpComp:refreshBossStage(isInit)
	local owner = self.owner

	if not owner.m_isCreated then
		return
	end

	if not owner.curTarget then
		return
	end

	if not pg.me.space:isBossRushEnv() then
		return
	end

	local newStage = pg.space.levelStage or 0

	if self.lastBossRushStage == newStage then
		return
	end

	self.lastBossRushStage = newStage

	if not isInit and newStage ~= 0 then
		owner.rootComponent:InvokeCallback(CS.XGUI.EInvokeTime.User2)
	end

	local totalHpCount = BossRushUtils.getBossTotalHpCount()

	ClientTextUtils.setText(self.hpNumUBaseText, "x", totalHpCount - newStage)
end

function BossHpComp:reset()
	local owner = self.owner

	owner.hpState = self:newHpState()
	self.m_lastSyncedCurHp = nil
	self.lastBossStage = nil
	self.lastBossRushStage = nil

	if self.barHp then
		self.barHp:ResetFxLockInfo()
	end
end

function BossHpComp:destroy()
	self:reset()
end

return BossHpComp
