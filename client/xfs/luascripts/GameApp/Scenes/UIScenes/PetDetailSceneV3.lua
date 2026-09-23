-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\PetDetailSceneV3.lua

local ClientUtils = require("Utils.ClientUtils")
local EMPTY_TABLE = require("Core.Common.EmptyTable")
local CommonConst = require("Common.Const.Const")
local PetProtoTypeData = require("Data.pet_prototype_data")
local AudioConst = require("Const.AudioConst")
local DoTweenAnimMgr = DoTweenAnimMgr
local HandbookModelView = HandbookModelView
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local Utils = require("Common.Utils.Utils")
local PetBasePrototypeToPrototypeMap = require("Data.pet_base_prototype_to_prototype_map")
local PetConfigData = require("Data.pet_config_data")
local Const = require("Common.Const.Const")
local PetEvolveData = require("Data.pet_evolve_data")
local PetEvolveCameraPosData = require("Data.pet_evolve_camera_pos_data")
local PetPrototypeData = require("Data.pet_prototype_data")
local PetResearchUtilsCommon = require("Common.Utils.PetResearchUtils")
local AddressDataConst = require("Const.AddressDataConst")
local PetEthnicData = require("Data.pet_ethnic_group_data")
local SysConfigData = require("Data.sys_config_data")
local ClientModelUtils = require("Utils.ClientModelUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientSimpleVirtualEntity = require("Entities.ClientSimpleVirtualEntity")
local ClientVirtualEntityUtils = require("Utils.ClientVirtualEntityUtils")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local PlayableConst = require("Common.Const.PlayableConst")
local TimerManager = require("Core.Timer.TimerManager")
local ResLoader = require("GameApp.ResLoad.ResLoader")
local ClientAbilityConst = require("Const.ClientAbilityConst")
local CustomEnData = require("Data.I18N.custom_en_data")
local PetDetailSceneV3 = Class.LightClass("PetDetailSceneV3", UISceneBase)
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local ID_MAIN_PET_SCALE = "mainPetScale"
local ID_MAIN_PET_ROTATION = "mainPetRotation"
local ID_MAIN_PET_POS = "mainPetPos"
local ID_ROUND_PET = "roundPet"
local ID_SURVEY_PET_ROTATION = "surveyPetRotation"
local ID_ENT_TO_ZERO = "entToZero"
local PAGE_ID = UIConst.HANDBOOK_PAGE_IDX
local EVOLUTION_REFERENCE_ASPECT = 1.7777777777777777
local EVOLUTION_MAX_ASPECT_DISTANCE_SCALE = 1.5
local PetDetailAmb = {
	AmbBeach = "AMB_UI_PetManualExplore_Beach",
	AmbGrass = "AMB_UI_PetManualExplore_Grassland"
}
local UI_SELECT_MODEL = AddressDataConst.UI_SELECT_MODEL
local UI_SELECT_MODEL_2 = AddressDataConst.UI_SELECT_MODEL_2
local SCENE_ID = {
	Water = 1,
	Grass = 2
}

function PetDetailSceneV3:getSimpleEnt(templateId)
	local configData = ClientVirtualEntityUtils.getPetUISceneConfig(templateId)
	local ent = ClientSimpleVirtualEntity.new()

	ent:setConfigData(configData)

	local initInfo = {
		isIgnoreEffectLod = true,
		templateId = templateId
	}

	ent:init(initInfo)
	ent:postInit(initInfo)
	ent:start()
	ent:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)

	return ent
end

function PetDetailSceneV3:refreshEntityRenderState(ent, visible)
	if not ent then
		return
	end

	ent:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)
	ent:setModelVisible(ClientConst.MODEL_VISIBLE_KEY.UIScene, visible)

	local shaderView = ent.eModel and ent.eModel.modelShaderView

	if shaderView then
		shaderView:SetMultiPassForce32Layer(true, ClientAbilityConst.MULTI_PASS_LAYER)
	end
end

function PetDetailSceneV3:onStart()
	self.Blue_Line_Color = Color(0.1921569, 0.6588235, 0.8784314, 1)
	self.Blue_Line_Gray_Color = Color(0.2156863, 0.345098, 0.5176471, 0.7)
	self.Pink_Line_Color = Color(0.9960784, 0.3254902, 0.6862745, 1)
	self.Pink_Line_Gray_Color = Color(0.4980392, 0.2117647, 0.3647059, 0.7)
	self.objectReference = self.scene.transform:Find("Global"):GetComponent("ObjectReference")
	self.petRootTransform = self.objectReference:GetRefValue("petRootTransform")
	self.uiSceneCamera = self.objectReference:GetRefValue("uiSceneCamera")
	self.abilityVCameraTransform = self.objectReference:GetRefValue("abilityVCameraTransform")
	self.surveyCameraTransform = self.objectReference:GetRefValue("surveyCameraTransform")
	self.abilityPlane = self.objectReference:GetRefValue("abilityPlane")
	self.artAssetTransform = self.objectReference:GetRefValue("artAssetTransform")
	self.artAssetGrassTransform = self.objectReference:GetRefValue("artAssetGrassTransform")
	self.lookAtTargetTransform = self.objectReference:GetRefValue("lookAtTargetTransform")
	self.evolutionCameraTransform = self.objectReference:GetRefValue("evolutionCameraTransform")
	self.photoCameraTransform = self.objectReference:GetRefValue("photoCameraTransform")
	self.formCameraTransform = self.objectReference:GetRefValue("formCameraTransform")
	self.topicPageCameraTransform = self.objectReference:GetRefValue("topicPageCameraTransform")
	self.surveyFormCameraTransform = self.objectReference:GetRefValue("surveyFormCameraTransform")
	self.lightTimelineCtrl = self.objectReference:GetRefValue("lightTimelineCtrl")
	self.lightAssetCtrl = self.objectReference:GetRefValue("lightAssetCtrl")
	self.lightTransform = self.objectReference:GetRefValue("lightTransform")
	self.abilityLight = self.objectReference:GetRefValue("abilityLight")
	self.topicPageTransform = self.objectReference:GetRefValue("topicPageTransform")
	self.evolutionTransform = self.objectReference:GetRefValue("evolutionTransform")
	self.notHidingTransform = self.objectReference:GetRefValue("notHidingTransform")
	self.pos01 = self.objectReference:GetRefValue("pos01Transform")
	self.pos02 = self.objectReference:GetRefValue("pos02Transform")
	self.pos12 = self.objectReference:GetRefValue("pos12Transform")
	self.pos03 = self.objectReference:GetRefValue("pos03Transform")
	self.pos13 = self.objectReference:GetRefValue("pos13Transform")
	self.pos23 = self.objectReference:GetRefValue("pos23Transform")
	self.evolutionPos = self.objectReference:GetRefValue("EvolutionPos")
	self.photoTransform = self.objectReference:GetRefValue("photoTransform")
	self.entPoolTransform = self.objectReference:GetRefValue("entPoolTransform")
	self.effUIResearchVolumeJinhuaTransform = self.objectReference:GetRefValue("effUIResearchVolumeJinhuaTransform")
	self.posTable = {
		["01"] = self.pos01,
		["02"] = self.pos02,
		["12"] = self.pos12,
		["13"] = self.pos13,
		["03"] = self.pos03,
		["23"] = self.pos23
	}
	self.entPoolTable = {}
	self.evolutionShowEntIds = {}
	self.aniTimerDict = {}

	pg.global.cameraMgr:SetUISceneCamera(self.uiSceneCamera)
	pg.game.camera:setUICameraObject(self.uiSceneCamera)

	self.posY = 500
	self.centerPos = Vector3(0, self.posY, 0)
	self.scene.transform.position = self.centerPos
	self.evolutionPosOrigin = self.evolutionCameraTransform.position

	self:initTempScene()
	self:clearUpdateTimer()

	self.updateTimer = TimerManager.addRepeatTimer(0.1, function()
		self:updateEvolutionCameraAspect()
		self:updateCameraPosInSurveyPage()
	end)

	self:initVirtualCameraGroup()

	self.originPointKey = "originPoint"
	self.resLoadInst = {}

	local isBranchSelect = self.params and self.params.isBranchSelect

	if isBranchSelect then
		self:generalPetEvolutionBranchGraph(self.params.petId)
	end
