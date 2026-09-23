-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientCarryItem.lua

local class = require("Core.Framework.Class")
local ClientInteractor = require("Entities.SpaceEntities.ClientInteractor")
local HoldItemData = require("Data.hold_item_data")
local ClientAttachComponent = require("Entities.SpaceEntities.CommonComponent.ClientAttachComponent")
local ClientBeCarryComponent = require("Entities.SpaceEntities.CommonComponent.ClientBeCarryComponent")
local ClientConst = require("Const.ClientConst")
local AddressDataConst = require("Const.AddressDataConst")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local InteractionConst = require("Common.Const.InteractionConst")
local ClientPrefabModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientPrefabModelComponent")
local ClientCarryItem = class.Class("ClientCarryItem", ClientInteractor)
local CarryItemComponents = {
	ClientAttachComponent,
	ClientBeCarryComponent,
	ClientPrefabModelComponent
}

class.AddComponents(ClientCarryItem, CarryItemComponents)

function ClientCarryItem:ctor(entityId)
	ClientCarryItem.super.ctor(self, entityId)

	self.isCarryItem = true
end

function ClientCarryItem:init(bdict)
	ClientCarryItem.super.init(self, bdict)

	self.item = bdict.item or {}

	return true
end

function ClientCarryItem:getInteractionListData()
	return nil
end

function ClientCarryItem:onPrefabModelLoaded()
	self:refreshCollider(true)

	if self.attachTargetId then
		local target = pg.getEntity(self.attachTargetId)

		if target and target.carryEnt ~= self then
			target:carryEntImp(self)
		end
	end
end

function ClientCarryItem:refreshAppearance()
	ClientCarryItem.super.refreshAppearance(self)

	if self:hasEModelComponent(Const.COMPONENT_IDX_ITEM) then
		local resId, scale
		local configData = HoldItemData[self.item.id]

		if configData then
			resId = configData.res
			scale = configData.scale or 1
		end

		scale = scale or 1

		self:setScaleNumber(scale)

		resId = resId or AddressDataConst.EMPTY_BAG_MODEL

		self:loadPrefabModel(resId)
		self:setCollideEnable(ClientConst.MODEL_VISIBLE_KEY.HUG_ENT, false)
	end
end

function ClientCarryItem:repr()
	return string.format("ClientCarryItem(entityId=%s, actorId=%d)", self.id, self.actorId or 0)
end

return ClientCarryItem
