-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\MovingPlatform.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local MovingPlatform = Class.LightClass("MovingPlatform", LevelItem)
local Time = require("Core.Common.Time")
local SceneUtils = require("Common.Utils.SceneUtils")

function MovingPlatform:ctor(sandbox, spawnInfo, syncInfo)
	MovingPlatform.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function MovingPlatform:initShareMem()
	MovingPlatform.super.initShareMem(self)
end

function MovingPlatform:onSandboxReady()
	self.movingPlatformSB = self.shell.gameObject:GetComponent("MovingPlatformSB")
end

function MovingPlatform:initPosition(startPos)
	if not self.sandbox.isMain then
		return
	end

	self:clientFirstSetInfo({
		startPos = startPos
	})
end

function MovingPlatform:moveTo(startPos, endIndex)
	if not self.sandbox.isMain then
		return
	end

	self:clientFirstSetInfo({
		isInit = true,
		startTime = Time.secondCache,
		startPos = startPos,
		endIndex = endIndex
	})
end

function MovingPlatform:continue()
	if not self.sandbox.isMain then
		return
	end

	if not self.shareMem:get("isPause") then
		return
	end

	self:clientFirstSetInfo({
		isPause = false,
		startTime = Time.secondCache
	})
end

function MovingPlatform:pause(startPos)
	if not self.sandbox.isMain then
		return
	end

	if self.shareMem:get("isPause") then
		return
	end

	self:clientFirstSetInfo({
		isPause = true,
		startPos = startPos
	})
end

function MovingPlatform:setSyncInfo(syncInfo, isInit)
	MovingPlatform.super.setSyncInfo(self, syncInfo, isInit)
end

function MovingPlatform:clientFirstSetInfo(syncInfo)
	for k, v in pairs(syncInfo) do
		self.shareMem:set(k, v)
	end

	self.shareMem:flush()
	self:syncFieldValue(syncInfo)
end

function MovingPlatform:RPC_SC_MoveNext(args)
	if self.movingPlatformSB then
		self.movingPlatformSB:MoveNext()
	end
end

function MovingPlatform:destroy()
	MovingPlatform.super.destroy(self)
end

function MovingPlatform:setActived(v)
	if not self.sandbox.isMain then
		return
	end

	self:clientFirstSetInfo({
		actived = v
	})
end

function MovingPlatform:setReachEnd(v)
	if not self.sandbox.isMain then
		return
	end

	self:clientFirstSetInfo({
		isEnd = v
	})
end

return MovingPlatform
