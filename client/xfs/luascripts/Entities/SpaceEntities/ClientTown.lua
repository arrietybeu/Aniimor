-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientTown.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local ClientSpace = require("Entities.SpaceEntities.ClientSpace")
local ClientTown = Class.Class("ClientTown", ClientSpace)

function ClientTown:ctor(entityId)
	ClientTown.super.ctor(self, entityId)

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("ClientTown create")
	end
end

function ClientTown:init(dict)
	ClientTown.super.init(self, dict)

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("ClientTown init", inspect(dict))
	end

	return true
end

return ClientTown
