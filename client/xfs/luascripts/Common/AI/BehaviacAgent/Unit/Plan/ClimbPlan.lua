-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\Plan\\ClimbPlan.lua

local class = require("Core.Framework.Class")
local BaseEcologyPlan = require("Common.AI.BehaviacAgent.Unit.Plan.BaseEcologyPlan")
local AiConst = require("Common.Const.AiConst")
local BehaviorTreePlanUtils = require("Common.Utils.BehaviorTreePlanUtils")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local Vectorpool = require("Common.Container.VectorPool")
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("ClimbPlan")
local ParmonBehaivorData = require("Data.parmon_behavior_data")
local PatrolConst = require("Common.Const.PatrolConst")
local TablePool = require("Common.Container.TablePool")
local ClimbPlanFsm = require("Common.AI.BehaviacAgent.Unit.Plan.ClimbPlanFsm.ClimbPlanFsm")
local CLIMB_STATE = require("Common.Const.AiConst").CLIMB_STATE
local ClimbType = require("Common.Const.AiConst").ClimbType
local Vector3 = Vector3
local Quaternion = Quaternion
local ClimbPlan = class.LightClass("ClimbPlan", BaseEcologyPlan)

function ClimbPlan:recycleInit(posX, posY, posZ, angleX, angleY, angleZ, climbDataId, climbData, behaviorId)
	ClimbPlan.super.ctor(self)

	local referenceData = behaviorId and ParmonBehaivorData[behaviorId] or AiConst.DefaultNullTable

	if self.climbData then
		self.climbData.rootPos:Set(posX, posY, posZ)
		self.climbData.rootRot:SetEuler(angleX, angleY, angleZ)

		self.climbData.dataId = climbDataId
		self.climbData.data = climbData
		self.climbData.behaviorId = behaviorId
		self.climbData.priority = referenceData.priority or PatrolConst.DEFAULT_PRIORITY
		self.climbData.interruptType = referenceData.interruptType or AiConst.AIBeInterruptedType.CanInterruptedByHighPriority
		self.climbData.posIndex = 1
		self.climbData.climbDataList = nil
	else
		self.climbData = {
			posIndex = 1,
			rootPos = Vector3.New(posX, posY, posZ),
			rootRot = Quaternion.Euler(angleX, angleY, angleZ),
			dataId = climbDataId,
			data = climbData,
			behaviorId = behaviorId,
			priority = referenceData.priority or PatrolConst.DEFAULT_PRIORITY,
			interruptType = referenceData.interruptType or AiConst.AIBeInterruptedType.CanInterruptedByHighPriority
		}
	end

	return true
end

function ClimbPlan:getPriority()
	return self.climbData.priority
end

function ClimbPlan:initPlan(entity)
	if not entity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("climb tree plan init error: entity is nil")
		end

		return false
	end

	if not self.climbPlanFsm then
		self.climbPlanFsm = ClimbPlanFsm.new(self)
	end

	ClimbPlan.super.initPlan(self, entity)

	self.targetEnt = entity

	self.climbPlanFsm:start(CLIMB_STATE.ClimbOn)

	return true
end

function ClimbPlan:_selectPosList()
	local data = self.climbData.data

	if data.climbLines then
		local lines = data.climbLines
		local entPos = self.targetEnt:getPosition()
		local minIndex, minSqrDist, sqrDist

		Vector3.enableCreateFromCache()

		for index, line in ipairs(lines) do
			sqrDist = Vector3.SqrDistance(entPos, Vector3.New(self:_getWorldPos(line.points[1].point)))

			if minSqrDist == nil or sqrDist < minSqrDist then
				minSqrDist = sqrDist
				minIndex = index
			end
		end

		Vector3.disableCreateFromCache()

		self.climbData.climbDataList = lines[minIndex].points
	else
		self.climbData.climbDataList = data.climbLine.points
	end
end

function ClimbPlan:_getWorldPos(localPos)
	Vector3.enableCreateFromCache()

	local tmpWorldPos = self.climbData.rootPos + self.climbData.rootRot * Vector3.New(localPos[1], localPos[2], localPos[3])
	local tmpWorldPosX, tmpWorldPosY, tmpWorldPosZ = tmpWorldPos[1], tmpWorldPos[2], tmpWorldPos[3]

	Vector3.disableCreateFromCache()

	return tmpWorldPosX, tmpWorldPosY, tmpWorldPosZ
end

function ClimbPlan:_getWorldNormal(localRotNormal)
	Vector3.enableCreateFromCache()

	local tmpWorldRot = self.climbData.rootRot * Vector3.New(localRotNormal[1], localRotNormal[2], localRotNormal[3])
	local tmpWorldRotX, tmpWorldRotY, tmpWorldRotZ = tmpWorldRot[1], tmpWorldRot[2], tmpWorldRot[3]

	Vector3.disableCreateFromCache()

	return tmpWorldRotX, tmpWorldRotY, tmpWorldRotZ
end

function ClimbPlan:tryRunPlan()
	if not self:isActive() then
		return false
	end

	self.climbPlanFsm:onRun()

	return self:isActive()
end

function ClimbPlan:isActive()
	return not self.climbPlanFsm:checkIsCurState(CLIMB_STATE.ClimbDisable)
end

function ClimbPlan:breakPlan()
	if self.targetEnt == nil then
		return
	end

	local ent = self.targetEnt

	self.targetEnt = nil

	ClimbPlan.super.breakPlan(self)
	ent:clearCurrentAIParmonPlan(self)
end

function ClimbPlan:getNextMovePointData(autoAddIndex)
	local curIndex = self.climbData.posIndex
	local climbDataList = self.climbData.climbDataList
	local maxLen = #climbDataList

	for i = curIndex, maxLen do
		local tClimbType = climbDataList[i].climbType

		if tClimbType == nil or tClimbType == ClimbType.ClimbMove then
			if autoAddIndex then
				self.climbData.posIndex = i + 1
			end

			return climbDataList[i]
		end
	end
end

function ClimbPlan:getNextPointData(autoAddIndex)
	local curIndex = self.climbData.posIndex

	if autoAddIndex then
		self.climbData.posIndex = curIndex + 1
	end

	return self.climbData.climbDataList[curIndex]
end

function ClimbPlan:getPlanType()
	return AiConst.ParmonPlanType.ClimbPlan
end

function ClimbPlan:getID()
	return self.climbData.behaviorId
end

return ClimbPlan
