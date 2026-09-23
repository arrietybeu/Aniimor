-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientPhotoComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local CallbackHandler = require("Core.Common.CallbackHandler")
local ServiceUtils = require("Common.Utils.ServiceUtils")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local IDManager = require("Core.Common.IDManager")
local PhotoOfficialPresetData = require("Data.photo_official_preset_data")
local ClientUtils = require("Utils.ClientUtils")
local NoticeDef = require("Common.NoticeDef")
local ClientPhotoComponent = Class.Component("ClientPhotoComponent")

function ClientPhotoComponent:callPhotoGet(photoId, callback)
	local function cb(status, response)
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self.logger:debug("callPhotoGet callback", inspect(status), inspect(response.key))
		end

		local isOk = status.status

		if callback ~= nil then
			callback(isOk, response.value)
		end
	end

	ServiceUtils.kvServiceFind("photo-" .. photoId, cb)

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("callPhotoGet", photoId, self.uid)
	end
end

function ClientPhotoComponent:getOSSPhotoPictureKey(photoKey, callback)
	self:callPhotoGet(photoKey, function(isOk, photoUrl)
		if not isOk or string.isNilOrEmpty(photoUrl) then
			if callback then
				callback(nil)
			end

			return
		end

		local pictureKey = string.match(photoUrl, "/picture/([^/?#]+)")

		if string.isNilOrEmpty(pictureKey) then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				self.logger:error("getOSSPhotoPictureKey invalid photo url, photoKey=%s", tostring(photoKey))
			end

			if callback then
				callback(nil)
			end

			return
		end

		if callback then
			callback(pictureKey)
		end
	end)
end

function ClientPhotoComponent:pullOSSPhoto(photoKey, callback)
	self:getOSSPhotoPictureKey(photoKey, function(pictureKey)
		if string.isNilOrEmpty(pictureKey) then
			if callback then
				callback(nil)
			end

			return
		end

		ClientUtils.pullPicture(pictureKey, function(_, sprite)
			if callback then
				callback(sprite)
			end
		end)
	end)
end

function ClientPhotoComponent:removeOSSPhoto(photoKey, callback)
	if string.isNilOrEmpty(photoKey) then
		if callback then
			callback(false)
		end

		return
	end

	self:getOSSPhotoPictureKey(photoKey, function(pictureKey)
		if string.isNilOrEmpty(pictureKey) then
			if callback then
				callback(false)
			end

			return
		end

		ClientUtils.deletePicture(pictureKey, function(_, err)
			if err then
				if callback then
					callback(false)
				end

				return
			end

			self:serverMsg("RPC_CS_RemoveOSSPhoto", photoKey, function(result)
				if callback then
					callback(result == NoticeDef.SUCCESS)
				end
			end)
		end)
	end)
end

function ClientPhotoComponent:testPhotoGet(photoId)
	self:callPhotoGet(photoId, function(isOk, photoContent)
		if isOk then
			if LoggerManager.checkLogger(LoggerConst.INFO) then
				self.logger:info("get photo success, photoId:%s, content:%s", photoId, photoContent)
			end
		elseif LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("get photo failed")
		end
	end)
end

function ClientPhotoComponent:testPhotoGetByConfigId(photoConfigId)
	local photoId = self.photoRecordMap[photoConfigId] and self.photoRecordMap[photoConfigId].photoId

	self:testPhotoGet(photoId)
end

function ClientPhotoComponent:onLeaveSpace()
	pg.global.ui.photo:clearTemplateCache()
end

function ClientPhotoComponent:getPhotoLightScheme(slot)
	local rawScheme = self.photoLightSchemeList and self.photoLightSchemeList[slot]

	if string.isNilOrEmpty(rawScheme) then
		return nil
	end

	local decodeOk, scheme = pcall(Utils.decodeFromStr, rawScheme)

	if not decodeOk or type(scheme) ~= "table" then
		self.logger:error("getPhotoLightScheme decode failed, slot=%s", tostring(slot))

		return nil
	end

	return scheme
end

function ClientPhotoComponent:uploadPhotoLightScheme(slot, scheme, callback)
	local maxCount = tonumber(self.photoLightSchemeCount) or 0

	if type(slot) ~= "number" or slot < 1 or maxCount < slot or type(scheme) ~= "table" then
		if callback then
			callback(NoticeDef.FAIL)
		end

		return false
	end

	local schemeStr = Utils.encodeToStr(scheme)

	if string.isNilOrEmpty(schemeStr) then
		self.logger:error("uploadPhotoLightScheme encode failed, slot=%s", tostring(slot))

		if callback then
			callback(NoticeDef.FAIL)
		end

		return false
	end

	if callback then
		self:serverMsg("RPC_CS_UploadPhotoLightScheme", slot, schemeStr, callback)
	else
		self:serverMsg("RPC_CS_UploadPhotoLightScheme", slot, schemeStr)
	end

	return true
