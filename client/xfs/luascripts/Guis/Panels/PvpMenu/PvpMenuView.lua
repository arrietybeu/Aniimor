-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpMenu\\PvpMenuView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PvpMenuView = Class.LightClass("PvpMenuView", UIView)

function PvpMenuView:findObjects()
	self.component = self.transform:GetComponent("UComponent")
	self.animation = self.transform:GetComponent("Animation")
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.pageMain = self.objectReference:GetRefValue("pageMain")
	self.page1 = self.objectReference:GetRefValue("page1")
	self.root = self.objectReference:GetRefValue("root")
	self.consoleKeyUList = self.objectReference:GetRefValue("consoleKeyUList")
	self.btnInviteFriend = self.objectReference:GetRefValue("btnInviteFriend")
end

function PvpMenuView:registerObjects()
	return
end

function PvpMenuView:initView()
	return
end

return PvpMenuView
