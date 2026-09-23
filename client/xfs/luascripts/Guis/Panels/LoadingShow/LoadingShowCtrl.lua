-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LoadingShow\\LoadingShowCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("LoadingShowCtrl")
local LoggerConst = require("Core.Log.LoggerConst")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LoadingShowCtrl = Class.LightClass("LoadingShowCtrl", UICtrl)
local TimerManager = require("Core.Timer.TimerManager")
local BlackScreenData = require("Data.black_screen_data")
local NpcDialogueData = require("Data.npc_dialogue_data")
local Utils = require("Common.Utils.Utils")
local ClientConst = require("Const.ClientConst")

LoadingShowCtrl.messages = {
	[MessageName.SCENE_LOADED] = {
		"onSceneLoaded",
		true
	}
}

local CHANGE_MODE = {
	AUTO = 0,
	NONAUTO = 1
}

function LoadingShowCtrl:onCreate(info)
	UICtrl.onCreate(self)

	self.SCREEN_IN_ANI = "VX_Pb_WhiteScreen_In"
	self.SCREEN_IN_ANI_TIME = 0.5
	self.SCREEN_OUT_ANI = "VX_Pb_WhiteScreen_Out"
	self.SCREEN_OUT_ANI_TIME = 0.5

	self:addListener()
end

function LoadingShowCtrl:onOpen(info)
	info = info or {}

	self:killAllLoadingTimers()

	self.refreshTimer = nil
	self.deltaTime = 0.03
	self.oldProgress = 0
	self.closeEvent = nil
	self.closeToken = nil
	self.isClosingScreen = false
	self.curDialogIndex = 1
	self.isScanFinished = false
	self.btnCanClose = false
	self.isLoadFinished = false
	self.changeMode = CHANGE_MODE.AUTO
	self.dialogsLength = 0

	self:refresh(info)

	self.isreload = info.isreload
end

function LoadingShowCtrl:onHide()
	self.closeToken = nil

	self:killAllLoadingTimers()
	UICtrl.onHide(self)

	if pg.global.scene.blackScreenId ~= 0 then
		pg.global.scene.blackScreenId = 0
	end
end

function LoadingShowCtrl:onDestroy()
	self.closeToken = nil

	self:killAllLoadingTimers()
	UICtrl.onDestroy(self)
end

function LoadingShowCtrl:tryClosePanel(callback)
	self.closeEvent = callback

	if self.isreload then
		self.isLoadFinished = true

		self:loadCompleted()

		self.isreload = nil
	end
end

function LoadingShowCtrl:refresh(param)
	self.view:setNextBtnVisible(false)

	if param == nil or param.id == nil then
		self:closeScreen(true)

		return
	end

	self.screenConfig = BlackScreenData[param.id]

	if self.screenConfig == nil then
		self:closeScreen(true)

		return
	end

	if self.screenConfig.inOrNot == 1 then
		local blendSpeed = self.screenConfig.inTime and self.screenConfig.inTime ~= 0 and self.screenConfig.inTime / self.SCREEN_IN_ANI_TIME or 1

		UIUtils.PlayAnimation(self.view.mainAni, self.SCREEN_IN_ANI, function()
			self:refreshAll(param)
		end, blendSpeed)
	else
		self:refreshAll(param)
	end
end

function LoadingShowCtrl:refreshAll(param)
	if param.isreload then
		self.view:setLoadProgressVisible(false)
	else
		self.view:setLoadProgressVisible(true)
		self:startLoading()
	end

	self:refreshScreen()
end

function LoadingShowCtrl:refreshScreen()
	local style = self.screenConfig.type or 1

	self.view:changeLoadingStyle(style - 1)

	local dialogueId = self.screenConfig.dialogue

	self.allDialogs = Utils.deepCopyTable(NpcDialogueData[dialogueId])

	if self.allDialogs == nil or #self.allDialogs == 0 then
		self.view:setNextBtnVisible(false)
		self.view:refreshTxtContent("")

		self.changeMode = CHANGE_MODE.AUTO
		self.dialogsLength = 0
	else
		local intervalTime = tonumber(self.screenConfig.intervalTime) or 1

		if intervalTime <= 0 then
			intervalTime = 1
		end

		self.changeMode = self.screenConfig.loadingCompleteClose or CHANGE_MODE.AUTO
		self.dialogsLength = #self.allDialogs

		if self.changeMode == CHANGE_MODE.AUTO then
			self.view:setNextBtnVisible(false)
			self:autoPlayTxt(intervalTime)
		else
			self.isScanFinished = self.curDialogIndex == self.dialogsLength

			self.view:setNextBtnVisible(true)
			self:setNextBtn("CLICK_TO_CONTINUE")
			self:nonAutoPlayTxt()
		end
	end
end

function LoadingShowCtrl:autoPlayTxt(intervalTime)
	self:killTickTimer()
	self:refreshTxtContent()

	self.tickTimer = self:startScaleTimer(function()
		self:onAutoPlayTxt()
	end, intervalTime, true)
end

function LoadingShowCtrl:nonAutoPlayTxt()
	self:refreshTxtContent()
end

