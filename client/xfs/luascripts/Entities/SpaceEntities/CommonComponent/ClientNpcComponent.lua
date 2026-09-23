-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientNpcComponent.lua

local class = require("Core.Framework.Class")
local Utils = require("Utils.Utils")
local RigidbodyData = require("Data.rigidbody_data")
local Const = require("Const.Const")
local AiConst = require("Const.AiConst")
local Events = require("Common.Container.Events")
local SceneUtils = require("Common.Utils.SceneUtils")
local EModelUtils = require("Entities.Utils.EModelUtils")
local ClientConst = require("Const.ClientConst")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local ClientModelUtils = require("Utils.ClientModelUtils")
local MessageName = require("Const.MessageName")
local Bitset = require("Common.Bitset")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local ClientUtils = require("Utils.ClientUtils")
local PuppetData = require("Data.puppet_data")
local Vector3 = Vector3
local Quaternion = Quaternion
local ClientNpcComponent = class.Component("ClientNpcComponent")

function ClientNpcComponent:ctor()
	self.isInScene = false
	self.eventEmitter = Events.new()
end

function ClientNpcComponent:init(dict)
	self.dic = dict or AiConst.DefaultNullTable
	self.specialStateEffIds = {}
end

function ClientNpcComponent:start()
	local isHide = self:getConfigData().isHide

	if isHide == 1 then
		self:setActive(ClientConst.MODEL_VISIBLE_KEY.CONFIG, false)
	end

	if EnableBotTest then
		return
	end

	local modelScaleRange = self:getConfigData().modelScaleRange

	if modelScaleRange and modelScaleRange[3] then
		self.curModelScale = modelScaleRange[3]

		self:setModelScale(ClientConst.MODEL_SCALE_KEY.DEFAULT, modelScaleRange[3])
		self:refreshTopLogoHeight()
	end
end

function ClientNpcComponent:onNPCPostInitializeComponents()
	self.eModel:PostInitialize()

	local st, err = xpcall(function()
		self:refreshAppearance()
	end, debug.traceback)

	if not st and LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("%s safeDestroy failed, %s", self:repr(), err)
	end

	self.eModel.isMainAuthority = true

	self:applyFixedScale()
end

function ClientNpcComponent:getSceneEntityCfg(cfgName)
	if self.staticSceneEntityData then
		local sceneEntityDataValue = self.staticSceneEntityData[cfgName]

		if sceneEntityDataValue ~= nil then
			return sceneEntityDataValue
		end
	end

	return self:getConfigData()[cfgName]
end

function ClientNpcComponent:setInScene(isInScene, isReset, extraInfo)
	if self.isInScene ~= isInScene then
		self.isInScene = isInScene

		if isInScene then
			self:onEnterScene(extraInfo)
		else
			self:onLeaveScene(extraInfo)
		end
	elseif self.isInScene and isReset then
		self:onResetScene(extraInfo)
	end
end

function ClientNpcComponent:preDestroy()
	if #self.specialStateEffIds > 0 then
		for _, effId in ipairs(self.specialStateEffIds) do
			self:dropEffect(effId)
		end

		self.specialStateEffIds = {}
	end

	self:setInScene(false)
end

function ClientNpcComponent:destroy()
	self.staticSceneEntityData = nil
end

function ClientNpcComponent:canAim()
	return not Utils.isPeopleNpc(self)
end

function ClientNpcComponent:canAbsorb()
	return false
end

function ClientNpcComponent:getLockPosition()
	return self:getPosition()
end

function ClientNpcComponent:canBeLookAt()
	return self:getSceneEntityCfg("canBeLookAt")
end

function ClientNpcComponent:onEnterSpace()
	local staticId = self.staticId

	if staticId ~= nil and staticId > 0 then
		self.staticSceneEntityData = SceneUtils.getSceneEntityData(self.space.sceneId, self.space.id)[staticId]
	end

	self:postComponentMethod("onEnterSpace")
	self:setInScene(pg.global.scene:isSceneValid())
end

function ClientNpcComponent:onLeaveSpace()
	self.staticSceneEntityData = nil

	self:postComponentMethod("onLeaveSpace")
end

function ClientNpcComponent:onEnterScene()
	self:postComponentMethod("EVENT_EnterScene")

	if self.resumeBt then
		self:resumeBt(AiConst.PauseBtReason.SceneLoading)
	end

	self:genNPCCollider()
end

