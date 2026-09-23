-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientCallFriendsComponent.lua

local Class = require("Core.Framework.Class")
local Const = require("Const.Const")
local AttributeConst = require("Common.Const.AttributeConst")
local SysConfigData = require("Data.sys_config_data")
local ClientUtils = require("Utils.ClientUtils")
local Utils = require("Common.Utils.Utils")
local PlayableConst = require("Common.Const.PlayableConst")
local AIUtils = require("Common.Utils.AIUtils")
local GroupBehaviourConst = require("Common.Const.GroupBehaviourConst")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local ClientCallFriendsComponent = Class.Component("ClientCallFriendsComponent")

function ClientCallFriendsComponent:ctor()
	return
end

function ClientCallFriendsComponent:start()
	if self.isInControl then
		self:onControlChangeToPet()
	else
		self:onControlChangeToPlayer()
	end
end

function ClientCallFriendsComponent:EVENT_IsInControlChange()
	if self.isInControl then
		self:onControlChangeToPet()
	else
		self:onControlChangeToPlayer()
	end
end

function ClientCallFriendsComponent:onControlChangeToPet()
	self.callFriendsEnabled = true
	self.callFriendTotalCount = self:getConfigData().canCallFriendNum or SysConfigData.CollectCallFriendNum

	if self.callFriendsGroupBehav == nil then
		self.callFriendsGroupBehav = pg.me.space.aiMgr:createBehaviour("CallFriends", self)

		self.callFriendsGroupBehav:start()
	end
end

function ClientCallFriendsComponent:onControlChangeToPlayer()
	self.callFriendsEnabled = false

	if self.callFriendsGroupBehav then
		pg.me.space.aiMgr:destroyBehaviour(self.callFriendsGroupBehav)

		self.callFriendsGroupBehav = nil
	end
end

function ClientCallFriendsComponent:tick(deltaTime)
	if not self.callFriendsEnabled or not self.callFriendsGroupBehav or #self.slaves == 0 then
		return
	end

	for _, slaveActorId in ipairs(self.slaves) do
		local ent = pg.getEntityByActorId(slaveActorId)

		if ent and ent.agent and ent.agent:getRootState() == BaseEnum.EBTRootState.ST_Root_Recruit and self.callFriendsGroupBehav:getMemberIndex(ent) < 0 and ent.joinGroupBehaviour then
			local ret = ent:joinGroupBehaviour(self.callFriendsGroupBehav)

			if ret then
				AnimationUtils.exitMimicry(ent)
			end
		end
	end
end

function ClientCallFriendsComponent:doCallFriend(actorId)
	if not self.callFriendsEnabled or not self.callFriendsGroupBehav or #self.slaves >= self.callFriendTotalCount or table.contains(self.slaves, actorId) or self:isInCombat() then
		return
	end

	local targetEntity = pg.getEntityByActorId(actorId)

	if not targetEntity then
		return
	end

	local curPos = self:getPosition()
	local callFriendsDistance = SysConfigData.CollectCallFriendRange
	local canBeCallFriends = targetEntity:getConfigData().canBeCallFriends == 1 and targetEntity.slavesOwnerId == "" and not targetEntity.isInGoHome and not AIUtils.checkEntIsInLeave(targetEntity)

	if targetEntity.canInteractCallFriend ~= nil then
		canBeCallFriends = true
		callFriendsDistance = targetEntity.canInteractCallFriend.distance
	end

	if canBeCallFriends and Vector3.SqrDistance(curPos, targetEntity:getPosition()) <= callFriendsDistance * callFriendsDistance then
		pg.me:serverMsg("RPC_CS_StartCallFriend", self.actorId, actorId)
	end
end

function ClientCallFriendsComponent:isEntitySlavePuppets(staticId)
	local ent = self.space:getEntityByStaticId(staticId)

	if not ent then
		return false
	end

	return table.contains(self.slaves, ent.actorId)
end

function ClientCallFriendsComponent:destroy()
	return
end

return ClientCallFriendsComponent
