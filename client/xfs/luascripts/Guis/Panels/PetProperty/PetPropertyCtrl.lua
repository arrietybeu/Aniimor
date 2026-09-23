-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetProperty\\PetPropertyCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local HotkeyConst = require("Const.HotkeyConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetManagementUtils = require("Utils.PetManagementUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local PetPropertyCtrl = Class.LightClass("PetPropertyCtrl", UICtrl)

PetPropertyCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function PetPropertyCtrl:getManagedBlurEffect()
	return self.view and self.view.bgBlurUIBlurEffect
end

function PetPropertyCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:initializeManagedBlur()
	self:Init(info)
end

function PetPropertyCtrl:onShow()
	return
end

function PetPropertyCtrl:onHide()
	return
end

function PetPropertyCtrl:onDestroy()
	self:destroy()
	UICtrl.onDestroy(self)
end

function PetPropertyCtrl:Init(info)
	local data = LuaUIUtils.getPropertyData(info.curPetId, true)

	function self.view.listUList.luaRenderItem(button, index, data1)
		self:renderItem(button, index, data1)
	end

	self.view.listUList:SetList(data)
end

function PetPropertyCtrl:destroy()
	return
end

function PetPropertyCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnBackUButton.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:closePanel()
		end
	end

	function self.view.btnBackUButton.luaClick()
		self:closePanel()
	end
end

function PetPropertyCtrl:closePanel()
	pg.global.ui:close(UIConst.UI_ID_PET_PROPERTY)
end

function PetPropertyCtrl:renderItem(button, index, data)
	if data.tIndex == 0 then
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
		local txtNumExtraPropTs = button.transform:Find("Widget/LayoutBox/TxtNumAdd")
		local txtNumExtraPropUsdftxt = txtNumExtraPropTs and txtNumExtraPropTs:GetComponent("USDFText")
		local btnInfoTx = button.transform:Find("Widget/BtnInfo")
		local btnInfoUButton = btnInfoTx and btnInfoTx:GetComponent("UButton")
		local element96Ts = button.transform:Find("Widget/LayoutBox/Element96")
		local element96TsUButton = element96Ts and element96Ts:GetComponent("UButton")

		iconUImage.url = data.icon

		ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.name))
		ClientTextUtils.setText(txtNumUSDFText, data.value)

		button.enabledTooltip = true

		function button.luaTooltipPopup(_, flag)
			button:TryChangePage("Select", flag and 1 or 0)
		end

		function button.luaRenderTooltip(_, tipItem)
			PetManagementUtils.customRefreshBuffInfoTooltip(tipItem, PetManagementDataHelper.BuffInfoToolTipType.Buff, {
				buffName = pg.getLocalizationText(data.name),
				buffDesc = pg.getLocalizationText(data.desc),
				buffIcon = data.icon
			})
		end

		if NotNil(txtNumExtraPropUsdftxt) then
			txtNumExtraPropUsdftxt:SetActive(true)
			ClientTextUtils.setText(txtNumExtraPropUsdftxt, data.extraProp and "+" .. tostring(data.extraProp) or "")
		end

		local specialDesInfo = data.specialDesInfo or {}
		local specialType = specialDesInfo.type or UIConst.Pet_ProperDetail_SubDesType.None

		if NotNil(btnInfoUButton) then
			local isShowTip = specialType ~= UIConst.Pet_ProperDetail_SubDesType.None

			btnInfoUButton:SetActive(isShowTip)

			btnInfoUButton.enabledTooltip = false

			if not isShowTip then
				btnInfoUButton.luaClick = nil
			elseif specialType == UIConst.Pet_ProperDetail_SubDesType.Info then
				function btnInfoUButton.luaClick()
					pg.global.ui.tips:openCommonPopUpTipById(specialDesInfo.decConfigId)
				end
			else
				function btnInfoUButton.luaClick()
					self:popElementTip(specialType, specialDesInfo)
				end
			end
		end

		if NotNil(element96TsUButton) then
			local isShowElement96 = specialDesInfo and specialDesInfo.mainElementTypeId and specialDesInfo.mainElementTypeId ~= -1

			element96TsUButton:SetActive(isShowElement96)

			if isShowElement96 then
				element96TsUButton:TryChangePage("type", specialDesInfo.mainEleName)
			end
		end
	else
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, data.name)
	end
end

function PetPropertyCtrl:popElementTip(specialType, specialDesInfo)
	if not specialDesInfo or specialType ~= UIConst.Pet_ProperDetail_SubDesType.ElementRestrain and specialType ~= UIConst.Pet_ProperDetail_SubDesType.ElementResist then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_ELEMENT_STRENGTHEN_DETAILS, {
		specialType = specialType,
		elementInfos = specialDesInfo.subElementShowInfos or {},
		activeElementTypeIds = specialDesInfo.activeElementTypeIds or {},
		title = specialDesInfo.title or "",
		tips = specialDesInfo.desc or ""
	})
end

return PetPropertyCtrl
