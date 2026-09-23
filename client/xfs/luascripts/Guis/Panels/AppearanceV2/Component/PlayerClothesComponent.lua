-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AppearanceV2\\Component\\PlayerClothesComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local CallbackHandler = require("Core.Common.CallbackHandler")
local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("CreatePlayerCtrl")
local Utils = require("Common.Utils.Utils")
local ClientConst = require("Const.ClientConst")
local RedDotConst = require("Const.RedDotConst")
local UIComponent = require("Guis.Helper.UIComponent")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local ClientModelUtils = require("Utils.ClientModelUtils")
local WorkShopCostumeDesignComponent = require("Guis.Panels.WorkShopDesign.Component.WorkShopCostumeDesignComponent")
local AppearanceData = require("Data.appearance_data")
local AppearancePointData = require("Data.appearance_point_data")
local AvatarPresetData = require("Data.avatar_preset_data")
local AppearancePointEnum = require("Data.appearance_point_enum")
local AppearanceSuitData = require("Data.appearance_suit_data")
local ItemData = require("Data.item_data")
local Const = require("Common.Const.Const")
local FunctionEnum = require("Data.function_unlock_enum")
local TimerManager = require("Core.Timer.TimerManager")
local PlayerClothesComponent = Class.LightClass("PlayerClothesComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")

function PlayerClothesComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.nameUText = self.objectReference:GetRefValue("nameUText")
	self.designUButton = self.objectReference:GetRefValue("designUButton")
	self.titleUButton = self.objectReference:GetRefValue("titleUButton")
	self.operationUList = self.objectReference:GetRefValue("operationUList")
	self.cancelUButton = self.objectReference:GetRefValue("cancelUButton")
	self.saveUButton = self.objectReference:GetRefValue("saveUButton")
	self.detailsUBaseText = self.objectReference:GetRefValue("detailsUBaseText")
	self.workshopUButton = self.objectReference:GetRefValue("workshopUButton")
	self.btnFashionValueIconUButton = self.objectReference:GetRefValue("btnFashionValueIconUButton")
	self.btnFashionValue = self.objectReference:GetRefValue("btnFashionValue")
	self.rootUComponent = self.ctrl.rootUComponent
	self.sourceUList = self.ctrl.sourceUList
	self.presetTitleUBaseText = self.ctrl.presetTitleUBaseText
	self.presetNumUBaseText = self.ctrl.presetNumUBaseText
	self.presetUList = self.ctrl.presetUList
	self.presetPartUList = self.ctrl.presetPartUList
end

function PlayerClothesComponent:initView()
	self.avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
	self.slotOptionComponent = self.ctrl.slotOptionComponent
	self.presetKey = self.ctrl.curPresetKey
end

function PlayerClothesComponent:addListener()
	function self.workshopUButton.luaClick()
		if not pg.me:checkFunctionUnlock(FunctionEnum.APPEARANCE_COSTUME_CUSTOM) then
			pg.global.showBubbleMessageRaw(LuaUIUtils.getFunctionUnlockDesc(FunctionEnum.APPEARANCE_COSTUME_CUSTOM, true), 3)

			return
		end

		local slotData = self.slotOptionComponent.slotUList.selectedItem
		local optionData = self.slotOptionComponent.optionUList.selectedItem

		if self:isSuit(slotData) then
			pg.global.ui:open(UIConst.UI_ID_WORKSHOP_DESIGN, {
				type = AvatarUtils.DESIGN_TYPE.COSTUME,
				component = WorkShopCostumeDesignComponent
			})
		else
			local entity = self.avatarScene:getCurEntity()
			local checkInitState = AvatarUtils.applyClothesPreset(entity, slotData.slotId, optionData.clothesId)

			if checkInitState then
				pg.global.ui:open(UIConst.UI_ID_WORKSHOP_COSTUME_STAIN, {
					mode = 1,
					clothId = optionData.clothesId,
					slotId = slotData.slotId
				})
			else
				pg.global.showBubbleMessageRaw(pg.getGameString("APPEARANCE_CLOTH_INIT_FAIL"), 3)
			end
		end
	end
end

function PlayerClothesComponent:removeListener()
	return
