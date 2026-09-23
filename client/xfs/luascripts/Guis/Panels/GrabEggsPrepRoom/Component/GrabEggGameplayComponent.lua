-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsPrepRoom\\Component\\GrabEggGameplayComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local GrabEggGameplayComponent = Class.LightClass("GrabEggGameplayComponent", UIComponent)

function GrabEggGameplayComponent:findObjects()
	self.btnEquip = self.view.btnEquip
	self.btnStore = self.view.btnStore
end

function GrabEggGameplayComponent:registerObjects()
	function self.btnEquip.luaClick()
		self:onBtnEquip()
	end

	function self.btnStore.luaClick()
		self:onBtnStore()
	end
end

function GrabEggGameplayComponent:refreshView(data)
	self.btnEquip:SetActive(true)
end

function GrabEggGameplayComponent:onBtnEquip()
	pg.global.ui:open(UIConst.UI_ID_GRAB_EGGS_BAG, {
		bagType = UIConst.GRAB_EGG_BAG_TYPE.INVENTORY
	})
end

function GrabEggGameplayComponent:onBtnStore()
	if LuaUIUtils.checkFuncTemporaryDisable(UIConst.UI_ID_SHOP_MAIN) then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_SHOP_MAIN, {
		shopTags = {
			35
		}
	})
end

return GrabEggGameplayComponent
