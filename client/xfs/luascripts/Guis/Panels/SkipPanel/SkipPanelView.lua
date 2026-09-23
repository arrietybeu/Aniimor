-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SkipPanel\\SkipPanelView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local SkipPanelView = Class.LightClass("SkipPanelView", UIView)

function SkipPanelView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnSkipUButton = self.objectReference:GetRefValue("btnSkipUButton")
	self.btnSkipHotKeyContent = self.objectReference:GetRefValue("btnSkipHotKeyContent")
	self.txtNameUSDFText = self.objectReference:GetRefValue("txtNameUSDFText")
end

function SkipPanelView:registerObjects()
	return
end

function SkipPanelView:initView()
	return
end

return SkipPanelView
