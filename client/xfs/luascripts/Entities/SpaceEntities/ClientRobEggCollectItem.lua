-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientRobEggCollectItem.lua

local class = require("Core.Framework.Class")
local ClientCollectItem = require("Entities.SpaceEntities.ClientCollectItem")
local EModelUtils = require("Entities.Utils.EModelUtils")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local PhysxComponent = CS.FunPlus.WorldX.Entities.Components.PhysxComponent
local typeof = typeof
local ClientRobEggCollectItem = class.Class("ClientRobEggCollectItem", ClientCollectItem)
local bit = bit
local SNAP_LIFT_HEIGHT = 2
local SNAP_DOWN_LIMIT = 10
local SNAP_CAST_RADIUS = 0.05
local EGG_NEST = Const.ROB_EGG_LOOT_TYPE.EGG_NEST
local snapDownDir

local function getSnapDownDir()
	if snapDownDir == nil then
		snapDownDir = Vector3.New(0, -1, 0)
	end

	return snapDownDir
end

local staticSurfaceMask

local function getStaticSurfaceMask()
	if staticSurfaceMask == nil then
		local layer = ClientConst.LayerDefine

		staticSurfaceMask = CS.FunPlus.WorldX.Const.LayerDefine.STABLE_GROUND_LAYERS
		staticSurfaceMask = bit.bor(staticSurfaceMask, bit.lshift(1, layer.LAYER_ENTITY))
	end

	return staticSurfaceMask
end

local function getOwnerEntity(collider)
	if IsNil(collider) then
		return nil
	end

	local physxComponent = collider:GetComponentInParent(typeof(PhysxComponent))

	if physxComponent == nil then
		local rb = collider.attachedRigidbody

		if NotNil(rb) then
			physxComponent = rb:GetComponent(typeof(PhysxComponent))
		end
	end

	if physxComponent == nil then
		return nil
	end

	local owner = physxComponent.owner

	if IsNil(owner) then
		return nil
	end

	return pg.getEntityByActorId(owner.actorId)
end

local function isValidSnapSurface(collider)
	local ent = getOwnerEntity(collider)

	if ent == nil then
		return true
	end

	return ent.subType == EGG_NEST
end

function ClientRobEggCollectItem:onPrefabModelLoaded()
	self:snapToStaticSurface()
	ClientRobEggCollectItem.super.onPrefabModelLoaded(self)
end

function ClientRobEggCollectItem:snapToStaticSurface()
	if not self.eModel then
		return
	end

	local pos = self:getPosition()

	if not pos then
		return
	end

	local from = Vector3.New(pos.x, pos.y + SNAP_LIFT_HEIGHT, pos.z)
	local castDistance = SNAP_LIFT_HEIGHT + SNAP_DOWN_LIMIT
	local results, count = pg.global.physicsMgr:SphereCastNonAlloc(from, SNAP_CAST_RADIUS, getSnapDownDir(), castDistance, getStaticSurfaceMask(), true)

	if not count or count <= 0 then
		return
	end

	local nearestY, nearestDist

	for idx = 0, count - 1 do
		local raycastHit = results[idx]
		local handle = raycastHit.colliderHandle

		if raycastHit.distance > 0 and isValidSnapSurface(handle.collider) then
			local dist = raycastHit.distance

			if nearestDist == nil or dist < nearestDist then
				nearestDist = dist
				nearestY = raycastHit.point.y
			end
		end
	end

	if nearestY then
		local target = Vector3.Clone(pos)

		target.y = nearestY

		EModelUtils.setAgentPosition(self, target)
	end
end

return ClientRobEggCollectItem
