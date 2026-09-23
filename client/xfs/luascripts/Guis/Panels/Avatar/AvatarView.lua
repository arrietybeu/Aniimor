-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Avatar\\AvatarView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local AvatarView = Class.LightClass("AvatarView", UIView)

function AvatarView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.backUButton = self.objectReference:GetRefValue("backUButton")
	self.titleShadowUSDFText = self.objectReference:GetRefValue("titleShadowUSDFText")
	self.tabUList = self.objectReference:GetRefValue("tabUList")
	self.switchUButton = self.objectReference:GetRefValue("switchUButton")
	self.firstSortUList = self.objectReference:GetRefValue("firstSortUList")
	self.secondSortUList = self.objectReference:GetRefValue("secondSortUList")
	self.firstDesignUList = self.objectReference:GetRefValue("firstDesignUList")
	self.secondDesignUList = self.objectReference:GetRefValue("secondDesignUList")
	self.nextUButton = self.objectReference:GetRefValue("nextUButton")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.rightPanelTransform = self.objectReference:GetRefValue("rightPanelTransform")
	self.maskRayBoxTrans = self.objectReference:GetRefValue("maskRayBoxTrans")
	self.bubbleUComponent = self.objectReference:GetRefValue("bubbleUComponent")
	self.lookAtUButton = self.objectReference:GetRefValue("lookAtUButton")
	self.listCurrencyUList = self.objectReference:GetRefValue("listCurrencyUList")
	self.clothHideUButton = self.objectReference:GetRefValue("clothHideUButton")
	self.uiUButton = self.objectReference:GetRefValue("uiUButton")
	self.uploadUButton = self.objectReference:GetRefValue("uploadUButton")
	self.downloadUButton = self.objectReference:GetRefValue("downloadUButton")
	self.btnBackgroundSwitchUButton = self.objectReference:GetRefValue("btnBackgroundSwitchUButton")
	self.backgroundSelectorUSelector = self.objectReference:GetRefValue("backgroundSelectorUSelector")
	self.leftLayoutBoxUWidget = self.objectReference:GetRefValue("leftLayoutBoxUWidget")
	self.btnHairTieUButton = self.objectReference:GetRefValue("btnHairTieUButton")
end

function AvatarView:registerObjects()
	local objRef = self.rightPanelTransform:GetComponent("ObjectReference")

	self.rightPanelUComponent = objRef:GetRefValue("rightPanelUComponent")
	self.operationUList = objRef:GetRefValue("operationUList")
	self.shortOperationUList = objRef:GetRefValue("shortOperationUList")
	self.squareSelectUList = objRef:GetRefValue("squareSelectUList")
	self.hairSelectUList = objRef:GetRefValue("hairSelectUList")
	self.decalSelectUList = objRef:GetRefValue("decalSelectUList")
	self.applyUButton = objRef:GetRefValue("applyUButton")
	self.deleteUButton = objRef:GetRefValue("deleteUButton")
	self.editUButton = objRef:GetRefValue("editUButton")
	self.globalEffectList = objRef:GetRefValue("globalEffectList")
	self.rootBoneUList = objRef:GetRefValue("rootBoneUList")
	self.boneOpUList = objRef:GetRefValue("boneOpUList")
	self.closeUButton = objRef:GetRefValue("closeUButton")
	self.conformUButton = objRef:GetRefValue("conformUButton")
	self.previewUButton = objRef:GetRefValue("previewUButton")
	self.nextStepUButton = objRef:GetRefValue("nextStepUButton")
	self.undoUButton = objRef:GetRefValue("undoUButton")
	self.redoUButton = objRef:GetRefValue("redoUButton")
	self.resetUButton = objRef:GetRefValue("resetUButton")
	self.makeupPresetUList = objRef:GetRefValue("makeupPresetUList")
	self.closeUButtonConsole = objRef:GetRefValue("closeUButtonConsole")
	self.downloadBtnUButton = objRef:GetRefValue("downloadBtnUButton")
	self.listPartsUList = objRef:GetRefValue("listPartsUList")
	self.consumeUWidget = objRef:GetRefValue("consumeUWidget")
	self.listItemsUList = objRef:GetRefValue("listItemsUList")
	self.txtTitleUSDFText = objRef:GetRefValue("txtTitleUSDFText")
end

function AvatarView:initView()
	return
end

function AvatarView:renderMakeUpSelectList(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")

	if data.state then
		button:TryChangePage("State", data.state)
	end

	if data.makeupList then
		button:TryChangePage("State", not data.owned and 2 or 1)
	end

	iconUImage.url = data.icon
end

function AvatarView:renderMakeUpSkinSelectList(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

	ClientTextUtils.setText(txtNameUSDFText, string.format(pg.getGameString("AVATAR_SKIN"), index + 1))
end

return AvatarView
