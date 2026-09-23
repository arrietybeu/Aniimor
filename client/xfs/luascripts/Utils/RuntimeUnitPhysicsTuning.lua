-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\RuntimeUnitPhysicsTuning.lua

local CommonConst = require("Common.Const.Const")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Utils = require("Common.Utils.Utils")
local RigidbodyData = require("Data.rigidbody_data")
local AbilityConst = require("Common.Const.AbilityConst")
local ClientDebugUtils = require("Utils.ClientDebugUtils")
local ClientAbilityConst = require("Const.ClientAbilityConst")
local SysConfigData = require("Data.sys_config_data")
local logger = LoggerManager.getLogger("RuntimeUnitPhysicsTuning")
local Vector3 = Vector3
local Color = Color
local RuntimeUnitPhysicsTuning = {
	previewModelHeight = true,
	previewHitBody = true,
	previewRb = true,
	previewAll = false,
	previewAppliedAll = false,
	prefsPrefix = "runtimeUnitPhysicsTuning_",
	originalMap = {},
	overrideMap = {}
}
local FIELD_KEYS = {
	useFinalValue = "useFinalValue",
	realModelHeight = "realModelHeight",
	finalBodyHeight = "finalBodyHeight",
	finalBodySize = "finalBodySize",
	modelHeight = "modelHeight",
	bodyHeight = "bodyHeight",
	bodySize = "bodySize",
	rbCenterManual = "rbCenterManual",
	rbCenterY = "rbCenterY",
	combatCenterY = "combatCenterY",
	combatHeight = "combatHeight",
	combatRadius = "combatRadius",
	finalRbHeight = "finalRbHeight",
	finalRbRadius = "finalRbRadius",
	rbHeight = "rbHeight",
	rbRadius = "rbRadius",
	rigidbody = "rigidbody",
	actorId = "actorId"
}

local function getPrefs()
	return pg and pg.global and pg.global.prefsCacheUtils
end

local function getPrefKey(key)
	return RuntimeUnitPhysicsTuning.prefsPrefix .. key
end

local function roundNumber(value)
	if type(value) ~= "number" then
		return ""
	end

	local text = string.format("%.4f", value)

	text = string.gsub(text, "0+$", "")
	text = string.gsub(text, "%.$", "")

	return text == "-0" and "0" or text
end

local function roundOptionalNumber(value)
	if type(value) ~= "number" then
		return "nil"
	end

	return roundNumber(value)
end

local function formatNumberList(values)
	if type(values) ~= "table" then
		return "nil"
	end

	local result = {}

	for i, value in ipairs(values) do
		result[i] = roundOptionalNumber(value)
	end

	return "{" .. table.concat(result, ", ") .. "}"
end

local function getVectorY(center)
	if center == nil then
		return nil
	end

	return center.y or center[2]
end

local function makeCenter(x, y, z)
	return {
		x or 0,
		y or 0,
		z or 0
	}
end

local function copyCenter(center, fallbackHeight)
	if center == nil then
		return makeCenter(0, (fallbackHeight or 0) * 0.5, 0)
	end

	return makeCenter(center.x or center[1] or 0, center.y or center[2] or 0, center.z or center[3] or 0)
end

local function cloneRbData(rbData, rbId)
	if not rbData then
		return nil
	end

	local cloned = {}

	for k, v in pairs(rbData) do
		cloned[k] = v
	end

	cloned.id = rbId
	cloned.center = copyCenter(rbData.center, rbData.height)

	return cloned
end

local function getEntityScale(ent)
	return ent and ent.curModelScale or 1
end

local function getScaleDebugInfo(ent, configData, scale)
	local label = ent and ent.label or 0
	local scaleSource = "curModelScale"
	local sourceScale = scale

	if Utils.isLabelBoss(label) then
		scaleSource = "scaleBoss"
		sourceScale = configData and configData.scaleBoss or nil
	elseif Utils.isLabelElite(label) then
		scaleSource = "scaleElite"
		sourceScale = configData and configData.scaleElite or nil
	elseif configData and configData.modelScaleRange then
		scaleSource = "modelScaleRange"
	end

	return {
		label = label,
		scaleSource = scaleSource,
		sourceScale = sourceScale,
		scaleBoss = configData and configData.scaleBoss or nil,
		scaleElite = configData and configData.scaleElite or nil,
		modelScaleRange = configData and configData.modelScaleRange or nil
	}
end

local function getConfigFinalValue(configValue, scale)
	if type(configValue) ~= "number" then
		return nil
	end

	return configValue * (scale or 1)
end

local function getScaledRbValue(configValue, scale)
	if type(configValue) ~= "number" then
		return nil
	end

	return configValue * (scale or 1)
end

local function finalToConfig(finalValue, scale)
	if type(finalValue) ~= "number" then
		return nil
	end

	scale = scale or 1

	if scale == 0 then
		return nil
	end

	return finalValue / scale
end

