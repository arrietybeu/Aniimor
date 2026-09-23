-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\PlatformPro.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local PlatformPro = Class.LightClass("PlatformPro", LevelItem)
local Time = require("Core.Common.Time")
local SceneUtils = require("Common.Utils.SceneUtils")

function PlatformPro:ctor(sandbox, spawnInfo, syncInfo)
	PlatformPro.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function PlatformPro:moveTo(startPos, endPos, speed)
	self:clientFirstSetInfo({
		isInit = true,
		startTime = Time.secondCache,
		startPos = startPos,
		endPos = endPos,
		speed = speed
	})
end

function PlatformPro:teleportTo(endPos)
	self:clientFirstSetInfo({
		isInit = true,
		startPos = endPos,
		endPos = endPos
	})
end

function PlatformPro:setSyncInfo(syncInfo, isInit)
	if pg.me.id == syncInfo.senderId then
		return
	end

	PlatformPro.super.setSyncInfo(self, syncInfo, isInit)
end

function PlatformPro:setMovingState(state)
	self:clientFirstSetInfo({
		movingState = state
	})
end

function PlatformPro:setPerformState(state)
	self:clientFirstSetInfo({
		performState = state
	})
end

function PlatformPro:setActived(active)
	self:clientFirstSetInfo({
		actived = active
	})
end

function PlatformPro:setActionIndex(index)
	self:clientFirstSetInfo({
		actionIndex = index
	})
end

function PlatformPro:clientFirstSetSingle(field, value)
	self:clientFirstSetInfo({
		[field] = value
	})
end

function PlatformPro:clientFirstSetInfo(syncInfo)
	if not self.sandbox.isMain then
		return
	end

	for k, v in pairs(syncInfo) do
		self.shareMem:set(k, v)
	end

	syncInfo.senderId = pg.me.id

	self.shareMem:flush()
	self:syncFieldValue(syncInfo)
end

function PlatformPro:destroy()
	PlatformPro.super.destroy(self)
end

return PlatformPro
