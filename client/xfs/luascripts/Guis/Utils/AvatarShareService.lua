-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Utils\\AvatarShareService.lua

local GlobalData = require("Core.Client.GlobalData")
local TimerManager = require("Core.Timer.TimerManager")
local ServiceUtils = require("Common.Utils.ServiceUtils")
local ClientUtils = require("Utils.ClientUtils")
local ClientModelUtils = require("Utils.ClientModelUtils")
local AppearanceEffectUtils = require("Utils.AppearanceEffectUtils")
local UIConst = require("Const.UIConst")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local AppearancePointEnum = require("Data.appearance_point_enum")
local Utils = require("Common.Utils.Utils")
local ItemUtils = require("Common.Utils.ItemUtils")
local json = require("json")
local LuaUIUtils = require("Utils.LuaUIUtils")
local AvatarHairSuitData = require("Data.avatar_hair_suit_data")
local AppearanceMakeupPresetData = require("Data.appearance_makeup_preset_data")
local AppearanceData = require("Data.appearance_data")
local md5 = require("md5")
local avatarMgr = pg.global.avatarMgr
local AvatarShareService = {}

AvatarShareService.SHARE_TYPE = {
	HAIR = "hair",
	CLOTHES = "clothes",
	FACE = "face"
}

local UPLOAD_VERIFY_MAX_RETRY = 5
local UPLOAD_VERIFY_INTERVAL = 0.5
local BUILD_SHARE_ID_MAX_RETRY = 10
local SHARE_ID_PATTERN = ".-%-face%-.-"
local SHORT_SHARE_ID_LEN = 16
local SHORT_SHARE_ID_PATTERN = "^[0-9A-F]+$"
local shareIdSeq = 0
local lastPreviewShareType = AvatarShareService.SHARE_TYPE.FACE
local originClothesSnapshot
local CLOTHES_SHARE_LOG = "[ClothesShare]"

local function logClothesShare(fmt, ...)
	if select("#", ...) > 0 then
		print(string.format("%s %s", CLOTHES_SHARE_LOG, string.format(fmt, ...)))
	else
		print(CLOTHES_SHARE_LOG .. " " .. tostring(fmt))
	end
end

local function summarizeStainUnit(stainUnit)
	if not stainUnit then
		return "nil"
	end

	local stainKeys = 0
	local decalKeys = 0

	if stainUnit.stainMatMap then
		for _ in pairs(stainUnit.stainMatMap) do
			stainKeys = stainKeys + 1
		end
	end

	if stainUnit.decalMatMap then
		for _ in pairs(stainUnit.decalMatMap) do
			decalKeys = decalKeys + 1
		end
	end

	return string.format("stainKeys=%d decalKeys=%d empty=%s", stainKeys, decalKeys, tostring(stainKeys == 0 and decalKeys == 0))
end

local function describePresetUnit(presetUnit)
	if presetUnit == nil then
		return "nil"
	end

	if presetUnit == false then
		return "false"
	end

	if presetUnit == true then
		return "true"
	end

	local rawOk, rawTable = pcall(function()
		return presetUnit.getRawTable and presetUnit:getRawTable() or presetUnit
	end)

	if not rawOk or not rawTable then
		return "invalid"
	end

	return string.format("isChange=%s stainMapEmpty=%s decalMapEmpty=%s", tostring(rawTable.isChange), tostring(string.isNilOrEmpty(rawTable.stainMatMap)), tostring(string.isNilOrEmpty(rawTable.decalMatMap)))
end

local function getShareType(customData)
	if not customData then
		return AvatarShareService.SHARE_TYPE.FACE
	end

	return customData.shareType or AvatarShareService.SHARE_TYPE.FACE
end

local function packHairCustomInfo(hairCustomStr)
	if string.isNilOrEmpty(hairCustomStr) then
		return nil
	end

	return compressToStr(hairCustomStr)
end

local function parseMakeupSuitIdFromAvatarConfig(avatarConfigCompressed)
	if string.isNilOrEmpty(avatarConfigCompressed) then
		return -1
	end

	local ok, configStr = pcall(decompressFromStr, avatarConfigCompressed)

	if not ok or string.isNilOrEmpty(configStr) then
		return -1
	end

	local decodeOk, config = pcall(json.decode, configStr)

	if not decodeOk or type(config) ~= "table" then
		return -1
	end

	local suitId = tonumber(config.makeupSuitId)

	if suitId and suitId > 0 then
		return suitId
	end

	return -1
end

local FACE_COMPARE_KEYS = {
	"templateId",
	"bodySize",
	"makeupSuitId",
	"facePartAssetId",
	"bodyPartAssetId",
	"makeupPartAssetId",
	"faceCustomData",
	"bodyCustomData",
	"makeupCustomData"
}
local FACE_COMPARE_FLOAT_EPS = 0.0001

local function decodeAvatarConfigTable(avatarConfig)
	if string.isNilOrEmpty(avatarConfig) then
		return nil
	end

	local decodeOk, config = pcall(json.decode, avatarConfig)

	if decodeOk and type(config) == "table" then
		return config
	end

	local ok, configStr = pcall(decompressFromStr, avatarConfig)

	if not ok or string.isNilOrEmpty(configStr) then
		return nil
	end

	decodeOk, config = pcall(json.decode, configStr)

	if decodeOk and type(config) == "table" then
		return config
	end

	return nil
end

local function isEmptyFaceValue(value)
	return value == nil or value == false or value == "" or value == 0 or value == -1 or type(value) == "table" and next(value) == nil
end

local function areFaceValuesEqual(lhs, rhs)
	if lhs == rhs then
		return true
	end

	if isEmptyFaceValue(lhs) and isEmptyFaceValue(rhs) then
		return true
	end

	if type(lhs) == "number" and type(rhs) == "number" then
		return math.abs(lhs - rhs) <= FACE_COMPARE_FLOAT_EPS
	end

	if type(lhs) ~= "table" or type(rhs) ~= "table" then
		return false
	end

	local keys = {}

	for k in pairs(lhs) do
		keys[k] = true
	end

	for k in pairs(rhs) do
		keys[k] = true
	end

	for k in pairs(keys) do
		if not areFaceValuesEqual(lhs[k], rhs[k]) then
			return false
		end
	end

	return true
end

local function isSameFaceAsWorldPlayer(importedCompressed)
	if not pg.me or string.isNilOrEmpty(importedCompressed) or string.isNilOrEmpty(pg.me.avatarConfig) then
		return false
	end

	local importedConfig = decodeAvatarConfigTable(importedCompressed)
	local worldConfig = decodeAvatarConfigTable(pg.me.avatarConfig)

	if not importedConfig or not worldConfig then
		return false
	end

	for _, key in ipairs(FACE_COMPARE_KEYS) do
		if not areFaceValuesEqual(importedConfig[key], worldConfig[key]) then
			return false
		end
	end

	return true
end

local function getImportTargetTemplateId()
	local _, entity = AvatarShareService.getAvatarContext()

	if entity and entity.templateId then
		return entity.templateId
	end

	if pg.me then
		return pg.me.templateId
	end

	return nil
end

function AvatarShareService.validateFaceImportPreconditions(customData)
	if not customData or not customData.avatarConfig then
		return false, "INVALID_ID"
	end

	local targetTemplateId = getImportTargetTemplateId()

	if targetTemplateId and customData.templateId and targetTemplateId ~= customData.templateId then
		return false, "INVALID_TEMPLATE_ID"
	end

	local suitId = parseMakeupSuitIdFromAvatarConfig(customData.avatarConfig)

	if not pg.me then
		if suitId > 0 then
			return false, "APPEARANCE_PAY_FAIL"
		end

		return true
	end

	if suitId <= 0 then
		return true
	end

	local preset = AppearanceMakeupPresetData[suitId]

	if not preset then
		return false, "INVALID_ID"
	end

	local showStatus = preset.showStatus or 1

	if showStatus == 3 and ItemUtils.getItemCountById(pg.me, suitId, true) <= 0 then
		return false, "APPEARANCE_PAY_FAIL"
	end

	return true
end

function AvatarShareService.validateHairImportPreconditions(customData)
	if not customData or not customData.hairData or not customData.hairData.customShow then
		return false, "INVALID_ID"
	end

	local targetTemplateId = getImportTargetTemplateId()

	if targetTemplateId and customData.templateId and targetTemplateId ~= customData.templateId then
		return false, "INVALID_TEMPLATE_ID"
	end

	local hairSuitId = tonumber(customData.hairSuitId)

	if (not hairSuitId or hairSuitId <= 0) and customData.hairData.customShow then
		hairSuitId = LuaUIUtils.tryGetHairSuitId(customData.hairData.customShow)
	end

	if not hairSuitId or hairSuitId <= 0 then
		return false, "INVALID_ID"
	end

	if not pg.me then
		local hairSuitInfo = AvatarHairSuitData[hairSuitId]

		if not hairSuitInfo or hairSuitInfo.preview ~= 1 then
			return false, "APPEARANCE_HAIR_NOT_OWNED"
		end

		return true
	end

	if not LuaUIUtils.isHairSuitClaimed(pg.me, hairSuitId) then
		return false, "APPEARANCE_HAIR_NOT_OWNED"
	end

	return true
