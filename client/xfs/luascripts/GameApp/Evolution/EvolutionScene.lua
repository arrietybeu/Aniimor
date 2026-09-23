-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Evolution\\EvolutionScene.lua

local Class = require("Core.Framework.Class")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ID_EVO_SCENE_MOVE_CAMERA = "evoSceneMoveCamera"
local EvolutionScene = Class.LightClass("EvolutionScene")

function EvolutionScene:ctor(resId, pos, rot)
	self.resId = resId
	self.pos = pos
	self.rot = rot
end

function EvolutionScene:startLoad(callback)
	self.scene = pg.game.cutscene:playCutscene(self.resId, self.resId, self.pos, self.rot, nil, nil, {
		dontDestroy = true
	})

	self:onCutsceneLoaded(callback)
end

function EvolutionScene:destroy()
	self.mainCamera = nil

	if self.scene ~= nil then
		self.scene:destroy()
	end
end

function EvolutionScene:onCutsceneLoaded(cb)
	self:initMainCamera()

	if cb then
		cb()
	end
end

function EvolutionScene:initMainCamera()
	if self.scene then
		local objectReference = self.scene.cutscene.prefabRoot:GetComponent("ObjectReference")

		if objectReference then
			self.mainCamera = objectReference:GetRefValue("mainCamera")
			self.cameraTarget = objectReference:GetRefValue("cameraTarget")
		end
	end
end

function EvolutionScene:setCameraOffset(offSet)
	if self.mainCamera then
		local oriPos = self.mainCamera.transform.position
		local newPos = oriPos + offSet

		self.mainCamera.transform.position = newPos
	end
end

function EvolutionScene:setCameraTarget(offset)
	if self.cameraTarget then
		local oriPos = self.cameraTarget.transform.position
		local newPos = oriPos + offset

		self.cameraTarget.transform.position = newPos
	end
end

function EvolutionScene:tweenMoveCamera(moveDelta)
	if not moveDelta or IsNil(self.mainCamera) then
		return
	end

	local cameraTs = self.mainCamera.transform
	local oriPos = cameraTs.position
	local targetPos = oriPos + moveDelta

	DoTweenAnimMgr.GlobalMove(cameraTs, LuaUIUtils.TweenId(ID_EVO_SCENE_MOVE_CAMERA), targetPos, 0.75, 0, CS.DG.Tweening.Ease.__CastFrom(6), nil, nil, false)
end

return EvolutionScene
