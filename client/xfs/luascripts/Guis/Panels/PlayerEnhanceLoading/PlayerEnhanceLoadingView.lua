-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PlayerEnhanceLoading\\PlayerEnhanceLoadingView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PlayerEnhanceLoadingView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PlayerEnhanceLoadingView = Class.LightClass("PlayerEnhanceLoadingView", UIView)

function PlayerEnhanceLoadingView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.loadingProgressNumUSDFText = objectReference:GetRefValue("loadingProgressNumUSDFText")
	self.btnEnterUButton = objectReference:GetRefValue("btnEnterUButton")
	self.submitTextUSDFText = objectReference:GetRefValue("submitTextUSDFText")
	self.textTtileUSDFText = objectReference:GetRefValue("textTtileUSDFText")
	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
	self.schoolTitleUSDFText = objectReference:GetRefValue("schoolTitleUSDFText")
	self.schoolDesc1USDFText = objectReference:GetRefValue("schoolDesc1USDFText")
	self.schoolDesc2USDFText = objectReference:GetRefValue("schoolDesc2USDFText")
	self.rootCmp = self.transform:GetComponent("UComponent")
	self.rootAnim = self.transform:GetComponent("Animation")
end

function PlayerEnhanceLoadingView:registerObjects()
	return
end

function PlayerEnhanceLoadingView:initView()
	return
end

return PlayerEnhanceLoadingView
