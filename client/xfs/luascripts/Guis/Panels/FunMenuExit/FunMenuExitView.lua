-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FunMenuExit\\FunMenuExitView.lua

local logger = require("Core.Log.LoggerManager").getLogger("FunMenuExitView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local FunMenuExitView = Class.LightClass("FunMenuExitView", UIView)

function FunMenuExitView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listItemUList = objectReference:GetRefValue("listItemUList")
	self.btnReturn1 = objectReference:GetRefValue("btnReturn1")
	self.btnReturn2 = objectReference:GetRefValue("btnReturn2")
	self.txtReturn1 = objectReference:GetRefValue("txtReturn1")
	self.txtReturn2 = objectReference:GetRefValue("txtReturn2")
	self.btnExit1 = objectReference:GetRefValue("btnExit1")
	self.btnExit2 = objectReference:GetRefValue("btnExit2")
	self.txtExit1 = objectReference:GetRefValue("txtExit1")
	self.txtExit2 = objectReference:GetRefValue("txtExit2")
	self.consoleBarTransform = objectReference:GetRefValue("consoleBarTransform")
	self.rootUComponent = objectReference:GetRefValue("rootUComponent")

	local objectReference = self.transform:GetComponent("ObjectReference")

	self.battleRoomInfoUContainer = objectReference:GetRefValue("battleRoomInfoUContainer")
end

return FunMenuExitView
