-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCampVisit\\HomeCampVisitView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeCampVisitView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomeCampVisitView = Class.LightClass("HomeCampVisitView", UIView)

function HomeCampVisitView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.closeBtn = objectReference:GetRefValue("closeBtn")
	self.closeBtnBg = objectReference:GetRefValue("closeBtnBg")
	self.friendCampList = objectReference:GetRefValue("friendCampList")
	self.allCampList = objectReference:GetRefValue("allCampList")
	self.titleTxt = objectReference:GetRefValue("titleTxt")
	self.btnSearch = objectReference:GetRefValue("btnSearch")
	self.btnRefresh = objectReference:GetRefValue("btnRefresh")
	self.inputField = objectReference:GetRefValue("inputField")
	self.friendBtn = objectReference:GetRefValue("friendBtn")
	self.allBtn = objectReference:GetRefValue("allBtn")
	self.emptyUWidget = objectReference:GetRefValue("emptyUWidget")
	self.txtNameFriendUSDFText = objectReference:GetRefValue("txtNameFriendUSDFText")
	self.txtNameAllUSDFText = objectReference:GetRefValue("txtNameAllUSDFText")
end

function HomeCampVisitView:registerObjects()
	return
end

function HomeCampVisitView:initView()
	return
end

return HomeCampVisitView
