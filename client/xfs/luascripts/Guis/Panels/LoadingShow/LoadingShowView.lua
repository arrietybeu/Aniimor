-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LoadingShow\\LoadingShowView.lua

local logger = require("Core.Log.LoggerManager").getLogger("LoadingShowView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local LoadingShowView = Class.LightClass("LoadingShowView", UIView)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")

function LoadingShowView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.adaptationUWidget = objectReference:GetRefValue("adaptationUWidget")
	self.textMatterUSDFText = objectReference:GetRefValue("textMatterUSDFText")
	self.btnNextUButton = objectReference:GetRefValue("btnNextUButton")
	self.programNum = objectReference:GetRefValue("programNum")
	self.progressLoad = objectReference:GetRefValue("progressLoad")
	self.mainPanel = objectReference:GetRefValue("mainPanel")
	self.mainAni = objectReference:GetRefValue("mainAni")
	self.btnName = objectReference:GetRefValue("btnName")
	self.backGroundCloseUButton = objectReference:GetRefValue("backGroundCloseUButton")
	self.countDownUWidget = objectReference:GetRefValue("countDownUWidget")
	self.consoleBar = objectReference:GetRefValue("consoleBar")
	self.bgImage = objectReference:GetRefValue("bgImage")

	if self.bgImage then
		self.bgImage.forceSyncLoad = true
	end
end

function LoadingShowView:registerObjects()
	return
end

function LoadingShowView:initView()
	return
end

function LoadingShowView:setLoadProgressVisible(active)
	LuaUIUtils.setUIViewVisible(self.countDownUWidget, active)
end

function LoadingShowView:updateLoadProgress(value)
	self.programNum.text = tostring(math.modf(value * 100))
	self.progressLoad.fillAmount = value
end

function LoadingShowView:changeLoadingStyle(value)
	self.mainPanel:TryChangePage("LoadingStyle", value)
end

function LoadingShowView:setNextBtnVisible(isOn)
	LuaUIUtils.setUIViewVisible(self.btnNextUButton, isOn)
end

function LoadingShowView:setNextBtnTxt(str)
	ClientTextUtils.setText(self.btnName, str)
end

function LoadingShowView:refreshTxtContent(chat)
	ClientTextUtils.setText(self.textMatterUSDFText, LuaUIUtils.getReplacedDialogueText(chat))
end

return LoadingShowView
