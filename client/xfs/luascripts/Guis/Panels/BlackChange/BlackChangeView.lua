-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BlackChange\\BlackChangeView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local BlackChangeView = Class.LightClass("BlackChangeView", UIView)

function BlackChangeView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.blackImage = self.objectReference:GetRefValue("blackUImage")
end

function BlackChangeView:registerObjects()
	return
end

function BlackChangeView:initView()
	return
end

return BlackChangeView
