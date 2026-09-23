-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\Home\\ClientEditorTemplateGroupComponent.lua

local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local HomeObjectData = require("Data.home_object_data")
local HomeFacilityData = require("Data.homeland_facility_data")
local Utils = require("Common.Utils.Utils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local AddressDataConst = require("Const.AddressDataConst")
local ClientEditorTemplateGroupComponent = Class.Component("ClientEditorTemplateGroupComponent")

function ClientEditorTemplateGroupComponent:init()
	return
end

function ClientEditorTemplateGroupComponent:setHomeEditState(homeEditState)
	for _, childEntityInfo in pairs(self.childEntities) do
		local childEntity = childEntityInfo.entity

		childEntity:setHomeEditState(homeEditState)
	end
end

function ClientEditorTemplateGroupComponent:updateHomeEditorState()
	local placementValid = Const.HomeEditorErrorType.Normal

	for _, childEntityInfo in pairs(self.childEntities) do
		local childEntity = childEntityInfo.entity

		childEntity:updateHomeEditorState()

		if placementValid == Const.HomeEditorErrorType.Normal then
			placementValid = childEntity.placementValid
		end
	end

	self.placementValid = placementValid

	if self.onUpdateHomeEditorState then
		self:onUpdateHomeEditorState()
	end
end

function ClientEditorTemplateGroupComponent:applyEditorTemplateData(applyData)
	for _, childEntityInfo in pairs(self.childEntities) do
		local childEntity = childEntityInfo.entity

		childEntity:applyEditorTemplateData(applyData)
	end
end

function ClientEditorTemplateGroupComponent:applyWithdrawData(applyData)
	for _, childEntityInfo in pairs(self.childEntities) do
		local childEntity = childEntityInfo.entity

		childEntity:applyWithdrawData(applyData)
	end
end

function ClientEditorTemplateGroupComponent:getEditorEnvRelatedInfo(otherEnt, infoData)
	for _, childEntityInfo in pairs(self.childEntities) do
		local childEntity = childEntityInfo.entity

		childEntity:getEditorEnvRelatedInfo(otherEnt, infoData)
	end
end

return ClientEditorTemplateGroupComponent
