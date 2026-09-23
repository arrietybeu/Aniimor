-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\PetBallPreviewScene.lua

local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local PetBallPreviewScene = Class.LightClass("PetBallPreviewScene", UISceneBase)

function PetBallPreviewScene:onStart()
	self:initScene()
end

function PetBallPreviewScene:initScene()
	self.petBallPreviewController = self.scene.transform:GetComponent("PetBallPreviewController")
	self.objectReference = self.scene.transform:GetComponent("ObjectReference")
	self.cameraTransform = self.objectReference:GetRefValue("cameraTransform")
	self.parmonGeneratedPosTransform = self.objectReference:GetRefValue("parmonGeneratedPosTransform")
	self.breedSelectedMalePosTransform = self.objectReference:GetRefValue("breedSelectedMalePosTransform")
	self.breedSelectedFemalePosTransform = self.objectReference:GetRefValue("breedSelectedFemalePosTransform")
	self.preBallGenePos1 = self.objectReference:GetRefValue("preBallGenePos1")
	self.preBallGenePos2 = self.objectReference:GetRefValue("preBallGenePos2")
	self.preBallGenePos3 = self.objectReference:GetRefValue("preBallGenePos3")
	self.preBallGenePos4 = self.objectReference:GetRefValue("preBallGenePos4")
	self.nxtBallGenePos1 = self.objectReference:GetRefValue("nxtBallGenePos1")
	self.petBallOnhookSceneTransform = self.objectReference:GetRefValue("petBallOnhookSceneTransform")
	self.breedScene = self.objectReference:GetRefValue("breedScene")
	self.leftOrderTrans = {
		self.preBallGenePos1,
		self.preBallGenePos2,
		self.preBallGenePos3,
		self.preBallGenePos4
	}
	self.rightOrderTrans = {
		self.nxtBallGenePos1
	}
	self.camera = self.cameraTransform.gameObject
	self.scene.transform.position = Vector3(0, 500, 0)

	pg.game.petBall:bindPreviewSceneCamera(self.camera)
end

function PetBallPreviewScene:onDestroy()
	pg.game.petBall:bindPreviewSceneCamera(nil)
end

function PetBallPreviewScene:playTimeline(type, nextType, cb, delayCb, delay)
	nextType = nextType or -1
	delay = delay or -1

	if pg.global.ui:checkUIShow(UIConst.UI_ID_PET_FERTILITY) then
		pg.global.ui.petFertility:showAllUI(false)
	end

	self.petBallPreviewController:PlayTimeline(type, nextType, function()
		if cb then
			cb()
		end

		if pg.global.ui:checkUIShow(UIConst.UI_ID_PET_FERTILITY) then
			pg.global.ui.petFertility:showAllUI(true)
		end
	end, function()
		if delayCb then
			delayCb()
		end
	end, delay)
end

return PetBallPreviewScene
