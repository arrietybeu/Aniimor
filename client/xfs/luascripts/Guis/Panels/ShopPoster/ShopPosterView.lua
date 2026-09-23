-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ShopPoster\\ShopPosterView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ShopPosterView = Class.LightClass("ShopPosterView", UIView)

function ShopPosterView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnRightUButton = self.objectReference:GetRefValue("btnRightUButton")
	self.btnLeftUButton = self.objectReference:GetRefValue("btnLeftUButton")
	self.listPointUList = self.objectReference:GetRefValue("listPointUList")
	self.imgList = self.objectReference:GetRefValue("imgList")
	self.root = self.objectReference:GetRefValue("root")
end

function ShopPosterView:initView()
	return
end

return ShopPosterView