end

function PetDetailSceneV3:initTempScene()
	self.sceneTable = {}
	self.abilityModelView = HandbookModelView()

	self.abilityModelView:SetHandbookModel(self.abilityPlane.gameObject)

	self.sandView = HandbookModelView()

	self.sandView:SetHandbookModel(self.artAssetTransform.gameObject)

	self.grassView = HandbookModelView()

	self.grassView:SetHandbookModel(self.artAssetGrassTransform.gameObject)

	self.evolutionView = HandbookModelView()

	self.evolutionView:SetHandbookModel(self.evolutionTransform.gameObject)

	self.topicView = HandbookModelView()

	self.topicView:SetHandbookModel(self.topicPageTransform.gameObject)

	self.albumView = HandbookModelView()

	self.albumView:SetHandbookModel(self.photoTransform.gameObject)

	self.sceneTable[PAGE_ID.SURVEY] = {
		[SCENE_ID.Water] = self.sandView,
		[SCENE_ID.Grass] = self.grassView
	}
	self.sceneTable[PAGE_ID.SURVEY_FORM] = {
		[SCENE_ID.Water] = self.sandView,
		[SCENE_ID.Grass] = self.grassView
	}
	self.sceneTable[PAGE_ID.ABILITY] = {
		[SCENE_ID.Water] = self.abilityModelView,
		[SCENE_ID.Grass] = self.abilityModelView
	}
	self.sceneTable[PAGE_ID.TOPIC] = {
		[SCENE_ID.Water] = self.topicView,
		[SCENE_ID.Grass] = self.topicView
	}
	self.sceneTable[PAGE_ID.EVOLUTION] = {
		[SCENE_ID.Water] = self.evolutionView,
		[SCENE_ID.Grass] = self.evolutionView
	}
	self.sceneTable[PAGE_ID.ALBUM] = {
		[SCENE_ID.Water] = self.albumView,
		[SCENE_ID.Grass] = self.albumView
	}
	self.sceneTable[PAGE_ID.FORM] = {
		[SCENE_ID.Water] = self.abilityModelView,
		[SCENE_ID.Grass] = self.abilityModelView
	}
end

function PetDetailSceneV3:initVirtualCameraGroup()
	self.cameraGoDict = {}
	self.cameraPosDict = {}

	local pageCameraTrans = {
		[PAGE_ID.SURVEY] = self.surveyCameraTransform,
		[PAGE_ID.ABILITY] = self.abilityVCameraTransform,
		[PAGE_ID.INTERACT] = self.gestureInteractCameraTransform,
		[PAGE_ID.SURVEY_FORM] = self.surveyFormCameraTransform,
		[PAGE_ID.TOPIC] = self.topicPageCameraTransform,
		[PAGE_ID.EVOLUTION] = self.evolutionCameraTransform,
		[PAGE_ID.ALBUM] = self.photoCameraTransform,
		[PAGE_ID.FORM] = self.formCameraTransform
	}
	local cameraNames = {
		"VCameraNear",
		"VCameraMid",
		"VCameraFar"
	}

	for pid, trans in pairs(pageCameraTrans) do
		if pid == PAGE_ID.SURVEY or pid == PAGE_ID.SURVEY_FORM then
			for cIdx, name in ipairs(cameraNames) do
				local vcId = self:getVCameraId(pid, cIdx)
				local vc = trans:Find(name):GetComponent("RefVirtualCameraBehavior")

				self.cameraGoDict[vcId] = vc.gameObject

				function vc.luaFinishBlend()
					self:cameraBlendFinishCb()
				end

				self.cameraGoDict[vcId]:SetActiveEx(false)

				self.cameraPosDict[vcId] = vc.transform.localPosition
			end
		else
			local vcId = self:getVCameraId(pid)
			local vc = trans:Find(cameraNames[1]):GetComponent("RefVirtualCameraBehavior")

			self.cameraGoDict[vcId] = vc.gameObject

			function vc.luaFinishBlend()
				self:cameraBlendFinishCb()
			end

			self.cameraGoDict[vcId]:SetActiveEx(false)

			self.cameraPosDict[vcId] = vc.transform.localPosition

			if pid == PAGE_ID.EVOLUTION then
				self.evolutionCameraBaseLocalPosition = vc.transform.localPosition
			end
		end
	end

	self.evolutionLightGoDict = {}

	for id, trans in pairs(self.posTable) do
		local vc = trans:Find("Camera")

		vc.gameObject:SetActiveEx(false)

		self.evolutionLightGoDict[id] = trans:Find("Light").gameObject

		self.evolutionLightGoDict[id]:SetActiveEx(false)
	end
end

function PetDetailSceneV3:getPetTargetScale(templateId, pageId)
	if pageId == PAGE_ID.SURVEY or pageId == PAGE_ID.SURVEY_FORM then
		return 1
	elseif pageId == PAGE_ID.EVOLUTION then
		local petPrototypeId = templateId
		local stage = Utils.getPetPrototypeStage(petPrototypeId)
		local petData = PetProtoTypeData[templateId]

		if not PetEvolveData[templateId] then
			templateId = Utils.getBasePetPrototypeId(templateId)
		end

		local evolveData = PetEvolveData[templateId][1]

		if evolveData.individual then
			local positionId = evolveData.position
			local posScale = PetConfigData["PetScaleInEvo_" .. stage]

			return posScale and posScale[positionId] or 1
		end

		local groupId = PetEvolveData[templateId][1].groupId
		local ethnicTemplateIds = PetEthnicData[petData.ethnicGroup][groupId] or {}
		local curPosInfo = ethnicTemplateIds[templateId]
		local positionId = curPosInfo.position
		local posScale = PetConfigData["PetScaleInEvo_" .. stage]

		return posScale and posScale[positionId] or 1
	else
		local contentData = self:getResearchContentData(templateId)
		local scale = contentData.scale or 1

		return scale * PetConfigData.PetScaleInOtherPage
	end
end

function PetDetailSceneV3:getPetTargetRotationPosition(templateId, pageId)
	local contentData = self:getResearchContentData(templateId)
	local modelPos, modelRotation

	if pageId == PAGE_ID.EVOLUTION then
		modelRotation = contentData.modelRotation

		local rotation = self:getPetTargetEvolutionRotation(templateId, self.cameraGoDict[PAGE_ID.EVOLUTION].transform.position)
		local modelPosCfg = contentData.modelPos

		modelPos = modelPosCfg and Vector3(modelPosCfg[1], modelPosCfg[2], modelPosCfg[3]) or Vector3.zero
		modelRotation = modelRotation and Vector3(modelRotation[1], modelRotation[2], modelRotation[3]) or Vector3.zero

		return Quaternion.ToEulerAngles(rotation) + modelRotation, modelPos
	elseif pageId == PAGE_ID.SURVEY then
		modelRotation = contentData.modelRotation

		local modelPosCfg = contentData.modelPos

		modelPos = modelPosCfg and Vector3(modelPosCfg[1], modelPosCfg[2], modelPosCfg[3]) or Vector3.zero

		return modelRotation and Vector3(modelRotation[1], modelRotation[2], modelRotation[3]) or Vector3.zero, modelPos
	else
		modelRotation = contentData.modelRotationOther

		local modelPosCfg = contentData.modelPosOther

		modelPos = modelPosCfg and Vector3(modelPosCfg[1], modelPosCfg[2], modelPosCfg[3]) or Vector3.zero

		return modelRotation and Vector3(modelRotation[1], modelRotation[2], modelRotation[3]) or Vector3.zero, modelPos
	end
end

function PetDetailSceneV3:cameraBlendFinishCb()
	if self.pageCb then
		self.pageCb()
	end
end

function PetDetailSceneV3:evolutionCameraBlendFinishCb()
	self.cameraGoDict[self.curPageViewId]:SetActiveEx(true)
end

function PetDetailSceneV3:trySwitchView(pageId, cb)
	self.pageCb = cb

	self:TweenPetScale(pageId)
	self:TweenPetRotation(pageId)
	self:TweenSceneFade(pageId)
	self:TweenCameraFade()

	local viewId = self:getVCameraId(pageId, self.cameraModeId)

	if self.curPageViewId == viewId then
		if cb then
			cb()
		end

		self.pageCb = nil

		return
	end

	self.curPageViewId = viewId

	self:switchCamera(self.curPageViewId)
	self:tryChangeLight(pageId, self.cameraModeId, SCENE_ID.Water)
