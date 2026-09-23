-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\ArkBridge.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local ArkBridge = Class.LightClass("ArkBridge", LevelItem)

function ArkBridge:ctor(sandbox, spawnInfo, syncInfo)
	ArkBridge.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function ArkBridge:onSandboxReady()
	ArkBridge.super.onSandboxReady(self)

	self.ArkBridgeSB = self.shell.gameObject:GetComponent("ArkBridgeSB")
end

function ArkBridge:onPlayerEnter()
	local angle = self:GetHorizontalSignedAngle(pg.me:getForward(), self.ArkBridgeSB.forward)

	if angle > -90 and angle < 90 then
		pg.me:serverSpaceMsg("RPC_CS_MmoItemConditionTrigger", {
			self.ArkBridgeSB.staticId,
			self.id
		})
	end
end

function ArkBridge:GetHorizontalSignedAngle(a, b)
	local aH = Vector3(a.x, 0, a.z).normalized
	local bH = Vector3(b.x, 0, b.z).normalized
	local dot = Vector3.Dot(aH, bH)

	dot = math.max(-1, math.min(1, dot))

	local angle = math.acos(dot) * 57.29578
	local cross = Vector3.Cross(aH, bH)

	if cross.y < 0 then
		angle = -angle
	end

	return angle
end

function ArkBridge:destroy()
	ArkBridge.super.destroy(self)
end

return ArkBridge
