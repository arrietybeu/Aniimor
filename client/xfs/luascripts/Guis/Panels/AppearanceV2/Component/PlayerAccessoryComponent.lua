-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AppearanceV2\\Component\\PlayerAccessoryComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("PlayerAccessoryComponent")
local Class = require("Core.Framework.Class")
local CallbackHandler = require("Core.Common.CallbackHandler")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientModelUtils = require("Utils.ClientModelUtils")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local Utils = require("Common.Utils.Utils")
local PlayableConst = require("Common.Const.PlayableConst")
local UIComponent = require("Guis.Helper.UIComponent")
local HotkeyConst = require("Const.HotkeyConst")
local AppearanceJewelryInfo = require("CustomTypes.AppearanceJewelryInfo")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local RedDotConst = require("Const.RedDotConst")
local UIConst = require("Const.UIConst")
local ColorJewelryData = require("Data.appearance_color_jewelry_data")
local AppearanceData = require("Data.appearance_data")
local AppearancePointEnum = require("Data.appearance_point_enum")
local AppearancePointData = require("Data.appearance_point_data")
local AvatarPresetData = require("Data.avatar_preset_data")
local ItemData = require("Data.item_data")
local PetData = require("Data.pet_data")
local SysConfigData = require("Data.sys_config_data")
local Const = require("Common.Const.Const")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TimerManager = require("Core.Timer.TimerManager")
local PlayerAccessoryComponent = Class.LightClass("PlayerAccessoryComponent", UIComponent)
local avatarMgr = pg.global.avatarMgr

function PlayerAccessoryComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.nameUText = self.objectReference:GetRefValue("nameUText")
	self.designUButton = self.objectReference:GetRefValue("designUButton")
	self.titleUButton = self.objectReference:GetRefValue("titleUButton")
	self.operationUList = self.objectReference:GetRefValue("operationUList")
	self.cancelUButton = self.objectReference:GetRefValue("cancelUButton")
	self.saveUButton = self.objectReference:GetRefValue("saveUButton")
	self.adjustUComponent = self.objectReference:GetRefValue("adjustUComponent")
	self.btnAllUnlockUButton = self.objectReference:GetRefValue("btnAllUnlockUButton")
	self.colorAccessoryCloseUButton = self.objectReference:GetRefValue("colorAccessoryCloseUButton")
	self.colorAccessoryUList = self.objectReference:GetRefValue("colorAccessoryUList")
	self.colorAccessoryUButton = self.objectReference:GetRefValue("colorAccessoryUButton")
	self.colorAccessorySourceUButton = self.objectReference:GetRefValue("colorAccessorySourceUButton")
	self.detailsUBaseText = self.objectReference:GetRefValue("detailsUBaseText")
	self.workshopUButton = self.objectReference:GetRefValue("workshopUButton")
	self.backwardUButton = self.objectReference:GetRefValue("backwardUButton")
	self.forwardUButton = self.objectReference:GetRefValue("forwardUButton")
	self.colorAccessoryNumUBaseText = self.objectReference:GetRefValue("colorAccessoryNumUBaseText")
	self.btnAdsorptionSiteUButton = self.objectReference:GetRefValue("btnAdsorptionSiteUButton")
	self.btnAdsorptionSiteUButtonText = self.objectReference:GetRefValue("btnAdsorptionSiteUButtonText")
	self.btnFashionValueIconUButton = self.objectReference:GetRefValue("btnFashionValueIconUButton")
	self.btnFashionValue = self.objectReference:GetRefValue("btnFashionValue")
	self.btnBackAlterUButton = self.objectReference:GetRefValue("btnBackAlterUButton")
	self.tMPUSDFText = self.objectReference:GetRefValue("tMPUSDFText")
	self.editUWidget = self.objectReference:GetRefValue("editUWidget")
	self.tabAdjustModeUWidget = self.objectReference:GetRefValue("tabAdjustModeUWidget")
	self.btnResetUButton = self.objectReference:GetRefValue("btnResetUButton")
	self.txtUnlockUSDFText = self.objectReference:GetRefValue("txtUnlockUSDFText")
	self.rootUComponent = self.ctrl.rootUComponent
	self.sourceUList = self.ctrl.sourceUList
	self.presetTitleUBaseText = self.ctrl.presetTitleUBaseText
	self.presetNumUBaseText = self.ctrl.presetNumUBaseText
	self.presetUList = self.ctrl.presetUList
	self.presetPartUList = self.ctrl.presetPartUList
end

function PlayerAccessoryComponent:initView()
	self.avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
	self.slotOptionComponent = self.ctrl.slotOptionComponent
	self.presetKey = self.ctrl.curPresetKey
	self.originConfig = self.model:getConfig(self.presetKey)

	self.editUWidget:SetActive(false)
	self.tabAdjustModeUWidget:SetActive(false)
	ClientTextUtils.setText(self.tMPUSDFText, pg.getGameString("BACK_TO_PRE"))
	ClientTextUtils.setText(self.txtUnlockUSDFText, pg.getGameString("ADJUST_UNLOCK_ALL"))
end

function PlayerAccessoryComponent:showLit(show)
	if show then
		self:setTPose()

		self.curAttachInstanceData = self.instanceData
		self.nearestBoneName = self:getSavedBoneName(self.curAttachInstanceData)
		self.enableTick = true
	else
		self:setIdle()

		self.enableTick = nil
		self.nearestBoneName = nil
		self.curAttachInstanceData = nil
		self.boneSliderChanged = nil

		UIUtils.ClearScreenPointCache("playerNearestBone")
		UIUtils.ClearScreenPointCache("playerCurAttach")
	end
