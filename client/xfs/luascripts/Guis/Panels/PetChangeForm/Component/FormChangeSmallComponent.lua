-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetChangeForm\\Component\\FormChangeSmallComponent.lua

local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetData = require("Data.pet_data")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local NoticeDef = require("Common.NoticeDef")
local UIComponent = require("Guis.Helper.UIComponent")
local FormChangeSmallComponent = Class.LightClass("FormChangeSmallComponent", UIComponent)

function FormChangeSmallComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.txtWarningUBaseText = self.objectReference:GetRefValue("txtWarningUBaseText")
	self.rewardItemUButton = self.objectReference:GetRefValue("rewardItemUButton")
	self.avatar1 = self.objectReference:GetRefValue("avatar1")
	self.avatar2 = self.objectReference:GetRefValue("avatar2")
	self.cancelBtn = self.objectReference:GetRefValue("btnCancelUButton")
	self.confirmBtn = self.objectReference:GetRefValue("btnConfirmUButton")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")

	local avatar2ObjectReference = self.avatar2:GetComponent("ObjectReference")

	self.btnSreachUButton = avatar2ObjectReference:GetRefValue("btnSreachUButton")
	self.btnTriangleUButton = avatar2ObjectReference:GetRefValue("btnTriangleUButton")
end

function FormChangeSmallComponent:initView()
	function self.cancelBtn.luaClick()
		self.ctrl:dismiss()
	end

	function self.confirmBtn.luaClick()
		local res, resIdNumDict, resList = self.model:getRealCostData(self._targetTemplateId)

		if not res then
			pg.global.showBubbleMessageRaw(pg.getGameString("ITEM_NUM_LESS"))

			return
		end

		local canChangeForm = Utils.petCanChangeForm(pg.me, self._fromTemplateId, self._targetTemplateId) ~= false

		if canChangeForm then
			pg.global.ui.commonUseConfirm:open({
				title = pg.getGameString("CHANGE_FORM"),
				tipTop = self:getChangeFormConfirmTip(),
				data = resList,
				confirmCb = function()
					self:requestChangeForm()
				end,
				cancelCb = function()
					return
				end
			})
		else
			pg.global.showBubbleMessageById(NoticeDef.PET_FORM_CHANGE_PET_INVALID)

			return
		end
	end

	function self.btnSreachUButton.luaClick()
		self:hide()
		pg.global.ui:open(UIConst.UI_ID_PET_DETAIL, {
			templateId = self._targetTemplateId
		}, nil, function()
			self:show()
		end)
	end

	function self.btnTriangleUButton.luaClick()
		self.ctrl:tryChangePopupState(1)
	end

	function self.btnCloseUButton.luaClick()
		self.ctrl:dismiss()
	end
end

function FormChangeSmallComponent:getChangeFormConfirmTip()
	local tipTop
	local pet = self._petInfo and (pg.me:getPetInfo(self._petInfo.id) or self._petInfo)

	if pet and Utils.isLabelDark(pet.label) then
		tipTop = pg.getGameString("PET_DARK_DISAPPEAR_CONVERT_DESC")
	else
		tipTop = pg.getGameString("ACCESSORY_UNLOCK_DESC")
	end

	return tipTop
end

function FormChangeSmallComponent:requestChangeForm()
	pg.me:serverMsg("RPC_CS_StartChangeForm", self._petInfo.id, self._targetTemplateId)
	self.ctrl:dismiss()
end

function FormChangeSmallComponent:onDestroy()
	UIComponent.onDestroy(self)
end

function FormChangeSmallComponent:setChangeFormTarget(templateId, itemId)
	self._targetTemplateId = templateId
	self._curItemId = itemId
end

function FormChangeSmallComponent:setInfo(petInfo, itemId)
	self._petInfo = petInfo
	self._fromTemplateId = petInfo.templateId
	self._curItemId = itemId

	self:refreshInfo()
end

function FormChangeSmallComponent:refreshInfo()
	self:refreshAvatar()
	self:refreshItem()
end

