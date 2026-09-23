-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Ability\\ClientAbilityManager.lua

local Class = require("Core.Framework.Class")
local AbilityManager = require("Common.Ability.AbilityManager")
local ClientCombatAction = require("GameApp.Ability.ClientCombatAction")
local EditorCombatAction = require("Common.Ability.EditorCombatAction")
local ClientActorAttributeModifier = require("GameApp.Ability.ClientActorAttributeModifier")
local AbilityConst = require("Common.Const.AbilityConst")
local CombatActionTool = require("Common.Ability.CombatActionTool")
local Utils = require("Common.Utils.Utils")
local Buff = require("Common.Ability.Buff.Buff")
local ClientDebugUtils = require("Utils.ClientDebugUtils")
local VoxelUtils = require("Common.Utils.VoxelUtils")
local AddressDataConst = require("Const.AddressDataConst")
local Const = require("Common.Const.Const")
local GameObject = CS.UnityEngine.GameObject
local ClientAbilityConst = require("Const.ClientAbilityConst")
local VoxelReactionData = require("Common.Data.voxel_reaction_data")
local ClientSwitch = require("Common.ClientSwitch")
local pg = pg
local ToBool = ToBool
local IndicatorManager = CS.FunPlus.WorldX.RenderingScripts.Effect.IndicatorManager
local PHYSICS_TRAVERSE_SHAPE_ARG_COUNT = {
	[AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D] = 3,
	[AbilityConst.LX_GEOMETRY_TYPE_SECTOR3D] = 4,
	[AbilityConst.LX_GEOMETRY_TYPE_TRAPEZOID3D] = 5,
	[AbilityConst.LX_GEOMETRY_TYPE_ANNULARSECTOR3D] = 5
}
local ClientAbilityManager = Class.LiteClass("ClientAbilityManager", AbilityManager)

function ClientAbilityManager:ctor()
	AbilityManager.ctor(self)

	self.combatAction = ClientCombatAction()
	self.actorAttributeModifier = ClientActorAttributeModifier()
	self.effectInheritMap = {}
	self.indicatorManger = nil
	self.masterEntityLoadedCallback = {}
	self.isPlayingCutScene = false
	self.csharpManager = appFacade.abilityMgr
end

function ClientAbilityManager:addMasterEntityLoadedCallback(ent, callback)
	if ent.masterId then
		if not self.masterEntityLoadedCallback[ent.masterId] then
			self.masterEntityLoadedCallback[ent.masterId] = {
				callback
			}
		else
			table.insert(self.masterEntityLoadedCallback[ent.masterId], callback)
		end
	end
end

function ClientAbilityManager:onEntityLoaded(ent)
	if self.masterEntityLoadedCallback[ent.id] then
		for _, callback in ipairs(self.masterEntityLoadedCallback[ent.id]) do
			callback()
		end

		self.masterEntityLoadedCallback[ent.id] = nil
	end
end

function ClientAbilityManager:getIndicatorManager()
	if self.indicatorManger == nil then
		local effInsId = pg.me:playEffect("Eff_SkillIndicator_Comm", {
			duration = -1
		}, true)

		if not ToBool(effInsId) then
			return false
		end

		local effTrans = pg.me.eModel:GetEffect(Const.COMPONENT_INDEX_EFFECT, effInsId)

		self.indicatorManger = effTrans:GetComponent(typeof(IndicatorManager))
	end

	return self.indicatorManger
end

function ClientAbilityManager:loadCutSceneLocalTod()
	if not self.cutSceneLocalTod then
		pg.global.resMgr:GetInstanceFromCacheByLua(AddressDataConst.SKILL_EX_LOCAL_TOD, function(gameObj, userData)
			self.cutSceneLocalTod = gameObj
			self.cutSceneLocalTod.transform.position = ClientAbilityConst.PLAY_CUT_SCENE_POS

			GameObject.DontDestroyOnLoad(gameObj)
			self.cutSceneLocalTod:SetActiveEx(self.isPlayingCutScene)
		end)
	end

	return self.cutSceneLocalTod
end