local function getCombatColliderValues(finalRbRadius, finalRbHeight, ent)
	if not Utils.isPuppet(ent) and not ent.isMainPlayer and not ent.isMainPet or type(finalRbRadius) ~= "number" or type(finalRbHeight) ~= "number" then
		return nil, nil, nil
	end

	local minR = SysConfigData.enemyExtraCollideRadiusMin or 0
	local radius = finalRbRadius + minR

	if finalRbHeight < radius then
		return radius, radius * 2, 0
	end

	return radius, radius + finalRbHeight, (finalRbHeight - radius) * 0.5
end

local function parseNumber(value)
	if value == nil or value == "" then
		return nil
	end

	return tonumber(value)
end

local function parseBoolNumber(value)
	local n = tonumber(value)

	return n ~= nil and n ~= 0
end

local function showTip(text)
	if pg and pg.global and pg.global.ui and pg.global.ui.tips then
		pg.global.ui.tips:showTextTip(text)
	end
end

local function copyToClipboard(text)
	if CS and CS.FunPlus and CS.FunPlus.WorldX and CS.FunPlus.WorldX.Utils and CS.FunPlus.WorldX.Utils.UIUtils then
		CS.FunPlus.WorldX.Utils.UIUtils.ClipboardWriter(text)
	elseif CS and CS.UnityEngine and CS.UnityEngine.GUIUtility then
		CS.UnityEngine.GUIUtility.systemCopyBuffer = text
	end
end

local function getConfigTableName(ent)
	if not ent then
		return "unknown_config"
	end

	if Utils.isPet(ent) then
		return "pet_base_prototype_data"
	elseif Utils.isPuppet(ent) then
		return "puppet_data"
	elseif Utils.isEnvObj(ent) then
		return "envobj_data"
	end

	return tostring(ent.className or ent.actorType or "unknown_config")
end

local function getEntityDisplayName(ent, configData)
	if not ent then
		return ""
	end

	configData = configData or Utils.getEntityConfigData(ent)

	if type(configData.editorName) == "string" and configData.editorName ~= "" then
		return configData.editorName
	end

	if type(configData.uiName) == "string" and configData.uiName ~= "" then
		return configData.uiName
	end

	if type(ent.name) == "string" and ent.name ~= "" then
		return ent.name
	end

	if type(ent.nickName) == "string" and ent.nickName ~= "" then
		return ent.nickName
	end

	if type(ent.className) == "string" and ent.className ~= "" then
		return ent.className
	end

	return tostring(configData.name or "")
end

local function getActorId(ent)
	return ent and ent.actorId or nil
end

local function getCurrentPet()
	if pg and pg.me and pg.me.getCurPetEntity then
		local pet = pg.me:getCurPetEntity()

		if pet then
			return pet
		end
	end

	if pg and pg.me and pg.me.curCombatPetId then
		return pg.getEntity(pg.me.curCombatPetId) or pg.getEntityByActorId(pg.me.curCombatPetId)
	end

	return nil
end

local function getLockedTarget()
	if pg and pg.me and pg.me.lockedActorId and pg.me.lockedActorId ~= 0 then
		return pg.getEntityByActorId(pg.me.lockedActorId)
	end

	if pg and pg.pawn and pg.pawn.getAttackTargetActorId then
		local actorId = pg.pawn:getAttackTargetActorId()

		return actorId and pg.getEntityByActorId(actorId) or nil
	end

	return nil
end

local function getPhysxComponent(ent)
	if not ent or not ent.hasEModelComponent or not ent:hasEModelComponent(CommonConst.COMPONENT_IDX_PHYSX) then
		return nil
	end

	return ent:getEModelMonoComponent(CommonConst.COMPONENT_IDX_PHYSX)
end

local function refreshRuntimePhysx(ent, snapshot)
	local physxComponent = getPhysxComponent(ent)

	if not physxComponent or not snapshot then
		return
	end

	local center = snapshot.rbCenter

	ent.eModel:GenCapsule(CommonConst.COMPONENT_IDX_PHYSX, snapshot.rbRadius, snapshot.rbHeight, Vector3.New(center[1] or 0, center[2] or snapshot.rbHeight * 0.5, center[3] or 0), ToBool(snapshot.rbTrigger), false, true)

	if Utils.isPuppet(ent) and snapshot.combatRadius and snapshot.combatHeight and snapshot.combatCenterY then
		ent.eModel:GenCombatCollider(CommonConst.COMPONENT_IDX_PHYSX, snapshot.combatRadius, snapshot.combatHeight, snapshot.combatCenterY)
	end
end

local function refreshRuntimeCameraHeight(ent, snapshot)
	if not ent or not ent.eModel or not snapshot or not snapshot.realModelHeight then
		return
	end

	ent.eModel.cameraHitCheckHeight = snapshot.realModelHeight
end

local function restoreGlobalRbColliderPreview(ent)
	if Switch and Switch.EnableDrawRbCollider and ent and ent.enableDrawRbCollider then
		ent:enableDrawRbCollider(true)

		return true
	end

	return false
end