end

function PlayerAccessoryComponent:updateBone()
	if not self.enableTick then
		return
	end

	if not self.nearestBoneName then
		return
	end

	if self.avatarScene.waitLoadEntity then
		return
	end

	local entity = self.avatarScene:getCurEntity()

	if not entity then
		return
	end

	local hasBoned = self.boneSliderChanged or self:checkCurAccessoryHasBoned(self.curAttachInstanceData)
	local nearestBonePos = entity.eModel.modelView:GetBonePosByBoneName(self.nearestBoneName)

	if nearestBonePos and hasBoned then
		UIUtils.DrawScreenPointWithWorldPosition("playerNearestBone", nearestBonePos, self.view.rootUComponent.transform, self.avatarScene.camera, function(go)
			go:GetComponent("UComponent"):TryChangePage("state", 1)
		end)
	else
		UIUtils.ClearScreenPointCache("playerNearestBone")
	end

	local curAttachPos = entity.eModel.modelView:GetCurAttachPos(self.curAttachInstanceData.resId)

	if curAttachPos then
		UIUtils.DrawScreenPointWithWorldPosition("playerCurAttach", curAttachPos, self.view.rootUComponent.transform, self.avatarScene.camera, function(go)
			go:GetComponent("UComponent"):TryChangePage("state", 0)
		end)
	else
		UIUtils.ClearScreenPointCache("playerCurAttach")
	end
end

function PlayerAccessoryComponent:addListener()
	function self.operationUList.luaRenderItem(button, index, data)
		AvatarUtils.renderOperationCollection(button, data, function(btn, idx, subData, parentDisplayName)
			if subData.tIndex == 0 then
				local curValue = avatarMgr.avatarMakeup:GetReactionDataValue(data.reactionKey, subData.opName)
				local oldLockState = btn.navForceNonInteractable

				btn.navForceNonInteractable = data.isLock

				local unlockFocus = oldLockState == true and data.isLock == false

				if idx == 0 and unlockFocus then
					CS.XGUI.Navigation.NavManager.Instance:FocusItem(btn)
				end

				local btnObjectReference = btn:GetComponent("ObjectReference")
				local sliderUSlider = btnObjectReference:GetRefValue("sliderUSlider")

				sliderUSlider:SetSliderActionPaths("Raw/GamepadLeftShoulder", "Raw/GamepadRightShoulder")
				AvatarUtils.renderSlider(btn, subData, curValue, function(value)
					avatarMgr.avatarMakeup:EditAttach(data.reactionKey, value)
					self.ctrl.bubbleComponent:setNormalValue(value, subData.displayName)
					self.ctrl.bubbleComponent:show()

					if not self.isLock then
						self.nearestBoneName = avatarMgr.avatarMakeup:GetNearestBoneName(self.instanceData.reactionKey)
					end

					self.curAttachInstanceData = self.instanceData
					self.boneSliderChanged = true
				end, function()
					avatarMgr.avatarMakeup:FinishEditAttach(data.reactionKey, self.lockBoneName)
					self:refreshButtonState()
					self.ctrl.bubbleComponent:hide()

					if not self.isLock then
						self.nearestBoneName = avatarMgr.avatarMakeup:GetNearestBoneName(self.instanceData.reactionKey)
					end

					self.curAttachInstanceData = self.instanceData
				end, function()
					avatarMgr.avatarMakeup:StartEditAttach(data.reactionKey, subData.opName)

					if not self.isLock then
						self.nearestBoneName = avatarMgr.avatarMakeup:GetNearestBoneName(self.instanceData.reactionKey)
					end

					self.curAttachInstanceData = self.instanceData
					self.boneSliderChanged = true
				end, parentDisplayName, 0.01)
			end
		end)
	end

	function self.btnAdsorptionSiteUButton.luaClick()
		self.isLock = not self.isLock

		self:refreshLockBtnStates()
	end

	function self.btnResetUButton.luaClick()
		self:resetAttachToPreset()
	end

	function self.designUButton.luaClick()
		if avatarMgr.avatarMakeup and NotNil(avatarMgr.avatarMakeup) then
			avatarMgr.avatarMakeup:InitAnimBoneToRootMatrixes()
		end

		self:refreshAccessory()
		self.rootUComponent:TryChangePage("State", "Edit")
		self.editUWidget:SetActive(false)
		self.tabAdjustModeUWidget:SetActive(false)
		self.btnAdsorptionSiteUButton:SetActive(true)
		self.view.topbarUWidget:SetActiveFastest(false)
		self:refreshTitleButton()
		self:refreshButtonState()
		self.avatarScene:setAvatarCameraModeFar()
		self.avatarScene:setCameraRotationOffset(1.5)
		self:refreshOperationList(self.selectReactionKey, self.selectAccessoryId)
		self:showLit(true)

		self.isLock = false

		self:refreshLockBtnStates()
		self.ctrl.ctrl:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel, function()
			self.cancelUButton.luaClick()

			return false
		end, self.rootUComponent.gameObject, "appearancePlayerAccessoryEscBind")
		self:passToRightInfoComponent(self.rootUComponent)
	end

	function self.cancelUButton.luaClick()
		local isClaim = self.slotOptionComponent.optionUList.selectedItem.claimed

		if isClaim then
			local title = pg.getGameString("ACCESSORY_CANCEL_TITLE")
			local desc = pg.getGameString("ACCESSORY_CANCEL_DESC")

			if avatarMgr.globalStack:IsEmpty() then
				self:cancelEditor()
			else
				pg.global.showConfirmMsgRaw(title, desc, function()
					self:cancelEditor()
				end, nil, nil, nil, nil, {
					cancelBtnDesc = pg.getGameString("CONSOLE_COMMON_CANCEL")
				})
			end
		else
			self:cancelEditor()
		end

		self.ctrl.ctrl:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel, function()
			return true
		end, self.rootUComponent.gameObject, "appearancePlayerAccessoryEscBind")
	end

	self.btnBackAlterUButton.luaClick = self.cancelUButton.luaClick

	function self.saveUButton.luaClick()
		self:saveEditor()
	end

	function self.backwardUButton.luaClick()
		pg.global.avatarMgr:Undo()
		self:refreshOperationList(self.selectReactionKey, self.selectAccessoryId)
		self:refreshButtonState()
	end

	function self.forwardUButton.luaClick()
		pg.global.avatarMgr:Redo()
		self:refreshOperationList(self.selectReactionKey, self.selectAccessoryId)
		self:refreshButtonState()
	end

	function self.colorAccessoryUButton.luaClick()
		self.rootUComponent:TryChangePage("State", "Colorful")
		self:refreshColorAccessory()
		self.view.topbarUWidget:SetActiveFastest(false)
		self:passToRightInfoComponent(self.rootUComponent)
	end

	function self.colorAccessoryCloseUButton.luaClick()
		self.rootUComponent:TryChangePage("State", "Detail")
		self.view.topbarUWidget:SetActiveFastest(true)
		self:passToRightInfoComponent(self.rootUComponent)
	end

	function self.colorAccessoryUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local rootUComponent = objectReference:GetRefValue("rootUComponent")

		iconUImage.url = data.icon

		rootUComponent:TryChangePage("Locked", data.isLock and "Yes" or "No")
		rootUComponent:TryChangePage("IsWear", data.isWear and "Yes" or "No")

		if not data.isLock then
			local treePath = string.format(RedDotConst.RedDotPath.APPEARANCE_COLOR_ACCESSORY_ITEM, data.id)

			pg.global.setRedDot(treePath, button, data.showRedDot or false, RedDotConst.RedDotStyle.NEW_LEFT_EXPEND)
		end
	end

	function self.colorAccessoryUList.luaSelectedChanged(uList)
		return
	end

	function self.colorAccessorySourceUButton.luaClick()
		local data = self.colorAccessoryUList.selectedItem
		local petHandbookInfo = pg.me.petHandbookMap[data.petTemplateId]

		if petHandbookInfo and petHandbookInfo:isCatched() then
			pg.global.ui:open(UIConst.UI_ID_PET_RESEARCH_PET_REWARD, {
				templateId = data.petTemplateId
			}, nil, function()
				self:refreshColorAccessory()
			end)
		else
			pg.global.ui.tips:showTextTip(string.format(pg.getGameString("UNLOCK_PAT_SOURCE"), pg.getLocalizationText(PetData[data.petTemplateId].name)))
		end
	end
