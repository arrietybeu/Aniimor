-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PhotoDownloadTemplate\\PhotoDownloadTemplateCtrl.lua

local Time = require("Core.Common.Time")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local PhotoDownloadTemplateCtrl = Class.LightClass("PhotoDownloadTemplateCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientSettingUtils = require("Utils.ClientSettingUtils")
local Utils = require("Common.Utils.Utils")
local UIConst = require("Const.UIConst")
local SocialMediaShareListComponent = require("Guis.Helper.SocialMediaShareListComponent")
local PhotographyStudioUtils = require("Utils.PhotographyStudioUtils")
local AppearanceVariableData = require("Data.appearance_variable_data")
local STUDIO_DEFAULT_COVER_URL = AppearanceVariableData.STUDIO_DEFAULT_IMAGE

function PhotoDownloadTemplateCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.templateInfo = info.templateInfo
	self.isPhotographyStudioShare = info.isPhotographyStudioShare or false
	self.codeStr = nil
end

function PhotoDownloadTemplateCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.btnCopyUButton.luaClick()
		UIUtils.ClipboardWriter(self.codeStr)
		pg.global.showBubbleMessageRaw(pg.getGameString("PHOTO_COPY_SUCCESS"))
	end

	local copy1ObjectReference = self.view.btnCopy1UButton:GetComponent("ObjectReference")
	local copy1NameUText = copy1ObjectReference:GetRefValue("txtNameUText")

	ClientTextUtils.setText(copy1NameUText, pg.getGameString("PHOTO_STUDIO_COPY_CODE"))

	function self.view.btnCopy1UButton.luaClick()
		UIUtils.ClipboardWriter(self.codeStr)
		pg.global.showBubbleMessageRaw(pg.getGameString("PHOTO_STUDIO_COPY_SUCCESS"))
	end

	function self.view.btnSaveUButton.luaClick()
		self:captureScreen()
	end

	local function requestImagePath(callback)
		self:getTemplateImagePath(callback)
	end

	self.shareListComponent = SocialMediaShareListComponent.new(self, self.view.listBtnUList, requestImagePath)
end

function PhotoDownloadTemplateCtrl:captureScreen()
	local imageSaved

	imageSaved = (not ClientSettingUtils.isCloudGame() or false) and pg.global.mobileCameraMgr:IsPresetImageExist(tostring(self.codeStr))

	if imageSaved then
		pg.global.showBubbleMessageRaw(pg.getGameString("SAVED_LOCAL"))

		return
	end

	local function onImageSaved(path)
		if ClientSettingUtils.isCloudGame() then
			if string.isNilOrEmpty(path) then
				pg.global.showBubbleMessage(NoticeDef.SAVE_PHOTOGRAPH_FAILED_DISC_FULL)

				return
			end

			pg.global.showBubbleMessageRaw(ClientSettingUtils.getPhotoSyncingToPhoneText(), 3)
		else
			local msg = string.format(pg.getGameString("AVATAR_SAVE"), path)

			pg.global.showBubbleMessageRaw(msg, 3)
		end
	end

	local function onTemplateCaptured(success)
		if not success then
			return
		end

		pg.global.mobileCameraMgr:SaveImageToAlbum(nil, onImageSaved)
	end

	self:captureTemplate(onTemplateCaptured)
end

function PhotoDownloadTemplateCtrl:captureTemplate(callback)
	local captureView = self.view
	local canvasSize = pg.global.uiMgr.uiRootCanvasRt.sizeDelta
	local localScale = captureView.widgetRectTransform.localScale
	local scaleX = captureView.widgetRectTransform.sizeDelta.x * localScale.x / canvasSize.x
	local scaleY = captureView.widgetRectTransform.sizeDelta.y * localScale.y / canvasSize.y
	local width = Screen.width * scaleX
	local height = Screen.height * scaleY
	local widgetScreenCenter = UIUtils.WorldToScreenPoint(captureView.widgetRectTransform.position)
	local position = Vector2.New(widgetScreenCenter.x - width * 0.5, widgetScreenCenter.y - height * 0.5)
	local captureWhiteList = {
		[UIConst.UI_ID_PHOTO_DOWNLOAD_TEMPLATE] = true
	}

	pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.TAKE_PHOTO, captureWhiteList, 5)

	captureView.bgURound.enabled = false

	local function onPhotoChecked(_, _, success)
		pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.TAKE_PHOTO)

		if self.view ~= captureView then
			return
		end

		captureView.bgURound.enabled = true

		callback(success == true)
	end

	Utils.captureAndCheckPhoto(Const.PhotoCheckScene.Share, onPhotoChecked, position, Vector2(width, height), 1, false)
