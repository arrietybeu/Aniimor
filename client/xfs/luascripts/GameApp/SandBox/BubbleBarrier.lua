-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\BubbleBarrier.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local SandboxConst = require("Common.Const.SandboxConst")
local BubbleBarrier = Class.LightClass("BubbleBarrier", LevelItem)

function BubbleBarrier:ctor(sandbox, spawnInfo, syncInfo)
	BubbleBarrier.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function BubbleBarrier:onBubbleHit(actorId)
	self:sendSandboxEvent(SandboxConst.EVENT_TYPE.BUBBLE_BARRIER_HIT)
end

function BubbleBarrier:onBubbleDistort(actorId)
	self:sendSandboxEvent(SandboxConst.EVENT_TYPE.BUBBLE_BARRIER_DISTORT)
end

function BubbleBarrier:onBubbleShellStay(actorId)
	self:sendSandboxEvent(SandboxConst.EVENT_TYPE.BUBBLE_BARRIER_SHELL_STAY)
end

function BubbleBarrier:onBubbleShellExit(actorId)
	self:sendSandboxEvent(SandboxConst.EVENT_TYPE.BUBBLE_BARRIER_SHELL_EXIT)
end

function BubbleBarrier:onBubbleEnter(actorId)
	self:sendSandboxEvent(SandboxConst.EVENT_TYPE.BUBBLE_BARRIER_ENTER)
end

function BubbleBarrier:onBubbleLeave(actorId)
	self:sendSandboxEvent(SandboxConst.EVENT_TYPE.BUBBLE_BARRIER_LEAVE)
end

function BubbleBarrier:destroy()
	BubbleBarrier.super.destroy(self)
end

return BubbleBarrier
