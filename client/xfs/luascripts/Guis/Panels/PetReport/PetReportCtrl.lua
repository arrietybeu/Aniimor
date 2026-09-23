-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetReport\\PetReportCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local CoinReportComponent = require("Guis.Panels.PetReport.Component.CoinReportComponent")
local NoticeDef = require("Common.NoticeDef")
local ResearchPointReportComponent = require("Guis.Panels.PetReport.Component.ResearchPointReportComponent")
local CommonSwitch = require("Common.CommonSwitch")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UICtrl = require("Guis.UICtrl")
local PetReportCtrl = Class.LightClass("PetReportCtrl", UICtrl)
local logger = require("Core.Log.LoggerManager").getLogger("PetReportACtrl")

PetReportCtrl.messages = {}

function PetReportCtrl:onCreate(info)
	info = info or {}

	self.model:setReportData(info)
	UICtrl.onCreate(self, info)

	self.coinReport = CoinReportComponent.new(self, self.view.getCoinsPanelUWidget)
	self.researchReport = ResearchPointReportComponent.new(self, self.view.researchPointsPanelUWidget)
	self.loadingPanel = self.view.widget:GetChild("LoadingPanel")
end

function PetReportCtrl:addListener()
	function self.view.btnEnterUButton.luaClick()
		self.model:sendOpenedRPC()
		self.view.widget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)

		if self.model.reportMoney and self.model.reportMoney > 0 then
			self.view.widget:TryChangePage("PanelState", 1)
			LuaUIUtils.setUIVisible(self.view.consoleBarTransform, false)
			self:startTimer(function()
				self.coinReport:onSwitchThisPage()
			end, 1)
		elseif self.model.hasAnyPoint then
			self.view.widget:TryChangePage("PanelState", 2)
			LuaUIUtils.setUIVisible(self.view.consoleBarTransform, false)
			self.coinReport:onExitThisPage()
			self:startTimer(function()
				self.researchReport:onSwitchThisPage()
			end, 0.5)
		else
			self:dismiss()
		end
	end

	self:bindHotKeyPerform("Raw/GamepadButtonSouth", function()
		self.view.btnEnterUButton:OnClickSimulate()
	end, self.view.btnEnterUButton.gameObject)
	LuaUIUtils.setCommonConsoleBarList(self.view.consoleBarTransform, {
		right = {
			{
				path = "Raw/GamepadButtonSouth",
				label = pg.getGameString("CONSOLE_BAR_SUBMIT")
			}
		}
	})

	self.tickTimer = self:startTimer(function()
		self:update()
	end, 0.01, true)

	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.NavManager.Instance:AddLuaFocusCursorMovedListener("PetReport", function()
			self:refreshConsoleBarState()
		end)
	end
end

function PetReportCtrl:refreshConsoleBarState()
	if CS.XGUI.Navigation.NavManager.Instance then
		local vxCompleted = true
		local isCoinReporting = self.coinReport and self.coinReport.uWidget and self.coinReport.uWidget.bActive
		local isResearchReporting = self.researchReport and self.researchReport.uWidget and self.researchReport.uWidget.bActive

		if isCoinReporting then
			vxCompleted = self.coinReport.vxIsCompleted
		elseif isResearchReporting then
			vxCompleted = self.researchReport.vxIsCompleted
		end

		local isInPlaying = not vxCompleted and self.loadingPanel and not self.loadingPanel.bActive or false

		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("isInLoading", self.loadingPanel and self.loadingPanel.bActive)
		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("isInPlaying", isInPlaying)
		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("isViewReporting", isResearchReporting)
	end
end

function PetReportCtrl:update()
	self:refreshConsoleBarState()
end

function PetReportCtrl:onDestroy()
	if self.tickTimer then
		self:killTimer(self.tickTimer)

		self.tickTimer = nil
	end

	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.NavManager.Instance:RemoveLuaFocusCursorMovedListener("PetReport")
	end

	UICtrl.onDestroy(self)
	self.coinReport:onExitThisPage()
	self.researchReport:onExitThisPage()

	self.coinReport = nil
	self.researchReport = nil
end

function PetReportCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function PetReportCtrl:dismiss()
	if not CommonSwitch.PET_REPORT then
		pg.global.showBubbleMessage(NoticeDef.COMMON_SWITCH_CLOSE_TIP)
	else
		self.model:sendRpc()
	end

	self.model.reportMoney = nil
	self.model.hasAnyPoint = nil

	local res, pageIndex = self.view.widget:TryGetCurrentPage("PanelState")
	local index = res and pageIndex or 1
	local animName = index == 1 and "UI_Ani_PetManual_SubmitPetReport_GetCoins_End" or "UI_Ani_PetManual_SubmitPetReport_Points_End"
	local anim = self.view.widget:GetComponent("Animation")

	UIUtils.PlayAnimation(anim, animName, function()
		UICtrl.dismiss(self)
	end)
end

function PetReportCtrl:onShow()
	return
end

function PetReportCtrl:onHide()
	return
end

function PetReportCtrl:checkUIShowVirtualMouseCursor()
	return false
end

return PetReportCtrl
