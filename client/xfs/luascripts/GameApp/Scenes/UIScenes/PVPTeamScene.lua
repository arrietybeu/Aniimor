-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\PVPTeamScene.lua

local ClientUtils = require("Utils.ClientUtils")
local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local PVPTeamScene = Class.LightClass("PVPTeamScene", UISceneBase)
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local FixedCameraMode = require("GameApp.Camera.CameraMode.FixedCameraMode")
local CameraConst = require("GameApp.Camera.CameraConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientVirtualEntityUtils = require("Utils.ClientVirtualEntityUtils")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local ClientConst = require("Const.ClientConst")
local AddressDataConst = require("Const.AddressDataConst")

function PVPTeamScene:onCtor()
	self.instArray = {}
end

function PVPTeamScene:onStart()
	local baseScene = self.addIns[AddressDataConst.PVP_FB_STAGE]
	local oc = baseScene:GetComponent("ObjectReference")

	self.camera = oc:GetRefValue("cameraBase")
	self.menuCameraParam = {
		pos = self.camera.transform.position,
		rot = self.camera.transform.rotation,
		fov = self.camera.fieldOfView
	}
	self.menuCamera = FixedCameraMode.new()

	self.menuCamera:setCameraName(CameraConst.CAMERA_NAME_FIXED)
	self.menuCamera:setActive(true)
	pg.game.camera:addUICamera(self.menuCamera, CameraConst.PRIORITY_FIXED)

	self.teamCamera = FixedCameraMode.new()

	self.teamCamera:setCameraName(CameraConst.CAMERA_NAME_PVP_LOADING)
	self.teamCamera:setActive(false)
	pg.game.camera:addUICamera(self.teamCamera, CameraConst.PRIORITY_PVP_LOADING)
	pg.game.camera:setUIGroupActive(true)

	self.stageOC = self.scene.transform:GetComponent("ObjectReference")
	self.sMFenceblue = self.stageOC:GetRefValue("sMFenceblue")
	self.sMFencered = self.stageOC:GetRefValue("sMFencered")
	self.btnEditTeam = self.stageOC:GetRefValue("btnEditTeam")
	self.teamNum = self.stageOC:GetRefValue("teamNum")
	self.timeCount = self.stageOC:GetRefValue("timeCount")
	self.timeCount2 = self.stageOC:GetRefValue("timeCount2")
	self.baseContainer = self.stageOC:GetRefValue("baseContainer")
	self.addCamera = self.stageOC:GetRefValue("camera")
	self.teamCameraParam = {
		pos = self.addCamera.transform.position,
		rot = self.addCamera.transform.rotation,
		fov = self.addCamera.fieldOfView
	}, self.addCamera.gameObject:SetActiveEx(false)
	self.uiPosArray = {}

	for i = 1, 6 do
		local index = i
		local btn = self.stageOC:GetRefValue("uIPos" .. index)

		btn:TryChangePage("State", 1)

		function btn.luaClick()
			self:onSetPreselection(index)
		end

		self.uiPosArray[index] = btn
	end

	self.modelPosArray = {}

	for i = 1, 6 do
		self.modelPosArray[i] = self.stageOC:GetRefValue("pos" .. i)
	end

	function self.btnEditTeam.luaClick()
		self:onSetPreselection()
	end
end

function PVPTeamScene:onInitCamera()
	self.camera.gameObject:SetActiveEx(true)
	pg.global.cameraMgr:SetUISceneCamera(self.camera)
	pg.game.camera:setUICameraObject(self.camera)
end

function PVPTeamScene:refreshPetTeam()
	local pets = pg.global.ui.pvpMenu.model:getSelectedPetList()
	local maxNum = #pets
	local ownNum = 0

	for _, v in pairs(self.instArray) do
		ClientUtils.safeDestroy(v)
	end

	table.clear(self.instArray)

	for i, v in ipairs(pets) do
		local ent

		if not v.empty then
			ent = ClientVirtualEntityUtils.createPetVirtualEntityWithDic(v.templateId, v.appearanceData, v.label)

			if ent then
				PetTransmogUtils.applyAppliedTransmog(ent, v.petId)
				ent:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)
				ent.eModel:SetTransformParent(self.modelPosArray[i], false)

				self.instArray[i] = ent
			end
		end

		if ent ~= nil then
			ownNum = ownNum + 1

			self.uiPosArray[i]:TryChangePage("State", 0)
			self:refreshPetUI(i, v)
		else
			self.uiPosArray[i]:TryChangePage("State", 1)
		end
	end

	ClientTextUtils.setText(self.teamNum, string.format(ownNum < maxNum and "<color=#A64141>%d</color>/%d" or "%d/%d", ownNum, maxNum))