end

local function deepCopyStainUnit(stainUnit)
	if not stainUnit then
		return {
			stainMatMap = {},
			decalMatMap = {}
		}
	end

	return {
		stainMatMap = Utils.deepCopyTable(stainUnit.stainMatMap or {}),
		decalMatMap = Utils.deepCopyTable(stainUnit.decalMatMap or {})
	}
end

local function buildUnitDesignWrapper(rawTable)
	return {
		getRawTable = function()
			return rawTable
		end
	}
end

local function isStainUnitEmpty(stainUnit)
	if not stainUnit then
		return true
	end

	local stainMap = stainUnit.stainMatMap
	local decalMap = stainUnit.decalMatMap

	return (not stainMap or not next(stainMap)) and (not decalMap or not next(decalMap))
end

local function getClothesDesignUnit(slotId)
	local _, entity = AvatarShareService.getAvatarContext()

	if entity and entity.curShow and entity.curShow.clothesDesigns then
		local unit = entity.curShow.clothesDesigns[slotId]

		if unit then
			return unit
		end
	end

	if pg.me and pg.me.curShow and pg.me.curShow.clothesDesigns then
		return pg.me.curShow.clothesDesigns[slotId]
	end

	return nil
end

local function captureClothesDesignRaw(slotId)
	local unit = getClothesDesignUnit(slotId)

	if not unit then
		return nil
	end

	local rawOk, rawTable = pcall(function()
		return unit:getRawTable()
	end)

	if rawOk and rawTable then
		return Utils.deepCopyTable(rawTable)
	end

	return nil
end

local function rawTableHasStain(raw)
	if not raw then
		return false
	end

	if raw.isChange == false then
		return false
	end

	if not string.isNilOrEmpty(raw.stainMatMap) then
		local ok, stainMap = pcall(function()
			return string.toTable(decompressFromStr(raw.stainMatMap))
		end)

		if ok and stainMap and next(stainMap) then
			return true
		end
	end

	if not string.isNilOrEmpty(raw.decalMatMap) then
		local ok, decalMap = pcall(function()
			return string.toTable(decompressFromStr(raw.decalMatMap))
		end)

		if ok and decalMap and next(decalMap) then
			return true
		end
	end

	return false
end

local function entityHadAppliedClothesStain(snapshot)
	if not snapshot then
		return false
	end

	if rawTableHasStain(snapshot.entityUnitRaw) then
		return true
	end

	local clothId = snapshot.clothId
	local appUnit = pg.me and pg.me.appearanceInfo and pg.me.appearanceInfo[clothId]

	return appUnit ~= nil and (appUnit.designIndex or 0) > 0
end

local function snapshotHadPriorStain(snapshot)
	if not snapshot then
		logClothesShare("snapshotHadPriorStain snapshot=nil -> false")

		return false
	end

	if snapshot.hadPriorStain ~= nil then
		logClothesShare("snapshotHadPriorStain cached=%s designIndex=%s entityRaw=%s workshop=%s", tostring(snapshot.hadPriorStain), tostring(pg.me and pg.me.appearanceInfo and pg.me.appearanceInfo[snapshot.clothId] and pg.me.appearanceInfo[snapshot.clothId].designIndex), tostring(snapshot.entityUnitRaw ~= nil), summarizeStainUnit(snapshot.workshopCurUnit))

		return snapshot.hadPriorStain
	end

	local hadApplied = entityHadAppliedClothesStain(snapshot)

	logClothesShare("snapshotHadPriorStain entityApplied=%s workshop=%s (workshop模板不计入)", tostring(hadApplied), summarizeStainUnit(snapshot.workshopCurUnit))

	return hadApplied
end

local function buildCurUnitFromPresetUnit(presetUnit)
	local curUnit = {
		stainMatMap = {},
		decalMatMap = {}
	}

	if not presetUnit or presetUnit == false or presetUnit == true then
		return curUnit
	end

	local rawTable = presetUnit.getRawTable and presetUnit:getRawTable() or presetUnit

	if rawTable and not string.isNilOrEmpty(rawTable.stainMatMap) then
		curUnit.stainMatMap = string.toTable(decompressFromStr(rawTable.stainMatMap))
	end

	if rawTable and not string.isNilOrEmpty(rawTable.decalMatMap) then
		curUnit.decalMatMap = string.toTable(decompressFromStr(rawTable.decalMatMap))
	end

	return curUnit
end

local function buildUnitDesignFromStainUnit(stainUnit)
	if isStainUnitEmpty(stainUnit) then
		return buildUnitDesignWrapper({
			isChange = false,
			decalMatMap = "",
			name = "",
			stainMatMap = ""
		})
	end

	local raw = {
		isChange = true,
		name = "",
		stainMatMap = compressToStr(table.tostring(stainUnit.stainMatMap or {})),
		decalMatMap = compressToStr(table.tostring(stainUnit.decalMatMap or {}))
	}

	return buildUnitDesignWrapper(raw)
end

local function buildUnitDesignFromRawTable(rawTable)
	if not rawTable then
		return nil
	end

	return buildUnitDesignWrapper(Utils.deepCopyTable(rawTable))
end

local function getWorkShopCostumeStainCtrl()
	local stainCtrl = pg.global.ui and pg.global.ui.workShopCostumeStain

	if not stainCtrl or not stainCtrl.view or not stainCtrl.model then
		return nil
	end

	return stainCtrl
end

local function getWorkShopCostumeStainModel()
	local stainCtrl = getWorkShopCostumeStainCtrl()

	return stainCtrl and stainCtrl.model or nil
end

local function refreshClothesStainEditorUI(customData)
	local stainCtrl = getWorkShopCostumeStainCtrl()

	if not stainCtrl then
		return
	end

	local model = stainCtrl.model

	if model.clothId ~= customData.clothId then
		return
	end

	local stainUnit = deepCopyStainUnit(customData.stainUnit)

	table.clear(model.curUnit)
	table.merge(model.curUnit, stainUnit)

	if model.curUnit.stainMatMap == nil then
		model.curUnit.stainMatMap = {}
	end

	if model.curUnit.decalMatMap == nil then
		model.curUnit.decalMatMap = {}
	end

	if stainCtrl.onRefreshAreaView then
		stainCtrl:onRefreshAreaView()
	elseif stainCtrl.colorPick and stainCtrl.colorPick.resetColorPick then
		stainCtrl.colorPick:resetColorPick()
	end

	if stainCtrl.refreshConsume then
		stainCtrl:refreshConsume()
	end
end

local function applyClothStainToEntity(entity, slotId, unit)
	if not entity or not entity.eModel or not unit then
		logClothesShare("applyClothStainToEntity skip entity=%s unit=%s slotId=%s", tostring(entity ~= nil), tostring(unit ~= nil), tostring(slotId))

		return
	end

	local rawTable = unit.getRawTable and unit:getRawTable() or unit

	logClothesShare("applyClothStainToEntity slotId=%s %s modelShaderView=%s shaderView=%s sameView=%s", tostring(slotId), describePresetUnit(unit), tostring(entity.eModel.modelShaderView ~= nil), tostring(entity.eModel.shaderView ~= nil), tostring(entity.eModel.shaderView == entity.eModel.modelShaderView))
	ClientModelUtils.applyClothStainInfo(entity, slotId, unit)

	local shaderView = entity.eModel.shaderView
	local modelShaderView = entity.eModel.modelShaderView

	if shaderView and shaderView ~= modelShaderView then
		if rawTable.isChange == false then
			logClothesShare("applyClothStainToEntity sync shaderView ApplyPreset Default1 slotId=%s", tostring(slotId))
			shaderView:ApplyPreset(slotId, "Default1")
		else
			logClothesShare("applyClothStainToEntity sync shaderView ApplyServerMatInfo slotId=%s", tostring(slotId))

			local unitData = ClientModelUtils.parseStainMatInfo(rawTable)

			shaderView:ApplyServerMatInfo(slotId, unitData)
		end
	end
end

