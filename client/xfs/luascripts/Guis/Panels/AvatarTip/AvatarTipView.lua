-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AvatarTip\\AvatarTipView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local AvatarTipView = Class.LightClass("AvatarTipView", UIView)

function AvatarTipView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootTransform = self.objectReference:GetRefValue("rootTransform")
end

function AvatarTipView:registerObjects()
	local objectReference = self.rootTransform:GetComponent("ObjectReference")

	self.contextText = objectReference:GetRefValue("contextText")
	self.cancelBtn = objectReference:GetRefValue("cancelBtn")
	self.confirmBtn = objectReference:GetRefValue("confirmBtn")
end

function AvatarTipView:initView()
	return
end

return AvatarTipView
