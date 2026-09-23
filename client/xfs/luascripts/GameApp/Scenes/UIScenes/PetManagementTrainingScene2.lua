-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\PetManagementTrainingScene2.lua

local ClientUtils = require("Utils.ClientUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("PetManagementTrainingScene2")
local PetProtoTypeData = require("Data.pet_prototype_data")
local AudioConst = require("Const.AudioConst")
local DoTweenAnimMgr = DoTweenAnimMgr
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
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local ClientSimpleVirtualEntity = require("Entities.ClientSimpleVirtualEntity")
local ClientVirtualEntityUtils = require("Utils.ClientVirtualEntityUtils")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local PlayableConst = require("Common.Const.PlayableConst")
local TimerManager = require("Core.Timer.TimerManager")
local ClientAbilityConst = require("Const.ClientAbilityConst")
local PetManagementTrainingScene2 = Class.LightClass("PetManagementTrainingScene2", UISceneBase)
local Time = require("Core.Common.Time")
local PetManagementUtils = require("Utils.PetManagementUtils")
local UIMirrorEntity = CS.FunPlus.WorldX.GUIS.Panels.UIMirrorEntity

PetManagementTrainingScene2.PAGE_ID = UIConst.HANDBOOK_PAGE_IDX
PetManagementTrainingScene2.UI_SELECT_MODEL = AddressDataConst.UI_SELECT_MODEL
PetManagementTrainingScene2.UI_SELECT_MODEL_2 = AddressDataConst.UI_SELECT_MODEL_2
PetManagementTrainingScene2.isShowNewStarUpVx = true
PetManagementTrainingScene2.APPLY_BODY_SIZE_SCALE = false

local STANDARD_PET_SIZE = 0.65
local STANDARD_PET_HEIGHT = 1.8
local ECAMERA_MODES = {
	VC_BIG = 3,
	VC_MID = 2,
	VC_SMALL = 1
}
local FLOWERS_COUNT = 6
local RING_VX_RES = AddressDataConst.RING_VX_RES
local SING_LEAF_SHADOW = AddressDataConst.SING_LEAF_SHADOW
local SINGLE_LEAF_FLOOR = AddressDataConst.SINGLE_LEAF_FLOOR
local SINGLE_LEAF_ENT = AddressDataConst.SINGLE_LEAF_ENT
local SINGLE_LEAF_V_ENT = AddressDataConst.SINGLE_LEAF_V_ENT
local SINGLE_LEAF_EFFECT = AddressDataConst.SINGLE_LEAF_EFFECT
local MULTI_L_LEAF_FLOOR = AddressDataConst.MULTI_L_LEAF_FLOOR
local MULTI_M_LEAF_FLOOR = AddressDataConst.MULTI_M_LEAF_FLOOR
local MULTI_L_LEAF_SHADOW = AddressDataConst.MULTI_L_LEAF_SHADOW
local MULTI_M_LEAF_SHADOW = AddressDataConst.MULTI_M_LEAF_SHADOW
local MULTI_L_LEAF_V_ENT = AddressDataConst.MULTI_L_LEAF_V_ENT
local MULTI_M_LEAF_V_ENT = AddressDataConst.MULTI_M_LEAF_V_ENT
local MULTI_L_LEAF_ENT = AddressDataConst.MULTI_L_LEAF_ENT
local MULTI_M_LEAF_ENT = AddressDataConst.MULTI_M_LEAF_ENT
local MULTI_L_LEAF_EFFECT = AddressDataConst.MULTI_L_LEAF_EFFECT
local MULTI_M_LEAF_EFFECT = AddressDataConst.MULTI_M_LEAF_EFFECT
local LEAF_LAYER_TYPE = {
	M_EFFECT = 11,
	L_EFFECT = 10,
	M_ENT = 9,
	L_ENT = 8,
	M_V_ENT = 7,
	L_V_ENT = 6,
	M_SHADOW = 5,
	L_SHADOW = 4,
	M_FLOOR = 3,
	L_FLOOR = 2,
	RING = 1
}
local LAYER_TYPE_STR = {
	[LEAF_LAYER_TYPE.RING] = "Ring",
	[LEAF_LAYER_TYPE.L_FLOOR] = "L_Floor",
	[LEAF_LAYER_TYPE.M_FLOOR] = "M_Floor",
	[LEAF_LAYER_TYPE.L_SHADOW] = "L_Shadow",
	[LEAF_LAYER_TYPE.M_SHADOW] = "M_Shadow",
	[LEAF_LAYER_TYPE.L_V_ENT] = "L_V_Ent",
	[LEAF_LAYER_TYPE.M_V_ENT] = "M_V_Ent",
	[LEAF_LAYER_TYPE.L_ENT] = "L_Ent",
	[LEAF_LAYER_TYPE.M_ENT] = "M_Ent",
	[LEAF_LAYER_TYPE.L_EFFECT] = "L_Effect",
	[LEAF_LAYER_TYPE.M_EFFECT] = "M_Effect"
}
local LITTLE_LEAF_RESMAP = {
	[LEAF_LAYER_TYPE.RING] = {
		RING_VX_RES,
		RING_VX_RES
	},
	[LEAF_LAYER_TYPE.L_FLOOR] = {
		SINGLE_LEAF_FLOOR,
		MULTI_L_LEAF_FLOOR
	},
	[LEAF_LAYER_TYPE.M_FLOOR] = {
		-1,
		MULTI_M_LEAF_FLOOR
	},
	[LEAF_LAYER_TYPE.L_SHADOW] = {
		SING_LEAF_SHADOW,
		MULTI_L_LEAF_SHADOW
	},
	[LEAF_LAYER_TYPE.M_SHADOW] = {
		-1,
		MULTI_M_LEAF_SHADOW
	},
	[LEAF_LAYER_TYPE.L_V_ENT] = {
		-1,
		MULTI_L_LEAF_V_ENT
	},
	[LEAF_LAYER_TYPE.M_V_ENT] = {
		-1,
		MULTI_M_LEAF_V_ENT
	},
	[LEAF_LAYER_TYPE.L_ENT] = {
		SINGLE_LEAF_ENT,
		MULTI_L_LEAF_ENT
	},
	[LEAF_LAYER_TYPE.M_ENT] = {
		-1,
		MULTI_M_LEAF_ENT
	},
	[LEAF_LAYER_TYPE.L_EFFECT] = {
		-1,
		-1
	},
	[LEAF_LAYER_TYPE.M_EFFECT] = {
		-1,
		-1
	}
}
local NEW_STARUP_VX_RES = AddressDataConst.NEW_STARUP_VX_RES
local STARUP_VX_HIGH_RES = AddressDataConst.STARUP_VX_HIGH_RES
local STARUP_VX_LOW_RES = AddressDataConst.STARUP_VX_LOW_RES
local STARUP_VX_LOOP_RES = AddressDataConst.STARUP_VX_LOOP_RES
local STARUP_VX_GRADE = 2

PetManagementTrainingScene2.ActionCfg = {
	SURVEY = "showAnimation",
	EVOLUTION = "showAnimationEvolve",
	ABILITY = "showAnimationAbility",
	TOPIC = "showAnimationTask"
}

function PetManagementTrainingScene2:getActionCfg(pageId)
	local pageIds = PetManagementTrainingScene2.PAGE_ID
	local actionCfg = self.ActionCfg or PetManagementTrainingScene2.ActionCfg

	if not pageIds or not actionCfg then
		return nil
	end

	if pageId == pageIds.SURVEY then
		return actionCfg.SURVEY
	elseif pageId == pageIds.ABILITY then
		return actionCfg.ABILITY
	elseif pageId == pageIds.EVOLUTION then
		return actionCfg.EVOLUTION
	elseif pageId == pageIds.TOPIC then
		return actionCfg.TOPIC
	end

	return nil
end

function PetManagementTrainingScene2:getSimpleEnt(petInfo)
	local templateId = petInfo and petInfo.templateId

	if not templateId then
		return
	end

	local configData = ClientVirtualEntityUtils.getPetUISceneConfig(templateId)
	local ent = ClientSimpleVirtualEntity.new()

	ent:setConfigData(configData)

	local initInfo = {
		isIgnoreEffectLod = true,
		templateId = templateId,
		label = petInfo.label,
		shinyStyle = petInfo.shinyStyle,
		gender = petInfo.gender
	}

	ent:init(initInfo)
	ent:postInit(initInfo)
	ent:start()
	ent:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)

	return ent
