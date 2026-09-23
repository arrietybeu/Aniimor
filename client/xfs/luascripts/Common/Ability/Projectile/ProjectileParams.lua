-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\Projectile\\ProjectileParams.lua

local Class = require("Core.Framework.Class")
local ProjectileConst = require("Common.Const.ProjectileConst")
local CombatLogger = require("Common.Ability.CombatLogger")
local Vector3 = Vector3
local ProjectileParams = Class.LiteClass("ProjectileParams")

function ProjectileParams.createInstance(srcAbilityId, srcAbilityStoreType, srcActorId, targetActorId, templateId, instanceId, pos, rotation, targetPosition, srcCombatContextId, castingCombatContextId, soundId)
	local self = pg.global.abilityMgr.projectileParamsPool:get(true)

	self.srcAbilityId = srcAbilityId
	self.srcAbilityStoreType = srcAbilityStoreType
	self.srcActorId = srcActorId
	self.targetActorId = targetActorId
	self.pos = pos
	self.rotation = rotation
	self.templateId = templateId
	self.instanceId = instanceId

	if targetPosition ~= nil then
		self.targetPosition = Vector3.Clone(targetPosition)
	end

	self.srcCombatContextId = srcCombatContextId
	self.castingCombatContextId = castingCombatContextId
	self.soundId = soundId

	return self
end

return ProjectileParams
