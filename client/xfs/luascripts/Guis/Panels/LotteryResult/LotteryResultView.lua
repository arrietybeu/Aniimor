-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LotteryResult\\LotteryResultView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LotteryResultView = Class.LightClass("LotteryResultView", UIView)

function LotteryResultView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackCloseUButton = LuaUIUtils.safeGetRefValue(objectReference, "btnBackCloseUButton")
	self.rewardName = LuaUIUtils.safeGetRefValue(objectReference, "rewardName")
	self.rewardRarity = LuaUIUtils.safeGetRefValue(objectReference, "rewardRarity")
	self.rewardType = LuaUIUtils.safeGetRefValue(objectReference, "rewardType")
end

function LotteryResultView:setInfo(viewData)
	viewData = viewData or {}

	if self.rewardName then
		ClientTextUtils.setText(self.rewardName, viewData.rewardName or "")
	end

	if self.rewardRarity then
		ClientTextUtils.setText(self.rewardRarity, viewData.rewardRarity or "")
	end

	if self.rewardType then
		ClientTextUtils.setText(self.rewardType, viewData.rewardType or "")
	end
end

return LotteryResultView