end

function PlayerClothesComponent:onDestroy()
	UIComponent.onDestroy(self)

	self.slotOptionComponent = nil
	self.avatarScene = nil
end

function PlayerClothesComponent:getSlotListEquippedSuitId()
	local entity = self.avatarScene:getCurEntity()

	if not entity then
		return nil
	end

	return LuaUIUtils.tryGetEquippedSuitId(entity, entity.customShow)
end

function PlayerClothesComponent:getSlotListEquippedClothesId(slotId)
	local entity = self.avatarScene:getCurEntity()

	if not entity or not slotId then
		return nil
	end

	local clothesId = entity:getAppearanceConfigId(slotId, false)

	if not clothesId or clothesId == 0 then
		return nil
	end

	if not LuaUIUtils.isClothesBelongToSlot(clothesId, slotId) then
		return nil
	end

	return clothesId
end

function PlayerClothesComponent:resolveForceFirstClothesId(itemId, isSuit)
	if not itemId or itemId == 0 then
		return nil
	end

	local info

	if isSuit then
		info = LuaUIUtils.getSuitInfo(pg.me, itemId, false)
	else
		info = LuaUIUtils.getClothesInfo(pg.me, itemId)
	end

	if info and info.claimed then
		return itemId
	end

	return nil
end

function PlayerClothesComponent:onEnterPage()
	self:addListener()
	self:initSlotList()

	local slot0 = self.slotOptionComponent:getSlotData(0)
	local visualId = self.avatarScene:getCurSuitId(self.presetKey) or slot0 and (slot0.clothesId or slot0.suitId)
	local forceFirstId = self:resolveForceFirstClothesId(visualId, true) or self:resolveForceFirstClothesId(visualId, false) or self:resolveForceFirstClothesId(slot0 and (slot0.clothesId or slot0.suitId), slot0 and self:isSuit(slot0))

	self:initOptionList(forceFirstId)
	self.slotOptionComponent:setFilterRule()
	self.slotOptionComponent:reset()
	self.slotOptionComponent.slotUList:SelectItem(0)
	self.avatarScene:setAvatarCameraModeFar()
	self:setEnterRightInfo()
end

function PlayerClothesComponent:setEnterRightInfo()
	local slotData = self.slotOptionComponent.slotUList.selectedItem or self.slotOptionComponent:getSlotData(0)

	if not slotData then
		return
	end

	self:selectWornOptionInList(slotData)
end

function PlayerClothesComponent:selectWornOptionInList(slotData, skipRightInfo)
	local optionUList = self.slotOptionComponent.optionUList
	local targetId

	if self:isSuit(slotData) then
		targetId = self.avatarScene:getCurSuitId(self.presetKey)
	else
		targetId = self.avatarScene:getCurClothesId(self.presetKey, slotData.slotId)
	end

	if not targetId or targetId == 0 then
		optionUList:DeselectAll()

		if not skipRightInfo then
			self:refreshPageUnEquip()
		end

		return
	end

	for index = 0, optionUList.itemCount - 1 do
		local optionData = optionUList:GetData(index)

		if optionData and (optionData.suitId == targetId or optionData.clothesId == targetId or optionData.itemId == targetId) then
			optionUList:SelectItem(index)

			if not skipRightInfo then
				self:refreshPageEquip(optionData)
			end

			return
		end
	end

	if skipRightInfo then
		return
	end

	local cData

	if self:isSuit(slotData) then
		cData = LuaUIUtils.getSuitInfo(pg.me, targetId, true)
	else
		cData = LuaUIUtils.getClothesInfo(pg.me, targetId)
	end

	if cData then
		self:refreshPageEquip(cData)
	else
		self:refreshPageUnEquip()
	end
end

