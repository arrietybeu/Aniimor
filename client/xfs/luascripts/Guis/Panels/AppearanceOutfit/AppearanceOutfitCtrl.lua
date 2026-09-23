-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AppearanceOutfit\\AppearanceOutfitCtrl.lua

local MessageName = require("Const.MessageName")
local CallbackHandler = require("Core.Common.CallbackHandler")
local Class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local PlayableConst = require("Common.Const.PlayableConst")
local ServiceUtils = require("Common.Utils.ServiceUtils")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local UICtrl = require("Guis.UICtrl")
local ClientSimpleVirtualPlayer = require("Entities.ClientSimpleVirtualPlayer")
local ClientVirtualEntityUtils = require("Utils.ClientVirtualEntityUtils")
local ClientModelUtils = require("Utils.ClientModelUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local AvatarPresetData = require("Data.avatar_preset_data")
local AppearancePointEnum = require("Data.appearance_point_enum")
local AppearanceOutfitCtrl = Class.LightClass("AppearanceOutfitCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientUtils = require("Utils.ClientUtils")
local Utils = require("Common.Utils.Utils")
local Vector3 = Vector3
local GameConst = CS.FunPlus.WorldX.Const.GameConst

AppearanceOutfitCtrl.messages = {}

local LeftAvatarPos = Vector3(0.5, 0, 0)
local MiddleAvatarPos = Vector3.zero
local RightAvatarPos = Vector3(-0.5, 0, 0)

function AppearanceOutfitCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.templateId = info.templateId
	self.entityId = info.curPresetKey
	self.dummyEntityId = "dummy"
	self.avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
end

function AppearanceOutfitCtrl:addListener()
	function self.view.backUButton.luaClick()
		self:closePanel()
	end

	self.needDestroyDownloadSprite = {}

	function self.view.outfitUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local rootUComponent = objectReference:GetRefValue("rootUComponent")
		local nameUText = objectReference:GetRefValue("nameUText")
		local suitUImage = objectReference:GetRefValue("suitUImage")
		local costUImage = objectReference:GetRefValue("costUImage")
		local costUText = objectReference:GetRefValue("costUText")

		rootUComponent:TryChangePage("State", data.state)
		ClientTextUtils.setText(nameUText, pg.getLocalizationText(data.name))
		ClientTextUtils.setText(costUText, data.costNum or "")

		if data.costType then
			costUImage:SetActiveFastest(true)

			costUImage.url = LuaUIUtils.getIconByItemId(data.costType)
		else
			costUImage:SetActiveFastest(false)
		end

		if data.photoId then
			ServiceUtils.kvServiceFind(data.photoId, function(status, response)
				if status.status and response.value then
					ClientUtils.pullPicture(response.value, function(_, pic)
						if not pic then
							return
						end

						if not self:checkUIOpen() then
							pg.global.mobileCameraMgr:DestroySpriteTexture(pic)

							return
						end

						self.needDestroyDownloadSprite[#self.needDestroyDownloadSprite + 1] = pic

						if self.view.outfitUList:GetData(button) == data then
							suitUImage.sprite = pic
						end
					end)
				else
					suitUImage.sprite = nil
				end
			end)
		end
	end

	function self.view.outfitUList.luaSelectedChanged(uList)
		local slotItem = uList.selectedItem

		if not slotItem then
			return
		end

		local contentList = {}

		if slotItem.state == self.model.OUTFIT_TAB.LOCKED then
			self.view.rootUComponent:TryChangePage("ButtonState", "None")
			self.view.rootUComponent:TryChangePage("canEditName", "None")
		elseif slotItem.state == self.model.OUTFIT_TAB.EMPTY then
			contentList = self.model:getContentList(slotItem.slotId)

			self.view.rootUComponent:TryChangePage("ButtonState", "Empty")
			self.view.rootUComponent:TryChangePage("canEditName", "Edit")

			local objectReference = self.view.saveSuitUButton:GetComponent("ObjectReference")
			local txtNameUText = objectReference:GetRefValue("txtNameUText")

			ClientTextUtils.setText(txtNameUText, pg.getGameString("OUTFIT_SAVE"))
		elseif slotItem.state == self.model.OUTFIT_TAB.NORMAL then
			contentList = self.model:getContentList(slotItem.slotId)

			self.view.rootUComponent:TryChangePage("ButtonState", "Suit")
			self.view.rootUComponent:TryChangePage("canEditName", "Edit")

			local objectReference = self.view.saveSuitUButton:GetComponent("ObjectReference")
			local txtNameUText = objectReference:GetRefValue("txtNameUText")

			ClientTextUtils.setText(txtNameUText, pg.getGameString("CHANGE_OUTFIT"))
		elseif slotItem.state == self.model.OUTFIT_TAB.NOW then
			contentList = self.model:getContentList()

			self.view.rootUComponent:TryChangePage("ButtonState", "None")
			self.view.rootUComponent:TryChangePage("canEditName", "None")
		end

		self.view.contentUList:SetList(contentList)

		self.view.nameUInputField.text = ""

		ClientTextUtils.setText(self.view.nameUInputField, pg.getLocalizationText(slotItem.name))
	end

	function self.view.outfitUList.luaClick(button, data)
		if data.state == self.model.OUTFIT_TAB.LOCKED then
			local costText = LuaUIUtils.getItemCountConsumeShowText(data.costType, data.costNum, true)

			pg.global.ui.commonUseConfirm:open({
				type = 4,
				title = pg.getGameString("APPEARANCE_UNLOCK_TITLE"),
				tipTop = string.format(pg.getGameString("HOME_BUY_DESC"), costText),
				data = {
					{
						data.costType,
						data.costNum
					}
				},
				confirmCb = function()
					local param = {
						triggerSelectedChanged = true,
						forceSelectSlotId = data.slotId
					}

					pg.me:serverMsg("RPC_CS_UnlockCustom", CallbackHandler(self, "refreshOutfitList", param))
				end,
				cancelCb = function()
					self.view.outfitUList:SelectItem(0)
				end
			})
		elseif data.state == self.model.OUTFIT_TAB.EMPTY then
			self.avatarScene:previewCustomShow(self.entityId)
		elseif data.state == self.model.OUTFIT_TAB.NORMAL then
			self.avatarScene:previewCustomShow(self.entityId, data.slotId)
		elseif data.state == self.model.OUTFIT_TAB.NOW then
			self.avatarScene:previewCustomShow(self.entityId)
		end
	end

	function self.view.contentUList.luaRenderItem(button, index, data)
		self.view:renderContentList(button, data)
	end

	function self.view.editUButton.luaClick()
		pg.global.ui.tips:showCommonInput(pg.getGameString("EDIT"), function(newName)
			if string.isNilOrEmpty(newName) then
				pg.global.showBubbleMessageRaw(pg.getGameString("NAME_NOT_VALID"))

				return true
			end

			local slotItem = self.view.outfitUList.selectedItem
			local param = {
				forceSelectSlotId = slotItem.slotId,
				newName = newName
			}
			local isShowBag = pg.me.appearanceCustom[slotItem.slotId].isShowBag

			pg.me:serverMsg("RPC_CS_SetCustomNameAndBag", "appearanceCustom", slotItem.slotId, newName, isShowBag, CallbackHandler(self, "refreshOutfitList", param))
		end)
	end

	function self.view.saveSuitUButton.luaClick()
		local selectedOutfit = self.view.outfitUList.selectedItem

		if not selectedOutfit then
			return
		end

		if selectedOutfit.state == self.model.OUTFIT_TAB.EMPTY then
			self:enterSwitchConfirmMode(self.model.OP_TYPE.SAVE_TO_EMPTY)
		elseif selectedOutfit.state == self.model.OUTFIT_TAB.NORMAL then
			self:enterSwitchConfirmMode(self.model.OP_TYPE.SAVE_TO_OUTFIT)
		end
	end

	local objectReference1 = self.view.useSuitUWidget:GetComponent("ObjectReference")
	local txtNameUText1 = objectReference1:GetRefValue("txtNameUText")

	ClientTextUtils.setText(txtNameUText1, pg.getGameString("USE_OUTFIT"))

	function self.view.useSuitUWidget.luaClick()
		self:enterSwitchConfirmMode(self.model.OP_TYPE.USE_FROM_OUTFIT)
	end

	function self.view.cancelUButton.luaClick()
		self:exitSwitchConfirmMode()
	end

	function self.view.saveUButton.luaClick()
		local slotItem = self.view.outfitUList.selectedItem
		local isShowBag = pg.me.curShow.isShowBag
		local name = self.view.nameUInputField.text
		local entity = self.avatarScene:getEntity(self.entityId)

		if self.opType == self.model.OP_TYPE.USE_FROM_OUTFIT then
			for slotId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
				entity.customShow[slotId] = nil
			end

			for slotId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
				entity.customShow[slotId] = nil
			end

			pg.me:serverMsg("RPC_CS_SetAppearanceCustom", slotItem.slotId, CallbackHandler(self, "onConfirmCustom", slotItem.slotId))
			self:exitSwitchConfirmMode()
		else
			self.view.rootUComponent:TryChangePage("switchPreset", "hide")

			local captureEntityId = self.entityId

			if self.opType == self.model.OP_TYPE.SAVE_TO_OUTFIT then
				captureEntityId = self.dummyEntityId
			end

			self:snapShot(function(imageKey)
				local param = {
					triggerSelectedChanged = true,
					forceSelectSlotId = slotItem.slotId
				}
				local customInfo = {}

				for slotId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
					local configId = entity:getAppearanceConfigId(slotId)
					local jewelryInfo = pg.me.curShow[slotId]

					customInfo[slotId] = {
						configId = configId,
						jewelryInfo = jewelryInfo and jewelryInfo:getRawTable()
					}
				end

				for slotId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
					local configId = entity:getAppearanceConfigId(slotId)
					local clothesDesign = pg.me.curShow.clothesDesigns and pg.me.curShow.clothesDesigns[slotId]

					customInfo[slotId] = {
						configId = configId,
						clothesDesign = clothesDesign and clothesDesign:getRawTable()
					}
				end

				pg.me:serverMsg("RPC_CS_SaveAppearanceCustom", slotItem.slotId, customInfo, imageKey, CallbackHandler(self, "refreshOutfitList", param))
				pg.me:serverMsg("RPC_CS_SetCustomNameAndBag", "appearanceCustom", slotItem.slotId, name, isShowBag, CallbackHandler(self, "refreshBag", slotItem.slotId))
				self:exitSwitchConfirmMode()
			end, captureEntityId)
		end
	end

	function self.view.previousUList.luaRenderItem(button, index, data)
		self.view:renderContentList(button, data)
	end

	function self.view.nextUList.luaRenderItem(button, index, data)
		self.view:renderContentList(button, data)
	end
end

function AppearanceOutfitCtrl:snapShot(callback, targetEntityId)
	targetEntityId = targetEntityId or self.entityId

	local entity = self.avatarScene:getEntity(targetEntityId)

	if not entity or not entity.eModel then
		if callback then
			callback("")
		end

		return
	end

	if self.opType == self.model.OP_TYPE.SAVE_TO_OUTFIT then
		self.avatarScene:setEntityPos(targetEntityId, MiddleAvatarPos)
		self.avatarScene:hideEntityWithId(self.entityId)
	end

	self.avatarScene:setEntityRot(targetEntityId, 0)
	pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.PRESET_SNAPSHOT)
	pg.game.input:setEnabledViewCtrl(false, ClientConst.ViewControl.PRESET_SNAPSHOT)
	TimerManager.addNextFrameCb(function()
		if not self.avatarScene then
			pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.PRESET_SNAPSHOT)
			pg.game.input:setEnabledViewCtrl(true, ClientConst.ViewControl.PRESET_SNAPSHOT)

			if callback then
				callback("")
			end

			return
		end

		local sizeDelta = Vector2.New(Screen.width / 2, Screen.height)
		local position = Vector2.New(Screen.width / 2 - sizeDelta.x / 2, Screen.height / 2 - sizeDelta.y / 2)

		Utils.captureAndCheckPhoto(Const.PhotoCheckScene.Share, function(_, _, success, imageKey)
			pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.PRESET_SNAPSHOT)
			pg.game.input:setEnabledViewCtrl(true, ClientConst.ViewControl.PRESET_SNAPSHOT)

			if not success then
				return
			end

			if callback then
				callback(imageKey)
			end
		end, position, sizeDelta, 3, false, true)
	end)