local function refreshRuntimePreviewMeshes(ent, snapshot, enableRb, enableHitBody)
	local physxComponent = getPhysxComponent(ent)

	if not physxComponent or not snapshot then
		return
	end

	local center = snapshot.rbCenter or {}
	local rbArgs = {
		snapshot.finalRbRadius or snapshot.rbRadius,
		snapshot.finalRbHeight or snapshot.rbHeight,
		(center[2] or snapshot.rbHeight * 0.5) * (snapshot.curModelScale or 1)
	}

	if ToBool(enableRb) then
		ent.eModel:SetRbColliderMeshActive(CommonConst.COMPONENT_IDX_PHYSX, true, AbilityConst.LX_GEOMETRY_TYPE_CAPSULE, rbArgs, Color(0, 0, 1, 0.28))

		if Utils.isPuppet(ent) then
			ent.eModel:SetCombatColliderMeshActive(CommonConst.COMPONENT_IDX_PHYSX, true, ClientAbilityConst.MESH_COMBAT_COLLIDER_COLOR)
		end
	elseif not restoreGlobalRbColliderPreview(ent) then
		ent.eModel:SetRbColliderMeshActive(CommonConst.COMPONENT_IDX_PHYSX, false, AbilityConst.LX_GEOMETRY_TYPE_CAPSULE, rbArgs, Color(0, 0, 1, 0.28))

		if Utils.isPuppet(ent) then
			ent.eModel:SetCombatColliderMeshActive(CommonConst.COMPONENT_IDX_PHYSX, false, ClientAbilityConst.MESH_COMBAT_COLLIDER_COLOR)
		end
	end

	ent.eModel:SetHitBoxMeshActive(CommonConst.COMPONENT_IDX_PHYSX, ToBool(enableHitBody), AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D, {
		snapshot.finalBodySize or snapshot.bodySize,
		snapshot.finalBodyHeight or snapshot.bodyHeight,
		0
	}, ClientAbilityConst.MESH_HIT_BODY_COLOR)
end

local function drawModelHeightPreview(ent)
	if not ent or not ent.getPosition then
		return
	end

	local override = RuntimeUnitPhysicsTuning.overrideMap[tonumber(ent.actorId)]
	local modelHeight = override and override.realModelHeight or ent.getRealHeight and ent:getRealHeight()

	if not modelHeight or modelHeight <= 0 then
		return
	end

	local pos = ent:getPosition()
	local offset = 0.7
	local thickness = 0.01
	local uidPrefix = string.format("RuntimeUnitPhysicsTuning_ModelHeight_%s_%s_", tostring(ent.actorId or ent.id or ""), roundNumber(modelHeight))

	ClientDebugUtils.drawUniqueDebugMesh(uidPrefix .. "vertical", pos + Vector3(offset, modelHeight * 0.5, 0), nil, AbilityConst.LX_GEOMETRY_TYPE_BOX, {
		thickness,
		modelHeight * 0.5,
		thickness
	}, 0.25, Color(1, 0.05, 0.95, 0.85))
	ClientDebugUtils.drawUniqueDebugMesh(uidPrefix .. "topBar", pos + Vector3(offset * 0.5, modelHeight, 0), nil, AbilityConst.LX_GEOMETRY_TYPE_BOX, {
		offset * 0.5,
		thickness,
		thickness
	}, 0.25, Color(1, 0.05, 0.95, 0.85))
end

function RuntimeUnitPhysicsTuning.refreshModelHeightPreview()
	if not RuntimeUnitPhysicsTuning.previewModelHeight then
		return
	end

	if RuntimeUnitPhysicsTuning.previewAll then
		local entities = pg and pg.getEntities and pg.getEntities()

		if not entities then
			return
		end

		for _, entity in pairs(entities) do
			drawModelHeightPreview(entity)
		end

		return
	end

	drawModelHeightPreview(RuntimeUnitPhysicsTuning.getEntity(RuntimeUnitPhysicsTuning.previewActorId))
end

local function setEntityPreview(ent, enableRb, enableHitBody, enableModelHeight)
	if not ent then
		return
	end

	enableRb = ToBool(enableRb)
	enableHitBody = ToBool(enableHitBody)
	enableModelHeight = ToBool(enableModelHeight)

	local override = RuntimeUnitPhysicsTuning.overrideMap[tonumber(ent.actorId)]
	local snapshot = override or RuntimeUnitPhysicsTuning.buildSnapshot(ent)

	if snapshot then
		refreshRuntimePreviewMeshes(ent, snapshot, enableRb, enableHitBody)
	end

	if enableModelHeight then
		drawModelHeightPreview(ent)
	end
end

local function setAllEntityPreview(enableRb, enableHitBody, enableModelHeight)
	local entities = pg and pg.getEntities and pg.getEntities()

	if not entities then
		return
	end

	for _, entity in pairs(entities) do
		setEntityPreview(entity, enableRb, enableHitBody, enableModelHeight)
	end
end

function RuntimeUnitPhysicsTuning.getTargetActorId(targetType)
	local ent

	if targetType == "hero" then
		ent = pg and pg.me
	elseif targetType == "pet" then
		ent = getCurrentPet()
	elseif targetType == "lock" then
		ent = getLockedTarget()
	else
		ent = pg and (pg.pawn or pg.me)
	end

	return tostring(getActorId(ent) or "")
end

