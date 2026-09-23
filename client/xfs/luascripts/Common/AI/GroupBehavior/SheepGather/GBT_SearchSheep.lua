-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\GroupBehavior\\SheepGather\\GBT_SearchSheep.lua

local Class = require("Core.Framework.Class")
local GroupBehaviourTacheBase = require("Common.AI.GroupBehavior.GroupBehaviourTacheBase")
local Const = require("Common.Const.Const")
local AIUtils = require("Common.Utils.AIUtils")
local GroupBehaviourConst = require("Common.Const.GroupBehaviourConst")
local TacheDefine = GroupBehaviourConst.TacheDefine
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local EBTRootState = BaseEnum.EBTRootState
local GBT_SearchSheep = Class.LiteClass("GBT_SearchSheep", GroupBehaviourTacheBase)

function GBT_SearchSheep:ctor(owner, stateKey)
	GroupBehaviourTacheBase.ctor(self, owner, stateKey)

	self.sheepCache = {}
	self.sheepPrototypeId = owner.bindEnt.petPrototypeId
	self.sheepNeedCount = GroupBehaviourConst.SheepGatherMemberCount - 1
end

function GBT_SearchSheep:_execStart()
	return
end

function GBT_SearchSheep:_execBreak(isNormalFinish)
	if self.isInBreak then
		return
	end

	self.isInBreak = true

	self.owner:unregisterAllMember()
	self.owner:stopBehaviour()
end

function GBT_SearchSheep:onMemberAdd(member)
	return
end

function GBT_SearchSheep:onMemberRemove(member)
	if member == self.owner.bindEnt then
		self:_execBreak(false)
	end
end

function GBT_SearchSheep:onMemberPlanInit(member, planType, planId)
	return
end

function GBT_SearchSheep:onMemberPlanFinish(member, planType, planId)
	return
end

function GBT_SearchSheep:onRun(controller)
	local ent = self.owner.bindEnt
	local targetActorId = ent:getMaxPerceptibility()

	table.clearArray(self.sheepCache)

	local puppetCount = AIUtils.SearchEntitiesInRangeWithTable(ent, 10, Const.SEARCH_USR_TYPE_MONSTER, 10, self.sheepCache)
	local puppet
	local foundCount = 0

	for i = 1, puppetCount do
		puppet = pg.getEntityByActorId(self.sheepCache[i])

		if puppet and puppet.agent and puppet.perceptibility and puppet.petPrototypeId == self.sheepPrototypeId then
			if puppet.agent:getRootState() == EBTRootState.ST_Root_Idle or puppet.agent:getRootState() == EBTRootState.ST_Root_Alert then
				puppet:addOncePerceptibility(targetActorId, puppet:getVisionPerceptMaxLimit())
			elseif puppet.agent:getRootState() == EBTRootState.ST_Root_Sensed and not puppet:isInGroupBehaviour(false) then
				foundCount = foundCount + 1
				self.sheepCache[foundCount] = puppet
			end
		end
	end

	if foundCount < self.sheepNeedCount then
		return
	end

	for i = 1, self.sheepNeedCount do
		puppet = self.sheepCache[i]

		puppet:joinGroupBehaviour(self.owner)
	end

	self.owner:setOwnerEntVal(true)
	self.owner:tryTransitionTo(TacheDefine.SheepGather)
end

return GBT_SearchSheep
