-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientCombatActorPartComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local ClientUtils = require("Utils.ClientUtils")
local Utils = require("Common.Utils.Utils")
local HitBoxData = require("Common.Data.hitbox_data")
local Vector3 = Vector3
local ClientCombatActorPartComponent = class.Component("ClientCombatActorPartComponent")

function ClientCombatActorPartComponent:ctor()
	self.actorPartUnits = {}
end

function ClientCombatActorPartComponent:start()
	return
end

function ClientCombatActorPartComponent:on_actorParts_changed(oldVal, newVal)
	local partUnit = self.actorPartUnits[newVal.actorPartId]

	if partUnit then
		partUnit:refreshPartInfo(newVal.hittable, newVal.lockable, newVal.visible)
	end
end

function ClientCombatActorPartComponent:onEnterSpace()
	for idx, partInfo in pairs(self.actorParts) do
		local partUnit = ClientUtils.createClientEntity("ClientPartUnit", self.id .. "_part_" .. tostring(idx), {
			actorId = self.actorId,
			position = Vector3(-2 * idx, 0, 0),
			rotation = Quaternion.identity,
			actorPartIdx = partInfo.actorPartIdx,
			hittable = partInfo.hittable,
			lockable = partInfo.lockable,
			visible = partInfo.visible,
			camp = self.camp
		})

		self.actorPartUnits[partInfo.actorPartIdx] = partUnit
	end
end

function ClientCombatActorPartComponent:onLeaveSpace()
	for _, partUnit in pairs(self.actorPartUnits) do
		ClientUtils.safeDestroy(partUnit)
	end

	self.actorPartUnits = {}
end

function ClientCombatActorPartComponent:onSkeletonLoaded()
	local configData = Utils.getEntityConfigData(self)

	if configData.hitBox then
		self.aoi:setIsMultiHitBox(true)

		local hitBoxData = HitBoxData[configData.hitBox]

		if hitBoxData then
			local copyData = {}

			for idx, value in ipairs(hitBoxData.hitBoxNodes) do
				copyData[idx] = {
					boneName = value.boneName,
					boxCenter = Vector3(value.boxCenter[1], value.boxCenter[2], value.boxCenter[3]),
					boxSize = Vector3(value.boxSize[1], value.boxSize[2], value.boxSize[3]),
					part = value.part,
					nodeIndex = value.nodeIndex,
					subPart = value.subPart
				}
			end

			CS.FunPlus.WorldX.Physx.HitBoxData.InitEntity(self.eModel, copyData, hitBoxData.shaderPartMaxCnt)
		end
	elseif self.aoi then
		self.aoi:setIsMultiHitBox(false)
	end
end

return ClientCombatActorPartComponent
