-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AlbumPhoto\\AlbumPhotoCtrl.lua

local MessageName = require("Const.MessageName")
local HotkeyConst = require("Const.HotkeyConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local AbilityParamData = require("Data.ability_param_data")
local PetFeatureData = require("Data.pet_character_data")
local SocialMediaShareListComponent = require("Guis.Helper.SocialMediaShareListComponent")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local MapBlockConfigData = require("Data.map_block_config_data")
local PetTraitData = require("Data.pet_trait_data")
local Time = require("Core.Common.Time")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local AlbumPhotoCtrl = Class.LightClass("AlbumPhotoCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local CommonSwitch = require("Common.CommonSwitch")
local ConflictTypes = require("Common.ConflictTypes")
local ClientUtils = require("Utils.ClientUtils")
local traitType_2_page_idx = {
	3,
	3,
	2
}

AlbumPhotoCtrl.messages = {
	[MessageName.CHAT_MESSAGE_UPDATE_ITEM] = {
		"onChatMessageUpdateItem",
		true
	}
}

function AlbumPhotoCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.needDestroySprite = {}
end

function AlbumPhotoCtrl:addListener()
	function self.view.btnScaleUButton.luaClick()
		self:dismiss()
	end

	function self.view.btnHideUIUButton.luaClick()
		local _, page = self.view.rootComponent:TryGetCurrentPage("hideLabel")

		self.view.rootComponent:TryChangePage("hideLabel", page == 0 and 1 or 0)
	end

	function self.view.levelUList.luaRenderItem(button, idx, data)
		button:TryChangePage("Have", data.reachedIdx)
	end

	function self.view.btnFolderUButton.luaClick()
		LuaUIUtils.openPhotoFolder()
	end

	function self.view.btnDeleteUButton.luaClick()
		if self.photoInfo.traitId then
			pg.global.showBubbleMessageRaw(pg.getGameString("DEL_PHOTO_FORBIDDEN"))
		elseif self.photoInfo.isOSS then
			pg.global.showConfirmMsgRaw(pg.getGameString("DEL_PHOTO_TITLE"), pg.getGameString("DEL_PHOTO_DESC"), function()
				local albumCtrl = pg.global.ui.album

				if not albumCtrl then
					return
				end

				albumCtrl:deletePhotos({
					self.photoInfo
				}, function(isSuccess)
					if not isSuccess or not self:checkUIOpen() then
						return
					end

					self.spriteInfos[self.photoIdx].isDeleted = true

					self:showNextPhoto(1)
				end)
			end, nil)
		else
			pg.global.showConfirmMsgRaw(pg.getGameString("DEL_PHOTO_TITLE"), pg.getGameString("DEL_PHOTO_DESC"), function()
				pg.global.mobileCameraMgr:DeletePhotoByPath(self.photoInfo.path)

				self.spriteInfos[self.photoIdx].isDeleted = true

				self:showNextPhoto(1)
				facade:sendMsgToUI(MessageName.PHOTO_DELETE)
			end, nil)
		end
	end

	function self.view.btnPreUButton.luaClick()
		self:showNextPhoto(-1)
	end

	function self.view.btnNextUButton.luaClick()
		self:showNextPhoto(1)
	end

	function self.view.btnTemplateUButton.luaClick()
		local templateInfo = {}

		templateInfo.preset = self.photoInfo.preset
		templateInfo.time = self.photoInfo.timeStamp
		templateInfo.userName = pg.me.playerName
		templateInfo.uid = pg.me.uid

		pg.global.ui:open(UIConst.UI_ID_PHOTO_SAVE_TEMPLATE, {
			templateInfo = templateInfo,
			sprite = self.view.photoUImage.sprite,
			successCallback = function()
				self.view.btnTemplateUButton.interactable = false
			end
		})
	end

	function self.view.btnRoadUButton.luaClick()
		if not CommonSwitch.MARK_SHARE then
			return
		end

		local forbiddenMark, tip = LuaUIUtils.checkFuncIdForbidden(10)

		if forbiddenMark then
			if tip then
				pg.global.showBubbleMessageRaw(tip)
			end

			return
		end

		pg.global.ui:close(UIConst.UI_ID_PHOTO)

		local templateInfo = {}

		templateInfo.preset = self.photoInfo.preset
		templateInfo.time = self.photoInfo.timeStamp
		templateInfo.imgKey = self.photoInfo.imgKey
		templateInfo.userName = pg.me.playerName
		templateInfo.uid = pg.me.uid

		pg.global.ui:open(UIConst.UI_ID_MARK_SHARE_EDIT, {
			photoTemplate = templateInfo,
			photoSprite = self.view.photoUImage.sprite
		}, function()
			return
		end)
		self:dismiss()
	end

	function self.view.btnSaveUButton.luaClick()
		if self.photoInfo and self.photoInfo.usePhotoCallback then
			self.photoInfo.usePhotoCallback(self.photoInfo.sprite, self.photoInfo.imgKey)
			self:dismiss()

			if pg.global.ui.photo then
				pg.global.ui.photo:closePanel()
			end

			return
		end

		if self.photoInfo and self.photoInfo.saveCallback then
			self.photoInfo.saveCallback()
		end

		if pg.global.ui.photo and pg.global.ui.photo.photoComponent then
			pg.global.ui.photo.photoComponent:savePhoto()
		end
	end

	function self.view.btnFavoriteUButton.luaClick()
		if self.photoInfo and self.photoInfo.chatLikeInfo then
			local chatLikeInfo = self.photoInfo.chatLikeInfo

			if chatLikeInfo.likedByMe == true then
				return
			end

			pg.me:likeChatMessage(chatLikeInfo)

			return
		end

		local id = self.photoInfo.presetId
		local isLiked = pg.global.ui.photo.model:isLikedTemplate(id)

		pg.global.ui.photo.model:likeTemplate(id, not isLiked, function()
			local isLiked = pg.global.ui.photo.model:isLikedTemplate(id)
			local tipStr = isLiked and "PHOTO_TEMPLATE_LIKED" or "PHOTO_TEMPLATE_UNLIKED"

			pg.global.showBubbleMessageRaw(pg.getFormatText(pg.getGameString(tipStr), self.photoInfo.title))
			self.view.btnFavoriteUButton:TryChangePage("enable", isLiked and 1 or 0)
		end)
	end

	local function requestImagePath(callback)
		self:requestShareImagePath(callback)
	end

	self.shareListComponent = SocialMediaShareListComponent.new(self, self.view.listBtnUList, requestImagePath)
end

function AlbumPhotoCtrl:requestShareImagePath(callback)
	local photoInfo = self.photoInfo
	local imagePath = self:getShareImagePath()

	if not string.isNilOrEmpty(imagePath) then
		callback(imagePath)

		return
	end

	if not photoInfo.isOSS and not photoInfo.isInRes then
		callback(imagePath)

		return
	end

	local sprite = photoInfo.isInRes and self.view.photoUImage.sprite or photoInfo.sprite or self.photoIdPic[photoInfo.ossPhotoKey]

	if not sprite then
		callback("")

		return
	end

	local fileKey

	if photoInfo.isInRes then
		fileKey = string.gsub(photoInfo.resId, "[^%w_-]", "_")
		fileKey = string.sub(fileKey, 4, -4)
		fileKey = string.sub(fileKey, 1, 64)
	else
		fileKey = string.format("album_%s_%s", pg.me.uid, photoInfo.localPhotoId)
	end

	if photoInfo.isInRes then
		local texture = sprite.texture

		sprite = pg.global.mobileCameraMgr:GetSpriteCover(sprite, texture.width, texture.height)
	end

	imagePath = pg.global.mobileCameraMgr:SaveSpriteToShareCache(sprite, fileKey)

	if photoInfo.isInRes then
		pg.global.mobileCameraMgr:DestroySpriteTexture(sprite)
	end

	callback(imagePath)
end

function AlbumPhotoCtrl:getShareImagePath()
	if not string.isNilOrEmpty(self.photoInfo.localPhotoPath) then
		return self.photoInfo.localPhotoPath
	end

	if self.photoInfo.isOSS then
		return ""
	end

	if self.photoInfo.isInRes then
		return ""
	end

	if string.isNilOrEmpty(self.albumPhotoImagePath) then
		self.albumPhotoImagePath = pg.global.mobileCameraMgr:SaveCapturedImageToCache(self.albumPhotoShareKey)
	end

	return self.albumPhotoImagePath
end

function AlbumPhotoCtrl:onDestroy()
	UICtrl.onDestroy(self)

	for _, pic in pairs(self.needDestroySprite) do
		pg.global.mobileCameraMgr:DestroySpriteTexture(pic)
	end

	self.albumPhotoShareKey = nil
	self.albumPhotoImagePath = nil
end

function AlbumPhotoCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.albumPhotoShareKey = string.format("album_%.0f_%d", Time.getMillisecond(), Time.frameCount)
	self.albumPhotoImagePath = nil
	self.photoIdPic = {}

	if info.spriteInfos then
		self.spriteInfos = info.spriteInfos
	else
		self.spriteInfos = self:getSpriteInfos() or {}
	end

	self:showPhotoDetail(info.photoInfo)
	self:initCurPhotoIdx()
	self:refreshPageBtn()
	self.shareListComponent:refresh()
end

function AlbumPhotoCtrl:onChatMessageUpdateItem(info)
	if not info or not self.photoInfo or not self.photoInfo.chatLikeInfo then
		return
	end

	local chatLikeInfo = self.photoInfo.chatLikeInfo

	if chatLikeInfo.SourceMsgId ~= info.msgId then
		return
	end

	local messageData = pg.game.chat:getMessageInfo(info.channelId, info.msgId)

	if not messageData then
		return
	end

	chatLikeInfo.likeCount = messageData.likeCount
	chatLikeInfo.likedByMe = messageData.likedByMe == true

	self.view.btnFavoriteUButton:TryChangePage("enable", chatLikeInfo.likedByMe and 1 or 0)
end

function AlbumPhotoCtrl:getSpriteInfos()
	local ret = {}
	local spriteInfos = pg.global.mobileCameraMgr:GetImageFromAlbum()
	local len = spriteInfos.Length

	for i = 0, len - 1 do
		local item = {}
		local spriteInfo = spriteInfos[i]

		item.isInRes = spriteInfo.isInRes

		if item.isInRes then
			item.resId = spriteInfo.path
		end

		local ts = spriteInfo.ts

		item.timeStamp = ts
		item.position = spriteInfo.pos
		item.path = spriteInfo.path
		item.sceneId = spriteInfo.sceneId
		ret[#ret + 1] = item
	end

	table.sort(ret, function(a, b)
		return a.timeStamp > b.timeStamp
	end)

	return ret
end

function AlbumPhotoCtrl:showNextPhoto(step)
	local index = self:getNextPhotoIndex(step)

	if not index then
		self:dismiss()

		return
	end

	self:showPhotoDetail(self.spriteInfos[index])

	self.photoIdx = index

	self:refreshPageBtn()
end

function AlbumPhotoCtrl:getNextPhotoIndex(step)
	local index

	if step > 0 then
		for idx = self.photoIdx + 1, #self.spriteInfos do
			if self.spriteInfos[idx] and not self.spriteInfos[idx].isDeleted then
				index = idx

				break
			end
		end

		if not index then
			for idx = self.photoIdx - 1, 1, -1 do
				if self.spriteInfos[idx] and not self.spriteInfos[idx].isDeleted then
					index = idx

					break
				end
			end
		end
	else
		for idx = self.photoIdx - 1, 1, -1 do
			if self.spriteInfos[idx] and not self.spriteInfos[idx].isDeleted then
				index = idx

				break
			end
		end

		if not index then
			for idx = self.photoIdx + 1, #self.spriteInfos do
				if self.spriteInfos[idx] and not self.spriteInfos[idx].isDeleted then
					index = idx

					break
				end
			end
		end
	end

	return index
end

function AlbumPhotoCtrl:refreshPageBtn()
	if self.photoIdx then
		self.view.btnPreUButton:SetActive(self.photoIdx > 1)
		self.view.btnNextUButton:SetActive(self.photoIdx < #self.spriteInfos)
	else
		self.view.btnPreUButton:SetActive(false)
		self.view.btnNextUButton:SetActive(false)
	end

	if self.photoInfo.preset or self.photoInfo.needSave or self.photoInfo.isPresetDetail or self.photoInfo.onlyShow then
		self.view.btnPreUButton:SetActive(false)
		self.view.btnNextUButton:SetActive(false)
	end
end

function AlbumPhotoCtrl:initCurPhotoIdx()
	for idx, photoInfo in pairs(self.spriteInfos) do
		if self:isSamePhoto(photoInfo, self.photoInfo) then
			self.photoIdx = idx

			break
		end
	end
end

function AlbumPhotoCtrl:isSamePhoto(leftPhotoInfo, rightPhotoInfo)
	if not leftPhotoInfo or not rightPhotoInfo then
		return false
	end

	if leftPhotoInfo.isOSS and rightPhotoInfo.isOSS then
		return leftPhotoInfo.ossPhotoKey == rightPhotoInfo.ossPhotoKey
	end

	if leftPhotoInfo.path and rightPhotoInfo.path then
		return leftPhotoInfo.path == rightPhotoInfo.path
	end

	if leftPhotoInfo.photoId and rightPhotoInfo.photoId then
		return leftPhotoInfo.photoId == rightPhotoInfo.photoId
	end

	return leftPhotoInfo == rightPhotoInfo
end

function AlbumPhotoCtrl:showPhotoDetail(photoInfo)
	self.photoInfo = photoInfo
	self.view.photoUImage.url = nil
	self.view.photoUImage.sprite = nil

	if self.photoInfo.isInRes then
		self.view.photoUImage.url = photoInfo.resId
	elseif photoInfo.isOSS then
		if not string.isNilOrEmpty(photoInfo.localPhotoPath) then
			pg.global.mobileCameraMgr:SetTextureToUImage(photoInfo.localPhotoPath, self.view.photoUImage, function(texture)
				if self.photoInfo == photoInfo then
					self:updateAdaptation(texture)
				end
			end)
		else
			local cachedSprite = photoInfo.sprite or self.photoIdPic[photoInfo.ossPhotoKey]

			if cachedSprite then
				self.view.photoUImage.sprite = cachedSprite

				self:updateAdaptation(cachedSprite.texture)
			else
				pg.me:pullOSSPhoto(photoInfo.ossPhotoKey, function(sprite)
					if not sprite then
						return
					end

					if not self:checkUIOpen() then
						pg.global.mobileCameraMgr:DestroySpriteTexture(sprite)

						return
					end

					self.needDestroySprite[#self.needDestroySprite + 1] = sprite
					self.photoIdPic[photoInfo.ossPhotoKey] = sprite

					if self.photoInfo == photoInfo then
						self.view.photoUImage.sprite = sprite

						self:updateAdaptation(sprite.texture)
					end
				end)
			end
		end
	elseif photoInfo.photoId then
		if self.photoIdPic[photoInfo.photoId] then
			self.view.photoUImage.sprite = self.photoIdPic[photoInfo.photoId]
		else
			pg.me:callPhotoGet(photoInfo.photoId, function(isOk, photoUrl)
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
						self.photoIdPic[photoInfo.photoId] = pic

						if self.photoInfo == photoInfo then
							self.view.photoUImage.sprite = pic

							self:updateAdaptation(pic.texture)
						end
					end)
				end
			end)
		end
	elseif photoInfo.needSave then
		self.view.photoUImage.sprite = photoInfo.sprite
	elseif photoInfo.isPresetDetail or photoInfo.onlyShow then
		if photoInfo.sprite then
			self.view.photoUImage.sprite = photoInfo.sprite
		elseif photoInfo.imgKey then
			pg.global.ui.photo.model:queryPresetImg(photoInfo.imgKey, function(sprite)
				if not sprite then
					return
				end

				self.needDestroySprite[#self.needDestroySprite + 1] = sprite
				self.view.photoUImage.sprite = sprite

				self:updateAdaptation(sprite.texture)
			end)
		else
			self.view.photoUImage.url = photoInfo.url
		end
	else
		self.view.photoUImage.url = nil

		pg.global.mobileCameraMgr:SetTextureToUImage(photoInfo.path, self.view.photoUImage, function(texture)
			self:updateAdaptation(texture)
		end)
	end

	if photoInfo.sprite then
		self:updateAdaptation(photoInfo.sprite.texture)
	end

	local locationName = photoInfo.locationName

	if locationName == nil then
		locationName = self:getPointNameByPos(photoInfo.sceneId, photoInfo.position)
	end

	ClientTextUtils.setText(self.view.textUText, locationName)
	ClientTextUtils.setText(self.view.timeUText, pg.getLocalizationTimeYMD(photoInfo.timeStamp))

	local traitId = photoInfo.traitId

	self.view.rootComponent:TryChangePage("hideBtn", traitId and 0 or 1)
	self.view.rootComponent:TryChangePage("hideLabel", traitId and 0 or 1)

	local templateId = photoInfo.templateId

	if traitId then
		local traitInfo = PetTraitData[templateId] and PetTraitData[templateId][traitId]

		if traitInfo then
			ClientTextUtils.setText(self.view.titleUText, pg.getLocalizationText(traitInfo.traitsName))
			ClientTextUtils.setText(self.view.detailUText, pg.getLocalizationText(traitInfo.traitsDesc))

			self.view.traitItemIcon.url = traitInfo.traitsImg

			local traitsContentType = traitInfo.traitsContentType

			if not traitsContentType then
				self.view.rootComponent:TryChangePage("Type", 0)
			else
				self.view.rootComponent:TryChangePage("Type", traitType_2_page_idx[traitsContentType])
				self.view.skillIconWidgetUWidget:SetActive(true)

				if traitsContentType == 1 then
					local skillId = traitInfo.traitsContentParam[1]
					local skillInfo = AbilityParamData[skillId]

					self.view.skillIcon.url = LuaUIUtils.getSkillIcon(skillInfo.icon)
				elseif traitsContentType == 2 then
					local featureId = traitInfo.traitsContentParam[1]
					local featureInfo = PetFeatureData[featureId]

					self.view.skillIcon.url = featureInfo.icon
				elseif traitsContentType == 3 then
					local param = traitInfo.traitsContentParam
					local exploreId = param[1]
					local level = param[2]
					local exploreInfo = PetResearchUtils.getPetExploreSkillData(exploreId, level)
					local maxLevel = param[3] or 3
					local levelData = {}

					for idx = 1, maxLevel do
						local data = {}

						data.reachedIdx = idx <= level and 1 or 0
						levelData[#levelData + 1] = data
					end

					self.view.levelUList:SetList(levelData)

					self.view.exploreIconUImage.url = exploreInfo.icon

					self.view.exploreBtnUComponent:TryChangePage("quality", maxLevel)
				end
			end
		end
	end

	local needSave = photoInfo.needSave == true
	local onlySave = photoInfo.onlySave == true
	local havePreset = photoInfo.preset ~= nil
	local isPresetDetail = photoInfo.isPresetDetail == true
	local isChatPicture = photoInfo.chatLikeInfo ~= nil
	local isSaved = isPresetDetail and pg.global.ui.photo.model:isSavedTemplate(photoInfo.presetId)
	local showFavorite = isChatPicture or isPresetDetail and not isSaved
	local showTemplateButton = havePreset and not isPresetDetail and not isChatPicture
	local showRoadButton = showTemplateButton and CommonSwitch.MARK_SHARE
	local showFolderButton = not needSave and not isPresetDetail and not isChatPicture and not self.photoInfo.isOSS and not pg.global.platform:isConsole()
	local showDeleteButton = not needSave and not isPresetDetail and not isChatPicture and not self.photoInfo.isInRes

	self.view.btnTemplateUButton:SetActive(showTemplateButton)
	self.view.btnRoadUButton:SetActive(showRoadButton)
	self.view.btnSaveUButton:SetActive(needSave and not isChatPicture)
	self.view.btnFolderUButton:SetActive(showFolderButton)
	self.view.btnDeleteUButton:SetActive(showDeleteButton)
	self.view.btnFavoriteUButton:SetActive(showFavorite)

	if onlySave then
		self.view.btnWidgetUWidget:SetActive(true)
		self.view.btnShareUButton:SetActive(false)
		self.view.btnUploadUButton:SetActive(false)
		self.view.btnTemplateUButton:SetActive(false)
		self.view.btnRoadUButton:SetActive(false)
		self.view.btnFolderUButton:SetActive(false)
		self.view.btnDeleteUButton:SetActive(false)
		self.view.btnFavoriteUButton:SetActive(false)
	end

	if isChatPicture then
		local enableState = photoInfo.chatLikeInfo.likedByMe and 1 or 0

		self.view.btnFavoriteUButton:TryChangePage("enable", enableState)
	elseif showFavorite then
		local isLiked = pg.global.ui.photo.model:isLikedTemplate(photoInfo.presetId)

		self.view.btnFavoriteUButton:TryChangePage("enable", isLiked and 1 or 0)
	end

	if photoInfo.onlyShow and not isChatPicture then
		self.view.btnWidgetUWidget:SetActive(false)
	elseif isChatPicture then
		self.view.btnWidgetUWidget:SetActive(true)
	end
end

function AlbumPhotoCtrl:getPointNameByPos(sceneId, pos)
	if not sceneId then
		return ""
	end

	local blockId = pg.game.map:inWhichBlock(sceneId, false, {
		x = pos[1],
		z = pos[3]
	})

	if blockId then
		return pg.getLocalizationText(MapBlockConfigData[blockId].areaName) or ""
	end

	return pg.game.map:getSceneName(sceneId)
end

function AlbumPhotoCtrl:updateAdaptation(texture)
	if not texture then
		return
	end

	self.view.adaptationBoxUXAdaptionRect.customResolution = Vector2(texture.width, texture.height)

	self.view.adaptationBoxUXAdaptionRect:UpdateAdaptation()
	self.view.adaptationBoxUXAdaptionRect.rectTransform:SetAnchorMinEx(0, 1)
	self.view.adaptationBoxUXAdaptionRect.rectTransform:SetAnchorMaxEx(0, 1)
	self.view.adaptationBoxUXAdaptionRect.rectTransform:SetPivotEx(0, 1)
	self.view.adaptationBoxUXAdaptionRect.rectTransform:SetAnchoredPositionEx(0, 0)
end

function AlbumPhotoCtrl:onShow()
	return
end

function AlbumPhotoCtrl:onHide()
	return
end

return AlbumPhotoCtrl
