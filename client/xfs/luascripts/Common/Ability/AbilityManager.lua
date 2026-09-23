-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\AbilityManager.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local AbilityConst = require("Common.Const.AbilityConst")
local CombatActionTool = require("Common.Ability.CombatActionTool")
local AbilityParamData = require("Data.ability_param_data")
local TimelineTemplate = require("Common.Ability.Timeline.TimelineTemplate")
local AbilityParamMapData = require("Common.Data.SkillBPData.abilityId2ParamId_BP")
local BuffConfigData = require("Data.buff_config_data")
local ECSConst = require("Const.ECSConst")
local ObjectPool = require("Common.Container.ObjectPool")
local ActionTimelineParams = require("Common.Ability.Timeline.ActionTimelineParams")
local CombatHitTargetInfo = require("Common.Ability.CombatHitTargetInfo")
local CombatCasterInfo = require("Common.Ability.CombatCasterInfo")
local Lume = require("Core.Common.lume")
local CombatContext = require("Common.Ability.CombatContext")
local CombatHitResult = require("Common.Ability.CombatHitResult")
local GuardValue = require("Common.Ability.GuardValue")
local MultiTargetsInfo = require("Common.Ability.MultiTargetsInfo")
local ProjectileParams = require("Common.Ability.Projectile.ProjectileParams")
local AttributeConst = require("Common.Const.AttributeConst")
local LxGeometry = require("Common.Ability.LxGeometry")
local CombatLogger = require("Common.Ability.CombatLogger")
local AttributeData = require("Data.attribute_id_data")
local Utils = require("Common.Utils.Utils")
local pg = pg
local ToBool = ToBool
local MAX_CACHE_CNT = 100

if pg.component == "game" then
	MAX_CACHE_CNT = 0
end

local AbilityManager = Class.LiteClass("AbilityManager")

function AbilityManager:returnTimelineConstCasterInfo(t)
	local constCasterInfo = t.constCasterInfo

	t.constCasterInfo = nil

	if constCasterInfo then
		CombatCasterInfo.convert(constCasterInfo)
		self.constCasterInfoPool:returnObject(constCasterInfo)
	end
end

function AbilityManager:returnCombatContextToPool(combatContext)
	if combatContext == nil then
		return
	end

	if rawget(combatContext, "isClone") then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			CombatLogger.warn("returnCombatContextToPool on clone, rejected", combatContext.id, combatContext.BPName, debug.traceback())
		end

		return
	end

	self.combatContextPool:returnObject(combatContext)
end

function AbilityManager:ctor()
	self:clear()

	self.tokenIdGen = AbilityConst.MIN_ID_GEN

	self:init()

	self.constCasterInfoPool = ObjectPool()

	self.constCasterInfoPool:setup(MAX_CACHE_CNT, function()
		return CombatCasterInfo()
	end, nil, function(t)
		t:clear()
	end)

	self.combatParamsPool = ObjectPool()

	self.combatParamsPool:setup(MAX_CACHE_CNT, function()
		return ActionTimelineParams.CombatActionTimelineParam()
	end, nil, function(t)
		self:returnTimelineConstCasterInfo(t)
		ActionTimelineParams.CombatActionTimelineParam.ctor(t)
	end)

	self.hitParamsPool = ObjectPool()

	self.hitParamsPool:setup(MAX_CACHE_CNT, function()
		return ActionTimelineParams.HitActionTimelineParam()
	end, nil, function(t)
		self:returnTimelineConstCasterInfo(t)
		ActionTimelineParams.HitActionTimelineParam.ctor(t)
	end)

	self.runtimeTargetInfoPool = ObjectPool()

	self.runtimeTargetInfoPool:setup(MAX_CACHE_CNT, function()
		return CombatHitTargetInfo()
	end, nil, function(t)
		Lume.clear(t)
	end)

	self.combatContextPool = ObjectPool()

	self.combatContextPool:setup(MAX_CACHE_CNT, function()
		return CombatContext()
	end, nil, function(combatContext)
		combatContext:clear()
	end)

	self.combatHitResultPool = ObjectPool()

	self.combatHitResultPool:setup(MAX_CACHE_CNT, function()
		return CombatHitResult()
	end, nil, function(t)
		Lume.clear(t)
	end)

	self.attributeChangeContextPool = ObjectPool()

	self.attributeChangeContextPool:setup(MAX_CACHE_CNT, function()
		return {}
	end, nil, function(t)
		Lume.clear(t)
	end)

	self.calcInfoTablePool = ObjectPool()

	self.calcInfoTablePool:setup(MAX_CACHE_CNT, function()
		return {}
	end, nil, function(t)
		Lume.clear(t)
	end)

	self.guardValuePool = ObjectPool()

	self.guardValuePool:setup(MAX_CACHE_CNT, function()
		return GuardValue()
	end, nil, function(t)
		t:recover()
	end)

	self.multiTargetInfoPool = ObjectPool()

	self.multiTargetInfoPool:setup(MAX_CACHE_CNT, function()
		return MultiTargetsInfo()
	end, nil, function(t)
		t:ctor()
	end)

	self.lxCirclePool = ObjectPool()

	self.lxCirclePool:setup(MAX_CACHE_CNT, function()
		return LxGeometry.LxCircle3D()
	end)

	self.lxSectorPool = ObjectPool()

	self.lxSectorPool:setup(MAX_CACHE_CNT, function()
		return LxGeometry.LxSector3D()
	end)

	self.lxTrapezoidPool = ObjectPool()

	self.lxTrapezoidPool:setup(MAX_CACHE_CNT, function()
		return LxGeometry.LxTrapezoid3D()
	end)

	self.lxAnnularSectorPool = ObjectPool()

	self.lxAnnularSectorPool:setup(MAX_CACHE_CNT, function()
		return LxGeometry.LxAnnularSector3D()
	end)

	self.lxSpherePool = ObjectPool()

	self.lxSpherePool:setup(MAX_CACHE_CNT, function()
		return LxGeometry.LxSphere()
	end)

	self.projectileParamsPool = ObjectPool()

	self.projectileParamsPool:setup(MAX_CACHE_CNT, function()
		return ProjectileParams()
	end, nil, function(t)
		Lume.clear(t)
	end)
