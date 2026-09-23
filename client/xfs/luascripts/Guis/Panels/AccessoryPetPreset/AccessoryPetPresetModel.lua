-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AccessoryPetPreset\\AccessoryPetPresetModel.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("AccessoryPetPresetModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local Const = require("Common.Const.Const")
local AccessoryPetPresetModel = Class.LightClass("AccessoryPetPresetModel", UIModel)
local AppearanceCustomData = require("Data.appearance_custom_data")
local AttachPointData = require("Data.pet_appearance_point_data")
local ItemData = require("Data.item_data")
local CallbackHandler = require("Core.Common.CallbackHandler")
local PetData = require("Data.pet_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ServiceUtils = require("Common.Utils.ServiceUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientUtils = require("Utils.ClientUtils")
local Utils = require("Common.Utils.Utils")
local PetJewelryOssCache = require("Utils.PetJewelryOssCache")

AccessoryPetPresetModel.OUTFIT_TAB = {
	PREVIEW = "Preview",
	EMPTY = "Empty",
	NOW = "Now",
	LOCKED = "Locked",
	NORMAL = "Normal"
}
AccessoryPetPresetModel.CONTENT_TAB = {
	EMPTY_NO_WORD = "EmptyNoWord",
	EMPTY = "Empty",
	HAVE = "Have",
	LOCKED = "Locked"
}
AccessoryPetPresetModel.OP_TYPE = {
	SAVE_TO_OUTFIT = 1,
	USE_FROM_OUTFIT = 0,
	SAVE_TO_EMPTY = 2
}

function AccessoryPetPresetModel:initQuickPhotoCache()
	self.needDestroyDownloadSprites = {}
end

function AccessoryPetPresetModel:initAvatarScene(petId)
	local UISceneConst = require("GameApp.UIScene.UISceneConst")

	self.avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)

	local pInfo = pg.me:getPetInfo(petId)

	self.adjustPetCurId = petId
	self.adjustPetProId = pInfo.petPrototypeId
	self.adjustPetTmpId = pInfo.id

	self:initPresetDataList()
end

function AccessoryPetPresetModel:getTitleInfo()
	local res = {}
	local pInfo = pg.me:getPetInfo(self.adjustPetCurId)

	if pInfo == nil then
		return res
	end

	local cData = PetData[pInfo.templateId]

	if cData == nil then
		return res
	end

	res.refPetIcon = LuaUIUtils.getPetIcon(cData.iconName, LuaUIUtils.PET_ICON, pInfo.label, pInfo.gender)

	local title = pg.getGameString("PET_FAMILY_PRESET_TITLE")

	res.title = pg.getFormatText(title, pg.getLocalizationText(cData.name))

	return res
end

function AccessoryPetPresetModel:initPresetDataList()
	local res = {}

	table.insert(res, {
		slot = 0,
		state = self.OUTFIT_TAB.NOW,
		name = pg.getGameString("APPEARANCE_CURRENT_SUIT")
	})

	local presetDic = pg.me.petJewelryCustom[self.adjustPetProId]

	for slot, v in presetDic:items() do
		local item = {
			state = self.OUTFIT_TAB.EMPTY,
			slot = slot,
			name = ClientTextUtils.concatByLanguage(pg.getGameString("APPEARANCE_OUTFIT"), tostring(slot))
		}

		self:refreshPresetData(item)

		res[#res + 1] = item
	end

	local lastIdx = #res + 1
	local data = AppearanceCustomData[lastIdx - 1]

	if data.petJewelryCostType and data.petJewelryCostNum then
		local item = {
			slot = lastIdx,
			state = self.OUTFIT_TAB.LOCKED,
			name = ClientTextUtils.concatByLanguage(pg.getGameString("APPEARANCE_OUTFIT"), tostring(lastIdx)),
			unlockCost = {
				id = data.petJewelryCostType,
				num = data.petJewelryCostNum
			}
		}

		self:refreshPresetData(item)
		table.insert(res, item)
	end

	self.presetDataList = res

	return res
end

function AccessoryPetPresetModel:refreshPresetData(item)
	if item.state == self.OUTFIT_TAB.NOW then
		return
	end

	local presetDic = pg.me.petJewelryCustom[self.adjustPetProId]
	local preset = presetDic[item.slot]

	if preset then
		item.state = self.OUTFIT_TAB.EMPTY

		for _, v in preset.customPresets:items() do
			if v and v ~= 0 then
				item.state = self.OUTFIT_TAB.NORMAL

				break
			end
		end

		if not string.isNilOrEmpty(preset.customName) then
			item.name = preset.customName
		end
	else
		item.state = self.OUTFIT_TAB.LOCKED
	end
end

function AccessoryPetPresetModel:refreshPresetDataList()
	if self.presetDataList == nil then
		return
	end

	for _, v in ipairs(self.presetDataList) do
		self:refreshPresetData(v)
	end
end

function AccessoryPetPresetModel:getPresetDataList()
	return self.presetDataList
end

function AccessoryPetPresetModel:getOutfitAccesses(presetData)
	if presetData.state == self.OUTFIT_TAB.NOW then
		return self:getCurrentEquipAccess()
	end

	if presetData.state == self.OUTFIT_TAB.EMPTY then
		return self:getEmptyAccesses(presetData)
	end

	if presetData.state == self.OUTFIT_TAB.NORMAL then
		return self:getPresetAccesses(presetData)
	end
end

function AccessoryPetPresetModel:getCurrentEquipAccess()
	local accesses = pg.me.petJewelryInfos[self.adjustPetCurId] or {
		customShow = {}
	}
	local res = {}
	local maxSlot = table.nums(AttachPointData)

	for slot = 1, maxSlot do
		local item
		local genId = accesses.customShow[slot]

		if genId and genId ~= 0 then
			item = {
				empty = false,
				slot = slot,
				accessoryId = accesses.customPresets[slot] or 0
			}
			item.state = self.CONTENT_TAB.HAVE

			self:accessoryBaseInfo(item)
		else
			item = {
				empty = true,
				slot = slot
			}
			item.state = self.CONTENT_TAB.EMPTY_NO_WORD
		end

		res[#res + 1] = item
	end

	return res
end

function AccessoryPetPresetModel:getEmptyAccesses(presetData)
	local pIndex = presetData.slot
	local res = {}
	local maxSlot = table.nums(AttachPointData)

	for slot = 1, maxSlot do
		res[#res + 1] = {
			slot = slot,
			state = self.CONTENT_TAB.EMPTY_NO_WORD,
			pIndex = pIndex
		}
	end

	return res
end

function AccessoryPetPresetModel:getPresetAccesses(presetData)
	local pIndex = presetData.slot
	local res = {}
	local maxSlot = table.nums(AttachPointData)

	for slot = 1, maxSlot do
		local item = {
			empty = true,
			slot = slot,
			pIndex = pIndex
		}

		self:refreshAccessData(item)

		res[#res + 1] = item
	end

	return res
end

function AccessoryPetPresetModel:accessoryBaseInfo(data)
	local itemData = ItemData[data.accessoryId]

	if itemData == nil then
		return
	end

	data.icon = itemData.icon
	data.name = itemData.itemName
	data.quality = itemData.quality
end

function AccessoryPetPresetModel:refreshAccessData(data)
	local petProId = self.adjustPetProId
	local petPreset = pg.me.petJewelryCustom[petProId]

	if petPreset == nil then
		return
	end

	local jewelryInfo = petPreset[data.pIndex]

	if jewelryInfo == nil then
		return
	end

	local accessoryId = jewelryInfo.customPresets[data.slot]

	if accessoryId and accessoryId ~= 0 then
		data.accessoryId = accessoryId
		data.state = self.CONTENT_TAB.HAVE
		data.empty = false

		self:accessoryBaseInfo(data)
	else
		data.state = self.CONTENT_TAB.EMPTY_NO_WORD
		data.empty = true
	end
end

function AccessoryPetPresetModel:refreshAccessDataList(dataList)
	if dataList == nil then
		return
	end

	for _, v in pairs(dataList) do
		self:refreshAccessData(v)
	end
end

function AccessoryPetPresetModel:unlockPresetSlot2Server(callback)
	local petProId = self.adjustPetProId

	pg.me:serverMsg("RPC_CS_UnlockPetAppearanceCustom", petProId, callback)
end

function AccessoryPetPresetModel:savePreset2Server(slot, callback)
	pg.me:serverMsg("RPC_CS_SavePetJewelryCustom", self.adjustPetProId, slot, self.adjustPetCurId, callback)
end

function AccessoryPetPresetModel:setPresetName(slot, name, callback)
	local petProId = self.adjustPetProId

	pg.me:serverMsg("RPC_CS_SetPetJewelryCustomName", petProId, slot, name, callback)
end

function AccessoryPetPresetModel:parseServerJewelryInfo(modelView, slot)
	local attachInfo = self.tabIdxToAttach[slot]
	local instanceId = attachInfo.instanceId
	local item = {
		configId = attachInfo.accessoryId
	}

	item.attachBone = modelView:GetAttachBoneName(instanceId)

	local lPos = modelView:GetAttachLocalPosition(instanceId)

	item.posX = lPos.x
	item.posY = lPos.y
	item.posZ = lPos.z

	local lRot = modelView:GetAttachLocalEulerRotation(instanceId)

	item.rotX = lRot.x
	item.rotY = lRot.y
	item.rotZ = lRot.z
	item.scale = modelView:GetAttachLocalScale(instanceId)

	return item
end

function AccessoryPetPresetModel:applyPreset(index, callback)
	local petId = self.adjustPetCurId

	pg.me:serverMsg("RPC_CS_ApplyPetJewelryCustom", petId, index, function(res, countTable)
		if res then
			self:syncAppliedPresetTransforms(petId)
		end

		if callback then
			callback(res, countTable)
		end
	end)
end

function AccessoryPetPresetModel:syncAppliedPresetTransforms(petId)
	local jewelryInfo = pg.me.petJewelryInfos[petId]

	if not jewelryInfo then
		return
	end

	local changed = false

	for slot, genId in jewelryInfo.customShow:items() do
		local accessoryId = jewelryInfo.customPresets[slot]

		if genId and genId ~= 0 and accessoryId and accessoryId ~= 0 then
			local slotInfo = jewelryInfo[slot]

			if slotInfo then
				PetJewelryOssCache.set(petId, accessoryId, {
					configId = accessoryId,
					attachBone = slotInfo.attachBone,
					posX = slotInfo.posX,
					posY = slotInfo.posY,
					posZ = slotInfo.posZ,
					rotX = slotInfo.rotX,
					rotY = slotInfo.rotY,
					rotZ = slotInfo.rotZ,
					scale = slotInfo.scale
				})
			else
				PetJewelryOssCache.remove(petId, accessoryId)
			end

			changed = true
		end
	end

	if changed then
		PetJewelryOssCache.upload()
	end
end

function AccessoryPetPresetModel:captureQuickPetPresetPhoto(imageSize, callback)
	local entity = self.avatarScene:getCurEntity()

	if entity == nil then
		return
	end

	local rate = Screen.width / 1920
	local sizeDelta = imageSize * 2.2 * rate
	local _ex, _ey, _ez = entity.eModel:GetPositionAgentPosEx()
	local screenPos = self.avatarScene.camera:WorldToScreenPoint(Vector3.New(_ex, _ey, _ez))
	local position = Vector2.New(screenPos.x - sizeDelta.x / 2, screenPos.y - sizeDelta.y * 1 / 6)

	Utils.captureAndCheckPhoto(Const.PhotoCheckScene.Share, function(sprite, _, success, imageKey)
		if callback then
			local presetSprite

			if success and NotNil(sprite) then
				local texture = sprite.texture

				presetSprite = pg.global.mobileCameraMgr:GetSpriteCover(sprite, texture.width, texture.height)
			end

			callback(presetSprite, imageKey, success and NotNil(presetSprite))
		end
	end, position, sizeDelta, 3, false, true)
end

function AccessoryPetPresetModel:retainRuntimeSprite(sprite)
	if IsNil(sprite) or not self.needDestroyDownloadSprites then
		return false
	end

	self.needDestroyDownloadSprites[#self.needDestroyDownloadSprites + 1] = sprite

	return true
end

function AccessoryPetPresetModel:uploadQuickPhoto(tabData, imageKey, update, callback)
	local key = self:getQuickPhotoServiceKey(tabData.slot)

	pg.me:serverMsg("RPC_CS_UploadAppearancePhoto", key, imageKey or "")
	callback()
end

function AccessoryPetPresetModel:downloadQuickPhoto(slot, callback)
	local key = self:getQuickPhotoServiceKey(slot)
	local downloadSprites = self.needDestroyDownloadSprites

	local function cb(status, response)
		local isOk = status.status

		if isOk then
			ClientUtils.pullPicture(response.value, function(_, sprite)
				if downloadSprites == nil or self.needDestroyDownloadSprites ~= downloadSprites then
					if sprite then
						pg.global.mobileCameraMgr:DestroySpriteTexture(sprite)
					end

					return
				end

				if sprite then
					downloadSprites[#downloadSprites + 1] = sprite
				end

				if callback then
					callback(sprite ~= nil, sprite)
				end
			end)
		elseif callback then
			callback(false, nil)
		end

		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug("@zqd downloadQuickPhoton -000: ", inspect(status), inspect(response.context))
		end
	end

	ServiceUtils.kvServiceFind(key, cb)
end

function AccessoryPetPresetModel:getQuickPhotoServiceKey(slot)
	slot = slot or 999

	return string.format("access_pet_preset_quick_photo_key_%d_%d", self.adjustPetProId, slot)
end

function AccessoryPetPresetModel:clearOperationData()
	self.avatarScene = nil
end

function AccessoryPetPresetModel:destroy()
	if self.needDestroyDownloadSprites then
		for _, sprite in ipairs(self.needDestroyDownloadSprites) do
			pg.global.mobileCameraMgr:DestroySpriteTexture(sprite)
		end
	end

	self.needDestroyDownloadSprites = nil
end

return AccessoryPetPresetModel
