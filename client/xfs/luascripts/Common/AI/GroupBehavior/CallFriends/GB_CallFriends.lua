-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\GroupBehavior\\CallFriends\\GB_CallFriends.lua

local Class = require("Core.Framework.Class")
local GroupBehaviourBase = require("Common.AI.GroupBehavior.GroupBehaviourBase")
local GBT_QueueFollow = require("Common.AI.GroupBehavior.CallFriends.GBT_QueueFollow")
local GBT_Formation = require("Common.AI.GroupBehavior.CallFriends.GBT_Formation")
local GBT_HelpSkill = require("Common.AI.GroupBehavior.CallFriends.GBT_HelpSkill")
local GroupBehaviourConst = require("Common.Const.GroupBehaviourConst")
local TacheDefine = GroupBehaviourConst.TacheDefine
local Const = require("Common.Const.Const")
local EventConst = require("Common.Const.EventConst")
local Utils = require("Common.Utils.Utils")
local AIUtils = require("Common.Utils.AIUtils")
local GB_CallFriends = Class.LiteClass("GB_CallFriends", GroupBehaviourBase)

function GB_CallFriends:onInit(entity)
	self.bindEnt = entity

	GroupBehaviourBase.onInit(self)

	self.minStartMemberCount = 0
	self.minHoldMemberCount = 0
	self.maxMemberCount = 20
	self.tickInterval = 2
	self.envObjsCache = {}

	self:addTache(TacheDefine.QueueFollow, GBT_QueueFollow.new(self, TacheDefine.QueueFollow))
	self:addTache(TacheDefine.Formation, GBT_Formation.new(self, TacheDefine.Formation))
	self:addTache(TacheDefine.HelpSkill, GBT_HelpSkill.new(self, TacheDefine.HelpSkill))

	self.chemSkillCastInfo = {}

	function self.listener(globalId, skillId)
		self:_onCastChemSkillOnTarget(globalId, skillId)
	end
end

function GB_CallFriends:onStart()
	GroupBehaviourBase.onStart(self)
	self.bindEnt.eventEmitter:addEventListener(EventConst.CAST_CHEM_SKILL_ON_TARGET, self.listener)
	self.fsm:start(TacheDefine.QueueFollow)
end

function GB_CallFriends:onDestroy()
	GroupBehaviourBase.onDestroy(self)
	self.bindEnt.eventEmitter:removeEventListener(EventConst.CAST_CHEM_SKILL_ON_TARGET, self.listener)
end

function GB_CallFriends:getClosestCallFriendEnvObj()
	table.clearArray(self.envObjsCache)

	local count = AIUtils.SearchEntitiesInRangeWithTable(self.bindEnt, 10, Const.SEARCH_USR_TYPE_ENVOBJ, 10, self.envObjsCache)
	local envObj, actorId, envObjConfig, dist, closestEnvObj
	local closestDist = 999999

	for i = 1, count do
		actorId = self.envObjsCache[i]
		envObj = pg.getEntityByActorId(actorId)
		envObjConfig = envObj and envObj:getConfigData()

		if envObjConfig and envObjConfig.callFriend then
			dist = Vector3.Distance(self.bindEnt:getPosition(), envObj:getPosition())

			if dist < envObjConfig.callFriendRange and dist < closestDist then
				closestDist = dist
				closestEnvObj = envObj
			end
		end
	end

	return closestEnvObj
end

function GB_CallFriends:getChemSkillCastInfo()
	return self.chemSkillCastInfo[1], self.chemSkillCastInfo[2], self.chemSkillCastInfo[3]
end

function GB_CallFriends:resetChemSkillCastInfo()
	table.clearArray(self.chemSkillCastInfo)
end

function GB_CallFriends:_onCastChemSkillOnTarget(globalId, skillId)
	local target = pg.getEntityByGlobalId(globalId)

	if target and (Utils.isEnemy(self.bindEnt, target) or Utils.isEnvObj(target)) then
		self.chemSkillCastInfo[1] = true
		self.chemSkillCastInfo[2] = globalId
		self.chemSkillCastInfo[3] = skillId
	end
end

return GB_CallFriends