end

function PetManagementTrainingScene2:onStart()
	self.rootTransform = self.scene.transform:Find("Root")
	self.objectReference = self.rootTransform:GetComponent("ObjectReference")
	self.uICameraCamera = self.objectReference:GetRefValue("uICameraCamera")
	self.storyboard01Transform = self.objectReference:GetRefValue("storyboard01Transform")
	self.storyboard02Transform = self.objectReference:GetRefValue("storyboard02Transform")
	self.storyboard03Transform = self.objectReference:GetRefValue("storyboard03Transform")
	self.evolutionPos = self.objectReference:GetRefValue("EvolutionPos")
	self.entPoolTransform = self.objectReference:GetRefValue("entPoolTransform")
	self.petsParentTransform = self.objectReference:GetRefValue("petsParentTransform")
	self.mirrorPetsParentTransform = self.objectReference:GetRefValue("mirrorPetsParentTransform")
	self.trainingCameraTransform = self.objectReference:GetRefValue("trainingCameraTransform")
	self.starUpCameraTransform = self.objectReference:GetRefValue("starUpCameraTransform")
	self.loadFlowersRootTransform = self.objectReference:GetRefValue("loadFlowersRootTransform")

	self:init()
	pg.global.cameraMgr:SetUISceneCamera(self.uICameraCamera)
	pg.game.camera:setUICameraObject(self.uICameraCamera)

	self.m_sceneCreated = true
end

function PetManagementTrainingScene2:isCreated()
	return self.m_sceneCreated
end

function PetManagementTrainingScene2:onDestroy()
	self:destroyAllEnt()
	self:clearSelectPetEvolve()
	self:removeTranslateFlowersTimers()
	pg.game.audio:playAmb(nil, AudioConst.BgmPriority.PetDetailScene)

	self.tabShowTsList = nil
	self.tabShowFlowerLayer = nil
	self.tabFastShowTsList = nil
	self.tabCameraTrans = nil
	self.tabCheckShowTsList = nil
	self.loadFlowerTsList = nil
	self.loadFlowerLeafTsMap = nil
	self.loadFlowerEffectTsList = nil

	if self.delayTimerSetLoopEffect then
		TimerManager.removeTimer(self.delayTimerSetLoopEffect)

		self.delayTimerSetLoopEffect = nil
	end

	if self.m_delayHideStarupVfxTimer then
		TimerManager.removeTimer(self.m_delayHideStarupVfxTimer)

		self.m_delayHideStarupVfxTimer = nil
	end
end

function PetManagementTrainingScene2:destroyAllEnt()
	for _, ent in pairs(self.entPoolTable) do
		ClientUtils.safeDestroy(ent)
	end

	for _, ent in pairs(self.mirrorEntPoolTable) do
		ClientUtils.safeDestroy(ent)
	end

	self.m_CoupleCacheMap = {}
end

function PetManagementTrainingScene2:init()
	self.posY = 500
	self.outPos = Vector3(0, 9999, 0)
	self.centerPos = Vector3(0, self.posY, 0)
	self.scene.transform.position = self.centerPos
	self.entPoolTable = {}
	self.mirrorEntPoolTable = {}
	self.evolutionShowEntIds = {}
	self.cameraGoDict = {}
	self.cameraPosDict = {}
	self.flowersPos = Vector3(0, 0.013, 0)

	local tabCameraTrans = {
		[Const.PetCulPages.TALENT] = self.trainingCameraTransform,
		[Const.PetCulPages.STARUP] = self.starUpCameraTransform,
		[Const.PetCulPages.CARRY] = self.trainingCameraTransform
	}

	self.starupRingTs = self.rootTransform:Find("ArtAssets/Eff_UI_LVUIPet_BackGround_scene")
	self.tabShowTsList = {
		[self.storyboard01Transform] = {
			Const.PetCulPages.TALENT,
			Const.PetCulPages.CARRY
		},
		[self.storyboard02Transform] = {
			Const.PetCulPages.STARUP
		},
		[self.starupRingTs] = {
			Const.PetCulPages.STARUP
		},
		[self.mirrorPetsParentTransform] = {
			Const.PetCulPages.STARUP,
			Const.PetCulPages.TALENT
		}
	}

	for t, _ in pairs(self.tabShowTsList) do
		if NotNil(t) and NotNil(t.transform) then
			local eComps = {}

			table.insert(eComps, t.transform:GetComponent("EffectLevelSetting"))

			for i = 0, t.childCount - 1 do
				local childT = t:GetChild(i)

				if childT then
					table.insert(eComps, childT.transform:GetComponent("EffectLevelSetting"))
				end
			end

			for _, comp in ipairs(eComps) do
				if NotNil(comp) then
					comp:IgnoreUnLoad()
					comp:SetEnableUpdate(false)
				end
			end
		end
	end

	self.tabFastShowTsList = {
		[self.loadFlowersRootTransform] = {
			Const.PetCulPages.STARUP
		}
	}
	self.tabCheckShowTsList = {
		[self.storyboard03Transform] = {
			showTabId = Const.PetCulPages.STARUP,
			tryShowFunc = function()
				self:m_checkShowStoryboard03()
			end
		}
	}

	local cameraNames = {
		"VCameraSmall",
		"VCameraMid",
		"VCameraBig"
	}

	for pid, trans in pairs(tabCameraTrans) do
		for vcModeId, cName in ipairs(cameraNames) do
			local vc = trans:Find(cName):GetComponent("RefVirtualCameraBehavior")
			local vcKey = self:m_contactVCameraKey(pid, vcModeId)

			self.cameraGoDict[vcKey] = vc.gameObject

			function vc.luaFinishBlend()
				self:cameraBlendFinishCb()
			end

			self.cameraGoDict[vcKey]:SetActiveEx(false)

			self.cameraPosDict[vcKey] = vc.transform.localPosition
		end
	end

	self.loadFlowerTsList = {}
	self.loadFlowerLeafTsMap = {}
	self.loadFlowerEffectTsList = {}

	if self.loadFlowersRootTransform then
		for i = 1, FLOWERS_COUNT do
			local flowerTrans = self.loadFlowersRootTransform:Find("F" .. i)

			table.insert(self.loadFlowerTsList, flowerTrans)
			table.insert(self.loadFlowerLeafTsMap, {})
		end
	end

	self.m_initLoadFlowersPos = self.loadFlowersRootTransform.localPosition
