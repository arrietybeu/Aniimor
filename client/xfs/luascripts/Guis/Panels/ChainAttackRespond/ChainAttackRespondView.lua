-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ChainAttackRespond\\ChainAttackRespondView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ChainAttackRespondView = Class.LightClass("ChainAttackRespondView", UIView)

function ChainAttackRespondView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.clickBtn = objectReference:GetRefValue("clickBtn")
	self.progressUProgress = objectReference:GetRefValue("progressUProgress")
	self.keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")
end

return ChainAttackRespondView
