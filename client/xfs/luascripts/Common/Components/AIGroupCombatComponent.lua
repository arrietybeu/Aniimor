-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Components\\AIGroupCombatComponent.lua

local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local AiConst = require("Common.Const.AiConst")
local CallbackHandler = require("Core.Common.CallbackHandler")
local roguelike_data = require("Data.roguelike_data")
local lume = require("Core.Common.lume")
local SysConfigData = require("Data.sys_config_data")
local ListPool = require("Common.Container.ListPool")
local VectorPool = require("Common.Container.VectorPool")
local AIGroupCombatComponent = Class.Component("AIGroupCombatComponent")

function AIGroupCombatComponent:init()
	self.groupCombatData = {
		membersCount = 0,
		members = {},
		ascendSortByPlayer = CallbackHandler(self, "_ascendSortFuncByPlayer"),
		descendSortByPlayer = CallbackHandler(self, "_descendSortFuncByPlayer"),
		descendSortByCamera = CallbackHandler(self, "_descendSortFuncByCamera")
	}
	self.groupCombatData.needRefreshLock = false
end

function AIGroupCombatComponent:onEnterSpace()
	if self.space:isMultiPlayerEnv() then
		if not Utils.checkClient() then
			self:enterGroupCombat()
		end
	elseif Utils.checkClient() then
		self:enterGroupCombat()
	end
end

function AIGroupCombatComponent:onLeaveSpace()
	self:exitGroupCombat()
end

function AIGroupCombatComponent:onMultiPlayerEnvChanged(multiPlayerEnvValue)
	if self.space:isMultiPlayerEnv() then
		if Utils.checkClient() then
			self:exitGroupCombat()
		else
			self:enterGroupCombat()
		end
	elseif Utils.checkClient() then
		self:enterGroupCombat()
	else
		self:exitGroupCombat()
	end
end

function AIGroupCombatComponent:exitGroupCombat()
	if self.groupCombatData.groupCombatTimer then
		self:removeTimer(self.groupCombatData.groupCombatTimer)

		self.groupCombatData.groupCombatTimer = nil
	end

	local memberActorId, _ = next(self.groupCombatData.members)

	while memberActorId do
		Utils.removeEntityTag(pg.getEntityByActorId(memberActorId), AiConst.CombatTag, true)

		memberActorId, _ = next(self.groupCombatData.members, memberActorId)
	end
end

function AIGroupCombatComponent:enterGroupCombat()
	self:exitGroupCombat()

	self.groupCombatData.groupCombatTimer = self:addRepeatTimer(2, CallbackHandler(self, "updateGroupCombatTag"))
end

function AIGroupCombatComponent:joinGroupCombat(member)
	if self.groupCombatData.groupCombatTimer then
		local memberExists = self.groupCombatData.members[member.actorId]

		if not memberExists then
			self.groupCombatData.members[member.actorId] = true
			self.groupCombatData.membersCount = self.groupCombatData.membersCount + 1
		end
	end
end

function AIGroupCombatComponent:leaveGroupCombat(member)
	if member then
		local memberExists = self.groupCombatData.members[member.actorId]

		if memberExists then
			Utils.removeEntityTag(member, AiConst.CombatTag)

			self.groupCombatData.members[member.actorId] = nil
			self.groupCombatData.membersCount = self.groupCombatData.membersCount - 1
		end
	end
end

function AIGroupCombatComponent:onLockTargetChange(olderTargetActorId, newTargetActorId)
	local isForceLock = ToBool(self.isForceLock)

	if not isForceLock then
		return
	end

	local newEntity = pg.getEntityByActorId(newTargetActorId)

	if newEntity and Utils.isPuppet(newEntity) then
		Utils.addEntityTag(newEntity, AiConst.CombatTag)
	end
end

