-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientPosRotComponent.lua

local class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local EModelUtils = require("Entities.Utils.EModelUtils")
local ClientPosRotSyncData = require("Entities.SpaceEntities.CommonComponent.ClientPosRotSyncData")
local PLAYER_DISTANCE_SLOT = ClientPosRotSyncData.PLAYER_DISTANCE_SLOT
local PLAYER_Y_DISTANCE_SLOT = ClientPosRotSyncData.PLAYER_Y_DISTANCE_SLOT
local SYNC_POS_FRAME_COUNT_SLOT = ClientPosRotSyncData.SYNC_POS_FRAME_COUNT_SLOT
local SYNC_ROT_FRAME_COUNT_SLOT = ClientPosRotSyncData.SYNC_ROT_FRAME_COUNT_SLOT
local SYNC_PLAYER_DISTANCE_FRAME_COUNT_SLOT = ClientPosRotSyncData.SYNC_PLAYER_DISTANCE_FRAME_COUNT_SLOT
local SYNC_PLAYER_Y_DISTANCE_FRAME_COUNT_SLOT = ClientPosRotSyncData.SYNC_PLAYER_Y_DISTANCE_FRAME_COUNT_SLOT
local ROTATION_REVISION_SLOT = ClientPosRotSyncData.ROTATION_REVISION_SLOT
local Math_Abs = math.abs
local Quaternion = Quaternion
local Vector3 = Vector3
local RefreshQuaternionReadOnly = Quaternion.refreshReadOnly
local RefreshVector3ReadOnly = Vector3.refreshReadOnly
local ClientPosRotComponent = class.Component("ClientPosRotComponent")

function ClientPosRotComponent:ctor()
	self.posRef = Vector3.NewReadOnly(0, 0, 0)
	self.lastPosRef = Vector3.NewReadOnly(0, 0, 0)
	self.rotRef = Quaternion.NewReadOnly(0, 0, 0, 1)
	self.posSyncData = ClientPosRotSyncData.createPlain()
	self._cacheYawDegree = nil
	self._cacheYawRad = nil
	self._cacheRotationRevision = nil
	self._cacheScaleRef = 1
	self._cachePositionScaleRef = Vector3.NewReadOnly(1, 1, 1)
end

function ClientPosRotComponent:ensurePosSyncData(shareMem)
	local data = self.posSyncData
	local isShared = ClientPosRotSyncData.isShared(data)

	if shareMem ~= true then
		if isShared then
			local plainData = ClientPosRotSyncData.createPlain()

			self.posSyncData = plainData

			ClientPosRotSyncData.destroy(data)
		end

		return
	end

	if isShared then
		return
	end

	local sharedData = ClientPosRotSyncData.createShared(self.posRef, self.lastPosRef, self.rotRef)

	self.posSyncData = sharedData

	ClientPosRotSyncData.destroy(data)
end

function ClientPosRotComponent:createSharedPosSyncData(forceShared)
	local shouldShare = forceShared == true or self.entityCanMove

	if shouldShare and ClientPosRotSyncData.isShared(self.posSyncData) then
		return
	end

	self:ensurePosSyncData(shouldShare)
end

function ClientPosRotComponent:init(dict)
	self.bornPosition = dict.bornPosition
end

function ClientPosRotComponent:initPosRot(posX, posY, posZ, rotX, rotY, rotZ, rotW)
	RefreshVector3ReadOnly(self.posRef, posX, posY, posZ)
	RefreshVector3ReadOnly(self.lastPosRef, posX, posY, posZ)
	RefreshQuaternionReadOnly(self.rotRef, rotX, rotY, rotZ, rotW)

	if self.posSyncData then
		ClientPosRotSyncData.writeInitial(self.posSyncData)
	end
end

function ClientPosRotComponent:setPositionRotation(posX, posY, posZ, rotX, rotY, rotZ, rotW)
	EModelUtils.setAgentPositionAndRotation(self, posX, posY, posZ, rotX, rotY, rotZ, rotW)
end

function ClientPosRotComponent:setPosition(position, transformReason)
	EModelUtils.setAgentPosition(self, position, transformReason)
