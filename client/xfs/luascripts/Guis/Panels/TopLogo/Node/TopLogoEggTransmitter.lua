-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Node\\TopLogoEggTransmitter.lua

local Class = require("Core.Framework.Class")
local AddressDataConst = require("Const.AddressDataConst")
local EventConst = require("Const.EventConst")
local UIConst = require("Const.UIConst")
local TopLogoItem = require("Guis.Panels.TopLogo.Node.TopLogoItem")
local TopLogoEggStateComponent = require("Guis.Panels.TopLogo.Component.TopLogoEggStateComponent")
local TopLogoEggTransmitter = Class.LightClass("TopLogoEggTransmitter", TopLogoItem)

function TopLogoEggTransmitter:ctor(entity)
	TopLogoEggTransmitter.super.ctor(self, entity)
end

function TopLogoEggTransmitter:destroy()
	TopLogoEggTransmitter.super.destroy(self)
end

function TopLogoEggTransmitter:findObjects()
	return
end

function TopLogoEggTransmitter:createLogicComponents()
	self.components = {
		[UIConst.TOPLOGO_COMPONENT.GRAB_EGG_STATE] = TopLogoEggStateComponent.new(nil, self)
	}

	self:m_classifyComponents()
end

function TopLogoEggTransmitter:switchEggTransState(state)
	return
end

return TopLogoEggTransmitter