function PlayerClothesComponent:refreshPage(ignoreSelectFirst, itemId)
	local keepSlotIndex = ignoreSelectFirst and self.slotOptionComponent.slotUList.selectedIndex or nil

	self:initSlotList(ignoreSelectFirst, itemId, keepSlotIndex)

	local slotData = self.slotOptionComponent.slotUList.selectedItem or self.slotOptionComponent:getSlotData(0)
	local forceFirstId

	if slotData then
		local isSuit = self:isSuit(slotData)

		if isSuit then
			forceFirstId = self.avatarScene:getCurSuitId(self.presetKey) or slotData.suitId
		else
			forceFirstId = self.avatarScene:getCurClothesId(self.presetKey, slotData.slotId) or slotData.clothesId
		end

		forceFirstId = self:resolveForceFirstClothesId(forceFirstId, isSuit) or self:resolveForceFirstClothesId(isSuit and slotData.suitId or slotData.clothesId, isSuit)
	end

	if itemId and forceFirstId == itemId then
		forceFirstId = self:resolveForceFirstClothesId(itemId, slotData and self:isSuit(slotData))
	end

	self:initOptionList(forceFirstId, nil, ignoreSelectFirst)
	self.slotOptionComponent:setFilterRule()
	self.slotOptionComponent:reset()

	if ignoreSelectFirst then
		if slotData then
			self:selectWornOptionInList(slotData, true)
		end

		return
	end

	self.slotOptionComponent.slotUList:SelectItem(0)
end

function PlayerClothesComponent:onSlotSelectedChanged(data)
	if self:isSuit(data) then
		local curSuitId = self.avatarScene:getCurSuitId(self.presetKey)
		local forceFirstId = self:resolveForceFirstClothesId(curSuitId, true) or self:resolveForceFirstClothesId(data.suitId, true)

		self:initOptionList(forceFirstId)
		self:selectWornOptionInList(data)
	elseif data.state == LuaUIUtils.SLOT_STATE.HAVE then
		self:initOptionList(self:resolveForceFirstClothesId(data.clothesId, false))
		self:selectWornOptionInList(data)
	else
		self:initOptionList()
		self:refreshPageUnEquip()
	end
end

function PlayerClothesComponent:onSlotClicked(oldData, data)
	if not oldData or oldData ~= data then
		return
	end

	if oldData.state == LuaUIUtils.SLOT_STATE.HAVE then
		if self:isSuit(oldData) then
			self:unEquipSuit(oldData.suitId)
		else
			self:unEquipClothes(oldData.clothesId, oldData.slotId)
		end

		self:refreshPageUnEquip()
	end
end

function PlayerClothesComponent:refreshPageUnEquip()
	self.rootUComponent:TryChangePage("State", "Normal")
	self:passToRightInfoComponent(self.rootUComponent)
end

function PlayerClothesComponent:refreshPageEquip(data)
	local extra

	self.rootUComponent:TryChangePage("State", "Detail")

	if data.claimed and AvatarUtils.isDyeingEnabled(data.itemId) then
		self.rootUComponent:TryChangePage("detail", "setting")
		self.rootUComponent:TryChangePage("BtnType", 0)
	else
		self.rootUComponent:TryChangePage("detail", "source")
		self.rootUComponent:TryChangePage("BtnType", 3)
		self:refreshSourceList(data.itemId)
	end

	ClientTextUtils.setText(self.nameUText, pg.getLocalizationText(data.name))
	ClientTextUtils.setText(self.btnFashionValue, data.fashion)

	function self.btnFashionValueIconUButton.luaRenderTooltip(btn, prop)
		self.view:renderFashionTips(prop, data.fashion)
	end

	extra = {
		name = pg.getLocalizationText(data.name),
		fashion = data.fashion,
		id = data.itemId,
		claimed = data.claimed,
		refreshCallback = function()
			if AvatarUtils.isDyeingEnabled(data.itemId) then
				self.rootUComponent:TryChangePage("detail", "setting")
				self.rootUComponent:TryChangePage("BtnType", 0)
			else
				self.rootUComponent:TryChangePage("detail", "source")
				self.rootUComponent:TryChangePage("BtnType", 3)
			end

			extra.claimed = true

			self:passToRightInfoComponent(self.rootUComponent, extra)
			self:refreshPage()
		end
	}

	if not ItemData[data.itemId] or not ItemData[data.itemId].itemDes then
		ClientTextUtils.setText(self.detailsUBaseText, "")

		extra.desc = ""

		self:passToRightInfoComponent(self.rootUComponent, extra)

		return
	end

	extra.desc = pg.getLocalizationText(ItemData[data.itemId].itemDes)

	ClientTextUtils.setText(self.detailsUBaseText, pg.getLocalizationText(ItemData[data.itemId].itemDes))
	self:passToRightInfoComponent(self.rootUComponent, extra)
