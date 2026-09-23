-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\HomeCar\\ClientHomeCarEditorComponent.lua

local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local AddressDataConst = require("Const.AddressDataConst")
local ClientHomeCarEditorComponent = Class.Component("ClientHomeCarEditorComponent")

function ClientHomeCarEditorComponent:start()
	self:updateEditorEffect()
end

function ClientHomeCarEditorComponent:setHomeEditState(homeEditState)
	self.homeEditState = homeEditState

	self:updateEditorEffect()
	self:updateHomeEditorState()
end

function ClientHomeCarEditorComponent:getOrnamentLayer()
	local configData = self:getHomelandConfigData()

	if configData.canEditYAxis or configData.overlapAllowed then
		return Const.HOMELAND_ORNAMENT_LAYER.None
	end

	return Const.HOMELAND_ORNAMENT_LAYER.Default
end

function ClientHomeCarEditorComponent:updateEditorEffect()
	if not self.ornamentId then
		return
	end

	local boundHeight = 0

	if self.isPreview or self.homeEditState == ClientConst.HomeEntEffectType.Edit then
		local showArrow = self:getHomelandConfigData().needForwardIcon == 1

		self:playEditorBoundEffect(ClientConst.EntityEditorBoundType.Default, 8, self:getBaseBoundSize(), pg.game.homeCar.editor:getBottomEffectOffset() + 0.01, pg.game.homeCar.editor:getBaseY(), nil, showArrow, boundHeight)
	else
		self:stopEditorBoundEffect(ClientConst.EntityEditorBoundType.Default)
	end
end

function ClientHomeCarEditorComponent:getBasePlaceYaw()
	return self.carGroup.baseRotation:GetEulerAnglesY()
end

return ClientHomeCarEditorComponent
