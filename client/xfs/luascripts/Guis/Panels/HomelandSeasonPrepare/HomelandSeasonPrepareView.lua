-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandSeasonPrepare\\HomelandSeasonPrepareView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomelandSeasonPrepareView = Class.LightClass("HomelandSeasonPrepareView", UIView)

function HomelandSeasonPrepareView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootUComponent = self.transform:GetComponent("UComponent")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.txtSeasonNameUSDFText = objectReference:GetRefValue("txtSeasonNameUSDFText")
	self.txtProgressUSDFText = objectReference:GetRefValue("txtProgressUSDFText")
	self.txtProgressTitleUSDFText = objectReference:GetRefValue("txtProgressTitleUSDFText")
	self.listGoalUList = objectReference:GetRefValue("listGoalUList")
	self.imgGoalImageUImage = objectReference:GetRefValue("imgGoalImageUImage")
	self.imgGoalLockedUImage = objectReference:GetRefValue("imgGoalLockedUImage")
	self.imgGoalOrderUImage = objectReference:GetRefValue("imgGoalOrderUImage")
	self.txtGoalTitleUSDFText = objectReference:GetRefValue("txtGoalTitleUSDFText")
	self.txtGoalDescUSDFText = objectReference:GetRefValue("txtGoalDescUSDFText")
	self.txtLockedUSDFText = objectReference:GetRefValue("txtLockedUSDFText")
	self.txtComfortTitleUSDFText = objectReference:GetRefValue("txtComfortTitleUSDFText")
	self.txtComfortUSDFText = objectReference:GetRefValue("txtComfortUSDFText")
	self.btnGoUButton = objectReference:GetRefValue("btnGoUButton")

	local btnGoObjectReference = self.btnGoUButton:GetComponent("ObjectReference")

	self.txtGoUText = btnGoObjectReference and btnGoObjectReference:GetRefValue("txtNameUText")
end

function HomelandSeasonPrepareView:registerObjects()
	return
end

function HomelandSeasonPrepareView:initView()
	return
end

return HomelandSeasonPrepareView
