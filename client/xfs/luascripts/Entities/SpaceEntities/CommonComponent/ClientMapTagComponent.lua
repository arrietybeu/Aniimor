-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientMapTagComponent.lua

local class = require("Core.Framework.Class")
local ClientMapTagComponent = class.Component("ClientMapTagComponent")

function ClientMapTagComponent:ctor()
	return
end

function ClientMapTagComponent:init(dict)
	return true
end

function ClientMapTagComponent:RPC_SC_BindMapMarkToEntity(entityMarkGroup)
	pg.game.map:bindEntityPosToMapMark(entityMarkGroup.markId, entityMarkGroup.entityId)
end

function ClientMapTagComponent:RPC_SC_UnBindMapMarkToEntity(entityMarkGroup)
	pg.game.map:unbindEntityPosFromMapMark(entityMarkGroup.markId, entityMarkGroup.entityId)
end

return ClientMapTagComponent
