-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientPetCombatEntityComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local ClientCombatEntityComponent = require("Entities.SpaceEntities.CommonComponent.ClientCombatEntityComponent")
local MessageName = require("Const.MessageName")
local Utils = require("Common.Utils.Utils")
local PetData = require("Data.pet_data")
local pg = pg
local Vector3 = Vector3
local ClientPetCombatEntityComponent = class.Component("ClientPetCombatEntityComponent", ClientCombatEntityComponent)

function ClientPetCombatEntityComponent:start()
	ClientPetCombatEntityComponent.super.start(self)
end

function ClientPetCombatEntityComponent:getGroupActorId()
	return self.masterActorId
end

function ClientPetCombatEntityComponent:getStamina()
	local master = self:getMasterEntity()

	if master then
		return master:getStamina()
	end

	return 0
end

function ClientPetCombatEntityComponent:getHatredValue(ent)
	local master = self:getMasterEntity()

	if master then
		return master:getHatredValue(ent)
	end

	return 0
end

function ClientPetCombatEntityComponent:getHatred()
	local master = self:getMasterEntity()

	if master then
		return master:getHatred()
	end

	return {}
end

function ClientPetCombatEntityComponent:getBehatredMap()
	local master = self:getMasterEntity()

	if master then
		return master:getBehatredMap()
	end

	return {}
end

function ClientPetCombatEntityComponent:isInCombat()
	local master = self:getMasterEntity()

	if master then
		return master:isInCombat()
	end

	return false
end

function ClientPetCombatEntityComponent:getHatredBossIds()
	local master = self:getMasterEntity()

	if master and master.getHatredBossIds then
		return master:getHatredBossIds()
	end

	return {}
end

function ClientPetCombatEntityComponent:getLockedActorId()
	local master = self:getMasterEntity()

	if master then
		return master.petLockedActorId
	end

	return nil
end

function ClientPetCombatEntityComponent:checkAppearDash(targetActorId, petTemplateId)
	local configData = PetData[petTemplateId]

	if not configData then
		return false
	end

	local targetEntity = pg.getEntityByActorId(targetActorId)

	if not targetEntity then
		return false
	end

	if not Utils.isPuppet(targetEntity) then
		return false
	end

	if targetActorId ~= pg.game.controller.lockHelper.forceLockActorId then
		return false
	end

	local dis = Vector3.Distance(targetEntity:getPosition(), self:getPosition())
	local appearDashDisMin = configData.appearDashDisMin or 3
	local appearDashDisMax = configData.appearDashDisMax or 8

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("checkAppearDash, distance", dis, appearDashDisMin, appearDashDisMax)
	end

	local result = dis < appearDashDisMin or appearDashDisMax < dis

	if result then
		local appearDesireDis = configData.appearDesireDis or 1.5
		local sx, sy, sz = self.eModel:GetPositionAgentPosEx()
		local tx, ty, tz = targetEntity.eModel:GetPositionAgentPosEx()

		Vector3.enableCreateFromCache()

		local targetToSelfDir = Vector3.New(sx - tx, 0, sz - tz)

		Vector3.SetNormalize(targetToSelfDir)

		local desirePos = Vector3.New(tx, ty, tz) + targetToSelfDir * appearDesireDis

		Vector3.disableCreateFromCache(desirePos)

		return result, desirePos
	else
		return result, nil
	end
end

function ClientPetCombatEntityComponent:getMaxEp()
	return self.master and self.master.maxEp or 0
end

function ClientPetCombatEntityComponent:getEp()
	return self.master and self.master.curEp or 0
end

return ClientPetCombatEntityComponent