end

function PlayerAccessoryComponent:removeListener()
	self.btnAdsorptionSiteUButton:SetActive(false)

	self.designUButton.luaClick = nil
	self.operationUList.luaRenderItem = nil
	self.btnResetUButton.luaClick = nil
end

function PlayerAccessoryComponent:onDestroy()
	UIComponent.onDestroy(self)

	self.slotOptionComponent = nil
end

function PlayerAccessoryComponent:refreshLockBtnStates()
	if self.isLock then
		ClientTextUtils.setText(self.btnAdsorptionSiteUButtonText, pg.getGameString("ACCESSORY_BONE_ADSORPTION_ENABLED"))

		self.lockBoneName = self.nearestBoneName
	else
		ClientTextUtils.setText(self.btnAdsorptionSiteUButtonText, pg.getGameString("ACCESSORY_BONE_ADSORPTION_DISABLED"))

		self.lockBoneName = nil
	end

	self.btnAdsorptionSiteUButton:TryChangePage("Lock", self.isLock and 1 or 0)
end

function PlayerAccessoryComponent:onAccessoryUnlock(data)
	self:refreshOperationList(self.selectReactionKey, self.selectAccessoryId)
end

function PlayerAccessoryComponent:getFilterRule()
	local res = {}

	table.insert(res, {
		filterBy = -1,
		text = pg.getGameString("ALL")
	})

	for _, info in pairs(self.originConfig) do
		table.insert(res, {
			text = info.displayName,
			filterBy = info.key
		})
	end

	return res
end

function PlayerAccessoryComponent:onEnterPage()
	self:addListener()
	self:initSlotList()

	local filterRule = self:getFilterRule()

	self.slotOptionComponent:setFilterRule(filterRule, "kindKey")
	self.slotOptionComponent:reset()
	self.slotOptionComponent.slotUList:SelectItem(0)
	self.avatarScene:setAvatarCameraModeFar()
end

function PlayerAccessoryComponent:refreshPage()
	self:initSlotList()

	local filterRule = self:getFilterRule()

	self.slotOptionComponent:setFilterRule(filterRule, "kindKey")
	self.slotOptionComponent:reset()
	self.slotOptionComponent.slotUList:SelectItem(0)
end

