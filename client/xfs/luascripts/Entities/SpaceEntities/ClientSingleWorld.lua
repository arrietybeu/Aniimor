-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientSingleWorld.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local ClientSpace = require("Entities.SpaceEntities.ClientSpace")
local CallbackHandler = require("Core.Common.CallbackHandler")
local GlobalData = require("Core.Client.GlobalData")
local Utils = require("Common.Utils.Utils")
local ClientSingleWorld = Class.Class("ClientSingleWorld", ClientSpace)

function ClientSingleWorld:ctor(entityId)
	ClientSingleWorld.super.ctor(self, entityId)
end

function ClientSingleWorld:init(dict)
	ClientSingleWorld.super.init(self, dict)

	return true
end

function ClientSingleWorld:start()
	ClientSingleWorld.super.start(self)
end

function ClientSingleWorld:destroy()
	ClientSingleWorld.super.destroy(self)
end

return ClientSingleWorld