end

function ClientPhotoComponent:savePhotoPresetAdd(presetInfo, callback)
	local presetStr = Utils.encodeToStr(presetInfo) or ""

	self:serverMsg("RPC_CS_SavePhotoPresetAdd", presetStr, callback)
end

function ClientPhotoComponent:savePhotoPresetDel(presetId, callback)
	local isOfficial, rawId = Utils.parsePhotoPresetUniqueId(presetId)

	assert(not isOfficial, "cannot delete official preset")
	self:serverMsg("RPC_CS_SavePhotoPresetDel", presetId, callback)
end

function ClientPhotoComponent:likePhotoPresetAdd(presetId, callback)
	self:serverMsg("RPC_CS_LikePhotoPresetAdd", presetId, callback)
end

function ClientPhotoComponent:likePhotoPresetDel(presetId, callback)
	self:serverMsg("RPC_CS_LikePhotoPresetDel", presetId, callback)
end

function ClientPhotoComponent:onPhotoPresetInfo_SavedIdMap_EntryAdded(key, value)
	if pg.logDebug() then
		self.logger:debug("photoPreset onPhotoPresetInfo_SavedIdMap_EntryAdded key=%s, value=%s", key, inspect(value))
	end
end

function ClientPhotoComponent:onPhotoPresetInfo_SavedIdMap_EntryDeleted(key, value)
	if pg.logDebug() then
		self.logger:debug("photoPreset onPhotoPresetInfo_SavedIdMap_EntryDeleted key=%s, value=%s", key, inspect(value))
	end
end

function ClientPhotoComponent:onPhotoPresetInfo_LikedIdMap_EntryAdded(key, value)
	if pg.logDebug() then
		self.logger:debug("photoPreset onPhotoPresetInfo_LikedIdMap_EntryAdded key=%s, value=%s", key, inspect(value))
	end
end

function ClientPhotoComponent:onPhotoPresetInfo_LikedIdMap_EntryDeleted(key, value)
	if pg.logDebug() then
		self.logger:debug("photoPreset onPhotoPresetInfo_LikedIdMap_EntryDeleted key=%s, value=%s", key, inspect(value))
	end
end

function ClientPhotoComponent:_queryPhotoPreset(presetId, callback)
	local isOfficial, rawId = Utils.parsePhotoPresetUniqueId(presetId)

	if isOfficial then
		local content = PhotoOfficialPresetData[tonumber(rawId)]

		callback(content)
	else
		local kvKey = Utils.genKVKey(Const.KV_KEY.PHOTO_PRESET, presetId)

		ServiceUtils.kvServiceFind(kvKey, function(status, response)
			local contentStr = status.status and response.value
			local content = contentStr and Utils.decodeFromStr(contentStr)

			if content == nil then
				self.logger:error("photoPreset _queryPhotoPreset failed, presetId=%s", presetId)
			end

			callback(content)
		end)
	end
end

function ClientPhotoComponent:addPhotoImgSprite(sprite, callback)
	local picId = Utils.genPhotoPresetPicId(IDManager.genStrID())

	ClientUtils.uploadPicture(picId, sprite, callback)
end

function ClientPhotoComponent:genPresetWithImgUrlSprite(preset, sprite, callback)
	self:addPhotoImgSprite(sprite, function(key, result)
		if result == true then
			preset.imgKey = key
		end

		callback(result)
	end)
end

function ClientPhotoComponent:uploadPresetWithImgSprite(preset, sprite, callback)
	self:genPresetWithImgUrlSprite(preset, sprite, function(result)
		if result == true then
			self:savePhotoPresetAdd(preset, function(result, id)
				if result ~= NoticeDef.SUCCESS then
					self.logger:error("photoPreset uploadPresetWithImgSprite failed! result = %s", result)

					if preset.imgKey then
						ClientUtils.deletePicture(preset.imgKey)
					end

					return
				end

				callback(id)
			end)
		end
	end)
end

function ClientPhotoComponent:deleteMyPhotoPreset(presetId, imgKey, callback)
	self:savePhotoPresetDel(presetId, function(result)
		if result == NoticeDef.SUCCESS then
			if imgKey then
				ClientUtils.deletePicture(imgKey)
			end

			callback()
		end
	end)
end

return ClientPhotoComponent