function RuntimeUnitPhysicsTuning.setPreviewTarget(actorId)
	local oldActorId = RuntimeUnitPhysicsTuning.previewActorId

	if oldActorId and tonumber(oldActorId) ~= tonumber(actorId) and not RuntimeUnitPhysicsTuning.previewAll then
		setEntityPreview(RuntimeUnitPhysicsTuning.getEntity(oldActorId), false, false, false)

		RuntimeUnitPhysicsTuning.previewAppliedActorId = nil
	end

	RuntimeUnitPhysicsTuning.previewActorId = tonumber(actorId)

	RuntimeUnitPhysicsTuning.refreshPreview()
end

function RuntimeUnitPhysicsTuning.setPreviewOptions(previewRb, previewHitBody, previewModelHeight, previewAll)
	local oldPreviewAll = RuntimeUnitPhysicsTuning.previewAll

	RuntimeUnitPhysicsTuning.previewRb = ToBool(previewRb)
	RuntimeUnitPhysicsTuning.previewHitBody = ToBool(previewHitBody)
	RuntimeUnitPhysicsTuning.previewModelHeight = ToBool(previewModelHeight)
	RuntimeUnitPhysicsTuning.previewAll = ToBool(previewAll)

	if oldPreviewAll and not RuntimeUnitPhysicsTuning.previewAll then
		setAllEntityPreview(false, false, false)

		RuntimeUnitPhysicsTuning.previewAppliedAll = false
	end

	RuntimeUnitPhysicsTuning.refreshPreview()
end

function RuntimeUnitPhysicsTuning.setPreview(actorId, previewRb, previewHitBody, previewModelHeight, previewAll)
	local oldActorId = RuntimeUnitPhysicsTuning.previewActorId
	local oldPreviewAll = RuntimeUnitPhysicsTuning.previewAll

	RuntimeUnitPhysicsTuning.previewActorId = tonumber(actorId)
	RuntimeUnitPhysicsTuning.previewRb = ToBool(previewRb)
	RuntimeUnitPhysicsTuning.previewHitBody = ToBool(previewHitBody)
	RuntimeUnitPhysicsTuning.previewModelHeight = ToBool(previewModelHeight)
	RuntimeUnitPhysicsTuning.previewAll = ToBool(previewAll)

	if oldPreviewAll and not RuntimeUnitPhysicsTuning.previewAll then
		setAllEntityPreview(false, false, false)

		RuntimeUnitPhysicsTuning.previewAppliedAll = false
	elseif oldActorId and oldActorId ~= RuntimeUnitPhysicsTuning.previewActorId and not RuntimeUnitPhysicsTuning.previewAll then
		setEntityPreview(RuntimeUnitPhysicsTuning.getEntity(oldActorId), false, false, false)

		RuntimeUnitPhysicsTuning.previewAppliedActorId = nil
	end

	RuntimeUnitPhysicsTuning.refreshPreview()
end

function RuntimeUnitPhysicsTuning.refreshPreview()
	if RuntimeUnitPhysicsTuning.previewAll then
		setAllEntityPreview(RuntimeUnitPhysicsTuning.previewRb, RuntimeUnitPhysicsTuning.previewHitBody, RuntimeUnitPhysicsTuning.previewModelHeight)

		RuntimeUnitPhysicsTuning.previewAppliedAll = true
		RuntimeUnitPhysicsTuning.previewAppliedActorId = nil

		return
	end

	if RuntimeUnitPhysicsTuning.previewAppliedAll then
		setAllEntityPreview(false, false, false)

		RuntimeUnitPhysicsTuning.previewAppliedAll = false
	elseif RuntimeUnitPhysicsTuning.previewAppliedActorId and RuntimeUnitPhysicsTuning.previewAppliedActorId ~= RuntimeUnitPhysicsTuning.previewActorId then
		setEntityPreview(RuntimeUnitPhysicsTuning.getEntity(RuntimeUnitPhysicsTuning.previewAppliedActorId), false, false, false)
	end

	setEntityPreview(RuntimeUnitPhysicsTuning.getEntity(RuntimeUnitPhysicsTuning.previewActorId), RuntimeUnitPhysicsTuning.previewRb, RuntimeUnitPhysicsTuning.previewHitBody, RuntimeUnitPhysicsTuning.previewModelHeight)

	RuntimeUnitPhysicsTuning.previewAppliedActorId = RuntimeUnitPhysicsTuning.previewActorId
end

function RuntimeUnitPhysicsTuning.clearPreview()
	if RuntimeUnitPhysicsTuning.previewAppliedAll then
		setAllEntityPreview(false, false, false)
	elseif RuntimeUnitPhysicsTuning.previewAppliedActorId then
		setEntityPreview(RuntimeUnitPhysicsTuning.getEntity(RuntimeUnitPhysicsTuning.previewAppliedActorId), false, false, false)
	end

	RuntimeUnitPhysicsTuning.previewAppliedAll = false
	RuntimeUnitPhysicsTuning.previewAppliedActorId = nil
end

function RuntimeUnitPhysicsTuning.getSaveKey(key)
	return getPrefKey(key)
end

function RuntimeUnitPhysicsTuning.getFieldKeys()
	return FIELD_KEYS
