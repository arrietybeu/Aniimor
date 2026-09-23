-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\Home\\ClientHomeFurnitureStoreEntity.lua

local CommonConst = require("Common.Const.Const")
local Class = require("Core.Framework.Class")
local ClientVirtualEntity = require("Entities.ClientVirtualEntity")
local ClientConst = require("Const.ClientConst")
local MessageName = require("Const.MessageName")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ClientHomeFurnitureStoreEntity = Class.Class("ClientHomeFurnitureStoreEntity", ClientVirtualEntity)

function ClientHomeFurnitureStoreEntity:init(dict)
	ClientHomeFurnitureStoreEntity.super.init(self, dict)
end

function ClientHomeFurnitureStoreEntity:initializeComponents()
	ClientHomeFurnitureStoreEntity.super.initializeComponents(self)
end

function ClientHomeFurnitureStoreEntity:addVirtualEntityComponent()
	self:addEModelComponent(CommonConst.COMPONENT_IDX_ITEM)
end

function ClientHomeFurnitureStoreEntity:enterSpace(space)
	self.space = space

	self:onEnterSpace()
end

function ClientHomeFurnitureStoreEntity:onModelRefreshed()
	ClientHomeFurnitureStoreEntity.super.onModelRefreshed(self)
	facade:SendMessageCommand(MessageName.ON_MODEL_REFRESHED, self.id)

	if self.modelLoadedCallback then
		self.modelLoadedCallback()
	end
end

function ClientHomeFurnitureStoreEntity:onItemModelLoaded()
	if self.modelLoadedCallback then
		self.modelLoadedCallback()
	end
end

function ClientHomeFurnitureStoreEntity:refreshAppearance()
	ClientHomeFurnitureStoreEntity.super.refreshAppearance(self)

	local configData = self:getConfigData()

	self.eModel.itemModelView.keepPrefabLayer = false

	self.eModel:SetModelResId(CommonConst.COMPONENT_IDX_ITEM, configData.modelResId, ClientConst.InstantiatePriority.Urgent, ClientConst.InstantiatePriority.High)
	self:setModelLayer()
	self.eModel.itemModelView:SetRendererLod(0)
end

function ClientHomeFurnitureStoreEntity:setModelLayer()
	if self.eModel then
		self.eModel:SetModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)
	end
end

return ClientHomeFurnitureStoreEntity
