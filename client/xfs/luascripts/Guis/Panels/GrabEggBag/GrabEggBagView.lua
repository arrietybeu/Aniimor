-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggBag\\GrabEggBagView.lua

local logger = require("Core.Log.LoggerManager").getLogger("GrabEggBagView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local GrabEggBagView = Class.LightClass("GrabEggBagView", UIView)

function GrabEggBagView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.playerBagMineUWidget = objectReference:GetRefValue("playerBagMineUWidget")
	self.inventoryContainer = objectReference:GetRefValue("inventoryContainer")
	self.recyclePanelContainer = objectReference:GetRefValue("recyclePanelContainer")
	self.listCurrency = objectReference:GetRefValue("listCurrency")
	self.btnBack = objectReference:GetRefValue("btnBack")
	self.searchPanelContainer = objectReference:GetRefValue("searchPanelContainer")
	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.dragDeleteUButton = objectReference:GetRefValue("dragDeleteUButton")
	self.dropAreaUButton = objectReference:GetRefValue("dropAreaUButton")
	self.keyListUList = objectReference:GetRefValue("keyListUList")
	self.consoleBarTransform = objectReference:GetRefValue("consoleBarTransform")
	self.currencyUWidget = objectReference:GetRefValue("currencyUWidget")
	self.gamePadVirtualBtn1UButton = objectReference:GetRefValue("gamePadVirtualBtn1UButton")
	self.gamePadVirtualBtn2UButton = objectReference:GetRefValue("gamePadVirtualBtn2UButton")
	self.gamePadVirtualBtn3UButton = objectReference:GetRefValue("gamePadVirtualBtn3UButton")
	self.gamePadVirtualBtn4UButton = objectReference:GetRefValue("gamePadVirtualBtn4UButton")
	self.btnJumpUWidget = objectReference:GetRefValue("btnJumpUWidget")
	self.jumpUButton = objectReference:GetRefValue("jumpUButton")
end

function GrabEggBagView:registerObjects()
	return
end

function GrabEggBagView:initView()
	return
end

return GrabEggBagView