end

function AppearanceOutfitCtrl:onDestroy()
	UICtrl.onDestroy(self)
	self:exitSwitchConfirmMode()

	local entity = self.avatarScene:getEntity(self.entityId)

	if entity then
		entity.previewOutfitId = nil
	end

	self.avatarScene:previewCustomShow(self.entityId)

	self.avatarScene = nil

	for _, sprite in ipairs(self.needDestroyDownloadSprite) do
		pg.global.mobileCameraMgr:DestroySpriteTexture(sprite)
	end

	local appearanceV2 = pg.global.ui.appearanceV2

	if appearanceV2 and appearanceV2.components and appearanceV2.components.player and appearanceV2.components.player.curComponent then
		appearanceV2.components.player.curComponent:onEnterPage()
	end
end

function AppearanceOutfitCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self.avatarScene:addCameraZoomKeyBinding(self.view.gameObject)
end

function AppearanceOutfitCtrl:onShow()
	self:refreshOutfitList()
end

function AppearanceOutfitCtrl:refreshConsoleBarState()
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("ConsoleBar_AccessoryPetPreset_CameraZoom", true)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("ConsoleBar_AccessoryPetPreset_CameraMove", true)
end

function AppearanceOutfitCtrl:onHide()
	return
end

function AppearanceOutfitCtrl:onVisibleChange(visible)
	if visible then
		self.avatarScene:registerGesture(self.uid, {
			maskRayBoxTrans = self.view.maskRayBoxTrans
		})
	else
		self.avatarScene:unRegisterGesture(self.uid)
	end
