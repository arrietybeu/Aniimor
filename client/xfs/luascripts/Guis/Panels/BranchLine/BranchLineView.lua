-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BranchLine\\BranchLineView.lua

local logger = require("Core.Log.LoggerManager").getLogger("BranchLineView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local BranchLineView = Class.LightClass("BranchLineView", UIView)

function BranchLineView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.branchList = self.objectReference:GetRefValue("branchList")
	self.btnConfirmUButton = self.objectReference:GetRefValue("btnConfirmUButton")
	self.btnCancelUButton = self.objectReference:GetRefValue("btnCancelUButton")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
end

function BranchLineView:registerObjects()
	return
end

function BranchLineView:initView()
	return
end

return BranchLineView
