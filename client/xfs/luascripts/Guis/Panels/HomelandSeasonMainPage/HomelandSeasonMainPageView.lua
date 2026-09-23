-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandSeasonMainPage\\HomelandSeasonMainPageView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandSeasonMainPageView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomelandSeasonMainPageView = Class.LightClass("HomelandSeasonMainPageView", UIView)

function HomelandSeasonMainPageView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.txtTitle = objectReference:GetRefValue("txtTitle")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.shopBtn = objectReference:GetRefValue("shopBtn")
	self.bigTxtTitle = objectReference:GetRefValue("bigTxtTitle")
	self.seasonCountDown = objectReference:GetRefValue("seasonCountDown")
	self.ruleTitle = objectReference:GetRefValue("ruleTitle")
	self.remainTextTitle = objectReference:GetRefValue("remainTextTitle")
	self.descScroll = objectReference:GetRefValue("descScroll")
	self.btn1UButton = objectReference:GetRefValue("btn1UButton")
	self.btn2UButton = objectReference:GetRefValue("btn2UButton")
	self.btn3UButton = objectReference:GetRefValue("btn3UButton")
	self.btn4UButton = objectReference:GetRefValue("btn4UButton")
	self.btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
	self.progressUWidget = objectReference:GetRefValue("progressUWidget")
end

function HomelandSeasonMainPageView:registerObjects()
	self.progressObjectRef = self.progressUWidget:GetComponent("ObjectReference")
end

function HomelandSeasonMainPageView:initView()
	return
end

return HomelandSeasonMainPageView