end

function PetManagementTrainingScene2:m_contactVCameraKey(tabId, cameraModeId)
	return string.format("%s_%s", tabId, cameraModeId)
end

function PetManagementTrainingScene2:m_parseVCameraKey(keyStr)
	local splitIndex = string.find(keyStr, "_")

	if not splitIndex then
		return nil, nil
	end

	local tabId = string.sub(keyStr, 1, splitIndex - 1)
	local cameraName = string.sub(keyStr, splitIndex + 1)

	tabId = tabId ~= "" and tabId or nil
	cameraName = cameraName ~= "" and cameraName or nil

	return tabId, cameraName
end

function PetManagementTrainingScene2:cameraBlendFinishCb()
	if self.pageCb then
		self.pageCb()
	end
end

function PetManagementTrainingScene2:setSceneTabId(tabId)
	if self.selectedTabId == tabId then
		return
	end

	self.selectedTabId = tabId

	for showTs, showTabIds in pairs(self.tabShowTsList) do
		showTs.gameObject:SetActiveEx(table.contains(showTabIds, self.selectedTabId))
	end

	for showTs, fastShowTabIds in pairs(self.tabFastShowTsList) do
		local isShow = table.contains(fastShowTabIds, self.selectedTabId)

		showTs.localScale = isShow and Vector3.one or Vector3.zero
	end

	if self.selectedTabId ~= Const.PetCulPages.STARUP then
		self:setLoopEffect()
	end

	self:tryMoveCameraToTarget()
end

function PetManagementTrainingScene2:clearUpdateTimer()
	if self.updateTimer then
		TimerManager.removeTimer(self.updateTimer)
	end

	self.updateTimer = nil
end

function PetManagementTrainingScene2:getEntById(petInfo)
	local petId = petInfo and petInfo.id

	if petId then
		if self.entPoolTable[petId] then
			return self.entPoolTable[petId], false
		else
			local ent = self:getSimpleEnt(petInfo)

			self.entPoolTable[petId] = ent

			return ent, true
		end
	end
end

function PetManagementTrainingScene2:getMirrorEntById(petInfo)
	local petId = petInfo and petInfo.id

	if petId then
		if self.mirrorEntPoolTable[petId] then
			return self.mirrorEntPoolTable[petId], false
		else
			local ent = self:getSimpleEnt(petInfo)

			self.mirrorEntPoolTable[petId] = ent

			return ent, true
		end
	end
end

function PetManagementTrainingScene2:refreshPetModelAppearance(ent, petInfo, modelNeedBones)
	if not ent or not petInfo then
		return
	end

	local eModel = ent.eModel

	if eModel then
		local templateId = petInfo.templateId
		local researchContentData = PetResearchUtils.getPetResearchContent(templateId)

		eModel.RootRotationScale = Vector3(0, 0, 0)

		PetManagementDataHelper.refreshPetModelAppearance(ent, templateId, {
			canAttachEffs = false,
			applyAnimController = true,
			configData = ClientVirtualEntityUtils.getPetUISceneConfig(templateId),
			petInfo = petInfo,
			gender = petInfo.gender or researchContentData.gender or 0,
			transmogPetId = petInfo.id,
			modelNeedBones = ToBool(modelNeedBones)
		})

		local shaderView = eModel.modelShaderView

		if shaderView then
			shaderView:SetMultiPassForce32Layer(true, ClientAbilityConst.MULTI_PASS_LAYER)
		end

		ent:setLodTickEnable(Const.LOD_TICK_KEY.DEFAULT, false)
		ent:setRendererLod(0)
	end
end

function PetManagementTrainingScene2:selectPetEvolve(petId)
	local ent = self.entPoolTable[petId]

	if ent then
		local eModel = ent.eModel
		local shaderView = eModel.modelShaderView

		self:clearSelectPetEvolve()

		if shaderView then
			shaderView:ChangeEffectMaterial({
				PetManagementTrainingScene2.UI_SELECT_MODEL,
				PetManagementTrainingScene2.UI_SELECT_MODEL_2
			})

			self.selectedEnt = ent
		end
	end
end

function PetManagementTrainingScene2:selectMirrorPetEvolve(petId)
	local ent = self.mirrorEntPoolTable[petId]

	if ent then
		local eModel = ent.eModel
		local shaderView = eModel.modelShaderView

		self:clearSelectPetEvolve()

		if shaderView then
			shaderView:ChangeEffectMaterial({
				PetManagementTrainingScene2.UI_SELECT_MODEL,
				PetManagementTrainingScene2.UI_SELECT_MODEL_2
			})

			self.selectedEnt = ent
		end
	end
end

function PetManagementTrainingScene2:clearSelectPetEvolve()
	if self.selectedEnt then
		local eModel = self.selectedEnt.eModel
		local shaderView = eModel and eModel.modelShaderView

		if shaderView then
			shaderView:ResetMaterial()
		end
	end

	self.selectedEnt = nil
end

function PetManagementTrainingScene2:getPetModelLocalScale(petInfo)
	if not PetManagementTrainingScene2.APPLY_BODY_SIZE_SCALE then
		return 1
	end

	return petInfo and petInfo.bornScale or 1
end

function PetManagementTrainingScene2:setSceneDisplayPet(petId, tabId)
	self.evolutionPetDict = {}

	local petInfo = pg.me:getPetInfo(petId)

	self.curShowPetTemplateId = petInfo.templateId
	self.curShowPetEntId = petInfo.id
	self.petId = petId
	self.selectedTabId = tabId

	self:recycleOtherEnts()
	self:setPetTransform()
	self:tryMoveCameraToTarget()