end

function PVPTeamScene:refreshPetUI(pos, data)
	local item = self.uiPosArray[pos]
	local oc = item:GetComponent("ObjectReference")
	local pName = oc:GetRefValue("petNameBar")

	oc = pName:GetComponent("ObjectReference")

	local iName = oc:GetRefValue("name")
	local iNameV = oc:GetRefValue("nameV")
	local iElementList = oc:GetRefValue("elementList")

	ClientTextUtils.setText(iName, data.name)
	ClientTextUtils.setText(iNameV, data.name)

	function iElementList.luaRenderItem(sBtn, _, sd)
		LuaUIUtils.setElementButtonNew(sBtn, sd.element)
	end

	iElementList:SetList(data.elements)

	if data.isShiny then
		pName:TryChangePage("isFlash", 1)
	else
		pName:TryChangePage("isFlash", 0)
	end

	if data.isBoss then
		pName:TryChangePage("isBoss", 1)
	else
		pName:TryChangePage("isBoss", 0)
	end

	if data.isVariant then
		pName:TryChangePage("isChange", 1)
	else
		pName:TryChangePage("isChange", 0)
	end
end

function PVPTeamScene:focus(mode)
	local camera = self.menuCamera
	local cameraData = self.menuCameraParam
	local obj = self.addIns[AddressDataConst.PVP_MAIN_PET_NAME]

	if mode == 1 then
		camera = self.teamCamera
		cameraData = self.teamCameraParam

		if NotNil(obj) then
			obj:SetActiveEx(true)
		end

		self:refreshPetTeam()
	else
		camera = self.menuCamera
		cameraData = self.menuCameraParam

		if NotNil(obj) then
			obj:SetActiveEx(false)
		end
	end

	camera:setFov(cameraData.fov)
	camera:setRotation(cameraData.rot)
	camera:setPosition(cameraData.pos)
	self.teamCamera:setActive(mode == 1)
	self.menuCamera:setActive(mode == 0)
end

function PVPTeamScene:disFocus()
	pg.game.camera:closeFixedCamera()
end

function PVPTeamScene:tickRemandTime(timeStr)
	ClientTextUtils.setText(self.timeCount, timeStr)
	ClientTextUtils.setText(self.timeCount2, timeStr)
end

function PVPTeamScene:switchState(match)
	LuaUIUtils.setUIVisible(self.timeCount, match)
	LuaUIUtils.setUIVisible(self.timeCount2, match)
	LuaUIUtils.setUIVisible(self.baseContainer, not match)
end

function PVPTeamScene:onSetPreselection(pos)
	if pg.me:isMatchStatusInMatch() then
		return
	end

	local templateId = pos and self.instArray[pos] and self.instArray[pos].templateId or 0

	self:openEditPanel(templateId)
end

function PVPTeamScene:openEditPanel(templateId)
	pg.global.ui:open(UIConst.UI_ID_PVP_PET_SET, {
		cb = function()
			if not pg.global.ui:checkUIOpen(UIConst.UI_ID_PVP_MENU) then
				return
			end

			self:focus(1)
		end,
		pId = templateId
	})
end

function PVPTeamScene:onDestroy()
	if self.instArray then
		for _, v in pairs(self.instArray) do
			ClientUtils.safeDestroy(v)
		end
	end

	self.instArray = nil

	pg.global.cameraMgr:SetUISceneCamera(nil)
	pg.game.camera:setUICameraObject(nil)
	pg.game.camera:removeUICamera(self.menuCamera)
	pg.game.camera:removeUICamera(self.teamCamera)
	pg.game.camera:setUIGroupActive(false)

	self.menuCamera = nil
	self.teamCamera = nil
end

return PVPTeamScene