end

function PlayerClothesComponent:onOptionClicked(slotData, oldData, data, button)
	if self:isSuit(slotData) then
		local curSuitId = self.avatarScene:getCurSuitId(self.presetKey)

		if curSuitId == data.suitId then
			if oldData and oldData == data then
				self:unEquipSuit(data.suitId, not data.claimed)
				self:refreshPageUnEquip()
			else
				self:refreshPageEquip(data)
			end
		else
			self:equipSuit(data.suitId, not data.claimed)
			self:refreshPageEquip(data)
		end
	else
		local curClothesId = self.avatarScene:getCurClothesId(self.presetKey, slotData.slotId)

		if curClothesId == data.clothesId then
			if oldData and oldData == data then
				self:unEquipClothes(data.clothesId, slotData.slotId, not data.claimed)
				self:refreshPageUnEquip()
			end
		else
			self:equipClothes(data.clothesId, slotData.slotId, not data.claimed, function()
				self:refreshPageEquip(data)
			end, function()
				self:selectWornOptionInList(slotData, true)
			end)
		end
	end

	if data.claimed and data.showRedDot then
		local treePath = string.format(RedDotConst.RedDotPath.APPEARANCE_OPTION_LIST_ITEM, data.itemId)

		pg.me:setRedDotRecord(Const.CLIENT_KEY.APPEARANCE_RED_DOT, treePath, false)

		data.showRedDot = false

		local optionUList = self.slotOptionComponent.optionUList
		local index = optionUList:GetChildIndex(button)

		optionUList:RefreshElement(index)
	end
end

function PlayerClothesComponent:onFilterSelectedChanged(slotData, filterFunc)
	self.filterFunc = filterFunc

	self:initOptionList(slotData.clothesId or slotData.suitId, filterFunc)
end

function PlayerClothesComponent:onFilterClicked(slotData, filterFunc)
	self.filterFunc = filterFunc

	self:initOptionList(slotData.clothesId or slotData.suitId, filterFunc)
end

function PlayerClothesComponent:onSearchChanged(slotData, filterFunc)
	self.filterFunc = filterFunc

	self:initOptionList(slotData.clothesId or slotData.suitId, filterFunc)
end

function PlayerClothesComponent:initSlotList(ignoreSelectFirst, itemId, keepSlotIndex)
	local entity = self.avatarScene:getEntity(self.presetKey)
	local equipList = self.model:getClothesEquipInfoList(entity.customShow)

	self.slotOptionComponent.slotUList:SetList(equipList)

	if ignoreSelectFirst then
		local index = keepSlotIndex

		if index == nil or index < 0 or index >= self.slotOptionComponent.slotUList.itemCount then
			index = 0
		end

		self.slotOptionComponent.slotUList:SelectItem(index, false)

		return
	end

	self.slotOptionComponent.slotUList:SelectItem(0, false)
end

function PlayerClothesComponent:refreshSlotList()
	local entity = self.avatarScene:getCurEntity()
	local suitData = self.slotOptionComponent.slotUList:GetData(0)
	local suitId = self:getSlotListEquippedSuitId()

	if suitId then
		local itemData = ItemData[suitId] or {}

		suitData.state = LuaUIUtils.SLOT_STATE.HAVE
		suitData.suitId = suitId
		suitData.icon = itemData.icon
		suitData.quality = itemData.quality
	else
		suitData.state = LuaUIUtils.SLOT_STATE.EMPTY
	end

	self.slotOptionComponent.slotUList:RefreshElement(0)

	for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		local clothesId = entity:getAppearanceConfigId(partId)
		local index = partId - 10
		local data = self.slotOptionComponent.slotUList:GetData(index)

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

		self.slotOptionComponent.slotUList:RefreshElement(index)
	end
end

