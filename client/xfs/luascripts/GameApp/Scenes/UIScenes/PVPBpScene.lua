-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\PVPBpScene.lua

local ClientUtils = require("Utils.ClientUtils")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ClientConst = require("Const.ClientConst")
local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local PVPBpScene = Class.LightClass("PVPBpScene", UISceneBase)
local ClientSimpleVirtualEntity = require("Entities.ClientSimpleVirtualEntity")
local PetData = require("Data.pet_data")
local PvpModeData = require("Data.pvp_mode_data")
local Time = require("Core.Common.Time")
local FixedCameraMode = require("GameApp.Camera.CameraMode.FixedCameraMode")
local CameraConst = require("GameApp.Camera.CameraConst")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PVP_STATE = {
	NONE = 0,
	FINISHED = 3,
	LOADING = 2,
	BP = 1
}

function PVPBpScene:onCtor()
	self.mSelfModels = {}
	self.rivalModels = {}
	self.mSelfPos = {}
	self.rivalPos = {}
	self.enable = true
	self.state = PVP_STATE.NONE
end

function PVPBpScene:onStart()
	local AddressDataConst = require("Const.AddressDataConst")
	local bpScene = self.addIns[AddressDataConst.PVP_FB_STAGE]

	if NotNil(bpScene) then
		local oc = bpScene.transform:GetComponent("ObjectReference")
		local baseCamera = oc:GetRefValue("cameraBase")

		baseCamera.gameObject:SetActiveEx(false)
	end

	self.state = PVP_STATE.BP
	self.stageOC = self.scene.transform:GetComponent("ObjectReference")
	self.sMFenceblue = self.stageOC:GetRefValue("sMFenceblue")
	self.sMFencered = self.stageOC:GetRefValue("sMFencered")
	self.uIPbAnim = self.stageOC:GetRefValue("uIPbAnim")
	self.slider = self.stageOC:GetRefValue("slider")
	self.numProgress = self.stageOC:GetRefValue("numProgress")
	self.numProgressBG = self.stageOC:GetRefValue("numProgressBG")
	self.readyAnim = self.stageOC:GetRefValue("readyAnim")

	local camera = self.stageOC:GetRefValue("camera")

	camera.gameObject:SetActiveEx(true)
	pg.global.cameraMgr:SetUISceneCamera(camera)
	pg.game.camera:setUICameraObject(camera)

	self.pvpCamera = FixedCameraMode.new()

	self.pvpCamera:setCameraName(CameraConst.CAMERA_NAME_PVP_LOADING)
	self.pvpCamera:setActive(true)
	pg.game.camera:addUICamera(self.pvpCamera, CameraConst.PRIORITY_PVP_LOADING)
	pg.game.camera:setUIGroupActive(true)
	self.pvpCamera:setFov(camera.fieldOfView)
	self.pvpCamera:setPosition(camera.transform.position)
	self.pvpCamera:setRotation(camera.transform.rotation)

	self.slider.maxValue = 1
	self.slider.minValue = 0
	self.modelPosArray = {}

	for i = 1, 4 do
		self.mSelfPos[i] = self.stageOC:GetRefValue("pos" .. i)
		self.rivalPos[i] = self.stageOC:GetRefValue("pos" .. i + 4):GetComponent("Transform")
	end
end

function PVPBpScene:showModel(isEnemy, pos, data)
	if isEnemy then
		self:showRivalPetModel(pos, data.fake, data)
	else
		self:showMSelfPetModel(pos, data)
	end
end

function PVPBpScene:showMSelfPetModel(pos, data)
	if self.mSelfModels[pos] then
		ClientUtils.safeDestroy(self.mSelfModels[pos])

		self.mSelfModels[pos] = nil
	end

	local parent = self.mSelfPos[pos]
	local ent = self:initModel(data.templateId, data.label, data.gender)

	if ent == nil then
		return
	end

	self.mSelfModels[pos] = ent

	ent.eModel:SetTransformParent(parent, false)
	ent.eModel:SetActive(true)
	ent.eModel:SetTransformLocalPosition()
end

function PVPBpScene:showRivalPetModel(pos, fake, data)
	if self.rivalModels[pos] then
		ClientUtils.safeDestroy(self.rivalModels[pos])

		self.rivalModels[pos] = nil
	end

	local parent = self.rivalPos[pos]
	local ent

	if fake then
		ent = self:initFakeModel(pos)
	else
		ent = self:initModel(data.templateId, data.label, data.gender)
	end

	if ent == nil then
		return
	end

	self.rivalModels[pos] = ent

	ent.eModel:SetTransformParent(parent, false)
	ent.eModel:SetActive(true)
	ent.eModel:SetTransformLocalPosition()
