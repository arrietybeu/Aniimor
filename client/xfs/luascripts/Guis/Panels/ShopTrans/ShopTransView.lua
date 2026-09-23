-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ShopTrans\\ShopTransView.lua

local logger = require("Core.Log.LoggerManager").getLogger("ShopTransView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ShopTransView = Class.LightClass("ShopTransView", UIView)

function ShopTransView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.anim = objectReference:GetRefValue("anim")
	self.mask = objectReference:GetRefValue("mask")
end

return ShopTransView
