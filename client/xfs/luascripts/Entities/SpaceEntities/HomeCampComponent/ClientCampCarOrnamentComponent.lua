-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\HomeCampComponent\\ClientCampCarOrnamentComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local ClientHomeBaseOrnamentComponent = require("Entities.SpaceEntities.HomeBaseComponent.ClientHomeBaseOrnamentComponent")
local HomeObjectData = require("Data.home_object_data")
local Const = require("Common.Const.Const")
local MessageName = require("Const.MessageName")
local AddressDataConst = require("Const.AddressDataConst")
local SceneUtils = require("Common.Utils.SceneUtils")
local HomeCampData = require("Data.home_camp_data")
local EffectConst = require("Const.EffectConst")
local ClientCampCarOrnamentComponent = Class.Component("ClientCampCarOrnamentComponent", ClientHomeBaseOrnamentComponent)

function ClientCampCarOrnamentComponent:start()
	self:rebuildHomeBlueprintBuildGroupIndexCache()
	self:loadAllHomeCarEntities()
	self:createHomeCarPlaceHolder()
end

function ClientCampCarOrnamentComponent:rebuildHomeBlueprintBuildGroupIndexCache()
	self.homeBlueprintBuildGroupIndexCache = self.homeBlueprintBuildGroupIndexCache or {}

	table.clear(self.homeBlueprintBuildGroupIndexCache)

	for groupIndex, groupInfo in ipairs(self.homeBlueprintGroupInfo or EMPTY_TABLE) do
		local ornamentIds = groupInfo and groupInfo.ornamentIds

		self.logger:info("xzt on_homeBlueprintGroupInfo_changed 111111", inspect(groupInfo))

		for _, ornamentId in ipairs(ornamentIds or EMPTY_TABLE) do
			self.homeBlueprintBuildGroupIndexCache[ornamentId] = groupIndex
		end
	end
end

function ClientCampCarOrnamentComponent:getHomeBlueprintBuildGroupByOrnamentId(ornamentId)
	local groupIndex = self.homeBlueprintBuildGroupIndexCache and self.homeBlueprintBuildGroupIndexCache[ornamentId]

	if not groupIndex then
		return
	end

	local groupInfo = self.homeBlueprintGroupInfo and self.homeBlueprintGroupInfo[groupIndex]

	if not groupInfo or not groupInfo.ornamentIds then
		return
	end

	return groupIndex, groupInfo
end

function ClientCampCarOrnamentComponent:on_homeBlueprintGroupInfo_changed()
	self.logger:info("xzt on_homeBlueprintGroupInfo_changed 0000000")
	self:rebuildHomeBlueprintBuildGroupIndexCache()
end

function ClientCampCarOrnamentComponent:onOrnamentDataChanged(key, ornamentInfo)
	self.carGroup:updateHomeCarEntity(key, ornamentInfo)
	facade:sendMsgToUI(MessageName.HOMELAND_ORNAMENT_CHANGED, {
		ornamentId = key
	})
	self:postComponentMethod("EVENT_onOrnamentChanged", key)
end

function ClientCampCarOrnamentComponent:onOrnamentDataAdded(k, ornamentInfo)
	self.carGroup:createHomeCarEntity(k, ornamentInfo)
	facade:sendMsgToUI(MessageName.HOMELAND_ORNAMENT_CHANGED, {
		ornamentId = k
	})
	self:postComponentMethod("EVENT_onOrnamentAdd", k)
end

function ClientCampCarOrnamentComponent:onOrnamentDataDeleted(k)
	self.carGroup:destroyHomeCarEntityById(k)
	facade:sendMsgToUI(MessageName.HOMELAND_ORNAMENT_CHANGED, {
		ornamentId = k
	})
	self:postComponentMethod("EVENT_onOrnamentRemove", k)
end

function ClientCampCarOrnamentComponent:loadAllHomeCarEntities()
	self.carGroup:createHomeCarEntities(self.ornament)
end

function ClientCampCarOrnamentComponent:createHomeCarPlaceHolder()
	do return end

	if not self.placeHolderEffId then
		local campData = HomeCampData[self.campId]
		local placeConfig = self:getConfigData()
		local sceneId = SceneUtils.getMainSceneId(campData.sceneId)
		local pos, rot = SceneUtils.getCommonBasicsPosition(sceneId, placeConfig.ornamentCenter)
		local effectConfig = {
			position = pos,
			rotation = rot.eulerAngles,
			mountType = EffectConst.MountType.World,
			followType = EffectConst.FollowType.Global
		}

		self.placeHolderEffId = self:playEffectRaw(AddressDataConst.HOME_CAMP_PLACEHOLDER, effectConfig)
	end
end

function ClientCampCarOrnamentComponent:destroyHomeCarPlaceHolder()
	if self.placeHolderEffId then
		self:stopEffectById(self.placeHolderEffId)

		self.placeHolderEffId = nil
	end
end

return ClientCampCarOrnamentComponent
