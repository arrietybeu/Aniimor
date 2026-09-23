-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\HomelandComponent\\ClientHomelandZoneComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local logger = LoggerManager.getLogger("ClientHomelandOrnamentComponent", "Sandbox", LoggerConst.ERROR)
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local CallbackHandler = require("Core.Common.CallbackHandler")
local MessageName = require("Const.MessageName")
local NoticeDef = require("Common.NoticeDef")
local ClientHomelandZoneComponent = Class.Component("ClientHomelandZoneComponent")

function ClientHomelandZoneComponent:ctor()
	return
end

function ClientHomelandZoneComponent:on_zone_changed(ov, nv, key)
	return
end

function ClientHomelandZoneComponent:on_zone_added(k, v)
	pg.game.home:onZoneUnlock()
	facade:sendMsgToUI(MessageName.HOMELAND_ZONE_UNLOCK)
end

function ClientHomelandZoneComponent:on_zone_delete(k, v)
	return
end

function ClientHomelandZoneComponent:on_unlockArea_changed(ov, nv, key)
	pg.game.home:onAreaUnlockedChanged()
end

function ClientHomelandZoneComponent:on_unlockArea_added(k, v)
	pg.game.home:onAreaUnlockedChanged()
end

function ClientHomelandZoneComponent:getUnlockHomelandZoneCount()
	local count = 0

	for zoneId, unlock in pairs(self.unlockZone) do
		if unlock then
			count = count + 1
		end
	end

	return count
end

return ClientHomelandZoneComponent
