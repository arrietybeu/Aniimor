-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Ecs\\EcsSkillCache.lua

local Class = require("Core.Framework.Class")
local EcsSkillCache = Class.LiteClass("EcsSkillCache")
local Time = require("Core.Common.Time")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local TriggerConst = require("Common.Const.TriggerConst")

function EcsSkillCache:ctor(evtName)
	self.skillHitCache = {}
	self.skillHitIndex = 1
	self.actorCache = {}
	self.evtName = evtName
end

function EcsSkillCache:add(targetEnt, ret, abilityId, elementType, srcActorId)
	local cache = self.skillHitCache
	local index = (self.skillHitIndex - 1) * 6 + 1

	cache[index] = targetEnt.id
	cache[index + 1] = ret
	cache[index + 2] = abilityId
	cache[index + 3] = elementType
	cache[index + 4] = srcActorId
	cache[index + 5] = Time.realSecondCache
	self.skillHitIndex = self.skillHitIndex % 10 + 1
end

function EcsSkillCache:trigger(targetEnt)
	table.clear(self.actorCache)

	for i = 1, 10 do
		local index = (i - 1) * 6 + 1
		local entId = self.skillHitCache[index]

		if entId and entId == targetEnt.id then
			local ret = self.skillHitCache[index + 1]
			local srcActorId = self.skillHitCache[index + 4]
			local timeStamp = self.skillHitCache[index + 5]

			if ret == 1 and ToBool(srcActorId) and Time.realSecondCache - timeStamp < 5 and not self.actorCache[entId] then
				local srcEntity = pg.getEntityByActorId(srcActorId)
				local srcPet = AbilityUtils.getPet(srcEntity)

				self.actorCache[entId] = true

				if srcPet and srcPet:getConfigData().petPrototypeId then
					pg.me:tryClientTrigger(TriggerConst.TRIGGER_TARGET_PET_CHEMICAL_REACTIONS, srcPet:getConfigData().baseFormPet, 1, self.evtName)
				end
			end
		end
	end
end

function EcsSkillCache:findSkillCasterActorId(targetEnt)
	for i = 1, 10 do
		local index = (i - 1) * 6 + 1
		local entId = self.skillHitCache[index]

		if entId and entId == targetEnt.id then
			local ret = self.skillHitCache[index + 1]
			local srcActorId = self.skillHitCache[index + 4]
			local timeStamp = self.skillHitCache[index + 5]

			if ToBool(srcActorId) and math.abs(Time.realSecondCache - timeStamp) < 0.01 then
				return srcActorId
			end
		end
	end

	return 0
end

return EcsSkillCache