function ClientNpcComponent:onLeaveScene()
	self:postComponentMethod("EVENT_LeaveScene")

	if self.pauseBt then
		self:pauseBt(AiConst.PauseBtReason.SceneLoading)
	end
end

function ClientNpcComponent:onResetScene()
	self:postComponentMethod("EVENT_ResetScene")
end

function ClientNpcComponent:getTemplateData()
	return PuppetData[self.templateId] or AiConst.DefaultNullTable
end

function ClientNpcComponent:genNPCCollider()
	if (Utils.isStaticNpc(self) or Utils.isSimpleMoveNpc(self)) and not Utils.checkIsInTown(self) and not Utils.isPeopleNpc(self) then
		local entityConfigData = self:getConfigData()
		local rigidbodyId = entityConfigData.rigidbody
		local rigidbodyData = rigidbodyId and RigidbodyData[rigidbodyId]

		if not rigidbodyData then
			return
		end

		local centerX, centerY, centerZ

		if rigidbodyData.center == nil then
			centerX, centerY, centerZ = 0, rigidbodyData.height * 0.5, 0
		else
			centerX, centerY, centerZ = rigidbodyData.center[1], rigidbodyData.center[2], rigidbodyData.center[3]
		end

		local radius = ToBool(rigidbodyData.radius) and rigidbodyData.radius or 0.1
		local height = ToBool(rigidbodyData.height) and rigidbodyData.height or 0.1

		self:addEModelMonoComponent(Const.COMPONENT_IDX_PHYSX)
		self.eModel:GenNpcCollider(Const.COMPONENT_IDX_PHYSX, centerX, centerY, centerZ, radius, height)
	end
end

function ClientNpcComponent:turnToRotation(rotation)
	EModelUtils.setAgentRotation(self, rotation)
end

function ClientNpcComponent:faceToRotation(rotation)
	EModelUtils.setAgentRotation(self, rotation)
end

function ClientNpcComponent:faceToTarget(target, partId, useTurnAnim)
	local configData = self:getConfigData()

	if configData.lockDirection then
		return
	end

	if not self.rawRot then
		self.rawRot = self:getRotation()
	end

	if target then
		local targetDir = target:getLockPartPosition(partId) - self:getPosition()

		targetDir.y = 0

		if Vector3.SqrMagnitude(targetDir) < 0.1 then
			return
		end

		local targetRotation = Quaternion.LookRotation(targetDir, Vector3.up)

		if useTurnAnim then
			self:turnToRotation(targetRotation)
		else
			self:faceToRotation(targetRotation)
		end
	end
end

function ClientNpcComponent:faceToPosition(pos)
	local targetDir = pos - self:getPosition()

	targetDir.y = 0

	if Vector3.SqrMagnitude(targetDir) < 0.1 then
		return
	end

	local targetRotation = Quaternion.LookRotation(targetDir, Vector3.up)

	self:faceToRotation(targetRotation)
end

function ClientNpcComponent:resetRotation()
	local configData = self:getConfigData()

	if not configData.resetRotation then
		return
	end

	if self.rawRot then
		self:faceToRotation(self.rawRot)
	end

	self.rawRot = nil
end

function ClientNpcComponent:getLabel()
	return self.dic.label or self:getConfigData().label
end

function ClientNpcComponent:getGender()
	return self.dic.gender or self:getConfigData().gender
end

function ClientNpcComponent:refreshAppearance(forceRefreshPlayable)
	if EnableBotTest then
		return
	end

	self:setModelLayer()
	self.eModel:SetClientReady(true)

	local configData = self:getConfigData()
	local label = self:getLabel()
	local gender = self:getGender()
	local modelView = self.eModel.modelModelView

	modelView.instPriority = ClientConst.InstantiatePriority.Low

	local extraInfo = ClientModelUtils.getModelExtraInfo(configData, label or 0, gender or 0, true)

	if self.spPrefabResID then
		extraInfo.prefabResID = self.spPrefabResID
	end

	local result, realPrefabResID = AvatarUtils.refreshNPCModelData(configData)

	if result then
		extraInfo.prefabResID = realPrefabResID

		ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraInfo)

		if self.attachBaseEffects then
			self:attachBaseEffects(extraInfo.attachEffects)
		end

		self:postComponentMethod("Event_BeforeRefreshModels", modelView)
		self:onRefreshAppearance(configData, extraInfo, forceRefreshPlayable)
		modelView:RefreshModels()
		self:postComponentMethod("Event_AfterRefreshModels", modelView)
	else
		ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraInfo)

		if self.attachBaseEffects then
			self:attachBaseEffects(extraInfo.attachEffects)
		end

		self:onRefreshAppearance(configData, extraInfo, forceRefreshPlayable)
		modelView:RefreshModels()
	end
