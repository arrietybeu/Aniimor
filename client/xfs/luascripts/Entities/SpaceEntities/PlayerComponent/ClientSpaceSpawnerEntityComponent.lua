-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientSpaceSpawnerEntityComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local logger = LoggerManager.getLogger("ClientSpaceSpawnerEntityComponent")
local EventConst = require("Const.EventConst")
local GlobalData = require("Core.Client.GlobalData")
local Utils = require("Common.Utils.Utils")
local ClientSpaceSpawnerEntityComponent = class.Component("ClientSpaceSpawnerEntityComponent")

function ClientSpaceSpawnerEntityComponent:start()
	return
end

function ClientSpaceSpawnerEntityComponent:tick(deltaTime)
	return
end

function ClientSpaceSpawnerEntityComponent:onEnterSpace()
	self:refreshShowEntityDictVisible()
	self:refreshShowEntityInfoVisible()
end

function ClientSpaceSpawnerEntityComponent:on_hideShowEntityDict_entry_added(k, v)
	local ent = self.space:getEntityByStaticId(k)

	if not ent then
		return
	end

	ent:postComponentMethod("EVENT_OnHideShowEntityDictChange")
	ent:refreshServerVisible()
end

function ClientSpaceSpawnerEntityComponent:on_hideShowEntityDict_entry_deleted(k, v)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("on_hideShowEntityDict_entry_delete>>", k)
	end

	local ent = self.space:getEntityByStaticId(k)

	ent:postComponentMethod("EVENT_OnHideShowEntityDictChange")
	ent:refreshServerVisible()
end

function ClientSpaceSpawnerEntityComponent:on_hideShowEntityDict_item_changed(oldVal, newVal, k)
	local ent = self.space:getEntityByStaticId(k)

	if not ent then
		return
	end

	ent:postComponentMethod("EVENT_OnHideShowEntityDictChange")
	ent:refreshServerVisible()
end

function ClientSpaceSpawnerEntityComponent:refreshShowEntityDictVisible()
	for k, v in pairs(self.hideShowEntityDict) do
		local ent = self.space:getEntityByStaticId(k)

		if ent then
			ent:refreshServerVisible()
		end
	end
end

function ClientSpaceSpawnerEntityComponent:on_hideShowEntityInfo_entry_added(k, v)
	local ent = self.space:getEntityByStaticId(k)

	if not ent then
		return
	end

	ent:postComponentMethod("EVENT_OnHideShowEntityDictChange")
	ent:refreshServerVisible()
end

function ClientSpaceSpawnerEntityComponent:on_hideShowEntityInfo_entry_deleted(k, v)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("on_hideShowEntityInfo_entry_delete>>", k)
	end

	local ent = self.space:getEntityByStaticId(k)

	ent:postComponentMethod("EVENT_OnHideShowEntityDictChange")
	ent:refreshServerVisible()
end

function ClientSpaceSpawnerEntityComponent:on_hideShowEntityInfo_item_changed(oldVal, newVal, k)
	local ent = self.space:getEntityByStaticId(k)

	if not ent then
		return
	end

	ent:postComponentMethod("EVENT_OnHideShowEntityDictChange")
	ent:refreshServerVisible()
end

function ClientSpaceSpawnerEntityComponent:refreshShowEntityInfoVisible()
	if self.hideShowEntityInfo and type(self.hideShowEntityInfo) == "table" then
		for k, v in pairs(self.hideShowEntityInfo) do
			local ent = self.space:getEntityByStaticId(k)

			if ent then
				ent:refreshServerVisible()
			end
		end
	end
end

function ClientSpaceSpawnerEntityComponent:on_specialNpcDict_entry_deleted(k, v)
	local ent = self.space:getEntityByStaticId(k)

	if ent and ent.refreshIsNpcEntity then
		ent:refreshIsNpcEntity()
	end
end

function ClientSpaceSpawnerEntityComponent:on_specialNpcDict_entry_added(k, v)
	local ent = self.space:getEntityByStaticId(k)

	if ent then
		ent.isNpcEntity = true
	end
end

function ClientSpaceSpawnerEntityComponent:on_hideShowTitleDict_entry_added(k, v)
	local ents = pg.getEntitiesByTemplateId(k)

	for id, ent in pairs(ents) do
		ent:refreshAttachEffects()
	end
end

function ClientSpaceSpawnerEntityComponent:on_hideShowTitleDict_item_changed(oldVal, newVal, k)
	local ents = pg.getEntitiesByTemplateId(k)

	for id, ent in pairs(ents) do
		ent:refreshAttachEffects()
	end
end

function ClientSpaceSpawnerEntityComponent:on_specialContentDict_item_changed(oldVal, newVal, k)
	pg.global.eventEmitter:emit(EventConst.NPC_SPECIAL_STATE_UPDATE, k)
end

function ClientSpaceSpawnerEntityComponent:on_specialContentDict_entry_added(k, v)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("on_specialContentDict_entry_added>>", k)
	end

	pg.global.eventEmitter:emit(EventConst.NPC_SPECIAL_STATE_UPDATE, k)
end

function ClientSpaceSpawnerEntityComponent:on_specialContentDict_entry_deleted(k, v)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("on_specialContentDict_entry_delete>>", k)
	end

	pg.global.eventEmitter:emit(EventConst.NPC_SPECIAL_STATE_UPDATE, k)
end

return ClientSpaceSpawnerEntityComponent
