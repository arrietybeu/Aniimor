-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AccessoryPetPreset\\AccessoryPetPresetCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local AccessoryPetPresetCtrl = Class.LightClass("AccessoryPetPresetCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HotkeyConst = require("Const.HotkeyConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local PetData = require("Data.pet_data")
local ClientModelUtils = require("Utils.ClientModelUtils")
local AppearanceEffectUtils = require("Utils.AppearanceEffectUtils")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local AppearanceJewelryPetData = require("Data.appearance_jewelry_pet_data")
local AttachPointData = require("Data.pet_appearance_point_data")
local PetJewelryOssCache = require("Utils.PetJewelryOssCache")

AccessoryPetPresetCtrl.messages = {}

function AccessoryPetPresetCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self.model:initQuickPhotoCache()

	self.selectTabBtn = nil
end

function AccessoryPetPresetCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.backUButton.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:restoreCurrentWearModel()
			self:dismiss()
		end
	end

	function self.view.backUButton.luaClick()
		self:restoreCurrentWearModel()
		self:dismiss()
	end

	function self.view.outfitUList.luaRenderItem(button, index, data)
		self:onRenderPresetItem(button, index, data)
	end

	function self.view.contentUList.luaRenderItem(button, index, data)
		self:onRenderAccessItem(button, data)
	end

	function self.view.editUButton.luaClick()
		pg.global.ui.tips:showCommonInput(pg.getGameString("EDIT"), function(newName)
			if string.isNilOrEmpty(newName) then
				pg.global.showBubbleMessageRaw(pg.getGameString("NAME_NOT_VALID"))

				return true
			end

			self.model:setPresetName(self.selectTabBtn.dataFromUList.slot, newName, function(res)
				self:refreshSelectPreset()
			end)
		end)
	end

	function self.view.saveSuitUButton.luaClick()
		self:onBtnSavePreset()
	end

	function self.view.useSuitUWidget.luaClick()
		self:onBtnUsePreset()
	end

	function self.view.previousUList.luaRenderItem(button, index, data)
		self:onRenderAccessItem(button, data)
	end

	function self.view.nextUList.luaRenderItem(button, index, data)
		self:onRenderAccessItem(button, data)
	end

	function self.view.saveUButton.luaClick()
		self:onBtnConfirmOperation()
	end

	function self.view.cancelUButton.luaClick()
		self:onBtnCancelOperation()
	end

	function self.view.rootUComponent.luaTryChangePage(controllerName, pageIndex, lastPageIndex)
		if controllerName == "ButtonState" then
			if pageIndex == 1 then
				local objectReference = self.view.saveSuitUButton:GetComponent("ObjectReference")
				local txtNameUText = objectReference:GetRefValue("txtNameUText")

				ClientTextUtils.setText(txtNameUText, pg.getGameString("OUTFIT_SAVE"))
			elseif pageIndex == 2 then
				local objectReference = self.view.saveSuitUButton:GetComponent("ObjectReference")
				local txtNameUText = objectReference:GetRefValue("txtNameUText")

				ClientTextUtils.setText(txtNameUText, pg.getGameString("CHANGE_OUTFIT"))

				local objectReference1 = self.view.useSuitUWidget:GetComponent("ObjectReference")
				local txtNameUText1 = objectReference1:GetRefValue("txtNameUText")

				ClientTextUtils.setText(txtNameUText1, pg.getGameString("USE_OUTFIT"))
			end
		end
	end
end

function AccessoryPetPresetCtrl:onDestroy()
	self:restoreCurrentWearModel()
	UICtrl.onDestroy(self)
	self.model:destroy()
end

function AccessoryPetPresetCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.curPetId = info.petId
	self.selectCallback = info.selectCallback

	self.view.rootUComponent:TryChangePage("PetPreset", 1)
	self.view.arrowUImage.gameObject:SetActiveEx(false)
end

function AccessoryPetPresetCtrl:refreshConsoleBarState()
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("ConsoleBar_AccessoryPetPreset_CameraZoom", true)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("ConsoleBar_AccessoryPetPreset_CameraMove", true)
end

function AccessoryPetPresetCtrl:onShow()
	self._hasRestoreWear = false

	PetJewelryOssCache.ensureLoaded(function()
		self:clearTryWearOnEnter()
		self.model:initAvatarScene(self.curPetId)
		self:refreshList()

		local tInfo = self.model:getTitleInfo()

		self.view.imgPet.url = tInfo.refPetIcon

		ClientTextUtils.setText(self.view.petClanTitle, tInfo.title)
	end)
end

function AccessoryPetPresetCtrl:clearTryWearOnEnter()
	local appearanceV2 = pg.global.ui.appearanceV2

	if not appearanceV2 or not appearanceV2.components or not appearanceV2.components.pet then
		return
	end

	local petComp = appearanceV2.components.pet

	if petComp.model and petComp.model.clearTryAccessData then
		petComp.model:clearTryAccessData()
	end

	petComp:refreshAllList()
end

function AccessoryPetPresetCtrl:addPetAttachWithJewelryData(entity, modelView, slot, accessoryId, instanceId, jewelryInfo, useOss)
	local cfg = AppearanceJewelryPetData[accessoryId]

	if not cfg or not cfg.res or not modelView or not modelView.modelInfo then
		return false
	end

	local slotInfo = jewelryInfo and jewelryInfo[slot]
	local attachInfo

	if useOss then
		attachInfo = PetJewelryOssCache.getSavedTransform(self.curPetId, accessoryId, slotInfo)
	else
		attachInfo = slotInfo
	end

	if attachInfo then
		local localPos = Vector3.New(attachInfo.posX, attachInfo.posY, attachInfo.posZ)
		local localRot = Vector3.New(attachInfo.rotX, attachInfo.rotY, attachInfo.rotZ)
		local scale = Vector3.New(attachInfo.scale, attachInfo.scale, attachInfo.scale)

		modelView.modelInfo:AddAttachInfo(cfg.res, instanceId, attachInfo.attachBone, localPos, localRot, scale, false)
		AppearanceEffectUtils.setPetAccessory(entity, slot, accessoryId, instanceId, cfg.res)

		return true
	end

	local pInfo = pg.me:getPetInfo(self.curPetId)
	local templateId = pInfo and pInfo.templateId
	local refId = templateId and (PetData[templateId].refId or templateId) or nil
	local localCfg = templateId and pgUtils.GetAccessoryConfigFromLocal(templateId, accessoryId) or nil

	if not localCfg and refId then
		localCfg = pgUtils.GetAccessoryConfigFromLocal(refId, accessoryId)
	end

	if localCfg then
		ClientModelUtils.addPetAttachInfo(modelView.modelInfo, cfg.res, instanceId, localCfg.attachHp, localCfg.localPosition, localCfg.localRotation, Vector3.New(localCfg.scale, localCfg.scale, localCfg.scale))
		AppearanceEffectUtils.setPetAccessory(entity, slot, accessoryId, instanceId, cfg.res)

		return true
	end

	return false
end

function AccessoryPetPresetCtrl:addPetAttachWithServerData(entity, modelView, slot, accessoryId, instanceId)
	local curInfo = pg.me.petJewelryInfos[self.curPetId]

	return self:addPetAttachWithJewelryData(entity, modelView, slot, accessoryId, instanceId, curInfo, true)
end

function AccessoryPetPresetCtrl:refreshAndFocus()
	local dataList = self.model:initPresetDataList()

	self.view.outfitUList:SetList(dataList)

	local index = 1
	local num = #dataList

	for i = num, 1, -1 do
		local v = dataList[i]

		if v.state == self.model.OUTFIT_TAB.EMPTY then
			index = i

			break
		end
	end

	local res, tabBtn = self.view.outfitUList:TryGetChildAt(index - 1)

	if not res then
		return
	end

	tabBtn:OnClickSimulate()
end

function AccessoryPetPresetCtrl:refreshAllList(button)
	self.model:refreshPresetDataList()
	self.view.outfitUList:RefreshList()
	self.model:refreshAccessDataList(self.accessories)
	self:onFocusTab(button)
end

function AccessoryPetPresetCtrl:refreshSelectPreset(sprite, button)
	local uButton = button or self.selectTabBtn

	if IsNil(uButton) then
		return
	end

	local data = uButton.dataFromUList

	if not data then
		return
	end

	self.model:refreshPresetData(data)

	if sprite then
		if NotNil(data.sprite) and data.sprite ~= sprite then
			pg.global.mobileCameraMgr:DestroySpriteTexture(data.sprite)
		end

		data.sprite = sprite

		local _, btn = self.view.outfitUList:TryGetChildAt(data.slot)
		local objectReference = btn:GetComponent("ObjectReference")
		local suitUImage = objectReference:GetRefValue("suitUImage")

		suitUImage.sprite = sprite

		btn:TryChangePage("State", 1)
	else
		self.view.outfitUList:RefreshElement(data.slot)
	end

	if self.selectTabBtn == uButton then
		self:onFocusTab(uButton)
	end
end

function AccessoryPetPresetCtrl:refreshList()
	local dataList = self.model:getPresetDataList()

	self.view.outfitUList:SetList(dataList)

	local res, tabBtn = self.view.outfitUList:TryGetChildAt(0)

	if not res then
		return
	end

	tabBtn:OnClickSimulate()
end

function AccessoryPetPresetCtrl:onRenderPresetItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local rootUComponent = objectReference:GetRefValue("rootUComponent")
	local nameUText = objectReference:GetRefValue("nameUText")
	local suitUImage = objectReference:GetRefValue("suitUImage")
	local costUImage = objectReference:GetRefValue("costUImage")
	local costUText = objectReference:GetRefValue("costUText")

	rootUComponent:TryChangePage("State", data.state)
	ClientTextUtils.setText(nameUText, data.name)

	if data.state == self.model.OUTFIT_TAB.LOCKED then
		costUImage:SetActiveFastest(true)

		costUImage.url = LuaUIUtils.getIconByItemId(data.unlockCost.id)

		ClientTextUtils.setText(costUText, data.unlockCost.num or "")
	else
		costUImage:SetActiveFastest(false)
	end

	if data.state == self.model.OUTFIT_TAB.NORMAL and not data.downloaded or data.isDirty then
		data.downloaded = true

		self.model:downloadQuickPhoto(data.slot, function(res, sprite)
			if not res then
				return
			end

			data.sprite = sprite

			if self:checkUIOpen() and button.dataFromUList == data then
				suitUImage.sprite = sprite
			end
		end)
	else
		suitUImage.sprite = data.sprite
	end

	function button.luaClick()
		self:onSelectTab(button, index)
	end
end

function AccessoryPetPresetCtrl:onSelectTab(button, index)
	local data = button.dataFromUList

	if data.state == self.model.OUTFIT_TAB.LOCKED then
		self:onUnlockPresetSlot(button, index)
	else
		self:onFocusTab(button)

		local previewData = data

		if data.state == self.model.OUTFIT_TAB.EMPTY then
			previewData = {
				state = self.model.OUTFIT_TAB.NOW
			}
		end

		self:previewPresetWear(previewData)
	end
end

function AccessoryPetPresetCtrl:previewPresetWear(presetData, callback)
	local entity = self.model.avatarScene and self.model.avatarScene:getCurEntity()

	if not entity or not entity.eModel then
		return
	end

	local modelView = entity.eModel.modelView

	if not modelView or not modelView.modelInfo then
		return
	end

	local customPresets, presetInfo

	if presetData and presetData.state == self.model.OUTFIT_TAB.NOW then
		local curInfo = pg.me.petJewelryInfos[self.curPetId]

		customPresets = curInfo and curInfo.customPresets
	else
		local presetDic = pg.me.petJewelryCustom[self.model.adjustPetProId]

		presetInfo = presetDic and presetDic[presetData.slot]
		customPresets = presetInfo and presetInfo.customPresets
	end

	self:clearPreviewPresetWear(entity, modelView)

	self.previewSlotAttachMap = {}

	if not customPresets then
		ClientModelUtils.refreshModels(entity, modelView)
		self:afterRefreshModel(modelView, callback)

		return
	end

	local maxSlot = table.nums(AttachPointData)
	local useServerData = presetData and presetData.state == self.model.OUTFIT_TAB.NOW

	for slot = 1, maxSlot do
		local accessoryId = customPresets[slot]

		if accessoryId and accessoryId ~= 0 then
			local instanceId = useServerData and string.format("%d_%d", slot, accessoryId) or string.format("preset_preview_%d_%d", slot, accessoryId)

			self.previewSlotAttachMap[slot] = instanceId

			if useServerData then
				self:addPetAttachWithServerData(entity, modelView, slot, accessoryId, instanceId)
			elseif presetInfo then
				self:addPetAttachWithJewelryData(entity, modelView, slot, accessoryId, instanceId, presetInfo, false)
			end
		end
	end

	ClientModelUtils.refreshModels(entity, modelView)
	self:afterRefreshModel(modelView, callback)
end

function AccessoryPetPresetCtrl:clearPreviewPresetWear(entity, modelView)
	if not modelView or not modelView.modelInfo then
		return
	end

	if self.previewSlotAttachMap then
		for slot, instanceId in pairs(self.previewSlotAttachMap) do
			if instanceId then
				modelView.modelInfo:RemoveAttachInfoWithId(instanceId)
				AppearanceEffectUtils.setPetAccessory(entity, slot, nil)
			end
		end
	end

	local curInfo = pg.me.petJewelryInfos[self.curPetId]

	if curInfo and curInfo.customPresets then
		for slot, accessoryId in curInfo.customPresets:items() do
			if accessoryId and accessoryId ~= 0 then
				modelView.modelInfo:RemoveAttachInfoWithId(string.format("%d_%d", slot, accessoryId))
				AppearanceEffectUtils.setPetAccessory(entity, slot, nil)
			end
		end
	end
end

function AccessoryPetPresetCtrl:restoreFormalWearToModel(entity, modelView)
	if not modelView or not modelView.modelInfo then
		return
	end

	self:clearPreviewPresetWear(entity, modelView)

	self.previewSlotAttachMap = nil

	local curInfo = pg.me.petJewelryInfos[self.curPetId]

	if not curInfo or not curInfo.customPresets then
		ClientModelUtils.refreshModels(entity, modelView)
		self:afterRefreshModel(modelView)

		return
	end

	for slot, accessoryId in curInfo.customPresets:items() do
		if accessoryId and accessoryId ~= 0 then
			local instanceId = string.format("%d_%d", slot, accessoryId)

			self:addPetAttachWithServerData(entity, modelView, slot, accessoryId, instanceId)
		end
	end

	ClientModelUtils.refreshModels(entity, modelView)
	self:afterRefreshModel(modelView)
end

function AccessoryPetPresetCtrl:restoreCurrentWearModel()
	if self._hasRestoreWear then
		return
	end

	local appearanceV2 = pg.global.ui.appearanceV2

	if appearanceV2 and appearanceV2.components and appearanceV2.components.pet then
		local petComp = appearanceV2.components.pet
		local entity = petComp.avatarScene and petComp.avatarScene:getCurEntity()
		local modelView = entity and entity.eModel and entity.eModel.modelView

		if modelView then
			self:restoreFormalWearToModel(entity, modelView)
		end

		petComp:refreshAllList()

		self._hasRestoreWear = true

		return
	end

	local entity = self.model.avatarScene and self.model.avatarScene:getCurEntity()

	if not entity or not entity.eModel then
		return
	end

	local modelView = entity.eModel.modelView

	if not modelView or not modelView.modelInfo then
		return
	end

	self:restoreFormalWearToModel(entity, modelView)

	self._hasRestoreWear = true
end

function AccessoryPetPresetCtrl:onUnlockPresetSlot(button, index)
	local data = button.dataFromUList
	local cost = data.unlockCost
	local costText = LuaUIUtils.getItemCountConsumeShowText(cost.id, cost.num, true)

	pg.global.ui.commonUseConfirm:open({
		type = 4,
		title = pg.getGameString("UNLOCK_TITLE"),
		tipTop = string.format(pg.getGameString("HOME_BUY_DESC"), costText),
		data = {
			{
				cost.id,
				cost.num
			}
		},
		confirmCb = function()
			self.model:unlockPresetSlot2Server(function(res)
				if not res then
					return
				end

				self:refreshAndFocus()
			end)
		end,
		cancelCb = function()
			button:TryChangePage("GamePadFocus", 0)
			button:TryChangePage("button", 0)
		end
	})
end

function AccessoryPetPresetCtrl:onFocusTab(button)
	local btnList = self.view.outfitUList:GetAllButtons()

	for i = 0, btnList.Length - 1 do
		local v = btnList[i]

		v:TryChangePage("GamePadFocus", v == button and 1 or 0)
		v:TryChangePage("button", v == button and 5 or 0)
	end

	local data = button.dataFromUList

	if data.state == self.model.OUTFIT_TAB.LOCKED then
		self.view.rootUComponent:TryChangePage("ButtonState", "None")
		self.view.rootUComponent:TryChangePage("canEditName", "None")
	elseif data.state == self.model.OUTFIT_TAB.EMPTY then
		self.view.rootUComponent:TryChangePage("ButtonState", "Empty")
		self.view.rootUComponent:TryChangePage("canEditName", "Edit")
	elseif data.state == self.model.OUTFIT_TAB.NORMAL then
		self.view.rootUComponent:TryChangePage("ButtonState", "Suit")
		self.view.rootUComponent:TryChangePage("canEditName", "Edit")
	elseif data.state == self.model.OUTFIT_TAB.NOW then
		self.view.rootUComponent:TryChangePage("ButtonState", "None")
		self.view.rootUComponent:TryChangePage("canEditName", "None")
	end

	self.selectTabBtn = button
	self.accessories = self.model:getOutfitAccesses(data)

	self.view.contentUList:SetList(self.accessories)
	ClientTextUtils.setText(self.view.nameUInputField, data.name)
end

function AccessoryPetPresetCtrl:onRenderAccessItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local rootUComponent = objectReference:GetRefValue("rootUComponent")
	local slotUImage = objectReference:GetRefValue("slotUImage")
	local emptySlotUImage = objectReference:GetRefValue("emptySlotUImage")

	rootUComponent:TryChangePage("state", data.state)

	if data.state == self.model.CONTENT_TAB.EMPTY then
		button.luaClick = nil

		return
	end

	rootUComponent:TryChangePage("Quality", data.quality)

	iconUImage.url = data.icon

	if data.accessoryId and data.accessoryId ~= 0 then
		function button.luaClick()
			pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
				id = data.accessoryId,
				targetRect = button
			})
		end
	else
		button.luaClick = nil
	end
