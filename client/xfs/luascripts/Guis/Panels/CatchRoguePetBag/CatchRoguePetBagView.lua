-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CatchRoguePetBag\\CatchRoguePetBagView.lua

local logger = require("Core.Log.LoggerManager").getLogger("CatchRoguePetBagView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local CatchRoguePetBagView = Class.LightClass("CatchRoguePetBagView", UIView)

function CatchRoguePetBagView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootWidget = self.objectReference:GetRefValue("rootWidget")
	self.listPetUList = self.objectReference:GetRefValue("listPetUList")
	self.petInfoPanelUWidget = self.objectReference:GetRefValue("petInfoPanelUWidget")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
end

function CatchRoguePetBagView:registerObjects()
	return
end

function CatchRoguePetBagView:initView()
	return
end

return CatchRoguePetBagView
