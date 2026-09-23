-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertility\\Component\\BreedSceneComponent.lua

local ClientUtils = require("Utils.ClientUtils")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local BreedSceneComponent = Class.LightClass("BreedSceneComponent", UIComponent)
local UIConst = require("Const.UIConst")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ClientConst = require("Const.ClientConst")
local TimerManager = require("Core.Timer.TimerManager")
local ClientSimpleVirtualEntity = require("Entities.ClientSimpleVirtualEntity")
local PetData = require("Data.pet_data")
local PlayableConst = require("Common.Const.PlayableConst")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ID_PARMON_A_GLOBAL_MOVE = "parmonAGlobalMove"
local ID_PARMON_A_ROTATE = "parmonARotate"
local ID_CAMERA_A_GLOBAL_MOVE = "cameraAGlobalMove"
local ID_CAMERA_A_ROTATE = "cameraARotate"
local ID_CAMERA_A_OTHERS = "cameraAOthers"

function BreedSceneComponent:findObjects()
	self.petBallPreviewScene = pg.game.uiScene:getScene(UISceneConst.PET_BALL_PREVIEW_SCENE)
	self.finishLoadCb = nil
	self.refreshViewCount = 0
end

function BreedSceneComponent:load(parmonA, parmonB, cb)
	self.loaded = true
	self.parmonATId = parmonA
	self.parmonBTId = parmonB
	self.finishLoadCb = cb

	self:initScene()
end

function BreedSceneComponent:initScene()
	self.view.root:TryChangePage("showSkipBtn", 1)

	self.scene = self.petBallPreviewScene.breedScene
	self.breedTimelineModelReplacer = self.scene:Find("Breeding_Timline/Breeding_System/TimeLine"):GetComponent("BreedTimelineModelReplacer")

	self:getAllPosAndRot()
	self:initModels()
end

function BreedSceneComponent:getAllPosAndRot()
	self.allPosAndRotTable = self.breedTimelineModelReplacer:GetAllPosAndRot()
end

function BreedSceneComponent:initModels()
	self.entA = self:initModel(self.parmonATId, nil, 1, true)
	self.entB = self:initModel(self.parmonBTId, nil, 2, false)

	if self.entA and self.entA.eModel then
		self.entA.eModel:SetTransformParent(self.scene, false)

		local _lpA = self.allPosAndRotTable[0]

		self.entA:setPositionAgentLocalPos(_lpA[1], _lpA[2], _lpA[3])
		self.entA.eModel:SetPositionAgentLocalEulerEx(self.allPosAndRotTable[3][1], self.allPosAndRotTable[3][2], self.allPosAndRotTable[3][3])
		self.entA.eModel:SetActive(true)
	end

	if self.entB and self.entB.eModel then
		self.entB.eModel:SetTransformParent(self.scene, false)

		local _lpB = self.allPosAndRotTable[2]

		self.entB:setPositionAgentLocalPos(_lpB[1], _lpB[2], _lpB[3])
		self.entB.eModel:SetPositionAgentLocalEulerEx(self.allPosAndRotTable[5][1], self.allPosAndRotTable[5][2], self.allPosAndRotTable[5][3])
		self.entB.eModel:SetActive(true)
	end
end

function BreedSceneComponent:tween(time, cameraAObj)
	DoTweenAnimMgr.Move(self.entA.actorId, LuaUIUtils.TweenId(ID_PARMON_A_GLOBAL_MOVE), self.allPosAndRotTable[1], time, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
		self:walkFinishedEvent()
	end, false, nil)
	DoTweenAnimMgr.Rotate(self.entA.actorId, LuaUIUtils.TweenId(ID_PARMON_A_ROTATE), self.allPosAndRotTable[4], time, 0, CS.DG.Tweening.Ease.__CastFrom(1), nil, false)
	DoTweenAnimMgr.Move(cameraAObj.transform, LuaUIUtils.TweenId(ID_CAMERA_A_GLOBAL_MOVE), self.allPosAndRotTable[8], time, 0, CS.DG.Tweening.Ease.__CastFrom(1), nil, false, nil)
	DoTweenAnimMgr.Rotate(cameraAObj.transform, LuaUIUtils.TweenId(ID_CAMERA_A_ROTATE), self.allPosAndRotTable[9], time, 0, CS.DG.Tweening.Ease.__CastFrom(1), nil, false)
	DoTweenAnimMgr.DoFloat(cameraAObj, self.breedTimelineModelReplacer:GetCameraAFov(), self.breedTimelineModelReplacer:GetCameraBFov(), LuaUIUtils.TweenId(ID_CAMERA_A_OTHERS), time, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
		return
	end, function(fov)
		if self.breedTimelineModelReplacer then
			self.breedTimelineModelReplacer:SetCameraAFov(fov)
		end
	end, function()
		return
	end, false)
