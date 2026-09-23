-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BigWhiteBall\\BigWhiteBallView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local LuaUIUtils = require("Utils.LuaUIUtils")
local BigWhiteBallView = Class.LightClass("BigWhiteBallView", UIView)
local PRESS_MAX_TIME = 1.5

function BigWhiteBallView:findObjects()
	return
end

function BigWhiteBallView:registerObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootController = self.objectReference:GetRefValue("rootController")
	self.rootAnimation = self.objectReference:GetRefValue("rootAnimation")
	self.pressCancelBtn = self.objectReference:GetRefValue("pressCancelBtn")
	self.boxNumAnim = self.objectReference:GetRefValue("boxNumAnim")
	self.vxStarAnim = self.objectReference:GetRefValue("vxStarAnim")
	self.catchNumParticle2 = self.objectReference:GetRefValue("catchNumParticle2")
	self.catchNumParticle3 = self.objectReference:GetRefValue("catchNumParticle3")
	self.catchNumParticle2g = self.objectReference:GetRefValue("catchNumParticle2g")
	self.cDFinishTs = self.objectReference:GetRefValue("cDFinishTs")
	self.cDFinishTxt = self.objectReference:GetRefValue("cDFinishTxt")
	self.cDFinishProgress = self.objectReference:GetRefValue("cDFinishProgress")
	self.barTime = self.objectReference:GetRefValue("barTime")
	self.barTimeAnim = self.objectReference:GetRefValue("barTimeAnim")
	self.additionTimeTxt = self.objectReference:GetRefValue("additionTimeTxt")
	self.keyHintList = self.objectReference:GetRefValue("keyHintList")
	self.operateUComponent = self.objectReference:GetRefValue("operateUComponent")

	LuaUIUtils.setUIViewVisible(self.cDFinishTxt, false)

	self.cDFinishProgress.maxValue = PRESS_MAX_TIME
end

function BigWhiteBallView:initView()
	return
end

return BigWhiteBallView