local function applyClothStainPreviewDeferred(entity, slotId, unit, onComplete)
	if not entity or not entity.eModel then
		if onComplete then
			onComplete()
		end

		return
	end

	local modelView = entity.eModel.modelModelView

	local function applyNow()
		applyClothStainToEntity(entity, slotId, unit)

		if onComplete then
			onComplete()
		end
	end

	if modelView.partModel:IsPartModelLoaded(slotId) then
		applyNow()

		return
	end

	local prevCallback = entity.modelPartModelAllLoaded

	function entity.modelPartModelAllLoaded()
		if prevCallback then
			prevCallback()
		end

		applyNow()

		entity.modelPartModelAllLoaded = prevCallback
	end
end

local function restoreClothesInitialPreset(entity, slotId, clothId, onComplete)
	logClothesShare("restoreClothesInitialPreset enter slotId=%s clothId=%s entity=%s", tostring(slotId), tostring(clothId), tostring(entity ~= nil))

	if not entity or not entity.eModel then
		logClothesShare("restoreClothesInitialPreset skip: entity/eModel invalid")

		if onComplete then
			onComplete()
		end

		return
	end

	local AvatarUtils = require("Guis.Utils.AvatarUtils")

	local function applyNow()
		local appUnit = pg.me and pg.me.appearanceInfo and pg.me.appearanceInfo[clothId]
		local designIndex = appUnit and appUnit.designIndex or 0
		local designListLen = appUnit and appUnit.designList and #appUnit.designList or 0

		logClothesShare("restoreClothesInitialPreset applyNow designIndex=%s designListLen=%d partLoaded=%s", tostring(designIndex), designListLen, tostring(entity.eModel.modelModelView.partModel:IsPartModelLoaded(slotId)))

		local presetUnit = AvatarUtils.applyClothesPreset(entity, slotId, clothId)

		logClothesShare("restoreClothesInitialPreset applyClothesPreset -> %s", describePresetUnit(presetUnit))

		if designIndex > 0 and presetUnit and presetUnit ~= false and presetUnit ~= true then
			applyClothStainToEntity(entity, slotId, presetUnit)
		elseif presetUnit == false then
			local modelView = entity.eModel.modelModelView

			if modelView and modelView.shaderView then
				modelView.shaderView:ApplyPreset(slotId, "Default1")
			end

			local shaderView = entity.eModel.shaderView

			if shaderView and (not modelView or shaderView ~= modelView.shaderView) then
				shaderView:ApplyPreset(slotId, "Default1")
			end

			logClothesShare("restoreClothesInitialPreset fallback ApplyPreset Default1")
		else
			logClothesShare("restoreClothesInitialPreset keep Default1, skip reapply designList[1] to shader")
		end

		local stainCtrl = getWorkShopCostumeStainCtrl()

		logClothesShare("restoreClothesInitialPreset stainCtrl=%s modelClothId=%s", tostring(stainCtrl ~= nil), stainCtrl and tostring(stainCtrl.model.clothId) or "nil")

		if stainCtrl and stainCtrl.model.clothId == clothId then
			table.clear(stainCtrl.model.curUnit)

			if designIndex > 0 then
				table.merge(stainCtrl.model.curUnit, buildCurUnitFromPresetUnit(presetUnit))
			else
				stainCtrl.model.curUnit.stainMatMap = {}
				stainCtrl.model.curUnit.decalMatMap = {}
			end

			logClothesShare("restoreClothesInitialPreset curUnit restored %s", summarizeStainUnit(stainCtrl.model.curUnit))
		end

		logClothesShare("restoreClothesInitialPreset applyNow done")

		if onComplete then
			onComplete()
		end
	end

	local modelView = entity.eModel.modelModelView

	if modelView and modelView.partModel:IsPartModelLoaded(slotId) then
		applyNow()

		return
	end

	logClothesShare("restoreClothesInitialPreset defer until part loaded slotId=%s", tostring(slotId))

	local prevCallback = entity.modelPartModelAllLoaded

	function entity.modelPartModelAllLoaded()
		logClothesShare("restoreClothesInitialPreset deferred callback fired slotId=%s", tostring(slotId))

		if prevCallback then
			prevCallback()
		end

		applyNow()

		entity.modelPartModelAllLoaded = prevCallback
	end
end

local function rollbackClothesPreview(entity)
	logClothesShare("rollbackClothesPreview enter entity=%s snapshot=%s", tostring(entity ~= nil), tostring(originClothesSnapshot ~= nil))

	if not entity or not originClothesSnapshot then
		logClothesShare("rollbackClothesPreview abort entity=%s snapshot=%s", tostring(entity ~= nil), tostring(originClothesSnapshot ~= nil))

		return
	end

	local snapshot = originClothesSnapshot
	local slotId = snapshot.slotId
	local stainCtrl = getWorkShopCostumeStainCtrl()
	local workshopUnit = snapshot.workshopCurUnit

	logClothesShare("rollbackClothesPreview slotId=%s clothId=%s workshop=%s entityRaw=%s stainCtrl=%s", tostring(slotId), tostring(snapshot.clothId), summarizeStainUnit(workshopUnit), tostring(snapshot.entityUnitRaw ~= nil), tostring(stainCtrl ~= nil))

	if workshopUnit and stainCtrl and snapshotHadPriorStain(snapshot) then
		local model = stainCtrl.model

		table.clear(model.curUnit)
		table.merge(model.curUnit, Utils.deepCopyTable(workshopUnit))
		logClothesShare("rollbackClothesPreview restored workshop curUnit %s", summarizeStainUnit(model.curUnit))
	end

	local function refreshEditorAfterRollback()
		if stainCtrl then
			if stainCtrl.onRefreshAreaView then
				stainCtrl:onRefreshAreaView()
			elseif stainCtrl.colorPick and stainCtrl.colorPick.resetColorPick then
				stainCtrl.colorPick:resetColorPick()
			end

			if stainCtrl.refreshConsume then
				stainCtrl:refreshConsume()
			end
		end
	end

	local function finishRollback()
		logClothesShare("rollbackClothesPreview finishRollback")
		refreshEditorAfterRollback()

		originClothesSnapshot = nil
	end

	local hadPrior = snapshotHadPriorStain(snapshot)

	logClothesShare("rollbackClothesPreview hadPriorStain=%s branch=%s", tostring(hadPrior), hadPrior and "restoreSnapshot" or "restoreInitialPreset")

	if not hadPrior then
		restoreClothesInitialPreset(entity, slotId, snapshot.clothId, finishRollback)

		return
	end

	local unitToApply

	if workshopUnit and not isStainUnitEmpty(workshopUnit) then
		unitToApply = buildUnitDesignFromStainUnit(workshopUnit)
	elseif snapshot.entityUnitRaw then
		unitToApply = buildUnitDesignFromRawTable(snapshot.entityUnitRaw)
	else
		unitToApply = getClothesDesignUnit(slotId)
	end

	if unitToApply then
		logClothesShare("rollbackClothesPreview branch restoreSnapshot unitToApply=%s", describePresetUnit(unitToApply))
		applyClothStainPreviewDeferred(entity, slotId, unitToApply, finishRollback)

		return
	end

	local AvatarUtils = require("Guis.Utils.AvatarUtils")
	local clothId = snapshot.clothId

	if clothId then
		logClothesShare("rollbackClothesPreview branch fallback restoreInitialPreset clothId=%s", tostring(clothId))
		restoreClothesInitialPreset(entity, slotId, clothId, finishRollback)

		return
	end

	logClothesShare("rollbackClothesPreview branch last resort ApplyPreset Default1")

	if entity.eModel then
		local shaderView = entity.eModel.modelShaderView or entity.eModel.shaderView

		if shaderView then
			shaderView:ApplyPreset(slotId, "Default1")
		end

		local liveShaderView = entity.eModel.shaderView

		if liveShaderView and liveShaderView ~= shaderView then
			liveShaderView:ApplyPreset(slotId, "Default1")
		end
	end

	finishRollback()
end

local function saveClothesOriginSnapshot(customData)
	originClothesSnapshot = nil

	if not customData then
		logClothesShare("saveClothesOriginSnapshot skip customData=nil")

		return
	end

	local _, entity = AvatarShareService.getAvatarContext()

	if not entity then
		logClothesShare("saveClothesOriginSnapshot skip entity=nil clothId=%s slotId=%s", tostring(customData.clothId), tostring(customData.slotId))

		return
	end

	local slotId = customData.slotId
	local snapshot = {
		slotId = slotId,
		clothId = customData.clothId,
		entityUnitRaw = captureClothesDesignRaw(slotId)
	}
	local workshopModel = getWorkShopCostumeStainModel()

	if workshopModel and workshopModel.clothId == customData.clothId then
		snapshot.workshopCurUnit = deepCopyStainUnit(workshopModel.curUnit)
	end

	snapshot.hadPriorStain = entityHadAppliedClothesStain(snapshot)
	originClothesSnapshot = snapshot

	logClothesShare("saveClothesOriginSnapshot clothId=%s slotId=%s designIndex=%s workshop=%s entityRaw=%s hadPriorStain=%s", tostring(snapshot.clothId), tostring(snapshot.slotId), tostring(pg.me and pg.me.appearanceInfo and pg.me.appearanceInfo[snapshot.clothId] and pg.me.appearanceInfo[snapshot.clothId].designIndex), summarizeStainUnit(snapshot.workshopCurUnit), tostring(snapshot.entityUnitRaw ~= nil), tostring(snapshot.hadPriorStain))
