-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientPhase.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local ClientSpace = require("Entities.SpaceEntities.ClientSpace")
local ClientPhase = Class.Class("ClientPhase", ClientSpace)

function ClientPhase:ctor(entityId)
	ClientPhase.super.ctor(self, entityId)

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("ClientPhase create")
	end
end

function ClientPhase:init(dict)
	ClientPhase.super.init(self, dict)

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("ClientPhase init", inspect(dict))
	end

	return true
end

return ClientPhase
