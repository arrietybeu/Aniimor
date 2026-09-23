-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SubtitlesPanel\\SubtitlesPanelView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local SubtitlesPanelView = Class.LightClass("SubtitlesPanelView", UIView)

function SubtitlesPanelView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.infoTxt = self.objectReference:GetRefValue("infoTxt")
end

function SubtitlesPanelView:registerObjects()
	return
end

function SubtitlesPanelView:initView()
	return
end

return SubtitlesPanelView
