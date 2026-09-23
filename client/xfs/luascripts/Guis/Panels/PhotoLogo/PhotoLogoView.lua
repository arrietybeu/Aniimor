-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PhotoLogo\\PhotoLogoView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PhotoLogoView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PhotoLogoView = Class.LightClass("PhotoLogoView", UIView)

function PhotoLogoView:findObjects()
	return
end

function PhotoLogoView:registerObjects()
	return
end

function PhotoLogoView:initView()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.zhUWidget = self.objectReference:GetRefValue("zhUWidget")
	self.enUWidget = self.objectReference:GetRefValue("enUWidget")
end

return PhotoLogoView