end

function RuntimeUnitPhysicsTuning.getTargetSummary(actorId)
	local ent = RuntimeUnitPhysicsTuning.getEntity(actorId)

	if not ent then
		return "未读取到目标单位"
	end

	local configData = Utils.getEntityConfigData(ent)

	return string.format("%s  actorId=%s  templateId=%s  entityId=%s", getEntityDisplayName(ent, configData), tostring(ent.actorId or ""), tostring(ent.templateId or ""), tostring(ent.id or ""))
end

function RuntimeUnitPhysicsTuning.getEntity(actorId)
	actorId = tonumber(actorId)

	if not actorId then
		return nil
	end

	if pg and pg.getEntityByActorId then
		return pg.getEntityByActorId(actorId)
	end

	return nil
end

function RuntimeUnitPhysicsTuning.buildSnapshot(ent)
	if not ent then
		return nil, "找不到目标单位"
	end

	local configData = Utils.getEntityConfigData(ent)
	local rigidbodyId = configData.rigidbody
	local rigidbodyData = rigidbodyId and RigidbodyData[rigidbodyId]
	local rbHeight = rigidbodyData and rigidbodyData.height or 0.1
	local rbCenter = copyCenter(rigidbodyData and rigidbodyData.center, rbHeight)
	local scale = getEntityScale(ent)
	local bodySizeConfig = configData.bodySize or finalToConfig(ent.bodySize, scale) or ent.bodySize
	local bodyHeightConfig = configData.bodyHeight or finalToConfig(ent.bodyHeight, scale) or ent.bodyHeight
	local modelHeightConfig = configData.modelHeight
	local scaleDebug = getScaleDebugInfo(ent, configData, scale)
	local finalRbRadius = getScaledRbValue(rigidbodyData and rigidbodyData.radius or 0.1, scale)
	local finalRbHeight = getScaledRbValue(rbHeight, scale)
	local combatRadius, combatHeight, combatCenterY = getCombatColliderValues(finalRbRadius, finalRbHeight, ent)

	return {
		actorId = ent.actorId,
		entityId = ent.id,
		templateId = ent.templateId,
		label = scaleDebug.label,
		targetName = getEntityDisplayName(ent, configData),
		actorType = ent.actorType,
		className = ent.className,
		configTable = getConfigTableName(ent),
		scaleSource = scaleDebug.scaleSource,
		sourceScale = scaleDebug.sourceScale,
		scaleBoss = scaleDebug.scaleBoss,
		scaleElite = scaleDebug.scaleElite,
		modelScaleRange = scaleDebug.modelScaleRange,
		rigidbody = rigidbodyId,
		rbRadius = rigidbodyData and rigidbodyData.radius or 0.1,
		rbHeight = rbHeight,
		finalRbRadius = finalRbRadius,
		finalRbHeight = finalRbHeight,
		combatRadius = combatRadius,
		combatHeight = combatHeight,
		combatCenterY = combatCenterY,
		rbCenter = rbCenter,
		rbCenterManual = rigidbodyData and rigidbodyData.center ~= nil or false,
		rbTrigger = rigidbodyData and ToBool(rigidbodyData.trigger) or false,
		bodySize = bodySizeConfig,
		bodyHeight = bodyHeightConfig,
		modelHeight = modelHeightConfig,
		curModelScale = scale,
		finalBodySize = getConfigFinalValue(bodySizeConfig, scale) or ent.bodySize,
		finalBodyHeight = getConfigFinalValue(bodyHeightConfig, scale) or ent.bodyHeight,
		realModelHeight = getConfigFinalValue(modelHeightConfig, scale)
	}
end

function RuntimeUnitPhysicsTuning.saveSnapshotToPrefs(snapshot)
	local prefs = getPrefs()

	if not prefs or not snapshot then
		return
	end

	prefs:setString(getPrefKey(FIELD_KEYS.actorId), tostring(snapshot.actorId or ""))
	prefs:setString(getPrefKey(FIELD_KEYS.rigidbody), tostring(snapshot.rigidbody or ""))
	prefs:setString(getPrefKey(FIELD_KEYS.rbRadius), roundNumber(snapshot.rbRadius))
	prefs:setString(getPrefKey(FIELD_KEYS.rbHeight), roundNumber(snapshot.rbHeight))
	prefs:setString(getPrefKey(FIELD_KEYS.finalRbRadius), roundNumber(snapshot.finalRbRadius))
	prefs:setString(getPrefKey(FIELD_KEYS.finalRbHeight), roundNumber(snapshot.finalRbHeight))
	prefs:setString(getPrefKey(FIELD_KEYS.combatRadius), roundNumber(snapshot.combatRadius))
	prefs:setString(getPrefKey(FIELD_KEYS.combatHeight), roundNumber(snapshot.combatHeight))
	prefs:setString(getPrefKey(FIELD_KEYS.combatCenterY), roundNumber(snapshot.combatCenterY))
	prefs:setString(getPrefKey(FIELD_KEYS.rbCenterY), roundNumber(getVectorY(snapshot.rbCenter)))
	prefs:setString(getPrefKey(FIELD_KEYS.rbCenterManual), snapshot.rbCenterManual and "1" or "0")
	prefs:setString(getPrefKey(FIELD_KEYS.bodySize), roundNumber(snapshot.bodySize))
	prefs:setString(getPrefKey(FIELD_KEYS.bodyHeight), roundNumber(snapshot.bodyHeight))
	prefs:setString(getPrefKey(FIELD_KEYS.modelHeight), roundNumber(snapshot.modelHeight))
	prefs:setString(getPrefKey(FIELD_KEYS.finalBodySize), roundNumber(snapshot.finalBodySize))
	prefs:setString(getPrefKey(FIELD_KEYS.finalBodyHeight), roundNumber(snapshot.finalBodyHeight))
	prefs:setString(getPrefKey(FIELD_KEYS.realModelHeight), roundNumber(snapshot.realModelHeight))
	prefs:setString(getPrefKey(FIELD_KEYS.useFinalValue), "0")
