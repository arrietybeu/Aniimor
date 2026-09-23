-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchCountryReward\\PetResearchCountryRewardView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetResearchCountryRewardView = Class.LightClass("PetResearchCountryRewardView", UIView)

function PetResearchCountryRewardView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnClose = self.objectReference:GetRefValue("btnClose")
	self.btnTakeAll = self.objectReference:GetRefValue("btnTakeAll")
	self.listReward = self.objectReference:GetRefValue("listReward")
	self.txtTitle = self.objectReference:GetRefValue("txtTitle")
	self.keyListUList = self.objectReference:GetRefValue("keyListUList")
end

function PetResearchCountryRewardView:registerObjects()
	self.windowAnimation = self.transform:GetComponent("Animation")
end

function PetResearchCountryRewardView:initView()
	return
end

return PetResearchCountryRewardView
