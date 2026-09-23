-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TextLink\\TextLinkView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TextLinkView = Class.LightClass("TextLinkView", UIView)

function TextLinkView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listUList = objectReference:GetRefValue("listUList")
	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
end

function TextLinkView:registerObjects()
	return
end

function TextLinkView:initView()
	return
end

return TextLinkView
