-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientRobEggLimitTimePortal.lua

local class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ClientPawnEntity = require("Entities.ClientPawnEntity")
local PuppetData = require("Data.puppet_data")
local ClientRobEggLimitTimePortal = class.Class("ClientRobEggLimitTimePortal", ClientPawnEntity)
local ClientTopLogoComponent = require("Entities.SpaceEntities.CommonComponent.ClientTopLogoComponent")
local ClientTrapEventComponent = require("Entities.SpaceEntities.CommonComponent.ClientTrapEventComponent")
local ClientInanimateNpcInteractComponent = require("Entities.SpaceEntities.CommonComponent.ClientInanimateNpcInteractComponent")
local RobEggConst = require("Common.Const.RobEggConst")
local ClientRobEggLimitTimePortalComponents = {
	ClientTrapEventComponent,
	ClientTopLogoComponent,
	ClientInanimateNpcInteractComponent
}

if EnableBotTest then
	ClientRobEggLimitTimePortalComponents = {
		ClientInanimateNpcInteractComponent
	}
end

class.AddComponents(ClientRobEggLimitTimePortal, ClientRobEggLimitTimePortalComponents)

function ClientRobEggLimitTimePortal:ctor(entityId)
	ClientRobEggLimitTimePortal.super.ctor(self, entityId)

	self.actorType = Const.ACTOR_TYPE_PUPPET
	self.isTimeLimitPortal = true
end

function ClientRobEggLimitTimePortal:init(bdict)
	ClientRobEggLimitTimePortal.super.init(self, bdict)

	self.trapEventId = bdict.trapEventId

	local pdd = PuppetData[self.templateId] or {}

	self.forbiddenTopLogo = pdd.forbidTopLogo or false
	self.useHitBox = false
	self.bodyMass = pdd.mass
	self.bodyWeight = pdd.weight
	self.effs = pdd.effs
	self.entityCanMove = false

	return true
end

function ClientRobEggLimitTimePortal:start()
	ClientRobEggLimitTimePortal.super.start(self)
end

function ClientRobEggLimitTimePortal:refreshAppearance(forceRefreshPlayable)
	if EnableBotTest then
		return
	end

	ClientRobEggLimitTimePortal.super.refreshAppearance(self, forceRefreshPlayable)
end

function ClientRobEggLimitTimePortal:onRefreshAppearance(configData, extraData, forceRefreshPlayable)
	ClientRobEggLimitTimePortal.super.onRefreshAppearance(self, configData, extraData, forceRefreshPlayable)

	local modelView = self.eModel.modelModelView

	if configData.keepPrefabLayer then
		modelView.keepPrefabLayer = true
	end

	if configData.needWait and not self:modelLoaded() then
		self.waitModelMark = true
		modelView.instPriority = ClientConst.InstantiatePriority.High

		pg.global.scene:markWaitEntity(self.id, true)
	end
end

function ClientRobEggLimitTimePortal:refreshModel(configData, extraData)
	local modelView = self.eModel.modelModelView

	ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraData)
	modelView:RefreshModels()
end

function ClientRobEggLimitTimePortal:onModelRefreshed()
	ClientRobEggLimitTimePortal.super.onModelRefreshed(self)
end

function ClientRobEggLimitTimePortal:getModelExtraData(configData)
	local label = self:getLabel()
	local gender = self:getGender()
	local extraInfo = ClientModelUtils.getModelExtraInfo(configData, label or 0, gender or 0, true)

	if self.spPrefabResID then
		extraInfo.prefabResID = self.spPrefabResID
	end

	return extraInfo
end

function ClientRobEggLimitTimePortal:getTemplateData()
	return PuppetData[self.templateId] or {}
end

function ClientRobEggLimitTimePortal:getName()
	local cfgData = self:getTemplateData()

	return cfgData.name
end

function ClientRobEggLimitTimePortal:checkShowEntityInteract()
	if not pg.me or not pg.me.space then
		return false
	end

	local space = pg.me.space

	if not space.curStage then
		return false
	end

	return space.curStage == RobEggConst.LIMITTIME_STATE.REWARD
end

function ClientRobEggLimitTimePortal:repr()
	return string.format("ClientRobEggLimitTimePortal(entityId=%s)", self.id)
end

function ClientRobEggLimitTimePortal:preDestroy()
	self:playDestroyEffect()
	ClientRobEggLimitTimePortal.super.preDestroy(self)
end

return ClientRobEggLimitTimePortal
