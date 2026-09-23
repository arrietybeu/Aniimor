-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LiveStreaming\\LiveStreamingView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local LiveStreamingView = Class.LightClass("LiveStreamingView", UIView)

function LiveStreamingView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.chatListUList = self.objectReference:GetRefValue("chatListUList")
	self.heartRoot = self.objectReference:GetRefValue("heartRoot")
	self.likeBtnAni = self.objectReference:GetRefValue("likeBtnAni")
	self.liveTitleTxt = self.objectReference:GetRefValue("liveTitleTxt")
	self.liveTitleMask = self.objectReference:GetRefValue("liveTitleMask")
	self.likeTxt = self.objectReference:GetRefValue("likeTxt")
	self.timerCountDown = self.objectReference:GetRefValue("timerCountDown")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
end

return LiveStreamingView
