-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\MonthlyCardReward\\MonthlyCardRewardView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local MonthlyCardRewardView = Class.LightClass("MonthlyCardRewardView", UIView)

function MonthlyCardRewardView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.btnClose = objectReference:GetRefValue("btnClose")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.txtTitle = objectReference:GetRefValue("txtTitle")
	self.txtEmpty = objectReference:GetRefValue("txtEmpty")
	self.layoutBoxUWidget = objectReference:GetRefValue("layoutBoxUWidget")
	self.txtLock = objectReference:GetRefValue("txtLock")
	self.txtLockContent = objectReference:GetRefValue("txtLockContent")
	self.btnUWidget = objectReference:GetRefValue("btnUWidget")
	self.btnCancel = objectReference:GetRefValue("btnCancel")
	self.btnClaim = objectReference:GetRefValue("btnClaim")
	self.listReward = objectReference:GetRefValue("listReward")
	self.btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
	self.txtBtnClaim = objectReference:GetRefValue("txtBtnClaim")
end

function MonthlyCardRewardView:registerObjects()
	return
end

function MonthlyCardRewardView:initView()
	return
end

return MonthlyCardRewardView
