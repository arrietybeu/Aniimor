-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerPause\\TowerPauseView.lua

local logger = require("Core.Log.LoggerManager").getLogger("TowerPauseView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TowerPauseView = Class.LightClass("TowerPauseView", UIView)

function TowerPauseView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnContinueUButton = self.objectReference:GetRefValue("btnContinueUButton")
	self.btnSuspendUButton = self.objectReference:GetRefValue("btnSuspendUButton")
	self.btnSettlementUButton = self.objectReference:GetRefValue("btnSettlementUButton")
	self.btnRetryUButton = self.objectReference:GetRefValue("btnRetryUButton")
end

function TowerPauseView:registerObjects()
	return
end

function TowerPauseView:initView()
	return
end

return TowerPauseView
