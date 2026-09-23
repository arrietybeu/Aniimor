-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchDetailV2\\Component\\PetAlbumComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("PetAlbumComponent")
local lume = require("Core.Common.lume")
local PetBasePrototypeToPrototypeMap = require("Data.pet_base_prototype_to_prototype_map")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PetTraitPhotoData = require("Data.pet_trait_photo_data")
local PetAlbumComponent = Class.LightClass("PetAlbumComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientUtils = require("Utils.ClientUtils")

function PetAlbumComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.listUList = self.objectReference:GetRefValue("listUList")
	self.btnTopUButton = self.objectReference:GetRefValue("btnTopUButton")
	self.btnBottomUButton = self.objectReference:GetRefValue("btnBottomUButton")
	self.textUText = self.objectReference:GetRefValue("textUText")
	self.photosPageUComponent = self.objectReference:GetRefValue("photosPageUComponent")
end

function PetAlbumComponent:initView()
	self.needDestroySprites = {}
	self.photoIdPic = {}
	self.tabIdx = self.model.TAB_IDX.ALBUM
	self.ctrl.tabMap[self.tabIdx] = self
	self.petHandbookMap = pg.me.petHandbookMap
	self.photoPool = {}

	function self.listUList.luaRenderItem(button, idx, data)
		self:renderAlbum(button, idx, data)
	end

	ClientTextUtils.setText(self.textUText, pg.getGameString("PHOTO_ALBUM_IS_EMPTY"))

	function self.btnTopUButton.luaClick()
		self.listUList:GoToIndex(0)
	end

	function self.btnBottomUButton.luaClick()
		self.listUList:GotoEnd()
	end
end

function PetAlbumComponent:renderAlbum(button, idx, data)
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

function PetAlbumComponent:renderPhoto(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local photoUImage = objectReference:GetRefValue("photoUImage")

	if data.empty then
		button:TryChangePage("Empty", 0)

		button.interactable = false

		return
	end

	button:TryChangePage("Empty", 1)

	button.interactable = true

	if data.traitId then
		button:TryChangePage("PhotoIcon", 1)

		if self.photoIdPic[data.photoId] then
			photoUImage.sprite = self.photoIdPic[data.photoId]
		end

		pg.me:callPhotoGet(data.photoId, function(isOk, photoUrl)
			if isOk then
				ClientUtils.loadSpriteFromPhotoUrl(photoUrl, function(pic)
					if not pic then
						return
					end

					if not self.ctrl:checkUIOpen() then
						pg.global.mobileCameraMgr:DestroySpriteTexture(pic)

						return
					end

					self.needDestroySprites[#self.needDestroySprites + 1] = pic
					self.photoIdPic[data.photoId] = pic
					data.sprite = pic

					if self.listUList:GetData(button) == data then
						photoUImage.sprite = pic
					end
				end)
			elseif LoggerManager.checkLogger(LoggerConst.INFO) then
				logger:info("get photo failed")
			end
		end)
	else
		if data.isInRes then
			photoUImage.url = data.resId
		else
			photoUImage.url = nil

			pg.global.mobileCameraMgr:SetTextureToUImage(data.path, photoUImage, function()
				return
			end)
		end

		button:TryChangePage("PhotoIcon", 0)
	end

	function button.luaClick()
		pg.global.ui.albumPhoto:open({
			photoInfo = data,
			spriteInfos = self.spriteInfos
		})
	end
end

function PetAlbumComponent:onDeselectThisTab()
	self.ctrl.petScene:switchRootPetVisible(true)
end

function PetAlbumComponent:onDestroy()
	UIComponent.onDestroy(self)
	pg.global.mobileCameraMgr:ClearAlbumRes()

	for _, sprite in pairs(self.needDestroySprites) do
		pg.global.mobileCameraMgr:DestroySpriteTexture(sprite)
	end
end

function PetAlbumComponent:onSelectTopicAlbumPage()
	self.ctrl.petScene:switchRootPetVisible(false)
	self.ctrl.petScene:trySwitchView(self.tabIdx)

	if self.templateId == self.model.baseTemplateId then
		self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)

		return
	end

	self.templateId = self.model.baseTemplateId

	self:refreshPhotoList()
end

function PetAlbumComponent:onSelectThisPage(cb)
	self.ctrl:setPageTitle("TITLE_ALBUM")
	self:onSelectTopicAlbumPage()
	self.ctrl.petScene:playPetPageAction(self.templateId, self.tabIdx)
end

function PetAlbumComponent:refreshPhotoList()
	local photos = self:getPetPhotos()

	if #photos < 1 then
		self.photosPageUComponent:TryChangePage("Empty", 1)

		return
	end

	self.photosPageUComponent:TryChangePage("Empty", 0)

	local spriteDatas = self:getAlbumSprite()

	self.listUList:SetList(spriteDatas)
end

function PetAlbumComponent:getPetPhotos()
	return self:getAlbumSprite()
end

function PetAlbumComponent:getAlbumSprite()
	local spriteInfos = pg.global.mobileCameraMgr:GetPetImageFromAlbumByTemplateIds(lume.clone(PetBasePrototypeToPrototypeMap[self.templateId]))
	local serverSpritesInfo = self:getServerSprites()
	local weekGroup = {}
	local len = spriteInfos.Length

	for i = 0, len - 1 do
		local item = {}
		local spriteInfo = spriteInfos[i]

		item.sprite = spriteInfo.sprite
		item.isInRes = spriteInfo.isInRes

		if item.isInRes then
			item.resId = spriteInfo.path
		end

		local ts = spriteInfo.ts

		item.timeStamp = ts
		item.position = spriteInfo.pos
		item.path = spriteInfo.path
		item.sceneId = spriteInfo.sceneId
		item.templateIds = spriteInfo.templateIds
		item.tIndex = 1

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

	local weekList = {}
	local weekInfos = {}

	for _, weekInfo in pairs(weekGroup) do
		weekInfos[#weekInfos + 1] = weekInfo
	end

	table.sort(weekInfos, function(a, b)
		return a.startDate > b.startDate
	end)
	table.sort(weekList, function(a, b)
		return a.startDate > b.startDate
	end)

	local ret = {}

	self.spriteInfos = {}

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
	end

	return ret
end

function PetAlbumComponent:getServerSprites()
	local photoRecordMap = pg.me.photoRecordMap
	local petTraitPhotos = PetTraitPhotoData[self.templateId] or {}
	local ret = {}

	for traitId, identifyId in pairs(petTraitPhotos) do
		local recordInfo = photoRecordMap[identifyId]

		if recordInfo then
			local item = {}

			item.timeStamp = recordInfo.uploadTime
			item.position = recordInfo.uploadPos
			item.sceneId = recordInfo.uploadScene
			item.photoId = recordInfo.photoId
			item.traitId = traitId

			local weekIdx, startDate, endDate = self:getWeeklyByTs(recordInfo.uploadTime)

			item.weekIdx = weekIdx
			item.startDate = startDate
			item.endDate = endDate
			item.templateId = self.templateId
			item.tIndex = 1
			ret[#ret + 1] = item
		end
	end

	return ret
end

function PetAlbumComponent:getWeeklyByTs(ts)
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

function PetAlbumComponent:getSpriteInfo(sprite)
	return {}
end

function PetAlbumComponent:refreshPhoto(pic)
	if pic ~= nil then
		self.photo.sprite = pic
		self.pbPhotoFullPhoto.sprite = pic
		self.backBgImage.sprite = pic
	end
end

function PetAlbumComponent:loadPhotoById(photoId)
	pg.me:callPhotoGet(photoId, function(isOk, photoUrl)
		if isOk then
			ClientUtils.loadSpriteFromPhotoUrl(photoUrl, function(pic)
				if not pic then
					return
				end

				if not self.ctrl:checkUIOpen() then
					pg.global.mobileCameraMgr:DestroySpriteTexture(pic)

					return
				end

				self:refreshPhoto(pic)

				self.photoPool[photoId] = pic
				self.needDestroySprites[#self.needDestroySprites + 1] = pic
			end)
		elseif LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("get photo failed")
		end
	end)
end

return PetAlbumComponent