end

function PhotoDownloadTemplateCtrl:getTemplateImagePath(callback)
	if not string.isNilOrEmpty(self.templateImagePath) then
		callback(self.templateImagePath)

		return
	end

	local function onTemplateCaptured(success)
		if not success then
			callback("")

			return
		end

		self.templateImagePath = pg.global.mobileCameraMgr:SaveCapturedImageToCache(self.templateShareKey)

		callback(self.templateImagePath)
	end

	self:captureTemplate(onTemplateCaptured)
end

function PhotoDownloadTemplateCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.templateShareKey = string.format("%.0f_%d", Time.getMillisecond(), Time.frameCount)
	self.templateImagePath = nil

	self:refreshUI()
	self.shareListComponent:refresh()
end

function PhotoDownloadTemplateCtrl:refreshUI()
	pg.global.navMgr:SetConsoleBarState("StudioMode", self.isPhotographyStudioShare)
	pg.global.navMgr:SetConsoleBarState("PhotoMode", not self.isPhotographyStudioShare)
	self.view.widget:TryChangePage("CopyBtn", self.isPhotographyStudioShare and 1 or 0)

	local preset = self.templateInfo.preset

	if self.isPhotographyStudioShare then
		ClientTextUtils.setText(self.view.textPosUBaseText, self.templateInfo.studioName or "")
	else
		local pos = preset.playerPos
		local sceneId = preset.sceneId
		local pointName = self.model:getPointNameByPos(sceneId, {
			pos.x,
			pos.y,
			pos.z
		})
		local posTxt = string.format("%s(%s,%s)", pointName, self.model:formatNumber(pos.x), self.model:formatNumber(pos.z))

		ClientTextUtils.setText(self.view.textPosUBaseText, posTxt)
	end

	if self.isPhotographyStudioShare then
		self.codeStr = PhotographyStudioUtils.getPhotographyStudioShareCode(self.templateInfo.id)

		self.view.textPhotoCodeUBaseText:SetActive(true)
		self.view.qRImgURawImage:SetActive(true)
		self.view.textUidUBaseText:SetActive(true)
		self.view.btnSaveUButton:SetActive(true)
		ClientTextUtils.setText(self.view.textPhotoCodeUBaseText, string.format(pg.getGameString("PHOTO_STUDIO_PRESET_CODE"), self.codeStr))
		ClientTextUtils.setText(self.view.textUidUBaseText, string.format(pg.getGameString("PHOTO_UID"), self.templateInfo.uid))

		local presetStr = Utils.encodeToStr(self.templateInfo.id) or ""

		pg.game.camera.photoCameraMode.cameraMode:SetQRCode(self.view.qRImgURawImage, presetStr)

		self.view.btnSaveUButton.interactable = not pg.global.mobileCameraMgr:IsPresetImageExist(tostring(self.codeStr))

		ClientTextUtils.setText(self.view.textNameUBaseText, self.templateInfo.title or "")
		self.view.textDescUBaseText:SetActive(false)
		ClientTextUtils.setText(self.view.textCreatorUBaseText, pg.me.playerName or "")
		self:refreshPhotographyStudioCover()

		return
	end

	local isOfficial, codeStr = Utils.parsePhotoPresetUniqueId(self.templateInfo.id)

	isOfficial = isOfficial and true or false
	self.codeStr = codeStr

	self.view.textPhotoCodeUBaseText:SetActive(not isOfficial)
	self.view.qRImgURawImage:SetActive(not isOfficial)
	self.view.textUidUBaseText:SetActive(not isOfficial)
	self.view.btnCopyUButton:SetActive(not isOfficial)
	self.view.btnSaveUButton:SetActive(not isOfficial)

	if not isOfficial then
		ClientTextUtils.setText(self.view.textPhotoCodeUBaseText, string.format(pg.getGameString("PHOTO_PRESET_CODE"), codeStr))
		ClientTextUtils.setText(self.view.textUidUBaseText, string.format(pg.getGameString("PHOTO_UID"), self.templateInfo.uid))

		local presetStr = Utils.encodeToStr(self.templateInfo.id) or ""

		pg.game.camera.photoCameraMode.cameraMode:SetQRCode(self.view.qRImgURawImage, presetStr)
		pg.global.ui.photo.model:queryPresetImg(self.templateInfo.imgKey, function(sprite, id)
			if id == self.templateInfo.id then
				self.view.photoUImage.sprite = sprite

				if sprite then
					self.view.adaptationBoxUXAdaptionRect.customResolution = Vector2(sprite.texture.width, sprite.texture.height)

					self.view.adaptationBoxUXAdaptionRect:UpdateAdaptation()
				end
			end
		end, self.templateInfo.id)

		self.view.btnSaveUButton.interactable = not pg.global.mobileCameraMgr:IsPresetImageExist(tostring(self.codeStr))
	else
		self.view.photoUImage.url = preset.icon
	end

	local title = isOfficial and pg.getLocalizationText(self.templateInfo.title) or self.templateInfo.title or ""
	local desc = isOfficial and pg.getLocalizationText(self.templateInfo.desc) or self.templateInfo.desc or ""
	local userName = isOfficial and pg.getLocalizationText(self.templateInfo.userName) or self.templateInfo.userName or ""

	ClientTextUtils.setText(self.view.textNameUBaseText, title)

	if string.isNilOrEmpty(desc) then
		self.view.textDescUBaseText:SetActive(false)
	else
		self.view.textDescUBaseText:SetActive(true)
		ClientTextUtils.setText(self.view.textDescUBaseText, desc)
	end

	ClientTextUtils.setText(self.view.textCreatorUBaseText, userName)
