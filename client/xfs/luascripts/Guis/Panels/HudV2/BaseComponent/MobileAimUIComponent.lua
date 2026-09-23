-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\MobileAimUIComponent.lua

local Class = require("Core.Framework.Class")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local Const = require("Common.Const.Const")
local MessageName = require("Const.MessageName")
local TimerManager = require("Core.Timer.TimerManager")
local QuestConst = require("Common.Const.QuestConst")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local EventConst = require("Const.EventConst")
local MobileAimUIComponent = Class.LightClass("MobileAimUIComponent", HudBaseComponent)

MobileAimUIComponent.messages = {
	[MessageName.LOCKED_TARGET_CHANGE] = {
		"onLockedTargetChange",
		true
	},
	[MessageName.CATCH_MODE_CHANGE_UI] = {
		"onCatchModeChange",
		true
	},
	[MessageName.ON_SYSTEM_FUNCTION_UNLOCKED] = {
		"refreshAimBtnState",
		true
	},
	[MessageName.QUEST_ON_STATE_CHANGE] = {
		"onQuestStateChanged",
		true
	}
}

function MobileAimUIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.aimBtn = objectReference:GetRefValue("btnAimUButton")
	self.btnSwitchUButton = objectReference:GetRefValue("btnSwitchUButton")
	self.btnCancelUButton = objectReference:GetRefValue("btnCancelUButton")
end

function MobileAimUIComponent:initView()
	self:refreshAimBtnState()

	self.aimBtnForbid = false
	self.haveForceLockTarget = false

	function self.aimBtn.luaPress()
		self.aimBtnForbid = false

		if pg.game.controller.lockHelper.forceLockActorId ~= 0 then
			self.haveForceLockTarget = true

			local mobileSkill = pg.global.ui.hudV2.RD and pg.global.ui.hudV2.RD.mobileSkill

			if mobileSkill then
				mobileSkill:lockBtnPress()
			end
		else
			self.haveForceLockTarget = false
		end
	end

	function self.aimBtn.luaRelease()
		if self.aimBtnForbid then
			return
		end

		if pg.game.controller.lockHelper.forceLockActorId == 0 and not self.haveForceLockTarget then
			pg.game.controller.lockHelper:tryForceLockTarget()
		else
			self:cancelLock()
		end
	end

	function self.btnSwitchUButton.luaPress()
		self:switchBtnPress()
	end

	function self.btnCancelUButton.luaPress()
		self:cancelLock(true)
	end

	function self.aimBtn.luaUnhover()
		self.aimBtnForbid = true

		local lockComponent = pg.global.ui.hudV2.LD and pg.global.ui.hudV2.LD.focus

		if lockComponent then
			if lockComponent.lockStrongUProgress.value == 1 then
				return
			end

			lockComponent.lockStrongUProgress:ProgressToValue(0, nil)
		end

		if pg.game.input.skillInputProcessor.lockTargetTimer ~= nil then
			TimerManager.removeTimer(pg.game.input.skillInputProcessor.lockTargetTimer)

			pg.game.input.skillInputProcessor.lockTargetTimer = nil
		end
	end
end

function MobileAimUIComponent:switchBtnPress()
	local mobileSkill = pg.global.ui.hudV2.RD and pg.global.ui.hudV2.RD.mobileSkill
	local page = 0

	if mobileSkill and mobileSkill.uWidget then
		local _, p = mobileSkill.uWidget:TryGetCurrentPage("Synopsis")

		page = p or 0
	end

	if page == 2 then
		if pg.game.controller ~= nil then
			pg.global.eventEmitter:emit(EventConst.LOCK_ENITY_MSG, "switch", self)
		end
	else
		pg.game.input.skillInputProcessor:handleLockTargetActionPerformed()
		pg.game.input.skillInputProcessor:handleLockTargetActionCanceled()
	end
end

function MobileAimUIComponent:cancelLock(isPress)
	local mobileSkill = pg.global.ui.hudV2.RD and pg.global.ui.hudV2.RD.mobileSkill

	if mobileSkill and mobileSkill.uWidget then
		local _, page = mobileSkill.uWidget:TryGetCurrentPage("Synopsis")

		if page == 2 then
			return
		end
	end

	pg.game.controller.lockHelper:cancelLockTarget()
end

function MobileAimUIComponent:onQuestStateChanged(info)
	if info.questId == Const.AIM_TARGET_QUEST_ID and info.state == QuestConst.QUEST_STATE.COMPLETED then
		self:refreshAimBtnState()
	end
end

function MobileAimUIComponent:refreshAimBtnState()
	if not self.aimBtn then
		return
	end

	local visible = true

	if not QuestUtils.isQuestFinished(Const.AIM_TARGET_QUEST_ID) then
		visible = false
	end

	if self.ctrl and self.ctrl.quickChat and self.ctrl.quickChat.gameObject and self.ctrl.quickChat.gameObject.activeSelf then
		visible = false
	end

	self.aimBtn.renderOpacity = visible and 1 or 0
end

function MobileAimUIComponent:onLockedTargetChange()
	if not self.uWidget then
		return
	end

	local inCatchMode = false
	local mobileSkill = pg.global.ui.hudV2.RD and pg.global.ui.hudV2.RD.mobileSkill

	if mobileSkill and mobileSkill.uWidget then
		local _, page = mobileSkill.uWidget:TryGetCurrentPage("Synopsis")

		inCatchMode = page == 2
	end

	if not inCatchMode then
		local expand = pg.game.controller.lockHelper.forceLockActorId ~= 0 and 1 or 0

		self.uWidget:TryChangePage("expand", expand)
	end
end

function MobileAimUIComponent:onCatchModeChange(enable)
	if self.uWidget then
		local showAim = not enable

		self.uWidget:SetActive(showAim)

		if showAim then
			local expand = pg.game.controller.lockHelper.forceLockActorId ~= 0 and 1 or 0

			self.uWidget:TryChangePage("expand", expand)
		end
	end
end

function MobileAimUIComponent:onDestroy()
	HudBaseComponent.onDestroy(self)
end

function MobileAimUIComponent:playShowAnim()
	if self.uWidget then
		self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.Show)
	end
end

function MobileAimUIComponent:playHideAnim()
	if self.uWidget then
		self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.Hide)
	end
end

return MobileAimUIComponent
