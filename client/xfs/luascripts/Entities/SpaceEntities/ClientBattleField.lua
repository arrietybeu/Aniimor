-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientBattleField.lua

local class = require("Core.Framework.Class")
local ClientModelEntity = require("Entities.ClientModelEntity")
local ClientConst = require("Const.ClientConst")
local CreationData = require("Data.creation_data")
local ClientModelUtils = require("Utils.ClientModelUtils")
local Const = require("Common.Const.Const")
local ClientBattleField = class.Class("ClientBattleField", ClientModelEntity)
local ClientAoiComponent = require("Entities.SpaceEntities.CommonComponent.ClientAoiComponent")
local ClientAuthorityComponent = require("Entities.SpaceEntities.CommonComponent.ClientAuthorityComponent")
local Components = {
	ClientAoiComponent,
	ClientAuthorityComponent
}

class.AddComponents(ClientBattleField, Components)

function ClientBattleField:ctor(entityId)
	ClientBattleField.super.ctor(self, entityId)

	self.actorType = Const.ACTOR_TYPE_NONE
end

function ClientBattleField:init(bdict)
	ClientBattleField.super.init(self, bdict)

	self.radius = bdict.radius or 100
	self.entityCanMove = false

	return true
end

function ClientBattleField:start()
	ClientBattleField.super.start(self)
end

function ClientBattleField:onEnterScene()
	ClientBattleField.super.onEnterScene(self)

	if not self.corruptEff then
		self.corruptEff = pg.global.dungeonManager:StartCorrupt(self:getPosition(), self.radius, 10)
	end
end

function ClientBattleField:initializeComponents()
	ClientBattleField.super.initializeComponents(self)
end

function ClientBattleField:getConfigData()
	return {}
end

function ClientBattleField:destroy()
	if self.corruptEff then
		self.corruptEff:Stop()
	end

	ClientBattleField.super.destroy(self)
end

return ClientBattleField
