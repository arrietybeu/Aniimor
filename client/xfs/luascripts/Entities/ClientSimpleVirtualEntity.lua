-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\ClientSimpleVirtualEntity.lua

local CommonConst = require("Common.Const.Const")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local ClientVirtualEntity = require("Entities.ClientVirtualEntity")
local MessageName = require("Const.MessageName")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ClientModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelComponent")
local ClientCombatEntityComponent = require("Entities.SpaceEntities.CommonComponent.ClientCombatEntityComponent")
local ClientSimpleLookAtComponent = require("Entities.SpaceEntities.CommonComponent.ClientSimpleLookAtComponent")
local ClientModelTransmogComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelTransmogComponent")
local LoggerManager = require("Core.Log.LoggerManager")
local ClientSimpleVirtualEntity = Class.Class("ClientSimpleVirtualEntity", ClientVirtualEntity)
local ClientVirtualComponents = {
	ClientModelComponent,
	ClientCombatEntityComponent,
	ClientSimpleLookAtComponent,
	ClientModelTransmogComponent
}

Class.AddComponents(ClientSimpleVirtualEntity, ClientVirtualComponents)

function ClientSimpleVirtualEntity:init(dict)
	ClientSimpleVirtualEntity.super.init(self, dict)

	if dict then
		self.templateId = dict.templateId
		self.staticId = dict.staticId
		self.label = dict.label
		self.shinyStyle = dict.shinyStyle
		self.gender = dict.gender
		self.instPriority = dict.instPriority
		self.isIgnoreEffectLod = dict.isIgnoreEffectLod
	end
end

function ClientSimpleVirtualEntity:destroy()
	ClientSimpleVirtualEntity.super.destroy(self)

	self.cutsceneLoadCallback = nil
end

function ClientSimpleVirtualEntity:initializeComponents()
	ClientSimpleVirtualEntity.super.initializeComponents(self)
	self:addEModelComponent(CommonConst.COMPONENT_INDEX_IK)
end

function ClientSimpleVirtualEntity:enterSpace(space)
	self.space = space

	self:onEnterSpace()
end

function ClientSimpleVirtualEntity:onModelRefreshed()
	ClientSimpleVirtualEntity.super.onModelRefreshed(self)

	self.isModelLoaded = true

	facade:SendMessageCommand(MessageName.ON_MODEL_REFRESHED, self.id)

	if self.modelLoadedCallback then
		self.modelLoadedCallback()
	end

	self:setShinyStyle()

	if self.cutsceneLoadCallback then
		local callback = self.cutsceneLoadCallback

		self.cutsceneLoadCallback = nil

		callback(self)
	end
end

function ClientSimpleVirtualEntity:refreshAppearance()
	ClientSimpleVirtualEntity.super.refreshAppearance(self)

	if not self.eModel then
		return
	end

	local configData = self:getConfigData()
	local modelView = self.eModel.modelModelView

	if self.instPriority then
		modelView.instPriority = self.instPriority
	end

	modelView.modelInfo.physiqueModelInfo.isAlwaysAnimate = true

	if self.isCutsceneVirtualEntity then
		return
	end

	local extraInfo = ClientModelUtils.getModelExtraInfo(configData, self.label or 0)

	self:postComponentMethod("EVENT_OnMergeAppearanceData", configData, extraInfo)
	ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraInfo)

	if self.attachBaseEffects then
		self:attachBaseEffects(extraInfo.attachEffects, self.isIgnoreEffectLod)
	end

	modelView.forceLoadPart = true

	modelView:RefreshModels()

	modelView.forceLoadPart = false
end

return ClientSimpleVirtualEntity
