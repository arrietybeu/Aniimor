-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetExchangeCountdown\\PetExchangeCountdownCtrl.lua

local CallbackHandler = require("Core.Common.CallbackHandler")
local Time = require("Core.Common.Time")
local Class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local UICtrl = require("Guis.UICtrl")
local PetExchangeCountdownCtrl = Class.LightClass("PetExchangeCountdownCtrl", UICtrl)

PetExchangeCountdownCtrl.messages = {
	[MessageName.PET_EXCHANGE_SYNC_INFO] = {
		"refreshExchangeState",
		true
	},
	[MessageName.PET_EXCHANGE_SYNC_RESULT] = {
		"closeCountdownImmediately",
		true
	}
}

function PetExchangeCountdownCtrl.tryOpen(socialInfo)
	if not socialInfo.isSettling or socialInfo.isSettled or not socialInfo.settleEndTs then
		return
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_PET_EXCHANGE_COUNTDOWN) then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_PET_EXCHANGE_COUNTDOWN, {
		endTs = socialInfo.settleEndTs
	})
end

function PetExchangeCountdownCtrl.openPresentation(info)
	if pg.global.ui:checkUIOpen(UIConst.UI_ID_PET_EXCHANGE_COUNTDOWN) then
		return false
	end

	pg.global.ui:open(UIConst.UI_ID_PET_EXCHANGE_COUNTDOWN, {
		endTs = Time.secondCache + info.duration,
		completeCallback = info.completeCallback
	})

	return true
end

function PetExchangeCountdownCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.info = info

	self.view.btnCancelUButton:SetActive(false)
	self:armConfirmTimer()
end

function PetExchangeCountdownCtrl:armConfirmTimer()
	self:clearConfirmTimer()

	local endTs = self.info.endTs
	local remainTime = math.max(0, endTs - Time.secondCache)
	local timerCallback = CallbackHandler(self, "onConfirmTimer", endTs)

	self.confirmTimer = self:startTimer(timerCallback, remainTime)
end

function PetExchangeCountdownCtrl:onConfirmTimer(endTs)
	self.confirmTimer = nil

	if endTs > Time.secondCache then
		self:armConfirmTimer()

		return
	end

	local completeCallback = self.info.completeCallback

	self:closeCountdownImmediately()

	if completeCallback then
		completeCallback()
	end
end

function PetExchangeCountdownCtrl:clearConfirmTimer()
	if not self.confirmTimer then
		return
	end

	self:killTimer(self.confirmTimer)

	self.confirmTimer = nil
end

function PetExchangeCountdownCtrl:closeCountdownImmediately()
	self:clearConfirmTimer()
	self:closeImmediately()
end

function PetExchangeCountdownCtrl:refreshExchangeState()
	local exchangeInfo = pg.me:getExchangeSocialInfo()

	if not exchangeInfo or not exchangeInfo.isSettling or exchangeInfo.isSettled then
		self:closeCountdownImmediately()
	end
end

return PetExchangeCountdownCtrl
