-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Node\\PartTopLogoItem.lua

local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local TopLogoCombatComponent = require("Guis.Panels.TopLogo.Component.TopLogoCombatComponent")
local TopLogoItemBase = require("Guis.Panels.TopLogo.Node.TopLogoItemBase")
local PartTopLogoItem = Class.LightClass("PartTopLogoItem", TopLogoItemBase)

function PartTopLogoItem:ctor(entity, partId)
	PartTopLogoItem.super.ctor(self)

	self.entity = entity
	self.partId = partId
end

function PartTopLogoItem:destroy()
	PartTopLogoItem.super.destroy(self)
end

function PartTopLogoItem:getTopLogoName()
	return string.format("PartTopLogoItem_%s_%s", self.entity.actorId, self.partId)
end

function PartTopLogoItem:initTopLogoAttach()
	self:setTopLogoAttachTrans(self.partId)
end

function PartTopLogoItem:findObjects()
	return
end

function PartTopLogoItem:createLogicComponents()
	self.components = {
		[UIConst.TOPLOGO_COMPONENT.COMBAT] = TopLogoCombatComponent.new(nil, self)
	}

	self:m_classifyComponents()
end

local _offset = Vector3(0, 0, 0)
local _zero = Vector2.zero

function PartTopLogoItem:setTopLogoAttachTrans(partId)
	self.partId = partId or 0

	local offset = 0

	offset = self.entity.topLogoData.height

	if NotNil(self.topLogoScript) then
		self.topLogoScript:AttachToTransByActorId(self.entity.actorId)

		_offset[2] = offset or 0

		self.topLogoScript:SetOffset(_offset, _zero)
	end
end

return PartTopLogoItem
