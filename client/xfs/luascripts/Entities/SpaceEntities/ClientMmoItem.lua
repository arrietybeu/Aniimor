-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientMmoItem.lua

local class = require("Core.Framework.Class")
local ClientModelEntity = require("Entities.ClientModelEntity")
local ClientUtils = require("Utils.ClientUtils")
local SceneUtils = require("Common.Utils.SceneUtils")
local ClientConst = require("Const.ClientConst")
local level_item_config_data = require("Data.level_item_config_data")
local entityManager = appFacade.entityManager
local ClientMmoItem = class.Class("ClientMmoItem", ClientModelEntity)
local ClientAoiComponent = require("Entities.SpaceEntities.CommonComponent.ClientAoiComponent")
local ClientAuthorityComponent = require("Entities.SpaceEntities.CommonComponent.ClientAuthorityComponent")
local Components = {
	ClientAoiComponent,
	ClientAuthorityComponent
}

class.AddComponents(ClientMmoItem, Components)

function ClientMmoItem:ctor(entityId)
	ClientMmoItem.super.ctor(self, entityId)
end

function ClientMmoItem:init(bdict)
	ClientMmoItem.super.init(self, bdict)

	self.position = bdict.position
	self.rotation = bdict.rotation
	self.scale = bdict.scale
	self.levelItemConfig = bdict.levelItemConfig
	self.sceneSandboxData = SceneUtils.getSceneEntityData(pg.space.sceneId, pg.space.id)[self.staticId]
	self.shell = appFacade.sandboxManager.globalSandbox
	self.isMain = false

	self:addItem(self.levelItemConfig)

	self.entityCanMove = false

	return true
end

function ClientMmoItem:syncFieldValue(itemId, changeFields)
	return
end

function ClientMmoItem:sendSandboxEvent(itemId, eventType)
	return
end

function ClientMmoItem:serverMsgSb(levelItemId, name, ignoreAuthority, args)
	pg.me:serverSpaceMsg("RPC_CS_LevelItemServerMsg", {
		self.staticId,
		levelItemId,
		name,
		ignoreAuthority,
		args
	})
end

function ClientMmoItem:addItem(syncInfo)
	local spawnInfo = self.sceneSandboxData.levelItem
	local itemCfg = level_item_config_data[spawnInfo.configId]
	local levelItemType = require("GameApp.Sandbox." .. itemCfg.subType)

	self.levelItem = levelItemType.new(self, spawnInfo, syncInfo)

	local csItem = self.shell:CreateLevelItem(self.levelItem.id)

	self.levelItem:bindShell(csItem)
end

function ClientMmoItem:destroy()
	if self.levelItem then
		self.shell:DestroyLevelItem(self.levelItem.id)
		self.levelItem:destroy()

		self.levelItem = nil
	end

	self.shell = nil

	ClientMmoItem.super.destroy(self)
end

function ClientMmoItem:RPC_SC_LevelItemClientMsg(playerId, funcName, parameters)
	local func = self.levelItem[funcName]

	if func then
		func(self.levelItem, unpack(parameters))
	end
end

return ClientMmoItem
