-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\EventPetSaveManual\\EventPetSaveManualView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local EventPetSaveManualView = Class.LightClass("EventPetSaveManualView", UIView)

function EventPetSaveManualView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.btnClose = self.objectReference:GetRefValue("btnBackUButton")
	self.btnInfo = self.objectReference:GetRefValue("btnInfoUButton")
	self.btnPrev = self.objectReference:GetRefValue("btnPrevUButton")
	self.btnNext = self.objectReference:GetRefValue("btnNextUButton")
	self.listManualUList = self.objectReference:GetRefValue("listManualUList")
	self.listRewardUList = self.objectReference:GetRefValue("listRewardUList")
	self.txtNumUBaseText = self.objectReference:GetRefValue("txtNumUBaseText")
	self.txtEmptyUBaseText = self.objectReference:GetRefValue("txtEmptyUBaseText")
end

function EventPetSaveManualView:registerObjects()
	return
end

function EventPetSaveManualView:initView()
	return
end

return EventPetSaveManualView
