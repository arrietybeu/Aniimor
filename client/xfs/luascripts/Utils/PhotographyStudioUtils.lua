-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\PhotographyStudioUtils.lua

local AppearancePointEnum = require("Data.appearance_point_enum")
local FilterData = require("Data.photo_filter_data")
local DIYData = require("Data.photo_diy_data")
local OrnamentData = require("Data.photo_ornament_data")
local AddressDataConst = require("Const.AddressDataConst")
local UIConst = require("Const.UIConst")
local ClientConst = require("Const.ClientConst")
local Time = require("Core.Common.Time")
local ClientUtils = require("Utils.ClientUtils")
local Utils = require("Common.Utils.Utils")
local CommonSwitch = require("Common.CommonSwitch")
local FuncIdConfigData = require("Data.func_index_config_data")
local FunctionEnum = require("Data.function_unlock_enum")
local PhotoLightDiyModel = require("Guis.Panels.PhotoLightDiy.PhotoLightDiyModel")
local PetJewelryOssCache = require("Utils.PetJewelryOssCache")
local PhotographyStudioUtils = {}
local LightingData = require("Data.photo_lighting_data")

PhotographyStudioUtils.CONTENT_VERSION = 1
PhotographyStudioUtils.STUDIO_PET_KEY_PREFIX = "studioPet_"
PhotographyStudioUtils.SEVEN_DAY_CONFIRM_TYPE = {
	ImportOverwrite = "ImportOverwrite",
	Unsaved = "Unsaved",
	Leave = "Leave",
	RemoveMember = "RemoveMember",
	Invite = "Invite"
}

local SEVEN_DAY_SECONDS = 604800
local SEVEN_DAY_CONFIRM_PREF_KEY_PREFIX = "PhotographyStudioSevenDayConfirm_"
local STUDIO_COVER_KEY_PREFIX = "photographyStudioCover_"
local STUDIO_UID_PREFIX = "photographystudio_"
local INITIAL_STUDIO_CAMERA_POSITION = {
	z = 2.92,
	y = 0.8450012,
	x = 0
}
local INITIAL_STUDIO_CAMERA_ROTATION = {
	z = 0,
	y = -180,
	x = 0.89
}
local INITIAL_STUDIO_CAMERA_FOV = 5
local studioCoverCache = {}
local studioCoverLoading = {}
local studioCoverRequestSerial = {}

local function compareDefaultStudioInfo(a, b)
	if a.isMine ~= b.isMine then
		return a.isMine
	end

	if a.isMine and a.slotId ~= b.slotId then
		return (a.slotId or math.huge) < (b.slotId or math.huge)
	end

	return tostring(a.studioUid) < tostring(b.studioUid)
end

function PhotographyStudioUtils.checkFunctionEnabled(needNotify)
	local functionName = FunctionEnum.PHOTOGRAPHYSTUDIO

	if pg.me:isFunctionAndSwitchEnable(functionName) then
		return true
	end

	if not needNotify then
		return false
	end

	if CommonSwitch[functionName] == false then
		pg.global.ui.tips:showTextTip(pg.getGameString("FUNCTIONAL_MAINTENANCE"))

		return false
	end

	local config = FuncIdConfigData[functionName]

	if config and config.unlockDesc then
		pg.global.ui.tips:showTextTip(pg.getLocalizationText(config.unlockDesc))
	else
		pg.global.ui.tips:showTextTip(pg.getGameString("FUNCTION_NOT_OPEN"))
	end

	return false
end