end

function AccessoryPetPresetCtrl:onBtnSavePreset()
	local presetData = self.selectTabBtn.dataFromUList

	if presetData.state == self.model.OUTFIT_TAB.EMPTY then
		self:onOperationPresetWithOpName(self.model.OP_TYPE.SAVE_TO_EMPTY)
	else
		self:onOperationPresetWithOpName(self.model.OP_TYPE.SAVE_TO_OUTFIT)
	end
end

function AccessoryPetPresetCtrl:onBtnUsePreset()
	self:onOperationPresetWithOpName(self.model.OP_TYPE.USE_FROM_OUTFIT)
end

function AccessoryPetPresetCtrl:onOperationPresetWithOpName(case)
	local presetData = self.selectTabBtn.dataFromUList

	self.view.rootUComponent:TryChangePage("switchPreset", "show")

	local preDataList, nexDataList

	if case == self.model.OP_TYPE.USE_FROM_OUTFIT then
		preDataList = self.model:getCurrentEquipAccess()
		nexDataList = self.model:getOutfitAccesses(presetData)

		ClientTextUtils.setText(self.view.infoText, pg.getGameString("APPEARANCE_USE_FROM_OUTFIT"))
	elseif case == self.model.OP_TYPE.SAVE_TO_OUTFIT then
		preDataList = self.model:getOutfitAccesses(presetData)
		nexDataList = self.model:getCurrentEquipAccess()

		ClientTextUtils.setText(self.view.infoText, pg.getGameString("APPEARANCE_SAVE_TO_OUTFIT"))
	elseif case == self.model.OP_TYPE.SAVE_TO_EMPTY then
		preDataList = self.model:getOutfitAccesses(presetData)
		nexDataList = self.model:getCurrentEquipAccess()

		ClientTextUtils.setText(self.view.infoText, pg.getGameString("APPEARANCE_SAVE_TO_EMPTY"))
	end

	self.curOperation = case

	self.view.previousUList:SetList(preDataList)
	self.view.nextUList:SetList(nexDataList)
