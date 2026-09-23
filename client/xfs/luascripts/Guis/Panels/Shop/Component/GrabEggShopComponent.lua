-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Shop\\Component\\GrabEggShopComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local GrabEggShopComponent = Class.LightClass("GrabEggShopComponent", UIComponent)
local GOTO_EQUIP_TEXT_KEY = "GRAB_EGG_GOTO_EQUIP"

function GrabEggShopComponent:findObjects()
	self.jumpUButton = self.view.jumpUButton
end

function GrabEggShopComponent:registerObjects()
	function self.jumpUButton.luaClick()
		if LuaUIUtils.checkFuncTemporaryDisable(UIConst.UI_ID_GRAB_EGGS_BAG) then
			return
		end

		pg.global.ui:open(UIConst.UI_ID_GRAB_EGGS_BAG, {
			bagType = UIConst.GRAB_EGG_BAG_TYPE.INVENTORY
		})
	end
end

function GrabEggShopComponent:initView()
	local objectReference = self.jumpUButton.transform:GetComponent("ObjectReference")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")

	ClientTextUtils.setText(txtNameUText, pg.getGameString(GOTO_EQUIP_TEXT_KEY))
end

return GrabEggShopComponent