end

function AppearanceOutfitCtrl:refreshOutfitList(info)
	local outfitUList = self.model:getOutfitList(pg.me)

	self.view.outfitUList:SetList(outfitUList)

	if info and info.forceSelectSlotId then
		for id, suitData in ipairs(outfitUList) do
			if suitData.slotId == info.forceSelectSlotId then
				self.view.outfitUList:SelectItem(id - 1, info.triggerSelectedChanged or false)
			end
		end
	else
		local res, btn = self.view.outfitUList:TryGetChildAt(0)

		if res then
			btn:OnClickSimulate()
		end
	end

	if info and info.newName then
		self.view.nameUInputField.text = info.newName
	end

	if info and info.forceSelectSlotId then
		self:restoreOutfitPreview()
	end
end

function AppearanceOutfitCtrl:enterSwitchConfirmMode(opType)
	self.view.rootUComponent:TryChangePage("switchPreset", "show")
	self.avatarScene:unRegisterGesture(self.uid)
	self.avatarScene:enableCameraMode(self.avatarScene.CAMERA.FIXED)

	self.opType = opType

	self:refreshPreviousAndNextList(opType)
	self:refreshAvatar(opType)

	self.recordLights = self.avatarScene:recordCurLight()

	if opType == self.model.OP_TYPE.USE_FROM_OUTFIT or opType == self.model.OP_TYPE.SAVE_TO_OUTFIT then
		self.avatarScene:hideAllLights()
		self.avatarScene:showPairLights(true)
	end
