-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Node\\TopLogoElementSwitchItem.lua

local Class = require("Core.Framework.Class")
local ResLoader = require("GameApp.ResLoad.ResLoader")
local UIConst = require("Const.UIConst")
local CallbackHandler = require("Core.Common.CallbackHandler")
local SysConfigData = require("Data.sys_config_data")
local TopLogoItemBase = require("Guis.Panels.TopLogo.Node.TopLogoItemBase")
local AddressDataConst = require("Const.AddressDataConst")
local TopLogoElementSwitchItem = Class.LightClass("TopLogoElementSwitchItem", TopLogoItemBase)
local elementTypeToResId = {
	[0] = AddressDataConst.UI_Node_TopLogo_Element_Ice,
	AddressDataConst.UI_Node_TopLogo_Element_Water,
	AddressDataConst.UI_Node_TopLogo_Element_Electricity,
	AddressDataConst.UI_Node_TopLogo_Element_Fire
}

function TopLogoElementSwitchItem:ctor(attachTrans, type, maxDistance)
	self.attachTrans = attachTrans
	self.type = type
	self.maxDistance = maxDistance
	self.resId = self:getElementResIdByType(self.type)

	TopLogoElementSwitchItem.super.ctor(self)
end

function TopLogoElementSwitchItem:checkUseCache()
	return false
end

function TopLogoElementSwitchItem:getElementResIdByType(type)
	return elementTypeToResId[type] or ""
end

function TopLogoElementSwitchItem:getTopLogoName()
	return "TopLogoElementSwitchItem_" .. tostring(self.type)
end

function TopLogoElementSwitchItem:initTopLogoAttach()
	self.topLogoScript.maxDistance = self.maxDistance

	self.topLogoScript:AttachToTrans(self.attachTrans)
end

function TopLogoElementSwitchItem:setElementState(state)
	self.state = state

	self:refreshElementTopLogoInfo()
end

function TopLogoElementSwitchItem:refreshTopLogoItemOnLoaded()
	self:refreshElementTopLogoInfo()
end

function TopLogoElementSwitchItem:findObjects()
	self.rootComponent = self.transform:GetComponent("UComponent")
end

function TopLogoElementSwitchItem:onTopLogoDestroy()
	self.rootComponent = nil
end

function TopLogoElementSwitchItem:refreshElementTopLogoInfo()
	if not self.state then
		return
	end

	if self.rootComponent then
		self.rootComponent:TryChangePage("State", self.state or 0)
	end
end

return TopLogoElementSwitchItem
