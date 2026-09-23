-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SimpleTextTip\\SimpleTextTipView.lua

local logger = require("Core.Log.LoggerManager").getLogger("SimpleTextTipView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local SimpleTextTipView = Class.LightClass("SimpleTextTipView", UIView)

function SimpleTextTipView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.txtNameUSDFText = self.objectReference:GetRefValue("txtNameUSDFText")
	self.rootCmp = self.transform:GetComponent("UPopupForm")
end

function SimpleTextTipView:registerObjects()
	return
end

function SimpleTextTipView:initView()
	return
end

return SimpleTextTipView