end

function PetDetailSceneV3:TweenPetScale(pageId)
	if self.pageId ~= pageId and self.mainEnt then
		local targetScale = self:getPetTargetScale(self.curShowPetTemplateId, pageId)

		if targetScale ~= self.mainPetScale then
			DoTweenAnimMgr.Scale(self.mainEnt.actorId, LuaUIUtils.TweenId(ID_MAIN_PET_SCALE), Vector3.one * targetScale, SysConfigData.PetManualScaleSwitchDuration or 0.2, 0, CS.DG.Tweening.Ease.__CastFrom(6), function()
				return
			end)

			self.mainPetScale = targetScale
		end
	end
end

function PetDetailSceneV3:TweenPetRotation(pageId)
	if self.pageId ~= pageId and self.mainEnt then
		local targetRotation, targetPos = self:getPetTargetRotationPosition(self.curShowPetTemplateId, pageId)

		if targetRotation ~= self.mainEntRotation then
			DoTweenAnimMgr.Rotate(self.mainEnt.actorId, LuaUIUtils.TweenId(ID_MAIN_PET_ROTATION), targetRotation, SysConfigData.PetManualScaleSwitchDuration or 0.2, 0, CS.DG.Tweening.Ease.__CastFrom(6), function()
				return
			end)

			self.mainEntRotation = targetRotation
		end

		if targetPos ~= self.mainEntPos then
			DoTweenAnimMgr.Move(self.mainEnt.actorId, LuaUIUtils.TweenId(ID_MAIN_PET_POS), targetPos, SysConfigData.PetManualScaleSwitchDuration or 0.2, 0, CS.DG.Tweening.Ease.__CastFrom(6), function()
				return
			end)

			self.mainEntPos = targetPos
		end
	end
end

function PetDetailSceneV3:refreshEvolutionGraph()
	self:updateEvolutionCameraAspect()

	local petData = PetProtoTypeData[self.curShowPetTemplateId]
	local evolveData = PetEvolveData[self.curShowPetTemplateId] and PetEvolveData[self.curShowPetTemplateId][1]

	if evolveData then
		if evolveData.individual then
			self:recycleEvolution()
			self:generalEvolutionGraphIndividual()
		else
			local groupId = evolveData.groupId

			if petData.ethnicGroup ~= self.curEthicGroup or self.groupId ~= groupId then
				self:recycleEvolution()
				self:generalEvolutionGraph()
			else
				self:changeEvolutionPos()
			end

			self.curEthicGroup = petData.ethnicGroup
		end

		local cameraPosInfo = PetEvolveCameraPosData[petData.ethnicGroup] or {}
		local offsetPos = cameraPosInfo.cameraPosition or Vector3.zero
		local offsetRotation = cameraPosInfo.cameraRotation or Vector3.zero

		self:adjustEvolvePos(self.curShowPetTemplateId, offsetPos, offsetRotation)
	end
end

function PetDetailSceneV3:updateEvolutionCameraAspect()
	if not self.evolutionCameraBaseLocalPosition then
		return
	end

	if not self.cameraGoDict then
		return
	end

	local cameraGo = self.cameraGoDict[PAGE_ID.EVOLUTION]

	if not cameraGo then
		return
	end

	local screenWidth = tonumber(CS.UnityEngine.Screen.width) or 0
	local screenHeight = tonumber(CS.UnityEngine.Screen.height) or 0

	if screenWidth <= 0 or screenHeight <= 0 then
		return
	end

	local aspect = screenWidth / screenHeight
	local distanceScale = EVOLUTION_REFERENCE_ASPECT / aspect

	if distanceScale < 1 then
		distanceScale = 1
	end

	if distanceScale > EVOLUTION_MAX_ASPECT_DISTANCE_SCALE then
		distanceScale = EVOLUTION_MAX_ASPECT_DISTANCE_SCALE
	end

	local basePosition = self.evolutionCameraBaseLocalPosition
	local targetZ = basePosition.z * distanceScale
	local currentPosition = cameraGo.transform.localPosition
	local isSameAspect = self.evolutionCameraAspect and math.abs(self.evolutionCameraAspect - aspect) < 0.001
	local isSamePosition = math.abs(currentPosition.z - targetZ) < 0.001

	if isSameAspect and isSamePosition then
		return
	end

	cameraGo.transform.localPosition = Vector3(basePosition.x, basePosition.y, targetZ)
	self.evolutionCameraAspect = aspect
end