function PlayerClothesComponent:refreshOptionList()
	local slotData = self.slotOptionComponent.slotUList.selectedItem
	local data = self.slotOptionComponent.optionUList.itemData

	if not slotData then
		return
	end

	local entity = self.avatarScene:getCurEntity()

	if self:isSuit(slotData) then
		local suitId = self:getSlotListEquippedSuitId()

		for _, v in pairs(data) do
			v.equipped = suitId and v.suitId == suitId
			v.state = v.equipped and LuaUIUtils.SELECT_STATE.ROLE_WEAR or v.claimed and LuaUIUtils.SELECT_STATE.HAVE or LuaUIUtils.SELECT_STATE.LOCKED
			v.occupyConflict = false
		end
	else
		local slotId = slotData.slotId
		local curClothesId = self:getSlotListEquippedClothesId(slotId)

		for _, v in pairs(data) do
			v.equipped = curClothesId and v.clothesId == curClothesId
			v.state = v.equipped and LuaUIUtils.SELECT_STATE.ROLE_WEAR or v.claimed and LuaUIUtils.SELECT_STATE.HAVE or LuaUIUtils.SELECT_STATE.LOCKED
		end

		AvatarUtils.markClothesOccupyConflictFlags(entity, data)
	end

	self.slotOptionComponent.optionUList:RefreshList()
end

function PlayerClothesComponent:initOptionList(forceFirstClothesId, filterFunc, ignoreSelectFirst)
	local slotData = self.slotOptionComponent.slotUList.selectedItem

	if not slotData then
		return
	end

	filterFunc = filterFunc or self.filterFunc

	local presetData = pg.game.avatar:getAvatarPresetData(self.presetKey) or {}
	local optionList = {}
	local entity = self.avatarScene:getCurEntity()

	if self:isSuit(slotData) then
		local displaySuitId = self:getSlotListEquippedSuitId()

		optionList = self.model:getSuitList(presetData.body, forceFirstClothesId, filterFunc, displaySuitId) or {}

		for _, v in pairs(optionList) do
			v.occupyConflict = false
		end
	else
		optionList = self.model:getClothesInfoList(slotData.slotId, presetData.body, forceFirstClothesId, filterFunc)

		AvatarUtils.markClothesOccupyConflictFlags(entity, optionList)
	end

	self.slotOptionComponent.optionUList:SetList(optionList)
	self:refreshOptionList()

	for index, optionData in ipairs(optionList) do
		if optionData.itemId == forceFirstClothesId then
			local res, btn = self.slotOptionComponent.optionUList:TryGetChildAt(index - 1)

			if res then
				-- block empty
			end

			break
		end
	end

	if ignoreSelectFirst then
		return
	end

	local wearedCount = 0

	for _, v in pairs(optionList) do
		if v.state == "RoleWear" then
			wearedCount = wearedCount + 1
		end
	end

	if not forceFirstClothesId and wearedCount <= 0 then
		self:refreshPageUnEquip()
	end
end

function PlayerClothesComponent:selectSuitOnOpen(suitId)
	if not suitId then
		return
	end

	self.slotOptionComponent.slotUList:SelectItem(0)
	self:initOptionList(suitId)

	local optionUList = self.slotOptionComponent.optionUList

	for index = 0, optionUList.itemCount - 1 do
		local optionData = optionUList:GetData(index)

		if optionData and (optionData.suitId == suitId or optionData.itemId == suitId) then
			local res, btn = optionUList:TryGetChildAt(index)

			if res then
				btn:OnClickSimulate()
			end

			break
		end
	end
end

function PlayerClothesComponent:refreshSourceList(clothesId)
	local sourceList = self:getSourceList(clothesId)

	self.sourceUList:SetList(sourceList)
end

function PlayerClothesComponent:getSourceList(itemId)
	local list = {}
	local configData = AppearanceData[itemId] or AppearanceSuitData[itemId] or {}

	if configData.shopClassifyId or configData.shopId then
		table.insert(list, {
			text = pg.getGameString("ACCESSORY_SOURCE_SHOP"),
			func = function()
				if LuaUIUtils.checkFuncTemporaryDisable(UIConst.UI_ID_SHOP_MAIN) then
					return
				end

				pg.global.ui:open(UIConst.UI_ID_SHOP_MAIN, {
					shopTags = {
						configData.shopClassifyId
					},
					shopTag = configData.shopId
				}, nil, function()
					self:onEnterPage()
				end)
			end
		})
	end

	return list