end

function PVPBpScene:hideModel(isEnemy, pos)
	if isEnemy then
		ClientUtils.safeDestroy(self.rivalModels[pos])

		self.rivalModels[pos] = nil
	else
		ClientUtils.safeDestroy(self.mSelfModels[pos])

		self.mSelfModels[pos] = nil
	end
end

function PVPBpScene:getReady()
	self.uIPbAnim:Play("VX_Pb_PVP_Choose_Ground")
	self.readyAnim:Play("VX_Pb_PVP_Choose_Ground_Rotation")

	self.waitLoadMode = {}
end

function PVPBpScene:showLoadingPets(infos, isEnemy)
	if not pg.game.pvp:isFairMode() then
		for i, v in ipairs(infos.pvpSelectPets) do
			if v ~= "" then
				local addData = infos.isDefaultTeam and infos.defaulteCpValueMap[v] or infos.additionData[v]
				local templateId = infos.pvpTemplateIds[i] or 0
				local model = {
					pos = i,
					templateId = templateId,
					label = addData and addData.label,
					gender = addData and addData.gender,
					isEnemy = isEnemy
				}

				table.insert(self.waitLoadMode, model)
			end
		end
	else
		for i, v in ipairs(infos.pvpSelectPets) do
			if v ~= 0 then
				local model = {
					pos = i,
					templateId = v,
					isEnemy = isEnemy
				}

				table.insert(self.waitLoadMode, model)
			end
		end
	end
end

function PVPBpScene:tick()
	if self.waitLoadMode and #self.waitLoadMode > 0 then
		local model = self.waitLoadMode[#self.waitLoadMode]

		table.remove(self.waitLoadMode, #self.waitLoadMode)

		model.fake = false

		self:showModel(model.isEnemy, model.pos, model)
	end

	if self.state ~= PVP_STATE.LOADING then
		return
	end

	self:tickRemandTime()
end

function PVPBpScene:tickRemandTime()
	local sProgress = pg.global.scene:getLoadingProgress()
	local iProgress = (Time.realSecondCache - self.startTime) / (self.endTime - self.startTime)
	local progress = math.min(sProgress, iProgress)

	progress = math.max(self.slider.value, progress)

	self.slider:ProgressToValue(progress, nil, 0.1)

	local interProgress = math.round(progress * 100)

	if interProgress > 100 then
		interProgress = 100
	end

	ClientTextUtils.setText(self.numProgress, string.format("%d%%", interProgress))
	ClientTextUtils.setText(self.numProgressBG, string.format("%d%%", interProgress))

	if pg.global.scene:isSceneValid() and interProgress > 99 then
		self.slider:ProgressToValue(1, nil, 0.1)
		self:endLoading()
	end
end

function PVPBpScene:initModel(tId, label, gender)
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

	return ent
end

function PVPBpScene:initFakeModel(pos)
	local ent = ClientSimpleVirtualEntity.new()
	local initInfo = {}

	ent:init(initInfo)
	ent:postInit(initInfo)
	ent:start()
	ent:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)

	local modelView = ent.eModel.modelModelView

	modelView.modelInfo.physiqueModelInfo.modelPathID = "$P_Parmon_10000.prefab"

	modelView:RefreshModels()

	return ent
end

function PVPBpScene:startLoading(matchInfos)
	local cData = PvpModeData[1] or {}

	self.endTime = Time.realSecondCache + (cData.showTime or 0)
	self.startTime = Time.realSecondCache
	self.state = PVP_STATE.LOADING

	for uid, infos in pairs(matchInfos) do
		self:showLoadingPets(infos, uid ~= pg.me.uid)
	end

	self.slider.value = 0
	self.timer = self:startTimer(function()
		self:tick()
	end, 0.1, true)
end

function PVPBpScene:endLoading()
	pg.game.loading:onProgressFinished()

	self.state = PVP_STATE.FINISHED

	if self.timer then
		self:killTimer(self.timer)
	end

	self.timer = nil
end

function PVPBpScene:onDestroy()
	if self.mSelfModels then
		for _, v in pairs(self.mSelfModels) do
			ClientUtils.safeDestroy(v)
		end
	end

	self.mSelfModels = nil

	if self.rivalModels then
		for _, v in pairs(self.rivalModels) do
			ClientUtils.safeDestroy(v)
		end
	end

	self.rivalModels = nil

	pg.game.camera:setUIGroupActive(false)
	pg.game.camera:destroyAllUICamera()
end

return PVPBpScene
