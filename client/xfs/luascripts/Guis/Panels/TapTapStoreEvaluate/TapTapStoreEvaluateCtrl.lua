-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TapTapStoreEvaluate\\TapTapStoreEvaluateCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TapTapStoreEvaluateCtrl = Class.LightClass("TapTapStoreEvaluateCtrl", UICtrl)
local STAR_SCORES = {
	{
		score = 1
	},
	{
		score = 2
	},
	{
		score = 3
	},
	{
		score = 4
	},
	{
		score = 5
	}
}
local STORE_GRADE_SCORE = 4

function TapTapStoreEvaluateCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.selectedScore = 0

	ClientTextUtils.setText(self.view.titleText, pg.getGameString("feedback_us_01"))
	ClientTextUtils.setText(self.view.contextText, pg.getGameString("feedback_us_02"))
	ClientTextUtils.setText(self.view.cancelText, pg.getGameString("feedback_us_03"))
	ClientTextUtils.setText(self.view.confirmText, pg.getGameString("feedback_us_04"))
end

function TapTapStoreEvaluateCtrl:addListener()
	function self.view.listUList.luaRenderItem(button, index, data)
		button:TryChangePage("State", data.score <= self.selectedScore and "light" or "grey")
	end

	function self.view.listUList.luaClick(button, data)
		self:selectScore(data.score)
	end

	function self.view.cancelBtn.luaClick()
		self:dismiss()
	end

	function self.view.confirmBtn.luaClick()
		self:onConfirm()
	end

	self:bindCloseButton(self.view.cancelBtn)
end

function TapTapStoreEvaluateCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.selectedScore = 0

	self.view.listUList:SetList(STAR_SCORES)
end

function TapTapStoreEvaluateCtrl:selectScore(score)
	local oldScore = self.selectedScore

	self.selectedScore = score

	for changedScore = math.min(oldScore, score) + 1, math.max(oldScore, score) do
		self.view.listUList:RefreshElement(changedScore - 1)
	end
end

function TapTapStoreEvaluateCtrl:onConfirm()
	if self.selectedScore >= STORE_GRADE_SCORE then
		pg.global.sdkManager:getTapTapStoreGrade()
	end

	self:dismiss()
end

return TapTapStoreEvaluateCtrl
