-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AccessoryPetBox\\AccessoryPetBoxCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local AccessoryPetBoxCtrl = Class.LightClass("AccessoryPetBoxCtrl", UICtrl)
local LuaUIUtils = require("Utils.LuaUIUtils")
local AbilityConst = require("Common.Const.AbilityConst")
local lume = require("Core.Common.lume")
local PetLevelData = require("Data.pet_level_data")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local ItemConst = require("Common.Const.ItemConst")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local HotkeyConst = require("Const.HotkeyConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetManagementUtils = require("Utils.PetManagementUtils")
local ElementPropData = require("Data.element_prop_data")

AccessoryPetBoxCtrl.messages = {}

function AccessoryPetBoxCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.sceneType = info.sceneType or UISceneConst.AVATAR_SCENE
	self.avatarScene = pg.game.uiScene:getScene(self.sceneType)
	self.selectCallback = info.selectCallback
	self.disableScenePreview = info.disableScenePreview
	self.browseCallback = info.browseCallback
	self.oldPetId = info.curPetId

	self:initUI()
end

function AccessoryPetBoxCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:previewAvatarPet(self.oldPetId)
			self:dismiss()
		end
	end

	function self.view.btnBack.luaClick()
		self:previewAvatarPet(self.oldPetId)
		self:dismiss()
	end

	function self.view.currencyList.luaRenderItem(button, index, data)
		self:onRenderCurrencyItem(button, data)
	end

	function self.view.listAccessories.luaRenderItem(button, index, data)
		self:onRenderAccessItem(button, data)
	end

	function self.view.element.luaRenderItem(button, _, data)
		LuaUIUtils.setElementButtonNew(button, data.element)
	end

	if self.view.btnElementUButton then
		function self.view.btnElementUButton.luaClick()
			if not self.selectPetFirstElement then
				return
			end

			pg.global.ui.tips:showRestraint(self.selectPetFirstElement.element)
		end
	end

	function self.view.btnWorkshop.luaClick()
		return
	end

	function self.view.btnConfirm.luaClick()
		self:onBtnConfirmSelect()
	end
end

function AccessoryPetBoxCtrl:afterInit()
	PetManagementUtils.initMsg(self)
end

function AccessoryPetBoxCtrl:onDestroy()
	self:_setCashShopPetSelectionPositionActive(false)
	PetManagementUtils.destroyTemplate()
	UICtrl.onDestroy(self)

	self.selectCallback = nil
	self.oldPetId = nil
end

function AccessoryPetBoxCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.sceneType = info.sceneType or self.sceneType or UISceneConst.AVATAR_SCENE
	self.avatarScene = pg.game.uiScene:getScene(self.sceneType)
	self.selectCallback = info.selectCallback
	self.disableScenePreview = info.disableScenePreview
	self.browseCallback = info.browseCallback
	self.oldPetId = info.curPetId
end

function AccessoryPetBoxCtrl:_setCashShopPetSelectionPositionActive(active)
	if self.sceneType ~= UISceneConst.CASH_SCENE or not self.avatarScene or not self.avatarScene.setPetSelectionPositionActive then
		return
	end

	self.avatarScene:setPetSelectionPositionActive(active)
end

function AccessoryPetBoxCtrl:onShow()
	self:_setCashShopPetSelectionPositionActive(true)

	self.curBoxIndex = 1
	self.curSortId = 0
	self.isDescending = true
	self.currentPetId = nil
	self.selectPetId = nil

	if string.isNilOrEmpty(self.oldPetId) then
		self.view.rootComponent:TryChangePage("Switch", 2)
	end

	self:refreshCurrencyList()
end

function AccessoryPetBoxCtrl:initUI()
	PetManagementUtils.setListButtonDelegateTable({
		selectedChanged = function(data)
			self:onSelectedChanged(data)
		end,
		renderExtraLogic = function(button, index, data)
			button.draggable = false
		end
	})
	PetManagementUtils.initSimpleMidTemplate(self.view.petList, {
		selectPetId = self.oldPetId
	})
end

function AccessoryPetBoxCtrl:refreshCurrencyList()
	local currencyData = self.model:getCurrencyData({
		ItemConst.ITEM_SPECIAL_MONEY_COIN
	})

	self.view.currencyList:SetList(currencyData)
end

function AccessoryPetBoxCtrl:onRenderCurrencyItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local countUText = objectReference:GetRefValue("countUText")
	local iconUImage = objectReference:GetRefValue("iconUImage")

	ClientTextUtils.setText(countUText, data.count)

	iconUImage.url = data.icon
end

function AccessoryPetBoxCtrl:getLockStatus(data)
	local temp = {}
	local isFavorite = data.isFavorite
	local inBattle = pg.game.petManage:getPetIsInBattle(data.id)
	local inExplore = false
	local explorePets = self.model:getPetExploreGroupPetsInModel(pg.me.curPetFormationIndex)
	local index = 0

	for i, v in pairs(explorePets) do
		if v == data.id then
			inExplore = true
			index = i

			break
		end
	end

	temp.isFavorite = isFavorite
	temp.inBattle = inBattle
	temp.inExplore = inExplore
	temp.k = index

	return temp
end

function AccessoryPetBoxCtrl:onSelectedChanged(data)
	if string.isNilOrEmpty(data.id) then
		self.view.rootComponent:TryChangePage("Switch", 2)

		return
	end

	if self.selectPetId ~= data.id then
		self:previewAvatarPet(data.id)
	end

	self.selectPetId = data.id

	if data.elementNames then
		self.selectPetFirstElement = data.elementNames[1]
	end

	self.view.rootComponent:TryChangePage("Switch", 1)
	self:refreshPetInfoView(data)

	local accessories = self.model:getAccessDataList(data.id)

	if #accessories == 0 then
		return
	end

	self.view.listAccessories:SetList(accessories)
end

function AccessoryPetBoxCtrl:refreshPetInfoView(data)
	local petNameStr = pg.getLocalizationText(self.model:getPetName(data.id))

	if pg.game.setting:getShowDebugId() then
		petNameStr = petNameStr .. tostring(data.templateId)
	end

	ClientTextUtils.setText(self.view.petName, petNameStr)
	self.view.element:SetList(data.elementNames)

	if data.isCatchReportingStatus then
		ClientTextUtils.setText(self.view.numCP, "CP ???")
	else
		ClientTextUtils.setText(self.view.numCP, "CP ", data.cp)
	end

	ClientTextUtils.setText(self.view.numLevel, data.level)

	local maxExp = PetLevelData[data.level + 1] ~= nil and PetLevelData[data.level + 1].needExp or 0

	self.view.expSlider.value = maxExp == 0 and 1 or data.exp / maxExp

	if data.gender == Const.GENDER_TYPE_MALE then
		self.view.titleUComponent:TryChangePage("Gender", 0)
	elseif data.gender == Const.GENDER_TYPE_FEMALE then
		self.view.titleUComponent:TryChangePage("Gender", 1)
	else
		self.view.titleUComponent:TryChangePage("Gender", 2)
	end

	self.view.titleUComponent:TryChangePage("isFlash", data.isShiny and 1 or 0)
end

function AccessoryPetBoxCtrl:onRenderAccessItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local rootUComponent = objectReference:GetRefValue("rootUComponent")
	local slotUImage = objectReference:GetRefValue("slotUImage")
	local emptySlotUImage = objectReference:GetRefValue("emptySlotUImage")

	rootUComponent:TryChangePage("state", data.state)

	if data.state == self.model.CONTENT_TAB.EMPTY then
		return
	end

	rootUComponent:TryChangePage("Quality", data.quality)

	iconUImage.url = data.icon
end

function AccessoryPetBoxCtrl:onBtnConfirmSelect()
	if string.isNilOrEmpty(self.selectPetId) then
		return
	end

	if self.selectCallback then
		self.selectCallback(self.selectPetId)
	end

	self:dismiss()
end

function AccessoryPetBoxCtrl:previewAvatarPet(petId)
	if self.disableScenePreview then
		if self.browseCallback then
			self.browseCallback(petId)
		end

		return
	end

	facade:SendMessageCommand(MessageName.PET_BOX_SELECTED, petId)
	self.avatarScene:setPivotOffsetX(0.4)
end

function AccessoryPetBoxCtrl:onHide()
	self:_setCashShopPetSelectionPositionActive(false)

	if self.disableScenePreview then
		return
	end

	self.avatarScene:setPivotOffsetX(0)
end

function AccessoryPetBoxCtrl:checkUIShowVirtualMouseCursor()
	return false
end

return AccessoryPetBoxCtrl
