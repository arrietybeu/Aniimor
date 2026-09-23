-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\SpaceComponent\\ClientSpaceFollowComponent.lua

local Class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local ClientSpaceFollowComponent = Class.Component("ClientSpaceFollowComponent")

function ClientSpaceFollowComponent:ctor()
	self.followInfo = {}
end

function ClientSpaceFollowComponent:start()
	return
end

function ClientSpaceFollowComponent:canSpaceFollow()
	return Utils.canSpaceFollow(self.sceneId)
end

function ClientSpaceFollowComponent:isSpaceFollowLeader(uid)
	if self.followInfo[uid] then
		return true
	end

	return false
end

function ClientSpaceFollowComponent:isSpaceFollowMember(uid)
	for _, followList in pairs(self.followInfo) do
		if lume.findInList(followList, uid) then
			return true
		end
	end

	return false
end

function ClientSpaceFollowComponent:isSpaceFollowed(uid)
	if self:isSpaceFollowLeader(uid) then
		return true
	end

	for _, followList in pairs(self.followInfo) do
		if lume.findInList(followList, uid) then
			return true
		end
	end

	return false
end

function ClientSpaceFollowComponent:getSpaceFollowLeader(uid)
	for leader, followList in pairs(self.followInfo) do
		if leader == uid or lume.findInList(followList, uid) then
			return leader
		end
	end

	return nil
end

return ClientSpaceFollowComponent