end

function AccessoryPetPresetCtrl:onBtnConfirmOperation()
	if self.curOperation == nil then
		return
	end

	local case = self.curOperation

	if case == self.model.OP_TYPE.USE_FROM_OUTFIT then
		self:onUsePresetFromServer()
	elseif case == self.model.OP_TYPE.SAVE_TO_OUTFIT then
		self:onSavePreset2Server(true)
	elseif case == self.model.OP_TYPE.SAVE_TO_EMPTY then
		self:onSavePreset2Server(false)
	end
end

function AccessoryPetPresetCtrl:onSavePreset2Server(update)
	local button = self.selectTabBtn
	local presetData = button.dataFromUList
	local view = self.view

	self.model:savePreset2Server(presetData.slot, function(res)
		if not res or self.view ~= view or not self:checkUIOpen() then
			return
		end

		self.view.rootUComponent:TryChangePage("switchPreset", "hide")
		self.model:refreshPresetData(presetData)
		self:onFocusTab(button)
		self:previewPresetWear(presetData, function()
			self:captureQuickPhoto(button, update)
		end)
	end)
end

function AccessoryPetPresetCtrl:captureQuickPhoto(button, update)
	local objectReference = button:GetComponent("ObjectReference")
	local suitUImage = objectReference:GetRefValue("suitUImage")
	local imageSize = suitUImage.sizeDelta
	local view = self.view
	local data = button.dataFromUList

	self.model:captureQuickPetPresetPhoto(imageSize, function(sprite, imageKey, success)
		if not success or self.view ~= view or not self:checkUIOpen() or not self.model:retainRuntimeSprite(sprite) then
			if NotNil(sprite) then
				pg.global.mobileCameraMgr:DestroySpriteTexture(sprite)
			end

			return
		end

		data.isDirty = true

		self.model:uploadQuickPhoto(data, imageKey, update, function()
			if not self.view then
				return
			end

			self:refreshSelectPreset(sprite, button)
			pg.global.showBubbleMessageRaw(pg.getGameString("PET_ACCESSORY_SAVE_SUCCESS"), 3)
		end)
	end)