end

function RuntimeUnitPhysicsTuning.read(actorId)
	local ent = RuntimeUnitPhysicsTuning.getEntity(actorId)
	local snapshot, err = RuntimeUnitPhysicsTuning.buildSnapshot(ent)

	if not snapshot then
		showTip(err or "读取失败")

		return nil
	end

	RuntimeUnitPhysicsTuning.originalMap[snapshot.actorId] = RuntimeUnitPhysicsTuning.originalMap[snapshot.actorId] or snapshot

	RuntimeUnitPhysicsTuning.saveSnapshotToPrefs(snapshot)

	local text = RuntimeUnitPhysicsTuning.formatSnapshot(snapshot)

	copyToClipboard(text)

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("[UnitPhysicsTuning] read\n%s", text)
	end

	showTip("单位体型参数已读取并复制，刷新 GM 行可带入当前值")

	return snapshot
end

function RuntimeUnitPhysicsTuning.buildApplySnapshot(params)
	local actorId = tonumber(params.actorId)
	local ent = RuntimeUnitPhysicsTuning.getEntity(actorId)

	if not ent then
		return nil, "找不到 actorId"
	end

	local base = RuntimeUnitPhysicsTuning.overrideMap[actorId] or RuntimeUnitPhysicsTuning.originalMap[actorId] or RuntimeUnitPhysicsTuning.buildSnapshot(ent)

	if not base then
		return nil, "读取原始参数失败"
	end

	local scale = getEntityScale(ent)
	local configData = Utils.getEntityConfigData(ent)
	local scaleDebug = getScaleDebugInfo(ent, configData, scale)
	local bodySize = parseNumber(params.bodySize)
	local bodyHeight = parseNumber(params.bodyHeight)
	local modelHeight = parseNumber(params.modelHeight)
	local finalBodySize = parseNumber(params.finalBodySize)
	local finalBodyHeight = parseNumber(params.finalBodyHeight)
	local realModelHeight = parseNumber(params.realModelHeight)
	local useFinalValue = parseBoolNumber(params.useFinalValue)

	if (bodySize == nil or useFinalValue) and finalBodySize ~= nil then
		bodySize = finalToConfig(finalBodySize, scale)
	end

	if (bodyHeight == nil or useFinalValue) and finalBodyHeight ~= nil then
		bodyHeight = finalToConfig(finalBodyHeight, scale)
	end

	if (modelHeight == nil or useFinalValue) and realModelHeight ~= nil then
		modelHeight = finalToConfig(realModelHeight, scale)
	end

	bodySize = bodySize or base.bodySize
	bodyHeight = bodyHeight or base.bodyHeight
	modelHeight = modelHeight or base.modelHeight

	local rbHeight = parseNumber(params.rbHeight)
	local rbRadius = parseNumber(params.rbRadius)
	local finalRbRadius = parseNumber(params.finalRbRadius)
	local finalRbHeight = parseNumber(params.finalRbHeight)

	if (rbRadius == nil or useFinalValue) and finalRbRadius ~= nil then
		rbRadius = finalToConfig(finalRbRadius, scale)
	end

	if (rbHeight == nil or useFinalValue) and finalRbHeight ~= nil then
		rbHeight = finalToConfig(finalRbHeight, scale)
	end

	rbRadius = rbRadius or base.rbRadius
	rbHeight = rbHeight or base.rbHeight
	finalRbHeight = getScaledRbValue(rbHeight, scale)
	finalRbRadius = getScaledRbValue(rbRadius, scale)

	local combatRadius, combatHeight, combatCenterY = getCombatColliderValues(finalRbRadius, finalRbHeight, ent)
	local rbCenterManual = parseBoolNumber(params.rbCenterManual)
	local rbCenterY = parseNumber(params.rbCenterY)

	if not rbCenterManual or rbCenterY == nil then
		rbCenterY = rbHeight * 0.5
	end

	if not params.rigidbody or params.rigidbody == "" then
		params.rigidbody = base.rigidbody
	end

	if not params.rigidbody or params.rigidbody == "" then
		return nil, "rigidbody 为空"
	end

	if not RigidbodyData[params.rigidbody] and params.rigidbody ~= base.rigidbody then
		return nil, string.format("rigidbody id 不存在: %s", tostring(params.rigidbody))
	end

	if not rbRadius or rbRadius <= 0 then
		return nil, "rb.radius 必须大于 0"
	end

	if not rbHeight or rbHeight < rbRadius * 2 then
		return nil, "rb.height 必须大于等于 rb.radius * 2"
	end

	if not bodySize or bodySize <= 0 then
		return nil, "bodySize 必须大于 0"
	end

	if not bodyHeight or bodyHeight <= 0 then
		return nil, "bodyHeight 必须大于 0"
	end

	if modelHeight ~= nil and modelHeight <= 0 then
		return nil, "modelHeight 必须大于 0"
	end

	return {
		actorId = actorId,
		entityId = ent.id,
		templateId = ent.templateId,
		label = scaleDebug.label,
		targetName = getEntityDisplayName(ent, configData),
		actorType = ent.actorType,
		className = ent.className,
		configTable = getConfigTableName(ent),
		scaleSource = scaleDebug.scaleSource,
		sourceScale = scaleDebug.sourceScale,
		scaleBoss = scaleDebug.scaleBoss,
		scaleElite = scaleDebug.scaleElite,
		modelScaleRange = scaleDebug.modelScaleRange,
		rigidbody = params.rigidbody,
		rbRadius = rbRadius,
		rbHeight = rbHeight,
		finalRbRadius = finalRbRadius,
		finalRbHeight = finalRbHeight,
		combatRadius = combatRadius,
		combatHeight = combatHeight,
		combatCenterY = combatCenterY,
		rbCenter = makeCenter(0, rbCenterY, 0),
		rbCenterManual = rbCenterManual,
		rbTrigger = base.rbTrigger,
		bodySize = bodySize,
		bodyHeight = bodyHeight,
		modelHeight = modelHeight,
		curModelScale = scale,
		finalBodySize = bodySize * scale,
		finalBodyHeight = bodyHeight * scale,
		realModelHeight = modelHeight and modelHeight * scale or nil
	}, ent