function PlayerAccessoryComponent:onSlotSelectedChanged(data)
	if data.state == LuaUIUtils.SLOT_STATE.LOCKED then
		local costText = LuaUIUtils.getItemCountConsumeShowText(data.costItemId, data.costNum, true)

		pg.global.ui.commonUseConfirm:open({
			type = 4,
			title = pg.getGameString("ACCESSORY_UNLOCK_TITLE"),
			tipTop = string.format(pg.getGameString("HOME_BUY_DESC"), costText),
			data = {
				{
					data.costItemId,
					data.costNum
				}
			},
			confirmCb = function()
				pg.me:serverMsg("RPC_CS_UnlockPoint", data.slotId, CallbackHandler(self, "unlockSlotCallback", data.slotId))
			end,
			cancelCb = function()
				self.slotOptionComponent.slotUList:SelectItem(0)
			end
		})
	else
		self:initOptionList()
	end
end

function PlayerAccessoryComponent:onSlotClicked(oldData, data)
	if oldData and oldData == data and oldData.state == LuaUIUtils.SLOT_STATE.HAVE then
		self:unEquipAccessory(oldData.slotId, oldData.accessoryId)
		self:refreshPageUnEquip()
	end
end

function PlayerAccessoryComponent:refreshPageUnEquip()
	self.rootUComponent:TryChangePage("State", "Normal")
	self:passToRightInfoComponent(self.rootUComponent)
end

