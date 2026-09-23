-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetChangeForm\\Component\\PetFormDetailComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetFormDetailComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local NoticeDef = require("Common.NoticeDef")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local PetFormDetailComponent = Class.LightClass("PetFormDetailComponent", UIComponent)

function PetFormDetailComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnCloseFullScreen = self.objectReference:GetRefValue("btnCloseFullScreen")
	self.btnClose = self.objectReference:GetRefValue("btnClose")
	self.listCardUList = self.objectReference:GetRefValue("listCardUList")
	self.textNameUBaseText = self.objectReference:GetRefValue("textNameUBaseText")
end

function PetFormDetailComponent:initView()
	function self.btnCloseFullScreen.luaClick()
		self.ctrl:tryChangePopupState(0)
	end

	function self.btnClose.luaClick()
		self.ctrl:tryChangePopupState(0)
	end

	function self.listCardUList.luaRenderItem(button, index, data)
		self:onRenderCardItem(button, index, data)
	end
end

function PetFormDetailComponent:onDestroy()
	UIComponent.onDestroy(self)
end

function PetFormDetailComponent:onRenderCardItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local petNameText = objectReference:GetRefValue("petName")
	local itemIcon = objectReference:GetRefValue("itemIcon")
	local itemNumText = objectReference:GetRefValue("itemNumText")
	local formItemUWidget = objectReference:GetRefValue("formItemUWidget")
	local itemInfo = self.model:getNeedItemByTemplateId(data.templateId)
	local isCatched = data.isCatched
	local canChangeMagic = self:canChangeMagic(data.templateId)

	if isCatched then
		if canChangeMagic then
			button:TryChangePage("State", "Acquired")
		else
			button:TryChangePage("State", "Lock")
		end
	else
		button:TryChangePage("State", "NotAcquired")
	end

	LuaUIUtils.renderFormItem(formItemUWidget, data.templateId)

	function button.luaClick()
		if isCatched then
			if canChangeMagic == false then
				pg.global.showBubbleMessageById(NoticeDef.PET_NO_DARK)
			else
				self.ctrl:setChangeFormTarget(data.templateId, itemInfo.id)
			end
		else
			pg.global.showBubbleMessageById(NoticeDef.PET_FORM_CHANGE_PET_INVALID)
		end
	end

	iconUImage.url = LuaUIUtils.getPetIcon(data.iconName, LuaUIUtils.PET_CARD_ILLUSTRATE_BOOK)

	if isCatched then
		ClientTextUtils.setText(petNameText, LuaUIUtils.getPetFormName(data.templateId))

		itemIcon.url = itemInfo.icon

		local usesAlternative = itemInfo.ownNum < itemInfo.needNum and itemInfo.altOwnNum > 0
		local preferredState = usesAlternative and UIConst.ITEM_STATE.EXCHANGE or UIConst.ITEM_STATE.FULL

		LuaUIUtils.renderConsumeText(itemNumText, itemInfo.ownNum + itemInfo.altOwnNum, itemInfo.needNum, preferredState)
	end
end

function PetFormDetailComponent:openPetFormDetail(petInfo)
	local fromTemplateId = petInfo.templateId

	self._targetPetInfoList = self.model:getAllTargetInfo(fromTemplateId)

	self.listCardUList:SetList(self._targetPetInfoList)
	ClientTextUtils.setText(self.textNameUBaseText, pg.getGameString("PET_FORM_NAME"))
end

function PetFormDetailComponent:canChangeMagic(templateId)
	if self._isMagic == true then
		return Utils.petHasDemonicAvatar(templateId)
	else
		return true
	end
end

return PetFormDetailComponent