end

function RuntimeUnitPhysicsTuning.applySnapshot(ent, snapshot, previewRb, previewHitBody, previewModelHeight)
	if not ent or not snapshot then
		return false
	end

	RuntimeUnitPhysicsTuning.overrideMap[snapshot.actorId] = snapshot
	RuntimeUnitPhysicsTuning.originalMap[snapshot.actorId] = RuntimeUnitPhysicsTuning.originalMap[snapshot.actorId] or RuntimeUnitPhysicsTuning.buildSnapshot(ent)
	ent.bodySize = snapshot.finalBodySize or snapshot.bodySize
	ent.bodyHeight = snapshot.finalBodyHeight or snapshot.bodyHeight

	if ent.aoi and snapshot.finalBodySize and snapshot.finalBodyHeight then
		ent.aoi:setHitBoxParam(AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D, 3, {
			ent.bodySize,
			ent.bodyHeight,
			0
		})
	end

	refreshRuntimePhysx(ent, snapshot)
	refreshRuntimeCameraHeight(ent, snapshot)
	RuntimeUnitPhysicsTuning.setPreviewTarget(snapshot.actorId)
	RuntimeUnitPhysicsTuning.setPreviewOptions(previewRb, previewHitBody, previewModelHeight, RuntimeUnitPhysicsTuning.previewAll)
	RuntimeUnitPhysicsTuning.saveSnapshotToPrefs(snapshot)

	return true
end

function RuntimeUnitPhysicsTuning.apply(params)
	local snapshot, entOrErr = RuntimeUnitPhysicsTuning.buildApplySnapshot(params)

	if not snapshot then
		showTip(entOrErr or "应用失败")

		return false
	end

	local ok = RuntimeUnitPhysicsTuning.applySnapshot(entOrErr, snapshot, params.previewRb, params.previewHitBody, params.previewModelHeight)

	if ok then
		local text = RuntimeUnitPhysicsTuning.formatSnapshot(snapshot)

		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("[UnitPhysicsTuning] apply\n%s", text)
		end

		showTip("单位体型参数已应用")
	end

	return ok
end

function RuntimeUnitPhysicsTuning.reset(actorId)
	actorId = tonumber(actorId)

	local original = RuntimeUnitPhysicsTuning.originalMap[actorId]
	local ent = RuntimeUnitPhysicsTuning.getEntity(actorId)

	if not ent then
		showTip("找不到 actorId")

		return false
	end

	original = original or RuntimeUnitPhysicsTuning.buildSnapshot(ent)
	RuntimeUnitPhysicsTuning.overrideMap[actorId] = nil
	ent.bodySize = original.finalBodySize or original.bodySize
	ent.bodyHeight = original.finalBodyHeight or original.bodyHeight

	if ent.aoi and ent.bodySize and ent.bodyHeight then
		ent.aoi:setHitBoxParam(AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D, 3, {
			ent.bodySize,
			ent.bodyHeight,
			0
		})
	end

	refreshRuntimePhysx(ent, original)
	refreshRuntimeCameraHeight(ent, original)
	RuntimeUnitPhysicsTuning.refreshPreview()
	RuntimeUnitPhysicsTuning.saveSnapshotToPrefs(original)
	showTip("已重置单位体型参数")

	return true
