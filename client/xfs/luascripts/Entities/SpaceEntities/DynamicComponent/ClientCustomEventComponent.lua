-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\DynamicComponent\\ClientCustomEventComponent.lua

local class = require("Core.Framework.Class")
local ClientCustomEventComponent = class.Component("ClientCustomEventComponent")

function ClientCustomEventComponent:ctor()
	return
end

function ClientCustomEventComponent:init(dict)
	return true
end

function ClientCustomEventComponent:start()
	return
end

function ClientCustomEventComponent:sendCustomEvent(eventName, ...)
	pg.me:serverSpaceMsg("RPC_CS_SyncCustomEvent", {
		self.id,
		eventName,
		{
			...
		}
	})
end

function ClientCustomEventComponent:callCustomEvent(eventName, params)
	facade:sendLuaEvent(eventName, unpack(params))
end

function ClientCustomEventComponent:destroy()
	return
end

return ClientCustomEventComponent
