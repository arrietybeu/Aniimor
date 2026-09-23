-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTransmogItemGet\\PetTransmogItemGetView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetTransmogItemGetView = Class.LightClass("PetTransmogItemGetView", UIView)

function PetTransmogItemGetView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnClose = objectReference:GetRefValue("btnClose")
	self.txtName = objectReference:GetRefValue("txtName")
	self.txtDesc = objectReference:GetRefValue("txtDesc")
	self.item = objectReference:GetRefValue("item")
	self.txtPrize = objectReference:GetRefValue("txtPrize")
	self.numSelector = objectReference:GetRefValue("numSelector")
	self.txtCost = objectReference:GetRefValue("txtCost")
	self.currencyList = objectReference:GetRefValue("currencyList")
	self.btnConfirm = objectReference:GetRefValue("btnConfirm")
	self.itemName = objectReference:GetRefValue("itemName")
	self.txtBtnConfirm = objectReference:GetRefValue("txtBtnConfirm")
end

function PetTransmogItemGetView:registerObjects()
	return
end

function PetTransmogItemGetView:initView()
	ClientTextUtils.setText(self.txtName, pg.getGameString("PETTRANSMOGRIFY_QUICK_PURCHASE"))
	ClientTextUtils.setText(self.txtDesc, pg.getGameString("PETTRANSMOGRIFY_CRYSTAL_SHORTAGE"))
	ClientTextUtils.setText(self.txtBtnConfirm, pg.getGameString("PETTRANSMOGRIFY_BUY"))
end

return PetTransmogItemGetView
