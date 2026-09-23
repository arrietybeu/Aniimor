-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CatchRogueEntry\\CatchRogueEntryView.lua

local logger = require("Core.Log.LoggerManager").getLogger("CatchRogueEntryView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local CatchRogueEntryView = Class.LightClass("CatchRogueEntryView", UIView)

function CatchRogueEntryView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootComponent = self.objectReference:GetRefValue("rootComponent")
	self.pet1UContainer = self.objectReference:GetRefValue("pet1UContainer")
	self.pet2UContainer = self.objectReference:GetRefValue("pet2UContainer")
	self.pet3UContainer = self.objectReference:GetRefValue("pet3UContainer")
	self.pet4UContainer = self.objectReference:GetRefValue("pet4UContainer")
	self.pet5UContainer = self.objectReference:GetRefValue("pet5UContainer")
	self.pet6UContainer = self.objectReference:GetRefValue("pet6UContainer")
	self.textTitleUBaseText = self.objectReference:GetRefValue("textTitleUBaseText")
	self.listElementUList = self.objectReference:GetRefValue("listElementUList")
	self.catchPetBtnInfo = self.objectReference:GetRefValue("catchPetBtnInfo")
	self.catchPetUList = self.objectReference:GetRefValue("catchPetUList")
	self.rewardBtnInfo = self.objectReference:GetRefValue("rewardBtnInfo")
	self.rewardUList = self.objectReference:GetRefValue("rewardUList")
	self.textTipsRemainUBaseText = self.objectReference:GetRefValue("textTipsRemainUBaseText")
	self.btnComfirmUButton = self.objectReference:GetRefValue("btnComfirmUButton")
	self.specialItemUList = self.objectReference:GetRefValue("specialItemUList")
	self.shopBtn = self.objectReference:GetRefValue("shopBtn")
	self.specialItemNumTxt = self.objectReference:GetRefValue("specialItemNumTxt")
	self.commonItemUList = self.objectReference:GetRefValue("commonItemUList")
	self.commonItemBtnInfoUButton = self.objectReference:GetRefValue("commonItemBtnInfoUButton")
	self.commonItemNumTxt = self.objectReference:GetRefValue("commonItemNumTxt")
	self.listPreparePetUList = self.objectReference:GetRefValue("listPreparePetUList")
	self.preparePetBtnInfoUButton = self.objectReference:GetRefValue("preparePetBtnInfoUButton")
	self.btnAbandonUButton = self.objectReference:GetRefValue("btnAbandonUButton")
	self.btnStartUButton = self.objectReference:GetRefValue("btnStartUButton")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
	self.itemInfoSpecialUWidget = self.objectReference:GetRefValue("itemInfoSpecialUWidget")
	self.elementBigUButton = self.objectReference:GetRefValue("elementBigUButton")
	self.btnSearchUButton = self.objectReference:GetRefValue("btnSearchUButton")
end

function CatchRogueEntryView:registerObjects()
	return
end

function CatchRogueEntryView:initView()
	return
end

return CatchRogueEntryView