end

function PetManagementTrainingScene2:setPetTransform()
	local petInfo = pg.me:getPetInfo(self.curShowPetEntId)

	if not petInfo then
		return
	end

	local ent = self:getEntById(petInfo)
	local eModel = ent and ent.eModel

	if eModel then
		self:selectPetEvolve(petInfo.id)

		local modelLocalScale = self:getPetModelLocalScale(petInfo)

		self:refreshPetModelAppearance(ent, petInfo, true)
		eModel:SetTransformParent(self.petsParentTransform, false)
		eModel:SetTransformLocalPosition()
		eModel:SetTransformLocalRotation(0, 0, 0, 1)
		eModel:SetTransformLocalScale(modelLocalScale, modelLocalScale, modelLocalScale)
		eModel:PlayDefaultAnimation(Const.COMPONENT_IDX_PLAYABLE, true)

		local originModelView = eModel and eModel.modelModelView

		if originModelView then
			function originModelView.luaOnModelRefreshFinshed()
				self:m_tryAddCoupleEntities()
			end
		end

		self:setPetActive(ent, true)
	end

	local mirrorEnt = self:getMirrorEntById(petInfo)
	local mirrorEModel = mirrorEnt and mirrorEnt.eModel

	if mirrorEModel then
		self:selectMirrorPetEvolve(petInfo.id)

		local modelLocalScale = self:getPetModelLocalScale(petInfo)

		if mirrorEnt.hasEModelComponent and mirrorEnt:hasEModelComponent(Const.COMPONENT_INDEX_EFFECT) then
			mirrorEModel:SetMirrorEffectTransform(Const.COMPONENT_INDEX_EFFECT, true)
		end

		self:refreshPetModelAppearance(mirrorEnt, petInfo, true)
		mirrorEModel:SetTransformParent(self.mirrorPetsParentTransform, false)
		mirrorEModel:SetTransformLocalPosition()
		mirrorEModel:SetTransformLocalRotation(0, 0, 0, 1)
		mirrorEModel:SetTransformLocalScale(modelLocalScale, modelLocalScale, modelLocalScale)
		mirrorEModel:PlayDefaultAnimation(Const.COMPONENT_IDX_PLAYABLE, true)

		local mirrorModelView = mirrorEModel and mirrorEModel.modelModelView

		if mirrorModelView then
			function mirrorModelView.luaOnModelRefreshFinshed()
				self:m_tryAddCoupleEntities()
			end
		end

		self:setPetActive(mirrorEnt, true)
	end

	self:m_tryAddCoupleEntities()
end

function PetManagementTrainingScene2:m_tryAddCoupleEntities()
	local isReady = false

	self.m_CoupleCacheMap = self.m_CoupleCacheMap or {}

	for k, v in pairs(self.entPoolTable) do
		if v and not self.m_CoupleCacheMap[k] then
			local mirrorEnt = self.mirrorEntPoolTable and self.mirrorEntPoolTable[k]

			if mirrorEnt then
				local oSkt = v.eModel and v.eModel.modelSkeletonView and v.eModel.modelSkeletonView.skeletonRoot
				local mSkt = mirrorEnt.eModel and mirrorEnt.eModel.modelSkeletonView and mirrorEnt.eModel.modelSkeletonView.skeletonRoot

				if oSkt and mSkt then
					UIMirrorEntity.Create(mirrorEnt.eModel.animator, v.eModel.animator)

					self.m_CoupleCacheMap = self.m_CoupleCacheMap or {}
					self.m_CoupleCacheMap[k] = true
				end
			end
		end
	end
end

function PetManagementTrainingScene2:setPetRootActive(isActive)
	local localPos = isActive and Vector3(0.048, 0, 0.096) or self.outPos

	self.petsParentTransform.localPosition = localPos
	self.mirrorPetsParentTransform.localPosition = localPos
end

function PetManagementTrainingScene2:setPetActive(petEnt, isActive)
	if petEnt and petEnt.eModel then
		petEnt:setModelVisible(ClientConst.MODEL_VISIBLE_KEY.UIScene, isActive)

		if isActive then
			petEnt.eModel:SetTransformLocalPosition()
		else
			petEnt.eModel:SetTransformLocalPosition(self.outPos.x, self.outPos.y, self.outPos.z)
		end
	end
end

function PetManagementTrainingScene2:getPetTargetScale(templateId)
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

function PetManagementTrainingScene2:recycleOtherEnts()
	for k, v in pairs(self.entPoolTable) do
		if v and k ~= self.curShowPetEntId then
			v.eModel:SetTransformLocalScale(0, 0, 0)
			self:setPetActive(v, false)
		end
	end

	for k, v in pairs(self.mirrorEntPoolTable) do
		if v and k ~= self.curShowPetEntId then
			v.eModel:SetTransformLocalScale(0, 0, 0)
			self:setPetActive(v, false)
		end
	end
end

function PetManagementTrainingScene2:tryMoveCameraToTarget()
	if not self.selectedTabId or not self.curShowPetTemplateId then
		self:m_onCameraPosMoveEnd()

		return
	end

	local cameraModeId = PetPrototypeData[self.curShowPetTemplateId].cameraDistModeId or 1
	local vcKey = self:m_contactVCameraKey(self.selectedTabId, cameraModeId)
	local vcCamera = self.cameraGoDict[vcKey]

	if self.curVCamera ~= vcCamera then
		if self.curVCamera then
			self.curVCamera:SetActiveEx(false)
		end

		self.curVCamera = vcCamera
		self.curVCameraKey = vcKey

		if self.curVCamera then
			self.curVCamera:SetActiveEx(true)
		end
	end

	self:moveCameraPosToTarget()
end

function PetManagementTrainingScene2:moveCameraPosToTarget()
	if not self.curVCamera or not self.curVCameraKey then
		return
	end

	local originPos = self.cameraPosDict[self.curVCameraKey]
	local targetPos = Vector3(originPos.x, originPos.y, originPos.z)
	local tweenId = LuaUIUtils.TweenId("moveCameraPos" .. self.curVCameraKey)

	DoTweenAnimMgr.Kill(self.curVCamera, tweenId, true)
	DoTweenAnimMgr.Move(self.curVCamera.transform, tweenId, targetPos, 0.2, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
		self:m_onCameraPosMoveEnd()
	end)
end

function PetManagementTrainingScene2:m_onCameraPosMoveEnd()
	if PetManagementTrainingScene2.isShowNewStarUpVx then
		self:tryRefreshFlowersByStarUp()
	elseif not self.m_flowersLoaded then
		self:loadFlowers()
	else
		self:tryRefreshFlowersByStarUp()
	end

	self:m_refreshCheckShowEnvs()
end

