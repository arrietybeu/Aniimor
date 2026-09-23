-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\HomeBaseComponent\\ClientHomeBasePetsComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local logger = LoggerManager.getLogger("ClientHomelandOrnamentComponent", "Sandbox", LoggerConst.ERROR)
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local CallbackHandler = require("Core.Common.CallbackHandler")
local MessageName = require("Const.MessageName")
local NoticeDef = require("Common.NoticeDef")
local EventConst = require("Const.EventConst")
local ClientHomeBasePetsComponent = Class.Component("ClientHomeBasePetsComponent")

function ClientHomeBasePetsComponent:init()
	self.homeSpace = Utils.isHomeland(self) and self or self.space

	return true
end

function ClientHomeBasePetsComponent:getPetInfo(id)
	return self.pets[id]
end

return ClientHomeBasePetsComponent
