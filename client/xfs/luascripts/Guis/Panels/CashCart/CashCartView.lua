-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashCart\\CashCartView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local CashCartView = Class.LightClass("CashCartView", UIView)

function CashCartView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.listUList = objectReference:GetRefValue("listUList")
	self.titleTxt = objectReference:GetRefValue("titleTxt")
	self.title2Txt = objectReference:GetRefValue("title2Txt")
	self.allSelectTxt = objectReference:GetRefValue("allSelectTxt")
	self.allSelectBtn = objectReference:GetRefValue("allSelectBtn")
	self.editUBtn = objectReference:GetRefValue("editUBtn")
	self.confirmBtn = objectReference:GetRefValue("confirmBtn")
	self.closeBtn = objectReference:GetRefValue("closeBtn")
	self.listCoinsUList = objectReference:GetRefValue("listCoinsUList")
	self.btnOutUButton = objectReference:GetRefValue("btnOutUButton")
	self.btnDeleteUButton = objectReference:GetRefValue("btnDeleteUButton")
	self.txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")
end

function CashCartView:registerObjects()
	return
end

function CashCartView:initView()
	ClientTextUtils.setText(self.titleTxt, pg.getGameString("CASH_CART_TITLE"))
	ClientTextUtils.setText(self.title2Txt, pg.getGameString("CASH_CART_TITLE2"))
	ClientTextUtils.setText(self.allSelectTxt, pg.getGameString("CASH_CART_ALL_SELECT"))
	ClientTextUtils.setText(self.txtNameUBaseText, pg.getGameString("CASH_CART_EMPTY"))
	ClientTextUtils.setText(self.editUBtn.title, pg.getGameString("CASH_CART_MANAGE"))
	ClientTextUtils.setText(self.btnOutUButton.title, pg.getGameString("CASH_CART_MANAGE_DONE"))
	ClientTextUtils.setText(self.btnDeleteUButton.title, pg.getGameString("CASH_CART_DELETE"))
	ClientTextUtils.setText(self.confirmBtn.title, pg.getGameString("CASH_CART_BUY"))
end

return CashCartView
