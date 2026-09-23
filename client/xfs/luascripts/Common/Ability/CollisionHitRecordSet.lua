-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\CollisionHitRecordSet.lua

local Class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local CollisionHitRecordSet = Class.LiteClass("CollisionHitRecordSet")
local ToBool = ToBool

function CollisionHitRecordSet:ctor()
	if self.data then
		lume.clear(self.data)
	else
		self.data = {}
	end
end

function CollisionHitRecordSet:checkCanAddHitTarget(actorId)
	return not ToBool(self.data[actorId])
end

function CollisionHitRecordSet:addHitTarget(actorId, cd)
	if not ToBool(actorId) then
		return
	end

	if cd <= 0 then
		return
	end

	local actorSetInfo = self.data[actorId]

	if actorSetInfo == nil then
		self.data[actorId] = {}
		actorSetInfo = self.data[actorId]
	end

	actorSetInfo.timer = cd

	return actorSetInfo
end

function CollisionHitRecordSet:tryAddHitTarget(actorId, cd)
	if ToBool(self.data[actorId]) then
		return false
	end

	self:addHitTarget(actorId, cd)

	return true
end

function CollisionHitRecordSet:updateCollisionHitRecordSet(deltaSeconds, onRemoveCb)
	if not ToBool(self.data) then
		return
	end

	local waitRemoveColliderActorId = self._waitRemoveCache

	if not waitRemoveColliderActorId then
		waitRemoveColliderActorId = {}
		self._waitRemoveCache = waitRemoveColliderActorId
	end

	local removeCount = 0

	for actorId, hitData in pairs(self.data) do
		if hitData and hitData.timer then
			hitData.timer = hitData.timer - deltaSeconds

			if hitData.timer <= 0 then
				removeCount = removeCount + 1
				waitRemoveColliderActorId[removeCount] = actorId
			end
		end
	end

	for i = 1, removeCount do
		local actorId = waitRemoveColliderActorId[i]

		if onRemoveCb then
			onRemoveCb(actorId, self.data[actorId])
		end

		self.data[actorId] = nil
		waitRemoveColliderActorId[i] = nil
	end
end

function CollisionHitRecordSet:clear(onClearEntryCb)
	for actorId, hitData in pairs(self.data) do
		if hitData and onClearEntryCb then
			onClearEntryCb(actorId, hitData)
		end
	end

	lume.clear(self.data)
end

return CollisionHitRecordSet
