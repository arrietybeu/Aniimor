-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DialogueModule\\DialogReview\\DialogReviewView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local DialogReviewView = Class.LightClass("DialogReviewView", UIView)

function DialogReviewView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.returnBtn = self.objectReference:GetRefValue("returnBtn")
	self.contentList = self.objectReference:GetRefValue("contentList")
	self.consoleBarUWidget = self.objectReference:GetRefValue("consoleBarUWidget")
	self.blurUWidget = self.objectReference.transform:Find("Blur"):GetComponent("UWidget")
end

function DialogReviewView:registerObjects()
	return
end

function DialogReviewView:initView()
	return
end

return DialogReviewView
