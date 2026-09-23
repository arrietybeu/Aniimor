-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\PetManagementTrainingScene.lua

local ClientUtils = require("Utils.ClientUtils")
local EMPTY_TABLE = require("Core.Common.EmptyTable")
local CommonConst = require("Common.Const.Const")
local PetProtoTypeData = require("Data.pet_prototype_data")
local AudioConst = require("Const.AudioConst")
local DoTweenAnimMgr = DoTweenAnimMgr
local HandbookModelView = HandbookModelView
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local Utils = require("Common.Utils.Utils")
local PetConfigData = require("Data.pet_config_data")
local Const = require("Common.Const.Const")
local PetEvolveData = require("Data.pet_evolve_data")
local PetEvolveCameraPosData = require("Data.pet_evolve_camera_pos_data")
local PetPrototypeData = require("Data.pet_prototype_data")
local PetResearchUtilsCommon = require("Common.Utils.PetResearchUtils")
local AddressDataConst = require("Const.AddressDataConst")
local PetEthnicData = require("Data.pet_ethnic_group_data")
local SysConfigData = require("Data.sys_config_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientVirtualEntityUtils = require("Utils.ClientVirtualEntityUtils")
local PetJewelryOssCache = require("Utils.PetJewelryOssCache")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local PlayableConst = require("Common.Const.PlayableConst")
local TimerManager = require("Core.Timer.TimerManager")
local ClientAbilityConst = require("Const.ClientAbilityConst")
local PetManagementTrainingScene = Class.LightClass("PetManagementTrainingScene", UISceneBase)
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local ID_MAIN_PET_SCALE = "mainPetScale"
local ID_MAIN_PET_ROTATION = "mainPetRotation"
local ID_MAIN_PET_POS = "mainPetPos"
local ID_ROUND_PET = "roundPet"
local ID_ENT_TO_ZERO = "entToZero"
local PAGE_ID = UIConst.HANDBOOK_PAGE_IDX
local UI_SELECT_MODEL = AddressDataConst.UI_SELECT_MODEL
local UI_SELECT_MODEL_2 = AddressDataConst.UI_SELECT_MODEL_2
local SCENE_ID = {
	Grass = 2,
	Water = 1
}

function PetManagementTrainingScene:getPetPreviewExtraData(templateId, petInfo)
	local realPetId = petInfo and petInfo.templateId == templateId and petInfo.id or nil
	local label = petInfo and petInfo.label

	if petInfo and petInfo.templateId ~= templateId then
		label = bit.band(label or 0, bit.bnot(Const.PET_LABEL_MASK.DARK))
	end

	return {
		applyAnimController = true,
		useTransmogScheme = true,
		modelNeedBones = true,
		canAttachEffs = true,
		configData = ClientVirtualEntityUtils.getPetUISceneConfig(templateId),
		petInfo = petInfo,
		label = label,
		isCreateEntUsePetId = realPetId ~= nil,
		petId = realPetId,
		realPetId = realPetId,
		clearJewelryInfo = realPetId == nil,
		transmogPetId = realPetId
	}
end

function PetManagementTrainingScene:getSimpleEnt(templateId, petInfo)
	return PetManagementDataHelper.previewPetModel(templateId, self.entPoolTransform, function(ent)
		ent:setScaleNumber(1)
		ent.eModel:SetTransformLocalPosition()

		ent.modelNeedBones = true

		ent:setLodTickEnable(Const.LOD_TICK_KEY.DEFAULT, false)
	end, self:getPetPreviewExtraData(templateId, petInfo))
end

function PetManagementTrainingScene:onStart()
	self.Blue_Line_Color = Color(0.1921569, 0.6588235, 0.8784314, 1)
	self.Blue_Line_Gray_Color = Color(0.2156863, 0.345098, 0.5176471, 0.7)
	self.Pink_Line_Color = Color(0.9960784, 0.3254902, 0.6862745, 1)
	self.Pink_Line_Gray_Color = Color(0.4980392, 0.2117647, 0.3647059, 0.7)

	local root = self.scene.transform:Find("Global")

	self.objectReference = root:GetComponent("ObjectReference")
	self.petRootTransform = self.objectReference:GetRefValue("petRootTransform")
	self.uiSceneCamera = self.objectReference:GetRefValue("uiSceneCamera")
	self.evolutionCameraTransform = self.objectReference:GetRefValue("evolutionCameraTransform")
	self.lightTimelineCtrl = self.objectReference:GetRefValue("lightTimelineCtrl")
	self.lightAssetCtrl = self.objectReference:GetRefValue("lightAssetCtrl")
	self.lightTransform = self.objectReference:GetRefValue("lightTransform")
	self.evolutionTransform = self.objectReference:GetRefValue("evolutionTransform")
	self.notHidingTransform = self.objectReference:GetRefValue("notHidingTransform")
	self.pos01 = self.objectReference:GetRefValue("pos01Transform")
	self.pos02 = self.objectReference:GetRefValue("pos02Transform")
	self.pos12 = self.objectReference:GetRefValue("pos12Transform")
	self.pos03 = self.objectReference:GetRefValue("pos03Transform")
	self.pos13 = self.objectReference:GetRefValue("pos13Transform")
	self.pos23 = self.objectReference:GetRefValue("pos23Transform")
	self.evolutionPos = self.objectReference:GetRefValue("EvolutionPos")
	self.entPoolTransform = self.objectReference:GetRefValue("entPoolTransform")
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

	self.posY = 5000
	self.centerPos = Vector3(0, self.posY, 0)
	self.scene.transform.position = self.centerPos
	self.evolutionCameraOriginPosition = self.evolutionCameraTransform.position
	self.evolutionPosOriginPosition = self.evolutionPos.position
	self.evolutionTransformOriginPosition = self.evolutionTransform.position
	self.evolutionGraphTransform = self.pos01 and self.pos01.parent or self.notHidingTransform
	self.evolutionGraphOriginPosition = self.evolutionGraphTransform and self.evolutionGraphTransform.position or Vector3.zero
	self.evolutionOriginPosTable = {}

	for id, trans in pairs(self.posTable) do
		self.evolutionOriginPosTable[id] = trans.position
	end

	self:initTempScene()
	self:initVirtualCameraGroup()

	self.originPointKey = "originPoint"
	self.resLoadInst = {}
end

function PetManagementTrainingScene:initTempScene()
	self.sceneTable = {}
	self.evolutionView = HandbookModelView()

	self.evolutionView:SetHandbookModel(self.evolutionTransform.gameObject)

	self.sceneTable[PAGE_ID.EVOLUTION] = {
		[SCENE_ID.Water] = self.evolutionView,
		[SCENE_ID.Grass] = self.evolutionView
	}
end

function PetManagementTrainingScene:initVirtualCameraGroup()
	self.cameraGoDict = {}
	self.cameraPosDict = {}

	local pageCameraTrans = {
		[PAGE_ID.EVOLUTION] = self.evolutionCameraTransform
	}
	local cameraNames = {
		"VCameraNear",
		"VCameraMid",
		"VCameraFar"
	}

	for pid, trans in pairs(pageCameraTrans) do
		local vcId = self:getVCameraId(pid)
		local vc = trans:Find(cameraNames[1]):GetComponent("RefVirtualCameraBehavior")

		self.cameraGoDict[vcId] = vc.gameObject

		function vc.luaFinishBlend()
			self:cameraBlendFinishCb()
		end

		self.cameraGoDict[vcId]:SetActiveEx(false)

		self.cameraPosDict[vcId] = vc.transform.localPosition
	end

	self.evolutionLightGoDict = {}

	for id, trans in pairs(self.posTable) do
		local vc = trans:Find("Camera")

		vc.gameObject:SetActiveEx(false)

		self.evolutionLightGoDict[id] = trans:Find("Light").gameObject

		self.evolutionLightGoDict[id]:SetActiveEx(false)
	end
end

function PetManagementTrainingScene:getPetTargetScale(templateId, pageId)
	if pageId == PAGE_ID.EVOLUTION then
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

			return posScale[positionId] or 1
		end

		local groupId = PetEvolveData[templateId][1].groupId
		local ethnicTemplateIds = PetEthnicData[petData.ethnicGroup][groupId] or {}
		local curPosInfo = ethnicTemplateIds[templateId]
		local positionId = curPosInfo.position
		local posScale = PetConfigData["PetScaleInEvo_" .. stage]

		return posScale[positionId] or 1
	end
end

function PetManagementTrainingScene:getPetTargetRotationPosition(templateId)
	local contentData = self:getResearchContentData(templateId)
	local modelPos, modelRotation

	modelRotation = contentData.modelRotation

	local rotation = self:getPetTargetEvolutionRotation(templateId, self.cameraGoDict[PAGE_ID.EVOLUTION].transform.position)

	modelPos = contentData.modelPos or Vector3.zero

	return Quaternion.ToEulerAngles(rotation) + Vector3(modelRotation[1], modelRotation[2], modelRotation[3]) or Vector3.zero, modelPos
end

function PetManagementTrainingScene:cameraBlendFinishCb()
	if self.pageCb then
		self.pageCb()
	end
end

function PetManagementTrainingScene:evolutionCameraBlendFinishCb()
	self.cameraGoDict[self.curPageViewId]:SetActiveEx(true)
end

function PetManagementTrainingScene:trySwitchView(pageId, cb)
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

function PetManagementTrainingScene:TweenPetScale(pageId)
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

function PetManagementTrainingScene:TweenPetRotation(pageId)
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

function PetManagementTrainingScene:refreshEvolutionGraph()
	local petData = PetProtoTypeData[self.curShowPetTemplateId]
	local evolveData = PetEvolveData[self.curShowPetTemplateId][1]

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

function PetManagementTrainingScene:generalPetEvolutionBranchGraph(petId)
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

		local ent = self:getEvolveEnt(templateId, curPetStage, evolveData[1].position, label, true, petInfo.gender, petInfo)
		local rotation, _ = self:getPetTargetRotationPosition(templateId, PAGE_ID.EVOLUTION)

		ent.eModel:SetTransformRotationByEulerAngle(rotation[1], rotation[2], rotation[3])
	else
		local groupId = evolveData[1].groupId
		local ethnicTemplateIds = PetEthnicData[petData.ethnicGroup] and PetEthnicData[petData.ethnicGroup][groupId] or {}
		local curPetEntInfo = ethnicTemplateIds[templateId] or ethnicTemplateIds[refTemplated]
		local petHandbookMap = pg.me.petHandbookMap
		local ent = self:getEvolveEnt(templateId, curPetStage, curPetEntInfo.position, label, true, petInfo.gender, petInfo)
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

				local targetEnt = self:getEvolveEnt(targetPetId, targetPetStage, targetPetInfo.position, 0, entVisible, nil, petInfo)

				targetEnt.eModel:SetTransformRotationByEulerAngle(rotation[1], rotation[2], rotation[3])
				targetEnt.eModel:SetGameObjectName("evolveGraph_" .. branchId)

				self.evolutionPetDict[targetPetId] = targetEnt

				local isGray = false

				if not isGot and routeInitState ~= 2 then
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

function PetManagementTrainingScene:changeEvolutionPos()
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

function PetManagementTrainingScene:generalEvolutionGraphIndividual(label)
	self.groupId = nil
	self.curEthicGroup = nil

	pg.global.uiMgr:HideEvolveGraphLine()
end

function PetManagementTrainingScene:generalEvolutionGraph(label)
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
			local ent = self:getEvolveEnt(petTemplateId, stage, info.position, label or 0, entVisible)
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

function PetManagementTrainingScene:getPetTargetEvolutionRotation(templateId, cameraPos)
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

function PetManagementTrainingScene:adjustEvolvePos(templateId, offsetPos, offsetRotation)
	local targetPos = self:getEvolveEntOriginPos(templateId)
	local dir = self.centerPos - targetPos

	self.evolutionPos.position = self.evolutionPosOriginPosition + dir

	if self.evolutionTransform ~= self.evolutionPos then
		self.evolutionTransform.position = self.evolutionTransformOriginPosition + dir
	end

	if self.evolutionGraphTransform and self.evolutionGraphTransform ~= self.evolutionPos and self.evolutionGraphTransform ~= self.evolutionTransform then
		self.evolutionGraphTransform.position = self.evolutionGraphOriginPosition + dir
	end

	self.evolutionCameraTransform.position = self.evolutionCameraOriginPosition + dir + offsetPos
	self.evolutionCameraTransform.localRotation = Quaternion.Euler(offsetRotation[1], offsetRotation[2], offsetRotation[3])

	self:hideAllEvolveLight()

	local posId = self:getEvolveEntPosId(templateId)

	if posId then
		self.evolutionLightGoDict[posId]:SetActiveEx(true)
	end
end

function PetManagementTrainingScene:getEvolveEntOriginPos(templateId)
	local posIdx = self:getEvolveEntPosId(templateId)

	if posIdx then
		return self.evolutionOriginPosTable and self.evolutionOriginPosTable[posIdx] or self.posTable[posIdx].position
	end

	return Vector3.zero
end

function PetManagementTrainingScene:getEvolveEntPos(templateId)
	local posIdx = self:getEvolveEntPosId(templateId)

	if posIdx then
		return self.posTable[posIdx].position
	end

	return Vector3.zero
end

function PetManagementTrainingScene:registerEntLoadedCallback(templateId, cb)
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

	self.entLoadedCallbackTable = self.entLoadedCallbackTable or {}

	local callbacks = self.entLoadedCallbackTable[templateId]

	if not callbacks then
		callbacks = {}
		self.entLoadedCallbackTable[templateId] = callbacks
	end

	callbacks[#callbacks + 1] = cb

	function modelView.luaOnModelRefreshFinshed()
		local loadedCallbacks = self.entLoadedCallbackTable and self.entLoadedCallbackTable[templateId]

		if self.entLoadedCallbackTable then
			self.entLoadedCallbackTable[templateId] = nil
		end

		for _, loadedCallback in ipairs(loadedCallbacks or EMPTY_TABLE) do
			loadedCallback()
		end
	end

	return true
end

function PetManagementTrainingScene:getEvolveEntTopWorldPos(templateId, pageId)
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

function PetManagementTrainingScene:getEvolveEntPosId(templateId)
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

function PetManagementTrainingScene:showEntUnknown(ent, cb)
	ent._petMatForceUnKnow = true

	ent:setAttachEffectVisibleByReason(ClientConst.MODEL_VISIBLE_KEY.UIScene, false)

	local shaderView = ent.eModel.shaderView

	shaderView:SetOverrideMaterial(PetManagementDataHelper.getPetHandbookMat(), cb)
	shaderView:SetMultiPassRenderEnable(false)
end

function PetManagementTrainingScene:disableEntUnknown(ent)
	if not ent._petMatForceUnKnow then
		return
	end

	ent._petMatForceUnKnow = nil

	ent:setAttachEffectVisibleByReason(ClientConst.MODEL_VISIBLE_KEY.UIScene, true)

	local shaderView = ent.eModel.shaderView

	shaderView:SetOverrideMaterial("")
	shaderView:SetMultiPassRenderEnable(true)
end

function PetManagementTrainingScene:setMainEntKnownState(isKnown)
	if self.mainEnt and self.mainEnt.eModel then
		if not isKnown then
			self:showEntUnknown(self.mainEnt)
		else
			self:disableEntUnknown(self.mainEnt)
		end
	end
end

function PetManagementTrainingScene:recycleEvolution()
	local len = #self.evolutionShowEntIds

	for idx = 1, len do
		local templateId = self.evolutionShowEntIds[idx]

		self:recycleEnt(templateId)
	end

	self.evolutionShowEntIds = {}
end

function PetManagementTrainingScene:getEvolveEnt(templateId, stage, positionId, label, visible, gender, petInfo)
	local ent = self:getEntById(templateId, petInfo)
	local pKey = templateId .. "evolve"

	if gender then
		self.curGender = gender
	end

	self:disableEntUnknown(ent)
	self:refreshPetModelAppearance(templateId, ent, label or 0, visible, pKey, self.curGender, petInfo)

	local posTrans = self["pos" .. positionId .. stage]

	ent.eModel:SetTransformParent(posTrans, false)
	ent.eModel:SetTransformLocalPosition()

	self.evolutionShowEntIds[#self.evolutionShowEntIds + 1] = templateId

	return ent
end

function PetManagementTrainingScene:TweenSceneFade(pageId)
	local researchContentData = self:getResearchContentData(self.curShowPetTemplateId)
	local sceneId

	sceneId = not researchContentData and 1 or researchContentData.scene or 1

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

function PetManagementTrainingScene:TweenCameraFade()
	local cameraModeId = PetPrototypeData[self.curShowPetTemplateId].cameraDistModeId or 1

	if cameraModeId ~= self.cameraModeId then
		local modelView = self.sceneTable[self.pageId][self.sceneId]

		if modelView then
			modelView:PlayHandBookCameraViewFade("HBFade1", SysConfigData.PetManualSceneSwitchDuration or 0.5, self.centerPos, 2, 2)
		end

		self.cameraModeId = cameraModeId
	end
end

function PetManagementTrainingScene:playPetPhaseAction(ent, cfg, cb)
	ent = ent or self.mainEnt

	if not ent then
		if cb then
			cb()
		end

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

	if cb then
		if not state then
			cb()
		else
			ent.eModel:RegisterSleEndCallback(Const.COMPONENT_IDX_PLAYABLE, function()
				cb()
			end)
		end
	end
end

function PetManagementTrainingScene:switchEvolveGraph(visible)
	self.evolutionPos.gameObject:SetActiveEx(visible)

	if visible then
		for _, templateId in ipairs(self.evolutionShowEntIds) do
			local ent = self.entPoolTable[templateId]

			if ent and ent.eModel then
				ent:setActive(ClientConst.MODEL_VISIBLE_KEY.UIScene, true)
				ent.eModel:PlayDefaultAnimation(Const.COMPONENT_IDX_PLAYABLE, true)
			end
		end
	end
end

function PetManagementTrainingScene:entPosToZero()
	if not self.mainEnt then
		return
	end

	DoTweenAnimMgr.Kill(self.mainEnt.actorId, LuaUIUtils.TweenId(ID_ROUND_PET), true)
	DoTweenAnimMgr.Move(self.mainEnt.actorId, LuaUIUtils.TweenId(ID_ENT_TO_ZERO), Vector3.zero, 0.2, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
		return
	end)
end

function PetManagementTrainingScene:entPosAngleToZero()
	self.mainEnt.eModel:SetTransformLocalRotation(0, 0, 0, 1)
end

function PetManagementTrainingScene:switchCamera(viewId)
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

function PetManagementTrainingScene:enableSurveyCameraMove(enabled, heightLimit, heightTarget, duration)
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

function PetManagementTrainingScene:moveCameraPosToOrigin()
	local originPos = self.cameraPosDict[self.curPageViewId]

	self:moveCameraPos(self.cameraGoDict[self.curPageViewId], originPos, self.curPageViewId)

	self.inTop = false
end

function PetManagementTrainingScene:resetSurveyPageCamera()
	for vcId, go in pairs(self.cameraGoDict) do
		go.transform.localPosition = self.cameraPosDict[vcId]
	end
end

function PetManagementTrainingScene:moveCameraPos(cameraGo, targetPos, viewId, duration)
	local tweenId = LuaUIUtils.TweenId("moveCameraPos" .. viewId)

	duration = duration or 0.1

	DoTweenAnimMgr.Kill(cameraGo, tweenId, true)
	DoTweenAnimMgr.Move(cameraGo.transform, tweenId, targetPos, duration, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
		return
	end)
end

function PetManagementTrainingScene:clearUpdateTimer()
	if self.updateTimer then
		TimerManager.removeTimer(self.updateTimer)
	end

	self.updateTimer = nil
end

function PetManagementTrainingScene:playLightTimeLine(startTime, endTime, callback)
	self.lightTimelineCtrl:PlaySegment(startTime, endTime, callback)
end

function PetManagementTrainingScene:getModelSkeletonPos(skeletonName)
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

function PetManagementTrainingScene:checkPointToEnt(screenPos)
	if not self.mainEnt then
		return false
	end

	local ret = self.mainEnt.eModel:RaycastJoints(Const.COMPONENT_INDEX_MODEL, self.uiSceneCamera, Vector3(screenPos.x, screenPos.y), 0.15)

	return ret
end

function PetManagementTrainingScene:hideAllEvolveLight()
	for id, go in pairs(self.evolutionLightGoDict) do
		go:SetActiveEx(false)
	end
end

function PetManagementTrainingScene:tryChangeLight(pageId, sizeId, sceneId)
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

function PetManagementTrainingScene:getVCameraId(pageId, petCameraModeId)
	if pageId == PAGE_ID.SURVEY or pageId == PAGE_ID.SURVEY_FORM then
		return string.format("%s_%s", pageId, petCameraModeId)
	else
		return pageId
	end
end

function PetManagementTrainingScene:getLightTimelineId(pageId, sizeId, sceneId)
	return string.format("%s_%s_%s", pageId, sizeId, sceneId)
end

PetManagementTrainingScene.ActionCfg = {
	[PAGE_ID.SURVEY] = "showAnimation",
	[PAGE_ID.ABILITY] = "showAnimationAbility",
	[PAGE_ID.EVOLUTION] = "showAnimationEvolve",
	[PAGE_ID.TOPIC] = "showAnimationTask"
}

function PetManagementTrainingScene:playPetPageAction(templateId, pageId, cb)
	local curResearchContent = self:getResearchContentData(templateId)
	local cfgAction = self.ActionCfg[pageId]

	if cfgAction then
		self.mainEnt:hideEffect()
		self:playPetPhaseAction(self.mainEnt, curResearchContent[cfgAction], cb)
	end
end

function PetManagementTrainingScene:playPetEvolveAction(templateId)
	local ent = self.entPoolTable[templateId]

	if ent then
		local curResearchContent = self:getResearchContentData(templateId)
		local cfgAction = self.ActionCfg[PAGE_ID.EVOLUTION]

		ent:showEffect()
		self:playPetPhaseAction(ent, curResearchContent[cfgAction])
	end
end

function PetManagementTrainingScene:getResearchContentData(templateId)
	return PetResearchUtils.getPetResearchContent(templateId)
end

function PetManagementTrainingScene:selectPetEvolve(templateId)
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

function PetManagementTrainingScene:clearSelectPetEvolve()
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

function PetManagementTrainingScene:getEntById(templateId, petInfo)
	if templateId then
		if self.entPoolTable[templateId] then
			self.entPoolTable[templateId]:setActive(ClientConst.MODEL_VISIBLE_KEY.UIScene, true)

			return self.entPoolTable[templateId]
		else
			local ent = self:getSimpleEnt(templateId, petInfo)

			self.entPoolTable[templateId] = ent

			return ent
		end
	end
end

function PetManagementTrainingScene:getEntByTemplateId(templateId)
	if self.curShowPetTemplateId == templateId and self.mainEnt then
		return self.mainEnt
	end

	if self.entPoolTable then
		return self.entPoolTable[templateId]
	end

	return nil
end

function PetManagementTrainingScene:recycleEnt(templateId)
	if self.entPoolTable[templateId] then
		self.entPoolTable[templateId]:setActive(ClientConst.MODEL_VISIBLE_KEY.UIScene, false)
		self.entPoolTable[templateId].eModel:SetTransformParent(self.entPoolTransform)
	end
end

function PetManagementTrainingScene:loadSubScene(resId, parentTrans, nameNode)
	pg.global.resMgr:GetInstanceFromCacheByLua(resId, function(obj, userData)
		self.resLoadInst[#self.resLoadInst + 1] = obj

		obj.transform:SetParent(parentTrans, false)

		obj.transform.localPosition = Vector3.zero

		local ojr = obj.transform:GetComponent("ObjectReference")

		self[nameNode] = ojr:GetRefValue("name")

		if self.bgName then
			self[nameNode]:SetText(self.bgName)
		end
	end)
end

function PetManagementTrainingScene:refreshEntScale(ent, scale, eulerAngleVector3, position)
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

function PetManagementTrainingScene:refreshPetModelAppearance(templateId, ent, label, visible, pKey, gender, petInfo)
	ent = ent or self.mainEnt

	if not ent then
		return
	end

	local eModel = ent.eModel

	if eModel then
		local researchContentData = self:getResearchContentData(templateId)

		eModel.RootRotationScale = Vector3(0, 0, 0)

		local extraData = self:getPetPreviewExtraData(templateId, petInfo)

		extraData.label = extraData.label or label or 0
		extraData.gender = gender or researchContentData.gender or 0
		ent.modelNeedBones = true

		PetManagementDataHelper.refreshPetModelAppearance(ent, templateId, extraData)
		ent:setModelVisible(ClientConst.MODEL_VISIBLE_KEY.UIScene, visible)
		ent:setLodTickEnable(Const.LOD_TICK_KEY.DEFAULT, false)

		local shaderView = eModel.modelShaderView

		if shaderView then
			shaderView:SetMultiPassForce32Layer(true, ClientAbilityConst.MULTI_PASS_LAYER)
		end

		ent:addEModelMonoComponent(CommonConst.COMPONENT_IDX_PHYSX)

		local entCfg = ent:getConfigData()

		ent.eModel:GenCapsule(CommonConst.COMPONENT_IDX_PHYSX, entCfg.bodySize, entCfg.modelHeight, Vector3(0, entCfg.modelHeight / 2, 0), true, false)
		self:_refreshPetJewelryWhenReady(ent, extraData.realPetId)
	end
end

function PetManagementTrainingScene:_refreshPetJewelryWhenReady(ent, petId)
	ent.petJewelryRefreshRequest = nil

	if not petId or PetJewelryOssCache.isReady() then
		return
	end

	local request = {}
	local player = pg.me

	ent.petJewelryRefreshRequest = request

	PetJewelryOssCache.ensureLoaded(function()
		if ent.petJewelryRefreshRequest ~= request or ent.realPetId ~= petId or pg.me ~= player or ent.destroyed or ent._isDestroyingEntity or not ent.eModel then
			return
		end

		ent.petJewelryRefreshRequest = nil
		ent.tempJewelryInfo = player.petJewelryInfos[petId]

		ent:reloadAccessory()
	end)
end

function PetManagementTrainingScene:onDestroy()
	pg.global.uiMgr:ClearHandbookEvolveLine()

	for idx, res in ipairs(self.resLoadInst) do
		pg.global.resMgr:RemoveInstanceToCache(res, true)
	end

	self:destroyAllEnt()
	self:destroyModelView()
	self:clearSelectPetEvolve()
	pg.game.audio:playAmb(nil, AudioConst.BgmPriority.PetDetailScene)
end

function PetManagementTrainingScene:destroyModelView()
	for _, sceneViews in pairs(self.sceneTable) do
		for _, modelView in pairs(sceneViews) do
			modelView:Destroy()
		end
	end
end

function PetManagementTrainingScene:destroyAllEnt()
	for _, ent in pairs(self.entPoolTable) do
		ClientUtils.safeDestroy(ent)
	end
end

function PetManagementTrainingScene:setHandBookCameraVisible(visible)
	if IsNil(self.uiSceneCamera) or IsNil(self.uiSceneCamera.gameObject) then
		return false
	end

	self.uiSceneCamera.gameObject:SetActiveEx(visible)

	if visible then
		pg.global.cameraMgr:SetUISceneCamera(self.uiSceneCamera)
		pg.game.camera:setUICameraObject(self.uiSceneCamera)
		pg.game.camera:resetUICameraBlendStack()
	end

	return self.uiSceneCamera.gameObject.activeInHierarchy == visible
end

return PetManagementTrainingScene