end

function AvatarShareService.validateClothesImportPreconditions(customData)
	if not customData or not customData.clothId or not customData.slotId or not customData.stainUnit then
		return false, "INVALID_ID"
	end

	local clothId = tonumber(customData.clothId)
	local slotId = tonumber(customData.slotId)

	if not clothId or clothId <= 0 or not slotId or slotId <= 0 then
		return false, "INVALID_ID"
	end

	local AvatarUtils = require("Guis.Utils.AvatarUtils")

	if not AvatarUtils.isDyeingEnabled(clothId) then
		return false, "APPEARANCE_CLOTH_DYEING_NOT_VALID"
	end

	if not pg.me then
		return true
	end

	if pg.me.appearanceInfo[clothId] == nil then
		return false, "APPEARANCE_CLOTH_DYEING_NOT_OWNED"
	end

	if not pg.me.curShow or pg.me.curShow.customShow[slotId] ~= clothId then
		return false, "APPEARANCE_CLOTH_DYEING_NOT_VALID"
	end

	local workshopModel = getWorkShopCostumeStainModel()

	if not workshopModel or workshopModel.clothId ~= clothId then
		return false, "APPEARANCE_CLOTH_DYEING_NOT_VALID"
	end

	return true
end

function AvatarShareService.validateImportPreconditions(customData)
	if getShareType(customData) == AvatarShareService.SHARE_TYPE.HAIR then
		return AvatarShareService.validateHairImportPreconditions(customData)
	end

	if getShareType(customData) == AvatarShareService.SHARE_TYPE.CLOTHES then
		return AvatarShareService.validateClothesImportPreconditions(customData)
	end

	return AvatarShareService.validateFaceImportPreconditions(customData)
end

local function buildCreatePlayerHairCurShow(avatarScene, presetKey)
	local curShow = {
		customShow = {},
		hairInfo = {}
	}

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		local configId = pg.game.avatar.hairSelection[partId]

		if not configId and avatarScene then
			configId = avatarScene:getCurHairPartId(presetKey, partId)
		end

		if configId then
			curShow.customShow[partId] = configId

			local hairCustomStr = pg.global.avatarMgr:GetHairCustomDataString(partId)

			if string.isNilOrEmpty(hairCustomStr) and pg.game.avatar.hairCustomData then
				hairCustomStr = pg.game.avatar.hairCustomData[partId]

				if hairCustomStr and hairCustomStr ~= "" then
					curShow.hairInfo[partId] = hairCustomStr
				end
			else
				curShow.hairInfo[partId] = packHairCustomInfo(hairCustomStr)
			end
		end
	end

	return curShow
end

local function buildCurShowFromHairData(hairData)
	return {
		customShow = hairData.customShow or {},
		hairInfo = hairData.hairInfo or {}
	}
end

local function captureHairCurShow(entity, avatarScene, presetKey)
	if pg.me and pg.me.curShow then
		return pg.me.curShow
	end

	return buildCreatePlayerHairCurShow(avatarScene, presetKey)
end

local function getEntityHairCurShow(entity, avatarScene)
	if pg.me and pg.me.curShow then
		return pg.me.curShow
	end

	if pg.game.avatar.originCurShow and pg.game.avatar.originCurShow.customShow then
		return pg.game.avatar.originCurShow
	end

	if not entity then
		return nil
	end

	local presetKey = entity.avatarPresetKey

	if not presetKey and entity:hasEModelComponent(Const.COMPONENT_INDEX_MODEL) then
		presetKey = entity.eModel.modelModelView.modelInfo:GetPresetKey()
	end

	return buildCreatePlayerHairCurShow(avatarScene, presetKey)
end

local function syncHairSelection(curShow)
	if not curShow or not curShow.customShow then
		return
	end

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		local configId = curShow.customShow[partId]

		if configId then
			pg.game.avatar:updateHairSelection(partId, configId, "avatarShareRestore")
		end
	end
end

local function syncEntityHairCurShow(entity, curShow)
	if not entity or not curShow then
		return
	end

	if not entity.curShow then
		entity.curShow = {
			customShow = {},
			hairInfo = {}
		}
	end

	if not entity.curShow.customShow then
		entity.curShow.customShow = {}
	end

	if not entity.curShow.hairInfo then
		entity.curShow.hairInfo = {}
	end

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		entity.curShow.customShow[partId] = curShow.customShow and curShow.customShow[partId]
		entity.curShow.hairInfo[partId] = curShow.hairInfo and curShow.hairInfo[partId]
	end
end

local function syncEntityHairCustomShow(entity, curShow)
	if not entity or not curShow or not curShow.customShow then
		return
	end

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		if entity.cancelCustomShowPreview then
			entity:cancelCustomShowPreview(partId)
		end

		if entity.cancelCustomShow then
			entity:cancelCustomShow(partId, true)
		end

		local configId = curShow.customShow[partId]

		if configId and configId ~= 0 then
			if entity.setCustomShow then
				entity:setCustomShow(configId, true, partId)
			end

			if entity.setCustomShowPreview then
				entity:setCustomShowPreview(configId, true, partId)
			end
		end
	end
end

local function refreshWorkShopHairList(hairSuitId)
	if not hairSuitId then
		return
	end

	local workShopCtrl = pg.global.ui and pg.global.ui.workShopDesign

	if not workShopCtrl or not workShopCtrl.component then
		return
	end

	pg.game.avatar.optionSelectedData = {
		claimed = true,
		id = hairSuitId
	}
	workShopCtrl.component.selectedHairId = hairSuitId

	if workShopCtrl.component.refreshHairList then
		workShopCtrl.component:refreshHairList(hairSuitId)
	end
end

local function refreshAppearanceHairList(hairSuitId)
	if not hairSuitId then
		return
	end

	local appearanceCtrl = pg.global.ui and pg.global.ui.appearanceV2
	local playerComponent = appearanceCtrl and appearanceCtrl.components and appearanceCtrl.components.player
	local hairComponent = playerComponent and playerComponent.components and playerComponent.components.hair

	if not hairComponent or appearanceCtrl.curComponentName ~= "player" or playerComponent.curComponent ~= hairComponent then
		return
	end

	if hairComponent.refreshImportedHairSelection then
		hairComponent:refreshImportedHairSelection(hairSuitId)
	end
end

local function refreshHairEditorUI(hairSuitId)
	refreshWorkShopHairList(hairSuitId)
	refreshAppearanceHairList(hairSuitId)

	local avatarCtrl = pg.global.ui and pg.global.ui.avatar

	if not avatarCtrl or not avatarCtrl.components then
		return
	end

	local AvatarUtils = require("Guis.Utils.AvatarUtils")
	local hairComponent = avatarCtrl.components[AvatarUtils.AVATAR_TYPE.HAIR]

	if not hairComponent or not hairComponent.model then
		return
	end

	if hairSuitId and avatarCtrl.openData then
		avatarCtrl.openData.hairId = hairSuitId
	end

	if hairSuitId then
		hairComponent:sortConfig(hairSuitId)
	end

	if avatarCtrl.isDesignMode then
		local designType = avatarCtrl.openData and avatarCtrl.openData.designType or AvatarUtils.HAIR_DESIGN_TYPE.PRESET

		hairComponent.selectedGroupKey = hairComponent.model.HAIR_PART.WHOLE

		local firstDesignList = hairComponent.model:getHairFirstDesignList()

		for index, designInfo in ipairs(firstDesignList) do
			if designInfo.key == designType then
				avatarCtrl.firstDesignData = designInfo

				local res, btn = avatarCtrl.view.firstDesignUList:TryGetChildAt(index - 1)

				if res then
					btn:OnClickSimulate()

					break
				end

				hairComponent:onFirstDesignSelected(designInfo)

				break
			end
		end
	else
		hairComponent.selectedGroupKey = hairComponent.model.HAIR_PART.WHOLE
		hairComponent.selectedHairOp = AvatarUtils.HAIR_DESIGN_TYPE.PRESET

		hairComponent:refreshComponent()
	end
end

