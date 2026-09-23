-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DialogueSkip\\DialogueSkipCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("CommonSkipCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local HotkeyConst = require("Const.HotkeyConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local DialogueGraphSkipData = require("Data.dialogue_graph_skip_data")
local DialogueGraphConst = require("Const.DialogueGraphConst")
local UICtrl = require("Guis.UICtrl")
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local DialogueSkipCtrl = Class.LightClass("DialogueSkipCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientConst = require("Const.ClientConst")
local TimerManager = require("Core.Timer.TimerManager")

function DialogueSkipCtrl:onHide()
	return
end

function DialogueSkipCtrl:onCreate(...)
	DialogueSkipCtrl.super.onCreate(self, ...)

	function self.view.btnGoonUButton.luaClick()
		self:OnGoon()
	end

	function self.view.btnSkipUButton.luaClick()
		self:OnSkip()
	end
end

function DialogueSkipCtrl:onOpen(info)
	if self.onSupersededCb then
		local cb = self.onSupersededCb

		self.onSupersededCb = nil

		cb()
	end

	UICtrl.onOpen(self, info)
	self:showConfirm(info.title, info.desc, info.okCb, info.hideCancel, info.cancelCb, info.showNextBtn, info.nextBtnCb, info.extraInfo, info.tickFunc, info.tickInterval)
end

function DialogueSkipCtrl:onDestroy(...)
	UICtrl.onDestroy(self, ...)
end

function DialogueSkipCtrl:openConfirm(title, desc, okCb, hideCancel, cancelCb, showNextBtn, nextBtnCb, extraInfo, tickFunc, tickInterval)
	if pg.game.camera.worldCameraDisableInfo[ClientConst.CameraDisableReason.Cutscene] ~= nil then
		self.hadEnableWCamera = true

		pg.game.camera:setWorldCameraEnable(true, ClientConst.CameraDisableReason.Cutscene)
	end

	self:open({
		title = title,
		desc = desc,
		okCb = okCb,
		hideCancel = hideCancel,
		cancelCb = cancelCb,
		showNextBtn = showNextBtn,
		nextBtnCb = nextBtnCb,
		extraInfo = extraInfo,
		tickFunc = tickFunc,
		tickInterval = tickInterval
	})
end

function DialogueSkipCtrl:showConfirm(title, desc, okCb, hideCancel, cancelCb, showNextBtn, nextBtnCb, extraInfo, tickFunc, tickInterval)
	ClientTextUtils.setText(self.view.titleText, pg.getLocalizationText(title or ""))
	ClientTextUtils.setText(self.view.scrollContent.content, pg.getLocalizationText(desc or ""))

	if extraInfo and extraInfo.okBtnDesc then
		ClientTextUtils.setText(self.view.btnSkipText, extraInfo.okBtnDesc)
	else
		ClientTextUtils.setText(self.view.btnSkipText, pg.getGameString("DIALOGUE_SKIP"))
	end

	if extraInfo and extraInfo.cancelBtnDesc then
		ClientTextUtils.setText(self.view.btnGoonText, extraInfo.cancelBtnDesc)
	else
		ClientTextUtils.setText(self.view.btnGoonText, pg.getGameString("DIALOGUE_CONTINUE_READ"))
	end

	self.goonCall = cancelCb
	self.skipCall = okCb

	local showBgBlur

	showBgBlur = true

	if self.view.bgBlurUWidget and self.view.bgBlurUWidget.SetActive then
		self.view.bgBlurUWidget:SetActive(showBgBlur)
	end

	if self.hadEnableWCamera then
		-- block empty
	end
end

function DialogueSkipCtrl:OnGoon()
	local goonCall = self.goonCall

	self.goonCall = nil

	self:close()

	if goonCall ~= nil then
		goonCall()
	end
end

function DialogueSkipCtrl:OnSkip()
	local skipCall = self.skipCall

	self.skipCall = nil

	self:close()

	if skipCall ~= nil then
		skipCall()
	end
end

return DialogueSkipCtrl
