-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Quiz\\QuizView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local QuizView = Class.LightClass("QuizView", UIView)

function QuizView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnQuitUButton = self.objectReference:GetRefValue("btnQuitUButton")
	self.root = self.objectReference:GetRefValue("root")
	self.countDownUCountDown = self.objectReference:GetRefValue("countDownUCountDown")
	self.txtQuestionUSDFText = self.objectReference:GetRefValue("txtQuestionUSDFText")
	self.sliderUSlider = self.objectReference:GetRefValue("sliderUSlider")
	self.listOptionUList = self.objectReference:GetRefValue("listOptionUList")
	self.muteTransform = self.objectReference:GetRefValue("muteTransform")
	self.imgPicUImage = self.objectReference:GetRefValue("imgPicUImage")
	self.countDownWaitUCountDown = self.objectReference:GetRefValue("countDownWaitUCountDown")
	self.picUWidget = self.objectReference:GetRefValue("picUWidget")
end

function QuizView:registerObjects()
	return
end

function QuizView:initView()
	return
end

return QuizView
