-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\WorkShopCostumeStain\\WorkShopCostumeStainView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local WorkShopCostumeStainView = Class.LightClass("WorkShopCostumeStainView", UIView)

function WorkShopCostumeStainView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnBack = self.objectReference:GetRefValue("btnBack")
	self.tabList = self.objectReference:GetRefValue("tabList")
	self.subItemList = self.objectReference:GetRefValue("subItemList")
	self.colorPicker = self.objectReference:GetRefValue("colorPicker")
	self.maskRayBoxTrans = self.objectReference:GetRefValue("maskRayBoxTrans")
	self.btnApply = self.objectReference:GetRefValue("btnApply")
	self.consume = self.objectReference:GetRefValue("consume")
	self.titleShadowUBaseText = self.objectReference:GetRefValue("titleShadowUBaseText")
	self.btnHideUButton = self.objectReference:GetRefValue("btnHideUButton")
	self.listCurrencyUList = self.objectReference:GetRefValue("listCurrencyUList")

	local okUpload, uploadUButton = pcall(function()
		return self.objectReference:GetRefValue("uploadUButton")
	end)

	if okUpload then
		self.uploadUButton = uploadUButton
	end

	local okDownload, downloadUButton = pcall(function()
		return self.objectReference:GetRefValue("downloadUButton")
	end)

	if okDownload then
		self.downloadUButton = downloadUButton
	end

	self.consumeUWidget = self.objectReference:GetRefValue("consumeUWidget")
	self.listItemsUList = self.objectReference:GetRefValue("listItemsUList")
	self.txtTitleUSDFText = self.objectReference:GetRefValue("txtTitleUSDFText")
	self.rightPanelOc = self.objectReference:GetRefValue("rightPanelOc")
	self.objectReference = self.rightPanelOc
	self.rightPanelUComponent = self.objectReference:GetRefValue("rightPanelUComponent")
	self.operationUList = self.objectReference:GetRefValue("operationUList")
	self.shortOperationUList = self.objectReference:GetRefValue("shortOperationUList")
	self.squareSelectUList = self.objectReference:GetRefValue("squareSelectUList")
	self.hairSelectUList = self.objectReference:GetRefValue("hairSelectUList")
	self.decalSelectUList = self.objectReference:GetRefValue("decalSelectUList")
	self.applyUButton = self.objectReference:GetRefValue("applyUButton")
	self.deleteUButton = self.objectReference:GetRefValue("deleteUButton")
	self.editUButton = self.objectReference:GetRefValue("editUButton")
	self.globalEffectList = self.objectReference:GetRefValue("globalEffectList")
	self.patternList = self.objectReference:GetRefValue("patternList")
	self.rootBoneUList = self.objectReference:GetRefValue("rootBoneUList")
	self.boneOpUList = self.objectReference:GetRefValue("boneOpUList")
	self.closeUButton = self.objectReference:GetRefValue("closeUButton")
	self.conformUButton = self.objectReference:GetRefValue("conformUButton")
	self.consumeUList = self.objectReference:GetRefValue("consumeUList")
	self.previewUButton = self.objectReference:GetRefValue("previewUButton")
	self.nextStepUButton = self.objectReference:GetRefValue("nextStepUButton")
	self.undoUButton = self.objectReference:GetRefValue("undoUButton")
	self.redoUButton = self.objectReference:GetRefValue("redoUButton")
	self.resetUButton = self.objectReference:GetRefValue("resetUButton")
	self.rootComponent = self.transform:GetComponent("UComponent")
end

function WorkShopCostumeStainView:registerObjects()
	return
end

function WorkShopCostumeStainView:initView()
	return
end

return WorkShopCostumeStainView