function ClientAbilityManager:setIsPlayingCutScene(isPlaying)
	self.isPlayingCutScene = isPlaying

	if self.cutSceneLocalTod then
		self.cutSceneLocalTod:SetActiveEx(self.isPlayingCutScene)
	end

	if not isPlaying and self.stopCameraAniEnt then
		self.combatAction:doStopSkillCameraAnim(self.stopCameraAniEnt)
	end

	self.stopCameraAniEnt = nil
end

function ClientAbilityManager:physicsTraverseNearby(targetData, center, rot, attackerId, multiTargetsInfo)
	if not pg.me.useHitBoxEntityCnt or pg.me.useHitBoxEntityCnt <= 0 then
		return
	end

	local shapeKind = multiTargetsInfo.shapeKind
	local requiredArgCount = PHYSICS_TRAVERSE_SHAPE_ARG_COUNT[shapeKind]

	if not requiredArgCount then
		return
	end

	local shapeArgs = multiTargetsInfo.shapeArgs
	local shapeArgsType = type(shapeArgs)
	local isShapeArgsTable = Utils.isTable(shapeArgs)
	local shapeArgCount = isShapeArgsTable and #shapeArgs or 0

	if not isShapeArgsTable or shapeArgCount ~= requiredArgCount then
		CombatActionTool.logError(multiTargetsInfo.combatContext, multiTargetsInfo.actionData, "physicsTraverseNearby shapeArgs invalid", targetData.shapeKind, "requiredArgCount", requiredArgCount, "actualArgCount", shapeArgCount, "shapeArgsType", shapeArgsType)

		return
	end

	for idx = 1, requiredArgCount do
		local value = shapeArgs[idx]

		if type(value) ~= "number" or value < 0 or value ~= value or value == math.huge then
			CombatActionTool.logError(multiTargetsInfo.combatContext, multiTargetsInfo.actionData, "physicsTraverseNearby shapeArg invalid", targetData.shapeKind, "argIndex", idx, "argValue", value)

			return
		end
	end

	local function operationFun(actorId, partIdx, hitPosX, hitPosY, hitPosZ)
		return multiTargetsInfo:actOnTargetsOperatorFun(actorId, partIdx, hitPosX, hitPosY, hitPosZ)
	end

	local function preCheckFun(actorId)
		return multiTargetsInfo:actOnPartPreCheckFun(actorId)
	end

	if shapeKind == AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D then
		pg.global.physicsMgr:TraversePartCircle3D(center, rot, shapeArgs, attackerId, operationFun, preCheckFun)
	elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_SECTOR3D then
		pg.global.physicsMgr:TraversePartSector3D(center, rot, shapeArgs, attackerId, operationFun, preCheckFun)
	elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_TRAPEZOID3D then
		pg.global.physicsMgr:TraversePartTrapezoid3D(center, rot, shapeArgs, attackerId, operationFun, preCheckFun)
	elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_ANNULARSECTOR3D then
		pg.global.physicsMgr:TraversePartAnnularSector3D(center, rot, shapeArgs, attackerId, operationFun, preCheckFun)
	end
end

function ClientAbilityManager:boxSweep(startPos, rotation, extendX, extendY, extendZ, distance, actionData, combatContext)
	local conditionTypes = pg.global.abilityMgr.combatAction:getConditionTypes(combatContext, actionData)
	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)

	for _, conditionType in ipairs(conditionTypes) do
		local reactionName = AbilityConst.CONDITION_NUM_TO_STR[conditionType]
		local actions = VoxelReactionData[reactionName]

		if actions == nil then
			return
		end

		VoxelUtils.doSweepBoxVoxelReact(ownerEntity.space.id, reactionName, startPos, rotation, extendX, extendY, extendZ, distance)
	end

	if ClientSwitch.EnableDrawAbilityGizmo then
		ClientDebugUtils.drawBoxSweep(startPos, rotation, extendX, extendY, extendZ, distance, nil, tostring(combatContext.BPName) .. "#" .. tostring(actionData.NodeID))
	end

	return pg.global.physicsMgr:AbilityBoxSweep(startPos, rotation, extendX, extendY, extendZ, distance)
end

function ClientAbilityManager:createBuff(buffData)
	return Buff(buffData)
end

function ClientAbilityManager:switchRuntimeDebugMode(enable)
	if enable then
		self.combatAction = EditorCombatAction()
	else
		self.combatAction = ClientCombatAction()
	end
end

return ClientAbilityManager
