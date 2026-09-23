-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandFacilityInfo\\HomelandFacilityInfoView.lua

local logger = require("Core.Log.LoggerManager").getLogger("InteractSecondView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomelandFacilityInfoView = Class.LightClass("HomelandFacilityInfoView", UIView)

function HomelandFacilityInfoView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.titleText = self.objectReference:GetRefValue("titleText")
	self.closeBtn = self.objectReference:GetRefValue("closeBtn")
	self.listPet = self.objectReference:GetRefValue("listPet")
	self.workInfo = self.objectReference:GetRefValue("workInfo")
	self.levelUWidget = self.objectReference:GetRefValue("levelUWidget")
	self.levelText = self.objectReference:GetRefValue("levelText")
	self.facilityIcon = self.objectReference:GetRefValue("facilityIcon")
	self.petPanelUComponent = self.objectReference:GetRefValue("petPanelUComponent")
	self.petPanelTextUSDFText = self.objectReference:GetRefValue("petPanelTextUSDFText")
	self.recommendText = self.objectReference:GetRefValue("recommendText")
	self.accessList = self.objectReference:GetRefValue("accessList")
	self.recommendUWidget = self.objectReference:GetRefValue("recommendUWidget")
	self.itemInfo02UWidget = self.objectReference:GetRefValue("itemInfo02UWidget")
	self.itemInfo01UWidget = self.objectReference:GetRefValue("itemInfo01UWidget")
	self.itemInfo03UWidget = self.objectReference:GetRefValue("itemInfo03UWidget")
	self.homeAbilityUWidget = self.objectReference:GetRefValue("homeAbilityUWidget")
	self.homeAbilityItem = self.objectReference:GetRefValue("homeAbilityItem")
	self.detailInfoPopupRectRectTransform = self.objectReference:GetRefValue("detailInfoPopupRectRectTransform")
	self.contentUWidget = self.objectReference:GetRefValue("contentUWidget")
end

return HomelandFacilityInfoView
