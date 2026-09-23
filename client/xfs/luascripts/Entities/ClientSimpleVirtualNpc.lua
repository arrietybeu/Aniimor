-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\ClientSimpleVirtualNpc.lua

local CommonConst = require("Common.Const.Const")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local ClientSimpleVirtualEntity = require("Entities.ClientSimpleVirtualEntity")
local MessageName = require("Const.MessageName")
local ClientModelUtils = require("Utils.ClientModelUtils")
local AppearanceEffectUtils = require("Utils.AppearanceEffectUtils")
local PuppetData = require("Data.puppet_data")
local SysConfigData = require("Data.sys_config_data")
local NpcAvatarData = require("Data.npc_avatar_data")
local EModelUtils = require("Entities.Utils.EModelUtils")
local Const = require("Const.Const")
local ClientSimpleVirtualNpc = Class.Class("ClientSimpleVirtualNpc", ClientSimpleVirtualEntity)

function ClientSimpleVirtualNpc:init(dict)
	ClientSimpleVirtualNpc.super.init(self, dict)

	self.dic = dict
	self.templateId = dict.templateId
	self.syncLoad = dict.syncLoad

	if Utils.isVirtualTwinPuppet(dict.templateId) then
		local twinPetChoiceIndex = pg.me and pg.me.twinPetChoiceIndex or 0

		if twinPetChoiceIndex ~= 0 then
			self.templateId = Utils.getVirtualTwinPuppetTemplateId(dict.templateId, twinPetChoiceIndex)
		end
	end

	local pData = PuppetData[self.templateId]

	self:setConfigData(pData)

	self.gender = dict.gender or pData and pData.gender or 0
end

function ClientSimpleVirtualNpc:initializeComponents()
	ClientSimpleVirtualNpc.super.initializeComponents(self)

	if self.dic.applyMotion then
		self:addEModelComponent(CommonConst.COMPONENT_MOTION)

		local configData = self:getConfigData()

		self.eModel:SetOverrideSteering(Const.COMPONENT_MOTION, configData.turnMaxTime or SysConfigData.defaultTurnMaxTime)
		self:addEModelComponent(CommonConst.COMPONENT_AUTO_PATH_FIND)
	end
end

function ClientSimpleVirtualNpc:postInitializeComponents()
	if self.eModel then
		self.eModel:PostInitialize()
	end
end

function ClientSimpleVirtualNpc:onModelRefreshed()
	ClientSimpleVirtualNpc.super.onModelRefreshed(self)
	facade:SendMessageCommand(MessageName.ON_MODEL_REFRESHED, self.id)

	if self.modelLoadedCallback then
		self.modelLoadedCallback()
	end
end

function ClientSimpleVirtualNpc:refreshAppearance()
	if not self.eModel then
		return
	end

	self.appearanceEffectInfo = {}

	local configData = self:getConfigData()
	local label = self:getLabel()
	local gender = self:getGender()
	local modelView = self.eModel.modelModelView

	if self.copyEntity then
		modelView.modelInfo:CopyFrom(self.copyEntity.eModel.modelModelView.modelInfo)
		AppearanceEffectUtils.copyAppearanceInfo(self, self.copyEntity)
	else
		local extraInfo = ClientModelUtils.getModelExtraInfo(configData, label or 0, gender or 0, true)

		ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraInfo)

		if self.attachBaseEffects then
			self:attachBaseEffects(extraInfo.attachEffects)
		end

		if configData.appearanceResID then
			local npcAvatarData = NpcAvatarData[configData.appearanceResID] or {}
			local presetKey = npcAvatarData.avatarId

			if presetKey then
				modelView.modelInfo:ParseAvatarRuntimeData(presetKey)
				modelView.modelInfo:ParseToModelInfo()
			end
		end
	end

	if self.dic.position ~= nil and self.dic.rotation ~= nil then
		local rot = Quaternion.Euler(self.dic.rotation[1], self.dic.rotation[2], self.dic.rotation[3])

		EModelUtils.setAgentPositionAndRotation(self, self.dic.position, rot)
	end

	if not self.dic.applyAnim then
		modelView.modelInfo.physiqueModelInfo.animControllerAssetID = ""
	end

	ClientModelUtils.refreshModels(self, modelView)
end

function ClientSimpleVirtualNpc:getLabel()
	return self.dic.label or self:getConfigData().label
end

function ClientSimpleVirtualNpc:getGender()
	return self.gender
end

return ClientSimpleVirtualNpc
