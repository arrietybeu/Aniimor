-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientCafeGatheringComponent.lua

local Class = require("Core.Framework.Class")
local ClientCafeGatheringComponent = Class.Component("ClientCafeGatheringComponent")

function ClientCafeGatheringComponent:ctor()
	return
end

function ClientCafeGatheringComponent:RPC_SC_NotifyCafeGatheringState(state)
	if self.isMainPlayer ~= true then
		return
	end

	pg.game.social:onNotifyCafeGatheringState(state == true)
end

return ClientCafeGatheringComponent