end

function AbilityManager:getCurve(abilityId, curveType, rawData)
	if self.curveCache[curveType] == nil then
		self.curveCache[curveType] = {}
	end

	if self.curveCache[curveType][abilityId] == nil then
		local newCurve = CombatActionTool.parseCurveData(rawData)

		if newCurve ~= nil then
			self.curveCache[curveType][abilityId] = newCurve

			return newCurve
		end
	else
		return self.curveCache[curveType][abilityId]
	end
end

function AbilityManager:getBuffCurve(buffId, curveType, rawData)
	if self.buffCurveCache[curveType] == nil then
		self.buffCurveCache[curveType] = {}
	end

	if self.buffCurveCache[curveType][buffId] == nil then
		local newCurve = CombatActionTool.parseCurveData(rawData)

		if newCurve ~= nil then
			self.buffCurveCache[curveType][buffId] = newCurve

			return newCurve
		end
	else
		return self.buffCurveCache[curveType][buffId]
	end
end

function AbilityManager:getLevelArray(abilityId, levelArrayType, rawData)
	if self.levelArrayCache[levelArrayType] == nil then
		self.levelArrayCache[levelArrayType] = {}
	end

	if self.levelArrayCache[levelArrayType][abilityId] == nil then
		local newLevelArray = CombatActionTool.parseLevelArray(rawData)

		if newLevelArray ~= nil then
			self.levelArrayCache[levelArrayType][abilityId] = newLevelArray

			return newLevelArray
		end
	else
		return self.levelArrayCache[levelArrayType][abilityId]
	end
end

function AbilityManager:getBuffLevelArray(buffId, levelArrayType, rawData)
	if self.buffLevelArrayCache[levelArrayType] == nil then
		self.buffLevelArrayCache[levelArrayType] = {}
	end

	if self.buffLevelArrayCache[levelArrayType][buffId] == nil then
		local newLevelArray = CombatActionTool.parseLevelArray(rawData)

		if newLevelArray ~= nil then
			self.buffLevelArrayCache[levelArrayType][buffId] = newLevelArray

			return newLevelArray
		end
	else
		return self.buffLevelArrayCache[levelArrayType][buffId]
	end
end

function AbilityManager:init()
	self:clear()
end

function AbilityManager:clear()
	self.levelArrayCache = {}
	self.curveCache = {}
	self.abilityTemplateMap = {}
	self.timelineTemplateMap = {}
	self.buffLevelArrayCache = {}
	self.buffCurveCache = {}
	self.buffTemplateMap = {}
	self.abilityLevelAttributeMap = {}
	self.ecsElementCache = {}
	self.conditionTypesCache = {}
	self.projectileTemplateMap = {}
	self.attributeRangeMap = {}

	for attributeId = 1, AttributeConst.GROUP_END do
		local configData = AttributeData[AttributeConst.ID2NAME[attributeId]]
		local min = configData and configData.min or 0
		local max = configData and configData.max or math.maxInt

		self.attributeRangeMap[attributeId] = {
			min,
			max
		}
	end
