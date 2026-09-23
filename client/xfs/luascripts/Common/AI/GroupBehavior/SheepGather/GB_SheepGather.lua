-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\GroupBehavior\\SheepGather\\GB_SheepGather.lua

local Class = require("Core.Framework.Class")
local GroupBehaviourBase = require("Common.AI.GroupBehavior.GroupBehaviourBase")
local GroupBehaviourConst = require("Common.Const.GroupBehaviourConst")
local Const = require("Common.Const.Const")
local TacheDefine = GroupBehaviourConst.TacheDefine
local GBT_SearchSheep = require("Common.AI.GroupBehavior.SheepGather.GBT_SearchSheep")
local GBT_SheepGather = require("Common.AI.GroupBehavior.SheepGather.GBT_SheepGather")
local GBT_SheepAbility = require("Common.AI.GroupBehavior.SheepGather.GBT_SheepAbility")
local AiConst = require("Common.Const.AiConst")
local EntityCacheValueUtils = require("Common.Utils.EntityCacheValueUtils")
local AIUtils = require("Common.Utils.AIUtils")
local GB_SheepGather = Class.LiteClass("GB_SheepGather", GroupBehaviourBase)

function GB_SheepGather:onInit(entity)
	self.bindEnt = entity
	self.perceptActorId = entity:getMaxPerceptibility()

	GroupBehaviourBase.onInit(self)

	self.parmonBehavId = GroupBehaviourConst.SheepGatherBehaviourID
	self.minStartMemberCount = GroupBehaviourConst.SheepGatherMemberCount
	self.minHoldMemberCount = GroupBehaviourConst.SheepGatherMemberCount
	self.maxMemberCount = GroupBehaviourConst.SheepGatherMemberCount
	self.tickInterval = 20

	self:addTache(TacheDefine.SearchSheep, GBT_SearchSheep.new(self, TacheDefine.SearchSheep))
	self:addTache(TacheDefine.SheepGather, GBT_SheepGather.new(self, TacheDefine.SheepGather))
	self:addTache(TacheDefine.SheepAbility, GBT_SheepAbility.new(self, TacheDefine.SheepAbility))
end

function GB_SheepGather:onStart()
	GroupBehaviourBase.onStart(self)
	self.fsm:start(TacheDefine.SearchSheep)
end

function GB_SheepGather:isRunning()
	if not self.fsm or not self.fsm._curState then
		return false
	end

	return self.fsm._curState._stateEnum > GroupBehaviourConst.TacheDefine.SearchSheep
end

function GB_SheepGather:onMemberRemove(member)
	self:_setMemberAttach(member, false)
	GroupBehaviourBase.onMemberRemove(self, member)
end

function GB_SheepGather:setAllMemberAttach(flag)
	for _, member in pairs(self.members) do
		self:_setMemberAttach(member, flag)
	end
end

function GB_SheepGather:_setMemberAttach(member, flag)
	local target = self.bindEnt

	if target == member then
		return
	end

	if target.eModel and member.eModel then
		if flag then
			Vector3.enableCreateFromCache()

			local offset = target:getRotation():Inverse():MulVec3(member:getPosition() - target:getPosition())
			local rotate = target:getRotation():Inverse() * member:getRotation()

			member.eModel:AttachByCurrentPos(Const.COMPONENT_ATTACH, target.eModel, offset, rotate, 1000)
			Vector3.disableCreateFromCache()
			member:pauseBt(AiConst.PauseBtReason.SheepGather)
		else
			member.eModel:Detach(Const.COMPONENT_ATTACH)
			member:resumeBt(AiConst.PauseBtReason.SheepGather)
		end
	end
end

function GB_SheepGather:setOwnerEntVal(flag)
	local ent = self.bindEnt

	for i = 1, GroupBehaviourConst.SheepGatherMemberCount - 1 do
		EntityCacheValueUtils.setCacheValue(ent, GroupBehaviourConst.SheepGatherEntValKeys[i], flag and self.members[i + 1].actorId or 0)
	end
end

function GB_SheepGather:setAllMemberEnterCombat(targetActorId)
	for _, member in pairs(self.members) do
		member:resumeBt(AiConst.PauseBtReason.SheepGather)
		AIUtils.enterCombat(member, targetActorId)
	end
end

function GB_SheepGather:stopBehaviour()
	local ent = self.bindEnt

	if ent.space and ent.space.aiMgr then
		ent.space.aiMgr:destroyBehaviour(self)
	end
end

return GB_SheepGather
