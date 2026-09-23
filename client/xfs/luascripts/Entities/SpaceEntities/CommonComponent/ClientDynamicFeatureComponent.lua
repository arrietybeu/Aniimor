-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientDynamicFeatureComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local ClientDynamicFeatureComponent = Class.Component("ClientDynamicFeatureComponent")

function ClientDynamicFeatureComponent:ctor()
	self.features = {}
end

function ClientDynamicFeatureComponent:init(initDict)
	if initDict.dynamicFeatures then
		for name, data in pairs(initDict.dynamicFeatures) do
			self:addFeature(name, data)
		end
	end
end

function ClientDynamicFeatureComponent:onEnterSpace()
	for _, feature in pairs(self.features) do
		feature:onEnterSpace()
	end
end

function ClientDynamicFeatureComponent:onLeaveSpace()
	for _, feature in pairs(self.features) do
		feature:onLeaveSpace()
	end
end

function ClientDynamicFeatureComponent:destroy()
	for name, feature in pairs(self.features) do
		feature:onLeaveSpace()
		feature:destroy()

		self[name] = nil
	end

	self.features = {}
end

function ClientDynamicFeatureComponent:EVENT_onModelLoaded()
	for _, feature in pairs(self.features) do
		feature:onMasterModelLoaded()
	end
end

function ClientDynamicFeatureComponent:EVENT_OnModelRefreshed()
	for _, feature in pairs(self.features) do
		feature:onMasterModelLoaded()
	end
end

function ClientDynamicFeatureComponent:onMasterSpecialStateUpdate()
	for _, feature in pairs(self.features) do
		if feature.onMasterSpecialStateUpdate then
			feature:onMasterSpecialStateUpdate()
		end
	end
end

function ClientDynamicFeatureComponent:RPC_SC_AddFeature(name, data)
	self:addFeature(name, data)
end

function ClientDynamicFeatureComponent:RPC_SC_RemoveFeature(name)
	self:removeFeature(name)
end

function ClientDynamicFeatureComponent:RPC_SC_FeatureMsg(featureName, funcName, args)
	local feature = self.features[featureName]

	if not feature then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("%s RPC_SC_FeatureMsg feature %s not exist", self:repr(), featureName)
		end

		return
	end

	if not feature[funcName] then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("%s RPC_SC_FeatureMsg feature %s has no method %s", self:repr(), featureName, funcName)
		end

		return
	end

	feature[funcName](feature, unpack(args))
end

function ClientDynamicFeatureComponent:addFeature(name, data)
	self:removeFeature(name)

	local featurePath = "Entities.SpaceEntities.DynamicFeature." .. name
	local status, featureClass = pcall(require, featurePath)

	if status then
		local feature = featureClass.new()

		self.features[name] = feature
		self[name] = feature
		data = data or {}
		data.featureName = name

		feature:init(self, data)

		if self.space then
			feature:onEnterSpace()
		end

		if self.isModelLoaded then
			feature:onMasterModelLoaded()
		end
	end
end

function ClientDynamicFeatureComponent:removeFeature(name)
	local oldFeature = self.features[name]

	if oldFeature then
		oldFeature:onLeaveSpace()
		oldFeature:destroy()
	end

	self.features[name] = nil
	self[name] = nil
end

function ClientDynamicFeatureComponent:EVENT_LoseControlled()
	local stickerFeature = self.features.StickerFeature

	if stickerFeature then
		stickerFeature:refreshStickEnable()
	end
end

function ClientDynamicFeatureComponent:EVENT_OnLifterIdChanged()
	for _, feature in pairs(self.features) do
		if feature.EVENT_OnLifterIdChanged then
			feature:EVENT_OnLifterIdChanged()
		end
	end
end

function ClientDynamicFeatureComponent:onTakeDamage()
	local stickerFeature = self.features.StickerFeature

	if stickerFeature then
		stickerFeature:serverMsg("RPC_CS_ClearStick")
	end
end

function ClientDynamicFeatureComponent:EVENT_OnCharacterStateChange(oldState, newState)
	local stickerFeature = self.features.StickerFeature

	if stickerFeature then
		stickerFeature:refreshStickEnable()
	end
end

return ClientDynamicFeatureComponent
