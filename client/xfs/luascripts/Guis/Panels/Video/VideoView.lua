-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Video\\VideoView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local SysConfigData = require("Data.sys_config_data")
local VideoView = Class.LightClass("VideoView", UIView)
local ToBool = ToBool

function VideoView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.panelObj = self.objectReference:GetRefValue("panelObj")
	self.skipBtn = self.objectReference:GetRefValue("skipBtn")
	self.videoPlayer = self.objectReference:GetRefValue("videoPlayer")
	self.background = self.objectReference:GetRefValue("background")
end

function VideoView:registerObjects()
	return
end

function VideoView:initView()
	return
end

return VideoView
