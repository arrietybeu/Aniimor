-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientSubMagnesisComponent.lua

local Class = require("Core.Framework.Class")
local PlayableEventConst = require("Const.PlayableEventConst")
local ClientSubMagnesisComponent = Class.Component("ClientSubMagnesisComponent")

function ClientSubMagnesisComponent:RPC_SC_SyncPlayerPlayMagnesisEffect(effectId)
	self:playEffect(effectId)
end

function ClientSubMagnesisComponent:RPC_SC_SyncPlayerStopMagnesisEffect(effectId)
	self:stopEffect(effectId)
end

return ClientSubMagnesisComponent