local function isTargetHairPartsLoaded(modelView, curShow)
	if not modelView or not curShow or not curShow.customShow then
		return false
	end

	local partModelInfo = modelView.modelInfo and modelView.modelInfo.partModelInfo

	if not partModelInfo then
		return false
	end

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		local configId = curShow.customShow[partId]

		if configId and configId ~= 0 then
			local configData = AppearanceData[configId]
			local expectedResId = configData and configData.res

			if not string.isNilOrEmpty(expectedResId) then
				if partModelInfo:GetPartResId(partId) ~= expectedResId then
					return false
				end

				if not modelView.partModel:IsPartModelLoaded(partId) then
					return false
				end
			end
		end
	end

	return true
end

local function applyEntityHairCustomDataDeferred(entity, curShow, onComplete)
	if not entity or not curShow or not entity.eModel then
		if onComplete then
			onComplete()
		end

		return
	end

	local modelView = entity.eModel.modelModelView
	local applied = false

	local function applyAllHairCustomData()
		if applied then
			return
		end

		applied = true

		avatarMgr:SetAvatarInstance(entity.eModel)

		local hairSuitId = LuaUIUtils.tryGetHairSuitId(curShow.customShow)
		local hairSuitInfo = hairSuitId and AvatarHairSuitData[hairSuitId]
		local hairAssetId = hairSuitInfo and hairSuitInfo.assetId

		if hairAssetId then
			avatarMgr.avatarHair:SetAssetIdAndLoad(hairAssetId)
		end

		for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
			local configId = curShow.customShow and curShow.customShow[partId]

			if configId and configId ~= 0 then
				ClientModelUtils.applyHairCustomData(entity, curShow, partId)
			else
				modelView.modelInfo:ParseHairCustomData(partId, "")
				modelView.modelInfo:ProcessHairCustomData(partId)
			end
		end

		if hairAssetId and modelView.modelInfo.hairCustomDataDic then
			for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
				local ok, hairCustomData = pcall(function()
					return modelView.modelInfo.hairCustomDataDic[partId]
				end)

				if ok and hairCustomData then
					hairCustomData.assetId = hairAssetId

					modelView.modelInfo:ProcessHairCustomData(partId)

					if modelView.partModel:IsPartModelLoaded(partId) then
						modelView:ApplyHairCustomData(partId)
					end
				end
			end

			avatarMgr.avatarHair:SetAssetIdAndLoad(hairAssetId)
		end

		avatarMgr.avatarHair:InitColors()

		if onComplete then
			onComplete()
		end
	end

	local prevCallback = entity.modelPartModelAllLoaded

	function entity.modelPartModelAllLoaded()
		entity.modelPartModelAllLoaded = prevCallback

		applyAllHairCustomData()

		if prevCallback then
			prevCallback()
		end
	end
end

local function resolveHairSuitIdFromCustomData(customData)
	if not customData then
		return nil
	end

	local hairSuitId = tonumber(customData.hairSuitId)

	if (not hairSuitId or hairSuitId <= 0) and customData.hairData and customData.hairData.customShow then
		hairSuitId = LuaUIUtils.tryGetHairSuitId(customData.hairData.customShow)
	end

	return hairSuitId
end

local function restoreEntityHair(entity, curShow, onComplete)
	if not entity or not curShow then
		if onComplete then
			onComplete()
		end

		return
	end

	avatarMgr:SetAvatarInstance(entity.eModel)

	local hairSuitId = LuaUIUtils.tryGetHairSuitId(curShow.customShow)
	local hairSuitInfo = hairSuitId and AvatarHairSuitData[hairSuitId]
	local hairAssetId = hairSuitInfo and hairSuitInfo.assetId
	local presetKey = entity.avatarPresetKey

	if not presetKey and entity:hasEModelComponent(Const.COMPONENT_INDEX_MODEL) then
		presetKey = entity.eModel.modelModelView.modelInfo:GetPresetKey()
	end

	local param = {
		entityId = presetKey
	}
	local modelView = entity.eModel.modelModelView
	local partModelInfo = modelView.modelInfo.partModelInfo

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		local configId = curShow.customShow[partId]

		AppearanceEffectUtils.setAppearance(entity, partId, configId)

		if configId then
			pg.game.avatar:updateHairSelection(partId, configId, "avatarShareRestore")
		end

		local configData = configId and AppearanceData[configId]

		if configData and configData.res then
			table.insert(param, {
				isApply = true,
				resId = configData.res,
				partId = partId
			})
		else
			local resId = partModelInfo:GetPartResId(partId)

			if not string.isNilOrEmpty(resId) then
				table.insert(param, {
					isApply = false,
					resId = resId
				})
			end
		end
	end

	if hairAssetId then
		avatarMgr.avatarHair:OnHairSuitChanged(nil, hairAssetId)
	end

	syncEntityHairCurShow(entity, curShow)
	syncEntityHairCustomShow(entity, curShow)
	syncHairSelection(curShow)
	applyEntityHairCustomDataDeferred(entity, curShow, onComplete)

	local avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)

	modelView.forceLoadPart = true

	if avatarScene then
		avatarScene:changeHair(param)
	else
		require("Guis.Utils.AvatarUtils").cancelHairTie()

		for _, info in ipairs(param) do
			if info.isApply then
				partModelInfo:ModifyPartItem(info.resId, {
					info.partId
				})
			else
				partModelInfo:RemovePartItem(info.resId)
			end
		end

		ClientModelUtils.refreshModels(entity, modelView)
	end

	modelView.forceLoadPart = false

	TimerManager.addNextFrameCb(function()
		if isTargetHairPartsLoaded(modelView, curShow) then
			local cb = entity.modelPartModelAllLoaded

			if cb then
				cb()
			end
		end
	end)
end

local function applyConfigToEntity(entity, avatarConfig, presetKey, keepHair, hairCurShow)
	avatarMgr:SetAvatarInstance(entity.eModel)
	avatarMgr.avatarMakeup:ResetMakeupVisualStateBeforeImport()

	local modelView = entity.eModel.modelModelView

	if presetKey then
		modelView.modelInfo:ParseAvatarRuntimeData(presetKey)
	end

	modelView.modelInfo:ParseCustomData(avatarConfig)

	local partChanged = modelView.modelInfo:ApplyCustomPartAssetIds()

	modelView.modelInfo:ProcessCustomData()

	if partChanged then
		modelView.modelInfo:ParseToModelInfo()
	end

	avatarMgr:InitAvatarPart()
	avatarMgr.avatarMakeup:ClearPreviewDecal()

	modelView.forceLoadPart = true

	ClientModelUtils.refreshModels(entity, modelView)
	modelView:RefreshDecal()
	modelView:RefreshMakeup()

	modelView.forceLoadPart = false

	if keepHair then
		local avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)

		restoreEntityHair(entity, hairCurShow or getEntityHairCurShow(entity, avatarScene))
	end

	local bodySize = modelView.modelInfo:GetBodySize()

	entity:setModelScale(ClientConst.MODEL_SCALE_KEY.AVATAR, bodySize)
end

local function buildHairCustomDataForSave(hairData)
	local hairCustomData = {}

	if not hairData or not hairData.customShow then
		return hairCustomData
	end

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		local configId = hairData.customShow[partId]

		if configId and configId ~= 0 then
			hairCustomData[partId] = {
				configId = configId,
				hairInfo = hairData.hairInfo and hairData.hairInfo[partId] or nil
			}
		end
	end

	return hairCustomData
end

local function resolveHairPresetIndex(hairSuitId)
	local AvatarUtils = require("Guis.Utils.AvatarUtils")
	local usedNum, unlockNum = AvatarUtils.getHairPresetNumInfo(hairSuitId)

	if usedNum < unlockNum then
		return usedNum + 1
	end

	return nil
end

local function buildHairAppearanceActions(hairData)
	local actions = {}

	if not hairData or not hairData.customShow or not pg.me then
		return actions
	end

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		local newConfigId = hairData.customShow[partId]
		local curConfigId = pg.me.curShow and pg.me.curShow.customShow[partId]

		if curConfigId and curConfigId ~= 0 and curConfigId ~= newConfigId then
			table.insert(actions, {
				curConfigId,
				false,
				partId
			})
		end

		if newConfigId and newConfigId ~= 0 then
			table.insert(actions, {
				newConfigId,
				true,
				partId
			})
		end
	end

	return actions
end

