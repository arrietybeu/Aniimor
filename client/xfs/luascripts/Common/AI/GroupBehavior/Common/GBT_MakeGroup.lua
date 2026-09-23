-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\GroupBehavior\\Common\\GBT_MakeGroup.lua

local Class = require("Core.Framework.Class")
local GroupBehaviourTacheBase = require("Common.AI.GroupBehavior.GroupBehaviourTacheBase")
local GroupBehaviourConst = require("Common.Const.GroupBehaviourConst")
local GBT_MakeGroup = Class.LiteClass("GBT_MakeGroup", GroupBehaviourTacheBase)

function GBT_MakeGroup:ctor(owner, stateKey)
	GroupBehaviourTacheBase.ctor(self, owner, stateKey)

	self.timeoutTime = -1
end

function GBT_MakeGroup:_execStart()
	return
end

function GBT_MakeGroup:onMemberAdd(member)
	self:_tryFinish()
end

function GBT_MakeGroup:onMemberRemove(member)
	return
end

function GBT_MakeGroup:onMemberPlanInit(member, planType, planId)
	return
end

function GBT_MakeGroup:onMemberPlanFinish(member, planType, planId)
	return
end

function GBT_MakeGroup:_checkFinish()
	local memberCount = table.getCount(self.owner.members)

	if memberCount < self.owner.minStartMemberCount then
		return false
	end

	local mayFinish = true
	local resPoint = self:getBindResPoint()

	if resPoint then
		local pointPos = resPoint:getWorldPosition()

		for i = self.owner.maxMemberCount, 1, -1 do
			if self.owner.members[i] then
				local sqrDist = Vector3.HoriSqrDistance(pointPos, self.owner.members[i]:getPosition())

				if sqrDist > GroupBehaviourConst.MakeGroupMaxSqrDistance then
					self.owner.members[i]:exitCurrentGroupBehaviour()

					mayFinish = false
				end
			elseif not self.owner.memberData[i].notMustNeed then
				mayFinish = false
			end
		end
	end

	return mayFinish
end

return GBT_MakeGroup