function PlayerAccessoryComponent:refreshPageEquip(data)
	self.rootUComponent:TryChangePage("State", "Detail")

	if data.claimed then
		self.rootUComponent:TryChangePage("detail", "setting")
	else
		self.rootUComponent:TryChangePage("detail", "source")
		self:refreshSourceList(data.accessoryId)
	end

	local colorAccessoryList = self.model:getColorAccessoryList(data.accessoryId)

	if #colorAccessoryList > 0 then
		self.rootUComponent:TryChangePage("BtnType", 1)
		ClientTextUtils.setText(self.colorAccessoryNumUBaseText, #colorAccessoryList)
	else
		self.rootUComponent:TryChangePage("BtnType", 2)
	end

	ClientTextUtils.setText(self.nameUText, pg.getLocalizationText(data.name))
	ClientTextUtils.setText(self.btnFashionValue, data.fashion)

	function self.btnFashionValueIconUButton.luaRenderTooltip(btn, prop)
		self.view:renderFashionTips(prop, data.fashion)
	end

	ClientTextUtils.setText(self.detailsUBaseText, pg.getLocalizationText(ItemData[data.accessoryId].itemDes or ""))

	self.selectReactionKey = data.reactionKey
	self.selectAccessoryId = data.accessoryId

	local extra = {}

	extra = {
		name = pg.getLocalizationText(data.name),
		fashion = data.fashion,
		desc = pg.getLocalizationText(ItemData[data.accessoryId].itemDes or ""),
		id = data.accessoryId,
		claimed = data.claimed,
		refreshCallback = function()
			self.rootUComponent:TryChangePage("detail", "setting")

			local colorAccessoryList1 = self.model:getColorAccessoryList(data.accessoryId)

			if #colorAccessoryList1 > 0 then
				self.rootUComponent:TryChangePage("BtnType", 1)
			else
				self.rootUComponent:TryChangePage("BtnType", 2)
			end

			extra.claimed = true

			self:passToRightInfoComponent(self.rootUComponent, extra)
			self:refreshPage()
		end
	}

	self:passToRightInfoComponent(self.rootUComponent, extra)
end

function PlayerAccessoryComponent:onOptionClicked(slotData, oldData, data, button)
	self.instanceData = data

	local slotId = slotData.slotId
	local entity = self.avatarScene:getCurEntity()
	local curAccessoryId = entity:getAppearanceConfigId(slotId, true)

	if curAccessoryId == data.accessoryId then
		if oldData and oldData.accessoryId == data.accessoryId then
			self:unEquipAccessory(slotId, data.accessoryId, not data.claimed)
			self:refreshPageUnEquip()
		else
			self:refreshPageEquip(data)
		end
	else
		self:equipAccessory(slotId, data.accessoryId, not data.claimed)
		self:refreshPageEquip(data)
	end

	if data.claimed and data.showRedDot then
		local treePath = string.format(RedDotConst.RedDotPath.APPEARANCE_OPTION_LIST_ITEM, data.itemId)

		pg.me:setRedDotRecord(Const.CLIENT_KEY.APPEARANCE_RED_DOT, treePath, false)

		data.showRedDot = false

		local optionUList = self.slotOptionComponent.optionUList
		local index = optionUList:GetChildIndex(button)

		optionUList:RefreshElement(index)
	end

	self:showLit(false)
end

function PlayerAccessoryComponent:checkCurAccessoryHasBoned(curAttachInstanceData)
	return self:getSavedBoneName(curAttachInstanceData) ~= nil
end

function PlayerAccessoryComponent:getSavedBoneName(curAttachInstanceData)
	local entity = self.avatarScene:getCurEntity()
	local attachModelInfo = entity.eModel.modelModelView.modelInfo:GetAttachModelInfo(curAttachInstanceData.reactionKey)

	if string.isNilOrEmpty(attachModelInfo.attachHp) then
		return nil
	end

	return attachModelInfo.attachHp
end

function PlayerAccessoryComponent:setIdle()
	local entity = self.avatarScene:getCurEntity()

	entity:playAnimation("Idle")
end

function PlayerAccessoryComponent:setTPose()
	local entity = self.avatarScene:getCurEntity()

	entity:stopAllAnimation()
end

function PlayerAccessoryComponent:onFilterSelectedChanged(slotData, filterFunc)
	self.filterFunc = filterFunc

	self:initOptionList(filterFunc)
end

function PlayerAccessoryComponent:onFilterClicked(slotData, filterFunc)
	self.filterFunc = filterFunc

	self:initOptionList(filterFunc)
end

function PlayerAccessoryComponent:onSearchChanged(slotData, filterFunc)
	self.filterFunc = filterFunc

	self:initOptionList(filterFunc)
end

function PlayerAccessoryComponent:unlockSlotCallback(slotId)
	self:initSlotList()
end

function PlayerAccessoryComponent:initSlotList(slotId)
	local equipList = self.model:getAccessoryEquipInfoList()

	self.slotOptionComponent.slotUList:SetList(equipList)

	if slotId then
		for id, equipData in ipairs(equipList) do
			if equipData.slotId == slotId then
				self.slotOptionComponent.slotUList:SelectItem(id - 1)
			end
		end
	else
		self.slotOptionComponent.slotUList:SelectItem(0)
	end
end

function PlayerAccessoryComponent:refreshSlotList()
	for partId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
		self:refreshSlotItem(partId)
	end
end

function PlayerAccessoryComponent:findSlotListIndex(partId)
	local itemCount = self.slotOptionComponent.slotUList.itemCount

	for index = 0, itemCount - 1 do
		local data = self.slotOptionComponent.slotUList:GetData(index)

		if data and data.slotId == partId then
			return index
		end
	end
end

function PlayerAccessoryComponent:refreshSlotItem(partId)
	if LuaUIUtils.isAppearancePointHidden(partId) then
		return
	end

	local entity = self.avatarScene:getCurEntity()
	local index = self:findSlotListIndex(partId)

	if index == nil then
		return
	end

	local data = self.slotOptionComponent.slotUList:GetData(index)

	if not data then
		return
	end

	if pg.me.curShow.customShow[partId] == nil then
		data.state = LuaUIUtils.SLOT_STATE.LOCKED
	else
		local accessoryId = entity:getAppearanceConfigId(partId)

		if accessoryId == 0 then
			data.state = LuaUIUtils.SLOT_STATE.EMPTY
		else
			local accessoryInfo = LuaUIUtils.getAccessoryInfo(entity, accessoryId)

			data.state = LuaUIUtils.SLOT_STATE.HAVE
			data.icon = accessoryInfo.icon
			data.quality = accessoryInfo.quality
			data.accessoryId = accessoryId
		end
	end

	self.slotOptionComponent.slotUList:RefreshElement(index)
end

function PlayerAccessoryComponent:initOptionList(filterFunc)
	filterFunc = filterFunc or self.filterFunc

	local slotData = self.slotOptionComponent.slotUList.selectedItem

	if not slotData then
		return
	end

	local slotId = slotData.slotId
	local entity = self.avatarScene:getCurEntity()
	local forceFirstAccessoryId = entity:getAppearanceConfigId(slotId)
	local presetData = pg.game.avatar:getAvatarPresetData(self.presetKey) or {}
	local accessoryList = self.model:getAccessoryInfoList(presetData.body, forceFirstAccessoryId, filterFunc)

	self.slotOptionComponent.optionUList:SetList(accessoryList)

	for index, optionData in ipairs(accessoryList) do
		if optionData.itemId == forceFirstAccessoryId then
			local res, btn = self.slotOptionComponent.optionUList:TryGetChildAt(index - 1)

			if res then
				btn:OnClickSimulate()
			end

			break
		end
	end

	if #accessoryList > 0 then
		self.selectReactionKey = accessoryList[1].reactionKey
		self.selectAccessoryId = accessoryList[1].accessoryId
	end

	local wearedCount = 0
	local previewId = entity.customShowPreview and entity.customShowPreview[slotId]
	local hasPreview = previewId and previewId ~= 0

	for _, v in pairs(accessoryList) do
		if v.claimed and v.equipped then
			wearedCount = wearedCount + 1
		end
	end

	if (not forceFirstAccessoryId or forceFirstAccessoryId == 0) and wearedCount <= 0 and not hasPreview then
		self:refreshPageUnEquip()
	end
end

function PlayerAccessoryComponent:refreshOptionList()
	local slotData = self.slotOptionComponent.slotUList.selectedItem
	local data = self.slotOptionComponent.optionUList.itemData

	if not slotData then
		return
	end

	local entity = self.avatarScene:getCurEntity()

	for _, v in pairs(data) do
		v.equipped = LuaUIUtils.isAccessoryEquipped(entity, v.accessoryId)
		v.state = LuaUIUtils.getAccessorySelectState(v.claimed, v.equipped)
	end

	self.slotOptionComponent.optionUList:RefreshList()
end

function PlayerAccessoryComponent:refreshTitleButton()
	local objectReference = self.titleUButton:GetComponent("ObjectReference")
	local titleUText = objectReference:GetRefValue("titleUText")
	local positionUText = objectReference:GetRefValue("positionUText")
	local refreshUButton = objectReference:GetRefValue("refreshUButton")
	local reaction = self.model:getReaction(self.originConfig, self.selectReactionKey) or {}

	ClientTextUtils.setText(titleUText, pg.getGameString("ACCESSORY_DEFAULT_POS"))
	ClientTextUtils.setText(positionUText, pg.getLocalizationText(reaction.kindDisplayName))

	function refreshUButton.luaClick()
		self:resetAttachToPreset()
	end
end

function PlayerAccessoryComponent:resetAttachToPreset()
	avatarMgr.avatarMakeup:ResetAttachToPreset(self.selectReactionKey)
	avatarMgr.globalStack:Clear()
	self:refreshButtonState()
	self:refreshOperationList(self.selectReactionKey, self.selectAccessoryId)
end

function PlayerAccessoryComponent:refreshOperationList(reactionKey, accessoryId, unlockIndex, unLockResult)
	if not reactionKey then
		return {}
	end

	self.unlockTimer = nil

	local reaction = self.model:getReaction(self.originConfig, reactionKey) or {}
	local operations = reaction.operations or {}
	local res = {}
	local isAllLock = true
	local unlockInfo = pg.me.appearanceInfo[accessoryId] and pg.me.appearanceInfo[accessoryId].jewelryUnlockInfo or {}
	local isAllPlayUnlock = unlockIndex == 4 and unLockResult

	for idx, operation in ipairs(operations) do
		operation.reactionKey = reactionKey
		operation.kindKey = reaction.kindKey
		operation.isLock = unlockInfo[idx] ~= 1 and unlockInfo[4] ~= 1
		operation.idx = idx
		operation.accessoryId = accessoryId

		if operation.isLock == false then
			isAllLock = false
		end

		if isAllPlayUnlock or unlockIndex == idx and unLockResult then
			operation.playUnlock = true
		end

		local costInfo = SysConfigData.JewelryInfoCosts[idx]
		local costData = {}

		for id, cnt in pairs(costInfo) do
			table.insert(costData, {
				id,
				cnt
			})
		end

		operation.costData = costData

		function operation.unlockClicked()
			if not pg.me.appearanceInfo[accessoryId] then
				pg.global.showBubbleMessageRaw(pg.getGameString("ACCESSORY_SAVE_FAILED"), 3)

				return
			end

			local costText = ""

			for _, cost in ipairs(costData) do
				costText = costText .. LuaUIUtils.getItemCountConsumeShowText(cost[1], cost[2], true)
			end

			local info = {
				type = 4,
				title = pg.getGameString("ACCESSORY_ADJUST_UNLOCK_TITLE"),
				tipTop = string.format(pg.getGameString("HOME_BUY_DESC"), costText),
				data = costData,
				confirmCb = function()
					pg.me:serverMsg("RPC_CS_UnlockJewelryInfo", accessoryId, idx, CallbackHandler(self, "unlockAccessoryCallback", idx))
				end
			}

			pg.global.ui.commonUseConfirm:open(info)
		end

		table.insert(res, operation)
	end

	isAllLock = isAllLock and unlockInfo[4] ~= 1

	self.operationUList:SetList(res)
	self.adjustUComponent:TryChangePage("AllUnlock", isAllLock and 1 or 0)

	if isAllLock then
		local objectReference = self.btnAllUnlockUButton:GetComponent("ObjectReference")
		local txtNumTextPlus = objectReference:GetRefValue("txtNumTextPlus")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local allUnlockCosts = SysConfigData.JewelryInfoCosts[4]
		local costData = {}

		for id, cnt in pairs(allUnlockCosts) do
			table.insert(costData, {
				id,
				cnt
			})
		end

		iconUImage.url = LuaUIUtils.getIconByItemId(costData[1][1])

		ClientTextUtils.setText(txtNumTextPlus, costData[1][2])

		function self.btnAllUnlockUButton.luaClick()
			if not pg.me.appearanceInfo[accessoryId] then
				pg.global.showBubbleMessageRaw(pg.getGameString("ACCESSORY_SAVE_FAILED"), 3)

				return
			end

			local costText = ""

			for _, cost in ipairs(costData) do
				costText = costText .. LuaUIUtils.getItemCountConsumeShowText(cost[1], cost[2], true)
			end

			pg.global.ui.commonUseConfirm:open({
				type = 4,
				title = pg.getGameString("ACCESSORY_ADJUST_UNLOCK_TITLE"),
				tipTop = string.format(pg.getGameString("HOME_BUY_DESC"), costText),
				data = costData,
				confirmCb = function()
					pg.me:serverMsg("RPC_CS_UnlockJewelryInfo", accessoryId, 4, CallbackHandler(self, "unlockAccessoryCallback", 4))
				end
			})
		end
	end
end

function PlayerAccessoryComponent:unlockAccessoryCallback(unlockIndex, unLockResult)
	self:refreshOperationList(self.selectReactionKey, self.selectAccessoryId, unlockIndex, unLockResult)

	if self.unlockTimer then
		self.ctrl:killTimer(self.unlockTimer)
	end

	self.unlockTimer = self.ctrl:startTimer(function()
		self:refreshOperationList(self.selectReactionKey, self.selectAccessoryId)
	end, 2.1)
end

function PlayerAccessoryComponent:getSourceList(accessoryId)
	local list = {}
	local accessoryData = AppearanceData[accessoryId] or {}

	if accessoryData.templateId then
		table.insert(list, {
			text = pg.getGameString("ACCESSORY_SOURCE_PET_HANDBOOK"),
			func = function()
				local petHandbookInfo = pg.me.petHandbookMap[accessoryData.templateId]

				if petHandbookInfo and petHandbookInfo:isCatched() then
					pg.global.ui:open(UIConst.UI_ID_PET_RESEARCH_PET_REWARD, {
						templateId = accessoryData.templateId
					}, nil, function()
						self:onEnterPage()
						self:tryEquipAccessoryInPreview()
					end)
				else
					pg.global.ui.tips:showTextTip(pg.getGameString("JEWELRY_PAT_SOURCE"))
				end
			end
		})
	end

	if accessoryData.shopClassifyId or accessoryData.shopId then
		table.insert(list, {
			text = pg.getGameString("ACCESSORY_SOURCE_SHOP"),
			func = function()
				if LuaUIUtils.checkFuncTemporaryDisable(UIConst.UI_ID_SHOP_MAIN) then
					return
				end

				pg.global.ui:open(UIConst.UI_ID_SHOP_MAIN, {
					shopTags = {
						accessoryData.shopClassifyId
					},
					shopTag = accessoryData.shopId
				}, nil, function()
					self:onEnterPage()
					self:tryEquipAccessoryInPreview()
				end)
			end
		})
	end

	return list
end

function PlayerAccessoryComponent:refreshAccessory()
	local entity = self.avatarScene:getCurEntity()
	local modelView = entity.eModel.modelModelView

	modelView.modelInfo:RemoveAllAttach()

	local attachList = {}

	for partId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
		local accessoryId = entity:getAppearanceConfigId(partId, true, true)
		local reactionKey = ClientModelUtils.selectAppearanceAccessory(entity, partId, accessoryId)

		if accessoryId and accessoryId ~= 0 then
			attachList[#attachList + 1] = {
				accessoryId = accessoryId,
				reactionKey = reactionKey
			}
		end
	end

	local addedPeripheralIds = {}

	for pointId = AppearancePointEnum.FootPrint, AppearancePointEnum.Effect do
		local peripheralId = entity:getAppearanceConfigId(pointId, true, true)

		if peripheralId and peripheralId ~= 0 and not addedPeripheralIds[peripheralId] then
			local peripheralInfo = ClientModelUtils.getPeripheralAttachInfo(entity, peripheralId)

			if peripheralInfo then
				addedPeripheralIds[peripheralId] = true

				ClientModelUtils.addModelAttach(modelView.modelInfo, peripheralInfo)
			end
		end
	end

	ClientModelUtils.refreshModels(entity, modelView)

	for _, attach in ipairs(attachList) do
		self:refreshAttachByServer(attach.accessoryId, attach.reactionKey)
	end
end

function PlayerAccessoryComponent:tryEquipAccessoryInPreview()
	return
end

function PlayerAccessoryComponent:equipAccessory(slotId, accessoryId, isPreview)
	local entity = self.avatarScene:getCurEntity()
	local accessoryIdCurSlot = entity:getAppearanceConfigId(slotId, true, true)
	local swapToOldSlotId

	for otherSlotId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
		if otherSlotId ~= slotId then
			local otherId = entity:getAppearanceConfigId(otherSlotId, true, true)

			if otherId == accessoryId then
				if not isPreview and accessoryIdCurSlot and accessoryIdCurSlot ~= 0 then
					swapToOldSlotId = otherSlotId
				elseif isPreview then
					entity:cancelCustomShowPreview(otherSlotId, true)
				else
					entity:setCustomShow(accessoryId, false, otherSlotId)
				end
			end
		end
	end

	if isPreview then
		entity:setCustomShowPreview(accessoryId, true, slotId)
	else
		entity:cancelCustomShowPreview(slotId)

		if swapToOldSlotId and accessoryIdCurSlot and accessoryIdCurSlot ~= 0 then
			entity:setCustomShow(accessoryIdCurSlot, true, swapToOldSlotId)
		end

		entity:setCustomShow(accessoryId, true, slotId)
	end

	self:refreshAccessory()
	self:refreshSlotList()
	self:refreshOptionList()
	entity:refreshAppearanceFunction()
end

function PlayerAccessoryComponent:unEquipAccessory(slotId, accessoryId, isPreview)
	local entity = self.avatarScene:getCurEntity()

	if isPreview then
		entity:cancelCustomShowPreview(slotId)
	else
		entity:setCustomShow(accessoryId, false, slotId)
	end

	self:refreshAccessory()
	self:refreshSlotList()
	self:refreshOptionList()
	self.slotOptionComponent.optionUList:DeselectAll()
end

function PlayerAccessoryComponent:createJewelryInfo(accessoryId, reactionKey)
	local entity = self.avatarScene:getCurEntity()
	local res = {}
	local attachModelInfo = entity.eModel.modelModelView.modelInfo:GetAttachModelInfo(reactionKey)

	if attachModelInfo ~= nil then
		res = {
			configId = accessoryId,
			attachBone = attachModelInfo.attachHp,
			posX = attachModelInfo.localOffset.x,
			posY = attachModelInfo.localOffset.y,
			posZ = attachModelInfo.localOffset.z,
			rotX = attachModelInfo.localRotation.x,
			rotY = attachModelInfo.localRotation.y,
			rotZ = attachModelInfo.localRotation.z,
			scale = attachModelInfo.scale.x
		}
	elseif LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("@sxy attachModelInfo == nil", accessoryId, reactionKey)
	end

	return res
end

function PlayerAccessoryComponent:refreshSourceList(accessoryId)
	local sourceList = self:getSourceList(accessoryId)

	self.sourceUList:SetList(sourceList)
end

function PlayerAccessoryComponent:refreshAttachByServer(accessoryId, reactionKey)
	local lastInfoStr = pg.me.jewelryLastInfos[accessoryId]

	if not reactionKey or not lastInfoStr then
		return
	end

	local jewelryInfo = AppearanceJewelryInfo.new()

	jewelryInfo:toTable(accessoryId, lastInfoStr)

	local overrideResId = jewelryInfo.colorJewelryId == 0 and "" or ColorJewelryData[jewelryInfo.colorJewelryId].res

	avatarMgr.avatarMakeup:RefreshAttachByServer(reactionKey, jewelryInfo, overrideResId)
end

function PlayerAccessoryComponent:saveEditor()
	local slotData = self.slotOptionComponent.slotUList.selectedItem
	local optionData = self.slotOptionComponent.optionUList.selectedItem

	if not slotData or not optionData then
		return
	end

	if not optionData.claimed then
		pg.global.ui.tips:showTextTip(pg.getGameString("ACCESSORY_SAVE_FAILED"))

		return
	end

	self.btnAdsorptionSiteUButton:SetActive(false)

	local entity = self.avatarScene:getCurEntity()

	entity:syncToServer()

	local info = self:createJewelryInfo(optionData.accessoryId, optionData.reactionKey)

	if not Utils.isEmptyTable(info) then
		pg.me:serverMsg("RPC_CS_SetJewelryInfo", slotData.slotId, optionData.accessoryId, info, function()
			pg.global.showBubbleMessageRaw(pg.getGameString("PET_ACCESSORY_SAVE_SUCCESS"), 3)
		end)
	end

	self.rootUComponent:TryChangePage("State", "Detail")
	self.avatarScene:setCameraRotationOffset(0)
	avatarMgr.globalStack:Clear()
	self.ctrl.ctrl:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel, function()
		return true
	end, self.rootUComponent.gameObject, "appearancePlayerAccessoryEscBind")
	self:passToRightInfoComponent(self.rootUComponent)
	self.view.topbarUWidget:SetActiveFastest(true)

	local state = entity:getCurrentPlayableState(PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)

	if state then
		state:SetSpeed(1)
	end

	self:showLit(false)
