-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\InventoryDecompose\\InventoryDecomposeCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("InventoryDecomposeCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local InventoryDecomposeCtrl = Class.LightClass("InventoryDecomposeCtrl", UICtrl)
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")

InventoryDecomposeCtrl.messages = {}

function InventoryDecomposeCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function InventoryDecomposeCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnClose1.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:dismiss()
		end
	end

	function self.view.btnClose1.luaClick()
		self:dismiss()
	end

	function self.view.btnClose2.luaClick()
		self:dismiss()
	end

	function self.view.btnCancel.luaClick()
		self:dismiss()
	end

	function self.view.btnConfirm.luaClick()
		self:onClickBtnConfirm()
	end

	function self.view.listProp.luaRenderItem(button, idx, data)
		self:onRenderDecomposeItem(button, idx, data)
	end

	function self.view.listReward.luaRenderItem(button, idx, data)
		self:onRenderResultItem(button, idx, data)
	end
end

function InventoryDecomposeCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function InventoryDecomposeCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.selectedGensTable = info.selectedGensTable
	self.propList = info.propList
	self.resultList = self.model:getResultList(self.selectedGensTable, self.propList)
	self.confirmCallback = info.confirmCallback

	self:refreshView()
end

function InventoryDecomposeCtrl:onShow()
	return
end

function InventoryDecomposeCtrl:onHide()
	return
end

function InventoryDecomposeCtrl:refreshView()
	self.view.listProp:SetList(self.model:getFillUIPropList(self.propList))
	self.view.listReward:SetList(self.resultList)
end

function InventoryDecomposeCtrl:refreshPropItem(button, index, data, isResultItem)
	if not data.itemId then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local itemIconUImage = objectReference:GetRefValue("itemIconUImage")
	local txtNumUText = objectReference:GetRefValue("txtNumUText")
	local num = isResultItem and data.itemNum or self.selectedGensTable[data.index]

	itemIconUImage.url = data.icon

	ClientTextUtils.setText(txtNumUText, num)
	button:TryChangePage("Quality", data.quality)
	button:TryChangePage("ItemType", 0)

	function button.luaClick()
		if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP) then
			pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
		else
			pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
				id = data.itemId,
				num = data.itemNum,
				targetRect = button
			})
		end
	end
end

function InventoryDecomposeCtrl:onRenderDecomposeItem(button, idx, data)
	self:refreshPropItem(button, idx, data)
end

function InventoryDecomposeCtrl:onRenderResultItem(button, idx, data)
	self:refreshPropItem(button, idx, data, true)
end

function InventoryDecomposeCtrl:onClickBtnConfirm()
	local serverList = self.model:getDecomposeServerList(self.selectedGensTable, self.propList)

	for k, v in ipairs(serverList) do
		pg.me:serverMsg("RPC_CS_ItemDecompose", unpack(v))
	end

	self:dismiss()

	if self.confirmCallback then
		self.confirmCallback()
	end
end

return InventoryDecomposeCtrl
