-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\HomeCar\\ClientHomeCarTemplateEditorComponent.lua

local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local HomeObjectData = require("Data.home_object_data")
local HomeFacilityData = require("Data.homeland_facility_data")
local Utils = require("Common.Utils.Utils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local ClientHomelandUtils = require("Utils.ClientHomelandUtils")
local AddressDataConst = require("Const.AddressDataConst")
local ClientHomeCarTemplateEditorComponent = Class.Component("ClientHomeCarTemplateEditorComponent")

function ClientHomeCarTemplateEditorComponent:updateHomeEditorState()
	self.collideOrnaments = self.collideOrnaments or {}

	table.clear(self.collideOrnaments)

	self.placementValid = self:checkPlacementValid(self.collideOrnaments)

	self:refreshEditorOutline()

	local showArrow = false
	local configData = HomeObjectData[self.homeTemplateId] or {}

	if configData.needForwardIcon == 1 then
		showArrow = true
	end

	local boundHeight = 0

	self:playEditorBoundEffect(ClientConst.EntityEditorBoundType.Default, 8, self:getBaseBoundSize(), pg.game.homeCar.editor:getBottomEffectOffset() + 0.01, pg.game.homeCar.editor:getBaseY(), nil, showArrow, boundHeight)
end

function ClientHomeCarTemplateEditorComponent:checkPlacementValid(colliderOrnaments)
	table.clear(colliderOrnaments)

	local valid = Const.HomeEditorErrorType.Normal

	if self.carGroup and self.carGroup:checkPosCollide(self.ornamentId, colliderOrnaments, 0.01) then
		valid = Const.HomeEditorErrorType.Overlap
	end

	local editor = pg.game.homeCar.editor

	if editor and editor.checkBoundInArea then
		local localPosition = editor:getLocalPosition(self:getPosition())
		local localRotation = editor:getLocalRotation(self:getRotation())

		if not editor:checkBoundInArea(localPosition, localRotation, self:getBoundSize()) then
			valid = Const.HomeEditorErrorType.CrossBoundary
		end

		if valid == Const.HomeEditorErrorType.Normal and editor.displayHideMode and editor.displayHideMode ~= 0 and editor:isHeightOverCamera(localPosition.y) then
			valid = Const.HomeEditorErrorType.OverCameraHeight
		end
	end

	if valid == Const.HomeEditorErrorType.Normal and not ClientHomelandUtils.checkHomelandLoadCanAdd({
		editor = self.editor,
		homeTemplateId = self.homeTemplateId
	}, self.areaId, self.carGroup) then
		valid = Const.HomeEditorErrorType.OverLoad
	end

	return valid
end

function ClientHomeCarTemplateEditorComponent:refreshEditorOutline()
	if self.placementValid == Const.HomeEditorErrorType.Normal then
		self:setEditorOutline(ClientConst.EntityEditorOutlinePriority.Edit, true, AddressDataConst.HOMELAND_OUTLINE_GREEN)
	else
		self:setEditorOutline(ClientConst.EntityEditorOutlinePriority.Edit, true, AddressDataConst.HOMELAND_OUTLINE_RED)
	end
end

function ClientHomeCarTemplateEditorComponent:applyEditorTemplateData(applyData)
	self:applyEditorOrnamentTemplateData(applyData)
end

function ClientHomeCarTemplateEditorComponent:applyWithdrawData(applyData)
	if not self.originEntity then
		return
	end

	table.insert(applyData.removeList, self.originEntity.ornamentId)
end

function ClientHomeCarTemplateEditorComponent:applyEditorOrnamentTemplateData(applyData)
	local editor = pg.game.homeCar.editor

	if self.originEntity then
		applyData.updateData[self.originEntity.ornamentId] = {
			clientOrnamentId = self.ornamentId,
			position = editor:getLocalPosition(self:getPosition()),
			rotation = editor:getLocalRotation(self:getRotation()),
			scale = self:getScale(),
			areaId = self.areaId
		}
	else
		table.insert(applyData.createList, {
			homeTemplateId = self.homeTemplateId,
			clientOrnamentId = self.ornamentId,
			position = editor:getLocalPosition(self:getPosition()),
			rotation = editor:getLocalRotation(self:getRotation()),
			scale = self:getScale(),
			areaId = self.areaId
		})
	end
end

return ClientHomeCarTemplateEditorComponent