end

function AppearanceOutfitCtrl:restoreOutfitPreview()
	if not self.avatarScene then
		return
	end

	local slotItem = self.view.outfitUList.selectedItem

	if not slotItem then
		return
	end

	if slotItem.state == self.model.OUTFIT_TAB.NORMAL then
		self.avatarScene:previewCustomShow(self.entityId, slotItem.slotId)
	else
		self.avatarScene:previewCustomShow(self.entityId)
	end
end

function AppearanceOutfitCtrl:exitSwitchConfirmMode()
	self.view.rootUComponent:TryChangePage("switchPreset", "hide")
	self.avatarScene:registerGesture(self.uid, {
		maskRayBoxTrans = self.view.maskRayBoxTrans
	})
	self.avatarScene:enableCameraMode(self.avatarScene.CAMERA.SIMPLE)

	self.opType = nil

	self.avatarScene:showEntityWithId(self.entityId)
	self.avatarScene:setEntityPos(self.entityId, MiddleAvatarPos)
	self.avatarScene:setEntityRot(self.entityId, 0)
	self.avatarScene:hideEntityWithId(self.dummyEntityId)
	self.avatarScene:showPairLights(false)
	self.avatarScene:restorePrevLight(self.recordLights)
	self:restoreOutfitPreview()
end

function AppearanceOutfitCtrl:refreshPreviousAndNextList(opType)
	local slotItem = self.view.outfitUList.selectedItem

	if not slotItem then
		return
	end

	local previousList = {}
	local nextList = {}

	if opType == self.model.OP_TYPE.SAVE_TO_OUTFIT then
		previousList = self.model:getContentList(self.view.outfitUList.selectedItem.slotId)
		nextList = self.model:getContentList()

		self.view.arrowUImage:SetActiveFastest(true)
		ClientTextUtils.setText(self.view.previousUText, pg.getLocalizationText(slotItem.name))
		ClientTextUtils.setText(self.view.nextUText, pg.getGameString("APPEARANCE_CURRENT_SUIT"))
		ClientTextUtils.setText(self.view.infoText, pg.getGameString("APPEARANCE_SAVE_TO_OUTFIT"))
	elseif opType == self.model.OP_TYPE.USE_FROM_OUTFIT then
		previousList = self.model:getContentList()
		nextList = self.model:getContentList(self.view.outfitUList.selectedItem.slotId)

		self.view.arrowUImage:SetActiveFastest(true)
		ClientTextUtils.setText(self.view.previousUText, pg.getGameString("APPEARANCE_CURRENT_SUIT"))
		ClientTextUtils.setText(self.view.nextUText, pg.getLocalizationText(slotItem.name))
		ClientTextUtils.setText(self.view.infoText, pg.getGameString("APPEARANCE_USE_FROM_OUTFIT"))
	elseif opType == self.model.OP_TYPE.SAVE_TO_EMPTY then
		previousList = self.model:getContentList(self.view.outfitUList.selectedItem.slotId)
		nextList = self.model:getContentList()

		self.view.arrowUImage:SetActiveFastest(false)
		ClientTextUtils.setText(self.view.previousUText, pg.getLocalizationText(slotItem.name))
		ClientTextUtils.setText(self.view.nextUText, pg.getGameString("APPEARANCE_CURRENT_SUIT"))
		ClientTextUtils.setText(self.view.infoText, pg.getGameString("APPEARANCE_SAVE_TO_EMPTY"))
	end

	self.view.previousUList:SetList(previousList)
	self.view.nextUList:SetList(nextList)
