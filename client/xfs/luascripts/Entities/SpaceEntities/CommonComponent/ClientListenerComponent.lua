-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientListenerComponent.lua

local class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local ClientListenerComponent = class.Component("ClientListenerComponent")

function ClientListenerComponent:ctor()
	return
end

function ClientListenerComponent:init()
	pg.game.audio:registerDecibelListener(self)
end

function ClientListenerComponent:setListenRange(range)
	self.listenRange = range
end

function ClientListenerComponent:receiveDecibel(id, level)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:info("receiveDecibel id:%s level:%s", id, level)
	end
end

function ClientListenerComponent:destroy()
	pg.game.audio:unregisterDecibelListener(self)
end

return ClientListenerComponent
