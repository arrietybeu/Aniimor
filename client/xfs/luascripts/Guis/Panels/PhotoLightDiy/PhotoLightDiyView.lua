-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PhotoLightDiy\\PhotoLightDiyView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PhotoLightDiyView = Class.LightClass("PhotoLightDiyView", UIView)

function PhotoLightDiyView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnRenameUButton = objectReference:GetRefValue("btnRenameUButton")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.listTab3thUList = objectReference:GetRefValue("listTab3thUList")
	self.listUList = objectReference:GetRefValue("listUList")
	self.textNameUBaseText = objectReference:GetRefValue("textNameUBaseText")
	self.light1UButton = objectReference:GetRefValue("light1UButton")
	self.light2UButton = objectReference:GetRefValue("light2UButton")
	self.light3UButton = objectReference:GetRefValue("light3UButton")
end

function PhotoLightDiyView:registerObjects()
	return
end

function PhotoLightDiyView:initView()
	return
end

return PhotoLightDiyView
