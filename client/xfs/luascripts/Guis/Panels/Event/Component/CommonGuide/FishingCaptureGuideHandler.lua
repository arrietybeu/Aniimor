-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\CommonGuide\\FishingCaptureGuideHandler.lua

local Class = require("Core.Framework.Class")
local GuideHandlerBase = require("Guis.Panels.Event.Component.CommonGuide.GuideHandlerBase")
local ClientTextUtils = require("Utils.ClientTextUtils")
local EventCommonGuideData = require("Data.event_common_guide_data")
local PetData = require("Data.pet_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local FishingCaptureGuideHandler = Class.LightClass("FishingCaptureGuideHandler", GuideHandlerBase)

function FishingCaptureGuideHandler:getOwnedRefKeys()
	return {
		"bossCatchModeUContainer"
	}
end

function FishingCaptureGuideHandler:getOwnedContainers()
	return {
		"bossCatchModeUContainer"
	}
end

function FishingCaptureGuideHandler:onFindObjects(objectReference)
	self.bossCatchModeUContainer = objectReference:GetRefValue("bossCatchModeUContainer")
end

function FishingCaptureGuideHandler:onRefresh()
	if self.bossCatchModeUContainer:CheckURLLoaded() then
		self:_refreshCenterPet()
	else
		self.bossCatchModeUContainer:LoadDefaultUrlManually(function()
			self:_refreshCenterPet()
		end)
	end
end

function FishingCaptureGuideHandler:onExit()
	self.bossCatchModeUContainer:SetActive(false)
end

function FishingCaptureGuideHandler:_refreshCenterPet()
	local commonGuideData = EventCommonGuideData[self.comp.commonGuideId]
	local objectReference = self.bossCatchModeUContainer.content:GetComponent("ObjectReference")
	local backgroundUImage = objectReference:GetRefValue("backgroundUImage")
	local petNameUBaseText = objectReference:GetRefValue("petNameUBaseText")
	local btnLabelUButton = objectReference:GetRefValue("btnLabelUButton")
	local elementUButton = objectReference:GetRefValue("elementUButton")
	local labelTxt = objectReference:GetRefValue("labelTxt")
	local panelUWidget = objectReference:GetRefValue("panelUWidget")
	local btnShopUButton = objectReference:GetRefValue("btnShopUButton")
	local templateId = commonGuideData.centerTemplateId
	local pData = PetData[templateId]
	local _, names = LuaUIUtils.getElementInfo(pData.elementType)

	ClientTextUtils.setText(petNameUBaseText, pg.getLocalizationText(LuaUIUtils.getPetNameWithIdOrTmpId(templateId)))
	ClientTextUtils.setText(labelTxt, pg.getGameString("PET_STAGE_TXT_4"))
	LuaUIUtils.setElementButtonNew(elementUButton, names[1].element)

	function btnLabelUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_PET_DETAIL, {
			templateId = templateId
		})
	end

	panelUWidget:SetActive(true)
	btnLabelUButton:SetActive(true)
	self.comp.rewardPreviewUWidget:SetActive(true)
	self.comp.rewardPreviewUWidget:TryChangePage("Title", 1)

	if btnShopUButton then
		btnShopUButton:SetActive(commonGuideData.shopId ~= nil)

		local btnShopObjRef = btnShopUButton:GetComponent("ObjectReference")
		local btnShopTxt = btnShopObjRef and btnShopObjRef:GetRefValue("txtNameUBaseText")

		if btnShopTxt then
			ClientTextUtils.setText(btnShopTxt, pg.getGameString("GRAB_EGG_BTN_STORE"))
		end

		function btnShopUButton.luaClick()
			if commonGuideData.shopId then
				pg.global.ui:open(UIConst.UI_ID_SHOP_MAIN, {
					shopTags = {
						commonGuideData.shopId
					}
				})
			end
		end
	end
end

return FishingCaptureGuideHandler
