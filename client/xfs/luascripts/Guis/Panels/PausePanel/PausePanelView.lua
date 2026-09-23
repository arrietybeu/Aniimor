-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PausePanel\\PausePanelView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PausePanelView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PausePanelView = Class.LightClass("PausePanelView", UIView)

function PausePanelView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnContinueUButton = self.objectReference:GetRefValue("btnContinueUButton")
	self.btnSuspendUButton = self.objectReference:GetRefValue("btnSuspendUButton")
	self.btnSettlementUButton = self.objectReference:GetRefValue("btnSettlementUButton")
end

function PausePanelView:registerObjects()
	local objectReference = self.btnContinueUButton:GetComponent("ObjectReference")

	self.btnContinueText = objectReference:GetRefValue("txtNameUText")

	local objectReference = self.btnSuspendUButton:GetComponent("ObjectReference")

	self.btnSuspendText = objectReference:GetRefValue("txtNameUText")

	local objectReference = self.btnSettlementUButton:GetComponent("ObjectReference")

	self.btnSettlementText = objectReference:GetRefValue("txtNameUText")
end

function PausePanelView:initView()
	return
end

return PausePanelView
