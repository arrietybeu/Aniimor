-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Ability\\ProjAroundSelfControl.lua

local Class = require("Core.Framework.Class")
local CombatActionTool = require("Common.Ability.CombatActionTool")
local ProjAroundSelf = require("GameApp.Ability.ProjAroundSelf")
local Utils = require("Common.Utils.Utils")
local CombatLogger = require("Common.Ability.CombatLogger")
local ListPool = require("Common.Container.ListPool")
local TimerManager = require("Core.Timer.TimerManager")
local Vector3 = Vector3
local Quaternion = Quaternion
local tickInterval = 0.03
local ProjAroundSelfControl = Class.LiteClass("ProjAroundSelfControl")

function ProjAroundSelfControl:ctor(actionData, combatContext)
	self.owner = CombatActionTool.getOwnerEntity(combatContext)

	local nodeData = combatContext.nodeMap[actionData.projectileActionId]
	local projectileId = nodeData.templateId
	local projData = pg.global.abilityMgr:getProjectileTemplate(projectileId)

	self.launchTarget = nodeData.targetPos
	self.effectId = projData.effectId
	self.radius = actionData.radius
	self.launchInterval = self.owner.combatAction:doActionById(actionData.launchIntervalActionId, combatContext)
	self.rotateSpeed = actionData.rotateSpeed
	self.projList = {}
	self.launchingList = {}
	self.isRoundSelf = actionData.isRoundSelf
	self.timeHandler = nil
end

function ProjAroundSelfControl:initTimer()
	if self.timeHandler or self.owner == pg.me then
		return
	end

	self.timeHandler = TimerManager.addRepeatTimer(tickInterval, function()
		self:tick(tickInterval)
	end)
end

function ProjAroundSelfControl:cancelTimer()
	if self.timeHandler then
		TimerManager.removeTimer(self.timeHandler)

		self.timeHandler = nil
	end
end

function ProjAroundSelfControl:getFollowEntity()
	if self.isRoundSelf then
		if self.owner.isControllingEgg and self.owner:isControllingEgg() then
			return self.owner:getCurControllingEgg() or self.owner
		end

		return self.owner
	else
		local player = Utils.getMasterPlayer(self.owner)

		if player and player:isControllingEgg() then
			return player:getCurControllingEgg() or self.owner
		end

		return player and player:getCurPetEntity() or self.owner
	end
end

