-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\PVPRewardScene.lua

local ClientUtils = require("Utils.ClientUtils")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ClientConst = require("Const.ClientConst")
local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local PVPRewardScene = Class.LightClass("PVPRewardScene", UISceneBase)
local ClientSimpleVirtualEntity = require("Entities.ClientSimpleVirtualEntity")
local PetData = require("Data.pet_data")
local TmpPetTemplateData = require("Data.tmp_pet_template_data")

function PVPRewardScene:onCtor()
	return
end

function PVPRewardScene:onStart()
	self.scene.transform.position = Vector3.New(8, 0, 5.2)
	self.objectReference = self.scene.transform:GetComponent("ObjectReference")
	self.sMFenceblue = self.objectReference:GetRefValue("sMFenceblue")
	self.sMFencered = self.objectReference:GetRefValue("sMFencered")
	self.centerPos = self.objectReference:GetRefValue("centerPos")
	self.failure = self.objectReference:GetRefValue("failure")
	self.victory = self.objectReference:GetRefValue("victory")
	self.camera = self.objectReference:GetRefValue("camera")

	self.camera.gameObject:SetActiveEx(false)
end

function PVPRewardScene:showPet()
	local curPet = pg.me:getCurPetEntity()

	if curPet then
		self.showEnt = self:initModel(curPet.templateId)
	end

	if self.showEnt then
		self.showEnt.eModel:SetTransformParent(self.centerPos, false)
		self.showEnt.eModel:SetTransformLocalPosition()
	end

	local pos = self.camera.transform.position
	local rot = self.camera.transform.rotation
	local fov = self.camera.fieldOfView

	pg.game.camera:startPVPRewardCamera(pos, rot, fov)
end

function PVPRewardScene:showResult(victory)
	self:setActive(true)
	self.sMFenceblue.gameObject:SetActiveEx(victory)
	self.sMFencered.gameObject:SetActiveEx(not victory)
	self.victory.gameObject:SetActiveEx(victory)
	self.failure.gameObject:SetActiveEx(not victory)
	self:showPet()
end

function PVPRewardScene:initModel(tId)
	local tpdd = TmpPetTemplateData[tId]
	local templateId = tpdd and tpdd.templateBaseId
	local cData = PetData[templateId]

	if cData == nil then
		return
	end

	local ent = ClientSimpleVirtualEntity.new()

	ent:setConfigData(cData)

	local initInfo = {
		templateId = tId
	}

	ent:init(initInfo)
	ent:postInit(initInfo)
	ent:start()
	ent:setModelLayer(ClientConst.LayerDefine.LAYER_DEFAULT)

	return ent
end

function PVPRewardScene:onDestroy()
	if self.showEnt ~= nil then
		ClientUtils.safeDestroy(self.showEnt)
	end

	self.showEnt = nil

	pg.game.camera:closePVPRewardCamera()
end

return PVPRewardScene
