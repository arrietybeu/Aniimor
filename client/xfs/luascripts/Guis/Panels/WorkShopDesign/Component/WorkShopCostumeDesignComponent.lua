-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\WorkShopDesign\\Component\\WorkShopCostumeDesignComponent.lua

local Class = require("Core.Framework.Class")
local ClientModelUtils = require("Utils.ClientModelUtils")
local UIComponent = require("Guis.Helper.UIComponent")
local UIConst = require("Const.UIConst")
local AppearancePointEnum = require("Data.appearance_point_enum")
local AvatarPresetData = require("Data.avatar_preset_data")
local AppearanceData = require("Data.appearance_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local WorkShopCostumeDesignComponent = Class.LightClass("WorkShopCostumeDesignComponent", UIComponent)

function WorkShopCostumeDesignComponent:findObjects()
	return
end

function WorkShopCostumeDesignComponent:initView()
	self._clothPresetDirty = false

	self:addListener()
end

function WorkShopCostumeDesignComponent:addListener()
	function self.view.btnStain.luaClick()
		self:onClickStain()
	end

	function self.view.btnFabric.luaClick()
		self:onClickFabric()
	end

	function self.view.btnPattern.luaClick()
		self:onClickPattern()
	end

	self.view.btnFabric.interactable = false
	self.view.btnPattern.interactable = false
	self.view.btnCut.interactable = false

	self.view.btnCut:TryChangePage("button", 4)
end

function WorkShopCostumeDesignComponent:onDestroy()
	UIComponent.onDestroy(self)
end

function WorkShopCostumeDesignComponent:onClickStain()
	self:onOpenStainPanel(1)
end

function WorkShopCostumeDesignComponent:onClickPattern()
	self:onOpenStainPanel(2)
end

function WorkShopCostumeDesignComponent:onClickFabric()
	self:onOpenStainPanel(3)
end

function WorkShopCostumeDesignComponent:onOpenStainPanel(mode)
	if self.selectClothId == nil or not AvatarUtils.isDyeingEnabled(self.selectClothId) then
		pg.global.showBubbleMessageRaw(pg.getGameString("APPEARANCE_CLOTH_DYEING_NOT_VALID"), 3)

		return
	end

	local claimed = pg.me.appearanceInfo[self.selectClothId] ~= nil and true or false

	if not claimed then
		pg.global.showBubbleMessageRaw(pg.getGameString("APPEARANCE_CLOTH_DYEING_NOT_OWNED"), 3)

		return
	end

	if not self.checkInitState then
		pg.global.showBubbleMessageRaw(pg.getGameString("APPEARANCE_CLOTH_INIT_FAIL"), 3)

		return
	end

	pg.global.ui:open(UIConst.UI_ID_WORKSHOP_COSTUME_STAIN, {
		clothId = self.selectClothId,
		slotId = self.slotId,
		mode = mode,
		unitData = self.model.curUnit
	})
end

function WorkShopCostumeDesignComponent:onEnterPage(slotId)
	self.view.rootComponent:TryChangePage("Design", "Dress")

	self.slotId = nil
	self.selectClothId = nil

	local slotList = self.model:getCostumeTabList()

	self.ctrl.slotOptionComponent.slotUList:SetList(slotList)

	local selectIndex = 0

	if slotId then
		for index, slotData in ipairs(slotList) do
			if slotData.slotId == slotId then
				selectIndex = index - 1
			end
		end
	end

	local res, button = self.ctrl.slotOptionComponent.slotUList:TryGetChildAt(selectIndex)

	if res then
		button:OnClickSimulate()
	end

	self.model.avatarScene:setAvatarCameraModeFar()
end

function WorkShopCostumeDesignComponent:onSlotSelectedChanged(data)
	self.slotId = data.slotId

	self:refreshClothesList(data.slotId, data.clothesId)
	self:updateSelectClothId()
end

function WorkShopCostumeDesignComponent:onOptionSelectedChanged(data)
	if not data then
		return
	end

	self:refreshSlotList()
end

function WorkShopCostumeDesignComponent:onOptionClicked(slotData, oldData, data, button)
	local curClothesId = self.model.avatarScene:getCurClothesId(self.ctrl.presetKey, slotData.slotId)

	if curClothesId == data.clothesId then
		if oldData and oldData == data then
			self:unEquipClothes(data.clothesId, slotData.slotId, not data.claimed)
		end
	else
		self:equipClothes(data.clothesId, slotData.slotId, not data.claimed)
	end
end

function WorkShopCostumeDesignComponent:onFilterSelectedChanged(slotData, filterFunc)
	self:refreshClothesList(self.slotId, slotData.clothesId, filterFunc)
end

function WorkShopCostumeDesignComponent:onFilterClicked(slotData, filterFunc)
	self:refreshClothesList(self.slotId, slotData.clothesId, filterFunc)
end

function WorkShopCostumeDesignComponent:onSearchChanged(slotData, filterFunc)
	self:refreshClothesList(self.slotId, slotData.clothesId, filterFunc)
end

function WorkShopCostumeDesignComponent:refreshClothesList(slotId, forceFirstClothesId, filterFunc)
	local optionList = self.model:getPartCloths(slotId, pg.game.avatar:getAvatarPresetData(self.ctrl.presetKey).body, forceFirstClothesId, filterFunc)

	self.ctrl.slotOptionComponent.optionUList:SetList(optionList)

	if forceFirstClothesId then
		self.ctrl.slotOptionComponent.optionUList:SelectItem(0)
	end
end

function WorkShopCostumeDesignComponent:onPartModelLoaded()
	self._clothPresetDirty = true

	self:refreshClothPreset()
end

function WorkShopCostumeDesignComponent:updateSelectClothId()
	local curClothId

	if self.slotId then
		curClothId = self.model.avatarScene:getCurClothesId(self.ctrl.presetKey, self.slotId)
	end

	if curClothId ~= self.selectClothId then
		self.selectClothId = curClothId
		self._clothPresetDirty = true

		self:refreshClothPreset()
	end
end

function WorkShopCostumeDesignComponent:refreshClothPreset()
	if self._clothPresetDirty then
		self.checkInitState = self.model:applyClothPreset(self.slotId, self.selectClothId)
		self._clothPresetDirty = true
	end
end

function WorkShopCostumeDesignComponent:refreshSlotList()
	local entity = self.model.avatarScene:getCurEntity()

	for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		local clothesId = entity:getAppearanceConfigId(partId)
		local index = partId - 11
		local data = self.ctrl.slotOptionComponent.slotUList:GetData(index)

		if clothesId == 0 or not LuaUIUtils.isClothesBelongToSlot(clothesId, partId) then
			data.state = LuaUIUtils.SLOT_STATE.EMPTY
			data.clothesId = 0
			data.icon = nil
			data.quality = nil
		else
			data.state = LuaUIUtils.SLOT_STATE.HAVE
			data.clothesId = clothesId

			local clothesData = LuaUIUtils.getClothesInfo(pg.me, clothesId)

			data.icon = clothesData.icon
			data.quality = clothesData.quality
		end

		self.ctrl.slotOptionComponent.slotUList:RefreshElement(index)
	end
end

function WorkShopCostumeDesignComponent:unEquipClothes(clothesId, slotId, isPreview)
	local entity = self.model.avatarScene:getCurEntity()

	if isPreview then
		local data = AppearanceData[clothesId] or {}

		if data.points then
			for _, point in ipairs(data.points) do
				entity:cancelCustomShowPreview(point)
			end
		end
	else
		entity:setCustomShow(clothesId, false)
	end

	self:refreshClothes(isPreview)
	self:refreshSlotList()
	self:updateSelectClothId()
end

function WorkShopCostumeDesignComponent:equipClothes(clothesId, slotId, isPreview)
	local entity = self.model.avatarScene:getCurEntity()

	if not entity then
		return
	end

	local function doEquip()
		if isPreview then
			entity:setCustomShowPreview(clothesId, true)
		else
			local data = AppearanceData[clothesId] or {}

			if data.points then
				for _, point in ipairs(data.points) do
					entity:cancelCustomShowPreview(point)
				end
			end

			entity:setCustomShow(clothesId, true)
		end

		self:refreshClothes(isPreview)
		self:refreshSlotList()
		self:updateSelectClothId()
	end

	AvatarUtils.tryEquipClothesWithConflictConfirm(entity, clothesId, isPreview, doEquip)
end

function WorkShopCostumeDesignComponent:refreshClothes(isPreview)
	local entity = self.model.avatarScene:getCurEntity()
	local modelView = entity.eModel.modelModelView

	for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		local clothesId = entity:getAppearanceConfigId(partId, isPreview)
		local data = AppearanceData[clothesId]

		ClientModelUtils.applyAppearancePart(entity, partId, clothesId, data and data.res)
	end

	ClientModelUtils.refreshModels(entity, modelView)
	AvatarUtils.applyEquippedClothesStain(entity, isPreview)
end

return WorkShopCostumeDesignComponent