end

function PlayerClothesComponent:applyClothesStainForEntity(entity, isPreview)
	if entity.previewOutfitId then
		ClientModelUtils.applyOutfitClothesStain(entity, entity.previewOutfitId)
	elseif isPreview and entity.customShowPreview and next(entity.customShowPreview) then
		AvatarUtils.applyEquippedClothesStain(entity, true, true)
	else
		ClientModelUtils.applyClothesStainInfo(entity, entity.curShow)
	end
end

function PlayerClothesComponent:refreshClothes(isPreview)
	local entity = self.avatarScene and self.avatarScene:getCurEntity()

	if not entity or not entity.eModel then
		return
	end

	local modelView = entity.eModel.modelModelView
	local modelInfo = modelView and modelView.modelInfo
	local partModelInfo = modelInfo and modelInfo.partModelInfo

	if not modelView or not partModelInfo then
		return
	end

	for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		local clothesId = entity:getAppearanceConfigId(partId, true, true)
		local data = AppearanceData[clothesId]

		ClientModelUtils.applyAppearancePart(entity, partId, clothesId, data and data.res)
	end

	ClientModelUtils.refreshModels(entity, modelView)
	self:applyClothesStainForEntity(entity, isPreview)
end

function PlayerClothesComponent:onPartModelLoaded()
	if not self.avatarScene then
		return
	end

	local entity = self.avatarScene:getCurEntity()

	if not entity then
		return
	end

	self:applyClothesStainForEntity(entity, entity.customShowPreview and next(entity.customShowPreview))
end

function PlayerClothesComponent:getShowAnimKey(clothesId, slotId)
	local clothesData = AppearanceData[clothesId] or {}

	if clothesData.playable then
		return clothesData.playable
	end

	slotId = slotId == AppearancePointEnum.Shoes and AppearancePointEnum.Socks or slotId

	local pointName = AppearancePointData[slotId] and AppearancePointData[slotId].name or "Coat"

	return "Show_Change" .. pointName
end

function PlayerClothesComponent:getSuitShowAnimKey(suitId)
	local suitData = AppearanceSuitData[suitId] or {}

	for _, clothesId in ipairs(suitData.appearanceList or EMPTY_TABLE) do
		local clothesData = AppearanceData[clothesId]

		if clothesData and clothesData.playable then
			return clothesData.playable
		end
	end

	return "Show_Change" .. (AppearancePointData[AppearancePointEnum.Coat].name or "Coat")
end

function PlayerClothesComponent:playShowAnim(clothesId, slotId)
	self.avatarScene:playShowAnimation(self.presetKey, self:getShowAnimKey(clothesId, slotId))
end

function PlayerClothesComponent:unEquipClothes(clothesId, slotId, isPreview)
	local entity = self.avatarScene:getCurEntity()

	if not entity then
		return
	end

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
	self:refreshOptionList()
	self.slotOptionComponent.optionUList:DeselectAll()
end

function PlayerClothesComponent:equipClothes(clothesId, slotId, isPreview, onSuccess, onCancel)
	local entity = self.avatarScene:getCurEntity()

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
		self:refreshOptionList()
		self:playShowAnim(clothesId, slotId)

		if onSuccess then
			onSuccess()
		end
	end

	AvatarUtils.tryEquipClothesWithConflictConfirm(entity, clothesId, isPreview, doEquip, onCancel)
end

function PlayerClothesComponent:unEquipSuit(suitId, isPreview)
	local entity = self.avatarScene:getCurEntity()

	if not entity then
		return
	end

	local suitData = AppearanceSuitData[suitId] or {}
	local appearanceList = suitData.appearanceList or {}

	if isPreview then
		for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
			entity:cancelCustomShowPreview(partId)
		end
	else
		for _, clothesId in ipairs(appearanceList) do
			entity:setCustomShow(clothesId, false)
		end
	end

	self:refreshClothes(isPreview)
	self:refreshSlotList()
	self:refreshOptionList()
	self.slotOptionComponent.optionUList:DeselectAll()
