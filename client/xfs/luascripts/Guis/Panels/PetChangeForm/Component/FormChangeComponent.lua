-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetChangeForm\\Component\\FormChangeComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("FormChangeComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local UIConst = require("Const.UIConst")
local NoticeDef = require("Common.NoticeDef")
local FormChangeSmallComponent = require("Guis.Panels.PetChangeForm.Component.FormChangeSmallComponent")
local FormChangeComponent = Class.LightClass("FormChangeComponent", FormChangeSmallComponent)
local Const = require("Common.Const.Const")

function FormChangeComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.titleText = self.objectReference:GetRefValue("titleText")
	self.rightUpCornerCloseBtn = self.objectReference:GetRefValue("rightUpCornerCloseBtn")
	self.cancelBtn = self.objectReference:GetRefValue("cancelBtn")
	self.confirmBtn = self.objectReference:GetRefValue("confirmBtn")
	self.petListUList = self.objectReference:GetRefValue("petListUList")
	self.rewardItemUButton = self.objectReference:GetRefValue("rewardItemUButton")
	self.avatar1 = self.objectReference:GetRefValue("avatar1")
	self.avatar2 = self.objectReference:GetRefValue("avatar2")
	self.txtWarningUBaseText = self.objectReference:GetRefValue("txtWarningUBaseText")

	local avatar2ObjectReference = self.avatar2:GetComponent("ObjectReference")

	self.btnSreachUButton = avatar2ObjectReference:GetRefValue("btnSreachUButton")
	self.btnTriangleUButton = avatar2ObjectReference:GetRefValue("btnTriangleUButton")
end

function FormChangeComponent:initView()
	function self.rightUpCornerCloseBtn.luaClick()
		self.ctrl:dismiss()
	end

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
				title = pg.getGameString("PET_EVOLVE_CONFIRM"),
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

	function self.petListUList.luaRenderItem(btn, index, data)
		self:onRenderPetItem(btn, index, data)
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
end

function FormChangeComponent:onRenderPetItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local btnDelUButton = objectReference:GetRefValue("btnDelUButton")
	local petName = objectReference:GetRefValue("nameUText")
	local hpBarUHealthbar = objectReference:GetRefValue("hpBarUHealthbar")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local numLevelUText = objectReference:GetRefValue("numLevelUText")
	local numCPUText = objectReference:GetRefValue("numCPUText")
	local elementsUList = objectReference:GetRefValue("elementsUList")
	local icon1UImage = objectReference:GetRefValue("icon1UImage")
	local icon2UImage = objectReference:GetRefValue("icon2UImage")
	local iconOrientationUImage = objectReference:GetRefValue("iconOrientationUImage")

	iconOrientationUImage.url = data.petTypeUrl
	button.name = index + 1
	button.draggable = false

	btnDelUButton.gameObject:SetActiveEx(false)

	function elementsUList.luaRenderItem(btn, idx, eleData)
		LuaUIUtils.setElementButtonNew(btn, eleData.element)
	end

	if data.customName and data.customName ~= "" then
		ClientTextUtils.setText(petName, data.customName)
	else
		ClientTextUtils.setText(petName, pg.getLocalizationText(data.name))
	end

	if data.isShiny then
		button:TryChangePage("isFlash", 1)
	elseif data.isBoss then
		button:TryChangePage("isFlash", 2)
	else
		button:TryChangePage("isFlash", 0)
	end

	if data.gender == Const.GENDER_TYPE_MALE then
		button:TryChangePage("Gender", 0)
	elseif data.gender == Const.GENDER_TYPE_FEMALE then
		button:TryChangePage("Gender", 1)
	else
		button:TryChangePage("Gender", 2)
	end

	iconUImage.url = LuaUIUtils.getPetIcon(data.iconName, LuaUIUtils.PET_ICON, data.label)

	elementsUList:SetList(data.elementNames)
	hpBarUHealthbar:TryChangePage("BarColor", 1)

	hpBarUHealthbar.hp = data.expRate
	hpBarUHealthbar.maxHp = 1

	local levelInfo = "LV." .. data.level

	if data.cp then
		numCPUText:SetActiveFastest(true)

		numCPUText.text = "CP:" .. data.cp
	else
		numCPUText:SetActiveFastest(false)
	end

	ClientTextUtils.setText(numLevelUText, levelInfo)
	button:TryChangePage("pet_number", index)

	function button.luaClick()
		self:onBtnClickPetItem(button)
	end

	button:TryChangePage("select", data.id == self._petInfo.id and 1 or 0)
end

function FormChangeComponent:onBtnClickPetItem(button)
	local data = button.dataFromUList
	local targetTemplateId = Utils.petCanChangeForm(pg.me, data.templateId)

	if targetTemplateId == false then
		pg.global.showBubbleMessageById(NoticeDef.PET_FORM_CHANGE_ITEM_INVALID)

		return
	end

	local itemInfo = self.model:getNeedItemByTemplateId(targetTemplateId)

	if not itemInfo then
		pg.global.showBubbleMessageById(NoticeDef.PET_FORM_CHANGE_ITEM_INVALID)

		return
	end

	self._fromTemplateId = data.templateId
	self._targetTemplateId = targetTemplateId
	self._curItemId = itemInfo.id
	self._petInfo = data

	self:refreshInfo()
end

function FormChangeComponent:onDestroy()
	UIComponent.onDestroy(self)
end

function FormChangeComponent:refreshInfo()
	FormChangeSmallComponent.refreshInfo(self)

	local dataList, index = self.model:getPetDataList(self._petInfo.id)

	self.petListUList:SetList(dataList)
	ClientTextUtils.setText(self.titleText, pg.getGameString("CHANGE_FORM"))
end

return FormChangeComponent