function PetManagementTrainingScene2:m_refreshCheckShowEnvs()
	for showTs, checkInfo in pairs(self.tabCheckShowTsList) do
		if checkInfo.showTabId == self.selectedTabId then
			checkInfo.tryShowFunc()
		else
			showTs.gameObject:SetActiveEx(false)
		end
	end
end

function PetManagementTrainingScene2:playPetEvolveAction()
	local templateId = self.curShowPetTemplateId
	local petId = self.curShowPetEntId

	if not templateId or not petId then
		return
	end

	local ent = self.entPoolTable[petId]

	if ent then
		local curResearchContent = PetResearchUtils.getPetResearchContent(templateId)
		local cfgAction = self:getActionCfg(PetManagementTrainingScene2.PAGE_ID.EVOLUTION)

		ent:showEffect()

		if curResearchContent and cfgAction and curResearchContent[cfgAction] then
			self:playPetPhaseAction(ent, curResearchContent[cfgAction])
		end
	end

	local mEnt = self.mirrorEntPoolTable[petId]

	if mEnt then
		local curResearchContent = PetResearchUtils.getPetResearchContent(templateId)
		local cfgAction = self:getActionCfg(PetManagementTrainingScene2.PAGE_ID.EVOLUTION)

		mEnt:showEffect()

		if curResearchContent and cfgAction and curResearchContent[cfgAction] then
			self:playPetPhaseAction(mEnt, curResearchContent[cfgAction])
		end
	end
end

function PetManagementTrainingScene2:playPetPhaseAction(ent, cfg, cb)
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

local EaseType = {
	Linear = 1,
	EaseInOut = 2
}
local TranslationFlowersDuraionMS = 500

function PetManagementTrainingScene2:GetEaseProgress(easeType, t)
	if easeType == EaseType.Linear then
		return math.clamp(t, 0, 1)
	elseif easeType == EaseType.EaseInOut then
		return math.clamp(math.sin(t * math.pi - math.pi / 2) / 2 + 0.5, 0, 1)
	end

	return math.clamp(t, 0, 1)
end

function PetManagementTrainingScene2:removeTranslateFlowersTimers()
	TimerManager.removeTimer(self.m_translationFlowersFinishTimer)
	TimerManager.removeTimer(self.m_translationFlowersLoopTimer)

	self.m_translationFlowersFinishTimer = nil
	self.m_translationFlowersLoopTimer = nil
end

function PetManagementTrainingScene2:MoveFlowerTransforms(tsList, duration, easeType)
	if not tsList or #tsList < 2 then
		return
	end

	if self.m_translationFlowersFinishTimer then
		return
	end

	duration = TranslationFlowersDuraionMS or 1000
	easeType = easeType or EaseType.Linear

	local initPosList = {}
	local targetPosList = {}
	local tsCount = #tsList

	for i = 1, tsCount do
		initPosList[i] = tsList[i].position

		local targetIdx = i % tsCount + 1

		targetPosList[i] = tsList[targetIdx].position
	end

	self.m_translationFlowersElapsedMS = Time.realSecondCache * 1000
	self.m_translationFlowersFinishTimer = TimerManager.addTimer(duration / Const.MILLISECOND_ONE_SECOND, function()
		self.m_translationFlowersFinishTimer = nil

		TimerManager.removeTimer(self.m_translationFlowersLoopTimer)
	end)
	self.m_translationFlowersLoopTimer = TimerManager.addRepeatTimer(0.01, function()
		local elapsedTime = Time.realSecondCache * 1000 - self.m_translationFlowersElapsedMS
		local progress = elapsedTime / duration
		local easeProgress = self:GetEaseProgress(easeType, progress)

		for i = 1, tsCount do
			local newPos = Vector3.Lerp(initPosList[i], targetPosList[i], easeProgress)

			tsList[i].position = newPos
		end

		if progress >= 1 then
			for i = 1, tsCount do
				tsList[i].position = targetPosList[i]
			end

			self:removeTranslateFlowersTimers()
		end
	end)
end

function PetManagementTrainingScene2:m_getLeafObjCnt(flowerIndex, layerType)
	if layerType == LEAF_LAYER_TYPE.RING then
		return 1
	end

	return flowerIndex
end

function PetManagementTrainingScene2:loadFlowers()
	if not self.m_sceneCreated then
		return
	end

	if self.m_flowersLoaded then
		return
	end

	self.m_preLoadFlowerLeafTsRecord = self.m_preLoadFlowerLeafTsRecord or {}

	for flowerIndex = 1, FLOWERS_COUNT do
		local leafLayers = #LAYER_TYPE_STR

		for layerIndex = 1, leafLayers do
			local layerType = layerIndex
			local leafObjCnt = self:m_getLeafObjCnt(flowerIndex, layerType)

			for leafIndex = 1, leafObjCnt do
				local unitKey = self:m_getLeafKey(flowerIndex, leafIndex, layerType)

				if self.m_preLoadFlowerLeafTsRecord[unitKey] then
					break
				end

				local resUrls = LITTLE_LEAF_RESMAP[layerType]
				local resUrl
				local lastFix = ""

				if flowerIndex == 1 then
					resUrl = resUrls and resUrls[1] or nil
				else
					resUrl = resUrls and resUrls[2] or nil

					if layerType ~= LEAF_LAYER_TYPE.RING then
						lastFix = tostring(flowerIndex - 1) or nil
					end
				end

				if not resUrl or resUrl == -1 then
					break
				end

				if resUrl and resUrl ~= "" then
					if not string.find(resUrl, ".prefab") then
						resUrl = string.format(resUrl, lastFix)
						resUrl = resUrl .. ".prefab"
					end

					self.loadFlowerLeafTsMap = self.loadFlowerLeafTsMap or {}
					self.loadFlowerLeafTsMap[flowerIndex] = self.loadFlowerLeafTsMap[flowerIndex] or {}
					self.loadFlowerLeafTsMap[flowerIndex][leafIndex] = self.loadFlowerLeafTsMap[flowerIndex][leafIndex] or {}
					self.loadFlowerLeafTsMap[flowerIndex][leafIndex][layerType] = -1

					pg.global.resMgr:GetInstanceFromCacheByLua(resUrl, function(obj, userData)
						self:m_addLeafObj(obj, userData)
					end, 1, {
						flowerIndex = flowerIndex,
						leafIndex = leafIndex,
						layerType = layerType
					})
				end

				self.m_preLoadFlowerLeafTsRecord[unitKey] = self.m_preLoadFlowerLeafTsRecord[unitKey] or {}
			end
		end
	end
end

