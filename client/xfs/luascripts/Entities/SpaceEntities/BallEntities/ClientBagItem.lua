-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\BallEntities\\ClientBagItem.lua

local class = require("Core.Framework.Class")
local SysConfigData = require("Data.sys_config_data")
local AttributeConst = require("Common.Const.AttributeConst")
local ClientMainAuthorityBall = require("Entities.SpaceEntities.BallEntities.ClientMainAuthorityBall")
local ClientBagItem = class.Class("ClientBagItem", ClientMainAuthorityBall)

function ClientBagItem:ctor(entityId)
	ClientBagItem.super.ctor(self, entityId)
end

function ClientBagItem:onBallCreated()
	ClientBagItem.super.onBallCreated(self)
end

function ClientBagItem:onLuaHitEntity(hitEntityId)
	ClientBagItem.super.onLuaHitEntity(self, hitEntityId)
end

function ClientBagItem:fire()
	if self.fired then
		return
	end

	ClientBagItem.super.fire(self)
	self.shell:Throw()
end

return ClientBagItem
