-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientHomeCamp.lua

local Class = require("Core.Framework.Class")
local ClientSpace = require("Entities.SpaceEntities.ClientSpace")
local CallbackHandler = require("Core.Common.CallbackHandler")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local MessageName = require("Const.MessageName")
local ClientConst = require("Const.ClientConst")
local ClientHomeCamp = Class.Class("ClientHomeCamp", ClientSpace)
local ClientHomeCampComponents = {}

Class.AddComponents(ClientHomeCamp, ClientHomeCampComponents)

function ClientHomeCamp:ctor(entityId)
	ClientHomeCamp.super.ctor(self, entityId)
end

function ClientHomeCamp:init(dict)
	ClientHomeCamp.super.init(self, dict)

	return true
end

function ClientHomeCamp:start()
	ClientHomeCamp.super.start(self)
end

function ClientHomeCamp:destroy()
	ClientHomeCamp.super.destroy(self)
end

function ClientHomeCamp:getSelfHomeCampKey(player)
	return Utils.getSelfHomeCampKey(player)
end

function ClientHomeCamp:isSelfHomeCamp(player)
	player = player or pg.me

	return self:getSelfHomeCampKey(player) == self.spaceKey
end

return ClientHomeCamp