function AIGroupCombatComponent:updateGroupCombatTag()
	if self.groupCombatData.membersCount > 1 then
		if self.needRefreshLock then
			self:forceRefreshLockedCombatTag()

			self.needRefreshLock = false
		end

		local player = self
		local groupEnemyAttackNum = Utils.isInRogueSpace(player) and roguelike_data[player.curRogueLayer].groupEnemyAttackNum or SysConfigData.GroupEnemyAttackNum
		local groupEnemyAttackWeight = Utils.isInRogueSpace(player) and roguelike_data[player.curRogueLayer].groupEnemyAttackWeight or SysConfigData.GroupEnemyAttackWeight
		local targetCombatNum = lume.weightRandomChoiceOne(groupEnemyAttackNum, groupEnemyAttackWeight)
		local hasTagCount = self:getHasGroupCombatTagCount()

		if hasTagCount < targetCombatNum then
			self:grantGroupCombatTag(targetCombatNum - hasTagCount)
		elseif targetCombatNum < hasTagCount then
			self:removeGroupCombatTag(hasTagCount - targetCombatNum)
		end
	else
		local memberActorId, _ = next(self.groupCombatData.members)

		while memberActorId do
			Utils.addEntityTag(pg.getEntityByActorId(memberActorId), AiConst.CombatTag)

			memberActorId, _ = next(self.groupCombatData.members, memberActorId)
		end
	end
end

