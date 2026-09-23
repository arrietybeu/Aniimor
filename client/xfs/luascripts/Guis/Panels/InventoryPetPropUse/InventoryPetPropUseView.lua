-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\InventoryPetPropUse\\InventoryPetPropUseView.lua

local logger = require("Core.Log.LoggerManager").getLogger("InventoryPetPropUseView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local InventoryPetPropUseView = Class.LightClass("InventoryPetPropUseView", UIView)
local ClientTextUtils = require("Utils.ClientTextUtils")

function InventoryPetPropUseView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBack = objectReference:GetRefValue("btnBack")
	self.btnUse = objectReference:GetRefValue("btnUse")
	self.petListTransform = objectReference:GetRefValue("petListTransform")
	self.petInfoPanelTransform = objectReference:GetRefValue("petInfoPanelTransform")
	self.propInfoUWidget = objectReference:GetRefValue("propInfoUWidget")
	self.imgPet = objectReference:GetRefValue("imgPet")
	self.scrollRect = objectReference:GetRefValue("scrollRect")
	self.rootAnimation = objectReference:GetRefValue("rootAnimation")
	self.txtDisableUBaseText = objectReference:GetRefValue("txtDisableUBaseText")
	self.titleObjectReference = objectReference:GetRefValue("titleObjectReference")
	self.listCostUList = objectReference:GetRefValue("listCostUList")
	self.consumeUWidget = objectReference:GetRefValue("consumeUWidget")

	self:findTitleObjects(self.titleObjectReference)
end

function InventoryPetPropUseView:registerObjects()
	return
end

function InventoryPetPropUseView:initView()
	ClientTextUtils.setText(self.txtDisableUBaseText, pg.getGameString("INVENTORY_PETPROP_CANTUSE"))

	local objectReference = self.scrollRect.content:GetComponent("ObjectReference")
	local textLabelChangeUBaseText = objectReference:GetRefValue("textLabelChangeUBaseText")

	ClientTextUtils.setText(textLabelChangeUBaseText, pg.getGameString("INVENTORY_PETPROP_LABEL_CHANGE"))
	self.btnDetails:SetActiveFastest(false)
	self.btnHomePEgUButton:SetActiveFastest(false)
	self.btnLock:SetActiveFastest(false)
end

function InventoryPetPropUseView:findTitleObjects(objectReference)
	self.propName = objectReference:GetRefValue("propName")
	self.propIcon = objectReference:GetRefValue("propIcon")
	self.typeName = objectReference:GetRefValue("typeName")
	self.useCountUComponent = objectReference:GetRefValue("useCountUComponent")
	self.btnDetails = objectReference:GetRefValue("btnDetails")
	self.btnLock = objectReference:GetRefValue("btnLock")
	self.btnHomePEgUButton = objectReference:GetRefValue("btnHomePEgUButton")
	self.cashShopTradableUContainer = objectReference:GetRefValue("cashShopTradableUContainer")
	self.itemUContainer = objectReference:GetRefValue("itemUContainer")
	self.grabEggsUContainer = objectReference:GetRefValue("grabEggsUContainer")
	self.petChipsUContainer = objectReference:GetRefValue("petChipsUContainer")
	self.carryUContainer = objectReference:GetRefValue("carryUContainer")
	self.towerBuffUContainer = objectReference:GetRefValue("towerBuffUContainer")
end

return InventoryPetPropUseView