function FormChangeSmallComponent:refreshAvatar()
	for i = 1, 2 do
		local root = self["avatar" .. i]
		local objectReference = root:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")
		local txtLockTipsUSDFText = objectReference:GetRefValue("txtLockTipsUSDFText")
		local formItemUWidget = objectReference:GetRefValue("formItemUWidget")

		if i == 1 then
			local pData = PetData[self._fromTemplateId]

			root:TryChangePage("State", 0)

			iconUImage.url = LuaUIUtils.getPetIcon(pData.iconName, LuaUIUtils.PET_ICON, self._petInfo.label, self._petInfo.gender)

			ClientTextUtils.setText(txtNameUBaseText, LuaUIUtils.getPetFormName(self._fromTemplateId))
			LuaUIUtils.renderFormItem(formItemUWidget, self._fromTemplateId)

			local UButton = formItemUWidget:GetComponent("UButton")

			LuaUIUtils.setPetTagLabelToolTip(UButton, LuaUIUtils.getPetTagInfo(self._fromTemplateId, self._petInfo.label, self.bodySizeType, self.shinyStyle))
		else
			local pData = PetData[self._targetTemplateId]

			iconUImage.url = LuaUIUtils.getPetIcon(pData.iconName, LuaUIUtils.PET_ICON)

			ClientTextUtils.setText(txtNameUBaseText, LuaUIUtils.getPetFormName(self._targetTemplateId))

			if self._isMagic then
				if Utils.petHasDemonicAvatar(self._targetTemplateId) then
					root:TryChangePage("State", 1)
				else
					root:TryChangePage("State", 2)
					ClientTextUtils.setText(txtLockTipsUSDFText, pg.getGameString("BLACK_SHINY_NOT_OPEN"))
				end
			else
				root:TryChangePage("State", 1)
			end

			LuaUIUtils.renderFormItem(formItemUWidget, self._targetTemplateId)

			local UButton = formItemUWidget:GetComponent("UButton")

			LuaUIUtils.setPetTagLabelToolTip(UButton, LuaUIUtils.getPetTagInfo(self._targetTemplateId, self._petInfo.label, self.bodySizeType, self.shinyStyle))
		end
	end
end

function FormChangeSmallComponent:refreshItem()
	local itemInfo = self.model:getNeedItemByTemplateId(self._targetTemplateId)

	if not itemInfo then
		return
	end

	itemInfo.num = itemInfo.ownNum + itemInfo.altOwnNum

	LuaUIUtils.renderRewardItem(self.rewardItemUButton, itemInfo, nil, nil, nil, nil, function()
		self.ctrl:dismiss()
	end)

	local objectReference = self.rewardItemUButton:GetComponent("ObjectReference")
	local txtNumUText = objectReference:GetRefValue("txtNumUText")
	local ownNum = itemInfo.ownNum + itemInfo.altOwnNum
	local usesAlternative = itemInfo.ownNum < itemInfo.needNum and itemInfo.altOwnNum > 0
	local preferredState = usesAlternative and UIConst.ITEM_STATE.EXCHANGE or UIConst.ITEM_STATE.FULL

	LuaUIUtils.renderConsumeText(txtNumUText, ownNum, itemInfo.needNum, preferredState)

	local warnKey = ""
	local canChange = self:canChangeMagic()

	if not itemInfo.res then
		if canChange then
			warnKey = "ITEM_NUM_LESS"
		end

		self.confirmBtn.visualInteractable = false
	else
		self.confirmBtn.visualInteractable = canChange
	end

	ClientTextUtils.setText(self.txtWarningUBaseText, pg.getGameString(warnKey))
end

function FormChangeSmallComponent:getFromTemplateId()
	return self._fromTemplateId
end

function FormChangeSmallComponent:canChangeMagic()
	if self._isMagic == true then
		return Utils.petHasDemonicAvatar(self._targetTemplateId)
	else
		return true
	end
end

function FormChangeSmallComponent:onHide()
	if self.view.blurPopUWidget then
		self.view.blurPopUWidget:SetActiveFastest(false)
	end
end

function FormChangeSmallComponent:onShow()
	if self.view.blurPopUWidget then
		self.view.blurPopUWidget:SetActiveFastest(true)
	end
end

return FormChangeSmallComponent
