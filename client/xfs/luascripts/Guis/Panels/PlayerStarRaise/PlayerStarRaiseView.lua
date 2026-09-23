-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PlayerStarRaise\\PlayerStarRaiseView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PlayerStarRaiseView = Class.LightClass("PlayerStarRaiseView", UIView)

function PlayerStarRaiseView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.playerStarListUList = self.objectReference:GetRefValue("playerStarListUList")
	self.petResearchStarListUList = self.objectReference:GetRefValue("petResearchStarListUList")
	self.vFXWidgetUComponent = self.objectReference:GetRefValue("vFXWidgetUComponent")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.textUText = self.objectReference:GetRefValue("textUText")
	self.textUpUText = self.objectReference:GetRefValue("textUpUText")
	self.keyWordUButton = self.objectReference:GetRefValue("keyWordUButton")
end

function PlayerStarRaiseView:registerObjects()
	self.rootComponent = self.transform:GetComponent("UComponent")

	local objectReference = self.keyWordUButton:GetComponent("ObjectReference")

	self.keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")
end

function PlayerStarRaiseView:initView()
	return
end

return PlayerStarRaiseView
