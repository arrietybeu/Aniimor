-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\PetVariant\\PetVariantScene.lua

local AudioConst = require("Const.AudioConst")
local CallbackHandler = require("Core.Common.CallbackHandler")
local Class = require("Core.Framework.Class")
local SELF_PET_PATH = "Role/ChongWu01"
local FRIEND_PET_PATH = "Role/ChongWu02"
local PetVariantScene = Class.LightClass("PetVariantScene")

function PetVariantScene:ctor(resId, pos, rot, outputCamera)
	self.resId = resId
	self.pos = pos
	self.rot = rot
	self.outputCamera = outputCamera
end

function PetVariantScene:startPlay(bindCallback, finishCallback)
	self.bindSucceeded = false
	self.bindCallback = bindCallback
	self.finishCallback = finishCallback

	local scene = pg.game.cutscene:playCutscene(self.resId, self.resId, self.pos, self.rot, nil, false, {
		dontDestroy = true,
		createCallback = CallbackHandler(self, "_onSceneCreated"),
		startPlayCallback = CallbackHandler(self, "_onScenePlayed"),
		endCallback = CallbackHandler(self, "_onSceneFinished")
	}, nil)

	if self.destroyed then
		if scene then
			scene:destroy()
		end

		return false
	end

	self.scene = scene

	return self.scene ~= nil and self.bindSucceeded
end

function PetVariantScene:_onScenePlayed()
	if not self.bindSucceeded then
		return
	end

	pg.game.audio:playBgm("BGM_UI_PetHugs", AudioConst.BgmPriority.Cutscene)
end

function PetVariantScene:_onSceneCreated(scene)
	local bindCallback = self.bindCallback

	self.bindCallback = nil

	if not self:_resolveSceneReferences(scene) then
		return
	end

	if not self:_redirectOutputCamera() then
		return
	end

	if bindCallback then
		self.bindSucceeded = bindCallback(self) ~= false
	end
end

function PetVariantScene:_resolveSceneReferences(scene)
	local cutscene = scene and scene.cutscene
	local prefabRoot = cutscene and cutscene.prefabRoot
	local prefabRootTransform = prefabRoot and prefabRoot.transform

	if IsNil(prefabRootTransform) then
		return false
	end

	self.selfPetAnchor = prefabRootTransform:Find(SELF_PET_PATH)
	self.friendPetAnchor = prefabRootTransform:Find(FRIEND_PET_PATH)

	return NotNil(self.selfPetAnchor) and NotNil(self.friendPetAnchor)
end

function PetVariantScene:_redirectOutputCamera()
	local vcManager = pg.global.cameraMgr.vcManager
	local rootGroup = vcManager and vcManager.rootGroup

	if rootGroup == nil then
		return false
	end

	self.rootGroup = rootGroup
	self.originalOutputCamera = rootGroup.targetCamera
	rootGroup.targetCamera = self.outputCamera

	self:_resetCameraBlend()

	return true
end

function PetVariantScene:_onSceneFinished()
	self:_resetCameraBlend()

	local finishCallback = self.finishCallback

	self.finishCallback = nil

	if finishCallback then
		finishCallback()
	end
end

function PetVariantScene:_resetCameraBlend()
	local vcManager = pg.global.cameraMgr.vcManager
	local ownsOutput = vcManager ~= nil and self.rootGroup ~= nil and vcManager.rootGroup == self.rootGroup and self.rootGroup.targetCamera == self.outputCamera

	if not ownsOutput then
		return
	end

	local rootCameraGroup = vcManager.rootCameraGroup

	if rootCameraGroup then
		rootCameraGroup:ResetBlendStack()
	end
end

function PetVariantScene:getPetAnchors()
	return self.selfPetAnchor, self.friendPetAnchor
end

function PetVariantScene:destroy()
	if self.destroyed then
		return
	end

	self.destroyed = true
	self.selfPetAnchor = nil
	self.friendPetAnchor = nil
	self.bindSucceeded = nil
	self.bindCallback = nil
	self.finishCallback = nil

	self:_resetCameraBlend()

	local scene = self.scene

	self.scene = nil

	if scene then
		scene:destroy()
	end

	self:_stopBgm()
	self:_restoreOutputCamera()

	self.outputCamera = nil
end

function PetVariantScene:_stopBgm()
	pg.game.audio:playBgm(nil, AudioConst.BgmPriority.Cutscene)
end

function PetVariantScene:_restoreOutputCamera()
	local rootGroup = self.rootGroup

	if rootGroup and rootGroup.targetCamera == self.outputCamera then
		rootGroup.targetCamera = self.originalOutputCamera
	end

	self.rootGroup = nil
	self.originalOutputCamera = nil
end

return PetVariantScene
