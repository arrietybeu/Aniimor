-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Photo\\PhotoModel.lua

local PhotoIdentifyData = require("Data.photo_identify_data")
local UIModel = require("Guis.UIModel")
local Class = require("Core.Framework.Class")
local PhotoModel = Class.LightClass("PhotoModel", UIModel)
local Lume = require("Core.Common.lume")
local Utils = require("Common.Utils.Utils")
local ClientUtils = require("Utils.ClientUtils")
local ClientConst = require("Const.ClientConst")
local PhotographyAssetRedDotUtils = require("Utils.PhotographyAssetRedDotUtils")
local PetData = require("Data.pet_data")
local PhotoOfficialPresetData = require("Data.photo_official_preset_data")
local PhotoPrefabData = require("Data.photo_prefab_data")
local StudioSceneId = 521

PhotoModel.CameraModeIds = {
	WideAngle = 1,
	FreeCamera = 0,
	FishEye = 2
}
PhotoModel.TemplateType = {
	Hot = 2,
	Official = 1,
	Saved = 4,
	Liked = 3
}

function PhotoModel:ctor()
	UIModel.ctor(self)

	self.curCameraMode = self.CameraModeIds.FreeCamera
	self.templateCache = {}
	self.templateIdMap = {}
	self.presetImgSpriteMap = {}
	self.presetImgRequestSerial = 0
	self.officialKey2Data = nil
	self.studioPreset = nil
	self.studioAssetsId = nil
end

function PhotoModel:getTableDataByOfficialKey(officialId)
	if not self.officialKey2Data then
		self.officialKey2Data = {}

		for k, v in pairs(PhotoOfficialPresetData) do
			self.officialKey2Data[v.key] = v
		end
	end

	return self.officialKey2Data[officialId]
end

function PhotoModel:getCameraMode()
	return self.curCameraMode
end

function PhotoModel:setCameraMode(mode)
	self.curCameraMode = mode
end

function PhotoModel:setStudioPreset(preset)
	self.studioPreset = preset
end

function PhotoModel:getStudioPreset()
	return self.studioPreset
end

function PhotoModel:setStudioAssetsId(assetsId)
	if self.studioAssetsId == assetsId then
		return
	end

	self.studioAssetsId = assetsId

	if tonumber(self.studioAssetsId) then
		pg.global.prefsCacheUtils:setInt(ClientConst.PrefKey.PhotoStudioPrefab, self.studioAssetsId)
	else
		pg.global.prefsCacheUtils:deleteKey(ClientConst.PrefKey.PhotoStudioPrefab)
	end
end

function PhotoModel:getStudioAssetsId()
	if not self.studioAssetsId then
		self.studioAssetsId = pg.global.prefsCacheUtils:getInt(ClientConst.PrefKey.PhotoStudioPrefab, -1)
	end

	if self.studioAssetsId and self.studioAssetsId >= 0 then
		return self.studioAssetsId
	end

	return nil
end

function PhotoModel:tryGetPhotoTitle()
	local quickPhoto = pg.global.ui.hudV2.quickPhoto
	local photoId = quickPhoto.quickPhotoId or quickPhoto.curAITraitPhotoId

	if photoId then
		local identifyData = PhotoIdentifyData[photoId] or {}

		return identifyData.desc
	end
end

function PhotoModel:getPreparePetList()
	local player = pg.me
	local petPrepareInfoList = player:isTeamPlayerInWorld() and player:getTeamPetIds() or player.petPrepareList
	local infoList = {}

	if not petPrepareInfoList then
		return infoList
	end

	local curPet = pg.me:getCurPetEntity()
	local curPetId = curPet and curPet.id

	for index, petId in ipairs(petPrepareInfoList) do
		local petInfo = pg.me:getPetInfo(petId)

		if petInfo ~= nil then
			local pData = PetData[petInfo.templateId]

			infoList[#infoList + 1] = {
				entityId = petId,
				config = pData,
				templateId = petInfo.templateId,
				isCurPet = petId == curPetId
			}
		end
	end

	return infoList
end

function PhotoModel:getCurPetIndex()
	local player = pg.me
	local curPet = pg.me:getCurPetEntity()
	local curPetId = curPet and curPet.id
	local petPrepareInfoList = player:isTeamPlayerInWorld() and player:getTeamPetIds() or player.petPrepareList

	for index, petId in ipairs(petPrepareInfoList) do
		if petId == curPetId then
			return index
		end
	end

	return 1
end