end

function PlayerAccessoryComponent:cancelEditor()
	self.btnAdsorptionSiteUButton:SetActive(false)

	local slotData = self.slotOptionComponent.slotUList.selectedItem
	local optionData = self.slotOptionComponent.optionUList.selectedItem

	if slotData and optionData then
		local lastInfoStr = pg.me.jewelryLastInfos[optionData.accessoryId]

		if lastInfoStr then
			self:refreshAttachByServer(optionData.accessoryId, optionData.reactionKey, lastInfoStr)
		else
			avatarMgr.avatarMakeup:ResetAttachToPreset(optionData.reactionKey)
		end
	end

	self.rootUComponent:TryChangePage("State", "Detail")
	self.view.topbarUWidget:SetActiveFastest(true)
	self.avatarScene:setCameraRotationOffset(0)
	avatarMgr.globalStack:Clear()

	local entity = self.avatarScene:getCurEntity()
	local state = entity:getCurrentPlayableState(PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)

	if state then
		state:SetSpeed(1)
	end

	self:showLit(false)
	self:passToRightInfoComponent(self.rootUComponent)
end

function PlayerAccessoryComponent:refreshColorAccessory()
	local colorAccessoryList = self.model:getColorAccessoryList(self.selectAccessoryId)

	self.colorAccessoryUList:SetList(colorAccessoryList)

	local slotId = self.ctrl.slotOptionComponent.slotUList.selectedItem.slotId
	local colorJewelryId = pg.me.curShow[slotId] and pg.me.curShow[slotId].colorJewelryId or 0

	self.colorAccessorySourceUButton:SetActiveFastest(false)

	if colorJewelryId ~= 0 then
		for index, colorAccessoryData in ipairs(colorAccessoryList) do
			if colorAccessoryData.id == colorJewelryId then
				self.colorAccessoryUList:SelectItem(index - 1)
				self.colorAccessoryUList:GoToIndex(index - 1, true)

				break
			end
		end
	end