end

function AccessoryPetPresetCtrl:onUsePresetFromServer()
	local presetData = self.selectTabBtn.dataFromUList

	self.model:applyPreset(presetData.slot, function(res, countTable)
		if not res then
			return
		end

		local allItemCount = countTable[1]
		local successCount = countTable[2]

		if successCount <= 0 then
			pg.global.showBubbleMessageRaw(string.format(pg.getGameString("PET_ACCESSORY_APPLY_FAIL_1"), allItemCount), 3)

			return
		end

		if successCount < allItemCount then
			pg.global.showBubbleMessageRaw(string.format(pg.getGameString("PET_ACCESSORY_APPLY_SUCCESS_1"), allItemCount - successCount), 3)
		else
			pg.global.showBubbleMessageRaw(pg.getGameString("PET_ACCESSORY_APPLY_SUCCESS"), 3)
		end

		self.view.rootUComponent:TryChangePage("switchPreset", "hide")

		if self.selectCallback then
			self.selectCallback(self.curPetId)
		end

		self:refreshAllList(self.selectTabBtn)

		local appearanceV2 = pg.global.ui.appearanceV2

		if appearanceV2 and appearanceV2.components and appearanceV2.components.pet then
			appearanceV2.components.pet:refreshAllList()
		end
	end)
end

function AccessoryPetPresetCtrl:onBtnCancelOperation()
	self.view.rootUComponent:TryChangePage("switchPreset", "hide")
end

function AccessoryPetPresetCtrl:onHide()
	self:restoreCurrentWearModel()
end

function AccessoryPetPresetCtrl:afterRefreshModel(modelView, callback)
	self:killTimer(self.presetCaptureTimer)

	self.presetCaptureTimer = nil

	if not callback then
		return
	end

	self.presetCaptureTimer = self:startTimer(function()
		if not self:checkUIOpen() then
			self:killTimer(self.presetCaptureTimer)

			self.presetCaptureTimer = nil

			return
		end

		if not modelView.firstLoaded or not modelView:IsAnimatorRead() then
			return
		end

		self:killTimer(self.presetCaptureTimer)

		self.presetCaptureTimer = nil

		callback()
	end, 0.05, true)
end

return AccessoryPetPresetCtrl
