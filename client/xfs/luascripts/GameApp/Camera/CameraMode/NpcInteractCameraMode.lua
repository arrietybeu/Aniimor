-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\NpcInteractCameraMode.lua

local CameraMode = require("GameApp.Camera.CameraMode.CameraMode")
local CameraConst = require("GameApp.Camera.CameraConst")
local ClientConst = require("Const.ClientConst")
local HotkeyConst = require("Const.HotkeyConst")
local UIConst = require("Const.UIConst")
local CameraData = require("Data.camera_data")
local Class = require("Core.Framework.Class")
local ToBool = ToBool
local NpcInteractCameraMode = Class.OldLightClass("NpcInteractCameraMode", CameraMode)
local InteractionConst = require("Common.Const.InteractionConst")

NpcInteractCameraMode.MIN_DISTANCE = 2
NpcInteractCameraMode.MAX_DISTANCE = 12

function NpcInteractCameraMode:onCtor()
	CameraMode.onCtor(self)

	self.cameraMode.cameraController.maxPitch = self:getConfigData().maxPitch or 60
	self.cameraMode.cameraController.minPitch = self:getConfigData().minPitch or -60
	self.cameraMode.shoulder = Vector3(0, 0.5, 0)
	self.cameraMode.pivotOffset = Vector3(0, 1.2, 0)
	self.cameraMode.springArm.targetArmLength = 5
	self.defaultDistance = 5
end

function NpcInteractCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.NpcInteractCameraMode
end

function NpcInteractCameraMode:getCameraPriority()
	return CameraConst.PRIORITY_NPC_INTERACT_CAMERA
end

function NpcInteractCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_NPC_INTERACT
end

function NpcInteractCameraMode:getConfigData()
	return CameraData[CameraConst.CAMERA_NAME_NPC_INTERACT] or {}
end

function NpcInteractCameraMode:enableCamera(active)
	if active then
		local targetUnitList = pg.game.interaction.currentInteractLis

		if targetUnitList == nil then
			return
		end

		local selectedItem = pg.global.ui.interact:getSelectItem()

		if not selectedItem then
			return
		end

		local targetEnt

		for _, rootNode in ipairs(targetUnitList) do
			local units = rootNode.interactUnits

			for _, unit in ipairs(units) do
				if unit.interactType == InteractionConst.INTERACTION_TYPE_NPC_FUNC then
					targetEnt = unit:getEntity()

					break
				end
			end

			if targetEnt then
				break
			end
		end

		if not targetEnt then
			return
		end

		self.ent = targetEnt

		local me = pg.me

		self.cameraMode:SetTargetNpcByActorId(self.ent.actorId)
		self.cameraMode:SetFollowTransformByActorId(me.actorId)

		self.cameraMode.needFromRotation = true

		me:faceToTarget(self.ent)
		self.ent:faceToTarget(me)
		self:enterOperationCameraMode()
	else
		self:exitInteractMode()

		if self.ent and self.ent.resetRotation then
			self.ent:resetRotation()
		end
	end
end

function NpcInteractCameraMode:enterOperationCameraMode()
	self:setCameraDistance(4)
	self:setCameraOffset(1.2, 0.5)

	self.cameraMode.cameraController.maxPitch = 15
	self.cameraMode.cameraController.minPitch = 10

	pg.game.input:enablePlayerInput(false, HotkeyConst.INPUT_BLOCK_FLAG.NpcInteract)
	pg.game.input:enableCameraInput(false, HotkeyConst.INPUT_BLOCK_FLAG.NpcInteract)
	self:setActive(true)
end

function NpcInteractCameraMode:switchOptionMode()
	pg.game.input:enableCameraInput(false, HotkeyConst.INPUT_BLOCK_FLAG.NpcInteract)
end

function NpcInteractCameraMode:exitInteractMode()
	pg.game.input:enablePlayerInput(true, HotkeyConst.INPUT_BLOCK_FLAG.NpcInteract)
	pg.game.input:enableCameraInput(true, HotkeyConst.INPUT_BLOCK_FLAG.NpcInteract)
	self:setActive(false)
end

function NpcInteractCameraMode:setCameraDistance(distance)
	if not distance then
		self.cameraMode.springArm.targetArmLength = self.defaultDistance

		return
	end

	if distance < self.MIN_DISTANCE then
		distance = self.MIN_DISTANCE
	elseif distance > self.MAX_DISTANCE then
		distance = self.MAX_DISTANCE
	end

	self.cameraMode.springArm.targetArmLength = distance
end

function NpcInteractCameraMode:setCameraOffset(x, y)
	self.cameraMode.offset = Vector3(x or 0, y or 0, 0)
end

function NpcInteractCameraMode:setPosition(pos)
	if self.cameraMode then
		self.cameraMode:SetPosition(pos)
	end
end

function NpcInteractCameraMode:setRotation(rotation)
	if self.cameraMode then
		self.cameraMode:SetRotation(rotation)
	end
end

return NpcInteractCameraMode