end

function ClientPosRotComponent:setRotation(rotation, instant, transformReason)
	if instant == nil then
		instant = true
	end

	EModelUtils.setAgentRotation(self, rotation, instant, transformReason)
end

function ClientPosRotComponent:setPositionEx(x, y, z, transformReason)
	EModelUtils.setAgentPositionXYZ(self, x, y, z, transformReason)
end

function ClientPosRotComponent:setRotationEx(x, y, z, w, instant, transformReason)
	if instant == nil then
		instant = true
	end

	EModelUtils.setAgentRotationXYZW(self, x, y, z, w, instant, transformReason)
end

function ClientPosRotComponent:getPosition()
	if FREE_WALK and self.eModel and self.posSyncData[SYNC_POS_FRAME_COUNT_SLOT] ~= Time.frameCount then
		local x, y, z = self.eModel:GetPositionAgentPosEx()

		self:onSyncPos(x, y, z)
	end

	return self.posRef
end

function ClientPosRotComponent:getPositionClone(refTable)
	if refTable then
		Vector3.Copy(refTable, self:getPosition())

		return refTable
	end

	return self:getPosition():Clone()
end

function ClientPosRotComponent:getRotation()
	if FREE_WALK and self.eModel and self.posSyncData[SYNC_ROT_FRAME_COUNT_SLOT] ~= Time.frameCount then
		local x, y, z, w = self.eModel:GetPositionAgentRotationEx()

		self:onSyncRot(x, y, z, w)
	end

	return self.rotRef
end

function ClientPosRotComponent:getLastPosition()
	return self.lastPosRef
end

function ClientPosRotComponent:getYaw()
	self:_refreshRotationCacheRevision()

	if not self._cacheYawDegree then
		Vector3.enableCreateFromCache()

		self._cacheYawDegree = math.deg(self:getYawRad())

		Vector3.disableCreateFromCache()
	end

	return self._cacheYawDegree
end

function ClientPosRotComponent:getYawRad()
	self:_refreshRotationCacheRevision()

	if not self._cacheYawRad then
		Vector3.enableCreateFromCache()

		self._cacheYawRad = Vector3.ToYaw(self:getForward())

		Vector3.disableCreateFromCache()
	end

	return self._cacheYawRad
end

function ClientPosRotComponent:getForward()
	return self:getRotation() * Vector3.constForward
end

function ClientPosRotComponent:_refreshRotationCacheRevision()
	local revision = self.posSyncData[ROTATION_REVISION_SLOT]

	if self._cacheRotationRevision ~= revision then
		self._cacheYawRad = nil
		self._cacheYawDegree = nil
		self._cacheRotationRevision = revision
	end
end

function ClientPosRotComponent:clearRotFrameCache()
	self._cacheYawRad = nil
	self._cacheYawDegree = nil
	self._cacheRotationRevision = nil
end

function ClientPosRotComponent:onSyncPos(x, y, z, playerDistance, playerYDistance, frameCountAdd)
	local frameCount = Time.frameCount + (frameCountAdd or 0)
	local data = self.posSyncData
	local posRef = self.posRef

	RefreshVector3ReadOnly(self.lastPosRef, posRef[1], posRef[2], posRef[3])
	RefreshVector3ReadOnly(posRef, x, y, z)
	ClientPosRotSyncData.writePosition(data, playerDistance, playerYDistance, frameCount)
end

function ClientPosRotComponent:onSyncRot(x, y, z, w, playerDistance, playerYDistance, frameCountAdd)
	local frameCount = Time.frameCount + (frameCountAdd or 0)
	local data = self.posSyncData

	RefreshQuaternionReadOnly(self.rotRef, x, y, z, w)
	self:clearRotFrameCache()
	ClientPosRotSyncData.writeRotation(data, playerDistance, playerYDistance, frameCount)
end

function ClientPosRotComponent:onCommonLateUpdateSyncPosRot(posX, posY, posZ, rotX, rotY, rotZ, rotW, playerDistance, playerYDistance)
	self:onSyncPos(posX, posY, posZ, playerDistance, playerYDistance, 1)
	self:onSyncRot(rotX, rotY, rotZ, rotW, playerDistance, playerYDistance, 1)
