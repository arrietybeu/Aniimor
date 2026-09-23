-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Node\\TopLogoItemInteractable.lua

local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local TopLogoItem = require("Guis.Panels.TopLogo.Node.TopLogoItem")
local TopLogoInteractSignComponent = require("Guis.Panels.TopLogo.Component.TopLogoInteractSignComponent")
local TopLogoItemInteractable = Class.LightClass("TopLogoItemInteractable", TopLogoItem)

function TopLogoItemInteractable:ctor(entity)
	TopLogoItemInteractable.super.ctor(self, entity)
end

function TopLogoItemInteractable:destroy()
	TopLogoItemInteractable.super.destroy(self)
end

function TopLogoItemInteractable:findObjects()
	return
end

function TopLogoItemInteractable:setTopLogoAttachTrans()
	local eModel = self.entity.eModel

	if eModel == nil then
		return
	end

	if NotNil(self.topLogoScript) then
		local iconOffset = Vector3(0, 0, 0)
		local offset = self.entity.topLogoData.height
		local indicatorIconHeight = self.entity.indicatorIconHeight

		iconOffset[2] = offset or 0

		if indicatorIconHeight then
			iconOffset[1] = indicatorIconHeight[1] or 0
			iconOffset[2] = iconOffset[2] + (indicatorIconHeight[2] or 0)
			iconOffset[3] = indicatorIconHeight[3] or 0
		end

		self.topLogoScript:SetOffset(iconOffset, Vector2.zero)
		self.topLogoScript:AttachToEntity(eModel)
	end
end

function TopLogoItemInteractable:createLogicComponents()
	self.components = {
		[UIConst.TOPLOGO_COMPONENT.INTERACT_SIGN] = TopLogoInteractSignComponent.new(nil, self)
	}

	self:m_classifyComponents()
end

return TopLogoItemInteractable
