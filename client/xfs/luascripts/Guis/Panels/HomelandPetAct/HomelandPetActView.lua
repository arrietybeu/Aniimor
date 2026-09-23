-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandPetAct\\HomelandPetActView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomelandPetActView = Class.LightClass("HomelandPetActView", UIView)

function HomelandPetActView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.txtDetailsUBaseText = self.objectReference:GetRefValue("txtDetailsUBaseText")
	self.reportListUList = self.objectReference:GetRefValue("reportListUList")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
	self.logListUList = self.objectReference:GetRefValue("logListUList")
	self.uIPbHomePetReportIn = self.objectReference:GetRefValue("uIPbHomePetReportIn")
	self.btnNotFinishUButton = self.objectReference:GetRefValue("btnNotFinishUButton")
	self.imgSelectedNotFinish = self.objectReference:GetRefValue("imgSelectedNotFinish")
	self.btnFinishUButton = self.objectReference:GetRefValue("btnFinishUButton")
	self.imgSelectedFinish = self.objectReference:GetRefValue("imgSelectedFinish")
	self.emptyUWidget = self.objectReference:GetRefValue("emptyUWidget")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.emojiUContainer = self.objectReference:GetRefValue("emojiUContainer")
	self.tabOffline = self.objectReference:GetRefValue("tabOffline")
	self.tabPetAct = self.objectReference:GetRefValue("tabPetAct")
	self.listRewardUList = self.objectReference:GetRefValue("listRewardUList")
	self.emptyOffline = self.objectReference:GetRefValue("emptyOffline")
end

function HomelandPetActView:registerObjects()
	return
end

function HomelandPetActView:initView()
	if pg.global.platform:isPS() then
		self.btnCloseUButton.gameObject:SetActiveEx(false)
	end
end

return HomelandPetActView
