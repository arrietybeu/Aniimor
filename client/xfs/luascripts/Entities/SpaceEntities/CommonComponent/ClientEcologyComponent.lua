-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientEcologyComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local EntityTagIndexData = require("Data.entity_tag_to_index_data")
local Bitset = require("Common.Bitset")
local CTRPool = require("Common.AICt.CTRPool")
local EntityTagData = require("Data.entity_tag_data")
local EntityTagClearOnClientInitData = require("Data.entity_tag_clear_on_client_init__data")
local ClientEcologyComponent = Class.Component("ClientEcologyComponent")

function ClientEcologyComponent:ctor()
	return
end

function ClientEcologyComponent:onEnterSpace()
	for _, tagIndex in ipairs(EntityTagClearOnClientInitData) do
		Utils.removeEntityTag(self, tagIndex)
	end
end

function ClientEcologyComponent:requestAddEntityTag(tag)
	self:serverMsg("RPC_CS_AddEntityTag", tag)
end

function ClientEcologyComponent:requestRemoveEntityTag(tag)
	self:serverMsg("RPC_CS_RemoveEntityTag", tag)
end

function ClientEcologyComponent:onEntityTagChanged(tagIndex, isSet)
	if tagIndex == nil then
		return
	end

	local tagName = EntityTagIndexData[tagIndex]
	local context = CTRPool.getContext()

	context.tag = tagName

	if isSet then
		AIControllerUtils.sendAIEvent(self, "OnEntityTagAddMsgTrigger", context)
	else
		AIControllerUtils.sendAIEvent(self, "OnEntityTagRemoveMsgTrigger", context)
	end
end

function ClientEcologyComponent:on_entityTag_entry_added(k, v)
	local tagIndex, _ = Bitset.getChangedIndex(k, 0, v)

	self:onEntityTagChanged(tagIndex, true)
end

function ClientEcologyComponent:on_entityTag_entry_deleted(k, v)
	local tagIndex, _ = Bitset.getChangedIndex(k, v, 0)

	self:onEntityTagChanged(tagIndex, false)
end

function ClientEcologyComponent:addIsGrabbedEntityTag()
	Utils.addEntityTag(self, EntityTagData.TE_Wild_IsGrabbed.value)
end

function ClientEcologyComponent:removeIsGrabbedEntityTag()
	Utils.removeEntityTag(self, EntityTagData.TE_Wild_IsGrabbed.value)
end

function ClientEcologyComponent:addIsGrabbingEntityTag()
	Utils.addEntityTag(self, EntityTagData.TE_Wild_IsGrabbing.value)
end

function ClientEcologyComponent:removeIsGrabbingEntityTag()
	Utils.removeEntityTag(self, EntityTagData.TE_Wild_IsGrabbing.value)
end

function ClientEcologyComponent:on_entityTag_item_changed(oldVal, newVal, k)
	local tagIndex, isSet = Bitset.getChangedIndex(k, oldVal or 0, newVal)

	self:onEntityTagChanged(tagIndex, isSet)
end

function ClientEcologyComponent:getDebugEntityTags()
	local list = Bitset.getList(self.entityTag)

	for idx, tagIndex in ipairs(list) do
		list[idx] = EntityTagIndexData[tagIndex]
	end

	return list
end

return ClientEcologyComponent