end

function AbilityManager:isValidAbility(abilityId)
	return ToBool(self:getAbilityTemplate(abilityId, 1))
end

function AbilityManager:getAbilityTemplate(abilityId)
	if not abilityId then
		return nil
	end

	if self.abilityTemplateMap[abilityId] then
		return self.abilityTemplateMap[abilityId]
	end

	local result, info = xpcall(require, debug.traceback, "Common.Data.SkillBPData.AbilityBP.Ability_" .. tostring(abilityId))

	if result then
		self.abilityTemplateMap[abilityId] = info

		return info
	else
		self.abilityTemplateMap[abilityId] = {}

		return self.abilityTemplateMap[abilityId]
	end
end

function AbilityManager:getAbilityParamDataByParamId(abilityParamId)
	return AbilityParamData[abilityParamId] or {}
end

function AbilityManager:getAbilityParamId(abilityId, buffId)
	local paramId = AbilityParamMapData[abilityId]

	if paramId == nil then
		local cData = pg.global.abilityMgr:getAbilityTemplate(abilityId)

		if cData then
			paramId = cData.abilityParamId
		end
	end

	if paramId == nil and buffId then
		paramId = BuffConfigData[buffId].abilityParamId
	end

	return paramId
end

function AbilityManager:getAbilityParamData(abilityId, buffId)
	local paramId = AbilityParamMapData[abilityId]

	if paramId == nil then
		local cData = pg.global.abilityMgr:getAbilityTemplate(abilityId)

		if cData then
			paramId = cData.abilityParamId
		end
	end

	if paramId == nil and buffId then
		paramId = BuffConfigData[buffId].abilityParamId
	end

	return AbilityParamData[paramId] or {}
end

local _tagsSet = {}
local _emptySet = {}

function AbilityManager:existsTag(abilityId, targetTag)
	local tags = _tagsSet[abilityId]

	if tags == nil then
		local paramId = AbilityParamMapData[abilityId]

		if paramId == nil then
			local cData = self:getAbilityTemplate(abilityId)

			paramId = cData and cData.abilityParamId
		end

		local params = AbilityParamData[paramId]

		if params and params.tags then
			tags = {}

			for i, tag in ipairs(params.tags) do
				tags[tag] = true
			end
		else
			tags = _emptySet
		end

		_tagsSet[abilityId] = tags
	end

	return tags[targetTag]
end

function AbilityManager:getAbilityEpPower(ability)
	if ability == nil then
		return 1
	end

	local abilityId = ability.abilityId
	local abilityData = pg.global.abilityMgr:getAbilityTemplate(abilityId)

	if not abilityData then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("abilityData not found", abilityId)
		end

		return {}
	end

	local abilityParamId = abilityData.abilityParamId

	return AbilityParamData[abilityParamId] and AbilityParamData[abilityParamId].epPower or 0
end

function AbilityManager:getTimelineTemplate(timelineId)
	if not timelineId then
		return nil
	end

	local cached = self.timelineTemplateMap[timelineId]

	if cached ~= nil then
		return cached or nil
	end

	local result, data = xpcall(require, debug.traceback, "Common.Data.SkillBPData.TimelineBP.Timeline_" .. tostring(timelineId))

	if result then
		local timelineTemplate = TimelineTemplate(timelineId, data)

		self.timelineTemplateMap[timelineId] = timelineTemplate

		return timelineTemplate
	else
		self.timelineTemplateMap[timelineId] = false

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("timelineTemplate not found", timelineId)
		end

		return nil
	end
end

function AbilityManager:getBuffTemplate(buffId)
	if not buffId then
		return nil
	end

	if self.buffTemplateMap[buffId] then
		return self.buffTemplateMap[buffId]
	end

	local result, info = xpcall(require, debug.traceback, "Common.Data.SkillBPData.BuffBP.Buff_" .. tostring(buffId))

	if result then
		self.buffTemplateMap[buffId] = info

		return info
	else
		self.buffTemplateMap[buffId] = {}

		return self.buffTemplateMap[buffId]
	end
end