function AIGroupCombatComponent:getHasGroupCombatTagCount()
	local count = 0
	local memberActorId, __ = next(self.groupCombatData.members)
	local debugTest = ListPool.getList()

	while memberActorId do
		if Utils.hasEntityTag(pg.getEntityByActorId(memberActorId), AiConst.CombatTag) then
			debugTest[#debugTest + 1] = memberActorId
			count = count + 1
		end

		memberActorId, __ = next(self.groupCombatData.members, memberActorId)
	end

	ListPool.returnList(debugTest)

	return count
end

function AIGroupCombatComponent:removeGroupCombatTag(needRemoveCount)
	local memberActorId, __ = next(self.groupCombatData.members)
	local distanceList = ListPool.getList()

	while memberActorId do
		local member = pg.getEntityByActorId(memberActorId)

		if member then
			if not self:groupCombatFilterByLocked(member) then
				if not Utils.hasEntityTag(member, AiConst.CombatTag) then
					Utils.addEntityTag(member, AiConst.CombatTag)

					needRemoveCount = needRemoveCount + 1
				end
			elseif Utils.hasEntityTag(member, AiConst.CombatTag) then
				local maxKeepBoxDist = member:getConfigData().maxKeepBoxDist or 10
				local memberAttackActorId = member.getAttackTargetActorId and member:getAttackTargetActorId()

				if self:groupCombatFilerByDistance(member, memberAttackActorId, maxKeepBoxDist) or self:groupCombatFilterByCameraView(member) then
					if self:_memberRemoveCombatTag(member) then
						needRemoveCount = needRemoveCount - 1
					end
				else
					distanceList[#distanceList + 1] = member
				end
			end
		end

		memberActorId, __ = next(self.groupCombatData.members, memberActorId)
	end

	if needRemoveCount > 0 then
		table.sort(distanceList, self.groupCombatData.descendSortByPlayer)

		local index = 1
		local distanceListCount = #distanceList

		while needRemoveCount > 0 do
			if distanceListCount <= index then
				break
			end

			if self:_memberRemoveCombatTag(distanceList[index]) then
				needRemoveCount = needRemoveCount - 1
			end

			index = index + 1
		end
	end

	ListPool.returnList(distanceList)
end

function AIGroupCombatComponent:groupCombatFilterByLocked(member)
	local playerLockActorId = self:getGroupCombatLockedActorId()

	return playerLockActorId ~= member.actorId
end

function AIGroupCombatComponent:groupCombatFilerByDistance(member, memberLockActorId, maxKeepBoxDist)
	local lockedEnt = memberLockActorId and pg.getEntityByActorId(memberLockActorId)

	if not lockedEnt then
		return true
	end

	local lockedEntPos = lockedEnt:getPosition()
	local memberPos = member:getPosition()

	return math.abs(lockedEntPos.y - memberPos.y) > 0.6 * member:getRealHeight() or maxKeepBoxDist < Vector3.HoriDistance(lockedEntPos, memberPos)
end

function AIGroupCombatComponent:groupCombatFilterByCameraView(member)
	if self:isControllingPet() and Utils.checkClient() then
		local casterEntPos = VectorPool.getVector(3, member:getPosition())

		casterEntPos.y = casterEntPos.y + member:getRealHeight() * 0.5

		local ret = pg.game.camera:checkInViewport(casterEntPos)

		VectorPool.returnVector(casterEntPos)

		return not ret
	end

	return false
end

function AIGroupCombatComponent:groupCombatCheckInCameraView(member)
	if self:isControllingPet() and Utils.checkClient() then
		local casterEntPos = VectorPool.getVector(3, member:getPosition())

		casterEntPos.y = casterEntPos.y + member:getRealHeight() * 0.5

		local ret = pg.game.camera:checkInViewport(casterEntPos)

		VectorPool.returnVector(casterEntPos)

		return ret
	end

	return false
end

function AIGroupCombatComponent:grantGroupCombatTag(needGrantCount)
	local memberActorId, __ = next(self.groupCombatData.members)
	local fitMemberList = ListPool.getList()
	local notFitMemberList = ListPool.getList()

	while memberActorId do
		local member = pg.getEntityByActorId(memberActorId)

		if member and not Utils.hasEntityTag(member, AiConst.CombatTag) then
			local maxKeepBoxDist = member:getConfigData().maxKeepBoxDist or 10
			local memberAttackActorId = member:getAttackTargetActorId()

			if not self:groupCombatFilterByLocked(member) then
				Utils.addEntityTag(member, AiConst.CombatTag)

				needGrantCount = needGrantCount - 1

				if needGrantCount <= 0 then
					break
				end
			elseif not self:groupCombatFilerByDistance(member, memberAttackActorId, maxKeepBoxDist) or self:groupCombatCheckInCameraView(member) then
				fitMemberList[#fitMemberList + 1] = member
			else
				notFitMemberList[#notFitMemberList + 1] = member
			end
		end

		memberActorId, __ = next(self.groupCombatData.members, memberActorId)
	end

	if Utils.checkClient() then
		table.sort(fitMemberList, self.groupCombatData.descendSortByCamera)
	end

	for i = 1, math.min(needGrantCount, #fitMemberList) do
		Utils.addEntityTag(fitMemberList[i], AiConst.CombatTag)
	end

	needGrantCount = needGrantCount - #fitMemberList

	if needGrantCount > 0 then
		table.sort(notFitMemberList, self.groupCombatData.ascendSortByPlayer)

		for i = 1, math.min(needGrantCount, #notFitMemberList) do
			Utils.addEntityTag(notFitMemberList[i], AiConst.CombatTag)
		end
	end

	ListPool.returnList(fitMemberList)
	ListPool.returnList(notFitMemberList)
end

function AIGroupCombatComponent:forceRefreshLockedCombatTag()
	local playerLockActorId = self:getGroupCombatLockedActorId()
	local lockedEnt = pg.getEntityByActorId(playerLockActorId)

	if lockedEnt and Utils.isPuppet(lockedEnt) and not Utils.hasEntityTag(lockedEnt, AiConst.CombatTag) then
		Utils.addEntityTag(lockedEnt, AiConst.CombatTag)
	end
end

function AIGroupCombatComponent:_ascendSortFuncByPlayer(a, b)
	return Vector3.HoriDistance(self:getPosition(), a:getPosition()) < Vector3.HoriDistance(self:getPosition(), b:getPosition())
end

function AIGroupCombatComponent:_descendSortFuncByPlayer(a, b)
	return Vector3.HoriDistance(self:getPosition(), a:getPosition()) > Vector3.HoriDistance(self:getPosition(), b:getPosition())
end

function AIGroupCombatComponent:_descendSortFuncByCamera(a, b)
	if Utils.checkClient() then
		local cameraPos = pg.game.camera:getCameraPosition()

		return Vector3.HoriDistance(cameraPos, a:getPosition()) > Vector3.HoriDistance(cameraPos, b:getPosition())
	else
		return true
	end
end

function AIGroupCombatComponent:getGroupCombatLockedActorId()
	local player = self
	local currentPet = player:getCurPetEntity()

	if currentPet then
		return currentPet:getAttackTargetActorId()
	end

	return player:getAttackTargetActorId()
end

function AIGroupCombatComponent:_memberRemoveCombatTag(member, force)
	if not force and member:ABILITY_ST() then
		return false
	end

	Utils.removeEntityTag(member, AiConst.CombatTag)

	return true
end

return AIGroupCombatComponent
