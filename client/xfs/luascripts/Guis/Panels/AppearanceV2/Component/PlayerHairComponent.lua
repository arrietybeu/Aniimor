-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AppearanceV2\\Component\\PlayerHairComponent.lua

local CallbackHandler = require("Core.Common.CallbackHandler")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local UIComponent = require("Guis.Helper.UIComponent")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local ClientModelUtils = require("Utils.ClientModelUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local RedDotConst = require("Const.RedDotConst")
local UIConst = require("Const.UIConst")
local AppearanceData = require("Data.appearance_data")
local AvatarHairSuitData = require("Data.avatar_hair_suit_data")
local AvatarPresetData = require("Data.avatar_preset_data")
local AppearancePointEnum = require("Data.appearance_point_enum")
local ItemData = require("Data.item_data")
local Const = require("Common.Const.Const")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TimerManager = require("Core.Timer.TimerManager")
local PlayerHairComponent = Class.LightClass("PlayerHairComponent", UIComponent)

function PlayerHairComponent:findObjects()
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

function PlayerHairComponent:initView()
	self.avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
	self.slotOptionComponent = self.ctrl.slotOptionComponent
	self.presetKey = self.ctrl.curPresetKey
end

function PlayerHairComponent:onDestroy()
	self.avatarScene = nil

	UIComponent.onDestroy(self)

	self.slotOptionComponent = nil
end

function PlayerHairComponent:addListener()
	function self.workshopUButton.luaClick()
		self:openWorkShop()
	end

	function self.designUButton.luaClick()
		self:openWorkShop()
	end
end

function PlayerHairComponent:removeListener()
	self.view.btnHairTieUButton.gameObject:SetActiveEx(true)
end

function PlayerHairComponent:onEnterPage()
	AvatarUtils.cancelHairTie()
	self.view.btnHairTieUButton.gameObject:SetActiveEx(false)
	self:addListener()
	self:initSlotList()
	self:initOptionList(self.slotOptionComponent:getSlotData(0).id)
	self.slotOptionComponent:setFilterRule()
	self.slotOptionComponent:reset()
	self.slotOptionComponent.slotUList:SelectItem(0)
	self.avatarScene:setAvatarCameraModeCloseHead()

	self.workshopUButton.interactable = true
end

function PlayerHairComponent:refreshPage()
	self:initSlotList()
	self:initOptionList(self.slotOptionComponent:getSlotData(0).id)
	self.slotOptionComponent:setFilterRule()
	self.slotOptionComponent:reset()
	self.slotOptionComponent.slotUList:SelectItem(0)
end

function PlayerHairComponent:onSlotSelectedChanged(data)
	if data.state == LuaUIUtils.SLOT_STATE.HAVE then
		self:initOptionList(data.id)
		self:selectWornOptionInList(data)
	else
		self:initOptionList()
	end
end

function PlayerHairComponent:onSlotClicked(oldData, data)
	return
end

function PlayerHairComponent:refreshPageUnEquip()
	self.rootUComponent:TryChangePage("State", "Normal")
	self:passToRightInfoComponent(self.rootUComponent)
end

function PlayerHairComponent:refreshPageEquip(data)
	local extra
	local slotData = self.slotOptionComponent.slotUList.selectedItem

	if data.state == LuaUIUtils.SELECT_STATE.NULL then
		if slotData and self:isSuit(slotData) then
			self.selectedHairId = nil
		end

		self.rootUComponent:TryChangePage("State", "Normal")
	else
		if slotData and self:isSuit(slotData) then
			self.selectedHairId = data.id
		end

		self.rootUComponent:TryChangePage("State", "Detail")

		if data.claimed then
			self.rootUComponent:TryChangePage("detail", "setting")
			self.rootUComponent:TryChangePage("BtnType", 0)
		else
			self.rootUComponent:TryChangePage("detail", "source")
			self.rootUComponent:TryChangePage("BtnType", 3)
			self:refreshSourceList(data.id)
		end

		ClientTextUtils.setText(self.nameUText, pg.getLocalizationText(data.name))
		ClientTextUtils.setText(self.btnFashionValue, data.fashion)

		function self.btnFashionValueIconUButton.luaRenderTooltip(btn, prop)
			self.view:renderFashionTips(prop, data.fashion)
		end

		local itemData = ItemData[data.id] or {}

		ClientTextUtils.setText(self.detailsUBaseText, pg.getLocalizationText(itemData.itemDes or ""))

		extra = {
			name = pg.getLocalizationText(data.name),
			fashion = data.fashion,
			desc = pg.getLocalizationText(itemData.itemDes or ""),
			id = data.id,
			claimed = data.claimed
		}

		function extra.refreshCallback()
			self.rootUComponent:TryChangePage("detail", "setting")
			self.rootUComponent:TryChangePage("BtnType", 0)

			extra.claimed = true

			self:passToRightInfoComponent(self.rootUComponent, extra)
			self:refreshPage()
		end
	end

	self:passToRightInfoComponent(self.rootUComponent, extra)
end

function PlayerHairComponent:refreshSourceList(id)
	local sourceList = self:getSourceList(id)

	self.sourceUList:SetList(sourceList)
end

function PlayerHairComponent:getSourceList(id)
	local list = {}
	local hairData = AppearanceData[id] or AvatarHairSuitData[id] or {}

	if hairData.shopClassifyId or hairData.shopId then
		table.insert(list, {
			text = pg.getGameString("ACCESSORY_SOURCE_SHOP"),
			func = function()
				if LuaUIUtils.checkFuncTemporaryDisable(UIConst.UI_ID_SHOP_MAIN) then
					return
				end

				pg.global.ui:open(UIConst.UI_ID_SHOP_MAIN, {
					shopTags = {
						hairData.shopClassifyId
					},
					shopTag = hairData.shopId
				}, nil, function()
					self:onEnterPage()
				end)
			end
		})
	end

	return list
end

function PlayerHairComponent:onOptionClicked(slotData, oldData, data, button)
	if data.claimed and data.showRedDot then
		local treePath = string.format(RedDotConst.RedDotPath.APPEARANCE_OPTION_LIST_ITEM, data.itemId)

		pg.me:setRedDotRecord(Const.CLIENT_KEY.APPEARANCE_RED_DOT, treePath, false)

		data.showRedDot = false

		local optionUList = self.slotOptionComponent.optionUList
		local index = optionUList:GetChildIndex(button)

		optionUList:RefreshElement(index)
	end

	if self:isSuit(slotData) then
		pg.game.avatar.optionSelectedData = data
	elseif self.selectedHairId then
		pg.game.avatar.optionSelectedData = {
			id = self.selectedHairId
		}
	else
		pg.game.avatar.optionSelectedData = data
	end

	if oldData == data then
		self:refreshPageEquip(data)

		return
	end

	if data.state == LuaUIUtils.SELECT_STATE.NULL then
		if self:isSuit(slotData) then
			local unequipSuitId = data.id or self.selectedHairId

			self.model.cacheHairSuitId = nil
			self.selectedHairId = nil

			self:unEquipHairSuit(not data.claimed, unequipSuitId)
		else
			local entity = self.avatarScene:getCurEntity()
			local configId = entity:getAppearanceConfigId(slotData.slotId)

			self:unEquipHair(configId, slotData.slotId, not data.claimed)
		end

		self:refreshPageUnEquip()
	else
		if self:isSuit(slotData) then
			self.model.cacheHairSuitId = data.id
			self.selectedHairId = data.id

			self:equipHairSuit(data.id, not data.claimed)
		else
			self:equipHair(data.id, slotData.slotId, not data.claimed)
		end

		self:refreshPageEquip(data)
	end
end

function PlayerHairComponent:onFilterSelectedChanged(slotData, filterFunc)
	self.filterFunc = filterFunc

	self:initOptionList(slotData.id, filterFunc)
end

function PlayerHairComponent:onFilterClicked(slotData, filterFunc)
	self.filterFunc = filterFunc

	self:initOptionList(slotData.id, filterFunc)
end

function PlayerHairComponent:onSearchChanged(slotData, filterFunc)
	self.filterFunc = filterFunc

	self:initOptionList(slotData.id, filterFunc)
end

function PlayerHairComponent:initSlotList(slotId)
	local equipList = self.model:getHairEquipInfoList()

	self.slotOptionComponent.slotUList:SetList(equipList)

	if slotId then
		for id, equipData in ipairs(equipList) do
			if equipData.slotId == slotId then
				self.slotOptionComponent.slotUList:SelectItem(id - 1, false)

				break
			end
		end
	else
		self.slotOptionComponent.slotUList:SelectItem(0, false)
	end
end

function PlayerHairComponent:initOptionList(forceFirstHairId, filterFunc)
	local slotData = self.slotOptionComponent.slotUList.selectedItem

	if not slotData then
		return
	end

	local entity = self.avatarScene:getEntity(self.presetKey)

	filterFunc = filterFunc or self.filterFunc

	local presetData = pg.game.avatar:getAvatarPresetData(self.presetKey) or {}
	local optionList = {}

	if self:isSuit(slotData) then
		optionList = self.model:getHairSuitList(presetData.body, forceFirstHairId, filterFunc, entity.customShow) or {}
	else
		optionList = self.model:getHairPartList(slotData.slotId, self.selectedHairId, presetData.body, forceFirstHairId, filterFunc, entity.customShow)
	end

	self.slotOptionComponent.optionUList:SetList(optionList)

	local wearedCount = 0

	for _, v in pairs(optionList) do
		if v.state == "RoleWear" then
			wearedCount = wearedCount + 1
		end
	end

	if not forceFirstHairId and wearedCount <= 0 then
		self:refreshPageUnEquip()
	end
end

function PlayerHairComponent:selectWornOptionInList(slotData)
	local optionUList = self.slotOptionComponent.optionUList
	local entity = self.avatarScene:getCurEntity()
	local targetId

	if self:isSuit(slotData) then
		targetId = LuaUIUtils.tryGetEntityHairSuitId(entity)
	else
		targetId = entity:getAppearanceConfigId(slotData.slotId)
	end

	if not targetId or targetId == 0 then
		self:refreshPageUnEquip()

		return
	end

	for index = 0, optionUList.itemCount - 1 do
		local optionData = optionUList:GetData(index)

		if optionData and (optionData.id == targetId or optionData.itemId == targetId) then
			optionUList:SelectItem(index)
			self:refreshPageEquip(optionData)

			break
		end
	end
end

function PlayerHairComponent:refreshImportedHairSelection(hairSuitId)
	if not hairSuitId then
		return
	end

	self.model.cacheHairSuitId = hairSuitId
	self.selectedHairId = hairSuitId
	pg.game.avatar.optionSelectedData = {
		claimed = true,
		id = hairSuitId
	}

	self:initSlotList()
	self:initOptionList(hairSuitId)
	self:refreshOptionList()

	local optionUList = self.slotOptionComponent.optionUList

	for index = 0, optionUList.itemCount - 1 do
		local optionData = optionUList:GetData(index)

		if optionData and (optionData.id == hairSuitId or optionData.itemId == hairSuitId) then
			optionUList:SelectItem(index)
			self:refreshPageEquip(optionData)

			break
		end
	end
end

function PlayerHairComponent:selectSuitOnOpen(suitId)
	if not suitId then
		return
	end

	self.slotOptionComponent.slotUList:SelectItem(0)
	self:initOptionList(suitId)

	local optionUList = self.slotOptionComponent.optionUList

	for index = 0, optionUList.itemCount - 1 do
		local optionData = optionUList:GetData(index)

		if optionData and (optionData.id == suitId or optionData.itemId == suitId) then
			local res, btn = optionUList:TryGetChildAt(index)

			if res then
				btn:OnClickSimulate()
			end

			break
		end
	end
end

function PlayerHairComponent:refreshOptionList()
	local slotData = self.slotOptionComponent.slotUList.selectedItem
	local data = self.slotOptionComponent.optionUList.itemData

	if not slotData then
		return
	end

	local entity = self.avatarScene:getCurEntity()

	if self:isSuit(slotData) then
		local hairSuitId = LuaUIUtils.tryGetEntityHairSuitId(entity)

		for _, v in pairs(data) do
			if v.state ~= LuaUIUtils.SELECT_STATE.NULL then
				v.equipped = v.id == hairSuitId
				v.state = v.equipped and LuaUIUtils.SELECT_STATE.ROLE_WEAR or v.claimed and LuaUIUtils.SELECT_STATE.HAVE or LuaUIUtils.SELECT_STATE.LOCKED
			end
		end
	else
		for _, v in pairs(data) do
			if v.state ~= LuaUIUtils.SELECT_STATE.NULL then
				v.equipped = LuaUIUtils.isHairPartEquipped(entity, v.id)
				v.state = v.equipped and LuaUIUtils.SELECT_STATE.ROLE_WEAR or v.claimed and LuaUIUtils.SELECT_STATE.HAVE or LuaUIUtils.SELECT_STATE.LOCKED
			end
		end
	end

	self.slotOptionComponent.optionUList:RefreshList()
end

function PlayerHairComponent:refreshPresetList()
	ClientTextUtils.setText(self.presetTitleUBaseText, pg.getGameString("APPEARANCE_PRESET"))

	local usedNum, unlockNum, allNum = AvatarUtils.getHairPresetNumInfo(self.selectedHairId)
	local presetList = AvatarUtils.getHairPresetList(self.selectedHairId, true)

	ClientTextUtils.setText(self.presetNumUBaseText, usedNum, "/", unlockNum)
	self.presetUList:SetList(presetList)
end

function PlayerHairComponent:isSuit(slotItem)
	return slotItem.part == "Suit"
end

function PlayerHairComponent:refreshHair(isPreview)
	AvatarUtils.cancelHairTie()

	local entity = self.avatarScene:getCurEntity()
	local modelView = entity.eModel.modelModelView

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		local configId = entity:getAppearanceConfigId(partId, isPreview)
		local data = AppearanceData[configId]

		ClientModelUtils.applyAppearancePart(entity, partId, configId, data and data.res)
	end

	ClientModelUtils.refreshModels(entity, modelView)
end

function PlayerHairComponent:unEquipHair(configId, slotId, isPreview)
	local entity = self.avatarScene:getCurEntity()

	entity:cancelCustomShowPreview(slotId)
	entity:setCustomShow(configId, false, slotId)
	self:refreshHair(isPreview)
	self:initSlotList(slotId)
	self:refreshOptionList()
end

function PlayerHairComponent:equipHair(configId, slotId, isPreview)
	local entity = self.avatarScene:getCurEntity()

	if isPreview then
		entity:setCustomShowPreview(configId, true, slotId)
	else
		entity:cancelCustomShowPreview(slotId)
		entity:setCustomShow(configId, true, slotId)
	end

	self:refreshHair(isPreview)
	self:initSlotList(slotId)
	self:refreshOptionList()
end

function PlayerHairComponent:unEquipHairSuit(isPreview, hairSuitId)
	local entity = self.avatarScene:getCurEntity()
	local worldCustomShow = pg.me.curShow and pg.me.curShow.customShow or {}
	local worldHairSuitId = LuaUIUtils.tryGetHairSuitId(worldCustomShow)
	local restoreWorldHair = not hairSuitId or not worldHairSuitId or hairSuitId ~= worldHairSuitId

	if restoreWorldHair then
		local hairSuitInfo = worldHairSuitId and AvatarHairSuitData[worldHairSuitId] or {}

		if hairSuitInfo.assetId then
			pg.global.avatarMgr.avatarHair:OnHairSuitChanged(nil, hairSuitInfo.assetId)
		end

		for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
			entity:cancelCustomShowPreview(partId)
			entity:cancelCustomShow(partId, true)

			local worldConfigId = worldCustomShow[partId]

			if worldConfigId and worldConfigId ~= 0 then
				entity:setCustomShow(worldConfigId, true, partId)
			end
		end

		if entity.curShow and pg.me.curShow then
			if not entity.curShow.customShow then
				entity.curShow.customShow = {}
			end

			if not entity.curShow.hairInfo then
				entity.curShow.hairInfo = {}
			end

			for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
				entity.curShow.customShow[partId] = worldCustomShow[partId]

				if pg.me.curShow.hairInfo then
					entity.curShow.hairInfo[partId] = pg.me.curShow.hairInfo[partId]
				end
			end
		end

		function entity.modelPartModelAllLoaded()
			if entity.applyPlayerHairCustomData then
				entity:applyPlayerHairCustomData()
			end

			entity.modelPartModelAllLoaded = nil
		end

		self:refreshHair(false)
	else
		for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
			entity:cancelCustomShowPreview(partId)

			local configId = entity:getAppearanceConfigId(partId)

			if configId and configId ~= 0 then
				entity:setCustomShow(configId, false, partId)
			end
		end

		self:refreshHair(isPreview)
	end

	self:initSlotList()
	self:refreshOptionList()
end

function PlayerHairComponent:equipHairSuit(suitId, isPreview)
	local entity = self.avatarScene:getCurEntity()
	local modelInfo = entity.eModel.modelModelView.modelInfo
	local oldAssetId = modelInfo:GetOriginHairAssetId()
	local modelSuitId = self.avatarScene:getCurHairSuitId(self.presetKey)
	local modelSuitInfo = modelSuitId and AvatarHairSuitData[modelSuitId] or nil
	local currentAssetId = modelSuitInfo and modelSuitInfo.assetId
	local partItems = LuaUIUtils.getAllPartInSuit(suitId, oldAssetId, currentAssetId)
	local hairSuitInfo = AvatarHairSuitData[suitId] or {}
	local newAssetId = hairSuitInfo.assetId

	if newAssetId then
		pg.global.avatarMgr.avatarHair:OnHairSuitChanged(nil, newAssetId)
	end

	if isPreview then
		for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
			entity:cancelCustomShowPreview(partId)

			local newConfigId = partItems[partId]

			if newConfigId and newConfigId ~= 0 then
				entity:setCustomShowPreview(newConfigId, true, partId)
			end
		end
	else
		for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
			entity:cancelCustomShowPreview(partId)
			entity:cancelCustomShow(partId, true)

			local newConfigId = partItems[partId]

			if newConfigId and newConfigId ~= 0 then
				entity:setCustomShow(newConfigId, true, partId)
			end
		end
	end

	self:refreshHair(isPreview)
	self:initSlotList()
	self:refreshOptionList()

	if not isPreview then
		AvatarUtils.applyHairPresetOrRuntimeDefault(suitId, CallbackHandler(self, "refreshHairByCustom"))
	end
end

function PlayerHairComponent:onEnterPreset()
	self.rootUComponent:TryChangePage("HavePart", "NoPart")
	self:refreshPresetList()
	self.avatarScene:setAvatarCameraModeCloseHead()
	self.avatarScene:setCameraRotationOffset(1.5)
	self.view.topbarUWidget:SetActiveFastest(false)
end

function PlayerHairComponent:onLeavePreset()
	self.avatarScene:setCameraRotationOffset(0)
	self.view.topbarUWidget:SetActiveFastest(true)
end

function PlayerHairComponent:onPresetClicked(data)
	if data.state == AvatarUtils.PRESET_STATE.EMPTY then
		self:openWorkShop(true)
	elseif data.state == AvatarUtils.PRESET_STATE.NORMAL then
		if data.id < 0 then
			pg.global.showConfirmMsgRaw(pg.getGameString("APPEARANCE_PRESET"), pg.getGameString("APPEARANCE_PRESET_USE"), function()
				local entity = self.avatarScene:getCurEntity()
				local originAssetId = entity.eModel.modelModelView.modelInfo:GetOriginHairAssetId()
				local hairParts = LuaUIUtils.getAllPartInSuit(self.selectedHairId, originAssetId)
				local actions = {}
				local curHairParts = ClientModelUtils.getModelHairParts(pg.me)

				for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
					local newHairPartId = hairParts[partId]

					if curHairParts[partId] then
						local curHairPartId = curHairParts[partId].hairPartId

						if newHairPartId then
							if curHairPartId ~= newHairPartId then
								table.insert(actions, {
									curHairPartId,
									false,
									partId
								})
								table.insert(actions, {
									newHairPartId,
									true,
									partId
								})
							end
						else
							table.insert(actions, {
								curHairPartId,
								false,
								partId
							})
						end
					elseif newHairPartId then
						table.insert(actions, {
							newHairPartId,
							true,
							partId
						})
					end
				end

				if not Utils.isEmptyTable(actions) then
					pg.me:serverMsg("RPC_CS_MultiSetAppearanceShow", actions)
				end

				pg.me:serverMsg("RPC_CS_SetHairCustom", self.selectedHairId, 0, CallbackHandler(self, "refreshHairByCustom"))
			end)
		else
			pg.global.showConfirmMsgRaw(pg.getGameString("APPEARANCE_PRESET"), pg.getGameString("APPEARANCE_PRESET_USE"), function()
				pg.me:serverMsg("RPC_CS_SetHairCustom", self.selectedHairId, data.id, CallbackHandler(self, "refreshHairByCustom"))
			end)
		end
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
				pg.me:serverMsg("RPC_CS_UnlockHairCustom", self.selectedHairId, CallbackHandler(self, "unlockPresetCallback"))
			end,
			cancelCb = function()
				return
			end
		})
	end
