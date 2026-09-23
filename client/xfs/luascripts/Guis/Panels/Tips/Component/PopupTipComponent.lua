-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Component\\PopupTipComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local PopupTipComponent = Class.LightClass("PopupTipComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local UIConst = require("Const.UIConst")

function PopupTipComponent:findObjects()
	self.textInfoUContainer = self.view.textInfoUContainer

	self.textInfoUContainer.gameObject:SetActiveEx(true)

	self.assess_data = {}
end

function PopupTipComponent:pushAssessPopTip(lvUp)
	local canInsert = true

	for _, v in ipairs(self.assess_data) do
		if v[1] == lvUp[1] then
			canInsert = false

			break
		end
	end

	if canInsert then
		table.insert(self.assess_data, lvUp)
	end

	self:checkPopAssessTip()
end

function PopupTipComponent:checkPopAssessTip()
	if #self.assess_data == 0 then
		return
	end

	if pg.global.ui:checkUIShow(UIConst.UI_ID_PLAYER_ASSESS) then
		return
	end

	local param = self.assess_data[1]

	pg.global.ui:open(UIConst.UI_ID_PLAYER_ASSESS, param, nil, function()
		table.remove(self.assess_data, 1)
		self:startTimer(function()
			self:checkPopAssessTip()
		end, 0.5)
	end)
end

function PopupTipComponent:openPopupTipInfo(data, onClose)
	if self.textInfoUContainer:CheckURLLoaded() then
		self:innerViewStarImprove(data, onClose)

		return
	end

	self.textInfoUContainer:LoadDefaultUrlManually(function()
		self:startFrameTimer(function()
			self:innerViewStarImprove(data, onClose)
		end, 1)
	end)
end

local TINDEX_TYPE = {
	SUBTITLE = 0,
	TEXT = 2,
	TEXT_ORDER = 1
}

function PopupTipComponent:checkDataValid(data)
	if not data then
		return
	end

	if not data.content or not data.content.info1 then
		return
	end

	if data.popUpType and data.popUpType > UIConst.DESCRIPTION_POP_UP_TYPE.HAVE_TAB and (not data.content.info2 or not data.tab1Name or not data.tab2Name) then
		return
	end

	return true
end

function PopupTipComponent:innerViewStarImprove(data, onClose)
	local inst = self.textInfoUContainer.content

	if IsNil(inst) then
		return
	end

	local closed = false

	local function closePopup()
		if closed then
			return
		end

		closed = true

		if onClose then
			onClose()
		end

		self.textInfoUContainer:DestroyContent()
	end

	local objectReference = inst.transform:GetComponent("ObjectReference")
	local btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	local btnConfirm = objectReference:GetRefValue("btnConfirm")
	local btnConfirmName = objectReference:GetRefValue("btnConfirmName")
	local txtTitleUBaseText = objectReference:GetRefValue("txtTitleUBaseText")
	local listUList = objectReference:GetRefValue("listUList")
	local tab1Text = objectReference:GetRefValue("tab1Text")
	local tab2Text = objectReference:GetRefValue("tab2Text")
	local tab01UButton = objectReference:GetRefValue("tab01UButton")
	local tab02UButton = objectReference:GetRefValue("tab02UButton")
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(inst.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = 10000
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.ClosePanelCommon

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			closePopup()
		end
	end

	function btnCloseUButton.luaClick()
		closePopup()
	end

	if not self:checkDataValid(data) then
		return
	end

	function listUList.luaRenderItem(button, index, itemData)
		local tIndex = itemData.tIndex
		local subItemObjectReference = button:GetComponent("ObjectReference")
		local textUBaseText = subItemObjectReference:GetRefValue("textUBaseText")

		if tIndex == TINDEX_TYPE.SUBTITLE then
			button:TryChangePage("haveBlank", index > 0 and 1 or 0)
			button:TryChangePage("Type", itemData.subTitleType == 1 and 1 or 0)
		end

		ClientTextUtils.setText(textUBaseText, pg.getLocalizationText(itemData.content))

		function textUBaseText.luaOnHyperlinkClick(str1, str2, contentRect)
			local effect = LuaUIUtils.resolveHyperTextEffect(str1)
			local tooltipAnchor = data.useHyperlinkAnchor and contentRect or nil

			LuaUIUtils.clickHyperText(str1, str2, textUBaseText, tooltipAnchor)

			if effect == LuaUIUtils.HYPERLINK_EFFECT.OTHER then
				closePopup()
			end
		end
	end

	if data.state then
		inst:TryChangePage("HaveBtn", UIConst.DESCRIPTION_POP_UP_TYPE.HAVE_BTN)

		local state = data.state

		function btnConfirm.luaClick()
			LuaUIUtils.startUPStarAssess()
			closePopup()
		end

		if state == "TiTileZero" then
			ClientTextUtils.setText(btnConfirmName, pg.getGameString("TO_UPGRADE_PLAYER_LV"))

			function btnConfirm.luaClick()
				LuaUIUtils.openQuestPanel()
				closePopup()
			end
		elseif state == "LvNotMatch" then
			btnConfirm:TryChangePage("button", 0)
			ClientTextUtils.setText(btnConfirmName, pg.getGameString("TO_UPGRADE_PLAYER_LV"))
		elseif state == "TimeNotMatch" then
			btnConfirm:TryChangePage("button", 4)
		elseif state == "Match" then
			btnConfirm:TryChangePage("button", 0)
			ClientTextUtils.setText(btnConfirmName, pg.getGameString("TO_ASSESS_TITLE"))

			function btnConfirm.luaClick()
				pg.global.ui.SpecialTrainNew:open()
				closePopup()
			end
		elseif state == "MaxStar" then
			btnConfirm:TryChangePage("button", 4)
			ClientTextUtils.setText(btnConfirmName, pg.getGameString("MAX_ASSESS_TITLE"))
		end
	elseif data.popUpType then
		inst:TryChangePage("HaveBtn", data.popUpType)

		if data.popUpType > 1 then
			ClientTextUtils.setText(tab1Text, pg.getLocalizationText(data.tab1Name))
			ClientTextUtils.setText(tab2Text, pg.getLocalizationText(data.tab2Name))

			function tab01UButton.luaClick()
				listUList:SetList(data.content.info1)

				tab01UButton.isSelected = true
				tab02UButton.isSelected = false
			end

			function tab02UButton.luaClick()
				listUList:SetList(data.content.info2)

				tab01UButton.isSelected = false
				tab02UButton.isSelected = true
			end
		end
	else
		inst:TryChangePage("HaveBtn", UIConst.DESCRIPTION_POP_UP_TYPE.NO_BTN)
	end

	listUList:SetList(data.content.info1)
	ClientTextUtils.setText(txtTitleUBaseText, pg.getGameString(data.title))
end

return PopupTipComponent
