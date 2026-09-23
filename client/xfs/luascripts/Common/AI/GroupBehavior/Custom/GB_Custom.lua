-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\GroupBehavior\\Custom\\GB_Custom.lua

local Class = require("Core.Framework.Class")
local GroupBehaviourBase = require("Common.AI.GroupBehavior.GroupBehaviourBase")
local GroupBehaviourConst = require("Common.Const.GroupBehaviourConst")
local GroupBehaviourUtils = require("Common.Utils.GroupBehaviourUtils")
local TacheDefine = GroupBehaviourConst.TacheDefine
local GBT_CoolDown = require("Common.AI.GroupBehavior.Common.GBT_CoolDown")
local GBT_MakeGroup = require("Common.AI.GroupBehavior.Common.GBT_MakeGroup")
local GBT_Custom = require("Common.AI.GroupBehavior.Custom.GBT_Custom")
local Utils = require("Common.Utils.Utils")
local GB_Custom = Class.LiteClass("GB_Custom", GroupBehaviourBase)

function GB_Custom:onInit()
	GroupBehaviourBase.onInit(self)
	self:addTache(TacheDefine.CoolDown, GBT_CoolDown.new(self, TacheDefine.CoolDown))
	self:addTache(TacheDefine.MakeGroup, GBT_MakeGroup.new(self, TacheDefine.MakeGroup))

	local isOk, result = xpcall(function()
		local rawData = require("Common.Data.GroupBehaviour." .. self.behaviourName)

		self:_initByRawData(rawData)
	end, debug.traceback)
end

function GB_Custom:onStart()
	GroupBehaviourBase.onStart(self)
	self.fsm:start(TacheDefine.MakeGroup)
end

function GB_Custom:_initByRawData(rawData)
	self.parmonBehavId = rawData.behavID
	self.cdTime = rawData.CDAfterEnd or 0
	self.overrideVisionArea = rawData.GroupBehavVisionArea

	self:_initMemberCondition(rawData.roleList, rawData.minStartRoleNum, rawData.minHoldRoleNum)
	self:_initTache(rawData.stageList)
end

function GB_Custom:_initMemberCondition(memberListData, minStartMemberCount, minHoldMemberCount)
	self.memberData = memberListData
	self.minStartMemberCount = minStartMemberCount or #memberListData
	self.minHoldMemberCount = minHoldMemberCount or #memberListData
	self.maxMemberCount = #memberListData
end

function GB_Custom:_initTache(tacheListData)
	for tacheKey, tacheData in ipairs(tacheListData) do
		local tache = GBT_Custom.new(self, tacheKey, tacheData)

		self:addTache(tacheKey, tache)
	end
end

function GB_Custom:checkMemberJoinCondition(member)
	for i = 1, self.maxMemberCount do
		if not self.members[i] then
			local ret = true
			local conditions = self.memberData[i].roleCondition or {}

			for _, condition in ipairs(conditions) do
				local desc = condition[1]
				local param = condition[2]
				local op = condition[3]

				ret = self:_checkMemberJoinCondition(i, member, desc, param, op, ret)
			end

			if ret then
				return i
			end
		end
	end

	return -1
end

function GB_Custom:_checkMemberJoinCondition(index, member, desc, param, op, lastVal)
	local val = false

	if desc == "templateId" then
		val = member.templateId == param
	elseif desc == "petPrototypeId" then
		val = member.petPrototypeId == param
	elseif desc == "horiDistLessThan" then
		local horiSqrDist = Vector3.HoriSqrDistance(self.bindResPoint:getWorldPosition(), member:getPosition())

		val = horiSqrDist < param * param
	elseif desc == "horiDistMoreThan" then
		local horiSqrDist = Vector3.HoriSqrDistance(self.bindResPoint:getWorldPosition(), member:getPosition())

		val = horiSqrDist > param * param
	elseif desc == "entityTag" then
		val = Utils.hasEntityTag(member, param)
	elseif desc == "isTwinPet" then
		val = Utils.isTwinPet(member.petPrototypeId) == param
	elseif desc == "isPlayerTwinPet" then
		val = Utils.isPlayerTwinPet(pg.me, member.petPrototypeId) == param
	elseif desc == "staticId" then
		local roleType = self.memberData[index].roleType
		local targetStaticId = self.bindResPoint:getRoleConditionStaticId(roleType)

		val = targetStaticId == 0 or targetStaticId == member.staticId
	else
		GroupBehaviourUtils.LogError("member join condition desc error, desc: %s, param: %s, op: %s", tostring(desc), tostring(param), tostring(op))
	end

	if op == "and" then
		return lastVal and val
	elseif op == "or" then
		return lastVal or val
	elseif op == "" or op == nil then
		return val
	else
		GroupBehaviourUtils.LogError("member join condition op error, desc: %s, param: %s, op: %s", tostring(desc), tostring(param), tostring(op))
	end

	return lastVal
end

return GB_Custom
