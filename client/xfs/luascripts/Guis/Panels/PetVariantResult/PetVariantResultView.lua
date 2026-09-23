-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetVariantResult\\PetVariantResultView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetVariantResultView = Class.LightClass("PetVariantResultView", UIView)
local VARIANT_NAME_RES_ID = "$UI_Com_NameisChange.prefab"

function PetVariantResultView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.txtTitleUText = self.objectReference:GetRefValue("txtTitleUText")
	self.imgPetUImage = self.objectReference:GetRefValue("imgPetUImage")
	self.txtLevelUText = self.objectReference:GetRefValue("txtLevelUText")
	self.petDemensionObjectReference = self.objectReference:GetRefValue("petDemensionObjectReference")
	self.upTipsUWidget = self.objectReference:GetRefValue("upTipsUWidget")

	self:_findPropertyObjects()
end

function PetVariantResultView:_findPropertyObjects()
	self.hpNum = self.petDemensionObjectReference:GetRefValue("hpNum")
	self.atkNum = self.petDemensionObjectReference:GetRefValue("atkNum")
	self.defNum = self.petDemensionObjectReference:GetRefValue("defNum")
	self.regenNum = self.petDemensionObjectReference:GetRefValue("regenNum")
	self.defMagNum = self.petDemensionObjectReference:GetRefValue("defMagNum")
	self.atkMagNum = self.petDemensionObjectReference:GetRefValue("atkMagNum")
	self.hpCmp = self.petDemensionObjectReference:GetRefValue("hpCmp")
	self.atkCmp = self.petDemensionObjectReference:GetRefValue("atkCmp")
	self.defCmp = self.petDemensionObjectReference:GetRefValue("defCmp")
	self.regenCmp = self.petDemensionObjectReference:GetRefValue("regenCmp")
	self.defMagCmp = self.petDemensionObjectReference:GetRefValue("defMagCmp")
	self.atkMagCmp = self.petDemensionObjectReference:GetRefValue("atkMagCmp")
	self.hpLevelCmp = self.petDemensionObjectReference:GetRefValue("hpLevelCmp")
	self.atkLevelCmp = self.petDemensionObjectReference:GetRefValue("atkLevelCmp")
	self.defLevelCmp = self.petDemensionObjectReference:GetRefValue("defLevelCmp")
	self.regenLevelCmp = self.petDemensionObjectReference:GetRefValue("regenLevelCmp")
	self.defMagLevelCmp = self.petDemensionObjectReference:GetRefValue("defMagLevelCmp")
	self.atkMagLevelCmp = self.petDemensionObjectReference:GetRefValue("atkMagLevelCmp")
	self.hpLv = self.petDemensionObjectReference:GetRefValue("hpLv")
	self.atkLv = self.petDemensionObjectReference:GetRefValue("atkLv")
	self.defLv = self.petDemensionObjectReference:GetRefValue("defLv")
	self.regenLv = self.petDemensionObjectReference:GetRefValue("regenLv")
	self.defMagLv = self.petDemensionObjectReference:GetRefValue("defMagLv")
	self.atkMagLv = self.petDemensionObjectReference:GetRefValue("atkMagLv")
	self.defaultRadar = self.petDemensionObjectReference:GetRefValue("defaultRadar")
	self.addedRadar = self.petDemensionObjectReference:GetRefValue("addedRadar")
	self.hpUpUBaseText = self.petDemensionObjectReference:GetRefValue("hpUpUBaseText")
	self.atkUpUBaseText = self.petDemensionObjectReference:GetRefValue("atkUpUBaseText")
	self.defUpUBaseText = self.petDemensionObjectReference:GetRefValue("defUpUBaseText")
	self.regenUpUBaseText = self.petDemensionObjectReference:GetRefValue("regenUpUBaseText")
	self.defMsgUpUBaseText = self.petDemensionObjectReference:GetRefValue("defMsgUpUBaseText")
	self.atkMsgUpUBaseText = self.petDemensionObjectReference:GetRefValue("atkMsgUpUBaseText")
end

function PetVariantResultView:registerObjects()
	self.petAttributeRef = {
		propNumGroup = {
			self.hpNum,
			self.atkNum,
			self.defNum,
			self.regenNum,
			self.defMagNum,
			self.atkMagNum
		},
		propCmpGroup = {
			self.hpCmp,
			self.atkCmp,
			self.defCmp,
			self.regenCmp,
			self.defMagCmp,
			self.atkMagCmp
		},
		propLevelCmpGroup = {
			self.hpLevelCmp,
			self.atkLevelCmp,
			self.defLevelCmp,
			self.regenLevelCmp,
			self.defMagLevelCmp,
			self.atkMagLevelCmp
		},
		propLevelGroup = {
			self.hpLv,
			self.atkLv,
			self.defLv,
			self.regenLv,
			self.defMagLv,
			self.atkMagLv
		},
		propNumUpGroup = {
			self.hpUpUBaseText,
			self.atkUpUBaseText,
			self.defUpUBaseText,
			self.regenUpUBaseText,
			self.defMsgUpUBaseText,
			self.atkMsgUpUBaseText
		},
		defaultRadar = self.defaultRadar,
		addedRadar = self.addedRadar
	}

	self:_createVariantName()
end

function PetVariantResultView:_createVariantName()
	local titleRect = self.txtTitleUText.transform:GetComponent("RectTransform")
	local item = self:addPrefabWithPathSync(titleRect.parent, VARIANT_NAME_RES_ID)
	local variantNameRect = item.transform:GetComponent("RectTransform")

	self.variantNameUBaseText = item.gameObject:GetComponent("USDFText")
	self.variantNameCoverUBaseText = item.transform:Find("NameCover"):GetComponent("USDFText")
	variantNameRect.anchorMin = titleRect.anchorMin
	variantNameRect.anchorMax = titleRect.anchorMax
	variantNameRect.anchoredPosition = titleRect.anchoredPosition
	variantNameRect.pivot = titleRect.pivot

	variantNameRect:SetSiblingIndex(titleRect:GetSiblingIndex())

	local titleFontSize = self.txtTitleUText.fontSize

	self.variantNameUBaseText.fontSizeMax = titleFontSize
	self.variantNameUBaseText.fontSize = titleFontSize
	self.variantNameCoverUBaseText.fontSizeMax = titleFontSize
	self.variantNameCoverUBaseText.fontSize = titleFontSize

	self.txtTitleUText.gameObject:SetActiveEx(false)
end

return PetVariantResultView
