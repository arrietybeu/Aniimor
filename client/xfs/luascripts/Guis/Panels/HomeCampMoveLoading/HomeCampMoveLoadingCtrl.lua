-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCampMoveLoading\\HomeCampMoveLoadingCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeCampVisitCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local HomeCampData = require("Data.home_camp_data")
local PlayerHeadIconData = require("Data.player_head_icon_data")
local FriendshipLevelData = require("Data.friendship_level_data")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local Time = require("Core.Common.Time")
local HomeCampMoveLoadingCtrl = Class.LightClass("HomeCampMoveLoadingCtrl", UICtrl)

function HomeCampMoveLoadingCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:startLoadTimer()
end

function HomeCampMoveLoadingCtrl:addListener()
	return
end

function HomeCampMoveLoadingCtrl:onDestroy()
	if self.closeTimer then
		self:killTimer(self.closeTimer)

		self.closeTimer = nil
	end

	self.successMark = nil

	UICtrl.onDestroy(self)
end

function HomeCampMoveLoadingCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	if self.view.txtTipsUSDFText then
		ClientTextUtils.setText(self.view.txtTipsUSDFText, pg.getGameString("HOME_CAMP_MOVE_DESC"))
	end
end

function HomeCampMoveLoadingCtrl:startLoadTimer()
	if self.closeTimer then
		self:killTimer(self.closeTimer)

		self.closeTimer = nil
	end

	self.startTime = Time.realSecondCache
	self.closeTimer = self:startTimer(function()
		self:tickAndClose()
	end, 0.1, true)
end

function HomeCampMoveLoadingCtrl:tickAndClose()
	if self.successMark then
		if Time.realSecondCache - self.startTime > 6 then
			self:close()

			return
		end
	elseif Time.realSecondCache - self.startTime > 10 then
		self:close()

		return
	end

	self:setProgress((Time.realSecondCache - self.startTime) / 5.5)
end

function HomeCampMoveLoadingCtrl:onChangeCampSuccess()
	if self.view then
		self.successMark = true
	end

	pg.me:enterSelfHomeCamp()
end

function HomeCampMoveLoadingCtrl:setProgress(progress)
	if progress >= 1 then
		progress = 1
	end

	if self.view ~= nil and self.view.progressLoad then
		self.view.progressLoad.value = tonumber(progress)
	end
end

function HomeCampMoveLoadingCtrl:checkUIShowVirtualMouseCursor()
	return false
end

return HomeCampMoveLoadingCtrl
