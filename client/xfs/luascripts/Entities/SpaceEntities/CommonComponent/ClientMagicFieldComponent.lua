-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientMagicFieldComponent.lua

local class = require("Core.Framework.Class")
local ClientDebugUtils = require("Utils.ClientDebugUtils")
local AbilityConst = require("Common.Const.AbilityConst")
local MagicFieldComponentBase = require("Common.Components.MagicFieldComponentBase")
local EModelUtils = require("Entities.Utils.EModelUtils")
local ClientMagicFieldComponent = class.Component("ClientMagicFieldComponent", MagicFieldComponentBase)
local PhysxComponent = CS.FunPlus.WorldX.Entities.Components.PhysxComponent

function ClientMagicFieldComponent:init(spawnParams)
	ClientMagicFieldComponent.super.init(self, spawnParams)

	self.currEffects = {}
	self.master = pg.getEntityByActorId(self.masterActorId)

	return true
end

function ClientMagicFieldComponent:start()
	ClientMagicFieldComponent.super.start(self)
	self:setPosRot(self.position, self.rotation)
	self:applyTimeScale()
	self:attachEffects()
end

function ClientMagicFieldComponent:preDestroy()
	self:detachEffects()
end

function ClientMagicFieldComponent:destroy()
	ClientMagicFieldComponent.super.destroy(self)
end

function ClientMagicFieldComponent:activate(deltaSeconds)
	ClientMagicFieldComponent.super.activate(self, deltaSeconds)
	self:drawDebugShape()
end

function ClientMagicFieldComponent:onEnterSpace()
	self.timeScaleMgr = self.space.timeScaleMgr
end

function ClientMagicFieldComponent:setPosRot(pos, rot)
	if pos == nil then
		return
	end

	self.position = pos
	self.rot = rot

	if self.eModel and pos ~= nil and rot ~= nil then
		EModelUtils.setAgentPositionAndRotation(self, pos, rot)
	end

	if self.aoi then
		if pos then
			self.aoi:setPosition(pos.x, pos.y, pos.z)
		end

		if rot then
			self.aoi:setRotation(rot.x, rot.y, rot.z, rot.w)
		end
	end
end

function ClientMagicFieldComponent:attachEffects()
	self:detachEffects()

	if not self.templateData or not self.templateData.attachEffects then
		return
	end

	local effects = self.templateData.attachEffects or {}

	for _, effectKey in ipairs(effects) do
		self.currEffects[#self.currEffects + 1] = self:plaEffect(effectKey)
	end
end

function ClientMagicFieldComponent:detachEffects()
	for _, effectId in pairs(self.currEffects) do
		if effectId ~= nil then
			self:stopEffect(effectId)
		end
	end

	self.currEffects = {}
end

function ClientMagicFieldComponent:refreshPosition(deltaSeconds)
	ClientMagicFieldComponent.super.refreshPosition(self, deltaSeconds)
end

function ClientMagicFieldComponent:refreshExtent(deltaSeconds)
	ClientMagicFieldComponent.super.refreshExtent(self, deltaSeconds)
end

function ClientMagicFieldComponent:drawDebugShape()
	local shapeKind = AbilityConst.LX_GEOMETRY_TYPE_PARSER[self.templateData.shapeKind or ""] or -1
	local shapeArgs = self.templateData.shapeArgs or {}

	ClientDebugUtils.drawDebugHitBoxMesh(self.position, self.rotation, shapeKind, shapeArgs)
end

return ClientMagicFieldComponent
