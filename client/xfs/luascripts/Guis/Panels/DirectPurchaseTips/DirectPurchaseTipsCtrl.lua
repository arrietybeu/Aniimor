-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DirectPurchaseTips\\DirectPurchaseTipsCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local DirectPurchaseTipsCtrl = Class.LightClass("DirectPurchaseTipsCtrl", UICtrl)
local AUTO_DISMISS_SECONDS = 5

DirectPurchaseTipsCtrl.messages = {}

function DirectPurchaseTipsCtrl:ctor()
	UICtrl.ctor(self)
end

function DirectPurchaseTipsCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	local target = info and info.target

	ClientTextUtils.setText(self.view.titleUSDFText, pg.getGameString("Office_pay_tips1"))

	local remainingSeconds = AUTO_DISMISS_SECONDS

	ClientTextUtils.setText(self.view.tipsUSDFText, pg.getFormatText(pg.getGameString("Office_pay_tips2"), remainingSeconds))

	local targetTransform = target and target.transform

	if targetTransform then
		self.view.transform.position = targetTransform.position
	end

	self:addListener(target)

	self.view.progressUProgress.minValue = 0
	self.view.progressUProgress.maxValue = 1
	self.view.progressUProgress.value = 0

	self.view.progressUProgress:ProgressToValue(1, nil, AUTO_DISMISS_SECONDS, 0, CS.DG.Tweening.Ease.Linear)

	self.autoDismissTimerId = self:startTimer(function()
		remainingSeconds = remainingSeconds - 1

		if remainingSeconds <= 0 then
			self:killTimer(self.autoDismissTimerId)

			self.autoDismissTimerId = nil

			self:dismiss()

			return
		end

		ClientTextUtils.setText(self.view.tipsUSDFText, pg.getFormatText(pg.getGameString("Office_pay_tips2"), remainingSeconds))
	end, 1, true)
end

function DirectPurchaseTipsCtrl:addListener(target)
	function self.view.btnUButton.luaClick()
		self:killTimer(self.autoDismissTimerId)

		self.autoDismissTimerId = nil

		pg.game.recharge:openFirstDirectPurchaseGuide(target)
		self:dismiss()
	end
end

return DirectPurchaseTipsCtrl