function PhotoModel:getAssetsData(assetTable, type2Data, type2Name)
	for k, data in pairs(assetTable) do
		local type = data.type or 1

		if not type2Data[type] then
			type2Data[type] = {}
		end

		if data.name and not type2Name[type] then
			type2Name[type] = data.name
		end

		local list = type2Data[type]

		list[#list + 1] = Lume.clone(data)
	end

	for k, dataList in pairs(type2Data) do
		table.sort(dataList, function(a, b)
			return a.id < b.id
		end)
	end
end

function PhotoModel:isLikedTemplate(id)
	return pg.me.photoPresetInfo.likedIdMap[id] and true or false
end

function PhotoModel:likeTemplate(id, isLike, callback)
	if isLike then
		pg.me:likePhotoPresetAdd(id, callback)
	else
		pg.me:likePhotoPresetDel(id, callback)
	end
end

function PhotoModel:isSavedTemplate(id)
	return pg.me.photoPresetInfo.savedIdMap[id] and true or false
end

function PhotoModel:deleteSavedTemplate(id, imgKey, callback)
	pg.me:deleteMyPhotoPreset(id, imgKey, callback)
end

function PhotoModel:getOfficialTemplate(isStudio)
	local ret = {}

	if isStudio then
		for k, v in pairs(PhotoPrefabData) do
			ret[#ret + 1] = Lume.clone(v)
		end

		PhotographyAssetRedDotUtils.sortUnlockedFirst(ret, PhotographyAssetRedDotUtils.AssetType.StudioPrefab)
	else
		for k, v in pairs(PhotoOfficialPresetData) do
			ret[#ret + 1] = self:genOfficialTemplateData(v.key)
		end
	end

	return ret
end

function PhotoModel:genOfficialTemplateData(key)
	local id = Utils.genPhotoPresetUniqueId(true, key)

	if self.templateIdMap[id] then
		return self.templateIdMap[id]
	end

	local tableData = self:getTableDataByOfficialKey(key)
	local data = {}

	data.preset = pg.global.cameraMgr.vcManager:GetPhotoPreset(key)
	data.title = tableData.name
	data.desc = tableData.describe
	data.time = nil
	data.userName = tableData.owner
	data.id = id
	data.isOfficial = true
	self.templateIdMap[id] = data

	return data
end

function PhotoModel:getHotTemplate(isStudioType)
	return {}
end

function PhotoModel:filterTemplateList(list, isStudioType)
	local ret = {}

	for i = 1, #list do
		local data = list[i]

		if isStudioType then
			if data.preset.sceneId == StudioSceneId then
				ret[#ret + 1] = data
			end
		elseif data.preset.sceneId ~= StudioSceneId then
			ret[#ret + 1] = data
		end
	end

	return ret
end

function PhotoModel:getLikedTemplate(callback, isStudioType)
	if self.isQueryingLiked then
		return
	end

	local callback = function(list)
		local ret = self:filterTemplateList(list, isStudioType)

		callback(ret)
	end

	if not self.templateCache[self.TemplateType.Liked] then
		self.templateCache[self.TemplateType.Liked] = {}
	end

	local likeList = self.templateCache[self.TemplateType.Liked]
	local likedIdMap = pg.me.photoPresetInfo.likedIdMap

	local function sortList()
		table.sort(likeList, function(a, b)
			return likedIdMap[a.id] > likedIdMap[b.id]
		end)
	end

	local count = 0

	for k, v in pairs(likedIdMap) do
		count = count + 1
	end

	for i = #likeList, 1, -1 do
		local id = likeList[i].id

		if not self:isLikedTemplate(id) then
			self.templateIdMap[id] = nil

			table.remove(likeList, i)
		end
	end

	if #likeList == count then
		sortList()
		callback(likeList)

		return
	end

	local map = {}

	for i = 1, #likeList do
		map[likeList[i].id] = true
	end

	for presetId, _ in pairs(likedIdMap) do
		if not map[presetId] then
			if self.templateIdMap[presetId] then
				likeList[#likeList + 1] = self.templateIdMap[presetId]
				map[presetId] = true

				if #likeList == count then
					self.isQueryingLiked = false

					sortList()
					callback(likeList)
				end
			else
				local isOfficial, rawId = Utils.parsePhotoPresetUniqueId(presetId)

				if isOfficial then
					likeList[#likeList + 1] = self:genOfficialTemplateData(rawId)

					sortList()
					callback(likeList)
				else
					pg.me:_queryPhotoPreset(presetId, function(content)
						content.id = presetId
						self.templateIdMap[presetId] = content
						map[presetId] = true
						likeList[#likeList + 1] = content
						self.isQueryingLiked = true

						if #likeList == count then
							self.isQueryingLiked = false

							sortList()
							callback(likeList)
						end
					end)
				end
			end
		end
	end
end

function PhotoModel:getSavedTemplate(callback, isStudioType)
	if self.isQueryingSaved then
		return
	end

	local callback = function(list)
		local ret = self:filterTemplateList(list, isStudioType)

		callback(ret)
	end

	if not self.templateCache[self.TemplateType.Saved] then
		self.templateCache[self.TemplateType.Saved] = {}
	end

	local list = self.templateCache[self.TemplateType.Saved]
	local savedIdMap = pg.me.photoPresetInfo.savedIdMap

	local function sortList()
		table.sort(list, function(a, b)
			return savedIdMap[a.id] > savedIdMap[b.id]
		end)
	end

	local count = 0

	for k, v in pairs(savedIdMap) do
		count = count + 1
	end

	for i = #list, 1, -1 do
		local id = list[i].id

		if not self:isSavedTemplate(id) then
			self.templateIdMap[id] = nil

			table.remove(list, i)
		end
	end

	if #list == count then
		sortList()
		callback(list)

		return
	end

	local map = {}

	for i = 1, #list do
		map[list[i].id] = true
	end

	for presetId, _ in pairs(savedIdMap) do
		if not map[presetId] then
			if self.templateIdMap[presetId] then
				list[#list + 1] = self.templateIdMap[presetId]
				map[presetId] = true

				if #list == count then
					self.isQueryingSaved = false

					sortList()
					callback(list)
				end
			else
				pg.me:_queryPhotoPreset(presetId, function(content)
					if not content then
						return
					end

					content.id = presetId

					if content.iconData then
						content.icon = pg.global.mobileCameraMgr:GetSpriteByCompressByte(content.iconData)
						content.iconData = nil
					end

					self.templateIdMap[presetId] = content
					map[presetId] = true
					list[#list + 1] = content
					self.isQueryingSaved = true

					if #list == count then
						self.isQueryingSaved = false

						sortList()
						callback(list)
					end
				end)
			end
		end
	end
end

function PhotoModel:getPresetByQRCode(str, callback, notDecode)
	local presetId = notDecode and str or str and Utils.decodeFromStr(str)

	if presetId then
		pg.me:_queryPhotoPreset(presetId, function(content)
			if content then
				content.id = presetId

				callback(content.preset)
			else
				pg.global.showBubbleMessageRaw(pg.getGameString("PHOTO_SCAN_FAILED"))
			end
		end)
	else
		pg.global.showBubbleMessageRaw(pg.getGameString("PHOTO_SCAN_FAILED"))
	end
end

function PhotoModel:queryTemplateByPresetId(presetId, callback)
	local isOfficial, rawId = Utils.parsePhotoPresetUniqueId(presetId)

	if isOfficial then
		callback(self:genOfficialTemplateData(rawId))
	elseif self.templateIdMap[presetId] then
		callback(self.templateIdMap[presetId])
	else
		pg.me:_queryPhotoPreset(presetId, function(content)
			content.id = presetId

			if content.iconData then
				content.icon = pg.global.mobileCameraMgr:GetSpriteByCompressByte(content.iconData)
				content.iconData = nil
			end

			self.templateIdMap[presetId] = content

			callback(content)
		end)
	end
end

function PhotoModel:queryPresetImg(key, callback, id)
	if self.presetImgSpriteMap[key] then
		callback(self.presetImgSpriteMap[key], id)
	else
		local requestSerial = self.presetImgRequestSerial

		ClientUtils.pullPicture(key, function(resultKey, sprite)
			if requestSerial ~= self.presetImgRequestSerial then
				if sprite then
					pg.global.mobileCameraMgr:DestroySpriteTexture(sprite)
				end

				return
			end

			if resultKey == key and sprite then
				local cachedSprite = self.presetImgSpriteMap[key]

				if cachedSprite then
					pg.global.mobileCameraMgr:DestroySpriteTexture(sprite)

					sprite = cachedSprite
				else
					self.presetImgSpriteMap[key] = sprite
				end

				callback(sprite, id)
			end
		end)
	end
end

function PhotoModel:clearTemplateCache()
	self.presetImgRequestSerial = self.presetImgRequestSerial + 1
	self.templateCache = {}
	self.templateIdMap = {}

	for _, sprite in pairs(self.presetImgSpriteMap) do
		pg.global.mobileCameraMgr:DestroySpriteTexture(sprite)
	end

	self.presetImgSpriteMap = {}
end

function PhotoModel:isArriveTrackPos(sceneId, x, y, z)
	if pg.me.space.sceneId ~= sceneId then
		return false
	end

	local tarPos = Vector3(x, y, z)

	if Vector3.Distance(tarPos, pg.me:getPosition()) >= 6 then
		return false
	end

	return true
end

return PhotoModel
