-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashShopPenaltyTip\\CashShopPenaltyTipView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local CashShopPenaltyTipView = Class.LightClass("CashShopPenaltyTipView", UIView)

function CashShopPenaltyTipView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.txtTitleUBaseText = objectReference:GetRefValue("txtTitleUBaseText")
	self.listUList = objectReference:GetRefValue("listUList")
end

function CashShopPenaltyTipView:setContent(title, rows)
	ClientTextUtils.setText(self.txtTitleUBaseText, title)

	function self.listUList.luaRenderItem(button, _, data)
		if data.tIndex == 0 then
			button:TryChangePage("Type", data.titleType or 0)
			button:TryChangePage("state", data.titleState or 0)
			button:TryChangePage("haveBlank", data.haveBlank and 1 or 0)
		end

		local objectReference = button:GetComponent("ObjectReference")
		local textUBaseText = objectReference:GetRefValue("textUBaseText")

		ClientTextUtils.setText(textUBaseText, data.text)

		if data.tIndex == 0 then
			local minusTextUBaseText = button.transform:Find("Detail/Bg2/Text"):GetComponent("USDFText")

			ClientTextUtils.setText(minusTextUBaseText, data.text)
		end
	end

	self.listUList:SetList(rows)
end

return CashShopPenaltyTipView
