-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\MobileHpFuseUIComponent.lua

local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local BuffUIUtils = require("Utils.BuffUIUtils")
local SysConfigData = require("Data.sys_config_data")
local ClientConst = require("Const.ClientConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local HpFuseUIComponent = require("Guis.Panels.HudV2.BaseComponent.HpFuseUIComponent")
local HpUIComponent = require("Guis.Panels.HudV2.BaseComponent.HpUIComponent")
local Class = require("Core.Framework.Class")
local MobileHpFuseUIComponent = Class.LightClass("MobileHpFuseUIComponent", HpUIComponent)
local Utils = require("Common.Utils.Utils")
local MessageName = require("Const.MessageName")
local TimerManager = require("Core.Timer.TimerManager")
local ClientUtils = require("Utils.ClientUtils")
local PET_TIP = "PetTip"

function MobileHpFuseUIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.panel = objectReference:GetRefValue("panel")
	self.possessedBtn = objectReference:GetRefValue("btnHeadUButton")
	self.fuseText = objectReference:GetRefValue("fuseText")
	self.hPFuseUContainer = objectReference:GetRefValue("hPFuseUContainer")
	self.petTip = objectReference:GetRefValue("petTip")
end

function MobileHpFuseUIComponent:initView()
	self.visibleData = self.visibleData or {}

	if pg.me and pg.me.inTeammateView then
		self.visibleData.teammateView = false
	else
		self.visibleData.teammateView = nil
	end

	function self.possessedBtn.luaPress()
		self:shapeShifting()
	end

	self.hPFuseUContainer.defaultUrl = "$UI_Node_HUD_HP.prefab"

	if not self.hPFuseUContainer:CheckURLLoaded() then
		self.hPFuseUContainer:LoadDefaultUrlManually(function(content)
			self:onHealBarLoaded(content)
		end)
	else
		self:onHealBarLoaded(self.hPFuseUContainer.content)
	end

	self:preRefreshFuseBtn()

	self.buffDisappearHintTimer = {}

	self:tryConsumeQuickEnterControlMode()
end

function MobileHpFuseUIComponent:onTeammateViewChange()
	MobileHpFuseUIComponent.super.onTeammateViewChange(self)
	self:setFuseBtnVisible("teammateView", not pg.me.inTeammateView)
end

function MobileHpFuseUIComponent:onHealBarLoaded(content)
	local objectReference = content:GetComponent("ObjectReference")

	self.rootComponent = objectReference:GetRefValue("rootComponent")
	self.myHp = objectReference:GetRefValue("myHp")
	self.myHpText = objectReference:GetRefValue("myHpText")
	self.myShield = objectReference:GetRefValue("myShield")
	self.buffUList = objectReference:GetRefValue("buffUList")
	self.epListUList = objectReference:GetRefValue("epListUList")
	self.breakUHealthbar = objectReference:GetRefValue("breakUHealthbar")
	self.breakUCountDown = objectReference:GetRefValue("breakUCountDown")
	self.bloodUComponent = objectReference:GetRefValue("bloodUComponent")
	self.changeBossHpUContainer = objectReference:GetRefValue("changeBossHpUContainer")
	self.barDeadHPUHealthbar = objectReference:GetRefValue("barDeadHPUHealthbar")
	self.normalUWidget = objectReference:GetRefValue("normalUWidget")
	self.breakCountDown = objectReference:GetRefValue("breakUCountDown")
	self.vxCountdownAnimation = objectReference:GetRefValue("vxCountdownAnimation")
	self.breakCountDownBarBreak = objectReference:GetRefValue("barBreakUHealthbar")
	self.oneBallEpValue = SysConfigData.EP_VALUE_PER_BALL or 1
	self.epBalls = {}
	self.specialTempEpBalls = {}
	self.finalEpBalls = {}
	self.dirtyEpIndex = {}
	self.specialTempEpBallBuffData = {}

	function self.buffUList.luaRenderItem(button, index, data)
		BuffUIUtils.setBuffInfo(button, data)
	end

	function self.buffUList.luaClick(button, data)
		local info = data

		info.targetRect = button
		info.autoVer = true

		pg.global.ui:open(UIConst.UI_ID_COMMON_BUFF_INFO_TIP, info)
	end

	if self.epListUList then
		function self.epListUList.luaRenderItem(button, index, data)
			button:TryChangePage("state", data.state)

			button:GetChild("Progress"):GetComponent("UImage").fillAmount = data.progress
		end
	end

	self:refreshStatusVisible(true)
	self:initFuseState()
	self:refreshStatus()
	self:onExtraTempPetStateChange()

	if pg.me and pg.me.EXTRA_TEMP_PET_ST and pg.me:EXTRA_TEMP_PET_ST() then
		self:refreshEpBoss()
	end

	if Utils.isPlayer(pg.pawn) then
		self:onControlChanged(false)
	else
		self:onControlChanged(true)
	end
end

function MobileHpFuseUIComponent:refreshPossessedState()
	if not self.uWidget then
		return
	end

	local pawn = pg.pawn
	local isControllingEgg = pg.me:isControllingEgg()
	local controllingPetState = not Utils.isPlayer(pawn) or not not isControllingEgg

	if self.controllingPetState ~= controllingPetState then
		self.controllingPetState = controllingPetState

		self.uWidget:TryChangePage("FuseState", controllingPetState and 1 or 0)
		self:refreshFuseText(controllingPetState)
	end
end

function MobileHpFuseUIComponent:onCombatPetChange()
	MobileHpFuseUIComponent.super.onCombatPetChange(self)

	if not self:isHomeLand() then
		self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.User1)

		local curPetEntity = pg.me:getCurPetEntity()
		local bloodUComponentVisible = ToBool(curPetEntity) and not pg.me:EXTRA_TEMP_PET_ST()

		if self.bloodUComponent and self.bloodUComponentVisible ~= bloodUComponentVisible then
			self.bloodUComponentVisible = bloodUComponentVisible

			LuaUIUtils.setUIVisible(self.bloodUComponent, bloodUComponentVisible)
		end

		self:setEpListVisible(bloodUComponentVisible)
	end
