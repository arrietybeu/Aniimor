-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandSeasonIntro\\HomelandSeasonIntroView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandSeasonIntroView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomelandSeasonIntroView = Class.LightClass("HomelandSeasonIntroView", UIView)

function HomelandSeasonIntroView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.tabListUList = objectReference:GetRefValue("tabListUList")
	self.contentListUList = objectReference:GetRefValue("contentListUList")
	self.rootCmp = objectReference:GetRefValue("rootCmp")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.txtTitle = objectReference:GetRefValue("txtTitle")
end

function HomelandSeasonIntroView:registerObjects()
	return
end

function HomelandSeasonIntroView:initView()
	return
end

return HomelandSeasonIntroView
