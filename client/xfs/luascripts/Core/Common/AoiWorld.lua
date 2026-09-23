-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\AoiWorld.lua

local class = require("Core.Framework.Class")
local CallbackHandler = require("Core.Common.CallbackHandler")
local CallbackManager = require("Core.Net.CallbackManager")
local LoggerManager = require("Core.Log.LoggerManager")
local aoi = require("aoi")
local AoiWorld = class.Class("AoiWorld")

function AoiWorld:ctor(aoiType, enterCallback, leaveCallback)
	self.aoiType = aoiType
	self.enterCallback = enterCallback or CallbackHandler(self, "onEnterCallback")
	self.leaveCallback = leaveCallback or CallbackHandler(self, "onLeaveCallback")
	self.cObj, self.mappingObj = aoi.newAoiWorld(aoiType)

	CallbackManager.registerAoiWorld(self, self.mappingObj)
end

function AoiWorld:destroy()
	CallbackManager.unRegisterAoiWorld(self.mappingObj)

	self.mappingObj = nil

	if self.cObj ~= nil then
		self.cObj:destroy()

		self.cObj = nil
	end
end

function AoiWorld:setBoundary(xMin, xMax, zMin, zMax, aoiRadiusMax)
	if self.cObj ~= nil then
		self.cObj:setBoundary(xMin, xMax, zMin, zMax, aoiRadiusMax)
	end
end

function AoiWorld:addActor(actorId, x, y, z, tag, userdatas)
	if self.cObj ~= nil then
		self.cObj:addActor(actorId, x, y, z, tag, userdatas)
	end
end

function AoiWorld:addActorWithAoi(actorId, x, y, z, radius)
	if self.cObj ~= nil then
		self.cObj:addActorWithAoi(actorId, x, y, z, radius)
	end
end

function AoiWorld:removeActor(actorId)
	if self.cObj ~= nil then
		self.cObj:removeActor(actorId)
	end
end

function AoiWorld:moveActor(actorId, x, y, z)
	if self.cObj ~= nil then
		self.cObj:moveActor(actorId, x, y, z)
	end
end

function AoiWorld:addAoi(actorId, aoiId, radius, rules)
	if self.cObj ~= nil then
		self.cObj:addAoi(actorId, aoiId, radius, rules)
	end
end

function AoiWorld:removeAoi(actorId, aoiId)
	if self.cObj ~= nil then
		self.cObj:removeAoi(actorId, aoiId)
	end
end

function AoiWorld:setAoiRadius(actorId, aoiId, radius)
	if self.cObj ~= nil then
		self.cObj:setAoiRadius(actorId, aoiId, radius)
	end
end

function AoiWorld:setAoiTag(actorId, tag)
	if self.cObj ~= nil then
		self.cObj:setAoiTag(actorId, tag)
	end
end

function AoiWorld:addAoiUserdata(actorId, userdatas)
	if self.cObj ~= nil then
		self.cObj:addAoiUserdata(actorId, userdatas)
	end
end

function AoiWorld:removeAoiUserdata(actorId, keys)
	if self.cObj ~= nil then
		self.cObj:removeAoiUserdata(actorId, keys)
	end
end

function AoiWorld:getAoiActors(actorId)
	if self.cObj ~= nil then
		return self.cObj:getAoiActors(actorId)
	end
end

function AoiWorld:getAoiActorsByAoiId(actorId, aoiId)
	if self.cObj ~= nil then
		return self.cObj:getAoiActorsByAoiId(actorId, aoiId)
	end
end

function AoiWorld:getAoiActorsByRules(actorId, rules)
	if self.cObj ~= nil then
		return self.cObj:getAoiActorsByRules(actorId, rules)
	end
end

function AoiWorld:getAoiObservers(actorId)
	if self.cObj ~= nil then
		return self.cObj:getAoiObservers(actorId)
	end
end

function AoiWorld:debug()
	if self.cObj ~= nil then
		self.cObj:debug()
	end
end

function AoiWorld:onEnterCallback(enterMap)
	return
end

function AoiWorld:onLeaveCallback(leaveMap)
	return
end

return AoiWorld
