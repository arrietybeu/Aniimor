-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FriendIntimacyExplain\\FriendIntimacyExplainView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local FriendIntimacyExplainView = Class.LightClass("FriendIntimacyExplainView", UIView)

function FriendIntimacyExplainView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.titleUSDFText = objectReference:GetRefValue("titleUSDFText")
	self.scrollRectUScrollRect = objectReference:GetRefValue("scrollRectUScrollRect")
end

function FriendIntimacyExplainView:registerObjects()
	return
end

function FriendIntimacyExplainView:initView()
	return
end

return FriendIntimacyExplainView
