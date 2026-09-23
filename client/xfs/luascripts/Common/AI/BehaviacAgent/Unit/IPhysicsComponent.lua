-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\IPhysicsComponent.lua

local class = require("Core.Framework.Class")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local layer = require("Common.Const.PhysicsLayerConst")
local Utils = require("Common.Utils.Utils")
local bit = bit
local math_deg = math.deg
local IPhysicsComponent = class.Component("IPhysicsComponent")

function IPhysicsComponent:getRaycastEntityActorId(localYawDegree, distance)
	if Utils.checkClient() then
		Vector3.enableCreateFromCache()

		local myPos = self.ent:getPosition():Clone()

		myPos.y = myPos.y + self.ent:getRealHeight() / 2

		local direction = Quaternion.AngleAxis(math_deg(self.ent:getRotation():ToYaw()) + localYawDegree, Vector3.up):MulVec3(Vector3.forward)
		local layerMask = bit.lshift(1, layer.eDefault) + bit.lshift(1, layer.eEntity) + bit.lshift(1, layer.ePlayer) + bit.lshift(1, layer.ePet)
		local hitInfo, ret = PhysicsUtils.getRaycastInfo(myPos, direction, distance, layerMask)

		Vector3.disableCreateFromCache()

		local handle = hitInfo.colliderHandle

		if ret and handle:IsDyncmicCollider() then
			local collider = handle.collider
			local physxComponent = collider.transform and collider.transform:GetComponent(typeof(CS.FunPlus.WorldX.Entities.Components.PhysxComponent))

			if physxComponent then
				return physxComponent.tagId
			end
		end
	end

	return 0
end

return IPhysicsComponent