end

function MobileHpFuseUIComponent:triggerSwitchFailedEffect()
	return
end

function MobileHpFuseUIComponent:refreshCanCombine()
	if not self.rootComponent then
		return
	end

	if not pg.game:checkModuleEnable(ClientConst.ModuleKey.PetLink) then
		self.rootComponent:TryChangePage("canCombine", 2)

		return
	end

	if not self:isHomeLand() then
		self.rootComponent:TryChangePage("canCombine", 0)
	else
		local canCombine = self.canSwitch and pg.me:checkPetControlUnlock()

		self.rootComponent:TryChangePage("canCombine", canCombine and 0 or 1)
	end
end

function MobileHpFuseUIComponent:hideQuickLinkPromptAnim(result)
	self:_killQuickLinkProgressAnim()
end

function MobileHpFuseUIComponent:exitQuickLinkRunningAnim()
	self.panel:TryChangePage(PET_TIP, 0)
end

function MobileHpFuseUIComponent:showQuickLinkPromptAnim(info)
	self.panel:TryChangePage(PET_TIP, 1)
end

function MobileHpFuseUIComponent:cancelQuickLinkOnTimeoutAnim()
	self.panel:TryChangePage(PET_TIP, 0)
end

function MobileHpFuseUIComponent:killQuickLinkOnCombatAnim()
	self:_killQuickLinkProgressAnim()
end

function MobileHpFuseUIComponent:_killQuickLinkProgressAnim()
	if self.petTip.content then
		local objectReference = self.petTip.content.transform:GetComponent("ObjectReference")
		local progress = objectReference:GetRefValue("progress")

		progress:KillProcessAnim()
	end

	self.panel:TryChangePage(PET_TIP, 0)
end

function MobileHpFuseUIComponent:onInteractGestureStateChanged()
	if pg.game.social.interactGestureComponent:checkInteractGesturePlaying() then
		self:hide()
	else
		self:show()
	end
end

function MobileHpFuseUIComponent:onDestroy()
	MobileHpFuseUIComponent.super.onDestroy(self)

	if self.teammateViewTimer then
		TimerManager.removeTimer(self.teammateViewTimer)

		self.teammateViewTimer = nil
	end
end

function MobileHpFuseUIComponent:playShowAnim()
	if self.uWidget then
		self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.Show)
	end
end

function MobileHpFuseUIComponent:playHideAnim()
	if self.uWidget then
		self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.Hide)
	end
end

function MobileHpFuseUIComponent:preRefreshFuseBtn()
	LuaUIUtils.setUIVisible(self.possessedBtn, false)
end

return MobileHpFuseUIComponent