end

function BreedSceneComponent:walkFinishedEvent()
	self.entA:playAnimation(PlayableConst.Idle)
	self.entA:playAnimation(PlayableConst.Behav_Happy)
	self.entB:playAnimation(PlayableConst.Behav_Happy)
	self.breedTimelineModelReplacer:PlayRemainedTimeline()

	function self.breedTimelineModelReplacer.luaOnBreedTimelineFinished()
		self:finish()
	end
end

function BreedSceneComponent:finish()
	pg.global.ui:open(UIConst.UI_ID_PET_FERTILITY_RESULT)
	self.ctrl:displayPetBallBreed(false)
end

function BreedSceneComponent:initModel(tId, label, gender, isParmonA)
	local cData = PetData[tId]

	if cData == nil then
		return
	end

	local ent = ClientSimpleVirtualEntity.new()

	ent:setConfigData(cData)

	local initInfo = {
		templateId = tId,
		label = label,
		gender = gender
	}

	ent:init(initInfo)
	ent:postInit(initInfo)
	ent:start()
	ent:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)

	local modelView = ent.eModel.modelModelView

	function modelView.luaOnModelRefreshFinshed()
		self:onBothParmonModelRefreshFinished()
	end

	if isParmonA then
		self.timer1 = TimerManager.addNextFrameCb(function()
			ent:playAnimation(PlayableConst.WalkBlend)
		end)
	else
		ent:playAnimation(PlayableConst.Idle)
	end

	return ent
end

function BreedSceneComponent:onBothParmonModelRefreshFinished()
	self.refreshViewCount = self.refreshViewCount + 1

	if self.refreshViewCount == 2 then
		self.breedTimelineModelReplacer:EnableCameraA(true)
		self.breedTimelineModelReplacer:EnableCameraB(true)

		local entADistance = Vector3.Distance(self.allPosAndRotTable[0], self.allPosAndRotTable[1])
		local aPetWalkSpeed = PetData[self.parmonATId].walkspeed_v or 1
		local time = entADistance / aPetWalkSpeed
		local cameraAObj = self.breedTimelineModelReplacer:GetCameraAGameObject()

		self.timer = TimerManager.addTimer(0.1, function()
			if self.finishLoadCb then
				self.finishLoadCb()
			end

			self:tween(time, cameraAObj)
		end)
	end
end

function BreedSceneComponent:reset()
	TimerManager.removeTimer(self.timer)
	TimerManager.removeTimer(self.timer1)

	self.finishLoadCb = nil
	self.refreshViewCount = 0
	self.loaded = nil
	self.timer = nil
	self.timer1 = nil

	if self.entA then
		self.entA.eModel.modelModelView.luaOnModelRefreshFinshed = nil

		ClientUtils.safeDestroy(self.entA)

		self.entA = nil
	end

	if self.entB then
		self.entB.eModel.modelModelView.luaOnModelRefreshFinshed = nil

		ClientUtils.safeDestroy(self.entB)

		self.entB = nil
	end

	self.parmonATId = nil
	self.parmonBTId = nil
	self.scene = nil

	if self.breedTimelineModelReplacer then
		self.breedTimelineModelReplacer:ResetCamera()

		self.breedTimelineModelReplacer = nil
	end

	self.allPosAndRotTable = nil

	self.view.root:TryChangePage("showSkipBtn", 0)
end

function BreedSceneComponent:onDestroy()
	self:reset()
	UIComponent.onDestroy(self)
end

return BreedSceneComponent