end

function PlayerAccessoryComponent:refreshColorAccessoryEquipState()
	local data = self.colorAccessoryUList.itemData

	for _, v in pairs(data) do
		v.isWear = self.model:isColorAccessoryWear(self.selectAccessoryId, v.id)
	end

	self.colorAccessoryUList:RefreshList()
end

function PlayerAccessoryComponent:onChangeColorAccessory(param)
	if not param.reactionKey or not param.resId then
		return
	end

	avatarMgr.avatarMakeup:ChangeAttachResId(param.reactionKey, param.resId)
end

function PlayerAccessoryComponent:refreshButtonState()
	local globalStack = pg.global.avatarMgr.globalStack

	self.backwardUButton.interactable = globalStack:CanBackward()
	self.forwardUButton.interactable = globalStack:CanForward()
end

function PlayerAccessoryComponent:checkAccessoryEquipped(data)
	local entity = self.avatarScene:getCurEntity()

	return LuaUIUtils.isAccessoryEquipped(entity, data.accessoryId)
end

function PlayerAccessoryComponent:checkAccessoryHave(data)
	return data.claimed
end

function PlayerAccessoryComponent:checkSlotCanFocus(data)
	return data.state ~= LuaUIUtils.SLOT_STATE.LOCKED
end

function PlayerAccessoryComponent:onInputDeviceChanged(deviceType)
	return
end

function PlayerAccessoryComponent:passToRightInfoComponent(originCmp, extra)
	return self.ctrl:passToRightInfoComponent(originCmp, extra)
end

return PlayerAccessoryComponent