end

function PlayerClothesComponent:equipSuit(suitId, isPreview)
	local entity = self.avatarScene:getCurEntity()

	if not entity or not entity.cancelCustomShowPreview then
		return
	end

	local suitData = AppearanceSuitData[suitId] or {}
	local appearanceList = suitData.appearanceList or {}

	if isPreview then
		for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
			entity:cancelCustomShowPreview(partId, true)
		end

		for _, clothesId in ipairs(appearanceList) do
			entity:setCustomShowPreview(clothesId, true)
		end
	else
		for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
			entity:cancelCustomShowPreview(partId)
			entity:cancelCustomShow(partId, true)
		end

		for _, clothesId in ipairs(appearanceList) do
			entity:setCustomShow(clothesId, true)
		end
	end

	self:refreshClothes(isPreview)
	self:refreshSlotList()
	self:refreshOptionList()
	self.avatarScene:playShowAnimation(self.presetKey, self:getSuitShowAnimKey(suitId))
end

function PlayerClothesComponent:isSuit(slotItem)
	return slotItem.part == "Suit"
end

function PlayerClothesComponent:postRenderOptionList(button, index, data)
	if not data or not button then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local rootUComponent = objectReference and objectReference:GetRefValue("rootUComponent")

	if not rootUComponent then
		return
	end

	if data.claimed then
		rootUComponent:TryChangePage("Conflict", data.occupyConflict and 1 or 0)
	else
		rootUComponent:TryChangePage("Conflict", 0)
	end
end

function PlayerClothesComponent:onEnterPreset(selectPartId)
	local slotData = self.slotOptionComponent.slotUList.selectedItem
	local optionData = self.slotOptionComponent.optionUList.selectedItem

	if self:isSuit(slotData) then
		self.rootUComponent:TryChangePage("HavePart", "HavePart")
		self:refreshPresetPartList(optionData.suitId, selectPartId)
	else
		self.rootUComponent:TryChangePage("HavePart", "NoPart")
		self:refreshPresetList(optionData.clothesId)
	end

	self.avatarScene:setAvatarCameraModeFar()
	self.avatarScene:setCameraRotationOffset(1.5)
	self.view.topbarUWidget:SetActiveFastest(false)
end

function PlayerClothesComponent:onLeavePreset()
	self.avatarScene:setCameraRotationOffset(0)
	self.view.topbarUWidget:SetActiveFastest(true)
end

function PlayerClothesComponent:refreshPresetList(clothesId)
	if clothesId then
		self.presetClothesId = clothesId
	else
		clothesId = self.presetClothesId
	end

	ClientTextUtils.setText(self.presetTitleUBaseText, pg.getGameString("APPEARANCE_PRESET"))

	local usedNum, unlockNum, allNum = AvatarUtils.getClothesPresetNumInfo(clothesId)
	local presetList = AvatarUtils.getClothesPresetList(clothesId, true)

	ClientTextUtils.setText(self.presetNumUBaseText, usedNum, "/", unlockNum)
	self.presetUList:SetList(presetList)
end

function PlayerClothesComponent:refreshPresetPartList(suitId, selectSlotId)
	local partList = {}

	for slotId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		local suitData = AppearanceSuitData[suitId] or {}
		local clotheList = suitData.appearanceList or {}

		for _, clothesId in ipairs(clotheList) do
			if AppearanceData[clothesId].partId == slotId then
				local itemData = ItemData[clothesId] or {}

				table.insert(partList, {
					slotId = slotId,
					clothesId = clothesId,
					icon = itemData.icon,
					state = LuaUIUtils.SLOT_STATE.HAVE,
					quality = itemData.quality
				})

				break
			end
		end
	end

	self.presetPartUList:SetList(partList)

	if selectSlotId then
		for index, info in ipairs(partList) do
			if info.slotId == selectSlotId then
				self.presetPartUList:SelectItem(index - 1)
			end
		end
	else
		self.presetPartUList:SelectItem(0)
	end
end

