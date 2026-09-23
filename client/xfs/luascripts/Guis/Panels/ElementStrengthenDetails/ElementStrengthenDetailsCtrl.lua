-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ElementStrengthenDetails\\ElementStrengthenDetailsCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local HotkeyConst = require("Const.HotkeyConst")
local UIConst = require("Const.UIConst")
local ElementPropData = require("Data.element_prop_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local ElementStrengthenDetailsCtrl = Class.LightClass("ElementStrengthenDetailsCtrl", UICtrl)

function ElementStrengthenDetailsCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	function self.view.listAttriUList.luaRenderItem(button, index, data)
		self:renderItem(button, index, data)
	end
end

function ElementStrengthenDetailsCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:dismiss()
	end

	function self.view.btnCloseUButton2.luaClick()
		self:dismiss()
	end

	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnCloseUButton2.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:dismiss()
		end
	end
end

function ElementStrengthenDetailsCtrl:renderItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconElementUImage = objectReference:GetRefValue("iconElementUImage")
	local txtNameNotActiveUSDFText = objectReference:GetRefValue("txtNameNotActiveUSDFText")
	local txtNameActiveUSDFText = objectReference:GetRefValue("txtNameActiveUSDFText")
	local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	local elementData = ElementPropData[data.eId]
	local elementName = elementData and elementData.name or "null"
	local elementNameText = elementData and pg.getLocalizationText(elementData.name_ch) or ""
	local isActive = self.specialType == UIConst.Pet_ProperDetail_SubDesType.ElementResist or self.activeElementTypeIds[data.eId]

	button:TryChangePage("type", elementName)
	button:TryChangePage("Active", isActive and 1 or 0)

	iconElementUImage.url = data.cfg and data.cfg[2] or nil

	ClientTextUtils.setText(txtNameNotActiveUSDFText, elementNameText)
	ClientTextUtils.setText(txtNameActiveUSDFText, elementNameText)
	ClientTextUtils.setText(txtNumUSDFText, data.vStr or "")
end

function ElementStrengthenDetailsCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	info = info or {}
	self.specialType = info.specialType
	self.activeElementTypeIds = info.activeElementTypeIds or {}

	ClientTextUtils.setText(self.view.txtTltleUSDFText, pg.getLocalizationText(info.title or ""))
	ClientTextUtils.setText(self.view.txtTipsUSDFText, pg.getLocalizationText(info.tips or ""))
	self.view.listAttriUList:SetList(info.elementInfos or {})
end

function ElementStrengthenDetailsCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

return ElementStrengthenDetailsCtrl