function AbilityManager:genTokenId()
	if self.tokenIdGen == AbilityConst.MAX_ID_GEN then
		self.tokenIdGen = AbilityConst.MIN_ID_GEN

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("tokenIdGen max")
		end
	end

	self.tokenIdGen = self.tokenIdGen + 1

	return self.tokenIdGen
end

function AbilityManager:getProjectileTemplate(templateId)
	if not templateId then
		return nil
	end

	if self.projectileTemplateMap[templateId] then
		return self.projectileTemplateMap[templateId]
	end

	local result, info = xpcall(require, debug.traceback, "Common.Data.SkillBPData.ProjectileBP.Projectile_" .. tostring(templateId))

	if result then
		self.projectileTemplateMap[templateId] = info

		return info
	else
		self.projectileTemplateMap[templateId] = {}

		return self.projectileTemplateMap[templateId]
	end
end

function AbilityManager:getVoxelCondition(abilityId, buffId, elementType)
	if not ToBool(abilityId) then
		return nil
	end

	local abilityType = self:getAbilityTemplate(abilityId).abilityType
	local elementType = elementType or self:getAbilityParamData(abilityId, buffId).elementType
	local condition

	if abilityType ~= AbilityConst.EnumAbilityType.Attack then
		local transfer = AbilityConst.ELEMENT_TYPE_2_CONDITION_TRANSFER

		condition = transfer[elementType]
	end

	return condition or AbilityConst.CONDITION_TYPE_NONE
end

function AbilityManager:getEcsElement(abilityId)
	if not ToBool(abilityId) then
		return nil
	end

	local cache = self.ecsElementCache[abilityId]

	if cache then
		return cache
	else
		local abilityType = self:getAbilityTemplate(abilityId).abilityType
		local elementType = self:getAbilityParamData(abilityId).elementType
		local element

		if abilityType ~= AbilityConst.EnumAbilityType.Attack then
			local transfer = ECSConst.ELEMENT_TYPE_2_ECS_ELEMENT

			element = transfer[elementType]
		end

		cache = element or ECSConst.ELEMENT_TYPE_NONE
		self.ecsElementCache[abilityId] = cache

		return cache
	end
end

function AbilityManager:hotfixAbility(id, fun)
	CombatLogger.debug("hotfixAbility", id)

	self.abilityTemplateMap[id] = nil

	local path = "Common.Data.SkillBPData.AbilityBP.Ability_" .. tostring(id)

	package.loaded[path] = nil

	local data = require(path)

	fun(data)

	self.abilityTemplateMap[id] = data
end

function AbilityManager:hotfixTimeline(id, fun)
	CombatLogger.debug("hotfixTimeline", id)

	self.timelineTemplateMap[id] = nil

	local path = "Common.Data.SkillBPData.TimelineBP.Timeline_" .. tostring(id)

	package.loaded[path] = nil

	local data = require(path)

	fun(data)

	self.timelineTemplateMap[id] = TimelineTemplate(id, data)
	package.loaded[path] = nil
end

function AbilityManager:hotfixProjectile(id, fun)
	CombatLogger.debug("hotfixProjectile", id)

	self.projectileTemplateMap[id] = nil

	local path = "Common.Data.SkillBPData.ProjectileBP.Projectile_" .. tostring(id)

	package.loaded[path] = nil

	local data = require(path)

	fun(data)

	self.projectileTemplateMap[id] = data
end

function AbilityManager:hotfixBuff(id, fun)
	CombatLogger.debug("hotfixBuff", id)

	self.buffTemplateMap[id] = nil

	local path = "Common.Data.SkillBPData.BuffBP.Buff_" .. tostring(id)

	package.loaded[path] = nil

	local data = require(path)

	fun(data)

	self.buffTemplateMap[id] = data
end

function AbilityManager:loadAllFileInServerStart()
	local serverScript
	local dirs = {
		"Common/Data/SkillBPData/BuffBP/",
		"Common/Data/SkillBPData/ProjectileBP/",
		"Common/Data/SkillBPData/TimelineBP/",
		"Common/Data/SkillBPData/AbilityBP/"
	}
	local ServerMethod = require("ServerMethod")
	local lfs = require("lfs")
	local fileName, module

	for _, dir in ipairs(dirs) do
		serverScript = package.rootPath .. "/Scripts/" .. dir

		if ServerMethod.isDirectoryExists(serverScript) then
			for f in lfs.dir(serverScript) do
				if string.endsWith(f, ".lua") then
					fileName = f:gsub("%.lua$", "")
					module = dir:gsub("%/", ".")

					require(module .. fileName)
				end
			end
		end
	end
end

return AbilityManager
