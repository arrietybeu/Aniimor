-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\VitalityRedeem\\VitalityRedeemCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("VitalityRedeemCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local VitalityRedeemCtrl = Class.LightClass("VitalityRedeemCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local LuaMsgUtils = require("Utils.LuaMsgUtils")

VitalityRedeemCtrl.messages = {}

function VitalityRedeemCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self.view.costUWidget:SetActive(false)
end

function VitalityRedeemCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnCloseUButton.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:dismiss()
		end
	end

	local confirmBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnConfirmUButton.gameObject, "confirmBind")

	confirmBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Confirm

	function self.view.btnCloseUButton.luaClick()
		self:dismiss()
	end

	function self.view.btnCancelUButton.luaClick()
		self:dismiss()
	end

	function self.view.btnConfirmUButton.luaClick()
		self:onBtnConfirm()
	end

	function self.view.numSelectorSliderUNumSelector.luaValueChanged(value)
		self:onValueChanged(value)
	end

	function self.view.listItemFrontUList.luaRenderItem(button, index, data)
		self:refreshPropView(button, data)
	end

	function self.view.listItemBackUList.luaRenderItem(button, index, data)
		self:refreshPropView(button, data)
	end
end

function VitalityRedeemCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function VitalityRedeemCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.itemId = info or 0
end

function VitalityRedeemCtrl:onShow()
	ClientTextUtils.setText(self.view.titleUSDFText, pg.getGameString("ENERGY_EXCHANGE_TITLE"))
	self:refreshView()
end

function VitalityRedeemCtrl:refreshView()
	local data = LuaUIUtils.getVitalityData()
	local limitUseNum = math.floor((data.maxLimitNum - data.num) / 60)

	self.view.numSelectorSliderUNumSelector:SetAllValue(0, 0, 0, 0)

	local data1 = LuaUIUtils.getItemInfoById(self.itemId)
	local max = math.max(math.min(limitUseNum, data1.ownNum), 1)
	local min = 1

	ClientTextUtils.setText(self.view.describeUSDFText, pg.getFormatText(pg.getGameString("EXCHANGE_ENERGY_FOR_ONE_BATTERY"), data1.name, 60))
	self.view.numSelectorSliderUNumSelector:SetAllValue(1, min, max, 1, true)
end

function VitalityRedeemCtrl:onValueChanged(newValue)
	local data1 = LuaUIUtils.getItemInfoById(self.itemId)
	local data2 = LuaUIUtils.getItemInfoById(Const.CommonEnergyType_Stamina)

	data1.useNum = newValue
	data2.useNum = newValue * 60

	self.view.listItemFrontUList:SetList({
		data1
	})
	self.view.listItemBackUList:SetList({
		data2
	})
end

function VitalityRedeemCtrl:refreshPropView(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local itemIconUImage = objectReference:GetRefValue("itemIconUImage")
	local txtNumUBaseText = objectReference:GetRefValue("txtNumUBaseText")
	local imgDisableUImage = objectReference:GetRefValue("imgDisableUImage")
	local itemUnderName = objectReference:GetRefValue("itemUnderName")
	local iconPetUContainer = objectReference:GetRefValue("iconPetUContainer")

	button:TryChangePage("Quality", data.quality)

	itemIconUImage.url = data.icon

	ClientTextUtils.setText(txtNumUBaseText, data.useNum)
end

function VitalityRedeemCtrl:onBtnConfirm()
	local redeemNum = self.view.numSelectorSliderUNumSelector.value

	LuaMsgUtils.useItemById(self.itemId, redeemNum, {}, function()
		self:close()
		pg.global.ui:close(UIConst.UI_ID_VITALITY_GOT, {
			itemId = Const.CommonEnergyType_Stamina
		})
	end)
end

function VitalityRedeemCtrl:onHide()
	return
end

return VitalityRedeemCtrl
