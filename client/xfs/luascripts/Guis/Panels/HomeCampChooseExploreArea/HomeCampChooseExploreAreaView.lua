-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCampChooseExploreArea\\HomeCampChooseExploreAreaView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeCampChooseExploreAreaView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomeCampChooseExploreAreaView = Class.LightClass("HomeCampChooseExploreAreaView", UIView)

function HomeCampChooseExploreAreaView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.btnClose2UButton = objectReference:GetRefValue("btnClose2UButton")
	self.titleSDFText = objectReference:GetRefValue("titleSDFText")
	self.tabList = objectReference:GetRefValue("tabList")
	self.listAreaUList = objectReference:GetRefValue("listAreaUList")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.hotkeyList = objectReference:GetRefValue("hotkeyList")
end

function HomeCampChooseExploreAreaView:registerObjects()
	return
end

function HomeCampChooseExploreAreaView:initView()
	return
end

return HomeCampChooseExploreAreaView
