-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\Peep.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local Peep = Class.LightClass("Peep", LevelItem)
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local SandboxConst = require("Common.Const.SandboxConst")

function Peep:ctor(sandbox, spawnInfo, syncInfo)
	Peep.super.ctor(self, sandbox, spawnInfo, syncInfo)

	self.sysName = "Peep"
end

function Peep:onSandboxReady()
	Peep.super.onSandboxReady(self)

	self.peepSB = self.shell.gameObject:GetComponent("PeepSB")
	self.sneakModeTransitionTime = 0.3
end

function Peep:setSwitch(isOn)
	local cameraRotation = self.peepSB.cameraRotation
	local targetRot = self.peepSB.transform.eulerAngles + self.peepSB.cameraRotation
	local minPitch = targetRot.x - self.peepSB.rotateAngleY
	local maxPitch = targetRot.x + self.peepSB.rotateAngleY
	local minYaw = targetRot.y - self.peepSB.rotateAngleX
	local maxYaw = targetRot.y + self.peepSB.rotateAngleX
	local targetPos = self.peepSB.transform:TransformPoint(self.peepSB.cameraPosition)

	pg.game.camera.playerCameraMode:setPeepCameraArgs(self.peepSB.fleldOfView, minPitch, maxPitch, minYaw, maxYaw, targetPos, targetRot)
	pg.game.camera.playerCameraMode:enablePeep(isOn)

	if self.peepSB.hidePlayer then
		pg.me:setVisible(ClientConst.MODEL_VISIBLE_KEY.PEEP, not isOn)
	end

	pg.me.inPeep = isOn

	if pg.pawn.updateStateCache then
		pg.pawn:updateStateCache("PEEP_ST")
	end

	if isOn then
		pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.PEEP, {
			[UIConst.UI_ID_PEEP_EXIT] = true
		})
		pg.global.ui:open(UIConst.UI_ID_PEEP_EXIT)
		pg.global.cameraMgr:StartSneakMode(self.sneakModeTransitionTime)
	else
		pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.PEEP)
		pg.global.ui:close(UIConst.UI_ID_PEEP_EXIT)
		pg.global.cameraMgr:StopSneakMode(self.sneakModeTransitionTime)
	end
end

function Peep:destroy()
	if pg.global.ui:checkUIOpen(UIConst.UI_ID_PEEP_EXIT) then
		pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.PEEP)
		pg.global.ui:close(UIConst.UI_ID_PEEP_EXIT)
	end

	pg.game.camera.playerCameraMode:enablePeep(false)

	pg.me.inPeep = false

	if pg.pawn.updateStateCache then
		pg.pawn:updateStateCache("PEEP_ST")
	end

	Peep.super.destroy(self)
end

return Peep