function PetManagementTrainingScene2:m_addLeafObj(obj, userData)
	local leafObjc = obj

	if not leafObjc then
		return
	end

	if not leafObjc.transform then
		return
	end

	local effectLevelSetComop = leafObjc.transform:GetComponent("EffectLevelSetting")

	if effectLevelSetComop then
		effectLevelSetComop:IgnoreUnLoad()
		effectLevelSetComop:SetEnableUpdate(false)
	end

	local flowerIndex = userData.flowerIndex

	if not flowerIndex then
		return
	end

	local leafIndex = userData.leafIndex

	if not leafIndex then
		return
	end

	local layerType = userData.layerType

	if not layerType then
		return
	end

	local leafParentT = self.loadFlowerTsList and self.loadFlowerTsList[flowerIndex]

	if not leafParentT then
		return
	end

	local yAngle = 0

	if flowerIndex <= 1 then
		if layerType == LEAF_LAYER_TYPE.L_ENT or layerType == LEAF_LAYER_TYPE.M_ENT or layerType == LEAF_LAYER_TYPE.L_EFFECT or layerType == LEAF_LAYER_TYPE.M_EFFECT or layerType == LEAF_LAYER_TYPE.L_V_ENT or layerType == LEAF_LAYER_TYPE.M_V_ENT then
			yAngle = 45
		end
	else
		local averageAngle = 360 / flowerIndex

		yAngle = averageAngle * (leafIndex - 1)
	end

	leafObjc.transform:SetParent(leafParentT, false)

	local pos = layerType > LEAF_LAYER_TYPE.M_SHADOW and self.flowersPos or Vector3.zero

	leafObjc.transform.localPosition = pos
	leafObjc.transform.localScale = Vector3.one
	leafObjc.transform.localRotation = Quaternion.Euler(0, yAngle, 0)

	LuaUIUtils.safeSetGoLayer(leafObjc, ClientConst.LayerDefine.LAYER_UI_SCENE)
	leafObjc:SetActiveEx(false)

	self.loadFlowerLeafTsMap = self.loadFlowerLeafTsMap or {}
	self.loadFlowerLeafTsMap[flowerIndex] = self.loadFlowerLeafTsMap[flowerIndex] or {}
	self.loadFlowerLeafTsMap[flowerIndex][leafIndex] = self.loadFlowerLeafTsMap[flowerIndex][leafIndex] or {}
	self.loadFlowerLeafTsMap[flowerIndex][leafIndex][layerType] = leafObjc.transform
	leafObjc.transform.gameObject.name = "layer " .. LAYER_TYPE_STR[layerType] .. "_" .. self:m_getLeafKey(flowerIndex, leafIndex, layerType)

	self:m_checkFlowersLoaded()
	self:tryRefreshFlowersByStarUp()
end

function PetManagementTrainingScene2:m_checkFlowersLoaded()
	if self.m_flowersLoaded then
		return
	end

	for flowerIndex = 1, FLOWERS_COUNT do
		local leafLayers = #LAYER_TYPE_STR

		for layerIndex = 1, leafLayers do
			local layerType = layerIndex
			local leafObjCnt = self:m_getLeafObjCnt(flowerIndex, layerType)

			for leafIndex = 1, leafObjCnt do
				local resUrls = LITTLE_LEAF_RESMAP[layerType]
				local resUrl
				local lastFix = ""

				if flowerIndex == 1 then
					resUrl = resUrls and resUrls[1] or nil
				else
					resUrl = resUrls and resUrls[2] or nil
				end

				if not resUrl or resUrl == -1 then
					break
				end

				self.loadFlowerLeafTsMap = self.loadFlowerLeafTsMap or {}
				self.loadFlowerLeafTsMap[flowerIndex] = self.loadFlowerLeafTsMap[flowerIndex] or {}
				self.loadFlowerLeafTsMap[flowerIndex][leafIndex] = self.loadFlowerLeafTsMap[flowerIndex][leafIndex] or {}

				local loadedTs = self.loadFlowerLeafTsMap[flowerIndex][leafIndex][layerType]

				if not loadedTs or loadedTs == -1 then
					return
				end
			end
		end
	end

	self.m_flowersLoaded = true

	for flowerIndex = 1, FLOWERS_COUNT do
		self:tryResetFlowersLeafSibling(flowerIndex)
	end

	if LoggerManager.checkLogger(LoggerConst.WARN) then
		logger:warn("PetManagementTrainingScene2:m_checkFlowersLoaded, flowers loaded !!! ")
	end
end

function PetManagementTrainingScene2:m_getLeafKey(flowerIndex, leafIndex, layerType)
	return string.format("%d_%d_%d", flowerIndex, layerType, leafIndex)
end

function PetManagementTrainingScene2:tryResetFlowersLeafSibling(flowerIndex)
	local leafParentT = self.loadFlowerTsList and self.loadFlowerTsList[flowerIndex]

	if not leafParentT then
		return
	end

	local leafTsList = {}

	if self.loadFlowerLeafTsMap[flowerIndex] then
		for leafIndex = 1, #self.loadFlowerLeafTsMap[flowerIndex] do
			local leafObjs = self.loadFlowerLeafTsMap[flowerIndex][leafIndex]

			if leafObjs then
				for layerType, leafObjc in pairs(leafObjs) do
					if leafObjc then
						leafTsList[#leafTsList + 1] = {
							key = self:m_getLeafKey(flowerIndex, leafIndex, layerType),
							value = leafObjc
						}
					end
				end
			end
		end
	end

	if not leafTsList or #leafTsList <= 0 then
		return
	end

	table.sort(leafTsList, function(a, b)
		return a.key < b.key
	end)

	for siblingIndex, leafTs in ipairs(leafTsList) do
		if leafTs.value then
			leafTs.value:SetSiblingIndex(siblingIndex)
		end
	end
end

function PetManagementTrainingScene2:m_getLeafObjTransform(flowerIndex, leafIndex, layerType)
	if not self.loadFlowerLeafTsMap then
		return nil
	end

	local leafTsList = self.loadFlowerLeafTsMap[flowerIndex]

	if not leafTsList then
		return nil
	end

	local leafObjc = leafTsList[leafIndex]

	if not leafObjc then
		return nil
	end

	return leafObjc[layerType]
end

function PetManagementTrainingScene2:tryResetFlowersByStarUp()
	if self.selectedTabId ~= Const.PetCulPages.STARUP then
		self.loadFlowersRootTransform.localScale = Vector3.zero
		self.loadFlowersRootTransform.localPosition = Vector3(self.m_initLoadFlowersPos.x, -999999, self.m_initLoadFlowersPos.z)

		return true
	end

	return false
end

function PetManagementTrainingScene2:tryRefreshFlowersByStarUp()
	if self:tryResetFlowersByStarUp() then
		return
	end

	if not self.curShowPetEntId then
		return
	end

	if not self.m_flowersLoaded then
		return
	end

	self:refreshFlowersByStarUp(self.curShowPetEntId)
end

