-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Accusation\\AccusationView.lua

local logger = require("Core.Log.LoggerManager").getLogger("AccusationView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local AccusationView = Class.LightClass("AccusationView", UIView)

function AccusationView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.txtTitle = objectReference:GetRefValue("txtTitle")
	self.txtNameTitle = objectReference:GetRefValue("txtNameTitle")
	self.txtName = objectReference:GetRefValue("txtName")
	self.txtDescTitle = objectReference:GetRefValue("txtDescTitle")
	self.txtDescInput = objectReference:GetRefValue("txtDescInput")
	self.txtTypeTitle = objectReference:GetRefValue("txtTypeTitle")
	self.txtTypeInput = objectReference:GetRefValue("txtTypeInput")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.txtConfirm = objectReference:GetRefValue("txtConfirm")
	self.txtNum = objectReference:GetRefValue("txtNum")
	self.listUList = objectReference:GetRefValue("listUList")
	self.txtDescPlaceHolder = objectReference:GetRefValue("txtDescPlaceHolder")
	self.txtTypePlaceHolder = objectReference:GetRefValue("txtTypePlaceHolder")
	self.tipsUWidget = objectReference:GetRefValue("tipsUWidget")
	self.txtTipsUSDFText = objectReference:GetRefValue("txtTipsUSDFText")
end

function AccusationView:registerObjects()
	return
end

function AccusationView:initView()
	return
end

function AccusationView:refreshInputLimit(currentLen, maxLen)
	if self.txtNum then
		ClientTextUtils.setText(self.txtNum, string.format("%d/%d", currentLen, maxLen))
	end
end

return AccusationView
