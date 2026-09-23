-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\AIAbility\\AIEnvQueryAbility.lua

local Class = require("Core.Framework.Class")
local AIBaseAbility = require("Common.AI.BehaviacAgent.Unit.AIAbility.AIBaseAbility")
local enums = require("Common.AI.Behaviac.Enums")
local Utils = require("Common.Utils.Utils")
local CalcUtils = require("Common.Utils.CalcUtils")
local AiConst = require("Common.Const.AiConst")
local MovementConst = AiConst.MovementConst
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local PlayableConst = require("Common.Const.PlayableConst")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("AIMoveAbility")
local lume = require("Core.Common.lume")
local VectorPool = require("Common.Container.VectorPool")
local ListPool = require("Common.Container.ListPool")
local CalcUtils = require("Common.Utils.CalcUtils")
local AIStartAppointedAreaData = require("Common.AI.BehaviacAgent.Unit.AIAbility.AIStartAppointedAreaData")
local AIAppointedAreaFunc = require("Common.AI.BehaviacAgent.Unit.AIAbility.AIAppointedAreaFunc")
local layer = require("Common.Const.PhysicsLayerConst")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local VoxelUtils = require("Common.Utils.VoxelUtils")
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local EBTStatus = enums.EBTStatus
local AIEnvQueryAbility = Class.LiteClass("AIEnvQueryAbility", AIBaseAbility)

function AIEnvQueryAbility:ctor()
	AIBaseAbility.ctor(self)

	self.queryList = {}
	self.filterQueryList = {}
	self.debugMode = false
end

function AIEnvQueryAbility:release()
	AIBaseAbility.release(self)

	if self.queryList then
		table.clearArray(self.queryList)
	end

	if self.filterQueryList then
		table.clearArray(self.filterQueryList)
	end

	self.debugMode = false
end

function AIEnvQueryAbility:startCalcQualifiedPos(basePos, rangeMin, rangeMax, queryType, simpleNum)
	for i = #self.queryList, 1, -1 do
		VectorPool.returnVector(self.queryList[i])

		self.queryList[i] = nil
	end

	for i = #self.filterQueryList, 1, -1 do
		self.filterQueryList[i] = nil
	end

	local spaceId = self.ent.space.id
	local height = self.ent:getRealHeight()

	for up = 1, -1, -1 do
		for right = 1, -1, -1 do
			if up == 0 and right == 0 then
				-- block empty
			else
				for i = 1, simpleNum do
					local pos = VectorPool.getVector()
					local range = rangeMin + (rangeMax - rangeMin) * i / simpleNum

					pos.x = basePos.x + right * range
					pos.z = basePos.z + up * range
					pos.y = basePos.y
					pos.y = VoxelUtils.getGroundY(spaceId, pos, height)
					self.queryList[#self.queryList + 1] = pos
				end
			end
		end
	end
end

function AIEnvQueryAbility:oneStepCheckQualifiedPos(queryStep, unobstructedActorId, outOfWater, findPath)
	local pos = self.queryList[queryStep]
	local ret = self:checkUnobstructed(pos, unobstructedActorId) and self:checkOutOfWater(pos, outOfWater) and self:checkFindPath(pos, findPath)

	if ret then
		self.filterQueryList[#self.filterQueryList + 1] = pos
	end
end

function AIEnvQueryAbility:isCalcQualifiedPosFinished(filterStep)
	return filterStep >= #self.queryList
end

function AIEnvQueryAbility:hasCalcQualifiedFilterQueryPos()
	return #self.filterQueryList > 0
end

function AIEnvQueryAbility:stopCalcQualifiedPos()
	if UNITY_EDITOR and self.debugMode then
		for i = #self.filterQueryList, 1, -1 do
			CS.FunPlus.WorldX.Utils.DebugDraw.DrawDebugShape(5, self.filterQueryList[i][1], self.filterQueryList[i][2], self.filterQueryList[i][3], 0.2, 2)
		end
	end
end

function AIEnvQueryAbility:checkUnobstructed(pos, unobstructedActorId)
	local unobstructedEnt = pg.getEntityByActorId(unobstructedActorId)

	if unobstructedEnt then
		return PhysicsUtils.checkTargetBlockedByPos(unobstructedActorId, pos)
	end

	return true
end

function AIEnvQueryAbility:checkOutOfWater(pos, outOfWater)
	if outOfWater then
		return not VoxelUtils.isPosOnWater(self.ent.space.id, pos.x, pos.y, pos.z, 0.5)
	end

	return true
end

function AIEnvQueryAbility:checkFindPath(pos, findPath)
	if findPath then
		return AutoPathFindUtils.findPathToPos(self.ent, pos.x, pos.y, pos.z, AiConst.TARGET_POINT_STOP_DIST, AutoPathFindUtils.PathFindType.Voxel)
	end

	return true
end

function AIEnvQueryAbility:queryBestPosByTarget(targetActorId)
	local targetEnt = pg.getEntityByActorId(targetActorId)
	local len = #self.filterQueryList

	if not targetEnt then
		local index = math.random(1, len)

		return self.filterQueryList[index]
	end

	local index = 0
	local minSqrtDist = math.maxInt

	for i = 1, len do
		local pos = self.filterQueryList[i]
		local sqrtDist = Vector3.SqrDistance(targetEnt:getPosition(), pos)

		if sqrtDist < minSqrtDist then
			index = i
			minSqrtDist = sqrtDist
		end
	end

	return self.filterQueryList[index]
end

return AIEnvQueryAbility
