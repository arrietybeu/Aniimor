-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Communication\\DialogueCamera.lua

local CameraConst = require("GameApp.Camera.CameraConst")
local Const = require("Common.Const.Const")
local DialogueUtils = require("Utils.DialogueUtils")
local Utils = require("Common.Utils.Utils")
local DialogueConst = require("Const.DialogueConst")
local IS_MOBILE = IS_MOBILE
local DialogueCamera = {}
local DCTools = {}

function DialogueCamera.triggerCameraAnim(cameraPresetType, targetNpcEntity)
	if targetNpcEntity == nil then
		return
	end

	if cameraPresetType ~= DialogueConst.CAMERA_MODE.FREEDOM then
		return
	end

	DialogueCamera.triggerCameraDof(targetNpcEntity)
end

function DialogueCamera.triggerCameraDof(targetNpcEntity)
	local selfPos = pg.pawn:getPositionAgentPosition()
	local targetNpcPos = targetNpcEntity:getPositionAgentPosition()
	local midPoint = (selfPos + targetNpcPos) * 0.5
	local minDis, maxDis, distance, fov = 3, 5, 4, 40

	if not Utils.isPlayer(pg.pawn) and DCTools.__isTargetNpcPet(targetNpcEntity) then
		minDis, maxDis, distance, fov = DCTools.__calcPetPetCameraParams(targetNpcEntity, minDis, maxDis)
		midPoint.y = midPoint.y + DCTools.__calcPetPetHeightOffset(targetNpcEntity)

		DCTools.__enablePetPetDof(targetNpcEntity, pg.pawn)
	elseif Utils.isPlayer(pg.pawn) and not DCTools.__isTargetNpcPet(targetNpcEntity) then
		local playerHeight = DCTools.__getPlayerCameraHeight()

		midPoint.y = midPoint.y + playerHeight - 0.2

		DCTools.__enableDialogueDof(CameraConst.DofStateKeys.Dialogue_HumanVSHuman)
	else
		local playerHeight = DCTools.__getPlayerCameraHeight()

		midPoint.y = midPoint.y + playerHeight

		DCTools.__enableDialogueDof(CameraConst.DofStateKeys.Dialogue_HumanVSAniimo)
	end

	local initRot = DialogueUtils.calculateClosestInitialRotation(selfPos, targetNpcPos)

	pg.game.camera.npcDialogueCameraMode:enableFreedomCamera(true, initRot, midPoint, minDis, maxDis, distance, fov)
end

function DCTools.__isTargetNpcPet(targetNpcEntity)
	local npcType = targetNpcEntity:getConfigData().npcType

	return Utils.isPetNpc(targetNpcEntity) or Utils.isPuppet(targetNpcEntity) and npcType ~= nil and npcType ~= Const.NPC_TYPE.Human
end

function DCTools.__calcPetPetCameraParams(targetNpcEntity, minDis, maxDis)
	local npcModelScale = targetNpcEntity.curModelScale or 1
	local pNearHeight = pg.pawn:getCameraHeightInfo()
	local tNearHeight = targetNpcEntity.getCameraHeightInfo and targetNpcEntity:getCameraHeightInfo() or pNearHeight
	local avgHeight = (pNearHeight + tNearHeight * npcModelScale) * 0.5

	if pNearHeight < avgHeight then
		return minDis * npcModelScale, maxDis * npcModelScale, minDis, 45
	end

	return minDis, maxDis, 3, 40
end

function DCTools.__calcPetPetHeightOffset(targetNpcEntity)
	local pNearHeight = pg.pawn:getCameraHeightInfo()
	local tNearHeight = targetNpcEntity.getCameraHeightInfo and targetNpcEntity:getCameraHeightInfo() or pNearHeight
	local npcModelScale = targetNpcEntity.curModelScale or 1

	return (pNearHeight + tNearHeight * npcModelScale) * 0.5
end

function DCTools.__enablePetPetDof(targetNpcEntity, pawnEnt)
	local pNearHeight = pawnEnt:getCameraHeightInfo()
	local tNearHeight = targetNpcEntity.getCameraHeightInfo and targetNpcEntity:getCameraHeightInfo() or pNearHeight
	local npcModelScale = targetNpcEntity.curModelScale or 1
	local avgHeight = (pNearHeight + tNearHeight * npcModelScale) * 0.5
	local dofKey = pNearHeight < avgHeight and CameraConst.DofStateKeys.Dialogue_AniimoHuge or CameraConst.DofStateKeys.Dialogue_AniimoSmall

	DCTools.__enableDialogueDof(dofKey)
end

function DCTools.__getPlayerCameraHeight()
	if pg.me ~= nil then
		local playerHeight = pg.me:getCameraHeightInfo()

		if playerHeight ~= nil then
			return playerHeight
		end
	end

	return 0
end

function DCTools.__enableDialogueDof(dofKey)
	if IS_MOBILE then
		return
	end

	pg.game.camera:setDofEnable(dofKey, true)
end

return DialogueCamera
