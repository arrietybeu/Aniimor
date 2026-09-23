-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\ClientStudioOrnamentVirtualEntity.lua

local Class = require("Core.Framework.Class")
local ClientVirtualEntity = require("Entities.ClientVirtualEntity")
local CommonConst = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local ClientStudioOrnamentVirtualEntity = Class.Class("ClientStudioOrnamentVirtualEntity", ClientVirtualEntity)

function ClientStudioOrnamentVirtualEntity:init(dict)
	ClientStudioOrnamentVirtualEntity.super.init(self, dict)

	self.actorId = VirtualEntUtils.getNewVirtualEntActorId()
	self.studioOrnamentId = dict.ornamentId
	self.ownerUid = dict.ownerUid

	self:setConfigData(dict.configData or {})
end

function ClientStudioOrnamentVirtualEntity:addVirtualEntityComponent()
	self:addEModelComponent(CommonConst.COMPONENT_IDX_ITEM)
	self:addEModelMonoComponent(CommonConst.COMPONENT_IDX_PHYSX)
end

function ClientStudioOrnamentVirtualEntity:getOwnerUid()
	return self.ownerUid
end

function ClientStudioOrnamentVirtualEntity:refreshAppearance()
	ClientStudioOrnamentVirtualEntity.super.refreshAppearance(self)

	local configData = self:getConfigData()
	local modelView = self.eModel.itemModelView

	modelView.keepPrefabLayer = false
	modelView.forceColliderLayer = ClientConst.LayerDefine.LAYER_IGNORE_RAYCAST

	self.eModel:SetModelResId(CommonConst.COMPONENT_IDX_ITEM, configData.res, ClientConst.InstantiatePriority.Urgent, ClientConst.InstantiatePriority.High)
	modelView:SetRendererLod(0)
end

function ClientStudioOrnamentVirtualEntity:onItemModelLoaded()
	self.isModelLoaded = true

	self:setModelLoaded(true)

	if self.studioSelectionEnabled ~= true then
		return
	end

	self.eModel:SetTag(CommonConst.COMPONENT_IDX_PHYSX, CommonConst.TAG_ACTOR, self.actorId, 0)
	self.eModel:EnsureStudioSelectionBoxFromModelBounds(CommonConst.COMPONENT_IDX_PHYSX, 0.1)
end

return ClientStudioOrnamentVirtualEntity
