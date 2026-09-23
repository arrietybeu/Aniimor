-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\VehicleEntities\\ClientBalloon.lua

local class = require("Core.Framework.Class")
local ClientBubble = require("Entities.SpaceEntities.VehicleEntities.ClientBubble")
local Utils = require("Common.Utils.Utils")
local ClientBalloon = class.Class("ClientBalloon", ClientBubble)
local AudioConst = require("Const.AudioConst")
local Components = {}

class.AddComponents(ClientBalloon, Components)

function ClientBalloon:ctor(entityId)
	ClientBalloon.super.ctor(self, entityId)
end

function ClientBalloon:onEntityDismount(entity, seatId)
	self:clientDestroy()
	ClientBalloon.super.onEntityDismount(self, entity, seatId)
end

function ClientBalloon:onTriggerEnter(userData, entId)
	local ent = pg.getEntity(entId)

	if ent == self then
		return
	end

	if self.entityCount == 0 and ent and (Utils.isChest(ent) or Utils.isEnvObj(ent)) and ent.getIsKinematic and ent:getIsKinematic() then
		self:clientDestroy()

		return
	end

	ClientBalloon.super.onTriggerEnter(self, userData, entId)
end

function ClientBalloon:onEnterControl()
	ClientBalloon.super.onEnterControl(self)
	pg.game.audio:playEvent("SFX_InsideBubble_Loop")
	pg.game.audio:trySetState(AudioConst.WATER_IN_OUT, AudioConst.WATER_IN_OUT_Inside)
end

function ClientBalloon:onExitControl()
	pg.game.audio:stopEvent("SFX_InsideBubble_Loop")
	pg.game.audio:trySetState(AudioConst.WATER_IN_OUT, AudioConst.WATER_IN_OUT_Outside)
	ClientBalloon.super.onExitControl(self)
end

return ClientBalloon