function AvatarShareService.commitHairImport(customData, callback)
	if not pg.me then
		if callback then
			callback(true)
		end

		return
	end

	local hairSuitId = resolveHairSuitIdFromCustomData(customData)

	if not hairSuitId then
		AvatarShareService.rollbackPreview()

		if callback then
			callback(false)
		end

		return
	end

	local targetIndex = resolveHairPresetIndex(hairSuitId)

	if not targetIndex then
		pg.global.showBubbleMessageRaw(pg.getGameString("APPEARANCE_HAIR_PRESET_NO_EMPTY_SLOT"), 3)
		AvatarShareService.rollbackPreview()

		if callback then
			callback(false)
		end

		return
	end

	local consumes = Utils.calculateWsHairConsume()

	for itemId, itemNum in pairs(consumes) do
		if itemNum > ItemUtils.getItemCountById(pg.me, itemId) then
			pg.global.showBubbleMessageRaw(pg.getGameString("APPEARANCE_PAY_FAIL"), 3)
			AvatarShareService.rollbackPreview()

			if callback then
				callback(false)
			end

			return
		end
	end

	local consumeList = {}

	for itemId, itemNum in pairs(consumes) do
		table.insert(consumeList, {
			itemId,
			itemNum
		})
	end

	pg.global.ui.commonUseConfirm:open({
		title = pg.getGameString("SAVE_PRESET"),
		tipTop = pg.getGameString("UNLOCK_DESC"),
		data = consumeList,
		confirmCb = function()
			targetIndex = resolveHairPresetIndex(hairSuitId)

			if not targetIndex then
				pg.global.showBubbleMessageRaw(pg.getGameString("APPEARANCE_HAIR_PRESET_NO_EMPTY_SLOT"), 3)
				AvatarShareService.rollbackPreview()

				if callback then
					callback(false)
				end

				return
			end

			local actions = buildHairAppearanceActions(customData.hairData)
			local hairCustomData = buildHairCustomDataForSave(customData.hairData)

			local function onHairCommitted(res)
				if res then
					pg.me:refreshAppearance()

					local AvatarUtils = require("Guis.Utils.AvatarUtils")

					AvatarUtils.refreshHairByCustom()
					refreshHairEditorUI(hairSuitId)
					pg.global.showBubbleMessageRaw(pg.getGameString("APPEARANCE_SAVE_SUCCESS"), 3)

					if callback then
						callback(true)
					end
				elseif callback then
					callback(false)
				end
			end

			local function saveAndApplyHairCustom()
				pg.me:serverMsg("RPC_CS_SaveHairCustom", hairSuitId, targetIndex, hairCustomData, pg.getGameString("DESIGN_DEFAULT"), "")
				pg.me:serverMsg("RPC_CS_SetHairCustom", hairSuitId, targetIndex, onHairCommitted)
			end

			if #actions > 0 then
				pg.me:serverMsg("RPC_CS_MultiSetAppearanceShow", actions, saveAndApplyHairCustom)
			else
				saveAndApplyHairCustom()
			end
		end,
		cancelCb = function()
			AvatarShareService.rollbackPreview()

			if callback then
				callback(false)
			end
		end
	})
end

function AvatarShareService.commitClothesImport(customData, callback)
	refreshClothesStainEditorUI(customData)

	originClothesSnapshot = nil

	if callback then
		callback(true)
	end
end

local function refreshAvatarWorkshopConsumeUI()
	local avatarCtrl = pg.global.ui and pg.global.ui.avatar

	if avatarCtrl and avatarCtrl.refreshButtonState then
		avatarCtrl:refreshButtonState()
	end
end

function AvatarShareService.commitImport(customData, callback)
	if getShareType(customData) == AvatarShareService.SHARE_TYPE.HAIR then
		AvatarShareService.commitHairImport(customData, callback)

		return
	end

	if getShareType(customData) == AvatarShareService.SHARE_TYPE.CLOTHES then
		AvatarShareService.commitClothesImport(customData, callback)

		return
	end

	local _, entity = AvatarShareService.getAvatarContext()

	if entity then
		entity.avatarConfig = customData.avatarConfig
	end

	local function finishFaceImport(success)
		refreshAvatarWorkshopConsumeUI()

		if callback then
			callback(success)
		end
	end

	if not pg.me then
		finishFaceImport(true)

		return
	end

	if isSameFaceAsWorldPlayer(customData.avatarConfig) then
		finishFaceImport(true)
		pg.global.showBubbleMessageRaw(pg.getGameString("SAME_FACE"))

		return
	end

	local consumes = Utils.calculateWsAvatarConfigConsume()

	for itemId, itemNum in pairs(consumes) do
		if itemNum > ItemUtils.getItemCountById(pg.me, itemId) then
			pg.global.showBubbleMessageRaw(pg.getGameString("APPEARANCE_PAY_FAIL"), 3)
			AvatarShareService.rollbackPreview()
			finishFaceImport(false)

			return
		end
	end

	local consumeList = {}

	for itemId, itemNum in pairs(consumes) do
		table.insert(consumeList, {
			itemId,
			itemNum
		})
	end

	pg.global.ui.commonUseConfirm:open({
		title = pg.getGameString("SAVE_PRESET"),
		tipTop = pg.getGameString("UNLOCK_DESC"),
		data = consumeList,
		confirmCb = function()
			local avatarConfig = decompressFromStr(customData.avatarConfig)
			local suitId = parseMakeupSuitIdFromAvatarConfig(customData.avatarConfig)

			pg.me:serverMsg("RPC_CS_SetAvatarConfig", compressToStr(avatarConfig), suitId, function(res)
				if res then
					pg.global.showBubbleMessageRaw(pg.getGameString("APPEARANCE_SAVE_SUCCESS"), 3)
					finishFaceImport(true)
				else
					finishFaceImport(false)
				end
			end)
		end,
		cancelCb = function()
			AvatarShareService.rollbackPreview()
			finishFaceImport(false)
		end
	})
end

function AvatarShareService.isShareId(id)
	return not string.isNilOrEmpty(id) and (string.len(id) == SHORT_SHARE_ID_LEN and string.match(id, SHORT_SHARE_ID_PATTERN) ~= nil or string.match(id, SHARE_ID_PATTERN) ~= nil)
end

function AvatarShareService.buildShareId()
	shareIdSeq = shareIdSeq + 1

	local seed = string.format("%s|%s|%s|%s|%s|%s", GlobalData.UserName or "", pg.me and pg.me.uid or "", os.time(), os.clock(), shareIdSeq, tostring({}))

	return string.upper(string.sub(md5.sumhexa(seed), 1, 16))
end

function AvatarShareService.buildUniqueShareId(callback, retryCount)
	retryCount = retryCount or 0

	local id = AvatarShareService.buildShareId()

	ServiceUtils.kvServiceFind(id, function(status, response)
		if status.status and not string.isNilOrEmpty(response.value) then
			if retryCount < BUILD_SHARE_ID_MAX_RETRY then
				AvatarShareService.buildUniqueShareId(callback, retryCount + 1)
			elseif callback then
				callback(nil)
			end

			return
		end

		if callback then
			callback(id)
		end
	end)
end

function AvatarShareService.encodeFaceData(entity)
	if not entity or not entity.eModel then
		return nil, "INVALID_ID"
	end

	local modelView = entity.eModel.modelModelView

	if not modelView or not modelView.modelInfo then
		return nil, "INVALID_ID"
	end

	local AvatarUtils = require("Guis.Utils.AvatarUtils")
	local customData = {
		shareType = AvatarShareService.SHARE_TYPE.FACE,
		templateId = modelView.modelInfo:GetTemplateId(),
		presetKey = modelView.modelInfo:GetPresetKey(),
		avatarConfig = compressToStr(AvatarUtils.getCustomDataStringForSave())
	}

	return customData
end

function AvatarShareService.encodeHairData(entity, avatarScene, presetKey)
	if not entity or not entity.eModel or not avatarScene or not presetKey then
		return nil, "INVALID_ID"
	end

	local modelView = entity.eModel.modelModelView

	if not modelView or not modelView.modelInfo then
		return nil, "INVALID_ID"
	end

	local hairData = {
		customShow = {},
		hairInfo = {}
	}

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		local configId = avatarScene:getCurHairPartId(presetKey, partId)

		if configId then
			hairData.customShow[partId] = configId

			local hairCustomStr = avatarMgr:GetHairCustomDataString(partId)
			local packedInfo = packHairCustomInfo(hairCustomStr)

			if packedInfo then
				hairData.hairInfo[partId] = packedInfo
			end
		end
	end

	local hairSuitId = avatarScene:getCurHairSuitId(presetKey)

	hairSuitId = hairSuitId or LuaUIUtils.tryGetHairSuitId(hairData.customShow)

	if not hairSuitId then
		return nil, "INVALID_ID"
	end

	return {
		shareType = AvatarShareService.SHARE_TYPE.HAIR,
		templateId = modelView.modelInfo:GetTemplateId(),
		presetKey = presetKey,
		hairSuitId = hairSuitId,
		hairData = hairData
	}
end