function PetDetailSceneV3:changeEvolutionPos()
	self.evolutionShowEntIds = {}

	local petData = PetProtoTypeData[self.curShowPetTemplateId]
	local groupId = PetEvolveData[self.curShowPetTemplateId][1].groupId
	local ethnicTemplateIds = PetEthnicData[petData.ethnicGroup][groupId] or {}

	for petTemplateId, info in pairs(ethnicTemplateIds) do
		local stage = Utils.getPetPrototypeStage(petTemplateId)

		if petTemplateId ~= self.curShowPetTemplateId then
			local ent = self:getEntById(petTemplateId)

			self.evolutionShowEntIds[#self.evolutionShowEntIds + 1] = petTemplateId

			local branchName = self.evolveBranchDict[petTemplateId]

			if stage == 1 then
				ent.eModel:SetGameObjectName("evolveGraph_" .. petTemplateId .. "_" .. 0)
			elseif branchName then
				ent.eModel:SetGameObjectName(branchName)
			end

			local posTrans = self["pos" .. info.position .. stage]
			local eModel = ent.eModel

			eModel:SetTransformParent(posTrans, false)
			eModel:SetTransformLocalPosition()
		end
	end
end

function PetDetailSceneV3:generalEvolutionGraphIndividual(label)
	self.groupId = nil
	self.curEthicGroup = nil

	pg.global.uiMgr:HideEvolveGraphLine()
end

function PetDetailSceneV3:generalEvolutionGraph(label)
	local petData = PetProtoTypeData[self.curShowPetTemplateId]
	local groupId = PetEvolveData[self.curShowPetTemplateId][1].groupId

	self.groupId = groupId

	local ethnicTemplateIds = PetEthnicData[petData.ethnicGroup][groupId] or {}
	local routeInitDict = {}

	self.evolveBranchDict = {}

	pg.global.uiMgr:HideEvolveGraphLine()
	pg.global.uiMgr:ShowHandbookEvolvePoint(self.originPointKey, self.Blue_Line_Color, 0.1, self.centerPos, self.evolutionPos.transform)
	pg.global.uiMgr:PlayHandbookEvolveLineBloom("EvolutionLine02", self.originPointKey)

	local petHandbookMap = pg.me.petHandbookMap

	for petTemplateId, _ in pairs(ethnicTemplateIds) do
		local curStage = Utils.getPetPrototypeStage(petTemplateId)
		local curPosInfo = ethnicTemplateIds[petTemplateId]
		local graphData = PetEvolveData[petTemplateId] or {}

		for branchId, branchInfo in pairs(graphData) do
			local targetPetId = branchInfo.targetPetId

			if targetPetId then
				local isGot = petHandbookMap[targetPetId] and petHandbookMap[targetPetId]:isCatched()
				local targetInfo = ethnicTemplateIds[targetPetId]
				local targetStage = Utils.getPetPrototypeStage(targetPetId)
				local targetPos = self["pos" .. targetInfo.position .. targetStage].position
				local originPos = self["pos" .. curPosInfo.position .. curStage].position
				local key = targetInfo.position .. targetStage .. curPosInfo.position .. curStage
				local left = originPos.x < targetPos.x and true or false
				local degree = targetStage - curStage > 1 and 45 or 80
				local dashed = false

				if not isGot then
					dashed = true
				end

				local routeInitState = branchInfo.routeInitState
				local lineColor = branchInfo.isSpecial and self.Pink_Line_Color or self.Blue_Line_Color
				local needDraw = true

				if routeInitState then
					local handbookInfo = petHandbookMap:getInfo(petTemplateId)
					local conditionState

					if not handbookInfo then
						conditionState = PetResearchUtilsCommon.genEvolveResearchInfoInitDict(petTemplateId, branchId)
					else
						conditionState = handbookInfo:getEvolveResearchInfoWithDefault(branchId):getRawTable() or {}
					end

					routeInitDict[targetPetId] = conditionState.status

					if routeInitState == 0 then
						needDraw = conditionState.status ~= Const.PET_RESEARCH.STATUS_HIDE
					elseif routeInitState == 2 then
						dashed = false
					end
				end

				if needDraw then
					pg.global.uiMgr:ShowHandbookEvolveLine(key, lineColor, dashed, Vector2(originPos.x, originPos.z), Vector2(targetPos.x, targetPos.z), self.evolutionPos.transform, degree, self.posY, left)
					pg.global.uiMgr:PlayHandbookEvolveLineBloom("EvolutionLine02", key)

					self.evolveBranchDict[targetPetId] = "evolveGraph_" .. petTemplateId .. "_" .. branchId
				end
			end
		end
	end

	for petTemplateId, info in pairs(ethnicTemplateIds) do
		local stage = Utils.getPetPrototypeStage(petTemplateId)

		if petTemplateId ~= self.curShowPetTemplateId then
			local routeInit = routeInitDict[petTemplateId]
			local isGot = petHandbookMap[petTemplateId] and petHandbookMap[petTemplateId]:isCatched()
			local entVisible = true

			if routeInit and routeInit == 0 then
				entVisible = routeInit ~= Const.PET_RESEARCH.STATUS_HIDE
			end

			local branchName = self.evolveBranchDict[petTemplateId]
			local ent = self:getEvolveEnt(petTemplateId, stage, info.position, label or 0, entVisible, self.gender)
			local targetScale = self:getPetTargetScale(petTemplateId, PAGE_ID.EVOLUTION)
			local rotation, _ = self:getPetTargetRotationPosition(petTemplateId, PAGE_ID.EVOLUTION)

			ent.eModel:SetTransformRotationByEulerAngle(rotation[1], rotation[2], rotation[3])

			if stage == 1 then
				ent.eModel:SetGameObjectName("evolveGraph_" .. petTemplateId .. "_" .. 0)
			elseif branchName then
				ent.eModel:SetGameObjectName(branchName)
			end

			self:refreshEntScale(ent, targetScale)

			if not isGot and routeInit ~= 2 then
				self:showEntUnknown(ent)
			else
				self:disableEntUnknown(ent)
			end
		end
	end
end

function PetDetailSceneV3:getPetTargetEvolutionRotation(templateId, cameraPos)
	local posIdx = self:getEvolveEntPosId(templateId)

	if not posIdx then
		return
	end

	local evolutionTrans = self.posTable[posIdx]
	local pos = evolutionTrans.position
	local directionToTarget = cameraPos - pos

	directionToTarget[2] = 0

	local rotation = Quaternion.LookRotation(directionToTarget, Vector3.up)

	return rotation
end

function PetDetailSceneV3:adjustEvolvePos(templateId, offsetPos, offsetRotation)
	local targetPos = self:getEvolveEntPos(templateId)
	local dir = self.centerPos - targetPos

	self.evolutionPos.position = self.evolutionPos.position + dir
	self.evolutionTransform.position = self.evolutionTransform.position + dir

	if self.preOffset then
		self.evolutionCameraTransform.position = self.evolutionCameraTransform.position - self.preOffset + dir + offsetPos
	else
		self.evolutionCameraTransform.position = self.evolutionCameraTransform.position + dir + offsetPos
	end

	self.preOffset = offsetPos
	self.evolutionCameraTransform.localRotation = Quaternion.Euler(offsetRotation[1], offsetRotation[2], offsetRotation[3])

	self:hideAllEvolveLight()

	local posId = self:getEvolveEntPosId(templateId)

	if posId then
		self.evolutionLightGoDict[posId]:SetActiveEx(true)
	end
end

function PetDetailSceneV3:getEvolveEntPos(templateId)
	local posIdx = self:getEvolveEntPosId(templateId)

	if posIdx then
		return self.posTable[posIdx].position
	end

	return Vector3.zero
end

function PetDetailSceneV3:getEvolveEntTopWorldPos(templateId, pageId)
	if not templateId or not pageId then
		return Vector3.zero
	end

	local anchorPos = self:getEvolveEntPos(templateId)
	local targetScale = self:getPetTargetScale(templateId, pageId) or 1
	local protoData = PetProtoTypeData[templateId]
	local fallbackHeight = protoData and protoData.modelHeight or 0
	local topWorldPos = Vector3(anchorPos[1], anchorPos[2] + fallbackHeight * targetScale, anchorPos[3])

	return topWorldPos
end

function PetDetailSceneV3:getEvolveEntPosId(templateId)
	local petPrototypeId = templateId
	local stage = Utils.getPetPrototypeStage(petPrototypeId)
	local petData = PetProtoTypeData[templateId]

	if not petData then
		return
	end

	if not PetEvolveData[templateId] then
		templateId = Utils.getBasePetPrototypeId(templateId)
	end

	local evolveData = PetEvolveData[templateId][1]

	if evolveData.individual then
		return evolveData.position .. stage
	end

	local groupId = PetEvolveData[templateId][1].groupId
	local ethnicTemplateIds = PetEthnicData[petData.ethnicGroup][groupId]

	if not ethnicTemplateIds then
		return
	end

	local showInfo = ethnicTemplateIds[templateId]
	local posIdx = showInfo.position .. stage

	return posIdx
end

function PetDetailSceneV3:showUnknownEffectBranchSelect()
	if not self.petId then
		return
	end

	local petHandbookMap = pg.me.petHandbookMap
	local petInfo = pg.me:getPetInfo(self.petId)
	local evolveData = PetEvolveData[petInfo.templateId] or {}

	for branchId, branchInfo in pairs(evolveData) do
		local targetPetId = branchInfo.targetPetId
		local isGot = petHandbookMap[targetPetId] and petHandbookMap[targetPetId]:isCatched()

		if not petInfo:canEvolveBranch(branchId) and not isGot then
			self:showEntUnknown(self.evolutionPetDict[targetPetId])
		end
	end

	self.lightTransform.gameObject:SetActiveEx(false)
end

function PetDetailSceneV3:showEntUnknown(ent, cb)
	ent._petMatForceUnKnow = true

	local shaderView = ent.eModel.shaderView

	shaderView:SetOverrideMaterial(PetManagementDataHelper.getPetHandbookMat(), cb)
	shaderView:SetMultiPassRenderEnable(false)
end

function PetDetailSceneV3:disableEntUnknown(ent)
	if not ent._petMatForceUnKnow then
		return
	end

	ent._petMatForceUnKnow = nil

	local shaderView = ent.eModel.shaderView

	shaderView:SetOverrideMaterial("")
	shaderView:SetMultiPassRenderEnable(true)
end

function PetDetailSceneV3:setMainEntKnownState(isKnown)
	if self.mainEnt and self.mainEnt.eModel then
		if not isKnown then
			self:showEntUnknown(self.mainEnt)
		else
			self:disableEntUnknown(self.mainEnt)

			self.unlockMainEntTemplateId = nil
			self.unlockMainEntLabel = nil
			self.unlockMainEntShinyStyleId = nil
		end
	end
end

function PetDetailSceneV3:showMainPetFormUnKnown(templateId)
	if not self.unlockMainEntTemplateId then
		self.unlockMainEntTemplateId = self.curShowPetTemplateId
		self.unlockMainEntLabel = self.label
		self.unlockMainEntShinyStyleId = self.shinyStyleId
	end

	self:showPet(templateId, 0, true, 0)
	self:refreshEntScale(self.mainEnt, self.mainPetScale, self.mainEntRotation, self.mainEntPos)
	self:setMainEntKnownState(false)
end

function PetDetailSceneV3:restoreMainPetKnown()
	if self.unlockMainEntTemplateId then
		self:showPet(self.unlockMainEntTemplateId, self.unlockMainEntLabel, nil, self.unlockMainEntShinyStyleId)
	end

	self.unlockMainEntTemplateId = nil
	self.unlockMainEntLabel = nil
	self.unlockMainEntShinyStyleId = nil
end

function PetDetailSceneV3:setMainEntForm(formTemplateId, label, shinyStyleId)
	self:showPet(formTemplateId, label, nil, shinyStyleId)
	self:refreshEntScale(self.mainEnt, self.mainPetScale, self.mainEntRotation, self.mainEntPos)
end

function PetDetailSceneV3:recycleEvolution()
	local len = #self.evolutionShowEntIds

	for idx = 1, len do
		local templateId = self.evolutionShowEntIds[idx]

		self:recycleEnt(templateId)
	end

	self.evolutionShowEntIds = {}
end

function PetDetailSceneV3:getEvolveEnt(templateId, stage, positionId, label, visible, gender)
	local ent = self:getEntById(templateId)

	self:refreshPetModelAppearance(templateId, ent, label or 0, visible, gender)

	local posTrans = self["pos" .. positionId .. stage]

	ent.eModel:SetTransformParent(posTrans, false)
	ent.eModel:SetTransformLocalPosition()

	self.evolutionShowEntIds[#self.evolutionShowEntIds + 1] = templateId

	return ent
end

function PetDetailSceneV3:TweenSceneFade(pageId)
	local researchContentData = self:getResearchContentData(self.curShowPetTemplateId)
	local sceneId

	sceneId = not researchContentData and 1 or researchContentData.scene or 1

	self.abilityLight.gameObject:SetActiveEx(pageId == PAGE_ID.ABILITY)

	if not self.pageId then
		self.pageId = pageId
		self.sceneId = sceneId

		for pId, sceneModelViews in pairs(self.sceneTable) do
			for _, modelView in pairs(sceneModelViews) do
				modelView:SetSceneGameObjectActive(false)
			end
		end

		self.sceneTable[self.pageId][self.sceneId]:SetSceneGameObjectActive(true)
	elseif (self.pageId ~= pageId or self.pageId == PAGE_ID.SURVEY and self.sceneId ~= sceneId) and self.sceneTable[pageId] then
		local modelView = self.sceneTable[self.pageId][self.sceneId]

		if modelView then
			modelView:SetSceneGameObjectActive(false)
		end

		local targetModelView = self.sceneTable[pageId][sceneId]

		if targetModelView then
			targetModelView:SetSceneGameObjectActive(true)
		end

		self.pageId = pageId
		self.sceneId = sceneId
	end
end

function PetDetailSceneV3:TweenCameraFade()
	local cameraModeId = PetPrototypeData[self.curShowPetTemplateId].cameraDistModeId or 1

	if cameraModeId ~= self.cameraModeId then
		local modelView = self.sceneTable[self.pageId][self.sceneId]

		if modelView then
			modelView:PlayHandBookCameraViewFade("HBFade1", SysConfigData.PetManualSceneSwitchDuration or 0.5, self.centerPos, 2, 2)
		end

		self.cameraModeId = cameraModeId
	end
end

function PetDetailSceneV3:playPetPhaseAction(ent, cfg, cb)
	ent = ent or self.mainEnt

	if not ent then
		if cb then
			cb()
		end

		return
	end

	local function func()
		if cb then
			cb()
		end

		self:resetCurShowPetIdle(ent)
	end

	if cfg == nil or #cfg == 0 then
		func()

		return
	end

	local state

	if #cfg <= 3 then
		state = ent:playCfgAnimation({
			cfg[1],
			cfg[2],
			cfg[3],
			{
				true
			}
		})
	else
		state = ent:playCfgAnimation(cfg)
	end

	if not state then
		func()
	else
		ent.eModel:RegisterSleEndCallback(Const.COMPONENT_IDX_PLAYABLE, function()
			func()
		end)
	end
end

function PetDetailSceneV3:switchEvolveGraph(visible)
	self.evolutionPos.gameObject:SetActiveEx(visible)

	for _, templateId in ipairs(self.evolutionShowEntIds) do
		local ent = self.entPoolTable[templateId]

		if ent and ent.eModel then
			ent:setActive(ClientConst.MODEL_VISIBLE_KEY.UIScene, visible)
		end
	end
end

function PetDetailSceneV3:switchRootPetVisible(visible)
	if self.mainEnt then
		self.mainEnt:setActive(ClientConst.MODEL_VISIBLE_KEY.BASE_VISIBLE, visible)
	end
end

function PetDetailSceneV3:stopPetActionByKey(stateKey, ent)
	ent = ent or self.mainEnt

	if not ent then
		return
	end

	ent:stopAnimation(stateKey)
end

function PetDetailSceneV3:clearAniTimer(templateId)
	if templateId then
		local tids = self.aniTimerDict[templateId] or {}

		for _, tid in ipairs(tids) do
			TimerManager.removeTimer(tid)
		end

		self.aniTimerDict[templateId] = nil

		return
	end

	for _, tIds in pairs(self.aniTimerDict or EMPTY_TABLE) do
		for _, tid in ipairs(tIds) do
			TimerManager.removeTimer(tid)
		end
	end

	self.aniTimerDict = {}
end

function PetDetailSceneV3:resetCurShowPetIdle(ent)
	ent = ent or self.mainEnt

	if ent then
		ent:stopLayerAnimation(PlayableConst.AnimationLayer.LAYER_FULLBODY, 0.2)
		ent:playAnimation(PlayableConst.Idle)
	end
end

function PetDetailSceneV3:playCurPetRotation(actionName, targetAngle, duration, cb)
	if self.mainEnt then
		self:clearAniTimer(self.mainEnt.aniTimerKey)

		local startTimerId, _, _ = LuaUIUtils.playEntPhasePlayableAction(self.mainEnt, actionName, nil, nil, duration, function()
			if cb then
				cb()
			end

			self:resetCurShowPetIdle(self.mainEnt)
		end)

		self.aniTimerDict[self.mainEnt.aniTimerKey] = {
			startTimerId
		}

		local curAngle = 0

		DoTweenAnimMgr.DoFloat(self.mainEnt.actorId, 0, targetAngle, LuaUIUtils.TweenId(ID_ROUND_PET), duration, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
			return
		end, function(angle)
			local interval = angle - curAngle

			curAngle = angle

			self.mainEnt.eModel:RotateAroundTransform(interval)
		end, nil, false)
	elseif cb then
		cb()
	end
end

function PetDetailSceneV3:shakeCurPet(delta)
	if not self.mainEnt then
		return
	end

	local x, y, z = self.mainEnt.eModel:GetTransformLocalPosition()
	local ret = Vector3(math.lerp(x, math.clamp(x - delta.x, -0.2, 0.2), 0.1), 0, 0)

	self.mainEnt.eModel:SetTransformLocalPosition(ret.x, ret.y, ret.z)
end

function PetDetailSceneV3:rotateSurveyPet(deltaX)
	if not self.mainEnt or not self.mainEnt.eModel then
		return
	end

	if not deltaX or deltaX == 0 then
		return
	end

	DoTweenAnimMgr.Kill(self.mainEnt.actorId, LuaUIUtils.TweenId(ID_SURVEY_PET_ROTATION), true)

	local targetLocalRotation = Quaternion.New(self.mainEnt.eModel:GetTransformLocalRotation())

	targetLocalRotation = targetLocalRotation * Quaternion.Euler(0, -deltaX * 0.2, 0)

	self.mainEnt.eModel:SetTransformLocalRotation(targetLocalRotation.x, targetLocalRotation.y, targetLocalRotation.z, targetLocalRotation.w)
end

function PetDetailSceneV3:resetSurveyPetRotation(cb)
	if not self.mainEnt or not self.mainEnt.eModel then
		if cb then
			cb()
		end

		return
	end

	local targetRotation = self.mainEntRotation

	targetRotation = targetRotation or self:getPetTargetRotationPosition(self.curShowPetTemplateId, PAGE_ID.SURVEY)

	DoTweenAnimMgr.Kill(self.mainEnt.actorId, LuaUIUtils.TweenId(ID_SURVEY_PET_ROTATION), true)
	DoTweenAnimMgr.Rotate(self.mainEnt.actorId, LuaUIUtils.TweenId(ID_SURVEY_PET_ROTATION), targetRotation, SysConfigData.PetManualScaleSwitchDuration or 0.2, 0, CS.DG.Tweening.Ease.__CastFrom(6), function()
		if cb then
			cb()
		end
	end)
end

function PetDetailSceneV3:entPosToZero()
	if not self.mainEnt then
		return
	end

	DoTweenAnimMgr.Kill(self.mainEnt.actorId, LuaUIUtils.TweenId(ID_ROUND_PET), true)
	DoTweenAnimMgr.Move(self.mainEnt.actorId, LuaUIUtils.TweenId(ID_ENT_TO_ZERO), Vector3.zero, 0.2, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
		return
	end)
end

function PetDetailSceneV3:entPosAngleToZero()
	self.mainEnt.eModel:SetTransformLocalRotation(0, 0, 0, 1)
end

function PetDetailSceneV3:switchCamera(viewId)
	local vcCamera = self.cameraGoDict[viewId]

	if self.curVCamera ~= vcCamera then
		if self.curVCamera then
			self.curVCamera:SetActiveEx(false)
		end

		self.curVCamera = vcCamera

		if self.curVCamera then
			self.curVCamera:SetActiveEx(true)
		end
	end
end

function PetDetailSceneV3:updateCameraPosInSurveyPage()
	if not self.enabledSurveyCameraMove then
		return
	end

	if not self.moveLimit or not self.targetHeight or not self.moveDuration then
		return
	end

	if not self.bipValid then
		local valid, pos = self.mainEnt.eModel.skeletonView:TryGetBonePos("Bip001")

		self.bipValid = valid
		self.bipPos = pos
	end

	if self.pageId == PAGE_ID.SURVEY and self.bipValid then
		local posY = self.bipPos.y
		local delta = posY - self.posY
		local originPos = self.cameraPosDict[self.curPageViewId]

		if delta > self.moveLimit then
			if not self.inTop then
				self:moveCameraPos(self.cameraGoDict[self.curPageViewId], Vector3(originPos.x, originPos.y + self.targetHeight, originPos.z), self.curPageViewId, self.moveDuration)

				self.inTop = true
			end
		elseif self.inTop then
			self:moveCameraPosToOrigin()
		end
	end
end

function PetDetailSceneV3:enableSurveyCameraMove(enabled, heightLimit, heightTarget, duration)
	self.enabledSurveyCameraMove = enabled

	if enabled then
		self.moveLimit = heightLimit
		self.targetHeight = heightTarget
		self.moveDuration = duration
	else
		self.moveLimit = nil
		self.targetHeight = nil
		self.moveDuration = nil
	end
end

function PetDetailSceneV3:moveCameraPosToOrigin()
	local originPos = self.cameraPosDict[self.curPageViewId]

	self:moveCameraPos(self.cameraGoDict[self.curPageViewId], originPos, self.curPageViewId)

	self.inTop = false
end

function PetDetailSceneV3:resetSurveyPageCamera()
	for vcId, go in pairs(self.cameraGoDict) do
		go.transform.localPosition = self.cameraPosDict[vcId]
	end
end

function PetDetailSceneV3:moveCameraPos(cameraGo, targetPos, viewId, duration)
	local tweenId = LuaUIUtils.TweenId("moveCameraPos" .. viewId)

	duration = duration or 0.1

	DoTweenAnimMgr.Kill(cameraGo, tweenId, true)
	DoTweenAnimMgr.Move(cameraGo.transform, tweenId, targetPos, duration, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
		return
	end)
end

function PetDetailSceneV3:clearUpdateTimer()
	if self.updateTimer then
		TimerManager.removeTimer(self.updateTimer)
	end

	self.updateTimer = nil
end

function PetDetailSceneV3:playLightTimeLine(startTime, endTime, callback)
	self.lightTimelineCtrl:PlaySegment(startTime, endTime, callback)
end

function PetDetailSceneV3:getModelSkeletonPos(skeletonName)
	local ent = self.mainEnt

	if not ent.eModel then
		return
	end

	local valid, pos = ent.eModel.skeletonView:TryGetBonePos(skeletonName)

	if not valid then
		return
	end

	return pos
end

function PetDetailSceneV3:checkPointToEnt(screenPos)
	if not self.mainEnt then
		return false
	end

	local ret = self.mainEnt.eModel:RaycastJoints(Const.COMPONENT_INDEX_MODEL, self.uiSceneCamera, Vector3(screenPos.x, screenPos.y), 0.15)

	return ret
end

function PetDetailSceneV3:hideAllEvolveLight()
	for id, go in pairs(self.evolutionLightGoDict) do
		go:SetActiveEx(false)
	end
end

function PetDetailSceneV3:tryChangeLight(pageId, sizeId, sceneId)
	self.lightTransform.gameObject:SetActiveEx(pageId ~= PAGE_ID.EVOLUTION)

	local timelineId = self:getLightTimelineId(pageId, sizeId, sceneId)

	if not self.curLightTimelineId then
		self.curLightTimelineId = timelineId

		local ret = self.lightAssetCtrl:SetLightCurState(timelineId)
	else
		local ret = self.lightAssetCtrl:SwitchLightPlayable(self.curLightTimelineId, timelineId)

		if ret then
			self.curLightTimelineId = timelineId

			self:playLightTimeLine(0, 0.5)

			return
		end

		ret = self.lightAssetCtrl:SwitchLightPlayable(timelineId, self.curLightTimelineId)
		self.curLightTimelineId = timelineId

		if ret then
			self:playLightTimeLine(0.5, 0)

			return
		end
	end
end

function PetDetailSceneV3:getVCameraId(pageId, petCameraModeId)
	if pageId == PAGE_ID.SURVEY or pageId == PAGE_ID.SURVEY_FORM then
		return string.format("%s_%s", pageId, petCameraModeId)
	else
		return pageId
	end
end

function PetDetailSceneV3:getLightTimelineId(pageId, sizeId, sceneId)
	return string.format("%s_%s_%s", pageId, sizeId, sceneId)
end

function PetDetailSceneV3:clearPetPageAction()
	local ent = self.mainEnt

	if ent then
		ent.eModel:RegisterSleEndCallback(Const.COMPONENT_IDX_PLAYABLE, nil)
		DoTweenAnimMgr.Kill(ent.actorId, LuaUIUtils.TweenId(ID_SURVEY_PET_ROTATION), false)
		ent.eModel:StopSleAnimation(Const.COMPONENT_IDX_PLAYABLE)
	end

	if self.enabledSurveyCameraMove then
		local viewId = self.curPageViewId
		local cameraGo = self.cameraGoDict[viewId]

		DoTweenAnimMgr.Kill(cameraGo, LuaUIUtils.TweenId("moveCameraPos" .. viewId), false)

		cameraGo.transform.localPosition = self.cameraPosDict[viewId]
	end

	self:enableSurveyCameraMove(false)

	self.inTop = false
end

function PetDetailSceneV3:onSwitchPet(templateId, label, pageId, countryId, cb)
	local shinyStyleId

	templateId, label, shinyStyleId = PetResearchUtils.getPetDisplayFormLabelTemplateId(templateId, nil, countryId)

	self:clearPetPageAction()
	self:showPet(templateId, label, nil, shinyStyleId)
	self:resetSurveyPageCamera()

	self.mainPetScale = self:getPetTargetScale(templateId, pageId)
	self.mainEntRotation, self.mainEntPos = self:getPetTargetRotationPosition(templateId, pageId)

	self:refreshEntScale(self.mainEnt, self.mainPetScale, self.mainEntRotation, self.mainEntPos)
	self:trySwitchView(pageId, cb)
end

PetDetailSceneV3.ActionCfg = {
	[PAGE_ID.SURVEY] = "showAnimation",
	[PAGE_ID.ABILITY] = "showAnimationAbility",
	[PAGE_ID.EVOLUTION] = "showAnimationEvolve",
	[PAGE_ID.TOPIC] = "showAnimationTask"
}

function PetDetailSceneV3:playPetPageAction(templateId, pageId, cb)
	local curResearchContent = self:getResearchContentData(templateId)
	local cfgAction = self.ActionCfg[pageId]
	local ent = self.mainEnt

	if not ent then
		return
	end

	if not cfgAction then
		ent:showEffect()

		return
	end

	ent:hideEffect()

	local cfg = curResearchContent and curResearchContent[cfgAction]

	self:playPetPhaseAction(ent, cfg, function()
		ent:showEffect()

		if cb then
			cb()
		end
	end)
end

function PetDetailSceneV3:playPetEvolveAction(templateId)
	local ent = self.entPoolTable[templateId]

	if ent then
		local curResearchContent = self:getResearchContentData(templateId)
		local cfgAction = self.ActionCfg[PAGE_ID.EVOLUTION]

		ent:showEffect()

		local cfg = curResearchContent and curResearchContent[cfgAction]

		self:playPetPhaseAction(ent, cfg)
	end
end

function PetDetailSceneV3:getResearchContentData(templateId)
	return PetResearchUtils.getPetResearchContent(templateId)
end

function PetDetailSceneV3:selectPetEvolve(templateId)
	local ent = self.entPoolTable[templateId]

	if ent then
		local eModel = ent.eModel
		local shaderView = eModel.modelShaderView

		self:clearSelectPetEvolve()

		if shaderView then
			shaderView:ChangeEffectMaterial({
				UI_SELECT_MODEL_2,
				UI_SELECT_MODEL
			})

			self.selectedEnt = ent
		end
	end
end

function PetDetailSceneV3:clearSelectPetEvolve()
	if self.selectedEnt then
		local eModel = self.selectedEnt.eModel
		local shaderView = eModel and eModel.modelShaderView

		if shaderView then
			shaderView:ResetMaterial()
		end
	end

	self.selectedEnt = nil

	if self.selectedArrowId then
		pg.game.effect:stopEffect(0, self.selectedArrowId)
	end

	self.selectedArrowId = nil
end

function PetDetailSceneV3:getEntById(templateId)
	if templateId then
		if self.entPoolTable[templateId] then
			self.entPoolTable[templateId]:setActive(ClientConst.MODEL_VISIBLE_KEY.UIScene, true)

			return self.entPoolTable[templateId]
		else
			local ent = self:getSimpleEnt(templateId)

			self.entPoolTable[templateId] = ent

			return ent
		end
	end
end

function PetDetailSceneV3:getEntByTemplateId(templateId)
	if not templateId then
		return nil
	end

	if self.curShowPetTemplateId == templateId and self.mainEnt then
		return self.mainEnt
	end

	if self.entPoolTable then
		return self.entPoolTable[templateId]
	end

	return nil
end

function PetDetailSceneV3:registerEntLoadedCallback(templateId, cb)
	if not cb then
		return false
	end

	local ent = self:getEntByTemplateId(templateId)

	if not ent then
		return false
	end

	local modelView = ent.eModel.modelModelView

	if modelView.firstLoaded then
		TimerManager.addTimer(0.05, cb)

		return true
	end

	function modelView.luaOnModelRefreshFinshed()
		cb()
	end

	return true
end

function PetDetailSceneV3:playSurveyAction(ent, action, cb)
	ent = ent or self.mainEnt

	if not ent then
		return
	end

	ent:showEffect()
	self:playPetPhaseAction(ent, action, cb)
end

function PetDetailSceneV3:recycleEnt(templateId)
	if self.entPoolTable[templateId] then
		self.entPoolTable[templateId]:setActive(ClientConst.MODEL_VISIBLE_KEY.UIScene, false)
		self.entPoolTable[templateId].eModel:SetTransformParent(self.entPoolTransform)
	end
end

function PetDetailSceneV3:showPet(templateId, label, forceUseUnknowMat, shinyStyleId)
	label = label or 0
	shinyStyleId = shinyStyleId or 0

	local isMainEntUnknown = self.mainEnt and self.mainEnt._petMatForceUnKnow

	if templateId and self.curShowPetTemplateId == templateId and self.label == label and self.shinyStyleId == shinyStyleId and (forceUseUnknowMat or not isMainEntUnknown) then
		return
	end

	self:recycleEnt(self.curShowPetTemplateId)

	self.curShowPetTemplateId = templateId
	self.label = label
	self.shinyStyleId = shinyStyleId or 0

	self:clearAniTimer()

	self.mainEnt = self:getEntById(templateId)

	self.mainEnt.eModel:SetTransformParent(self.petRootTransform, false)
	self.mainEnt.eModel:SetTransformLocalPosition()
	self.mainEnt.eModel:SetGameObjectName(templateId)
	self.mainEnt.eModel:AddShadowComp(ClientConst.ShadowPriority.PetResearchDetail)

	local researchContentData = self:getResearchContentData(templateId)

	self.sceneID = researchContentData.scene

	self:showSubScene()

	local isSandLand = self.sceneID == SCENE_ID.Water
	local amb = isSandLand and PetDetailAmb.AmbBeach or PetDetailAmb.AmbGrass

	pg.game.audio:playAmb(amb, AudioConst.BgmPriority.PetDetailScene)

	self.gender = self:getResearchContentData(templateId).gender

	self:disableEntUnknown(self.mainEnt)
	self:refreshPetModelAppearance(templateId, self.mainEnt, label, true, nil, shinyStyleId)

	self.bipTrans = nil
	self.bipValid = false

	if forceUseUnknowMat then
		self.mainEnt._petMatForceUnKnow = true
	else
		self.mainEnt._petMatForceUnKnow = nil
	end
end

function PetDetailSceneV3:preLoadSubScene(templateId)
	local researchContentData = self:getResearchContentData(templateId)

	self.sceneID = researchContentData.scene

	self:showSubScene()
end

function PetDetailSceneV3:showSubScene()
	if self.curShowPetTemplateId then
		local configData = PetProtoTypeData[self.curShowPetTemplateId]

		self.bgName = string.upper(CustomEnData[tostring(configData.name)] or "")
	end

	if self.sceneID == SCENE_ID.Water then
		if not self.sandScene then
			self.sandScene = true

			self:loadSubScene(AddressDataConst.UI_HANDBOOK_SAND_SCENE, self.artAssetTransform, "sandName")
		elseif self.sandName then
			self.sandName:SetText(self.bgName)
		end
	elseif self.sceneID == SCENE_ID.Grass then
		if not self.grassScene then
			self.grassScene = true

			self:loadSubScene(AddressDataConst.UI_HANDBOOK_GRASS_SCENE, self.artAssetGrassTransform, "grassName")
		elseif self.grassName then
			self.grassName:SetText(self.bgName)
		end
	end
end

function PetDetailSceneV3:loadSubScene(resId, parentTrans, nameNode)
	pg.global.resMgr:GetInstanceFromCacheByLua(resId, function(obj, userData)
		self.resLoadInst[#self.resLoadInst + 1] = obj

		obj.transform:SetParent(parentTrans, false)

		obj.transform.localPosition = Vector3.zero

		local ojr = obj.transform:Find("Global"):GetComponent("ObjectReference")

		self[nameNode] = ojr:GetRefValue("name")

		if self.bgName then
			self[nameNode]:SetText(self.bgName)
		end
	end)
end

function PetDetailSceneV3:refreshEntScale(ent, scale, eulerAngleVector3, position)
	local eModel = ent.eModel

	if eModel then
		ent.eModel:SetTransformLocalScale(scale, scale, scale)

		if eulerAngleVector3 then
			ent.eModel:SetTransformRotationByEulerAngle(eulerAngleVector3.x, eulerAngleVector3.y, eulerAngleVector3.z)
		end

		if position then
			ent.eModel:SetTransformLocalPosition(position.x, position.y, position.z)
		end
	end
end

function PetDetailSceneV3:generalPetEvolutionBranchGraph(petId)
	self.evolutionPetDict = {}

	local petInfo = pg.me:getPetInfo(petId)
	local label = petInfo.label or 0

	self.curShowPetTemplateId = petInfo.templateId
	self.petId = petId

	self:trySwitchView(PAGE_ID.EVOLUTION)

	local templateId = petInfo.templateId

	if not templateId then
		return
	end

	local curPetStage = Utils.getPetPrototypeStage(templateId)
	local refTemplated = Utils.getRefIdByPetPrototypeId(templateId)
	local evolveData = PetEvolveData[templateId] or PetEvolveData[refTemplated]
	local petData = PetProtoTypeData[templateId] or PetProtoTypeData[refTemplated]

	if evolveData[1].individual then
		pg.global.uiMgr:HideEvolveGraphLine()

		local ent = self:getEvolveEnt(templateId, curPetStage, evolveData[1].position, label, true, petInfo.gender)
		local rotation, _ = self:getPetTargetRotationPosition(templateId, PAGE_ID.EVOLUTION)

		ent.eModel:SetTransformRotationByEulerAngle(rotation[1], rotation[2], rotation[3])
	else
		local groupId = evolveData[1].groupId
		local ethnicTemplateIds = PetEthnicData[petData.ethnicGroup] and PetEthnicData[petData.ethnicGroup][groupId] or {}
		local curPetEntInfo = ethnicTemplateIds[templateId] or ethnicTemplateIds[refTemplated]
		local petHandbookMap = pg.me.petHandbookMap
		local ent = self:getEvolveEnt(templateId, curPetStage, curPetEntInfo.position, label, true, petInfo.gender)
		local rotation = self:getPetTargetRotationPosition(templateId, PAGE_ID.EVOLUTION)
		local originPos = self["pos" .. curPetEntInfo.position .. curPetStage].position

		pg.global.uiMgr:HideEvolveGraphLine(self.originPointKey)
		pg.global.uiMgr:ShowHandbookEvolvePoint(self.originPointKey, self.Blue_Line_Color, 0.1, Vector3(originPos.x, self.posY, originPos.z), self.evolutionPos.transform)
		pg.global.uiMgr:PlayHandbookEvolveLineBloom("EvolutionLine02", self.originPointKey)
		ent.eModel:SetTransformRotationByEulerAngle(rotation[1], rotation[2], rotation[3])

		for branchId, branchInfo in pairs(evolveData) do
			local targetPetId = branchInfo.targetPetId

			if targetPetId then
				local targetPetInfo = ethnicTemplateIds[targetPetId]
				local targetPetStage = Utils.getPetPrototypeStage(targetPetId)

				rotation = self:getPetTargetRotationPosition(targetPetId, PAGE_ID.EVOLUTION)

				local targetPos = self["pos" .. targetPetInfo.position .. targetPetStage].position

				originPos = self["pos" .. curPetEntInfo.position .. curPetStage].position

				local isGot = petHandbookMap[targetPetId] and petHandbookMap[targetPetId]:isCatched()
				local canEvolve = petInfo:canEvolveBranch(branchId)
				local key = targetPetInfo.position .. targetPetStage .. curPetEntInfo.position .. curPetStage
				local left = originPos.x < targetPos.x and true or false
				local degree = targetPetStage - curPetStage > 1 and 45 or 80
				local color
				local dashed = not isGot
				local routeInitState = branchInfo.routeInitState
				local needDraw = true
				local entVisible = true

				if routeInitState then
					if routeInitState == 0 then
						local handbookInfo = petHandbookMap:getInfo(templateId) or petHandbookMap:getInfo(refTemplated)
						local branchStatus = handbookInfo:getEvolveResearchInfoWithDefault(branchId):getRawTable()
						local isKnown = branchStatus.status ~= Const.PET_RESEARCH.STATUS_HIDE

						if not isKnown then
							needDraw = false
							entVisible = false
						end
					elseif routeInitState == 2 then
						dashed = false
					end
				end

				local targetEnt = self:getEvolveEnt(targetPetId, targetPetStage, targetPetInfo.position, label, entVisible, petInfo.gender)

				targetEnt.eModel:SetTransformRotationByEulerAngle(rotation[1], rotation[2], rotation[3])
				targetEnt.eModel:SetGameObjectName("evolveGraph_" .. branchId)

				self.evolutionPetDict[targetPetId] = targetEnt

				local isGray = false

				if not canEvolve and not isGot and routeInitState ~= 2 then
					self:showEntUnknown(self.evolutionPetDict[targetPetId])
				end

				if branchInfo.isSpecial then
					color = self.Pink_Line_Color

					if not canEvolve then
						color = self.Pink_Line_Gray_Color
						isGray = true
					end
				else
					color = self.Blue_Line_Color

					if not canEvolve then
						color = self.Blue_Line_Gray_Color
						isGray = true
					end
				end

				if needDraw then
					pg.global.uiMgr:ShowHandbookEvolveLine(key, color, dashed, Vector2(originPos.x, originPos.z), Vector2(targetPos.x, targetPos.z), self.evolutionPos.transform, degree, self.posY, left)

					if not isGray then
						local presetName = canEvolve and "EvolutionLine" or "EvolutionLine02"

						pg.global.uiMgr:PlayHandbookEvolveLineBloom(presetName, key)
					else
						pg.global.uiMgr:CloseHandbookEvolveLineBloom("EvolutionLine", key)
					end
				end
			end
		end

		local offsetPos = evolveData[1].cameraPositionIndividual or Vector3.zero
		local offsetRotation = evolveData[1].cameraRotationIndividual or Vector3.zero

		self:adjustEvolvePos(templateId, offsetPos, offsetRotation)
	end
end

function PetDetailSceneV3:refreshPetModelAppearance(templateId, ent, label, visible, gender, shinyStyleId)
	ent = ent or self.mainEnt
	gender = gender or self.gender

	if not ent then
		return
	end

	local eModel = ent.eModel

	if eModel then
		local modelView = eModel.modelModelView
		local researchContentData = self:getResearchContentData(templateId)

		label = label or 0
		shinyStyleId = shinyStyleId or 0

		local oldShinyStyleId = ent.shinyStyle or 0

		if Utils.isLabelShiny(ent.label) and (not Utils.isLabelShiny(label) or oldShinyStyleId ~= shinyStyleId) then
			ent:clearPetShinyAppearance()
		end

		local petInfo = {
			templateId = templateId,
			label = label,
			shinyStyle = shinyStyleId,
			gender = gender or researchContentData.gender or 0
		}
		local petData = ClientVirtualEntityUtils.syncPetUISceneAppearanceSource(ent, petInfo)

		if not petData then
			return
		end

		petInfo.petPrototypeId = petData.petPrototypeId

		local extraData, prefabResID

		if gender then
			extraData = ClientModelUtils.getModelExtraInfo(petData, label, gender, false)
		else
			extraData = ClientModelUtils.getModelExtraInfo(petData, label, researchContentData.gender or 0, false)
		end

		ClientModelUtils.applyModelAppearance(modelView.modelInfo, petData, extraData)

		eModel.RootRotationScale = Vector3(0, 0, 0)

		ClientModelUtils.applyAnimController(ent, eModel, petData)
		modelView:RefreshModels()

		local didRefresh = PetTransmogUtils.applySchemeTransmog(ent, templateId, nil, true, true)

		self:replayAfterTransmogRefresh(ent, didRefresh, function()
			ent:refreshParmonDye()
			ent:attachBaseEffects(extraData.attachEffects, ent.isIgnoreEffectLod)
			self:refreshEntityRenderState(ent, visible)
		end)
		ent:addEModelMonoComponent(CommonConst.COMPONENT_IDX_PHYSX)

		local entCfg = ent:getConfigData()

		ent.eModel:GenCapsule(CommonConst.COMPONENT_IDX_PHYSX, entCfg.bodySize, entCfg.modelHeight, Vector3(0, entCfg.modelHeight / 2, 0), true, false)
		ent:setLodTickEnable(Const.LOD_TICK_KEY.DEFAULT, false)
		ent:setRendererLod(0)
	end
end

function PetDetailSceneV3:onDestroy()
	pg.global.uiMgr:ClearHandbookEvolveLine()

	for idx, res in ipairs(self.resLoadInst) do
		pg.global.resMgr:RemoveInstanceToCache(res, true)
	end

	self:destroyAllEnt()
	self:clearAniTimer()
	self:destroyModelView()
	self:clearUpdateTimer()
	self:clearSelectPetEvolve()
	pg.game.audio:playAmb(nil, AudioConst.BgmPriority.PetDetailScene)
end

function PetDetailSceneV3:destroyModelView()
	for _, sceneViews in pairs(self.sceneTable) do
		for _, modelView in pairs(sceneViews) do
			modelView:Destroy()
		end
	end
end

function PetDetailSceneV3:destroyAllEnt()
	for _, ent in pairs(self.entPoolTable) do
		ClientUtils.safeDestroy(ent)
	end
end

function PetDetailSceneV3:entActive(active)
	if self.mainEnt then
		self.mainEnt:setActive(ClientConst.MODEL_VISIBLE_KEY.UIScene, active)
	end
end

return PetDetailSceneV3