function PlayerClothesComponent:onPresetPartSelectedChanged(data)
	self:refreshPresetList(data.clothesId)
end

function PlayerClothesComponent:onPresetClicked(data)
	if data.state == AvatarUtils.PRESET_STATE.EMPTY then
		if not pg.me:checkFunctionUnlock(FunctionEnum.APPEARANCE_COSTUME_CUSTOM) then
			pg.global.showBubbleMessageRaw(LuaUIUtils.getFunctionUnlockDesc(FunctionEnum.APPEARANCE_COSTUME_CUSTOM, true), 3)

			return
		end

		local slotData = self.slotOptionComponent.slotUList.selectedItem
		local optionData = self.slotOptionComponent.optionUList.selectedItem
		local partSlotData = self.presetPartUList.selectedItem
		local slotId = self:isSuit(slotData) and partSlotData.slotId or slotData.slotId
		local clothesId = self:isSuit(slotData) and partSlotData.clothesId or optionData.clothesId
		local entity = self.avatarScene:getCurEntity()
		local checkInitState = AvatarUtils.applyClothesPreset(entity, slotId, clothesId)

		if checkInitState then
			pg.global.ui:open(UIConst.UI_ID_WORKSHOP_COSTUME_STAIN, {
				mode = 1,
				clothId = clothesId,
				slotId = slotId
			}, function()
				self:onLeavePreset()
			end, function()
				self:onEnterPreset(slotId)
			end)
		else
			pg.global.showBubbleMessageRaw(pg.getGameString("APPEARANCE_CLOTH_INIT_FAIL"), 3)
		end
	elseif data.state == AvatarUtils.PRESET_STATE.NORMAL then
		pg.global.showConfirmMsgRaw(pg.getGameString("APPEARANCE_PRESET"), pg.getGameString("APPEARANCE_PRESET_USE"), function()
			if data.id < 0 then
				pg.me:serverMsg("RPC_CS_ApplyClothesDesign", data.points[1], data.clothesId, 0, function(res)
					if not res then
						return
					end

					pg.global.showBubbleMessageRaw(pg.getGameString("APPEARANCE_PRESET_SUCCESS"), 3)

					local ent = self.avatarScene:getCurEntity()

					ent.eModel.modelShaderView:ApplyPreset(data.points[1])
				end)
			else
				pg.me:serverMsg("RPC_CS_ApplyClothesDesign", data.points[1], data.clothesId, data.id, function(res)
					if not res then
						return
					end

					pg.global.showBubbleMessageRaw(pg.getGameString("APPEARANCE_PRESET_SUCCESS"), 3)

					local ent = self.avatarScene:getCurEntity()

					ent:applyPlayerClothStain()
				end)
			end
		end)
	elseif data.state == AvatarUtils.PRESET_STATE.LOCKED then
		local costText = LuaUIUtils.getItemCountConsumeShowText(data.costItemId, data.costNum, true)

		pg.global.ui.commonUseConfirm:open({
			type = 4,
			title = pg.getGameString("UNLOCK_TITLE"),
			tipTop = string.format(pg.getGameString("HOME_BUY_DESC"), costText),
			data = {
				{
					data.costItemId,
					data.costNum
				}
			},
			confirmCb = function()
				local clothesId = self.presetPartUList.selectedItem.clothesId

				pg.me:serverMsg("RPC_CS_UnlockClothesDesignInfo", clothesId, CallbackHandler(self, "unlockPresetCallback", {
					clothesId = clothesId
				}))
			end
		})
	end
end

function PlayerClothesComponent:unlockPresetCallback(param)
	self:refreshPresetList(param.clothesId)
end

function PlayerClothesComponent:onVisibleChange(visible)
	if not self.avatarScene then
		return
	end

	if self.curComponent ~= self then
		return
	end

	local curEntity = self.avatarScene:getCurEntity()

	if not curEntity.cancelCustomShowPreview then
		return
	end

	if visible then
		self:refreshSlotList()
		self:refreshOptionList()
	end
end

function PlayerClothesComponent:passToRightInfoComponent(originCmp, extra)
	return self.ctrl:passToRightInfoComponent(originCmp, extra)
end

return PlayerClothesComponent
