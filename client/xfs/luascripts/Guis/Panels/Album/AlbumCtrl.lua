-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Album\\AlbumCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("AlbumCtrl")
local MessageName = require("Const.MessageName")
local HotkeyConst = require("Const.HotkeyConst")
local PetTraitPhotoData = require("Data.pet_trait_photo_data")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local AlbumCtrl = Class.LightClass("AlbumCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local ChatPhotographCtrl = require("Guis.Panels.ChatPhotograph.ChatPhotographCtrl")
local ClientUtils = require("Utils.ClientUtils")
local Utils = require("Common.Utils.Utils")
local LOCAL_PHOTO_DELETE_TIMEOUT = 5
local AlbumMode = {
	ChatPicture = 2,
	Send = 1,
	Normal = 0,
	Investigation = 4,
	Delete = 3
}

AlbumCtrl.Mode = AlbumMode
AlbumCtrl.messages = {
	[MessageName.PHOTO_DELETE] = {
		"refreshAlbum",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function AlbumCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.needDestroySprite = {}
	self.ossPhotoSpriteMap = {}
	self.deleteSelectedPhotoIds = {}
	self.removedOSSPhotoKeys = {}
	self.deleteOperationToken = {}
end

function AlbumCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:dismiss()
	end

	function self.view.listUList.luaRenderItem(button, idx, data)
		self:renderAlbumList(button, idx, data)
	end

	function self.view.btnTopUButton.luaClick()
		self.view.listUList:GoToIndex(0)
	end

	function self.view.btnBottomUButton.luaClick()
		self.view.listUList:GotoEnd()
	end

	function self.view.btnUpdateUButton.luaClick()
		self:onBtnSubmitClick()
	end

	function self.view.btnOpenUButton.luaClick()
		LuaUIUtils.openPhotoFolder()
	end

	function self.view.btnBatchUButton.luaClick()
		if self:isDeleteMode() then
			self:toggleSelectAllDeletePhotos()
		elseif self.mode == AlbumMode.Normal then
			self:enterDeleteMode()
		end
	end

	function self.view.btnDeleteUButton.luaClick()
		self:confirmDeleteSelectedPhotos()
	end

	function self.view.btnExitSelectUButton.luaClick()
		self:exitDeleteMode()
	end

	function self.view.btnSettingUButton.luaClick()
		self:onSettingClick()
	end
end

function AlbumCtrl:onBtnSubmitClick()
	if self._lastSelButton then
		local data = self._lastSelButton[2]

		if self:isSelectMode() then
			self:submitPhoto(data)
		else
			self:dismiss()
		end
	end
end

function AlbumCtrl:submitPhoto(data)
	if not data or not self._investigateCb then
		self:dismiss()

		return
	end

	if not self:isPhotoSelectable(data) then
		return
	end

	local genderInfos = {}

	for tId, infos in pairs(data.templateGenders or EMPTY_TABLE) do
		genderInfos[tId] = genderInfos[tId] or {}

		local len = infos and infos.Count - 1 or 0
		local infosToAdd = genderInfos[tId]

		for i = 0, len do
			infosToAdd[#infosToAdd + 1] = infos[i]
		end
	end

	self._investigateCb(data.templateIds, self:getPhotoSubmitPath(data), data.timeStamp, data.position, data.sceneId, genderInfos, data)
	self:dismiss()
end

function AlbumCtrl:onDestroy()
	self.deleteOperationToken = {}
	self._lastSelButton = nil

	pg.global.mobileCameraMgr:ClearAlbumRes()

	for _, sprite in ipairs(self.needDestroySprite) do
		pg.global.mobileCameraMgr:DestroySpriteTexture(sprite)
	end

	self.needDestroySprite = {}
	self.ossPhotoSpriteMap = {}

	UICtrl.onDestroy(self)
end

function AlbumCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.deleteOperationToken = {}
	self._lastSelButton = nil
	self.deleteSelectedPhotoIds = {}
	self.removedOSSPhotoKeys = {}
	self.isDeletingPhoto = false
	self._investigateCb = info and info.investigateCb or nil
	self.mode = self:getOpenMode(info)
	self.selectedCount = info and info.selectedCount or 0
	self.maxSelectableCount = info and info.maxSelectableCount or 1

	local hasMode = info and info.mode ~= nil
	local investigation = info and info.investigation

	if hasMode or investigation == nil then
		investigation = self:isSelectMode()
	end

	local investigationPage = investigation and 1 or 0

	if self:isDeleteMode() then
		investigationPage = 2
	end

	self.view.rootViewComponent:TryChangePage("Investigation", investigationPage)
	self:refreshAlbum()
	self:refreshUpdateButtonText()
end

function AlbumCtrl:getOpenMode(info)
	if info and info.mode ~= nil then
		return info.mode
	end

	return self._investigateCb and AlbumMode.Send or AlbumMode.Normal
end

function AlbumCtrl:isSelectMode()
	return self.mode == AlbumMode.Send or self.mode == AlbumMode.ChatPicture or self.mode == AlbumMode.Investigation
end

function AlbumCtrl:isChatPictureMode()
	return self.mode == AlbumMode.ChatPicture
end

function AlbumCtrl:isInvestigationMode()
	return self.mode == AlbumMode.Investigation
end

function AlbumCtrl:isDeleteMode()
	return self.mode == AlbumMode.Delete
end

function AlbumCtrl:getPhotoSubmitPath(data)
	if not data then
		return nil
	end

	if not string.isNilOrEmpty(data.path) then
		return data.path
	end

	return data.localPhotoPath
end

function AlbumCtrl:isPhotoSelectable(data)
	if not data then
		return false
	end

	if self:isInvestigationMode() then
		return not Utils.tableIsEmptyOrNil(data.templateIds) and not string.isNilOrEmpty(self:getPhotoSubmitPath(data))
	end

	return self:isChatPictureMode() or not data.isOSS
end

function AlbumCtrl:refreshUpdateButtonText()
	if not self:isChatPictureMode() or not self.view.btnUpdateTxtNameUText then
		return
	end

	ClientTextUtils.setText(self.view.btnUpdateTxtNameUText, pg.getFormatText(pg.getGameString("CHAT_PHOTO_SEND"), self.selectedCount or 0, self.maxSelectableCount or 1))
end

function AlbumCtrl:enterDeleteMode()
	self.mode = AlbumMode.Delete
	self.deleteSelectedPhotoIds = {}

	self.view.rootViewComponent:TryChangePage("Investigation", 2)
	self.view.listUList:RefreshList()
	self:refreshCapacity()
	self:refreshDeleteModeButtons()
	pg.global.showBubbleMessageRaw(pg.getGameString("PHOTO_ALBUM_BATCH_MANAGING"))
end

function AlbumCtrl:exitDeleteMode()
	if not self:isDeleteMode() or self.isDeletingPhoto then
		return
	end

	self.mode = AlbumMode.Normal
	self.deleteSelectedPhotoIds = {}

	self.view.rootViewComponent:TryChangePage("Investigation", 0)
	self.view.listUList:RefreshList()
	self:refreshCapacity()
	self:refreshDeleteModeButtons()
end

function AlbumCtrl:onSettingClick()
	pg.global.ui:open(UIConst.UI_ID_SETTING, {
		selectedTabName = "storage"
	})
end

function AlbumCtrl:isPhotoDeletable(data)
	if not data then
		return false
	end

	if data.isOSS then
		return true
	end

	return not data.traitId and not data.isInRes and not string.isNilOrEmpty(data.path)
end

function AlbumCtrl:getDeletePhotoId(data)
	if not self:isPhotoDeletable(data) then
		return nil
	end

	if data.isOSS then
		return "oss:" .. tostring(data.ossPhotoKey)
	end

	return "local:" .. tostring(data.path)
end

function AlbumCtrl:getLocalPhotoPath(data)
	if not data then
		return nil
	end

	if data.isOSS then
		return data.localPhotoPath
	end

	if not data.traitId and not data.isInRes then
		return data.path
	end

	return nil
end

function AlbumCtrl:getDeleteSelectionStats()
	local selectedCount = 0
	local ossSelectedCount = 0
	local localSelectedCount = 0

	if not self.deletePhotoDataById then
		return selectedCount, ossSelectedCount, localSelectedCount
	end

	for photoId in pairs(self.deleteSelectedPhotoIds) do
		local data = self.deletePhotoDataById[photoId]

		if data then
			selectedCount = selectedCount + 1

			if data.isOSS then
				ossSelectedCount = ossSelectedCount + 1
			end

			if not string.isNilOrEmpty(self:getLocalPhotoPath(data)) then
				localSelectedCount = localSelectedCount + 1
			end
		end
	end

	return selectedCount, ossSelectedCount, localSelectedCount
end

function AlbumCtrl:getDeletePhotoCurrentStats()
	local ossPhotoCount = 0
	local localPhotoCount = 0

	if not self.deletePhotoDataById then
		return ossPhotoCount, localPhotoCount
	end

	for _, data in pairs(self.deletePhotoDataById) do
		if data.isOSS then
			ossPhotoCount = ossPhotoCount + 1
		end

		if not string.isNilOrEmpty(self:getLocalPhotoPath(data)) then
			localPhotoCount = localPhotoCount + 1
		end
	end

	return ossPhotoCount, localPhotoCount
end

function AlbumCtrl:getDeletablePhotoCount()
	local count = 0

	if not self.deletePhotoDataById then
		return count
	end

	for _ in pairs(self.deletePhotoDataById) do
		count = count + 1
	end

	return count
end

function AlbumCtrl:isAllDeletePhotosSelected()
	local deletablePhotoCount = self:getDeletablePhotoCount()

	return deletablePhotoCount > 0 and self:getDeleteSelectionStats() == deletablePhotoCount
end

function AlbumCtrl:refreshDeleteModeButtons()
	local textKey = "PHOTO_ALBUM_BATCH_MANAGE"

	if self:isDeleteMode() then
		textKey = self:isAllDeletePhotosSelected() and "PHOTO_ALBUM_CANCEL_SELECT_ALL" or "PHOTO_ALBUM_SELECT_ALL"
	end

	ClientTextUtils.setText(self.view.btnBatchUButton.title, pg.getGameString(textKey))

	self.view.btnBatchUButton.interactable = not self.isDeletingPhoto and (not self:isDeleteMode() or self:getDeletablePhotoCount() > 0)
	self.view.btnDeleteUButton.interactable = not self.isDeletingPhoto and self:getDeleteSelectionStats() > 0
	self.view.btnExitSelectUButton.interactable = not self.isDeletingPhoto
end

function AlbumCtrl:toggleDeletePhotoSelected(photoId)
	if self.deleteSelectedPhotoIds[photoId] then
		self.deleteSelectedPhotoIds[photoId] = nil
	else
		self.deleteSelectedPhotoIds[photoId] = true
	end

	self:refreshCapacity()
	self:refreshDeleteModeButtons()
	self.view.listUList:RefreshList()
end

function AlbumCtrl:toggleSelectAllDeletePhotos()
	if self.isDeletingPhoto then
		return
	end

	if self:isAllDeletePhotosSelected() then
		self.deleteSelectedPhotoIds = {}
	else
		for photoId in pairs(self.deletePhotoDataById) do
			self.deleteSelectedPhotoIds[photoId] = true
		end
	end

	self:refreshCapacity()
	self:refreshDeleteModeButtons()
	self.view.listUList:RefreshList()
end

function AlbumCtrl:confirmDeleteSelectedPhotos()
	local selectedCount = self:getDeleteSelectionStats()

	if self.isDeletingPhoto or selectedCount < 1 then
		return
	end

	local photoDatas = {}

	for photoId in pairs(self.deleteSelectedPhotoIds) do
		local data = self.deletePhotoDataById[photoId]

		if data then
			photoDatas[#photoDatas + 1] = data
		end
	end

	pg.global.showConfirmMsgRaw(pg.getGameString("DEL_PHOTO_TITLE"), string.format(pg.getGameString("PHOTO_ALBUM_BATCH_DELETE_DESC"), #photoDatas), function()
		self:deletePhotos(photoDatas)
	end, nil)
end

function AlbumCtrl:deletePhotos(photoDatas, callback)
	if #photoDatas < 1 then
		if callback then
			callback(false)
		end

		return
	end

	self.isDeletingPhoto = true
	self.deleteOperationToken = {}

	local operationToken = self.deleteOperationToken

	self:refreshDeleteModeButtons()

	local ossPhotoKeys = {}
	local localPhotoPaths = {}

	for _, data in ipairs(photoDatas) do
		local localPhotoPath = self:getLocalPhotoPath(data)

		if not string.isNilOrEmpty(localPhotoPath) then
			localPhotoPaths[#localPhotoPaths + 1] = localPhotoPath
		end

		if data.isOSS then
			ossPhotoKeys[#ossPhotoKeys + 1] = data.ossPhotoKey
		end
	end

	local localDeletePendingCount = #localPhotoPaths
	local localDeleteFailedCount = 0
	local localDeleteDone = localDeletePendingCount < 1
	local localDeleteTimedOut = false
	local localDeleteTimeoutTimer
	local ossDeleteDone = false
	local ossDeleteFailedCount = 0
	local operationFinished = false

	local function refreshAfterDelete()
		self:refreshAlbum()

		if self:isDeleteMode() and self:getDeletablePhotoCount() < 1 then
			self:exitDeleteMode()
		end
	end

	local function tryFinishDelete()
		if operationFinished or not localDeleteDone or not ossDeleteDone then
			return
		end

		operationFinished = true

		if localDeleteTimeoutTimer then
			self:killTimer(localDeleteTimeoutTimer)

			localDeleteTimeoutTimer = nil
		end

		if self.deleteOperationToken ~= operationToken then
			return
		end

		self.isDeletingPhoto = false

		if not self:checkUIOpen() then
			if callback then
				callback(false)
			end

			return
		end

		refreshAfterDelete()

		local isSuccess = localDeleteFailedCount + ossDeleteFailedCount < 1

		if not isSuccess then
			pg.global.showBubbleMessageRaw(pg.getGameString("PHOTO_ALBUM_BATCH_DELETE_FAILED"))
		end

		if callback then
			callback(isSuccess)
		end
	end

	local function onLocalPhotoDeleted()
		if self.deleteOperationToken ~= operationToken or localDeletePendingCount < 1 then
			return
		end

		localDeletePendingCount = localDeletePendingCount - 1

		if localDeleteTimedOut then
			localDeleteFailedCount = math.max(localDeleteFailedCount - 1, 0)

			if operationFinished and self:checkUIOpen() then
				refreshAfterDelete()
			end

			return
		end

		if localDeletePendingCount < 1 then
			localDeleteDone = true

			if localDeleteTimeoutTimer then
				self:killTimer(localDeleteTimeoutTimer)

				localDeleteTimeoutTimer = nil
			end

			tryFinishDelete()
		end
	end

	for _, localPhotoPath in ipairs(localPhotoPaths) do
		pg.global.mobileCameraMgr:DeletePhotoByPath(localPhotoPath, onLocalPhotoDeleted)
	end

	if not localDeleteDone then
		localDeleteTimeoutTimer = self:startTimer(function()
			if self.deleteOperationToken ~= operationToken then
				return
			end

			localDeleteTimeoutTimer = nil
			localDeleteTimedOut = true
			localDeleteFailedCount = localDeletePendingCount
			localDeleteDone = true

			tryFinishDelete()
		end, LOCAL_PHOTO_DELETE_TIMEOUT)
	end

	self:deleteOSSPhotos(ossPhotoKeys, operationToken, function(failedCount)
		if self.deleteOperationToken ~= operationToken then
			return
		end

		ossDeleteFailedCount = failedCount
		ossDeleteDone = true

		tryFinishDelete()
	end)
end

function AlbumCtrl:deleteOSSPhotos(photoKeys, operationToken, callback)
	local failedCount = 0

	local function deleteNext(index)
		if index > #photoKeys then
			callback(failedCount)

			return
		end

		local photoKey = photoKeys[index]

		if not pg.me then
			failedCount = failedCount + 1

			deleteNext(index + 1)

			return
		end

		pg.me:removeOSSPhoto(photoKey, function(success)
			if success then
				if self.deleteOperationToken == operationToken then
					self.deleteSelectedPhotoIds["oss:" .. tostring(photoKey)] = nil
					self.removedOSSPhotoKeys[photoKey] = true
					self.ossPhotoSpriteMap[photoKey] = nil
				end
			else
				failedCount = failedCount + 1
			end

			deleteNext(index + 1)
		end)
	end

	deleteNext(1)
end

function AlbumCtrl:refreshCapacity()
	local current = tonumber(pg.me and pg.me.curPhotoUploadCount) or 0
	local limit = tonumber(pg.me and pg.me.photoUploadLimit) or 0

	if self:isDeleteMode() then
		local _, ossSelectedCount, localSelectedCount = self:getDeleteSelectionStats()
		local ossPhotoCount, localPhotoCount = self:getDeletePhotoCurrentStats()
		local selectedText = string.format(pg.getGameString("PHOTO_ALBUM_DELETE_SELECTED"), ossSelectedCount, ossPhotoCount, localSelectedCount)

		ClientTextUtils.setText(self.view.textCapacityUBaseText, string.format("%s/%s", selectedText, localPhotoCount))

		return
	end

	local currentText = tostring(current)

	if limit > 0 and limit <= current then
		currentText = string.format("<style=Item_Lack>%s</style>", currentText)
	end

	local capacityText = string.format("<size=72>%s<size=60>/%s", currentText, limit)

	ClientTextUtils.setText(self.view.textCapacityUBaseText, string.format(pg.getGameString("PHOTO_ALBUM_CAPACITY"), capacityText))
end

function AlbumCtrl:refreshAlbum()
	CS.XGUI.LayoutMgr.ForceRebuildLayoutImmediate(self.view.listUList)

	local spriteDatas = self:getAlbumSprite()

	self.ossPhotoDataByKey = {}
	self.deletePhotoDataById = {}

	for _, photoInfo in ipairs(self.spriteInfos) do
		if photoInfo.isOSS then
			self.ossPhotoDataByKey[photoInfo.ossPhotoKey] = photoInfo
		end

		local photoId = self:getDeletePhotoId(photoInfo)

		if photoId then
			self.deletePhotoDataById[photoId] = photoInfo
		end
	end

	for photoId in pairs(self.deleteSelectedPhotoIds) do
		if not self.deletePhotoDataById[photoId] then
			self.deleteSelectedPhotoIds[photoId] = nil
		end
	end

	if #spriteDatas < 1 then
		self.view.rootViewComponent:TryChangePage("Empty", 1)
	else
		self.view.rootViewComponent:TryChangePage("Empty", 0)
	end

	ClientTextUtils.setText(self.view.emptyTextUText, pg.getGameString("PHOTO_ALBUM_IS_EMPTY"))
	self.view.listUList:SetList(spriteDatas)
	ClientTextUtils.setText(self.view.txtTipsUBaseText, pg.getGameString("PET_RESEARCH_PHOTO_TIP"))
	self.view.btnOpenUButton:SetActiveFastest(not pg.global.platform:isConsole())
	self:refreshCapacity()
	self:refreshDeleteModeButtons()
end

function AlbumCtrl:renderAlbumList(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")

	if data.tIndex == 1 then
		self:renderPhoto(button, data)
	elseif data.tIndex == 0 then
		local dateText = objectReference:GetRefValue("dateText")
		local countText = objectReference:GetRefValue("countText")

		ClientTextUtils.setText(dateText, pg.getLocalizationTimeYMD(data.startDate, true), "-", pg.getLocalizationTimeYMD(data.endDate, true))
		ClientTextUtils.setText(countText, data.count, pg.getGameString("PHOTO_ALBUM_PHOTO_NUM"))
	end
end

function AlbumCtrl:renderPhoto(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local photoUImage = objectReference:GetRefValue("photoUImage")
	local btnCheckUButton = objectReference:GetRefValue("btnCheckUButton")

	button.luaClick = nil

	button:RemoveLuaGamepadHotkey()

	btnCheckUButton.luaClick = nil

	if data.empty then
		button:TryChangePage("Empty", 0)

		button.interactable = false

		return
	end

	button:TryChangePage("Empty", 1)

	button.interactable = true
	photoUImage.url = nil
	photoUImage.sprite = nil

	if data.isOSS then
		button:TryChangePage("PhotoIcon", 2)

		if not string.isNilOrEmpty(data.localPhotoPath) then
			pg.global.mobileCameraMgr:SetTextureToUImage(data.localPhotoPath, photoUImage)
		else
			local cachedSprite = self.ossPhotoSpriteMap[data.ossPhotoKey]

			if cachedSprite then
				photoUImage.sprite = cachedSprite
				data.sprite = cachedSprite
			else
				pg.me:pullOSSPhoto(data.ossPhotoKey, function(sprite)
					if not sprite then
						if LoggerManager.checkLogger(LoggerConst.INFO) then
							logger:info("pull OSS photo failed, photoKey=%s", tostring(data.ossPhotoKey))
						end

						return
					end

					if not self:checkUIOpen() then
						pg.global.mobileCameraMgr:DestroySpriteTexture(sprite)

						return
					end

					self.ossPhotoSpriteMap[data.ossPhotoKey] = sprite
					self.needDestroySprite[#self.needDestroySprite + 1] = sprite
					data.sprite = sprite

					if self.view and self.view.listUList:GetData(button) == data then
						photoUImage.sprite = sprite
					end
				end)
			end
		end
	elseif data.traitId then
		button:TryChangePage("PhotoIcon", 1)
		pg.me:callPhotoGet(data.photoId, function(isOk, photoUrl)
			if isOk then
				ClientUtils.loadSpriteFromPhotoUrl(photoUrl, function(pic)
					if not pic then
						return
					end

					if not self:checkUIOpen() then
						pg.global.mobileCameraMgr:DestroySpriteTexture(pic)

						return
					end

					self.needDestroySprite[#self.needDestroySprite + 1] = pic
					data.sprite = pic

					if self.view.listUList:GetData(button) == data then
						photoUImage.sprite = pic
					end
				end)
			elseif LoggerManager.checkLogger(LoggerConst.INFO) then
				logger:info("get photo failed")
			end
		end)
	elseif data.isInRes then
		button:TryChangePage("PhotoIcon", 0)

		photoUImage.url = data.resId
	else
		button:TryChangePage("PhotoIcon", 0)
		pg.global.mobileCameraMgr:SetTextureToUImage(data.path, photoUImage)
	end

	if self:isDeleteMode() then
		local photoId = self:getDeletePhotoId(data)

		btnCheckUButton:SetActive(photoId ~= nil)

		if photoId then
			btnCheckUButton:TryChangePage("State", self.deleteSelectedPhotoIds[photoId] and 1 or 0)

			function btnCheckUButton.luaClick()
				self:toggleDeletePhotoSelected(photoId)
			end
		end
	elseif self:isSelectMode() then
		local canSelect = self:isPhotoSelectable(data)

		btnCheckUButton:SetActive(canSelect)

		if canSelect then
			if not self._lastSelButton then
				btnCheckUButton:TryChangePage("State", 0)
			elseif self._lastSelButton[2] == data then
				btnCheckUButton:TryChangePage("State", 1)
			else
				btnCheckUButton:TryChangePage("State", 2)
			end

			function btnCheckUButton.luaClick()
				if self._lastSelButton and self._lastSelButton[2] == data then
					self._lastSelButton = nil
					self.selectedCount = 0
				else
					self._lastSelButton = {
						btnCheckUButton,
						data
					}
					self.selectedCount = 1
				end

				self:refreshUpdateButtonText()
				self.view.listUList:RefreshList()
			end
		end
	else
		btnCheckUButton:SetActive(false)
	end

	local function openPhotoPreview()
		if self:isChatPictureMode() then
			local checkSelected = self._lastSelButton and self._lastSelButton[2] == data

			pg.global.ui:open(UIConst.UI_ID_CHAT_PHOTOGRAPH, {
				mode = ChatPhotographCtrl.Mode.Send,
				photoInfo = data,
				spriteInfos = self.spriteInfos,
				playerName = pg.me.playerName,
				checkSelected = checkSelected,
				selectedCount = self.selectedCount or 0,
				maxSelectableCount = self.maxSelectableCount,
				isPhotoSelectable = function(photoInfo)
					return self:isPhotoSelectable(photoInfo)
				end,
				isPhotoSelected = function(photoInfo)
					return self._lastSelButton and self._lastSelButton[2] == photoInfo
				end,
				checkCallback = function(photoInfo, isSelected)
					if not self:isPhotoSelectable(photoInfo) then
						return self.selectedCount
					end

					if isSelected then
						self._lastSelButton = {
							btnCheckUButton,
							photoInfo
						}
						self.selectedCount = 1
					else
						self._lastSelButton = nil
						self.selectedCount = 0
					end

					self:refreshUpdateButtonText()
					self.view.listUList:RefreshList()

					return self.selectedCount
				end,
				sendCallback = function(photoInfo)
					self:submitPhoto(photoInfo)
				end
			})
		else
			pg.global.ui.albumPhoto:open({
				photoInfo = data,
				spriteInfos = self.spriteInfos
			})
		end

		return false
	end

	button.luaClick = openPhotoPreview

	self:bindChatPictureGamepadEvents(button, btnCheckUButton.luaClick, openPhotoPreview)
end

function AlbumCtrl:bindChatPictureGamepadEvents(button, selectPhoto, openPhotoPreview)
	if not self:isChatPictureMode() or not pg.game.input:isUsingGamepad() then
		return
	end

	button.luaClick = selectPhoto

	button:SetGamepadAction(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonWest, nil, openPhotoPreview)
	button:SetHotkeyActiveOnlyInCurrentItem(true)
	button:SetHotkeyConsoleBar("CONSOLE_BAR_VIEW", 0)
end

function AlbumCtrl:onInputDeviceChanged()
	if not self:isChatPictureMode() then
		return
	end

	self.view.listUList:RefreshList()
	self:focusFirstAlbumItem()
end

function AlbumCtrl:getAlbumSprite()
	local spriteInfos = pg.global.mobileCameraMgr:GetImageFromAlbum()
	local ossSpritesInfo, ossPhotoByLocalPhotoId = self:getOSSPhotoSprites()
	local serverSpritesInfo = self:getServerSprites()
	local weekGroup = {}
	local displayCount = math.max(self.view.listUList:CalculateCrossAxisFillCountByTIndex(1), 1)
	local len = spriteInfos.Length

	for i = 0, len - 1 do
		local spriteInfo = spriteInfos[i]
		local ts = spriteInfo.ts
		local ossInfo = ossPhotoByLocalPhotoId[tostring(ts)]

		if ossInfo then
			ossInfo.localPhotoPath = spriteInfo.path
			ossInfo.timeStamp = ts
			ossInfo.position = spriteInfo.pos
			ossInfo.sceneId = spriteInfo.sceneId
			ossInfo.templateIds = {}
			ossInfo.templateGenders = spriteInfo.templateGenders

			for j = 0, spriteInfo.templateIds.Count - 1 do
				ossInfo.templateIds[#ossInfo.templateIds + 1] = spriteInfo.templateIds[j]
			end

			ossInfo.weekIdx, ossInfo.startDate, ossInfo.endDate = self:getWeeklyByTs(ts)
		else
			local item = {}

			item.isInRes = spriteInfo.isInRes

			if item.isInRes then
				item.resId = spriteInfo.path
			end

			item.timeStamp = ts
			item.position = spriteInfo.pos
			item.path = spriteInfo.path
			item.sceneId = spriteInfo.sceneId
			item.templateIds = {}
			item.templateGenders = spriteInfo.templateGenders
			item.tIndex = 1

			for j = 0, spriteInfo.templateIds.Count - 1 do
				local templateId = spriteInfo.templateIds[j]

				table.insert(item.templateIds, templateId)
			end

			local weekIdx, startDate, endDate = self:getWeeklyByTs(ts)
			local weekInfo = weekGroup[weekIdx]

			if not weekInfo then
				weekInfo = {
					startDate = startDate,
					endDate = endDate,
					sprites = {}
				}
				weekGroup[weekIdx] = weekInfo
			end

			weekInfo.sprites[#weekInfo.sprites + 1] = item
		end
	end

	for _, serverInfo in pairs(serverSpritesInfo) do
		local weekInfo = weekGroup[serverInfo.weekIdx]

		if not weekInfo then
			weekInfo = {
				startDate = serverInfo.startDate,
				endDate = serverInfo.endDate,
				sprites = {}
			}
			weekGroup[serverInfo.weekIdx] = weekInfo
		end

		weekInfo.sprites[#weekInfo.sprites + 1] = serverInfo
	end

	for _, ossInfo in pairs(ossSpritesInfo) do
		local weekInfo = weekGroup[ossInfo.weekIdx]

		if not weekInfo then
			weekInfo = {
				startDate = ossInfo.startDate,
				endDate = ossInfo.endDate,
				sprites = {}
			}
			weekGroup[ossInfo.weekIdx] = weekInfo
		end

		weekInfo.sprites[#weekInfo.sprites + 1] = ossInfo
	end

	local ret = {}

	self.spriteInfos = {}

	local weekInfos = {}

	for _, weekInfo in pairs(weekGroup) do
		weekInfos[#weekInfos + 1] = weekInfo
	end

	table.sort(weekInfos, function(a, b)
		return a.startDate > b.startDate
	end)

	for _, weekInfo in pairs(weekInfos) do
		ret[#ret + 1] = {
			tIndex = 0,
			startDate = weekInfo.startDate,
			endDate = weekInfo.endDate,
			count = #weekInfo.sprites
		}

		local sprites = weekInfo.sprites

		table.sort(sprites, function(a, b)
			return a.timeStamp > b.timeStamp
		end)

		for _, spriteInfo in pairs(sprites) do
			ret[#ret + 1] = spriteInfo
			self.spriteInfos[#self.spriteInfos + 1] = spriteInfo
		end

		local count = #sprites
		local mult = math.fmod(count, displayCount)

		if mult > 0 then
			for i = mult + 1, displayCount do
				ret[#ret + 1] = {
					empty = true,
					tIndex = 1
				}
			end
		end
	end

	return ret
end

function AlbumCtrl:getOSSPhotoSprites()
	local ret = {}
	local ossPhotoByLocalPhotoId = {}
	local photoRecordMap = pg.me and pg.me.ossPhotoRecordMap

	if not photoRecordMap then
		return ret, ossPhotoByLocalPhotoId
	end

	for photoKey, recordInfo in pairs(photoRecordMap) do
		if not self.removedOSSPhotoKeys[photoKey] then
			local localPhotoId = recordInfo.photoId
			local item = {}

			item.isOSS = true
			item.ossPhotoKey = photoKey
			item.localPhotoId = localPhotoId
			item.timeStamp = recordInfo.uploadTime
			item.position = {
				recordInfo.uploadPos[1],
				recordInfo.uploadPos[2],
				recordInfo.uploadPos[3]
			}
			item.sceneId = recordInfo.uploadScene
			item.templateIds = {}

			local weekIdx, startDate, endDate = self:getWeeklyByTs(recordInfo.uploadTime)

			item.weekIdx = weekIdx
			item.startDate = startDate
			item.endDate = endDate
			item.tIndex = 1
			ret[#ret + 1] = item

			if not string.isNilOrEmpty(localPhotoId) then
				ossPhotoByLocalPhotoId[localPhotoId] = item
			end
		end
	end

	return ret, ossPhotoByLocalPhotoId
end

function AlbumCtrl:getServerSprites()
	local ret = {}
	local photoRecordMap = pg.me.photoRecordMap

	for templateId, infos in pairs(PetTraitPhotoData) do
		for traitId, identifyId in pairs(infos) do
			local recordInfo = photoRecordMap[identifyId]

			if recordInfo then
				local item = {}

				item.timeStamp = recordInfo.uploadTime
				item.position = recordInfo.uploadPos
				item.sceneId = recordInfo.uploadScene
				item.photoId = recordInfo.photoId
				item.traitId = traitId
				item.templateId = templateId

				local weekIdx, startDate, endDate = self:getWeeklyByTs(recordInfo.uploadTime)

				item.weekIdx = weekIdx
				item.startDate = startDate
				item.endDate = endDate
				item.tIndex = 1
				ret[#ret + 1] = item
			end
		end
	end

	return ret
end

function AlbumCtrl:getWeeklyByTs(ts)
	local date = os.date("*t", ts)
	local weekIdx = os.date("%U", ts)
	local dayOfYear = date.yday
	local weekStartDay = dayOfYear - date.wday + 1
	local weekEndDay = weekStartDay + 6
	local weekStart = os.time({
		day = 1,
		month = 1,
		year = date.year
	}) + (weekStartDay - 1) * 24 * 60 * 60
	local weekEnd = os.time({
		day = 1,
		month = 1,
		year = date.year
	}) + (weekEndDay - 1) * 24 * 60 * 60

	return weekIdx, weekStart, weekEnd
end

function AlbumCtrl:getSpriteInfo(sprite)
	return {}
end

function AlbumCtrl:onShow()
	UICtrl.onShow(self)
	self:focusFirstAlbumItem()
end

function AlbumCtrl:focusFirstAlbumItem()
	if not pg.game.input:isUsingGamepad() or not pg.global.navMgr then
		return
	end

	local buttons = self.view.listUList:GetAllButtons()

	for i = 0, buttons.Length - 1 do
		local button = buttons[i]
		local data = self.view.listUList:GetData(button)

		if data and data.tIndex == 1 and not data.empty then
			pg.global.navMgr:FocusItem(button)

			return
		end
	end
end

function AlbumCtrl:onHide()
	return
end

return AlbumCtrl
