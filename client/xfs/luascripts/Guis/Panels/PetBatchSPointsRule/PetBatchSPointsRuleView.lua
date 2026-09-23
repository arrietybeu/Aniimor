-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetBatchSPointsRule\\PetBatchSPointsRuleView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetBatchSPointsRuleView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetBatchSPointsRuleView = Class.LightClass("PetBatchSPointsRuleView", UIView)

function PetBatchSPointsRuleView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listAttributeUList = objectReference:GetRefValue("listAttributeUList")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
end

function PetBatchSPointsRuleView:registerObjects()
	return
end

function PetBatchSPointsRuleView:initView()
	return
end

return PetBatchSPointsRuleView