end

function PhotoDownloadTemplateCtrl:refreshPhotographyStudioCover()
	local studioUid = self.templateInfo.id
	local coverVersion = self.templateInfo.coverVersion

	self.view.photoUImage:SetUrlWithCallback(STUDIO_DEFAULT_COVER_URL, function()
		if not self.isDestroyed and self.templateInfo.id == studioUid and self.view.photoUImage.url == STUDIO_DEFAULT_COVER_URL then
			local texture = self.view.photoUImage.sprite.texture

			self.view.adaptationBoxUXAdaptionRect.customResolution = Vector2(texture.width, texture.height)

			self.view.adaptationBoxUXAdaptionRect:UpdateAdaptation()
		end
	end, nil, true)
	PhotographyStudioUtils.loadPhotographyStudioCover(studioUid, coverVersion, function(sprite, success)
		if self.isDestroyed or not success or self.templateInfo.id ~= studioUid then
			return
		end

		self.view.photoUImage.url = nil
		self.view.photoUImage.sprite = sprite

		local texture = sprite.texture

		self.view.adaptationBoxUXAdaptionRect.customResolution = Vector2(texture.width, texture.height)

		self.view.adaptationBoxUXAdaptionRect:UpdateAdaptation()
	end)
end

function PhotoDownloadTemplateCtrl:onDestroy()
	self.templateShareKey = nil
	self.templateImagePath = nil

	UICtrl.onDestroy(self)
end

function PhotoDownloadTemplateCtrl:checkUIShowVirtualMouseCursor()
	return false
end

return PhotoDownloadTemplateCtrl
