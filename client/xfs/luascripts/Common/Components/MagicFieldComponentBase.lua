-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Components\\MagicFieldComponentBase.lua

local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local MagicFieldComponentBase = Class.Component("MagicFieldComponentBase")

function MagicFieldComponentBase:ctor()
	return
end

function MagicFieldComponentBase:getCustomClientDict(clientDict)
	clientDict.instanceId = self.instanceId
	clientDict.srcActorId = self.srcActorId
	clientDict.masterActorId = self.masterActorId
	clientDict.camp = self.camp
	clientDict.templateId = self.templateId
	clientDict.attached = self.attached
end

function MagicFieldComponentBase:init(spawnParams)
	if pg.component == "game" then
		self.templateId = spawnParams.templateId or 0
	end

	self.instanceId = spawnParams.instanceId
	self.srcActorId = spawnParams.srcActorId
	self.masterActorId = spawnParams.masterActorId
	self.attached = spawnParams.attached
	self.timeScale = 1
	self.globalFreeze = 1

	return true
end

function MagicFieldComponentBase:start()
	return
end

function MagicFieldComponentBase:refreshExtent(deltaSeconds)
	self.extendAccumulateTime = math.max(self.extendAccumulateTime + deltaSeconds, self.extendDuration)

	if self.extendAccumulateTime < self.extendDuration then
		self.curExtent = self.extent * (1 + math.min(1, self.extendAccumulateTime / self.extendDuration) * (self.extendRatio - 1))
	end
end

function MagicFieldComponentBase:destroy()
	self.isDestroyed = true
end

return MagicFieldComponentBase
