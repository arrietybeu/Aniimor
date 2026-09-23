-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientMagneticComponent.lua

local Class = require("Core.Framework.Class")
local ClientMagneticComponent = Class.Component("ClientMagneticComponent")

function ClientMagneticComponent:ctor()
	self.effectExtInfo = {
		scale = 1
	}
end

function ClientMagneticComponent:setMagnesisEffectScale(scale)
	self.effectExtInfo.scale = scale
end

function ClientMagneticComponent:playMagnesisEffect(effectId)
	local effInstanceId = self:playEffect(effectId, self.effectExtInfo)

	self:serverMsgNoGC("RPC_CS_SyncPlayMagnesisEffect", effectId)

	return effInstanceId
end

function ClientMagneticComponent:stopMagnesisEffect(effectId, instanceId)
	if self.eModel then
		if instanceId then
			self:stopEffectById(instanceId)
		else
			self:stopEffect(effectId)
		end
	end

	self:serverMsgNoGC("RPC_CS_SyncStopMagnesisEffect", effectId)
end

function ClientMagneticComponent:RPC_SC_SyncPlayMagnesisEffect(effectId)
	self:playEffect(effectId, self.effectExtInfo)
end

function ClientMagneticComponent:RPC_SC_SyncStopMagnesisEffect(effectId)
	self:stopEffect(effectId)
end

function ClientMagneticComponent:RPC_SC_OnMagnesisThrow(targetPos)
	targetPos = Vector3.Convert(targetPos)

	local magneticObj = CSEntityManager:GetPositionAgentByActorId(self.actorId):GetComponent(typeof(CS.FunPlus.WorldX.Entities.EnvObj.MagneticObject))

	if magneticObj then
		magneticObj:Fire(targetPos)
	end
end

return ClientMagneticComponent
