-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchReward\\PetResearchRewardView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetResearchRewardView = Class.LightClass("PetResearchRewardView", UIView)

function PetResearchRewardView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.mask = self.objectReference:GetRefValue("mask")
	self.txtName = self.objectReference:GetRefValue("txtName")
	self.listReward = self.objectReference:GetRefValue("listReward")
	self.progressReward = self.objectReference:GetRefValue("progressReward")
	self.btnClaim = self.objectReference:GetRefValue("btnClaim")
	self.progressRewardRect = self.objectReference:GetRefValue("progressRewardRect")
	self.listNumber2 = self.objectReference:GetRefValue("listNumber2")
	self.fillListNumber2 = self.objectReference:GetRefValue("fillListNumber2")
	self.animation = self.objectReference:GetRefValue("animation")
end

function PetResearchRewardView:registerObjects()
	return
end

function PetResearchRewardView:initView()
	self.progressReward:TryChangePage("type", 0)
end

local rewardCardComponents = {}

function PetResearchRewardView:findRewardCardObjects(button)
	if rewardCardComponents[button] == nil then
		rewardCardComponents[button] = {}
		rewardCardComponents[button].root = button:GetComponent("UButton")
		rewardCardComponents[button].cardRect = button:GetComponent("RectTransform")
		rewardCardComponents[button].listProp = button:Find("ListProp"):GetComponent("UList")
		rewardCardComponents[button].number1 = button:Find("BoxTxt/Number1"):GetComponent("UBaseText")
		rewardCardComponents[button].number2 = button:Find("BoxTxt/Number2"):GetComponent("UBaseText")
		rewardCardComponents[button].btnClaim = button:Find("BtnClaim"):GetComponent("UButton")
	end

	return rewardCardComponents[button]
end

local rewardItemComponents = {}

function PetResearchRewardView:findRewardItemObjects(button)
	if rewardItemComponents[button] == nil then
		rewardItemComponents[button] = {}
		rewardItemComponents[button].root = button:GetComponent("UButton")
		rewardItemComponents[button].imgItem = button:Find("PanelIcon/ImgItem"):GetComponent("UImage")
		rewardItemComponents[button].txtNum = button:Find("PanelNum/TxtNum"):GetComponent("UBaseText")
	end

	return rewardItemComponents[button]
end

return PetResearchRewardView
