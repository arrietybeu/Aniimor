-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Morphling\\MorphlingView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local MorphlingView = Class.LightClass("MorphlingView", UIView)

function MorphlingView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.uiRoot = objectReference:GetRefValue("uiRoot")
end

function MorphlingView:registerObjects()
	return
end

function MorphlingView:initView()
	return
end

return MorphlingView
