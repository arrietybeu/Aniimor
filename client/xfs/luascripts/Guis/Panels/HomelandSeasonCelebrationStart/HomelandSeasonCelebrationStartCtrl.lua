-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandSeasonCelebrationStart\\HomelandSeasonCelebrationStartCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local TimerManager = require("Core.Timer.TimerManager")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local DEFAULT_PRESENTATION_DURATION = 3
local HomelandSeasonCelebrationStartCtrl = Class.LightClass("HomelandSeasonCelebrationStartCtrl", UICtrl)

HomelandSeasonCelebrationStartCtrl.messages = {}

function HomelandSeasonCelebrationStartCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.presentationDuration = info and info.duration or DEFAULT_PRESENTATION_DURATION
end

function HomelandSeasonCelebrationStartCtrl:addListener()
	return
end

function HomelandSeasonCelebrationStartCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	ClientTextUtils.setText(self.view.txtDetails, pg.getGameString("HOME_SEASON_CELEBRATION_STARTED_TITLE"))
	pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.HOME_SEASON_CELEBRATION, {
		[UIConst.UI_ID_HOME_SEASON_CELEBRATION_START] = true
	})

	self.timerId = TimerManager.addTimer(self.presentationDuration, function()
		self.timerId = nil

		self:close()
	end)
end

function HomelandSeasonCelebrationStartCtrl:onDestroy()
	if self.timerId then
		TimerManager.removeTimer(self.timerId)

		self.timerId = nil
	end

	pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.HOME_SEASON_CELEBRATION)
	UICtrl.onDestroy(self)
end

return HomelandSeasonCelebrationStartCtrl
