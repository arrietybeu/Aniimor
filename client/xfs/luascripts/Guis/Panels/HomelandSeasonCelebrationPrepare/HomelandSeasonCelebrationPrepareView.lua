-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandSeasonCelebrationPrepare\\HomelandSeasonCelebrationPrepareView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomelandSeasonCelebrationPrepareView = Class.LightClass("HomelandSeasonCelebrationPrepareView", UIView)

function HomelandSeasonCelebrationPrepareView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnInviteUButton = objectReference:GetRefValue("btnInviteUButton")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.txtRole = objectReference:GetRefValue("txtRoleUSDFText")
	self.txtTips = objectReference:GetRefValue("txtTipsUSDFText")
	self.txtTitle = objectReference:GetRefValue("txtTitleUSDFText")
	self.listPlayerUList = objectReference:GetRefValue("listPlayerUList")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.btnCancelUButton = objectReference:GetRefValue("btnCancelUButton")

	local objectReference = self.btnConfirmUButton:GetComponent("ObjectReference")

	self.txtConfirm = objectReference:GetRefValue("txtNameUText")

	if self.btnCancelUButton then
		local objectReference = self.btnCancelUButton:GetComponent("ObjectReference")

		self.txtCancel = objectReference:GetRefValue("txtNameUText")
	end
end

function HomelandSeasonCelebrationPrepareView:registerObjects()
	return
end

function HomelandSeasonCelebrationPrepareView:initView()
	return
end

return HomelandSeasonCelebrationPrepareView
