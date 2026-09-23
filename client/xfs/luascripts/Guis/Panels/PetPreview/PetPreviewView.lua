-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetPreview\\PetPreviewView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetPreviewView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetPreviewView = Class.LightClass("PetPreviewView", UIView)

function PetPreviewView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.cornerCloseUButton = self.objectReference:GetRefValue("cornerCloseUButton")
	self.txtTitleUBaseText = self.objectReference:GetRefValue("txtTitleUBaseText")
	self.listUList = self.objectReference:GetRefValue("listUList")
end

function PetPreviewView:registerObjects()
	return
end

function PetPreviewView:initView()
	return
end

return PetPreviewView