function PhotographyStudioUtils.getPhotographyStudioShareCode(studioUid)
	if type(studioUid) ~= "string" then
		return nil
	end

	if string.sub(studioUid, 1, #STUDIO_UID_PREFIX) == STUDIO_UID_PREFIX then
		return string.sub(studioUid, #STUDIO_UID_PREFIX + 1)
	end

	return studioUid
end

function PhotographyStudioUtils.getPhotographyStudioUidByShareCode(code)
	if type(code) ~= "string" or code == "" then
		return nil
	end

	if string.match(code, "^photographystudio_%w+$") then
		return code
	end

	if string.match(code, "^%w+$") then
		return STUDIO_UID_PREFIX .. code
	end

	return nil
end

function PhotographyStudioUtils.genPhotographyStudioCoverImageId(studioUid)
	if studioUid == nil or studioUid == "" then
		return nil
	end

	return STUDIO_COVER_KEY_PREFIX .. tostring(studioUid)
end

function PhotographyStudioUtils.getDefaultPhotographyStudioUid()
	if not pg.me then
		return nil
	end

	local studioInfos = {}
	local studios = pg.me:getAllStudios() or {}

	for studioUid, info in pairs(studios) do
		if info then
			studioInfos[#studioInfos + 1] = {
				studioUid = tostring(studioUid),
				isMine = tostring(info.masterUid) == tostring(pg.me.uid),
				slotId = info.slotId
			}
		end
	end

	table.sort(studioInfos, compareDefaultStudioInfo)

	return studioInfos[1] and studioInfos[1].studioUid or nil
end

local function destroyStudioCoverSprite(sprite)
	if sprite then
		pg.global.mobileCameraMgr:DestroySpriteTexture(sprite)
	end
end

function PhotographyStudioUtils.loadPhotographyStudioCover(studioUid, coverVersion, callback)
	local coverImageId = PhotographyStudioUtils.genPhotographyStudioCoverImageId(studioUid)
	local version = tonumber(coverVersion)

	if not coverImageId or not version or version <= 0 then
		if callback then
			callback(nil, false)
		end

		return
	end

	local cached = studioCoverCache[studioUid]

	if cached and cached.version == version then
		if callback then
			callback(cached.sprite, true)
		end

		return
	end

	local loading = studioCoverLoading[studioUid]

	if loading and loading.version == version then
		if callback then
			loading.callbacks[#loading.callbacks + 1] = callback
		end

		return
	end

	local callbacks = {}

	if callback then
		callbacks[1] = callback
	end

	local serial = (studioCoverRequestSerial[studioUid] or 0) + 1

	studioCoverRequestSerial[studioUid] = serial
	studioCoverLoading[studioUid] = {
		version = version,
		serial = serial,
		callbacks = callbacks
	}

	ClientUtils.pullPicture(coverImageId, function(_, sprite)
		local currentLoading = studioCoverLoading[studioUid]

		if not currentLoading or currentLoading.serial ~= serial then
			destroyStudioCoverSprite(sprite)

			return
		end

		studioCoverLoading[studioUid] = nil

		if sprite then
			local oldCached = studioCoverCache[studioUid]

			if oldCached and oldCached.sprite ~= sprite then
				destroyStudioCoverSprite(oldCached.sprite)
			end

			studioCoverCache[studioUid] = {
				version = version,
				sprite = sprite
			}
		end

		for _, cb in ipairs(currentLoading.callbacks) do
			cb(sprite, sprite ~= nil)
		end
	end)
end

function PhotographyStudioUtils.invalidatePhotographyStudioCover(studioUid)
	if studioUid == nil then
		return
	end

	studioCoverRequestSerial[studioUid] = (studioCoverRequestSerial[studioUid] or 0) + 1
	studioCoverLoading[studioUid] = nil

	local cached = studioCoverCache[studioUid]

	if cached then
		destroyStudioCoverSprite(cached.sprite)

		studioCoverCache[studioUid] = nil
	end
end

function PhotographyStudioUtils.clearPhotographyStudioCoverCache()
	for _, cached in pairs(studioCoverCache) do
		destroyStudioCoverSprite(cached.sprite)
	end

	table.clear(studioCoverCache)
	table.clear(studioCoverLoading)
	table.clear(studioCoverRequestSerial)
end

function PhotographyStudioUtils.showSevenDayConfirm(confirmType, title, desc, okCb)
	local prefsKey = SEVEN_DAY_CONFIRM_PREF_KEY_PREFIX .. confirmType
	local lastConfirmTime = pg.global.prefsCacheUtils:getInt(prefsKey, 0, ClientConst.CACHE_TYPE_FLAG.USER)

	if lastConfirmTime + SEVEN_DAY_SECONDS > Time.secondCache then
		okCb()

		return
	end

	local hideForSevenDays = false

	pg.global.showConfirmMsgRaw(title, desc, function()
		if hideForSevenDays then
			pg.global.prefsCacheUtils:setInt(prefsKey, Time.secondCache, ClientConst.CACHE_TYPE_FLAG.USER)
			pg.global.prefsCacheUtils:save()
		end

		okCb()
	end, nil, nil, nil, nil, {
		hint = true,
		hintDesc = string.format(pg.getGameString("DISABLE_HINT"), 7),
		hintCb = function(isSelected)
			hideForSevenDays = isSelected
		end
	})
end

function PhotographyStudioUtils.showLockedAssetTip(assetId, targetRect)
	if assetId == nil then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
		id = assetId,
		targetRect = targetRect
	})
end

function PhotographyStudioUtils.bindTabEnterFirstItem(button, targetList)
	function button.luaClick()
		if not pg.game.input:isUsingGamepad() or not button.isSelected then
			return
		end

		local success, firstButton = targetList:TryGetChildAt(0)

		if success then
			pg.global.navMgr:PushFocusItem(firstButton)
		end
	end
end

function PhotographyStudioUtils.filterLockedStudioAssets(content, isBackgroundUnlocked)
	if type(content) ~= "table" then
		return content, {}
	end

	local filteredContent = Utils.deepCopyTable(content)
	local common = filteredContent.common
	local lockedAssetIds = {}
	local lockedAssetSet = {}

	local function addLockedAsset(assetId)
		assetId = tonumber(assetId)

		if not assetId or assetId <= 0 or lockedAssetSet[assetId] then
			return
		end

		lockedAssetSet[assetId] = true
		lockedAssetIds[#lockedAssetIds + 1] = assetId
	end

	local function isPhotoAssetUnlocked(assetId, configData)
		assetId = tonumber(assetId)

		if not assetId or assetId <= 0 then
			return true
		end

		if configData and configData.initialClaim == 1 then
			return true
		end

		return pg.me:isPhotoUnlock(assetId)
	end

	if type(common) == "table" then
		local backgroundId = tonumber(common.backgroundId)

		if backgroundId and backgroundId > 0 and isBackgroundUnlocked and not isBackgroundUnlocked(backgroundId) then
			addLockedAsset(backgroundId)

			common.backgroundId = nil
		end

		local filterId = tonumber(common.filterId)

		if filterId and filterId > 0 and not isPhotoAssetUnlocked(filterId, FilterData[filterId]) then
			addLockedAsset(filterId)

			common.filterId = nil
			common.filterValue = nil
		end

		local lightId = tonumber(common.lightId)

		if lightId and lightId > 0 and not isPhotoAssetUnlocked(lightId, LightingData[lightId]) then
			addLockedAsset(lightId)

			common.lightId = nil
			common.lightValue = nil
		end

		if type(common.diyInfo) == "table" then
			local diyInfo = {}

			for _, data in ipairs(common.diyInfo) do
				local assetId = type(data) == "table" and tonumber(data.id)

				if assetId and not isPhotoAssetUnlocked(assetId, DIYData[assetId]) then
					addLockedAsset(assetId)
				else
					diyInfo[#diyInfo + 1] = data
				end
			end

			common.diyInfo = diyInfo
		end

		if type(common.ornaments) == "table" then
			local ornaments = {}

			for _, data in ipairs(common.ornaments) do
				local assetId = type(data) == "table" and tonumber(data.ornamentId)

				if assetId and not isPhotoAssetUnlocked(assetId, OrnamentData[assetId]) then
					addLockedAsset(assetId)
				else
					ornaments[#ornaments + 1] = data
				end
			end

			common.ornaments = ornaments
		end
	end

	table.sort(lockedAssetIds)

	return filteredContent, lockedAssetIds
end

function PhotographyStudioUtils.buildStudioPetEntityId(ownerUid, petId)
	if ownerUid == nil or petId == nil then
		return nil
	end

	return PhotographyStudioUtils.STUDIO_PET_KEY_PREFIX .. tostring(ownerUid) .. "_" .. tostring(petId)
end

function PhotographyStudioUtils.parseStudioPetEntityId(entityId)
	if type(entityId) ~= "string" then
		return nil, nil
	end

	local prefix = PhotographyStudioUtils.STUDIO_PET_KEY_PREFIX

	if string.sub(entityId, 1, string.len(prefix)) ~= prefix then
		return nil, nil
	end

	local body = string.sub(entityId, string.len(prefix) + 1)
	local separatorIndex = string.find(body, "_", 1, true)

	if separatorIndex == nil then
		return nil, nil
	end

	local ownerUid = string.sub(body, 1, separatorIndex - 1)
	local petId = string.sub(body, separatorIndex + 1)

	if ownerUid == "" or petId == "" then
		return nil, nil
	end

	return ownerUid, petId
end

local APPEARANCE_SLOT_RANGES = {
	{
		AppearancePointEnum.Coat,
		AppearancePointEnum.Shoes
	},
	{
		AppearancePointEnum.Fringe,
		AppearancePointEnum.Plait
	},
	{
		AppearancePointEnum.Jewelry1,
		AppearancePointEnum.Jewelry10
	}
}

function PhotographyStudioUtils.serializeAppearance(entity)
	local map = {}

	if not entity or not entity.getAppearanceConfigId then
		return map
	end

	for _, range in ipairs(APPEARANCE_SLOT_RANGES) do
		for slotId = range[1], range[2] do
			local configId = entity:getAppearanceConfigId(slotId, true, true)

			if configId and configId ~= 0 then
				map[slotId] = configId
			end
		end
	end

	return map
end

function PhotographyStudioUtils.serializeUsableAppearance(entity)
	local list = {}

	if not entity or not entity.getAppearanceConfigId then
		return list
	end

	local appearanceInfo = pg.me and pg.me.appearanceInfo

	for _, range in ipairs(APPEARANCE_SLOT_RANGES) do
		for slotId = range[1], range[2] do
			local configId = entity:getAppearanceConfigId(slotId, true, true)
			local actualConfigId = entity:getAppearanceConfigId(slotId, false, true)

			if configId ~= actualConfigId and configId and configId ~= 0 and appearanceInfo and appearanceInfo[configId] == nil then
				configId = actualConfigId
			end

			if configId and configId ~= 0 then
				list[#list + 1] = {
					s = slotId,
					c = configId
				}
			end
		end
	end

	return list
end

function PhotographyStudioUtils.hasUnownedAppearancePreview(entity)
	if not entity or not entity.getAppearanceConfigId or not pg.me or not pg.me.appearanceInfo then
		return false
	end

	for _, range in ipairs(APPEARANCE_SLOT_RANGES) do
		for slotId = range[1], range[2] do
			local previewConfigId = entity:getAppearanceConfigId(slotId, true, true)
			local actualConfigId = entity:getAppearanceConfigId(slotId, false, true)

			if previewConfigId ~= actualConfigId and previewConfigId and previewConfigId ~= 0 and pg.me.appearanceInfo[previewConfigId] == nil then
				return true
			end
		end
	end

	return false
end

function PhotographyStudioUtils.clearUnownedAppearancePreview(entity)
	if not PhotographyStudioUtils.hasUnownedAppearancePreview(entity) then
		return false
	end

	if entity.customShowPreview then
		table.clear(entity.customShowPreview)
	end

	entity.previewOutfitId = nil

	return true
end

function PhotographyStudioUtils.serializeAppearanceFromCustomShow(customShow)
	local list = {}

	if type(customShow) ~= "table" then
		return list
	end

	for _, range in ipairs(APPEARANCE_SLOT_RANGES) do
		for slotId = range[1], range[2] do
			local configId = customShow[slotId]

			if configId and configId ~= 0 then
				list[#list + 1] = {
					s = slotId,
					c = configId
				}
			end
		end
	end

	return list
end

function PhotographyStudioUtils.appearanceArrayToMap(list)
	local map = {}

	if type(list) ~= "table" then
		return map
	end

	for _, item in ipairs(list) do
		local slotId = tonumber(item.s)
		local configId = tonumber(item.c)

		if slotId and configId and configId ~= 0 then
			map[slotId] = configId
		end
	end

	return map
end

function PhotographyStudioUtils.applyAppearanceMapToCurShow(curShow, appearanceMap)
	if not curShow then
		return
	end

	local customShow = curShow.customShow

	if type(customShow) ~= "table" then
		customShow = {}
		curShow.customShow = customShow
	end

	for _, range in ipairs(APPEARANCE_SLOT_RANGES) do
		for slotId = range[1], range[2] do
			customShow[slotId] = nil
		end
	end

	if type(appearanceMap) == "table" then
		for slotId, configId in pairs(appearanceMap) do
			customShow[slotId] = configId
		end
	end
end

function PhotographyStudioUtils.toRawTable(data)
	if not data then
		return nil
	end

	if data.getRawTable then
		return data:getRawTable()
	end

	if type(data) == "table" then
		return data
	end

	return nil
end

local function copyJsonSafeTable(data)
	if type(data) ~= "table" then
		return data
	end

	local count = 0
	local maxIndex = 0
	local isArray = true

	for key in pairs(data) do
		if type(key) ~= "number" or key < 1 or key % 1 ~= 0 then
			isArray = false

			break
		end

		count = count + 1
		maxIndex = math.max(maxIndex, key)
	end

	isArray = isArray and count == maxIndex

	local result = {}

	for key, value in pairs(data) do
		local resultKey = key

		if not isArray and type(key) == "number" then
			resultKey = tostring(key)
		end

		result[resultKey] = copyJsonSafeTable(value)
	end

	return result
end

function PhotographyStudioUtils.serializeJsonSafeTable(data)
	local rawTable = PhotographyStudioUtils.toRawTable(data)

	if type(rawTable) ~= "table" then
		return nil
	end

	return copyJsonSafeTable(rawTable)
end

function PhotographyStudioUtils.serializePetJewelryInfo(data, petId)
	local rawTable = PhotographyStudioUtils.toRawTable(data)

	if type(rawTable) ~= "table" then
		return nil
	end

	local result = copyJsonSafeTable(rawTable)

	if petId == nil or type(rawTable.customPresets) ~= "table" then
		return result
	end

	for slot, accessoryId in pairs(rawTable.customPresets) do
		local savedTransform = PetJewelryOssCache.get(petId, accessoryId)

		if savedTransform then
			result[tostring(slot)] = copyJsonSafeTable(savedTransform)
		end
	end

	return result
end

function PhotographyStudioUtils.normalizeNumberKeyTable(data)
	if type(data) ~= "table" then
		return data
	end

	local numberKeys

	for key, value in pairs(data) do
		PhotographyStudioUtils.normalizeNumberKeyTable(value)

		if type(key) == "string" then
			local numberKey = tonumber(key)

			if numberKey then
				numberKeys = numberKeys or {}
				numberKeys[#numberKeys + 1] = {
					key = key,
					numberKey = numberKey,
					value = value
				}
			end
		end
	end

	if numberKeys then
		for _, item in ipairs(numberKeys) do
			data[item.numberKey] = item.value
			data[item.key] = nil
		end
	end

	return data
end

function PhotographyStudioUtils.deserializeJsonSafeTable(data)
	if type(data) ~= "table" then
		return data
	end

	return PhotographyStudioUtils.normalizeNumberKeyTable(Utils.deepCopyTable(data))
end

function PhotographyStudioUtils.applyAppearance(entity, appearanceMap)
	if not entity or not entity.setCustomShow then
		return
	end

	appearanceMap = appearanceMap or {}

	for _, range in ipairs(APPEARANCE_SLOT_RANGES) do
		for slotId = range[1], range[2] do
			entity:cancelCustomShow(slotId, true)
		end
	end

	for slotId, configId in pairs(appearanceMap) do
		if configId and configId ~= 0 then
			entity:setCustomShow(configId, true, slotId)
		end
	end

	if entity.refreshAppearance and entity.eModel then
		entity:refreshAppearance()
	end
end

function PhotographyStudioUtils.renderReadonlyDIY(view, root, diyInfo, objs, ignoreUnlock)
	if type(objs) ~= "table" then
		objs = {}
	end

	local keepInstanceUids = {}

	local function renderOne(data, index)
		if not data or not data.id or not data.position or not ignoreUnlock and not pg.me:isPhotoUnlock(data.id) then
			return
		end

		local cfg = DIYData[data.id]

		if not cfg then
			return
		end

		local instanceUid = type(data) == "table" and data.instanceUid

		if instanceUid == nil or tostring(instanceUid) == "" then
			instanceUid = string.format("legacy_%s_%s", tostring(data.id), tostring(index))
		else
			instanceUid = tostring(instanceUid)
		end

		local obj = objs[instanceUid]

		if IsNil(obj) and view and NotNil(root) then
			local objInfo = view:addPrefabWithPathSync(root, AddressDataConst.PHOTO_DIY_FRAME)

			obj = objInfo and objInfo.gameObject

			if NotNil(obj) then
				objs[instanceUid] = obj
			end
		end

		if IsNil(obj) then
			return
		end

		keepInstanceUids[instanceUid] = true

		local objectReference = obj:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local rootUButton = objectReference:GetRefValue("rootUButton")
		local btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
		local btnZoomUWidget = objectReference:GetRefValue("btnZoomUWidget")
		local btnRotateUButton = objectReference:GetRefValue("btnRotateUButton")

		iconUImage.url = cfg.res

		local rectTrans = obj:GetComponent("RectTransform")
		local scale = data.scale or 1

		rectTrans.anchoredPosition = Vector2(data.position.x, data.position.y)
		rectTrans.localRotation = Quaternion.Euler(0, 0, data.rotation or 0)
		rectTrans.localScale = Vector3(scale, scale, scale)

		btnCloseUButton:SetActive(false)
		btnZoomUWidget:SetActive(false)
		btnRotateUButton:SetActive(false)
		rootUButton:TryChangePage("Status", 1)

		rootUButton.interactable = false
		rootUButton.draggable = false

		obj.transform:SetAsLastSibling()
	end

	if type(diyInfo) == "userdata" then
		for i = 0, diyInfo.Count - 1 do
			renderOne(diyInfo[i], i + 1)
		end
	elseif type(diyInfo) == "table" then
		for i = 1, #diyInfo do
			renderOne(diyInfo[i], i)
		end
	end

	for instanceUid, obj in pairs(objs) do
		if not keepInstanceUids[instanceUid] then
			if view and NotNil(obj) then
				view:destroyInstance(obj)
			end

			objs[instanceUid] = nil
		end
	end

	return objs
end

function PhotographyStudioUtils.clearReadonlyDIY(view, objs)
	if not view or type(objs) ~= "table" then
		return
	end

	for _, obj in pairs(objs) do
		if NotNil(obj) then
			view:destroyInstance(obj)
		end
	end
end

function PhotographyStudioUtils.applyPostProcessingToCamera(mode, common, ignoreUnlock)
	if not mode or not mode.cameraMode then
		return
	end

	common = common or {}

	local cameraMode = mode.cameraMode

	cameraMode:SetExposure(common.exposure or 0)
	cameraMode:SetSaturation(common.saturation or 0)
	cameraMode:SetBrightness(common.brightness or 0)
	cameraMode:SetContrast(common.contrast or 0)
	cameraMode:SetVignette((common.vignette or 0) + 0.2)

	if common.filterId and (ignoreUnlock or pg.me:isPhotoUnlock(common.filterId)) then
		local filterData = FilterData[tonumber(common.filterId)]

		if filterData then
			cameraMode:SetLUT(filterData.res)
			cameraMode:SetLUTIntensity(common.filterValue)
		else
			cameraMode:clearLUT()
		end
	else
		cameraMode:clearLUT()
	end
end

function PhotographyStudioUtils.applyCustomLightingToCamera(cameraMode, slot, savedScheme)
	slot = tonumber(slot)

	if not slot or slot < 1 or not cameraMode.ApplyDiyCameraLight then
		return false
	end

	local scheme

	if type(savedScheme) == "table" then
		scheme = PhotoLightDiyModel:normalizeScheme(slot, Utils.deepCopyTable(savedScheme))
	else
		local count = pg.me and tonumber(pg.me.photoLightSchemeCount) or 0

		if count < slot then
			return false
		end

		scheme = PhotoLightDiyModel:normalizeScheme(slot, pg.me:getPhotoLightScheme(slot))
	end

	for lightIndex = 1, PhotoLightDiyModel.LightCount do
		local lightData = scheme.lights[lightIndex]

		if type(lightData) ~= "table" or type(lightData.color) ~= "table" then
			return false
		end
	end

	cameraMode:HiddenCameraLight()

	for lightIndex = 1, PhotoLightDiyModel.LightCount do
		local lightData = scheme.lights[lightIndex]
		local color = lightData.color

		if cameraMode.ApplyDiyCameraLightTransform then
			cameraMode:ApplyDiyCameraLightTransform(lightIndex, lightData.distance, lightData.height, lightData.direction, lightData.tilt)
		end

		cameraMode:ApplyDiyCameraLight(lightIndex, lightData.enabled, lightData.intensity, color.r, color.g, color.b, lightData.colorIntensity)
	end

	return true
end

function PhotographyStudioUtils.applyLightingToCamera(mode, common, ignoreUnlock)
	if not mode or not mode.cameraMode then
		return false
	end

	common = common or {}

	local cameraMode = mode.cameraMode

	if common.customLightSlot ~= nil then
		if common.lightValue ~= nil then
			cameraMode.lightIntensityRate = tonumber(common.lightValue) or 1
		end

		if PhotographyStudioUtils.applyCustomLightingToCamera(cameraMode, common.customLightSlot, common.customLightScheme) then
			return true
		end
	end

	if cameraMode.HiddenDiyCameraLight then
		cameraMode:HiddenDiyCameraLight()
	end

	local lightId = tonumber(common.lightId)
	local lightData = lightId and LightingData[lightId]

	if lightData and (ignoreUnlock or pg.me:isPhotoUnlock(lightId)) then
		cameraMode.lightIntensityRate = tonumber(common.lightValue) or 1

		cameraMode:ApplyCameraLight(lightData.res)

		return true
	else
		cameraMode:HiddenCameraLight()

		return false
	end
end

function PhotographyStudioUtils.applyCommonToCamera(mode, common, ignoreUnlock)
	if not mode or not mode.cameraMode then
		return
	end

	common = common or {}

	if common.fov ~= nil then
		local curve = pg.global.cameraMgr.vcManager:GetPhotoCameraZoomUpdateCurve()

		mode:zoom(curve and curve:Evaluate(common.fov) or common.fov)
	end

	mode:rotateZ(common.rotate or 0)
	PhotographyStudioUtils.applyPostProcessingToCamera(mode, common, ignoreUnlock)

	return PhotographyStudioUtils.applyLightingToCamera(mode, common, ignoreUnlock)
end

function PhotographyStudioUtils.ensureInitialCameraPreset(content)
	if type(content) ~= "table" or content.version ~= nil then
		return type(content) == "table" and content.common or nil
	end

	local common = content.common

	if type(common) ~= "table" then
		common = {}
		content.common = common
	end

	if type(common.cameraPos) ~= "table" then
		common.cameraPos = {
			x = INITIAL_STUDIO_CAMERA_POSITION.x,
			y = INITIAL_STUDIO_CAMERA_POSITION.y,
			z = INITIAL_STUDIO_CAMERA_POSITION.z
		}
	end

	if type(common.cameraRot) ~= "table" then
		common.cameraRot = {
			x = INITIAL_STUDIO_CAMERA_ROTATION.x,
			y = INITIAL_STUDIO_CAMERA_ROTATION.y,
			z = INITIAL_STUDIO_CAMERA_ROTATION.z
		}
	end

	if common.fov == nil then
		common.fov = INITIAL_STUDIO_CAMERA_FOV
	end

	return common
end

function PhotographyStudioUtils.packContent(masterUid, common, playersMap)
	return {
		version = PhotographyStudioUtils.CONTENT_VERSION,
		masterUid = masterUid,
		common = common or {},
		players = playersMap or {}
	}
end

function PhotographyStudioUtils.unpackContent(content)
	if type(content) ~= "table" then
		return {}, {}, nil, nil
	end

	return content.common or {}, content.players or {}, content.version, content.masterUid
end

function PhotographyStudioUtils.getPlayerSegment(content, uid)
	if type(content) ~= "table" or type(content.players) ~= "table" then
		return nil
	end

	return content.players[uid]
end

function PhotographyStudioUtils.buildPlayerSegment(info)
	info = info or {}

	return {
		pos = info.pos,
		rot = info.rot,
		poseId = info.poseId,
		gazeType = info.gazeType,
		visible = info.visible,
		appearance = info.appearance,
		model = info.model,
		pets = info.pets
	}
end

function PhotographyStudioUtils.serializePlayerModel(entity)
	if not entity then
		return nil
	end

	return {
		avatarConfig = entity.avatarConfig,
		avatarPresetKey = entity.avatarPresetKey,
		templateId = entity.templateId
	}
end

return PhotographyStudioUtils
