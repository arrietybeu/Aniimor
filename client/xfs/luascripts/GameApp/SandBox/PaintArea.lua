-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\PaintArea.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local SandboxConst = require("Common.Const.SandboxConst")
local PaintArea = Class.LightClass("PaintArea", LevelItem)

function PaintArea:ctor(sandbox, spawnInfo, syncInfo)
	PaintArea.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function PaintArea:onSandboxReady()
	PaintArea.super.onSandboxReady(self)

	self.paintAreaCom = self.shell.gameObject:GetComponent("PaintArea")
end

function PaintArea:onReachStartTrigger()
	self:serverMsg("RPC_CS_StartPaintArea")
end

function PaintArea:onReachEndTrigger()
	self:serverMsg("RPC_CS_FinishPaintArea")
end

function PaintArea:onVirtualCameraBlendFinish()
	self:serverMsg("RPC_CS_CameraBlendFinish")
end

function PaintArea:destroy()
	PaintArea.super.destroy(self)
end

return PaintArea
