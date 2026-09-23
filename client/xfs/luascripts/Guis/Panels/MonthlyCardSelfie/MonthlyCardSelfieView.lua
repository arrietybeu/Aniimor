-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\MonthlyCardSelfie\\MonthlyCardSelfieView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local MonthlyCardSelfieView = Class.LightClass("MonthlyCardSelfieView", UIView)

function MonthlyCardSelfieView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnClose = objectReference:GetRefValue("btnClose")
	self.roleUImage = objectReference:GetRefValue("roleUImage")
	self.txtDay = objectReference:GetRefValue("txtDay")
	self.txtMonth = objectReference:GetRefValue("txtMonth")
	self.txtRemainDays = objectReference:GetRefValue("txtRemainDays")
	self.listReward = objectReference:GetRefValue("listReward")
	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.txtTips = objectReference:GetRefValue("txtTips")
end

function MonthlyCardSelfieView:registerObjects()
	return
end

function MonthlyCardSelfieView:initView()
	ClientTextUtils.setText(self.txtTips, pg.getGameString("MONTH_CARD_FACIAL_REWARD"))
end

return MonthlyCardSelfieView
