-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BlackBg\\BlackBgView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local BlackBgView = Class.LightClass("BlackBgView", UIView)

function BlackBgView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.blackBgImage = self.objectReference:GetRefValue("blackBgUImage")
end

function BlackBgView:registerObjects()
	return
end

function BlackBgView:initView()
	return
end

return BlackBgView
