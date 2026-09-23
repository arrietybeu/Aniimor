-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PlotPhoneCall\\PlotPhoneCallView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PlotPhoneCallView = Class.LightClass("PlotPhoneCallView", UIView)

function PlotPhoneCallView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.panelUComponent = self.objectReference:GetRefValue("panelUComponent")
	self.imgRoleUImage = self.objectReference:GetRefValue("imgRoleUImage")
	self.nameUText = self.objectReference:GetRefValue("nameUText")
	self.videoPlayer = self.objectReference:GetRefValue("videoPlayer")
	self.playBtn = self.objectReference:GetRefValue("playBtn")
	self.picUImage = self.objectReference:GetRefValue("picUImage")
	self.panelAvatarUComponent = self.objectReference:GetRefValue("panelAvatarUComponent")
	self.panelRectTransform = self.objectReference:GetRefValue("panelRectTransform")
	self.connectUText = self.objectReference:GetRefValue("connectUText")
end

function PlotPhoneCallView:registerObjects()
	return
end

function PlotPhoneCallView:initView()
	return
end

return PlotPhoneCallView
