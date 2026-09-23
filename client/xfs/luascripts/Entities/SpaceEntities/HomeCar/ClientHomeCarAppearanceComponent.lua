-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\HomeCar\\ClientHomeCarAppearanceComponent.lua

local Class = require("Core.Framework.Class")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ClientHomeCarAppearanceComponent = Class.Component("ClientHomeCarAppearanceComponent")

function ClientHomeCarAppearanceComponent:setShapeInfo(basicInfo, needUpgradeEffect)
	self.basicInfo = basicInfo
	self.needUpgradeEffect = needUpgradeEffect

	self:refreshCarAppearance()
end

function ClientHomeCarAppearanceComponent:refreshCarAppearance()
	if self.basicInfo then
		local modelView = self.eModel.modelModelView

		ClientModelUtils.applyHomeCarAppearance(modelView, self.basicInfo, self.needUpgradeEffect)
		modelView:RefreshModels(-1, false)
	end
end

function ClientHomeCarAppearanceComponent:setCarDecorationInfo(basicInfo)
	self.decorationInfo = basicInfo

	self:refreshCarDecorationAppearance()
end

function ClientHomeCarAppearanceComponent:refreshCarDecorationAppearance()
	if self.decorationInfo then
		local modelView = self.eModel.modelModelView

		ClientModelUtils.applyHomeCarDecorationAppearance(modelView, self.decorationInfo)
		modelView:RefreshModels(-1, false)
	end
end

return ClientHomeCarAppearanceComponent
