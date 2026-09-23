-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\VitalityV0\\VitalityV0Ctrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("VitalityV0Ctrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local VitalityV0Ctrl = Class.LightClass("VitalityV0Ctrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")

VitalityV0Ctrl.messages = {
	[MessageName.MONEY_COUNT_CHANGE] = {
		"onPropChangedCallback",
		true
	}
}

function VitalityV0Ctrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function VitalityV0Ctrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnClose.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:dismiss()
		end
	end

	function self.view.btnClose.luaClick()
		self:dismiss()
	end

	function self.view.btnClose2.luaClick()
		self:dismiss()
	end

	function self.view.listUList.luaRenderItem(button, index, data)
		self:onRenderVitalityItem(button, index, data)
	end

	function self.view.currencyItem.luaClick()
		if pg.global.ui:checkUIOpen(UIConst.UI_ID_COMMON_ITEM_TIP) then
			pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
		else
			local data = LuaUIUtils.getVitalityData()

			pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
				id = data.id,
				num = data.ownNum,
				targetRect = self.view.currencyItem
			})
		end
	end
end

function VitalityV0Ctrl:onDestroy()
	UICtrl.onDestroy(self)
end

function VitalityV0Ctrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function VitalityV0Ctrl:onShow()
	local dataList = self.model:getVitalityDataList()

	self.view.listUList:SetList(dataList)
	self:refreshCurrencyView()
end

function VitalityV0Ctrl:refreshCurrencyView()
	local data = LuaUIUtils.getVitalityData()
	local objectReference = self.view.currencyItem:GetComponent("ObjectReference")
	local countUText = objectReference:GetRefValue("countUText")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local btnAdd = objectReference:GetRefValue("btnAdd")

	ClientTextUtils.setText(countUText, string.format("%d/%d", data.num, data.maxRestoreNum))

	iconUImage.url = data.icon

	self.view.currencyItem:TryChangePage("IsAdd", 1)

	function btnAdd.luaClick()
		if pg.global.ui:checkUIOpen(UIConst.UI_ID_COMMON_ITEM_TIP) then
			pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
		end

		LuaUIUtils.openVitalityGot(Const.CommonEnergyType_Stamina)
	end
end

function VitalityV0Ctrl:onRenderVitalityItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local textName = objectReference:GetRefValue("textName")
	local listUList = objectReference:GetRefValue("listUList")
	local currencyGet = objectReference:GetRefValue("currencyGet")
	local currencyIcon = objectReference:GetRefValue("currencyIcon")
	local btnGoto = objectReference:GetRefValue("btnGoto")

	function listUList.luaRenderItem(subBtn, idx, subData)
		self:onRenderSubPropItem(subBtn, idx, subData)
	end

	listUList:SetList(data.rewards)
	ClientTextUtils.setText(textName, data.title)

	local consume = data.consumes[1]

	currencyIcon.url = consume.icon

	ClientTextUtils.setText(currencyGet, string.format(pg.getGameString("CONSUME_TIMES"), consume.num))

	function btnGoto.luaClick()
		LuaUIUtils.goToFromEvent({
			type = data.goTo[1],
			id = data.goTo[2],
			guideId = data.guideId
		})
	end
end

function VitalityV0Ctrl:onRenderSubPropItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local itemIconUImage = objectReference:GetRefValue("itemIconUImage")
	local txtNumUText = objectReference:GetRefValue("txtNumUText")
	local consoleSelected = objectReference:GetRefValue("consoleSelected")
	local petIconUImage = objectReference:GetRefValue("petIconUImage")
	local tagFirsRewardUWidget = objectReference:GetRefValue("tagFirsRewardUWidget")
	local btnExchangeUButton = objectReference:GetRefValue("btnExchangeUButton")

	itemIconUImage.url = data.icon

	ClientTextUtils.setText(txtNumUText, data.num)
	button:TryChangePage("Quality", data.quality)

	function button.luaClick()
		if pg.global.ui:checkUIOpen(UIConst.UI_ID_COMMON_ITEM_TIP) then
			pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
		else
			pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
				id = data.id,
				num = data.num,
				targetRect = button
			})
		end
	end
end

function VitalityV0Ctrl:onPropChangedCallback(data)
	self:refreshCurrencyView()
end

function VitalityV0Ctrl:onHide()
	return
end

return VitalityV0Ctrl
