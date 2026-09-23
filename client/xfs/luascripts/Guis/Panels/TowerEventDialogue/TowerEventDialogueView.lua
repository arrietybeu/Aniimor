-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerEventDialogue\\TowerEventDialogueView.lua

local logger = require("Core.Log.LoggerManager").getLogger("TowerEventDialogueView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TowerEventDialogueView = Class.LightClass("TowerEventDialogueView", UIView)

function TowerEventDialogueView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.currencyItemUButton = objectReference:GetRefValue("currencyItemUButton")
	self.eventTitleUBaseText = objectReference:GetRefValue("eventTitleUBaseText")
	self.eventDescUBaseText = objectReference:GetRefValue("eventDescUBaseText")
	self.selectorUList = objectReference:GetRefValue("selectorUList")
	self.choseUBaseText = objectReference:GetRefValue("choseUBaseText")
	self.resultTitleUBaseText = objectReference:GetRefValue("resultTitleUBaseText")
	self.resultContentUBaseText = objectReference:GetRefValue("resultContentUBaseText")
	self.closeUBaseText = objectReference:GetRefValue("closeUBaseText")
	self.nextUButton = objectReference:GetRefValue("nextUButton")
	self.arrowUpUButton = objectReference:GetRefValue("arrowUpUButton")
	self.arrowDownUButton = objectReference:GetRefValue("arrowDownUButton")
end

function TowerEventDialogueView:registerObjects()
	return
end

function TowerEventDialogueView:initView()
	return
end

return TowerEventDialogueView