function AvatarShareService.encodeClothesData(clothId, slotId, curUnit)
	if not clothId or not slotId or not curUnit then
		return nil, "INVALID_ID"
	end

	local AvatarUtils = require("Guis.Utils.AvatarUtils")

	if not AvatarUtils.isDyeingEnabled(clothId) then
		return nil, "APPEARANCE_CLOTH_DYEING_NOT_VALID"
	end

	return {
		shareType = AvatarShareService.SHARE_TYPE.CLOTHES,
		clothId = clothId,
		slotId = slotId,
		stainUnit = deepCopyStainUnit(curUnit)
	}
end

function AvatarShareService.serializePayload(customData)
	return compressToStr(table.tostring(customData))
end

function AvatarShareService.deserializePayload(payloadStr)
	if string.isNilOrEmpty(payloadStr) then
		return nil, "INVALID_ID"
	end

	local ok, customData = pcall(function()
		return string.toTable(decompressFromStr(payloadStr))
	end)

	if not ok or not customData then
		return nil, "INVALID_ID"
	end

	customData.shareType = customData.shareType or AvatarShareService.SHARE_TYPE.FACE

	if customData.shareType == AvatarShareService.SHARE_TYPE.HAIR then
		if not customData.hairData or not customData.hairData.customShow then
			return nil, "INVALID_ID"
		end
	elseif customData.shareType == AvatarShareService.SHARE_TYPE.CLOTHES then
		if not customData.clothId or not customData.slotId or not customData.stainUnit then
			return nil, "INVALID_ID"
		end
	elseif not customData.avatarConfig then
		return nil, "INVALID_ID"
	end

	return customData
end

function AvatarShareService.upload(id, payload, callback)
	if not pg.me then
		if callback then
			callback(false)
		end

		return
	end

	pg.me:serverMsg("RPC_CS_UploadAppearancePhoto", id, payload)
	AvatarShareService.verifyUpload(id, payload, 0, callback)
end

function AvatarShareService.verifyUpload(id, payload, retryCount, callback)
	ServiceUtils.kvServiceFind(id, function(status, response)
		if status.status and not string.isNilOrEmpty(response.value) then
			if callback then
				callback(true)
			end

			return
		end

		if retryCount < UPLOAD_VERIFY_MAX_RETRY then
			TimerManager.addTimer(UPLOAD_VERIFY_INTERVAL, function()
				AvatarShareService.verifyUpload(id, payload, retryCount + 1, callback)
			end)
		elseif callback then
			callback(false)
		end
	end)
end

function AvatarShareService.download(id, callback)
	if not AvatarShareService.isShareId(id) then
		if callback then
			callback(false, nil)
		end

		return
	end

	ServiceUtils.kvServiceFind(id, function(status, response)
		if status.status and not string.isNilOrEmpty(response.value) then
			if callback then
				callback(true, response.value)
			end
		elseif callback then
			callback(false, nil)
		end
	end)
end

function AvatarShareService.getAvatarContext()
	local avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)

	if not avatarScene then
		return nil, nil
	end

	return avatarScene, avatarScene:getCurEntity()
end

function AvatarShareService.saveOriginSnapshot(customData)
	if customData and getShareType(customData) == AvatarShareService.SHARE_TYPE.CLOTHES then
		saveClothesOriginSnapshot(customData)

		return
	end

	local avatarScene, entity = AvatarShareService.getAvatarContext()

	if not entity then
		return
	end

	local modelView = entity.eModel.modelModelView
	local presetKey = modelView.modelInfo:GetPresetKey()
	local capturedHairCurShow = captureHairCurShow(entity, avatarScene, presetKey)
	local curShow = {
		customShow = {},
		hairInfo = {}
	}

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		curShow.customShow[partId] = capturedHairCurShow.customShow[partId]
		curShow.hairInfo[partId] = capturedHairCurShow.hairInfo[partId]
	end

	local AvatarUtils = require("Guis.Utils.AvatarUtils")
	local avatarConfig = AvatarUtils.getCustomDataStringForSave()

	pg.game.avatar:recordAppearance(presetKey, avatarConfig, curShow)
end

function AvatarShareService.applyFacePreview(customData)
	local avatarScene, entity = AvatarShareService.getAvatarContext()

	if not entity then
		return false, "INVALID_ID"
	end

	if entity.templateId ~= customData.templateId then
		return false, "INVALID_TEMPLATE_ID"
	end

	local avatarConfig = decompressFromStr(customData.avatarConfig)
	local hairCurShow = getEntityHairCurShow(entity, avatarScene)
	local modelView = entity.eModel.modelModelView
	local presetKey = customData.presetKey

	if not presetKey or presetKey < 0 then
		presetKey = modelView.modelInfo:GetPresetKey()
	end

	applyConfigToEntity(entity, avatarConfig, presetKey, true, hairCurShow)

	entity.avatarConfig = customData.avatarConfig

	return true
end

function AvatarShareService.applyHairPreview(customData)
	local _, entity = AvatarShareService.getAvatarContext()

	if not entity then
		return false, "INVALID_ID"
	end

	if entity.templateId ~= customData.templateId then
		return false, "INVALID_TEMPLATE_ID"
	end

	avatarMgr:SetAvatarInstance(entity.eModel)

	local hairSuitId = resolveHairSuitIdFromCustomData(customData)
	local curShow = buildCurShowFromHairData(customData.hairData)

	restoreEntityHair(entity, curShow, function()
		refreshHairEditorUI(hairSuitId)
	end)

	return true
end

function AvatarShareService.applyClothesPreview(customData)
	local _, entity = AvatarShareService.getAvatarContext()

	logClothesShare("applyClothesPreview clothId=%s slotId=%s entity=%s stain=%s", tostring(customData and customData.clothId), tostring(customData and customData.slotId), tostring(entity ~= nil), summarizeStainUnit(customData and customData.stainUnit))

	if not entity then
		return false, "INVALID_ID"
	end

	local slotId = customData.slotId
	local unit = buildUnitDesignFromStainUnit(customData.stainUnit)

	applyClothStainPreviewDeferred(entity, slotId, unit, function()
		refreshClothesStainEditorUI(customData)
	end)
	refreshClothesStainEditorUI(customData)

	return true
end

function AvatarShareService.rollbackPreview()
	local _, entity = AvatarShareService.getAvatarContext()

	logClothesShare("rollbackPreview lastPreviewShareType=%s entity=%s clothesSnapshot=%s", tostring(lastPreviewShareType), tostring(entity ~= nil), tostring(originClothesSnapshot ~= nil))

	if not entity then
		logClothesShare("rollbackPreview abort entity=nil")

		return
	end

	if lastPreviewShareType == AvatarShareService.SHARE_TYPE.CLOTHES then
		rollbackClothesPreview(entity)

		return
	end

	if lastPreviewShareType == AvatarShareService.SHARE_TYPE.HAIR then
		if pg.game.avatar.originCurShow then
			local originHairSuitId = LuaUIUtils.tryGetHairSuitId(pg.game.avatar.originCurShow.customShow)

			restoreEntityHair(entity, pg.game.avatar.originCurShow, function()
				refreshHairEditorUI(originHairSuitId)
			end)
		end

		return
	end

	if not pg.game.avatar.originPresetKey then
		return
	end

	applyConfigToEntity(entity, pg.game.avatar.originAvatarConfig, pg.game.avatar.originPresetKey, true, pg.game.avatar.originCurShow)

	entity.avatarConfig = compressToStr(pg.game.avatar.originAvatarConfig)
end

function AvatarShareService.openImportConfirmPanel(id, customData)
	pg.global.ui:open(UIConst.UI_ID_AVATAR_IMPORT_CONFIRM, {
		confirmCb = function()
			AvatarShareService.commitImport(customData, function(success)
				if success and pg.global.ui.avatarImport then
					pg.global.ui.avatarImport:close()
				end
			end)
		end,
		cancelCb = function()
			logClothesShare("openImportConfirmPanel cancelCb")
			AvatarShareService.rollbackPreview()

			if pg.global.ui.avatarImport then
				pg.global.ui.avatarImport:close()
			end
		end,
		id = id,
		customData = customData,
		shareType = getShareType(customData)
	})
end

function AvatarShareService.openFaceWorkShop()
	local AvatarUtils = require("Guis.Utils.AvatarUtils")
	local avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)

	if not avatarScene then
		return
	end

	local presetKey = pg.game.avatar:getPresetKey(pg.me)

	pg.global.ui:open(UIConst.UI_ID_AVATAR, {
		isDesignMode = true,
		presetKey = presetKey,
		avatarType = AvatarUtils.AVATAR_TYPE.FACE,
		designType = AvatarUtils.DESIGN_TYPE.FACE
	}, function()
		avatarScene:showAvatar(presetKey)
		avatarScene:setAvatarCameraModeCloseHead()
	end)
end