function ProjAroundSelfControl:addProj(addNum)
	self:initTimer()

	local startAngle = 0

	if #self.projList > 0 then
		startAngle = self.projList[1].angle
	end

	local angleInterval = 360 / (addNum + #self.projList)

	for i = 1, #self.projList do
		self.projList[i].angle = startAngle + angleInterval * (i - 1)
	end

	local oldNum = #self.projList

	for i = 1, addNum do
		local startAngle = startAngle + (oldNum + i - 1) * angleInterval

		table.insert(self.projList, ProjAroundSelf(self, startAngle))
	end
end

function ProjAroundSelfControl.cmpAngle(a, b)
	return a[2] > b[2]
end

function ProjAroundSelfControl.angleDiff(a, b)
	local diff = math.abs(a - b) % 360

	return math.min(diff, 360 - diff)
end

function ProjAroundSelfControl:launch(num, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, self.launchTarget)
	local targetPos = Vector3()

	if not CombatActionTool.parsePosition(combatContext, self.launchTarget, targetPos) then
		CombatLogger.error("launch failed, targetPos not found", inspect(self.launchTarget), targetActorId)

		return
	end

	combatContext.overrideProjTargetActorId = targetActorId
	combatContext.overrideProjTargetPos = targetPos

	Vector3.enableCreateFromCache()

	local followPos = self:getFollowEntity():getPosition()
	local forwardDir = targetPos - followPos

	forwardDir.y = 0

	Vector3.SetNormalize(forwardDir)

	local right = Vector3(1, 0, 0)
	local launchIndex = 1
	local maxDoc = -1
	local listLen = #self.projList

	for idx, proj in ipairs(self.projList) do
		local projDir = proj.pos - followPos

		projDir.y = 0

		Vector3.SetNormalize(projDir)

		local tangentDir = Quaternion.MulVec3(Quaternion.LookRotation(projDir, Vector3.up), right)
		local doc = Vector3.Dot(tangentDir, forwardDir)

		if maxDoc < doc then
			launchIndex = idx
			maxDoc = doc
		end
	end

	local launchAngle = self.projList[launchIndex].angle
	local rotateSpeed = self.rotateSpeed

	if num > 1 then
		local nextIndex = (launchIndex + 1) % listLen

		if nextIndex == 0 then
			nextIndex = listLen
		end

		local angleOffset = ProjAroundSelfControl.angleDiff(self.projList[launchIndex].angle % 360, self.projList[nextIndex].angle % 360)

		rotateSpeed = angleOffset / self.launchInterval
	end

	Vector3.disableCreateFromCache()

	local removeList = ListPool.getList(3)

	for i = 1, num do
		local proj = self.projList[launchIndex]

		table.insert(removeList, launchIndex)
		table.insert(self.launchingList, proj)
		proj:readyLaunch(combatContext, launchAngle, self.launchInterval * (i - 1), targetActorId, targetPos, rotateSpeed)

		launchIndex = launchIndex - 1

		if launchIndex < 1 then
			launchIndex = launchIndex + listLen
		end
	end

	table.sort(removeList)

	for i = num, 1, -1 do
		table.remove(self.projList, removeList[i])
	end

	ListPool.returnList(removeList, 3)
	self:tick(0)
end

function ProjAroundSelfControl:launchV2(num, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, self.launchTarget)
	local targetPos = Vector3()

	if not CombatActionTool.parsePosition(combatContext, self.launchTarget, targetPos) then
		CombatLogger.error("launch failed, targetPos not found", self.launchTarget)

		return
	end

	Vector3.enableCreateFromCache()

	local followPos = self:getFollowEntity():getPosition()
	local forwardDir = targetPos - followPos

	forwardDir.y = 0

	Vector3.SetNormalize(forwardDir)

	local maxDoc = -1
	local startIndex = 1
	local right = Vector3(1, 0, 0)
	local launchAngle = 0

	for idx, proj in ipairs(self.projList) do
		local projDir = proj.pos - followPos

		projDir.y = 0

		Vector3.SetNormalize(projDir)

		local tangentDir = Quaternion.MulVec3(Quaternion.LookRotation(projDir, Vector3.up), right)
		local doc = Vector3.Dot(tangentDir, forwardDir)

		if maxDoc < doc then
			startIndex = idx
			maxDoc = doc
			launchAngle = proj.angle
		end
	end

	local totalAngle = 0
	local removeList = ListPool.getList(3)
	local listLen = #self.projList

	if num > 1 then
		local nextIndex = startIndex + 1

		if listLen < nextIndex then
			nextIndex = nextIndex - listLen
		end

		local angleA = self.projList[nextIndex].angle % 360
		local angleB = self.projList[startIndex].angle % 360
		local diff = math.abs(angleA - angleB) % 360

		diff = math.min(diff, 360 - diff)
		totalAngle = math.abs(diff) * (num - 1)
	end

	local speed = totalAngle / (self.launchInterval * (num - 1))

	for i = 1, num do
		local proj = self.projList[startIndex]

		table.insert(removeList, startIndex)
		table.insert(self.launchingList, proj)
		proj:readyLaunch(combatContext, launchAngle, self.launchInterval * (i - 1), targetActorId, targetPos, speed)

		startIndex = startIndex + 1

		if listLen < startIndex then
			startIndex = startIndex - listLen
		end
	end

	table.sort(removeList)

	for i = num, 1, -1 do
		table.remove(self.projList, removeList[i])
	end

	ListPool.returnList(removeList, 3)
	Vector3.disableCreateFromCache()
	self:tick(0)
end

function ProjAroundSelfControl:tick(deltaSeconds)
	local removeList = ListPool.getList(3)

	for idx, proj in ipairs(self.projList) do
		proj:tick(deltaSeconds)
	end

	for idx, proj in ipairs(self.launchingList) do
		proj:tick(deltaSeconds, idx, removeList)
	end

	for i = #removeList, 1, -1 do
		table.remove(self.launchingList, removeList[i])
	end

	ListPool.returnList(removeList, 3)
end

function ProjAroundSelfControl:clear()
	for _, proj in ipairs(self.projList) do
		proj:clear()
	end

	for _, proj in ipairs(self.launchingList) do
		proj:clear()
	end

	self.projList = {}
	self.launchingList = {}

	self:cancelTimer()
end

return ProjAroundSelfControl