end

function PlayerHairComponent:openWorkShop(isFromPreset)
	local hairId = self.selectedHairId

	if not hairId then
		local entity = self.avatarScene:getCurEntity()

		if entity then
			hairId = LuaUIUtils.tryGetEntityHairSuitId(entity)
		end
	end

	pg.global.ui:open(UIConst.UI_ID_AVATAR, {
		isDesignMode = true,
		avatarType = AvatarUtils.AVATAR_TYPE.HAIR,
		presetKey = pg.game.avatar:getPresetKey(pg.me),
		designType = AvatarUtils.HAIR_DESIGN_TYPE.COLOR,
		hairId = hairId
	}, function()
		if isFromPreset then
			self:onLeavePreset()
		end
	end, function()
		if isFromPreset then
			self:onEnterPreset()
		end
	end)
end

function PlayerHairComponent:unlockPresetCallback()
	self:refreshPresetList()
end

function PlayerHairComponent:refreshHairByCustom()
	AvatarUtils.refreshHairByCustom()
	self:initSlotList()
	self:refreshOptionList()
	self:passToRightInfoComponent(self.rootUComponent)
end

function PlayerHairComponent:passToRightInfoComponent(originCmp, extra)
	return self.ctrl:passToRightInfoComponent(originCmp, extra)
end

return PlayerHairComponent
