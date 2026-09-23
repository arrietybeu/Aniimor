-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\ClientStudioPlayerVirtualEntity.lua

local Class = require("Core.Framework.Class")
local ClientSimpleVirtualPlayer = require("Entities.ClientSimpleVirtualPlayer")
local PhotographyStudioUtils = require("Utils.PhotographyStudioUtils")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local Const = require("Common.Const.Const")
local ClientStudioPlayerVirtualEntity = Class.Class("ClientStudioPlayerVirtualEntity", ClientSimpleVirtualPlayer)

local function isSameValue(left, right)
	if left == right then
		return true
	end

	if type(left) ~= "table" or type(right) ~= "table" then
		return false
	end

	for slotId, configId in pairs(left) do
		if not isSameValue(configId, right[slotId]) then
			return false
		end
	end

	for slotId, configId in pairs(right) do
		if left[slotId] == nil and configId ~= nil then
			return false
		end
	end

	return true
end

function ClientStudioPlayerVirtualEntity:updateAvatarConfig(avatarConfig)
	local changed = not isSameValue(self.avatarConfig, avatarConfig)

	self.avatarConfig = avatarConfig

	return changed
end

function ClientStudioPlayerVirtualEntity:updateStudioCustomAppearance(curShow, jewelryLastInfos)
	local changed = not isSameValue(self.curShow, curShow) or not isSameValue(self.jewelryLastInfos, jewelryLastInfos)

	self.curShow = curShow
	self.jewelryLastInfos = jewelryLastInfos

	return changed
end

function ClientStudioPlayerVirtualEntity:init(dict)
	ClientStudioPlayerVirtualEntity.super.init(self, dict)

	self.actorId = VirtualEntUtils.getNewVirtualEntActorId()

	if dict then
		self.studioPlayerUid = dict.studioPlayerUid
		self.ownerUid = dict.ownerUid
		self.appearanceMap = dict.appearanceMap
		self.jewelryLastInfos = dict.jewelryLastInfos
		self.studioModelRefreshedCallback = dict.studioModelRefreshedCallback
	end
end

function ClientStudioPlayerVirtualEntity:refreshAppearance()
	if self.eModel and not IsNil(self.eModel.modelModelView) then
		self.eModel.modelModelView.modelInfo.enablePCHighFaceBodyOverride = true
	end

	ClientStudioPlayerVirtualEntity.super.refreshAppearance(self)
end

function ClientStudioPlayerVirtualEntity:onModelRefreshed()
	ClientStudioPlayerVirtualEntity.super.onModelRefreshed(self)

	if self.studioModelRefreshedCallback then
		self.studioModelRefreshedCallback(self)
	end
end

function ClientStudioPlayerVirtualEntity:getStudioPlayerUid()
	return self.studioPlayerUid
end

function ClientStudioPlayerVirtualEntity:getOwnerUid()
	return self.ownerUid
end

function ClientStudioPlayerVirtualEntity:addVirtualEntityComponent()
	ClientStudioPlayerVirtualEntity.super.addVirtualEntityComponent(self)
	self:addEModelMonoComponent(Const.COMPONENT_IDX_PHYSX)
end

function ClientStudioPlayerVirtualEntity:applyAppearanceMap(appearanceMap, force)
	if not force and isSameValue(self.appearanceMap, appearanceMap) then
		return false
	end

	if appearanceMap then
		self.appearanceMap = appearanceMap
	end

	if not self.appearanceMap then
		return false
	end

	if not self.curShow then
		self.curShow = {}
	end

	PhotographyStudioUtils.applyAppearanceMapToCurShow(self.curShow, self.appearanceMap)
	table.clear(self.customShow)
	table.clear(self.customShowPreview)

	for slotId, configId in pairs(self.appearanceMap) do
		self.customShow[slotId] = configId
	end

	if self.refreshAppearance and self.eModel then
		self:refreshAppearance()
	end

	return true
end

return ClientStudioPlayerVirtualEntity