function AvatarShareService.previewImport(id, payloadStr)
	local customData, errKey = AvatarShareService.deserializePayload(payloadStr)

	if not customData then
		return false, errKey
	end

	local ok, validateErr = AvatarShareService.validateImportPreconditions(customData)

	if not ok then
		return false, validateErr
	end

	lastPreviewShareType = getShareType(customData)

	logClothesShare("previewImport id=%s shareType=%s clothId=%s slotId=%s", tostring(id), tostring(lastPreviewShareType), tostring(customData.clothId), tostring(customData.slotId))

	local previewOk, applyErr

	if lastPreviewShareType == AvatarShareService.SHARE_TYPE.HAIR then
		previewOk, applyErr = AvatarShareService.applyHairPreview(customData)
	elseif lastPreviewShareType == AvatarShareService.SHARE_TYPE.CLOTHES then
		previewOk, applyErr = AvatarShareService.applyClothesPreview(customData)
	else
		previewOk, applyErr = AvatarShareService.applyFacePreview(customData)
	end

	if not previewOk then
		return false, applyErr
	end

	AvatarShareService.openImportConfirmPanel(id, customData)

	return true
end

function AvatarShareService.importById(id, onComplete)
	id = string.trim(id or "")

	if string.isNilOrEmpty(id) then
		pg.global.showBubbleMessageRaw(pg.getGameString("INVALID_ID"), 2)

		if onComplete then
			onComplete(false, "INVALID_ID")
		end

		return
	end

	AvatarShareService.download(id, function(success, payload)
		if not success then
			pg.global.showBubbleMessageRaw(pg.getGameString("INVALID_ID"), 2)

			if onComplete then
				onComplete(false, "INVALID_ID")
			end

			return
		end

		local customData, deserializeErr = AvatarShareService.deserializePayload(payload)

		if not customData then
			pg.global.showBubbleMessageRaw(pg.getGameString(deserializeErr or "INVALID_ID"), 2)

			if onComplete then
				onComplete(false, deserializeErr)
			end

			return
		end

		local ok, validateErr = AvatarShareService.validateImportPreconditions(customData)

		if not ok then
			pg.global.showBubbleMessageRaw(pg.getGameString(validateErr or "INVALID_ID"), 2)

			if onComplete then
				onComplete(false, validateErr)
			end

			return
		end

		AvatarShareService.saveOriginSnapshot(customData)

		local previewOk, previewErr = AvatarShareService.previewImport(id, payload)

		if not previewOk then
			AvatarShareService.rollbackPreview()
			pg.global.showBubbleMessageRaw(pg.getGameString(previewErr or "INVALID_ID"), 2)
		end

		if onComplete then
			onComplete(previewOk, previewErr)
		end
	end)
end

function AvatarShareService.tryImportFromClipboard(expectedShareType)
	local buffer = string.trim(UIUtils.ClipboardReader() or "")

	if not AvatarShareService.isShareId(buffer) then
		return
	end

	AvatarShareService.download(buffer, function(success, payload)
		if not success then
			return
		end

		local customData, errKey = AvatarShareService.deserializePayload(payload)

		if not customData then
			pg.global.showBubbleMessageRaw(pg.getGameString(errKey or "INVALID_ID"), 2)
			UIUtils.ClipboardWriter("")

			return
		end

		local shareType = getShareType(customData)

		if expectedShareType == AvatarShareService.SHARE_TYPE.CLOTHES then
			if shareType ~= AvatarShareService.SHARE_TYPE.CLOTHES then
				return
			end
		elseif shareType == AvatarShareService.SHARE_TYPE.CLOTHES then
			return
		end

		local ok, validateErr = AvatarShareService.validateImportPreconditions(customData)

		if not ok then
			pg.global.showBubbleMessageRaw(pg.getGameString(validateErr or "INVALID_ID"), 2)
			UIUtils.ClipboardWriter("")

			return
		end

		local cueKey = "IMPORT_AVATAR_CUE"

		if shareType == AvatarShareService.SHARE_TYPE.HAIR then
			cueKey = "IMPORT_HAIR_CUE"
		elseif shareType == AvatarShareService.SHARE_TYPE.CLOTHES then
			cueKey = "IMPORT_STAIN_CUE"
		end

		local desc = pg.getGameString(cueKey)

		ClientUtils.showConfirmRaw("", desc, function()
			AvatarShareService.saveOriginSnapshot(customData)

			local previewOk, previewErr = AvatarShareService.previewImport(buffer, payload)

			if not previewOk then
				AvatarShareService.rollbackPreview()
				pg.global.showBubbleMessageRaw(pg.getGameString(previewErr or "INVALID_ID"), 2)
			end

			UIUtils.ClipboardWriter("")
		end, false, function()
			UIUtils.ClipboardWriter("")
		end)
	end)
end

local function openSharePanelAndUpload(avatarScene, customData, avatarType, cameraModeFn)
	local payload = AvatarShareService.serializePayload(customData)

	AvatarShareService.buildUniqueShareId(function(id)
		if not id then
			pg.global.showBubbleMessageRaw(pg.getGameString("INVALID_ID"), 2)

			return
		end

		pg.global.ui:open(UIConst.UI_ID_SHARE, {
			qrCodeText = id,
			avatarType = avatarType
		})
		avatarScene:setCurEntityRot(0, 0.5)
		cameraModeFn(avatarScene)
		pg.game.input:setEnabledViewCtrl(false, ClientConst.ViewControl.SHARE_SNAPSHOT)
		TimerManager.addTimer(avatarScene.cameraDuration, function()
			local sizeDelta = Vector2.New(Screen.width, Screen.height)
			local position = Vector2.New(Screen.width / 2 - sizeDelta.x / 2, Screen.height / 2 - sizeDelta.y / 2)

			Utils.captureAndCheckPhoto(Const.PhotoCheckScene.Share, function(sprite, imgUrl, success)
				pg.game.input:setEnabledViewCtrl(true, ClientConst.ViewControl.SHARE_SNAPSHOT)

				if not success then
					pg.global.ui.share:closePanel()

					return
				end

				pg.global.ui.share:setScreenShot(sprite)
				AvatarShareService.upload(id, payload, function(uploadOk)
					if uploadOk then
						pg.global.showBubbleMessageRaw(pg.getGameString("UPLOAD_AVATAR_SUCCESS"), 2)
					else
						pg.global.showBubbleMessageRaw(pg.getGameString("INVALID_ID"), 2)
					end
				end)
			end, position, sizeDelta, 1, false, false)
		end)
	end)
end

function AvatarShareService.exportFace()
	local avatarScene, entity = AvatarShareService.getAvatarContext()

	if not avatarScene or not entity then
		return
	end

	local customData, errKey = AvatarShareService.encodeFaceData(entity)

	if not customData then
		pg.global.showBubbleMessageRaw(pg.getGameString(errKey or "INVALID_ID"), 2)

		return
	end

	local AvatarUtils = require("Guis.Utils.AvatarUtils")

	openSharePanelAndUpload(avatarScene, customData, AvatarUtils.AVATAR_TYPE.FACE, function(scene)
		scene:setAvatarCameraModeFar()
	end)
end

function AvatarShareService.exportHair()
	local avatarScene, entity = AvatarShareService.getAvatarContext()

	if not avatarScene or not entity then
		return
	end

	local presetKey = entity.eModel.modelModelView.modelInfo:GetPresetKey()
	local customData, errKey = AvatarShareService.encodeHairData(entity, avatarScene, presetKey)

	if not customData then
		pg.global.showBubbleMessageRaw(pg.getGameString(errKey or "INVALID_ID"), 2)

		return
	end

	local AvatarUtils = require("Guis.Utils.AvatarUtils")

	openSharePanelAndUpload(avatarScene, customData, AvatarUtils.AVATAR_TYPE.HAIR, function(scene)
		scene:setAvatarCameraModeCloseHead()
	end)
end

function AvatarShareService.exportClothes()
	local model = getWorkShopCostumeStainModel()

	if not model or not model.avatarScene then
		return
	end

	local clothId = model.clothId
	local slotId = model.slotId
	local customData, errKey = AvatarShareService.encodeClothesData(clothId, slotId, model.curUnit)

	if not customData then
		pg.global.showBubbleMessageRaw(pg.getGameString(errKey or "INVALID_ID"), 2)

		return
	end

	local AvatarUtils = require("Guis.Utils.AvatarUtils")

	openSharePanelAndUpload(model.avatarScene, customData, AvatarUtils.AVATAR_TYPE.CLOTHES, function()
		model:initAvatarSceneData(true)
	end)
end

function AvatarShareService.openImportPanel(shareType)
	pg.global.ui:open(UIConst.UI_ID_AVATAR_IMPORT, {
		shareType = shareType or AvatarShareService.SHARE_TYPE.FACE
	})
end

return AvatarShareService