function LoadingShowCtrl:onAutoPlayTxt()
	self.curDialogIndex = self.curDialogIndex + 1

	self:clampDialogIndex()
	self:refreshTxtContent()
end

function LoadingShowCtrl:refreshTxtContent()
	if self.allDialogs == nil then
		return
	end

	local curDialog = self.allDialogs[self.curDialogIndex]

	if curDialog then
		self.view:refreshTxtContent(curDialog.chat)
	end
end

function LoadingShowCtrl:clampDialogIndex()
	if self.curDialogIndex > self.dialogsLength then
		self.curDialogIndex = 1
	end
end

function LoadingShowCtrl:startLoading()
	self:killProgressTimer()

	self.ticId = TimerManager.addRepeatTimer(self.deltaTime, function()
		local progress = pg.game.loading:getProgress()

		self:setProgress(progress)
	end)

	local progress = 0

	self:setProgress(progress)
end

function LoadingShowCtrl:setProgress(progress)
	if not progress or progress < self.oldProgress then
		return
	end

	if pg.game.loading.curSceneId == ClientConst.SCENE_LOADING_ID or pg.game.loading.curSceneId == ClientConst.SCENE_LOGIN_ID then
		return
	end

	if progress >= 1 then
		progress = 1
		self.oldProgress = 0

		TimerManager.removeTimer(self.ticId)

		self.ticId = nil
	end

	self.oldProgress = progress

	if self.view ~= nil then
		self.view:updateLoadProgress(progress)
	end
end

function LoadingShowCtrl:addListener()
	function self.view.btnNextUButton.luaClick()
		self:onBtnNextClickHandler()
	end

	function self.view.backGroundCloseUButton.luaClick()
		self:onBtnNextClickHandler()
	end
end

function LoadingShowCtrl:onBtnNextClickHandler()
	if self.btnCanClose then
		self:closeScreen()
	else
		self.curDialogIndex = self.curDialogIndex + 1

		if not self.isScanFinished and self.curDialogIndex >= self.dialogsLength then
			self.isScanFinished = true

			if self.isLoadFinished then
				self:setNextBtn("CLICK_TO_CLOSE")

				self.btnCanClose = true
			end
		end

		self:clampDialogIndex()
		self:nonAutoPlayTxt()
	end
end

function LoadingShowCtrl:setNextBtn(str)
	self.view:setNextBtnTxt(pg.getGameString(str))
	self.view.btnNextUButton:SetHotkeyConsoleBar(str, 1, self.view.consoleBar.transform)
end

function LoadingShowCtrl:loadCompleted()
	if self.changeMode == CHANGE_MODE.AUTO then
		self:closeScreen()
	elseif self.isScanFinished then
		self:setNextBtn("CLICK_TO_CLOSE")

		self.btnCanClose = true
	else
		self:setNextBtn("CLICK_TO_CONTINUE")

		self.btnCanClose = false
	end
end

function LoadingShowCtrl:closeScreen(immediate)
	if self.isClosingScreen then
		return
	end

	self.isClosingScreen = true

	self:killTickTimer()

	local closeToken = {}

	self.closeToken = closeToken

	if not immediate and self.screenConfig ~= nil and self.screenConfig.outOrNot == 1 then
		local blendSpeed = self.screenConfig.outTime and self.screenConfig.outTime ~= 0 and self.screenConfig.outTime / self.SCREEN_OUT_ANI_TIME or 1

		UIUtils.PlayAnimation(self.view.mainAni, self.SCREEN_OUT_ANI, function()
			if self.closeToken ~= closeToken then
				return
			end

			self:closeSelfPanel()
		end, blendSpeed)
	else
		self:closeSelfPanel()
	end
end

function LoadingShowCtrl:closeSelfPanel()
	self:killCloseTimer()
	self:killProgressTimer()

	self.closeToken = nil

	self:dismiss()

	local cb = self.closeEvent

	if cb then
		self.closeEvent = nil

		cb()
	end
end

function LoadingShowCtrl:killProgressTimer()
	if self.ticId ~= nil then
		TimerManager.removeTimer(self.ticId)

		self.ticId = nil
	end
end

function LoadingShowCtrl:killTickTimer()
	if self.tickTimer ~= nil then
		self:killScaleTimer(self.tickTimer)

		self.tickTimer = nil
	end
end

function LoadingShowCtrl:killAllLoadingTimers()
	self:killProgressTimer()
	self:killTickTimer()
	self:killCloseTimer()
end

function LoadingShowCtrl:onSceneLoaded()
	self.isLoadFinished = true

	if self.isClosingScreen then
		return
	end

	self:killCloseTimer()

	self.delayToClosePanelTimer = self:startTimer(function()
		self:loadCompleted()
	end, 0.5)

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("LoadingShowCtrl:onSceneLoaded", self.isLoadFinished)
	end
end

function LoadingShowCtrl:killCloseTimer()
	if self.delayToClosePanelTimer ~= nil then
		self:killTimer(self.delayToClosePanelTimer)

		self.delayToClosePanelTimer = nil
	end
end

function LoadingShowCtrl:checkUIShowVirtualMouseCursor()
	return false
end

return LoadingShowCtrl
