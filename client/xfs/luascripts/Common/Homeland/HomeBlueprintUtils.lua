-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Homeland\\HomeBlueprintUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local HomelandConfigData = require("Data.homeland_config_data")
local HomeObjectData = require("Data.home_object_data")
local HomeBlueprintConst = require("Common.Const.HomeBlueprintConst")
local Utils = require("Common.Utils.Utils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomeBlueprintUtils = {}
local CODE_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
local CODE_LENGTH = 8
local CODE_BITS = CODE_LENGTH * 5
local HALF_BITS = CODE_BITS / 2
local HALF_DOMAIN = 2^HALF_BITS
local HALF_MASK = HALF_DOMAIN - 1
local CODE_DOMAIN = 2^CODE_BITS
local ROUND_KEYS = {
	4946461,
	7155292,
	2046585,
	8277035
}
local KNUTH_CONST = 2654435761

HomeBlueprintUtils.MAX_CODE_SEQ = CODE_DOMAIN

local bit = bit
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot
local rshift = bit.rshift
local math_floor = math.floor

local function _bxor(x, y)
	return band(bor(x, y), bor(bnot(x), bnot(y)))
end

local function _feistelRound(half, roundKey)
	local value = half * KNUTH_CONST + roundKey

	return band(rshift(value, 5), HALF_MASK)
end

local function _encodeBase32(value, length)
	local chars = {}
	local max = #CODE_CHARS

	for index = length, 1, -1 do
		local charIndex = value % max + 1

		chars[index] = CODE_CHARS:sub(charIndex, charIndex)
		value = math_floor(value / max)
	end

	return table.concat(chars)
end

local function _encryptCodeSeq(seq)
	local left = math_floor(seq / HALF_DOMAIN) % HALF_DOMAIN
	local right = seq % HALF_DOMAIN

	for index = 1, #ROUND_KEYS do
		local newRight = band(_bxor(left, _feistelRound(right, ROUND_KEYS[index])), HALF_MASK)

		left = right
		right = newRight
	end

	return left * HALF_DOMAIN + right
end

local function _getConfigValue(key, config)
	if config and config[key] ~= nil then
		return config[key]
	end

	return HomeBlueprintUtils.getConfig(key)
end

local function _copyArray(arr)
	local ret = {}

	for i, v in ipairs(arr or EMPTY_TABLE) do
		ret[i] = v
	end

	return ret
end

local function _subPos3(pos3, anchor)
	return {
		(pos3[1] or 0) - (anchor[1] or 0),
		(pos3[2] or 0) - (anchor[2] or 0),
		(pos3[3] or 0) - (anchor[3] or 0)
	}
end

local function _addPos3(pos3, anchor)
	return {
		(pos3[1] or 0) + (anchor[1] or 0),
		(pos3[2] or 0) + (anchor[2] or 0),
		(pos3[3] or 0) + (anchor[3] or 0)
	}
end

local function _rotateYaw(pos3, yawAngle)
	local rad = (yawAngle or 0) * 0.01 * math.pi / 180
	local cosv = math.cos(rad)
	local sinv = math.sin(rad)
	local x = pos3[1] or 0
	local y = pos3[2] or 0
	local z = pos3[3] or 0

	return {
		x * cosv + z * sinv,
		y,
		-x * sinv + z * cosv
	}
end

local function _normalizeExtraData(buildExtraData)
	buildExtraData = buildExtraData or {}

	return {
		attachData = buildExtraData.attachData or {},
		linkData = buildExtraData.linkData or {}
	}
end

local function _textLen(text)
	if string.strlen then
		return string.strlen(text)
	end

	return #text
end

function HomeBlueprintUtils.getConfig(key)
	local value = HomelandConfigData[key]

	if value ~= nil then
		return value
	end

	return HomeBlueprintConst.DEFAULT_CONFIG[key]
end

function HomeBlueprintUtils.validateCoverImageKeys(coverImageKeys, config)
	if coverImageKeys == nil then
		return true, {}
	end

	if type(coverImageKeys) ~= "table" then
		return false, "invalid_cover_image_keys"
	end

	local ret = {}

	for _, imageKey in ipairs(coverImageKeys) do
		if type(imageKey) ~= "string" or imageKey == "" then
			return false, "invalid_cover_image_key"
		end

		ret[#ret + 1] = imageKey
	end

	for key, _ in pairs(coverImageKeys) do
		if type(key) ~= "number" or key < 1 or key % 1 ~= 0 or key > #ret then
			return false, "invalid_cover_image_keys"
		end
	end

	local maxCount = _getConfigValue("maxBlueprintCoverImageCount", config)

	if maxCount and maxCount < #ret then
		return false, "too_many_cover_images"
	end

	return true, ret
end

local function _isUploadLimitConditionMet(player, condition)
	if condition == nil or condition == 0 then
		return true
	end

	if not player or not player.triggerMap or not player.triggerMap.isCompleteOrMeetCondition then
		return false
	end

	return player.triggerMap:isCompleteOrMeetCondition(condition) == true
end

local function _isUploadLimitExtraMatched(player, blueprintKind, extra)
	if type(extra) ~= "table" then
		return false
	end

	if extra.blueprintKind and extra.blueprintKind ~= blueprintKind then
		return false
	end

	if type(extra.conditions) == "table" then
		for _, condition in ipairs(extra.conditions) do
			if not _isUploadLimitConditionMet(player, condition) then
				return false
			end
		end

		return true
	end

	return _isUploadLimitConditionMet(player, extra.condition)
end

function HomeBlueprintUtils.getUploadBlueprintLimit(player, blueprintKind, config)
	local limit = tonumber(_getConfigValue("maxUploadBlueprintCount", config)) or 0
	local extra = player and tonumber(player.homeBlueprintUploadLimitExtra) or 0

	if extra and extra > 0 then
		limit = limit + extra
	end

	return limit
end

function HomeBlueprintUtils.getSavedOtherBlueprintLimit(player, config)
	local limit = tonumber(_getConfigValue("maxSavedOtherBlueprintCount", config)) or 0
	local extra = player and tonumber(player.homeBlueprintSaveLimitExtra) or 0

	if extra and extra > 0 then
		limit = limit + extra
	end

	return limit
end

function HomeBlueprintUtils.validateText(name, desc)
	if type(name) ~= "string" or name == "" then
		return false, "invalid_name"
	end

	if _textLen(name) > HomeBlueprintUtils.getConfig("maxBlueprintNameLength") then
		return false, "name_too_long"
	end

	if desc ~= nil and type(desc) ~= "string" then
		return false, "invalid_desc"
	end

	if _textLen(desc or "") > HomeBlueprintUtils.getConfig("maxBlueprintDescLength") then
		return false, "desc_too_long"
	end

	return true
end

function HomeBlueprintUtils.isCodeSeqEncodable(seq)
	return type(seq) == "number" and seq >= 0 and seq < CODE_DOMAIN
end

function HomeBlueprintUtils.encodeCodeFromSeq(seq)
	if not HomeBlueprintUtils.isCodeSeqEncodable(seq) then
		return nil
	end

	return _encodeBase32(_encryptCodeSeq(seq), CODE_LENGTH)
end

function HomeBlueprintUtils.countRequireItems(ornaments)
	local ret = {}

	for _, ornament in ipairs(ornaments or EMPTY_TABLE) do
		local homeId = ornament.homeId or ornament.itemNo

		if homeId then
			ret[homeId] = (ret[homeId] or 0) + 1
		end
	end

	return ret
end

function HomeBlueprintUtils.buildSnapshot(ornamentMap, buildExtraData, ornamentIdList, rootYawAngle)
	if type(ornamentIdList) ~= "table" or #ornamentIdList <= 0 then
		return false, "empty_selection"
	end

	local maxFurniture = HomeBlueprintUtils.getConfig("maxFurniturePerBlueprint")

	if maxFurniture and maxFurniture < #ornamentIdList then
		return false, "too_many_ornaments"
	end

	rootYawAngle = tonumber(rootYawAngle) or 0

	local selected = {}
	local sum = {
		0,
		0,
		0
	}
	local minY
	local ornamentPos3Map = {}

	for _, ornamentId in ipairs(ornamentIdList) do
		local ornament = ornamentMap and ornamentMap[ornamentId]

		if not ornament then
			return false, "ornament_missing"
		end

		selected[ornamentId] = true

		local posX, posY, posZ = ornament.posX, ornament.posY, ornament.posZ

		ornamentPos3Map[ornamentId] = {
			posX,
			posY,
			posZ
		}
		sum[1] = sum[1] + posX
		sum[3] = sum[3] + posZ

		if minY == nil or posY < minY then
			minY = posY
		end
	end

	local count = #ornamentIdList
	local anchor = {
		sum[1] / count,
		minY or 0,
		sum[3] / count
	}
	local clientIdByServerId = {}
	local ornaments = {}

	for idx, ornamentId in ipairs(ornamentIdList) do
		local ornament = ornamentMap[ornamentId]

		clientIdByServerId[ornamentId] = idx

		local relPos3 = _rotateYaw(_subPos3(ornamentPos3Map[ornamentId], anchor), -rootYawAngle)
		local rotX, rotY, rotZ = ornament.rotX, ornament.rotY, ornament.rotZ
		local relRot3 = {
			rotX,
			rotY,
			rotZ
		}

		relRot3[2] = ((tonumber(relRot3[2]) or 0) - rootYawAngle) % 36000

		local scaleX, scaleY, scaleZ = ornament.scaleX, ornament.scaleY, ornament.scaleZ

		ornaments[#ornaments + 1] = {
			clientOrnamentId = idx,
			homeId = ornament.homeId,
			relPos3 = relPos3,
			relRot3 = relRot3,
			scale3 = {
				scaleX,
				scaleY,
				scaleZ
			}
		}
	end

	local extraData = _normalizeExtraData(buildExtraData)
	local attachData = {}

	for childId, info in pairs(extraData.attachData) do
		if selected[childId] then
			local parentId = info.parentId

			if not parentId or parentId == 0 or selected[parentId] then
				attachData[clientIdByServerId[childId]] = {
					parentId = clientIdByServerId[parentId or 0] or 0,
					slotId = info.slotId or 0
				}
			end
		end
	end

	local linkData = {}

	for childId, info in pairs(extraData.linkData) do
		if selected[childId] then
			local parentId = info.parentId

			if not parentId or parentId == 0 or selected[parentId] then
				linkData[clientIdByServerId[childId]] = {
					parentId = clientIdByServerId[parentId or 0] or 0
				}
			end
		end
	end

	return true, {
		anchorPos3 = anchor,
		ornaments = ornaments,
		buildExtraData = {
			attachData = attachData,
			linkData = linkData
		}
	}
end

function HomeBlueprintUtils.toAbsoluteOrnaments(blueprint, targetPos3, targetYawAngle)
	local ret = {}

	for _, ornament in ipairs((blueprint or EMPTY_TABLE).ornaments or (blueprint or EMPTY_TABLE).furnitureData or EMPTY_TABLE) do
		local rotated = _rotateYaw(ornament.relPos3 or {
			0,
			0,
			0
		}, targetYawAngle or 0)
		local rot3 = _copyArray(ornament.relRot3 or {
			0,
			0,
			0
		})

		rot3[2] = (rot3[2] or 0) + (targetYawAngle or 0)

		local absPos3 = _addPos3(rotated, targetPos3 or {
			0,
			0,
			0
		})
		local scale3 = _copyArray(ornament.scale3 or {
			1000,
			1000,
			1000
		})

		ret[#ret + 1] = {
			clientOrnamentId = ornament.clientOrnamentId,
			homeId = ornament.homeId or ornament.itemNo,
			areaId = ornament.areaId,
			posX = absPos3[1],
			posY = absPos3[2],
			posZ = absPos3[3],
			rotX = rot3[1],
			rotY = rot3[2],
			rotZ = rot3[3],
			scaleX = scale3[1],
			scaleY = scale3[2],
			scaleZ = scale3[3]
		}
	end

	return ret
end

function HomeBlueprintUtils.buildSystemBlueprintData(systemData)
	local ret = {}

	for blueprintId, blueprint in pairs(systemData or EMPTY_TABLE) do
		local doc = HomeBlueprintUtils.cloneBlueprintDoc(blueprint)
		local furnitureData = type(doc) == "table" and (doc.furnitureData or doc.ornaments) or nil

		if type(furnitureData) == "table" then
			local ornaments = {}
			local loadValue = 0
			local comfortValue = 0

			for index, ornamentInfo in ipairs(furnitureData) do
				local ornament = HomeBlueprintUtils.cloneBlueprintDoc(ornamentInfo)

				ornament.clientOrnamentId = ornament.clientOrnamentId or index
				ornaments[#ornaments + 1] = ornament

				local homeData = HomeObjectData[ornament.homeId] or {}

				loadValue = loadValue + (tonumber(homeData.loadValue) or 0)
				comfortValue = comfortValue + (tonumber(homeData.comfortValue) or 0)
			end

			doc.ornaments = ornaments
			doc.loadValue = loadValue
			doc.comfortValue = comfortValue
			doc._id = blueprintId
			doc.size = doc.size or {}
			ret[blueprintId] = doc
		end
	end

	return ret
end

function HomeBlueprintUtils.remapBuildExtraData(buildExtraData, idMap)
	local extraData = _normalizeExtraData(buildExtraData)
	local ret = {
		attachData = {},
		linkData = {}
	}

	for childId, info in pairs(extraData.attachData) do
		local realChildId = idMap[childId]

		if realChildId then
			local parentId = info.parentId or 0

			ret.attachData[realChildId] = {
				parentId = idMap[parentId] or 0,
				slotId = info.slotId or 0
			}
		end
	end

	for childId, info in pairs(extraData.linkData) do
		local realChildId = idMap[childId]

		if realChildId then
			local parentId = info.parentId or 0

			ret.linkData[realChildId] = {
				parentId = idMap[parentId] or 0
			}
		end
	end

	return ret
end

function HomeBlueprintUtils.cloneBlueprintDoc(blueprint)
	return Utils.deepCopyTable(blueprint or {})
end

function HomeBlueprintUtils.parseYawUpdates(buildExtraData, groupInfoList, allowLegacy)
	local rawUpdates = buildExtraData and buildExtraData.homeBlueprintGroupInfoList

	if rawUpdates == nil and allowLegacy and buildExtraData and buildExtraData.homeBlueprintGroupInfo ~= nil then
		rawUpdates = {
			buildExtraData.homeBlueprintGroupInfo
		}
	end

	if rawUpdates == nil then
		return {}
	end

	if type(rawUpdates) ~= "table" then
		return nil
	end

	local updateCount = 0

	for index in pairs(rawUpdates) do
		if type(index) ~= "number" or index <= 0 or index ~= math.floor(index) then
			return nil
		end

		updateCount = updateCount + 1
	end

	local updates = {}

	for index = 1, updateCount do
		local updateInfo = rawUpdates[index]
		local groupIndex = type(updateInfo) == "table" and tonumber(updateInfo.groupIndex) or nil
		local yawAngle = type(updateInfo) == "table" and tonumber(updateInfo.yawAngle) or nil

		if not groupIndex or groupIndex <= 0 or groupIndex ~= math.floor(groupIndex) or not yawAngle or yawAngle ~= math.floor(yawAngle) or not groupInfoList or not groupInfoList[groupIndex] then
			return nil
		end

		updates[groupIndex] = yawAngle
	end

	return updates
end

return HomeBlueprintUtils