end

function ClientNpcComponent:onRefreshAppearance(configData)
	local modelView = self.eModel.modelModelView

	if configData.keepPrefabLayer then
		modelView.keepPrefabLayer = true
	end

	self:refreshSpecialStateEffs()
end

function ClientNpcComponent:modelLoaded()
	if not self.eModel then
		return false
	end

	local modelView = self.eModel.modelModelView

	return modelView.firstLoaded
end

function ClientNpcComponent:getSpecialStateEffData()
	local data = self:getTemplateData()

	return data.specialStateEff
end

function ClientNpcComponent:refreshSpecialStateEffs()
	if #self.specialStateEffIds > 0 then
		for _, effId in ipairs(self.specialStateEffIds) do
			self:dropEffect(effId)
		end

		self.specialStateEffIds = {}
	end

	local specialStateId = self:getSpecialStateId()
	local spEffData = self:getSpecialStateEffData()

	if spEffData and specialStateId then
		for spId, effD in pairs(spEffData) do
			for _, v in pairs(effD) do
				if spId == specialStateId or spId < specialStateId and v[4] then
					local offsetPos = self:getPosition() + v[2]
					local offsetRot = self:getRotation():ToEulerAngles() + v[3]

					self.specialStateEffIds[#self.specialStateEffIds + 1] = self:playEffectAt(v[1], offsetPos, offsetRot)
				end
			end
		end
	end
end

function ClientNpcComponent:onModelRefreshed()
	ClientModelUtils.applyModelSwitchTag(self)
	self:postComponentMethod("EVENT_OnModelRefreshed")
	facade:SendMessageCommand(MessageName.ON_MODEL_REFRESHED, self.id)

	if self.modelLoadedCallback then
		self.modelLoadedCallback()
	end
end

function ClientNpcComponent:setModelLayer(layer)
	if layer == nil then
		layer = self:getConfigData().layer or ClientConst.LayerDefine.LAYER_ENTITY
	end

	if self.eModel then
		self.eModel:SetModelLayer(layer)
	end
end

function ClientNpcComponent:setModelLoaded(isLoaded)
	self.eModel.isModelLoaded = isLoaded
end

function ClientNpcComponent:onActiveChange(active)
	self:postComponentMethod("EVENT_OnActiveChange", active)
	self:postComponentMethod("NPCINFO_OnAciveChange", active)
end

function ClientNpcComponent:onModelVisibleChange(visible)
	self:postComponentMethod("EVENT_OnModelVisibleChange", visible)
end

function ClientNpcComponent:refreshVisible()
	self:postComponentMethod("EVENT_RefreshVisible")
end

function ClientNpcComponent:queryModelVisible()
	if Bitset.any(ClientConst.PUPPET_VISIBLE_FLAG) then
		return true, false
	end

	return true, true, true
end

function ClientNpcComponent:applyFixedScale()
	if not self.space or not self.staticId or self.staticId == 0 then
		return
	end

	local sceneEntityData = SceneUtils.getSceneEntityData(self.space.sceneId, self.space.id)
	local data = sceneEntityData and sceneEntityData[self.staticId]

	if data and data.fixedScale and data.fixedScale ~= 0 and self.setModelScale then
		self.curModelScale = data.fixedScale

		if self.setModelScale then
			self:setModelScale(ClientConst.MODEL_SCALE_KEY.DEFAULT, data.fixedScale)
		end

		if self.refreshTopLogoHeight then
			self:refreshTopLogoHeight()
		end
	end
end

function ClientNpcComponent:getTopLogoFollowStrategy()
	return ClientUtils.getEntityTopLogoFollowStrategy(self)
end

function ClientNpcComponent:getTopLogoHeight(strategy, entry)
	return ClientUtils.getEntityTopLogoHeight(self, strategy, entry)
end

function ClientNpcComponent:getTopLogoHeightToRoot()
	local topLogoHeight = self:getTopLogoHeight()

	if self.topLogoData.strategy == 3 then
		local success, pos, _ = self.eModel:TryGetHead(Const.COMPONENT_INDEX_MODEL)

		if success then
			topLogoHeight = pos.y - self:getPosition().y
		end
	end

	return topLogoHeight
end

function ClientNpcComponent:getLockPartPosition(partId)
	return self:getPosition()
end

return ClientNpcComponent
