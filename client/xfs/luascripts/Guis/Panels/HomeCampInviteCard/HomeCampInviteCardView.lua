-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCampInviteCard\\HomeCampInviteCardView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeCampInviteCardView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomeCampInviteCardView = Class.LightClass("HomeCampInviteCardView", UIView)

function HomeCampInviteCardView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.textName = objectReference:GetRefValue("textName")
	self.textDetails = objectReference:GetRefValue("textDetails")
	self.sendName = objectReference:GetRefValue("sendName")
	self.textID = objectReference:GetRefValue("textID")
	self.acceptBtn = objectReference:GetRefValue("acceptBtn")
	self.closeBtn = objectReference:GetRefValue("closeBtn")
	self.textTitle = objectReference:GetRefValue("textTitle")
	self.inviteHint = objectReference:GetRefValue("inviteHint")
	self.acceptBtnText = objectReference:GetRefValue("acceptBtnText")
end

function HomeCampInviteCardView:registerObjects()
	return
end

function HomeCampInviteCardView:initView()
	return
end

return HomeCampInviteCardView
