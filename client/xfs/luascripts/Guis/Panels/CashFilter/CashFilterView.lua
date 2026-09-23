-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashFilter\\CashFilterView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local CashFilterView = Class.LightClass("CashFilterView", UIView)

function CashFilterView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listUList = objectReference:GetRefValue("listUList")
	self.btnBGClose = objectReference:GetRefValue("btnBGClose")
	self.btnClose = objectReference:GetRefValue("btnClose")
	self.btnConfirm = objectReference:GetRefValue("btnConfirm")
	self.btnReset = objectReference:GetRefValue("btnReset")
	self.textUBaseText = objectReference:GetRefValue("textUBaseText")
	self.txtBtnConfirmName = objectReference:GetRefValue("txtBtnConfirmName")
end

function CashFilterView:registerObjects()
	return
end

function CashFilterView:setupView()
	ClientTextUtils.setText(self.textUBaseText, pg.getGameString("SHOP_SEARCH_SORT"))
	ClientTextUtils.setText(self.txtBtnConfirmName, pg.getGameString("SHOP_OK"))
end

function CashFilterView:setListData(listData)
	self.listUList:SetList(listData)
end

return CashFilterView