end

function RuntimeUnitPhysicsTuning.copy(actorId)
	local actorIdNumber = tonumber(actorId)
	local snapshot = RuntimeUnitPhysicsTuning.overrideMap[actorIdNumber]

	if not snapshot then
		local ent = RuntimeUnitPhysicsTuning.getEntity(actorIdNumber)

		snapshot = RuntimeUnitPhysicsTuning.buildSnapshot(ent)
	end

	if not snapshot then
		showTip("复制失败：找不到 actorId")

		return
	end

	local text = RuntimeUnitPhysicsTuning.formatSnapshot(snapshot)

	copyToClipboard(text)

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("[UnitPhysicsTuning] copy\n%s", text)
	end

	showTip("单位体型参数已复制")
end

function RuntimeUnitPhysicsTuning.readForWindow(actorId)
	local snapshot = RuntimeUnitPhysicsTuning.read(actorId)

	return snapshot ~= nil
end

function RuntimeUnitPhysicsTuning.applyForWindow(params)
	return RuntimeUnitPhysicsTuning.apply(params)
end

function RuntimeUnitPhysicsTuning.getWindowSnapshot(actorId)
	local actorIdNumber = tonumber(actorId)

	return RuntimeUnitPhysicsTuning.overrideMap[actorIdNumber] or RuntimeUnitPhysicsTuning.originalMap[actorIdNumber]
end

function RuntimeUnitPhysicsTuning.getWindowValue(actorId, key)
	local snapshot = RuntimeUnitPhysicsTuning.getWindowSnapshot(actorId)

	if not snapshot then
		return ""
	end

	if key == FIELD_KEYS.rbCenterY then
		return roundNumber(getVectorY(snapshot.rbCenter))
	end

	if key == FIELD_KEYS.rigidbody then
		return tostring(snapshot.rigidbody or "")
	end

	if key == "targetName" then
		return tostring(snapshot.targetName or "")
	end

	return roundNumber(snapshot[key])
end

function RuntimeUnitPhysicsTuning.getWindowBool(actorId, key)
	local snapshot = RuntimeUnitPhysicsTuning.getWindowSnapshot(actorId)

	return snapshot and ToBool(snapshot[key]) or false
end

function RuntimeUnitPhysicsTuning.getWindowText(actorId)
	local snapshot = RuntimeUnitPhysicsTuning.getWindowSnapshot(actorId)

	if not snapshot then
		return "未读取到目标单位"
	end

	return RuntimeUnitPhysicsTuning.formatSnapshot(snapshot)
end

function RuntimeUnitPhysicsTuning.formatSnapshot(snapshot)
	local centerY = getVectorY(snapshot.rbCenter)

	return string.format("actorId=%s\nentityId=%s\ntemplateId=%s\nlabel=%s\nname=%s\nclassName=%s\n%s:\n  rigidbody = %s\n  bodySize = %s\n  bodyHeight = %s\n  modelHeight = %s\nrigidbody_data:\n  %s.radius = %s\n  %s.height = %s\n  %s.center = {0, %s, 0}%s\nruntime:\n  scaleSource = %s\n  sourceScale = %s\n  scaleBoss = %s\n  scaleElite = %s\n  modelScaleRange = %s\n  curModelScale = %s\n  finalRbRadius = %s\n  finalRbHeight = %s\n  combatRadius = %s\n  combatHeight = %s\n  combatCenterY = %s\n  finalBodySize = %s\n  finalBodyHeight = %s\n  realModelHeight = %s\n", tostring(snapshot.actorId or ""), tostring(snapshot.entityId or ""), tostring(snapshot.templateId or ""), tostring(snapshot.label or ""), tostring(snapshot.targetName or ""), tostring(snapshot.className or ""), tostring(snapshot.configTable or "config"), tostring(snapshot.rigidbody or ""), roundNumber(snapshot.bodySize), roundNumber(snapshot.bodyHeight), roundNumber(snapshot.modelHeight), tostring(snapshot.rigidbody or ""), roundNumber(snapshot.rbRadius), tostring(snapshot.rigidbody or ""), roundNumber(snapshot.rbHeight), tostring(snapshot.rigidbody or ""), roundNumber(centerY), snapshot.rbCenterManual and " -- 手动 center.y" or " -- 默认半高", tostring(snapshot.scaleSource or ""), roundOptionalNumber(snapshot.sourceScale), roundOptionalNumber(snapshot.scaleBoss), roundOptionalNumber(snapshot.scaleElite), formatNumberList(snapshot.modelScaleRange), roundNumber(snapshot.curModelScale), roundNumber(snapshot.finalRbRadius), roundNumber(snapshot.finalRbHeight), roundNumber(snapshot.combatRadius), roundNumber(snapshot.combatHeight), roundNumber(snapshot.combatCenterY), roundNumber(snapshot.finalBodySize), roundNumber(snapshot.finalBodyHeight), roundNumber(snapshot.realModelHeight))
end

return RuntimeUnitPhysicsTuning