end

function ClientPosRotComponent:getPlayerDistance(deltaFrame)
	local data = self.posSyncData

	if not data then
		return 9999
	end

	deltaFrame = deltaFrame or 0

	if deltaFrame < Time.frameCount - data[SYNC_PLAYER_DISTANCE_FRAME_COUNT_SLOT] then
		local playerDistance = Vector3.HoriDistance(self.posRef, pg.me.posRef)

		ClientPosRotSyncData.writePlayerDistance(data, playerDistance, Time.frameCount)
	end

	return data[PLAYER_DISTANCE_SLOT]
end

function ClientPosRotComponent:getPlayerYDistance(deltaFrame)
	local data = self.posSyncData

	if not data then
		return 9999
	end

	deltaFrame = deltaFrame or 0

	if deltaFrame < Time.frameCount - data[SYNC_PLAYER_Y_DISTANCE_FRAME_COUNT_SLOT] then
		local playerYDistance = Math_Abs(self.posRef.y - pg.me.posRef.y)

		ClientPosRotSyncData.writePlayerYDistance(data, playerYDistance, Time.frameCount)
	end

	return data[PLAYER_Y_DISTANCE_SLOT]
end

function ClientPosRotComponent:getScaleNumber()
	return self._cacheScaleRef
end

function ClientPosRotComponent:setScaleNumber(scale)
	if self.eModel then
		self.eModel:SetModelViewLocalScale(scale)
		self:onSyncScale(scale)
	end
end

function ClientPosRotComponent:onSyncScale(scale)
	self._cacheScaleRef = scale
end

function ClientPosRotComponent:getPositionAgentPosition()
	local data = self.posSyncData

	if self.eModel and data[SYNC_POS_FRAME_COUNT_SLOT] ~= Time.frameCount then
		local x, y, z = self.eModel:GetPositionAgentPosEx()

		RefreshVector3ReadOnly(self.posRef, x, y, z)
		ClientPosRotSyncData.writeAgentPosition(data, Time.frameCount)
	end

	return self.posRef
end

function ClientPosRotComponent:getPositionAgentRotation()
	local data = self.posSyncData

	if self.eModel and data[SYNC_ROT_FRAME_COUNT_SLOT] ~= Time.frameCount then
		local x, y, z, w = self.eModel:GetPositionAgentRotationEx()

		RefreshQuaternionReadOnly(self.rotRef, x, y, z, w)
		self:clearRotFrameCache()
		ClientPosRotSyncData.writeAgentRotation(data, Time.frameCount)
	end

	return self.rotRef
end

function ClientPosRotComponent:getPositionAgentScale()
	return self._cachePositionScaleRef
end

function ClientPosRotComponent:setPositionAgentScale(scaleX, scaleY, scaleZ)
	if self.eModel then
		scaleY = scaleY or scaleX
		scaleZ = scaleZ or scaleX

		self.eModel:SetPositionAgentLocalScaleEx(scaleX, scaleY, scaleZ)
		self:onSyncPositionAgentScale(scaleX, scaleY, scaleZ)
	end
end

function ClientPosRotComponent:onSyncPositionAgentScale(scaleX, scaleY, scaleZ)
	RefreshVector3ReadOnly(self._cachePositionScaleRef, scaleX, scaleY, scaleZ)
end

function ClientPosRotComponent:setPositionAgentLocalPos(posX, posY, posZ)
	if self.eModel then
		self.eModel:SetPositionAgentLocalPosEx(posX, posY, posZ)
	end
end

function ClientPosRotComponent:setPositionAgentLocalRotation(rotationX, rotationY, rotationZ, rotationW)
	if self.eModel then
		self.eModel:SetPositionAgentLocalRotationQuatEx(rotationX, rotationY, rotationZ, rotationW)
	end
end

function ClientPosRotComponent:destroy()
	ClientPosRotSyncData.destroy(self.posSyncData)

	self.posSyncData = nil
	self.posRef = nil
	self.lastPosRef = nil
	self.rotRef = nil
end

return ClientPosRotComponent