function PetManagementTrainingScene2:refreshFlowersByStarUp(petId, msg)
	if not petId then
		return
	end

	local curStage, curLv = PetManagementUtils.getPetCurStarSLv(petId)

	if not curStage or not curLv then
		return
	end

	local isUpVx = msg ~= nil
	local isBreakStage = isUpVx and curStage == 1 and curLv == 1 or isUpVx and curLv <= 0
	local isResonanceMaxed = PetManagementUtils.isMaxedResonance(curStage, curLv)
	local curStageMaxLv = PetManagementUtils.getResonanceStageMaxLv(curStage)

	if PetManagementTrainingScene2.isShowNewStarUpVx then
		if isUpVx then
			if self.m_delayHideStarupVfxTimer then
				TimerManager.removeTimer(self.m_delayHideStarupVfxTimer)

				self.m_delayHideStarupVfxTimer = nil
			end

			if NotNil(self.m_newStarUpVxGo) then
				self.m_newStarUpVxGo:SetActiveEx(false)
			end

			TimerManager.addTimer(0.01, function()
				self:m_refreshCheckShowEnvs()

				if NotNil(self.m_newStarUpVxGo) then
					self.m_newStarUpVxGo:SetActiveEx(true)

					return
				end

				pg.global.resMgr:GetInstanceFromCacheByLua(NEW_STARUP_VX_RES, function(obj, userData)
					if not self.m_sceneCreated or not obj or not obj.transform then
						return
					end

					local effectLevelSetComop = obj.transform:GetComponent("EffectLevelSetting")

					if effectLevelSetComop then
						effectLevelSetComop:IgnoreUnLoad()
						effectLevelSetComop:SetEnableUpdate(false)
					end

					LuaUIUtils.safeSetGoLayer(obj.transform.gameObject, ClientConst.LayerDefine.LAYER_UI_SCENE)
					obj.transform:SetParent(self.petsParentTransform, false)

					obj.transform.localPosition = self.flowersPos
					obj.transform.localRotation = Quaternion.Euler(0, 0, 0)
					obj.transform.localScale = Vector3.one
					self.m_newStarUpVxGo = obj.transform.gameObject
				end, 1)

				self.m_delayHideStarupVfxTimer = TimerManager.addTimer(1.5, function()
					if NotNil(self.m_newStarUpVxGo) then
						self.m_newStarUpVxGo:SetActiveEx(false)
					end
				end)
			end)
		end

		return
	end

	self.loadFlowersRootTransform.localScale = Vector3.one
	self.loadFlowersRootTransform.localPosition = Vector3(self.m_initLoadFlowersPos.x, self.m_initLoadFlowersPos.y, self.m_initLoadFlowersPos.z)

	local recordShowRingTsList = {}

	for stageIndex = 1, #(self.loadFlowerLeafTsMap or {}) do
		local leafTsList = self.loadFlowerLeafTsMap[stageIndex]

		if leafTsList then
			for level = 1, #leafTsList do
				local leafKindObjTsList = leafTsList[level]

				if leafKindObjTsList then
					for layerType = 1, #leafKindObjTsList do
						local leafObjc = leafKindObjTsList[layerType]

						if NotNil(leafObjc) then
							local isShow = isResonanceMaxed
							local isFirstFlower = stageIndex == 1
							local isUnlockFirstFlower = stageIndex == 1 and (curStage > 1 or curLv > 0)

							if layerType == LEAF_LAYER_TYPE.RING then
								isShow = isFirstFlower and isUnlockFirstFlower or not isFirstFlower and stageIndex < curStage or stageIndex == curStage and curLv > 0

								if isShow then
									recordShowRingTsList[#recordShowRingTsList + 1] = leafObjc
								end
							elseif layerType == LEAF_LAYER_TYPE.L_FLOOR then
								isShow = isFirstFlower and not isUnlockFirstFlower or curStage < stageIndex
							elseif layerType == LEAF_LAYER_TYPE.M_FLOOR then
								isShow = isFirstFlower and not isUnlockFirstFlower or curStage < stageIndex
							elseif layerType == LEAF_LAYER_TYPE.L_SHADOW then
								isShow = isFirstFlower and isUnlockFirstFlower or not isFirstFlower and stageIndex < curStage or stageIndex == curStage and curStageMaxLv <= curLv
							elseif layerType == LEAF_LAYER_TYPE.M_SHADOW then
								isShow = isFirstFlower and isUnlockFirstFlower or not isFirstFlower and stageIndex < curStage or stageIndex == curStage and level <= curLv
							elseif layerType == LEAF_LAYER_TYPE.L_V_ENT then
								isShow = stageIndex == curStage and curLv < level
							elseif layerType == LEAF_LAYER_TYPE.M_V_ENT then
								isShow = stageIndex == curStage and curLv < level
							elseif layerType == LEAF_LAYER_TYPE.L_ENT then
								isShow = isFirstFlower and isUnlockFirstFlower or not isFirstFlower and stageIndex < curStage or stageIndex == curStage and curStageMaxLv <= curLv
							elseif layerType == LEAF_LAYER_TYPE.M_ENT then
								isShow = isFirstFlower and isUnlockFirstFlower or not isFirstFlower and stageIndex < curStage or stageIndex == curStage and level <= curLv
							elseif layerType == LEAF_LAYER_TYPE.L_EFFECT then
								isShow = stageIndex < curStage or stageIndex == curStage and curStageMaxLv <= curLv
							elseif layerType == LEAF_LAYER_TYPE.M_EFFECT then
								isShow = isUpVx and stageIndex == curStage and level == curLv or stageIndex < curStage or stageIndex == curStage and level <= curLv
							end

							if isShow then
								if layerType == LEAF_LAYER_TYPE.RING then
									-- block empty
								else
									leafObjc.gameObject:SetActiveEx(isShow)
								end
							else
								leafObjc.gameObject:SetActiveEx(isShow)
							end
						end
					end
				end
			end
		end
	end

	for _, ringTs in ipairs(recordShowRingTsList) do
		ringTs.gameObject:SetActiveEx(false)
	end

	TimerManager.addTimer(0.01, function()
		for _, ringTs in ipairs(recordShowRingTsList) do
			ringTs.gameObject:SetActiveEx(true)
		end

		if isUpVx then
			self:m_refreshCheckShowEnvs()
		end
	end)

	local configMaxStage = PetManagementUtils.getResonanceMaxStageLv()

	if isUpVx then
		if curStageMaxLv <= curLv then
			self:playTrainSceneAudio(AudioConst.EVENT_PET_STARUP_2)

			if not PetManagementTrainingScene2.isShowNewStarUpVx then
				local effectUpVxTs = self.loadFlowerEffectTsList and self.loadFlowerEffectTsList[curStage]
				local effectUpVxUrl = curStage <= STARUP_VX_GRADE and STARUP_VX_LOW_RES or STARUP_VX_HIGH_RES

				if not effectUpVxTs then
					self:m_loadStarUpEffect(effectUpVxUrl, curStage)

					return
				end

				effectUpVxTs.gameObject:SetActiveEx(false)
				TimerManager.addTimer(0.01, function()
					effectUpVxTs.gameObject:SetActiveEx(true)
				end)
			end
		elseif curLv > 0 then
			self:playTrainSceneAudio(AudioConst.EVENT_PET_STARUP_1)
		end
	end

	if self.delayTimerSetLoopEffect then
		TimerManager.removeTimer(self.delayTimerSetLoopEffect)

		self.delayTimerSetLoopEffect = nil
	end

	self.delayTimerSetLoopEffect = TimerManager.addTimer(0.1, function()
		self.delayTimerSetLoopEffect = nil

		self:setLoopEffect(curStage)
	end)
end

function PetManagementTrainingScene2:m_tryHideLeafObjEffect()
	local objMap = self.m_delayHideLeafObjMap or {}
	local timerMap = self.m_delayHideLeafObjMapTimers or {}

	if not objMap or not next(objMap) or not timerMap or not next(timerMap) then
		return
	end

	local hideObjc = table.remove(objMap, 1)
	local hideTimer = table.remove(timerMap, 1)

	if hideObjc then
		hideObjc.gameObject:SetActiveEx(false)
	end

	if hideTimer then
		TimerManager.removeTimer(hideTimer)
	end
end

function PetManagementTrainingScene2:m_loadStarUpEffect(effectUrl, flowerIndex)
	if not effectUrl or not flowerIndex then
		return
	end

	self.loadFlowerEffectTsList = self.loadFlowerEffectTsList or {}

	if self.loadFlowerEffectTsList[flowerIndex] then
		return
	end

	pg.global.resMgr:GetInstanceFromCacheByLua(effectUrl, function(obj, userData)
		if not obj or not obj.transform then
			return
		end

		local effectLevelSetComop = obj.transform:GetComponent("EffectLevelSetting")

		if effectLevelSetComop then
			effectLevelSetComop:IgnoreUnLoad()
			effectLevelSetComop:SetEnableUpdate(false)
		end

		local flowerIndex = userData.flowerIndex
		local newEffectUpVxTs = obj.transform
		local leafParentT = self.loadFlowerTsList and self.loadFlowerTsList[flowerIndex]

		if PetManagementTrainingScene2.isShowNewStarUpVx then
			leafParentT = self.petsParentTransform
		end

		LuaUIUtils.safeSetGoLayer(newEffectUpVxTs.gameObject, ClientConst.LayerDefine.LAYER_UI_SCENE)
		newEffectUpVxTs:SetParent(leafParentT, false)

		newEffectUpVxTs.localPosition = self.flowersPos
		newEffectUpVxTs.localRotation = Quaternion.Euler(0, 0, 0)
		newEffectUpVxTs.localScale = Vector3.one
		self.loadFlowerEffectTsList[flowerIndex] = newEffectUpVxTs
	end, 1, {
		flowerIndex = flowerIndex
	})
end

function PetManagementTrainingScene2:m_checkShowStoryboard03()
	if self.storyboard03Transform then
		for i = 0, self.storyboard03Transform.childCount - 1 do
			local child = self.storyboard03Transform:GetChild(i)

			if NotNil(child) then
				local effectLevelSetComop = child.transform:GetComponent("EffectLevelSetting")

				if effectLevelSetComop then
					effectLevelSetComop:IgnoreUnLoad()
					effectLevelSetComop:SetEnableUpdate(false)
				end
			end
		end
	end

	local isShowPre = self.selectedTabId == Const.PetCulPages.STARUP

	if not isShowPre then
		self.storyboard03Transform.gameObject:SetActiveEx(false)

		return
	end

	if not self.petId then
		self.storyboard03Transform.gameObject:SetActiveEx(false)

		return
	end

	local curStage, curLv = PetManagementUtils.getPetCurStarSLv(self.petId)

	if not curStage or not curLv then
		self.storyboard03Transform.gameObject:SetActiveEx(false)

		return
	end

	local isResonanceMaxed = PetManagementUtils.isMaxedResonance(curStage, curLv)

	self.storyboard03Transform.gameObject:SetActiveEx(isResonanceMaxed)
end

function PetManagementTrainingScene2:playTrainSceneAudio(eventName)
	if not pg.game or not pg.game.audio then
		return
	end

	pg.game.audio:playEvent(eventName)
end

function PetManagementTrainingScene2:setLoopEffect(flowerIndex)
	if PetManagementTrainingScene2.isShowNewStarUpVx then
		return
	end

	local isAllHide = false

	if not flowerIndex or flowerIndex <= 0 or flowerIndex > FLOWERS_COUNT then
		isAllHide = true
	end

	local isLoaded = false

	self.loadFlowerLoopEffectTsList = self.loadFlowerLoopEffectTsList or {}

	for index, v in pairs(self.loadFlowerLoopEffectTsList) do
		if isAllHide then
			v.gameObject:SetActiveEx(false)
		else
			v.gameObject:SetActiveEx(flowerIndex == index)

			if flowerIndex == index then
				isLoaded = true
			end
		end
	end

	if not isLoaded then
		self:m_loadLoopEffect(flowerIndex)
	end
end

function PetManagementTrainingScene2:m_loadLoopEffect(flowerIndex)
	if not STARUP_VX_LOOP_RES or not flowerIndex then
		return
	end

	self.loadFlowerLoopEffectTsList = self.loadFlowerLoopEffectTsList or {}

	if self.loadFlowerLoopEffectTsList[flowerIndex] then
		return
	end

	pg.global.resMgr:GetInstanceFromCacheByLua(STARUP_VX_LOOP_RES, function(obj, userData)
		if not obj or not obj.transform then
			return
		end

		local effectLevelSetComop = obj.transform:GetComponent("EffectLevelSetting")

		if effectLevelSetComop then
			effectLevelSetComop:IgnoreUnLoad()
			effectLevelSetComop:SetEnableUpdate(false)
		end

		local flowerIndex = userData.flowerIndex
		local newEffectUpVxTs = obj.transform
		local leafParentT = self.loadFlowerTsList and self.loadFlowerTsList[flowerIndex]

		LuaUIUtils.safeSetGoLayer(newEffectUpVxTs.gameObject, ClientConst.LayerDefine.LAYER_UI_SCENE)
		newEffectUpVxTs:SetParent(leafParentT, false)

		newEffectUpVxTs.localPosition = self.flowersPos
		newEffectUpVxTs.localRotation = Quaternion.Euler(0, 0, 0)
		newEffectUpVxTs.localScale = Vector3.one
		self.loadFlowerLoopEffectTsList[flowerIndex] = newEffectUpVxTs
	end, 1, {
		flowerIndex = flowerIndex
	})
end

return PetManagementTrainingScene2
