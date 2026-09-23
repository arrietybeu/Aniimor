-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\ClientVirtualPuppet.lua

local Class = require("Core.Framework.Class")
local ClientVirtualEntity = require("Entities.ClientVirtualEntity")
local ClientConst = require("Const.ClientConst")
local MessageName = require("Const.MessageName")
local ClientModelUtils = require("Utils.ClientModelUtils")
local puppetData = require("Data.puppet_data")
local ClientVirtualPuppet = Class.Class("ClientVirtualPuppet", ClientVirtualEntity)

function ClientVirtualPuppet:onModelRefreshed()
	facade:SendMessageCommand(MessageName.ON_MODEL_REFRESHED, self.id)
end

function ClientVirtualPuppet:start()
	ClientVirtualPuppet.super.start(self)
end

function ClientVirtualPuppet:init(dict)
	ClientVirtualPuppet.super.init(self, dict)

	self.templateId = dict.templateId

	return true
end

function ClientVirtualPuppet:getTemplateData()
	return puppetData[self.templateId] or {}
end

function ClientVirtualPuppet:getConfigData()
	return self:getTemplateData()
end

function ClientVirtualPuppet:refreshAppearance()
	ClientVirtualPuppet.super.refreshAppearance(self)

	if not self.eModel then
		return
	end

	local configData = self:getConfigData()
	local modelView = self.eModel.modelModelView
	local extraData = ClientModelUtils.getModelExtraInfo(configData, 0)

	ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraData)
	modelView:RefreshModels()
end

return ClientVirtualPuppet