end

function AppearanceOutfitCtrl:refreshAvatar(opType)
	if opType == self.model.OP_TYPE.SAVE_TO_EMPTY then
		self.avatarScene:setEntityPos(self.entityId, MiddleAvatarPos)
		self.avatarScene:setEntityRot(self.entityId, 0)

		return
	end

	local dummyEntity = self.avatarScene:getEntity(self.dummyEntityId)

	if not dummyEntity then
		local initDict = {
			needFacialHighLight = true,
			copyEntity = pg.me
		}

		dummyEntity = self.avatarScene:createEntity(self.dummyEntityId, ClientSimpleVirtualPlayer, initDict)

		dummyEntity.eModel:SetTransformParent(self.avatarScene.entityRootTransform, false)

		dummyEntity.eModel.enableCameraHitCheck = false

		function dummyEntity.modelPartModelAllLoaded()
			dummyEntity.eModel.modelModelView:RefreshCullingMode()
			self.avatarScene:playIdleAnimation(dummyEntity)

			dummyEntity.modelPartModelAllLoaded = nil
		end

		local presetData = self.avatarScene:getPresetData()

		ClientModelUtils.applyAnimController(dummyEntity, dummyEntity.eModel, presetData)
		dummyEntity:playRawAnimation("Show_Idle")
		ClientVirtualEntityUtils.copySimpleVirtualPlayerAppearance(dummyEntity, pg.me)
	else
		self.avatarScene:showEntityWithId(self.dummyEntityId)
		self.avatarScene:playIdleAnimation(dummyEntity)
	end

	local srcEntity = self.avatarScene:getCurEntity()

	for k, v in pairs(srcEntity.customShow) do
		dummyEntity.customShow[k] = v
	end

	self.avatarScene:previewCustomShow(self.dummyEntityId)

	local slotItem = self.view.outfitUList.selectedItem

	if slotItem and slotItem.slotId then
		self.avatarScene:previewCustomShow(self.entityId, slotItem.slotId)
	end

	if opType == self.model.OP_TYPE.SAVE_TO_OUTFIT then
		self.avatarScene:setEntityPos(self.entityId, LeftAvatarPos)
		self.avatarScene:setEntityPos(self.dummyEntityId, RightAvatarPos)
	elseif opType == self.model.OP_TYPE.USE_FROM_OUTFIT then
		self.avatarScene:setEntityPos(self.entityId, RightAvatarPos)
		self.avatarScene:setEntityPos(self.dummyEntityId, LeftAvatarPos)
	end

	self.avatarScene:setEntityRot(self.entityId, 0)
	self.avatarScene:setEntityRot(self.dummyEntityId, 0)
end

function AppearanceOutfitCtrl:onConfirmCustom(slotId)
	local entity = self.avatarScene:getEntity(self.entityId)

	if not entity then
		return
	end

	entity.previewOutfitId = nil

	local customData = pg.me.appearanceCustom[slotId].customShow

	for k, v in pairs(customData) do
		if k >= AppearancePointEnum.Fringe and k <= AppearancePointEnum.Plait then
			-- block empty
		elseif k >= AppearancePointEnum.Eyebrow and k <= AppearancePointEnum.Skin then
			-- block empty
		else
			entity.customShow[k] = v
		end
	end

	self.avatarScene:previewCustomShow(self.entityId)
end

function AppearanceOutfitCtrl:refreshBag(slotId)
	local isShowBag = pg.me.appearanceCustom[slotId].isShowBag
	local actions = {
		{
			partId = GameConst.PART_TOP,
			slotId = GameConst.SLOT_BAG,
			visible = isShowBag
		}
	}

	self.avatarScene:refreshPartRendererVisible(self.entityId, actions)
end

return AppearanceOutfitCtrl
