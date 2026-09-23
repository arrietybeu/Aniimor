-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SkipPanel\\SkipPanelCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("SkipPanelCtrl")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local TimelineDataInfo = require("Data.timeline_info_data")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local MessageName = require("Const.MessageName")
local HotkeyConst = require("Const.HotkeyConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local GameStringConfig = require("Data.gamestring_config_data")
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")
local Time = require("Core.Common.Time")
local SkipPanelCtrl = Class.LightClass("SkipPanelCtrl", UICtrl)

SkipPanelCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

local timerDic = {}

function SkipPanelCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function SkipPanelCtrl:addListener()
	function self.view.btnSkipUButton.luaClick()
		if not self.canSkip then
			return
		end

		if self.info.startSkipFunc then
			self.info.startSkipFunc()
		end

		if string.isNilOrEmpty(self.info.skipInfoKey) then
			self:dismiss()

			if self.info.skipFunc then
				self.info.skipFunc()
			end

			return
		end

		local msgInfo = TimelineDataInfo[self.info.skipInfoKey] or TimelineDataInfo[string.format("$%s.prefab", self.info.skipInfoKey)]

		if msgInfo == nil and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("找不到对应的跳过文本信息！", tostring(self.info.skipInfoKey))
		end

		local title = msgInfo and pg.getGameString(msgInfo.title) or ""
		local msg = msgInfo and pg.getGameString(msgInfo.msg) or "内容没有配置！！"

		self.isShowConfirmMsg = true

		local function onSupersededCb()
			self.isShowConfirmMsg = false

			DialogueGraphUtils.resumeGame(Const.GameTimeScaleType.CUTSCENE)
		end

		DialogueGraphUtils.pauseGame(Const.GameTimeScaleType.CUTSCENE)
		pg.global.ui.dialogueSkip:openConfirm(title, msg, function()
			onSupersededCb()
			self:dismiss()

			if self.info.skipFunc then
				self.info.skipFunc()
			end
		end, false, function()
			onSupersededCb()

			if self.info.cancelSkipFunc then
				self.info.cancelSkipFunc()
			end
		end, false, nil, {
			onSupersededCb = onSupersededCb
		})
	end

	self:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadStart, function()
		self.view.btnSkipUButton.luaClick()
	end, self.view.btnSkipUButton.gameObject, HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadStart)
	self:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.KeyBoardCancel, function()
		self.view.btnSkipUButton.luaClick()
	end, self.view.btnSkipUButton.gameObject, HotkeyConst.INPUT_MAP_ACTION_KEY.KeyBoardCancel)
end

function SkipPanelCtrl:onShow()
	return
end

function SkipPanelCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.info = info

	self:SetInfo(info)
end

function SkipPanelCtrl:SetInfo(info)
	self:clearAllTimers()

	if info.skipState == 1 then
		self.canSkip = false

		ClientTextUtils.setText(self.view.confirmBtnText, pg.getLocalizationText(GameStringConfig.skipCountDownId))
		self:addShowBtn(info.skipTime)
	else
		self:SetSkip()
	end
end

function SkipPanelCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function SkipPanelCtrl:onInputDeviceChanged(deviceType)
	return
end

function SkipPanelCtrl:addShowBtn(skipTime)
	skipTime = skipTime or 0

	if pg.me then
		self.skipShowTime = pg.me:getGameTime() + skipTime
	else
		self.skipShowTime = Time.time + skipTime
	end

	local delta = 0

	if skipTime < 0.1 then
		-- block empty
	else
		self:countDownBtn()
	end
end

function SkipPanelCtrl:countDownBtn()
	timerDic.countdown = self:startScaleTimer(function()
		local diff = 0

		if pg.me then
			diff = self.skipShowTime - pg.me:getGameTime()
		else
			diff = self.skipShowTime - Time.time
		end

		if diff > 0.01 then
			self.view.btnSkipUButton:TryChangePage("SkipState", 1)
			LuaUIUtils.setUIVisible(self.view.btnSkipUButton, true)
			ClientTextUtils.setText(self.view.txtNameUSDFText, ClientTextUtils.getLocalizationText(GameStringConfig.skipCountDownId.desc, math.ceil(diff)))
		elseif timerDic.countdown then
			self:killScaleTimer(timerDic.countdown)

			timerDic.countdown = nil
		end
	end, 0.1, true)
end

function SkipPanelCtrl:SetSkip()
	self.canSkip = true

	LuaUIUtils.setUIVisible(self.view.btnSkipUButton, true)
	ClientTextUtils.setText(self.view.txtNameUSDFText, pg.getGameString("CONSOLE_BAR_SKIP"))
	self.view.btnSkipUButton:TryChangePage("SkipState", 0)
end

function SkipPanelCtrl:clearAllTimers()
	for _, timer in pairs(timerDic) do
		self:killScaleTimer(timer)
	end

	timerDic = {}
end

function SkipPanelCtrl:onDestroy()
	UICtrl.onDestroy(self)
	self:clearAllTimers()
	DialogueGraphUtils.resumeGame(Const.GameTimeScaleType.CUTSCENE)

	if self.isShowConfirmMsg == true and pg.global.ui.dialogueSkip then
		pg.global.ui.dialogueSkip:close()
	end
end

return SkipPanelCtrl
